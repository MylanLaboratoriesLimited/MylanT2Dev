package com.qapint.app.phonegap;

import org.json.JSONArray;

import android.content.Context;
import android.view.inputmethod.InputMethodManager;

import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaPlugin;

import android.graphics.Rect;
import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;


public class SoftKeyboard extends CordovaPlugin {

    public SoftKeyboard() {
    }

    public void showKeyBoard() {
      InputMethodManager mgr = (InputMethodManager) cordova.getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
      mgr.showSoftInput(webView, InputMethodManager.SHOW_IMPLICIT);

      ((InputMethodManager) cordova.getActivity().getSystemService(Context.INPUT_METHOD_SERVICE)).showSoftInput(webView, 0);
    }

    public void hideKeyBoard() {
      InputMethodManager mgr = (InputMethodManager) cordova.getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
      mgr.hideSoftInputFromWindow(webView.getWindowToken(), 0);
    }

    public boolean isKeyBoardShowing() {
      int heightDiff = webView.getRootView().getHeight() - webView.getHeight();
      return (100 < heightDiff); // if more than 100 pixels, its probably a keyboard...
    }

    public int getAvailScreenHeight() {
      Rect r = new Rect();
      webView.getWindowVisibleDisplayFrame(r);
      int heightDiff = r.bottom - r.top;
      return heightDiff;
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
    if (action.equals("show")) {
      this.showKeyBoard();
      callbackContext.success("done");
      return true;
    }
    else if (action.equals("hide")) {
      this.hideKeyBoard();
      callbackContext.success();
      return true;
    }
    else if (action.equals("isShowing")) {
      callbackContext.success(Boolean.toString(this.isKeyBoardShowing()));
      return true;
    }
    else if (action.equals("getAvailScreenHeight")) {
       callbackContext.success(Integer.toString(this.getAvailScreenHeight()));
       return true;
    }
    else {
      return false;
    }
  }
}

