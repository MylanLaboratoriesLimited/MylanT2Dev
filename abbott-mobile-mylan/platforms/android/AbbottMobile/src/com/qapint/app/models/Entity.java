package com.qapint.app.models;

import org.json.JSONException;
import org.json.JSONObject;
import java.text.ParseException;

public class Entity {
    public static final String ID_FIELD_NAME = "Id";
    private String id;

    public String getId(){
        return id;
    }

    private void parseFromJSON(JSONObject object) throws JSONException, ParseException{
        id = object.getString(ID_FIELD_NAME);
    }

    public Entity(JSONObject object) throws JSONException, ParseException {
        parseFromJSON(object);
    }
}
