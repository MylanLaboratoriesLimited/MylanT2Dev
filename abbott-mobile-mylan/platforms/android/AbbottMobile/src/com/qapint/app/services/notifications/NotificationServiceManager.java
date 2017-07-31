package com.qapint.app.services.notifications;

import java.util.Date;
import java.util.List;

import android.app.*;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.TaskStackBuilder;
import android.text.format.DateUtils;
import com.qapint.app.R;
import com.qapint.app.activities.AbbottMobile;
import com.qapint.app.bll.CallReportController;
import com.qapint.app.bll.SettingsManager;
import com.qapint.app.models.CallReport;
import com.qapint.app.models.Setting;

public class NotificationServiceManager extends Service {
    public static final String TAG = "Notification Service Manager";
    public static final int NOTIFICATION_ID = 666;
    public static final String CALL_REPORT_ID = "call_report_id";

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String callReportId = intent.getStringExtra(CALL_REPORT_ID);
        CallReportController callReportController = new CallReportController();
        if (callReportId != null) {
            createNotificationFor(getApplicationContext(), callReportController.loadById(callReportId));
        }
        List<CallReport> reports = callReportController.getNextClosestCallReports(getClosestDate());
        if (reports != null && reports.size() > 0) {
            scheduleNextAlarm(getApplicationContext(), reports.get(0));
        }
        return START_STICKY;
    }

    public long get_alarmDelay() {
        long minutes = 0;
        SettingsManager sManager = new SettingsManager();
        Setting alarmSetting = sManager.getValueByKey("alarm");
        if(alarmSetting != null){
            minutes = Integer.parseInt(alarmSetting.getValue());
        }
        return minutes * DateUtils.MINUTE_IN_MILLIS;
    }

    public void scheduleNextVisits(Context context) {
        clearAllNotifications(context);
        CallReportController callReportController = new CallReportController();
        List<CallReport> reports = callReportController.getNextClosestCallReports(getClosestDate());
        if (reports != null && reports.size() > 0) {
            scheduleNextAlarm(context, reports.get(0));
        }
    }

    private Date getClosestDate() {
        long alarmDelay = get_alarmDelay();
        return new Date((new Date()).getTime() + alarmDelay);
    }

    private void scheduleNextAlarm(Context context, CallReport callReport) {
        long alarmDelay = get_alarmDelay();
        if (alarmDelay <= 0) return;

        long date = callReport.getDateOfVisit().getTime();
        NotificationAlarm.setNextAlarm(context, date - alarmDelay, callReport.getId());
    }

    private void createNotificationFor(Context context, CallReport callReport) {
        if (callReport == null) return;

        NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        clearAllNotifications(context);
        long when = System.currentTimeMillis();
        Intent notificationIntent = new Intent(context, AbbottMobile.class);
        notificationIntent.putExtra(CALL_REPORT_ID, callReport.getId());
        notificationIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        notificationIntent.setAction(Intent.ACTION_MAIN);
        notificationIntent.addCategory(Intent.CATEGORY_LAUNCHER);

        TaskStackBuilder stackBuilder = TaskStackBuilder.create(context);
        stackBuilder.addNextIntent(notificationIntent);
        PendingIntent contentIntent = stackBuilder.getPendingIntent(0, PendingIntent.FLAG_CANCEL_CURRENT);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.map_pin)
                .setContentTitle(callReport.getDateOfVisitFormatted())
                .setContentText(callReport.getOrganization())
                .setContentIntent(contentIntent)
                .setWhen(when)
                .setAutoCancel(true);

        mNotificationManager.notify(NOTIFICATION_ID, mBuilder.build());
    }

    public void clearAllNotifications(Context context) {
        NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        mNotificationManager.cancelAll();
    }

}
