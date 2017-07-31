package com.qapint.app.models;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;

public class Setting {
    public static final String KEY_FIELD_NAME = "key";
    public static final String VALUE_FIELD_NAME = "value";
    private String key;
    private String value;

    private void parseFromJSON(JSONObject object) throws JSONException, ParseException{
        key = object.getString(KEY_FIELD_NAME);
        value = object.getString(VALUE_FIELD_NAME);
    }

    public Setting(JSONObject object) throws JSONException, ParseException {
        parseFromJSON(object);
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }
}
