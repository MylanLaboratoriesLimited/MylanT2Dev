package com.qapint.app.activities;

import android.content.Intent;
import com.qapint.app.services.notifications.NotificationServiceManager;
import com.salesforce.androidsdk.ui.sfhybrid.SalesforceDroidGapActivity;

public class AbbottMobile extends SalesforceDroidGapActivity {

    public void onResume() {
        super.onResume();
        Intent openIntent = getIntent();
        if (openIntent != null) {
            String callReportId = openIntent.getStringExtra(NotificationServiceManager.CALL_REPORT_ID);
            if (callReportId != null) {
                String command = String.format("javascript:window.callReportId = '%s';", callReportId);
                this.appView.loadUrl(command);
            }
        }
    }
}
