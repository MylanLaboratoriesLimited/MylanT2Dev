package com.qapint.app.bll;

import android.util.SparseArray;
import com.salesforce.androidsdk.smartstore.app.SalesforceSDKManagerWithSmartStore;
import com.salesforce.androidsdk.smartstore.phonegap.StoreCursor;
import com.salesforce.androidsdk.smartstore.store.QuerySpec;
import com.salesforce.androidsdk.smartstore.store.SmartStore;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

public abstract class BaseController<Type> {
    public static final String TAG = "Base controller";
    private static SparseArray<StoreCursor> storeCursors = new SparseArray<StoreCursor>();

    protected abstract Type instantiateFromJson(JSONObject object) throws JSONException, ParseException;

    protected SmartStore getSmartStore() {
        return (SalesforceSDKManagerWithSmartStore.getInstance()).getSmartStore();
    }

    protected List<Type> jsonToList(JSONArray list) throws JSONException, ParseException {
        List<Type> resultList = new ArrayList<Type>();
        for (int i = 0, length = list.length(); i < length; i++) {
            resultList.add(instantiateFromJson(list.getJSONArray(i).getJSONObject(0)));
        }
        return resultList;
    }

    protected List<Type> runQuery(QuerySpec querySpec) throws JSONException, ParseException {
        SmartStore smartStore = getSmartStore();
        StoreCursor storeCursor = new StoreCursor(smartStore, querySpec);
        storeCursors.put(storeCursor.cursorId, storeCursor);
        JSONObject result = storeCursor.getData(smartStore);
        return jsonToList(result.getJSONArray("currentPageOrderedEntries"));
    }
}
