package com.qapint.app.phonegap;

import android.content.Context;
import android.util.Log;
import com.qapint.app.services.notifications.NotificationAlarm;
import com.qapint.app.services.notifications.NotificationServiceManager;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaInterface;
import org.apache.cordova.api.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONObject;

public class SBNotifier extends CordovaPlugin {
    public static final String TAG = "StatusBar notifier";
    Context context = null;

    public SBNotifier() {
    }

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        context = cordova.getActivity().getApplicationContext();
    }

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        JSONObject responseParams = new JSONObject();
        try {
            NotificationServiceManager serviceManager = new NotificationServiceManager();
            if (action.equals("scheduleNextVisits")) {
                serviceManager.scheduleNextVisits(context);
            } else if (action.equals("cancelNotification")) {
                NotificationAlarm.cancelAlarm(context);
            }
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            callbackContext.error(e.getMessage());
            return false;
        }
        callbackContext.success(responseParams);
        return true;
    }

}
