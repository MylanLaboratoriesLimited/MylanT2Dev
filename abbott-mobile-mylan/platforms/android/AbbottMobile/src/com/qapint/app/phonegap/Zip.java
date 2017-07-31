package com.qapint.app.phonegap;

import java.io.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import android.net.Uri;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import android.util.Log;

public class Zip extends CordovaPlugin {
    private static final String LOG_TAG = "Zip";

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if ("unzip".equals(action)) {
            unzip(args, callbackContext);
            return true;
        }
        return false;
    }

    private void unzip(final JSONArray args, final CallbackContext callbackContext) {
        this.cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                unzipSync(args, callbackContext);
            }
        });
    }

    private static int readInt(InputStream is) throws IOException {
        int a = is.read();
        int b = is.read();
        int c = is.read();
        int d = is.read();
        return a | b << 8 | c << 16 | d << 24;
    }

    private void unzipSync(JSONArray args, CallbackContext callbackContext) {
        InputStream inputStream = null;
        try {
            String zipFileName = args.getString(0);
            String outputDirectory = args.getString(1);

            File outputDir = getFileFromPath(outputDirectory);
            outputDirectory = outputDir.getAbsolutePath();
            outputDirectory += outputDirectory.endsWith(File.separator) ? "" : File.separator;
            if (outputDir == null || (!outputDir.exists() && !outputDir.mkdirs())) {
                throw new FileNotFoundException("File: \"" + outputDirectory + "\" not found");
            }

            inputStream = new BufferedInputStream(getPathFromUri(zipFileName));
            inputStream.mark(10);
            int magic = readInt(inputStream);

            if (magic != 875721283) {
                inputStream.reset();
            } else {
                readInt(inputStream);
                int pubkeyLength = readInt(inputStream);
                int signatureLength = readInt(inputStream);
                inputStream.skip(pubkeyLength + signatureLength);
            }

            ZipInputStream zis = new ZipInputStream(inputStream);
            inputStream = zis;
            ZipEntry ze;
            byte[] buffer = new byte[64 * 1024];
            boolean anyEntries = false;

            while ((ze = zis.getNextEntry()) != null) {
                anyEntries = true;
                String compressedName = ze.getName();
                if (ze.isDirectory()) {
                    File dir = new File(outputDirectory + compressedName);
                    dir.mkdirs();
                } else {
                    File file = new File(outputDirectory + compressedName);
                    file.getParentFile().mkdirs();
                    if (file.exists() || file.createNewFile()) {
                        Log.w("Zip", "extracting: " + file.getPath());
                        FileOutputStream fout = new FileOutputStream(file);
                        int count;
                        while ((count = zis.read(buffer)) != -1) {
                            fout.write(buffer, 0, count);
                        }
                        fout.close();
                    }
                }
                zis.closeEntry();
            }
            if (anyEntries)
                callbackContext.success();
            else
                callbackContext.error("Bad zip file");
        } catch (Exception e) {
            String errorMessage = "An error occurred while unzipping.";
            callbackContext.error(errorMessage);
            Log.e(LOG_TAG, errorMessage, e);
        } finally {
            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (IOException e) {
                }
            }
        }
    }

    private InputStream getPathFromUri(String path) throws FileNotFoundException {
        if (path.startsWith("content:")) {
            Uri uri = Uri.parse(path);
            return cordova.getActivity().getContentResolver().openInputStream(uri);
        } else if (path.startsWith("file://")) {
            int question = path.indexOf("?");
            if (question == -1) {
                return new FileInputStream(path.substring(7));
            } else {
                return new FileInputStream(path.substring(7, question));
            }
        } else {
            return new FileInputStream(path);
        }
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
}
