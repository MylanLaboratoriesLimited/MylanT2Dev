package com.qapint.app.bll;

import android.util.Log;
import android.util.SparseArray;
import com.qapint.app.models.CallReport;
import com.qapint.app.utils.DateUtils;
import com.salesforce.androidsdk.smartstore.app.SalesforceSDKManagerWithSmartStore;
import com.salesforce.androidsdk.smartstore.phonegap.StoreCursor;
import com.salesforce.androidsdk.smartstore.store.QuerySpec;
import com.salesforce.androidsdk.smartstore.store.SmartStore;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class CallReportController extends BaseController<CallReport> {
    public static final String TAG = "CallReport controller";
    private static final String TABLE_NAME = "CallReport";
    private static final String CLOSEST_QUERY = "SELECT {#tname:_soup} FROM {#tname} " +
            "WHERE {#tname:#ftype} = 'Appointment' AND {#tname:#fdate} > '#datevalue' " +
            "ORDER BY {#tname:#fdate} COLLATE NOCASE ASC";
    private static final String QUERY_BY_ID_TEMPLATE = "SELECT {#tname:_soup} FROM {#tname} " +
            "WHERE {#tname:#fid} = '#vid'";

    private String buildClosestQuery(Date startDate) {
        String gmtDate = DateUtils.localToSFGMT(startDate);
        String query = CLOSEST_QUERY.replace("#datevalue", gmtDate);
        return query.replace("#tname", TABLE_NAME).replace("#ftype", CallReport.TYPE_FIELD_NAME).replace("#fdate", CallReport.DATE_FIELD_NAME);
    }

    private String buildQueryById(String id) {
        return QUERY_BY_ID_TEMPLATE.replace("#tname", TABLE_NAME).replace("#fid", CallReport.ID_FIELD_NAME).replace("#vid", id);
    }

    public List<CallReport> getNextClosestCallReports(Date startDate) {
        try {
            String query = buildClosestQuery(startDate);
            QuerySpec querySpec = QuerySpec.buildSmartQuerySpec(query, 10);
            return runQuery(querySpec);
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage());
        } catch (ParseException e) {
            Log.e(TAG, e.getMessage());
        }
        return null;
    }

    public CallReport loadById(String id) {
        try {
            String query = buildQueryById(id);
            QuerySpec querySpec = QuerySpec.buildSmartQuerySpec(query, 1);
            return runQuery(querySpec).get(0);
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage());
        } catch (ParseException e) {
            Log.e(TAG, e.getMessage());
        }
        return null;
    }

    @Override
    protected CallReport instantiateFromJson(JSONObject object) throws JSONException, ParseException {
        return new CallReport(object);
    }
}