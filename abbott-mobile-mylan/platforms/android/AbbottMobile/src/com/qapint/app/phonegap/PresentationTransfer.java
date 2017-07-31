/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
*/
package com.qapint.app.phonegap;

import java.io.Closeable;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FilterInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.HashMap;
import java.util.Iterator;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import org.apache.cordova.FileUtils;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.apache.cordova.api.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.os.Build;
import android.util.Log;
import android.webkit.CookieManager;

public class PresentationTransfer extends CordovaPlugin {
    private static final String LOG_TAG = "PresentationTransfer";
    private static final int MAX_BUFFER_SIZE = 64 * 1024;
    private static HashMap<String, RequestContext> activeRequests = new HashMap<String, RequestContext>();

    public static int FILE_NOT_FOUND_ERR = 1;
    public static int INVALID_URL_ERR = 2;
    public static int CONNECTION_ERR = 3;
    public static int ABORTED_ERR = 4;

    public static final class RequestContext {
        String source;
        String target;
        CallbackContext callbackContext;
        InputStream currentInputStream;
        OutputStream currentOutputStream;
        boolean aborted;
        RequestContext(String source, String target, CallbackContext callbackContext) {
            this.source = source;
            this.target = target;
            this.callbackContext = callbackContext;
        }
        void sendPluginResult(PluginResult pluginResult) {
            synchronized (this) {
                if (!aborted) {
                    callbackContext.sendPluginResult(pluginResult);
                }
            }
        }
    }

    private static final class DoneHandlerInputStream extends FilterInputStream {
        private boolean done;
        public DoneHandlerInputStream(InputStream stream) {
            super(stream);
        }
        
        @Override
        public int read() throws IOException {
            int result = done ? -1 : super.read();
            done = (result == -1);
            return result;
        }

        @Override
        public int read(byte[] buffer) throws IOException {
            int result = done ? -1 : super.read(buffer);
            done = (result == -1);
            return result;
        }

        @Override
        public int read(byte[] bytes, int offset, int count) throws IOException {
            int result = done ? -1 : super.read(bytes, offset, count);
            done = (result == -1);
            return result;
        }
    }
    
    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("upload") || action.equals("download")) {
            String source = args.getString(0);
            String target = args.getString(1);
            if (action.equals("download")) {
                download(source, target, args, callbackContext);
            }
            return true;
        } else if (action.equals("abort")) {
            String objectId = args.getString(0);
            abort(objectId);
            callbackContext.success();
            return true;
        }
        return false;
    }

     private static void addHeadersToRequest(URLConnection connection, JSONObject headers) {
        try {
            for (Iterator<?> iter = headers.keys(); iter.hasNext(); ) {
                String headerKey = iter.next().toString();
                JSONArray headerValues = headers.optJSONArray(headerKey);
                if (headerValues == null) {
                    headerValues = new JSONArray();
                    headerValues.put(headers.getString(headerKey));
                }
                connection.setRequestProperty(headerKey, headerValues.getString(0));
                for (int i = 1; i < headerValues.length(); ++i) {
                    connection.addRequestProperty(headerKey, headerValues.getString(i));
                }
            }
        } catch (JSONException e1) {
          // No headers to be manipulated!
        }
    }

    private static void safeClose(Closeable stream) {
        if (stream != null) {
            try {
                stream.close();
            } catch (IOException e) {
            }
        }
    }

    private static InputStream getInputStream(HttpURLConnection conn) throws IOException {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
            return new DoneHandlerInputStream(conn.getInputStream());
        }
        return conn.getInputStream();
    }

    private static final HostnameVerifier DO_NOT_VERIFY = new HostnameVerifier() {
        public boolean verify(String hostname, SSLSession session) {
            return true;
        }
    };

    private static final TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
        public java.security.cert.X509Certificate[] getAcceptedIssuers() {
            return new java.security.cert.X509Certificate[] {};
        }
        
        public void checkClientTrusted(X509Certificate[] chain,
                String authType) throws CertificateException {
        }
        
        public void checkServerTrusted(X509Certificate[] chain,
                String authType) throws CertificateException {
        }
    } };

    private static SSLSocketFactory trustAllHosts(HttpsURLConnection connection) {
        SSLSocketFactory oldFactory = connection.getSSLSocketFactory();
        try {
            SSLContext sc = SSLContext.getInstance("TLS");
            sc.init(null, trustAllCerts, new java.security.SecureRandom());
            SSLSocketFactory newFactory = sc.getSocketFactory();
            connection.setSSLSocketFactory(newFactory);
        } catch (Exception e) {
            Log.e(LOG_TAG, e.getMessage(), e);
        }
        return oldFactory;
    }

    private static JSONObject createFileTransferError(int errorCode, String source, String target, HttpURLConnection connection) {
        Integer httpStatus = null;
        if (connection != null) {
            try {
                httpStatus = connection.getResponseCode();
            } catch (IOException e) {
                Log.w(LOG_TAG, "Error getting HTTP status code from connection.", e);
            }
        }
        return createFileTransferError(errorCode, source, target, httpStatus);
    }

    private static JSONObject createFileTransferError(int errorCode, String source, String target, Integer httpStatus) {
        JSONObject error = null;
        try {
            error = new JSONObject();
            error.put("code", errorCode);
            error.put("source", source);
            error.put("target", target);
            if (httpStatus != null) {
                error.put("http_status", httpStatus);
            }
        } catch (JSONException e) {
            Log.e(LOG_TAG, e.getMessage(), e);
        }
        return error;
    }



    private void download(final String source, final String target, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(LOG_TAG, "download " + source + " to " +  target);
        final boolean trustEveryone = args.optBoolean(2);
        final String objectId = args.getString(3);
        final JSONObject headers = args.optJSONObject(4);

        final URL url;
        try {
            url = new URL(source);
        } catch (MalformedURLException e) {
            JSONObject error = createFileTransferError(INVALID_URL_ERR, source, target, 0);
            Log.e(LOG_TAG, error.toString(), e);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.IO_EXCEPTION, error));
            return;
        }
        final boolean useHttps = url.getProtocol().toLowerCase().equals("https");
        if (!webView.isUrlWhiteListed(source)) {
            Log.w(LOG_TAG, "Source URL is not in white list: '" + source + "'");
            JSONObject error = createFileTransferError(CONNECTION_ERR, source, target, 401);
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.IO_EXCEPTION, error));
            return;
        }

        
        final RequestContext context = new RequestContext(source, target, callbackContext);
        synchronized (activeRequests) {
            activeRequests.put(objectId, context);
        }
        
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                if (context.aborted) {
                    return;
                }
                HttpURLConnection connection = null;
                HostnameVerifier oldHostnameVerifier = null;
                SSLSocketFactory oldSocketFactory = null;
                try {
                    File file = getFileFromPath(target);
                    file.getParentFile().mkdirs();
                    if (useHttps) {
                        if (!trustEveryone) {
                            connection = (HttpsURLConnection) url.openConnection();
                        }
                        else {
                            HttpsURLConnection https = (HttpsURLConnection) url.openConnection();
                            oldSocketFactory = trustAllHosts(https);
                            oldHostnameVerifier = https.getHostnameVerifier();
                            https.setHostnameVerifier(DO_NOT_VERIFY);
                            connection = https;
                        }
                    }
                    else {
                          connection = (HttpURLConnection) url.openConnection();
                    }
                    connection.setRequestMethod("GET");
                    String cookie = CookieManager.getInstance().getCookie(source);
                    if(cookie != null)
                    {
                        connection.setRequestProperty("cookie", cookie);
                    }
                    // Handle the other headers
                    if (headers != null) {
                        addHeadersToRequest(connection, headers);
                    }
                    connection.connect();
                    Log.d(LOG_TAG, "Download file:" + url);
                    TransferNotifier progressNotifier = new TransferNotifier(context);
                    if (connection.getContentEncoding() == null) {
                        progressNotifier.setLengthComputable(true);
                        progressNotifier.setTotalFileLength(connection.getContentLength());
                    }
                    
                    FileOutputStream outputStream = new FileOutputStream(file);
                    InputStream inputStream = null;
                    try {
                        inputStream = getInputStream(connection);
                        synchronized (context) {
                            if (context.aborted) {
                                return;
                            }
                            context.currentInputStream = inputStream;
                        }
                        byte[] buffer = new byte[MAX_BUFFER_SIZE];
                        int bytesRead = 0;
                        while ((bytesRead = inputStream.read(buffer)) > 0) {
                            outputStream.write(buffer, 0, bytesRead);
                            progressNotifier.shouldNotify(bytesRead);
                        }
                    } finally {
                        context.currentInputStream = null;
                        safeClose(inputStream);
                        safeClose(outputStream);
                    }
                    Log.d(LOG_TAG, "Saved file: " + target);

                    FileUtils fileUtil = new FileUtils();
                    JSONObject fileEntry = fileUtil.getEntry(file);
                    context.sendPluginResult(new PluginResult(PluginResult.Status.OK, fileEntry));
                } catch (FileNotFoundException e) {
                    JSONObject error = createFileTransferError(FILE_NOT_FOUND_ERR, source, target, connection);
                    Log.e(LOG_TAG, error.toString(), e);
                    context.sendPluginResult(new PluginResult(PluginResult.Status.IO_EXCEPTION, error));
                } catch (IOException e) {
                    JSONObject error = createFileTransferError(CONNECTION_ERR, source, target, connection);
                    Log.e(LOG_TAG, error.toString(), e);
                    context.sendPluginResult(new PluginResult(PluginResult.Status.IO_EXCEPTION, error));
                } catch (JSONException e) {
                    Log.e(LOG_TAG, e.getMessage(), e);
                    context.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION));
                } catch (Throwable e) {
                    JSONObject error = createFileTransferError(CONNECTION_ERR, source, target, connection);
                    Log.e(LOG_TAG, error.toString(), e);
                    context.sendPluginResult(new PluginResult(PluginResult.Status.IO_EXCEPTION, error));
                } finally {
                    synchronized (activeRequests) {
                        activeRequests.remove(objectId);
                    }
                    if (connection != null) {
                        if (trustEveryone && useHttps) {
                            HttpsURLConnection https = (HttpsURLConnection) connection;
                            https.setHostnameVerifier(oldHostnameVerifier);
                            https.setSSLSocketFactory(oldSocketFactory);
                        }
                        connection.disconnect();
                    }
                }
            }
        });
    }

    private File getFileFromPath(String path) throws FileNotFoundException {
        File file;
        String prefix = "file://";
        if (path.startsWith(prefix)) {
            file = new File(path.substring(prefix.length()));
        } else {
            file = new File(path);
        }
        if (file.getParent() == null) {
            throw new FileNotFoundException();
        }
        return file;
    }

    private void abort(String objectId) {
        final RequestContext context;
        synchronized (activeRequests) {
            context = activeRequests.remove(objectId);
        }
        if (context != null) {
            JSONObject error = createFileTransferError(ABORTED_ERR, context.source, context.target, -1);
            synchronized (context) {
                context.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, error));
                context.aborted = true;
            }
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    synchronized (context) {
                        safeClose(context.currentInputStream);
                        safeClose(context.currentOutputStream);
                    }
                }
            });
        }
    }
}
