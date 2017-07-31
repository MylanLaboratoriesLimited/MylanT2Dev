package com.qapint.app.phonegap;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.webkit.MimeTypeMap;
import com.artifex.mupdfviewer.MuPDFActivity;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;

public class AttachmentsViewer extends CordovaPlugin {
    private static String TAG = "Attachments Viewer";

    private String getMimeType(Uri fileUri){
        String extension = fileUri.getLastPathSegment();
        extension = extension.substring(extension.lastIndexOf(".") + 1);
        String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
        if(null == mimeType || "".equals(mimeType)){
            mimeType = "*/*";
        }
        return mimeType;
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if ("open".equals(action)) {
            try {
                JSONObject parameters = args.getJSONObject(0);
                if (parameters != null) {
                    String path = parameters.getString("filePath");
                    String mimeType = parameters.getString("mimeType");
                    if (null == path) {
                        return false;
                    }

                    Uri uri = Uri.fromFile(new File(path));
                    if(null == mimeType || "".equals(mimeType)){
                        mimeType = getMimeType(uri);
                    }

                    open(uri, mimeType);
                }
            } catch (Exception e) {
                Log.e(TAG, e.getMessage());
                return false;
            }
            callbackContext.success();
            return true;
        }
        return false;
    }

    private void open(Uri fileUri, String mimeType) {
        Log.d(TAG, String.format("%s %s", fileUri.toString(), mimeType));

        Intent openFileIntent;
        if (mimeType.contains("application/pdf") || mimeType.contains("image/")) {
            openFileIntent = new Intent(webView.getContext(), MuPDFActivity.class);
            openFileIntent.setAction(Intent.ACTION_VIEW);
            openFileIntent.setData(fileUri);
        } else {
            openFileIntent = new Intent(Intent.ACTION_VIEW);
            openFileIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            openFileIntent.setDataAndType(fileUri, mimeType);
        }
        webView.getContext().startActivity(openFileIntent);
    }
}