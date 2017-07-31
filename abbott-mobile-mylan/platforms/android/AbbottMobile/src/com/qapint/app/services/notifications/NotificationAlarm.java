package com.qapint.app.services.notifications;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;

public class NotificationAlarm {

    public static void setNextAlarm(Context context, long time, String callId) {
        AlarmManager alarms = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        alarms.cancel(getNotifierIntent(context, callId));
        alarms.set(AlarmManager.RTC_WAKEUP, time, getNotifierIntent(context, callId));
    }

    public static void cancelAlarm(Context context) {
        AlarmManager alarms = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        alarms.cancel(getNotifierIntent(context, "0"));
        NotificationServiceManager nService = new NotificationServiceManager();
        nService.clearAllNotifications(context);
    }

    private static PendingIntent getNotifierIntent(Context context, String callId) {
        Intent notifier = new Intent(context, NotificationServiceManager.class);
        notifier.putExtra(NotificationServiceManager.CALL_REPORT_ID, callId);
        return PendingIntent.getService(context, 0, notifier, PendingIntent.FLAG_CANCEL_CURRENT);
    }

}