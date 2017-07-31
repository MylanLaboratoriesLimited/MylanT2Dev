package com.qapint.app.phonegap;

import android.content.Intent;
import android.net.Uri;
import android.view.View;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import com.qapint.app.activities.PresentationView;
import com.artifex.mupdfviewer.*;
import org.apache.cordova.api.*;
import org.json.JSONArray;

public class PresentationViewer extends CordovaPlugin {
    protected static final String LOG_TAG = "Presentation View";
    protected static final String EVENT_DID_LOAD = "DID_LOAD";
    protected static final String EVENT_ON_COMPLETE = "ON_COMPLETE";
    private CallbackContext callbackContext = null;
    private PresentationView presentationView = null;

    @Override
    public boolean execute(final String action, JSONArray args, final CallbackContext callbackContext){
        String result = "";
        if ("openPresentation".equals(action)) {
            try {
                this.callbackContext = callbackContext;
                if (presentationView != null && presentationView.isShowing()) {
                    sendResult(PluginResult.Status.ERROR, "Presentation viewer is already open");
                    return false;
                }

                if (args.length() == 1) {
                    result = this.showWebPage(args.getString(0));
                } else {
                    result = this.showWebPage(args.getString(0) + "?structure=" + args.getString(1));
                }

                if (result.length() > 0) {
                    sendResult(PluginResult.Status.ERROR, result);
                    return false;
                } else {
                    sendResult(PluginResult.Status.OK, "Show presentation");
                    return true;
                }
            } catch (Exception e) {
                sendResult(PluginResult.Status.INVALID_ACTION, result);
                return false;
            }
        } else if ("closePresentation".equals(action)) {
            if (presentationView != null) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        presentationView.clearKpi(); // clear KPI from storage
                    }
                });
                
                try {
                    presentationView.dismiss();
                    sendResult(PluginResult.Status.OK, "Presentation closed");
                    return true;
                } catch (Exception e) {
                    sendResult(PluginResult.Status.ERROR, e.getMessage());
                    return false;
                }
            } else {
                sendResult(PluginResult.Status.ERROR, "Presentation wasn't opened");
                return false;
            }
        } else if ("getKPI".equals(action)) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    presentationView.getKpi(new ValueCallback<String>() {
                        @Override
                        public void onReceiveValue(String kpiString) {
                            kpiString = kpiString == null ? "" : unescapeJson(kpiString);
                            callbackContext.success(kpiString);
                        }
                    });
                }
            });
        }else{
            sendResult(PluginResult.Status.INVALID_ACTION, "");
            return false;
        }
        return true;
    }

    private String unescapeJson(String jsonString){
        return jsonString.replace("\"{", "{").replace("}\"", "}").replace("\\\"", "\"");
    }

    public void sendResult(PluginResult.Status status, String data){
        PluginResult result = new PluginResult(status, data);
        result.setKeepCallback(true);
        callbackContext.sendPluginResult(result);
    }

    public String showWebPage(final String url) {
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                presentationView = new PresentationView(webView.getContext());
                presentationView.setOnCompleteListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        if (callbackContext != null) {
                            sendResult(PluginResult.Status.OK, EVENT_ON_COMPLETE);
                        }
                    }
                });
                presentationView.setWebClient(new PresentationViewClient(cordova));
                presentationView.viewByUrl(url);
            }
        });
        return "";
    }

    private void openPdf(String path) {
        Uri fileUri = Uri.parse(path);
        Intent intent = new Intent(webView.getContext(), MuPDFActivity.class);
        intent.setAction(Intent.ACTION_VIEW);
        intent.setData(fileUri);
        webView.getContext().startActivity(intent);
    }

    public class PresentationViewClient extends WebViewClient {
        CordovaInterface ctx;

        public PresentationViewClient(CordovaInterface mContext) {
            ctx = mContext;
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            if (callbackContext != null) {
                sendResult(PluginResult.Status.OK, EVENT_DID_LOAD);
            }
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url){
            if(url.startsWith("file") && url.endsWith(".pdf")){
                openPdf(url);
                return true;
            }else{
                return super.shouldOverrideUrlLoading(view, url);
            }
        }
    }
}
