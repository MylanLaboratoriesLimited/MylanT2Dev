package com.qapint.app.activities;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;

public class PresentationWebView extends WebView {
    Context context = null;
    private ValueCallback<String> evalCallback;

    public PresentationWebView(Context context, int style) {
        super(context, null, style);
        this.context = context;

        setupWebView();
        setViewSettings();
    }

    public void load(String url) {
        loadUrl(url);
    }

    public void executeMethodWithName(String methodName, ValueCallback<String> callback) {
        evalCallback = callback;
        loadUrl(String.format("javascript:PresentationViewer.getEvalResult('%s', executeMethod('%s'));", methodName, methodName));
    }

    private void setupWebView() {
        setInitialScale(0);
        setVerticalScrollBarEnabled(false);
        addJavascriptInterface(new JSEvalInterface(), "PresentationViewer");
    }

    @SuppressLint("SetJavaScriptEnabled")
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private void setViewSettings() {
        WebSettings webviewSettings = getSettings();
        webviewSettings.setDomStorageEnabled(true);
        webviewSettings.setJavaScriptEnabled(true);
        webviewSettings.setBuiltInZoomControls(false);
        webviewSettings.setDisplayZoomControls(false);
        webviewSettings.setUseWideViewPort(true);
        webviewSettings.setLoadWithOverviewMode(true);
    }
    public class JSEvalInterface {
        JSEvalInterface() {}

        @JavascriptInterface
        public void getEvalResult(String method, String value) {
            if(evalCallback!=null){
                evalCallback.onReceiveValue(value);
            }
        }
    }

}
