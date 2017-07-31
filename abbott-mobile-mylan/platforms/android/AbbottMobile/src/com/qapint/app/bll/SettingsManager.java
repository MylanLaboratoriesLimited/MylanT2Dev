package com.qapint.app.bll;

import android.util.Log;
import com.qapint.app.models.Setting;
import com.salesforce.androidsdk.smartstore.store.QuerySpec;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;

public class SettingsManager extends BaseController<Setting> {
    public static final String TAG = "Settings controller";
    private static final String TABLE_NAME = "Settings";
    private static final String GET_SETTING_QUERY = "SELECT {#tname:_soup} FROM {#tname} WHERE {#tname:#ftype} = '#kvalue'";

    private String buildByQueryByKey(String key){
        return GET_SETTING_QUERY.replace("#tname", TABLE_NAME).replace("#ftype", Setting.KEY_FIELD_NAME).replace("#kvalue", key);
    }

    public Setting getValueByKey(String key){
        try {
            String query = buildByQueryByKey(key);
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
    protected Setting instantiateFromJson(JSONObject object) throws JSONException, ParseException {
        return new Setting(object);
    }
}
