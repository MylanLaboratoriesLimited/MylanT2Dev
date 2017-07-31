package com.qapint.app.models;

import java.text.ParseException;
import java.util.Date;
import com.qapint.app.utils.DateUtils;
import org.json.JSONException;
import org.json.JSONObject;

public class CallReport extends Entity{
    public static final String DATE_FIELD_NAME = "Date_Time__c";
    public static final String TYPE_FIELD_NAME = "Type__c";
    public static final String ORGANISATION_FIELD_NAME = "Organisation__r";
    public static final String ORGANISATION_NAME_FIELD_NAME = "Name";
    public static final String ORGANISATION_CITY_FIELD_NAME = "BillingCity";
    public static final String ORGANISATION_STREET_FIELD_NAME = "BillingStreet";

    private Date dateOfVisit;
    private String organizationName;
    private String organizationCity;
    private String organizationAddress;

    private void parseFromJSON(JSONObject object) throws JSONException, ParseException{
        String date = object.getString(DATE_FIELD_NAME);
        dateOfVisit = DateUtils.SFGMTToLocal(date);
        if(object.has(ORGANISATION_FIELD_NAME)){
            JSONObject organisation = object.getJSONObject(ORGANISATION_FIELD_NAME);
            organizationName = organisation.getString(ORGANISATION_NAME_FIELD_NAME);
            organizationCity = organisation.getString(ORGANISATION_CITY_FIELD_NAME);
            organizationAddress = organisation.getString(ORGANISATION_STREET_FIELD_NAME);
        }else{
            organizationName = object.getString(String.format("%s.%s", ORGANISATION_FIELD_NAME, ORGANISATION_NAME_FIELD_NAME));
            organizationCity = object.getString(String.format("%s.%s", ORGANISATION_FIELD_NAME, ORGANISATION_CITY_FIELD_NAME));
            organizationAddress = object.getString(String.format("%s.%s", ORGANISATION_FIELD_NAME, ORGANISATION_STREET_FIELD_NAME));
        }
    }

    public CallReport(JSONObject object) throws JSONException, ParseException {
        super(object);
        parseFromJSON(object);
    }

    public Date getDateOfVisit(){
        return dateOfVisit;
    }

    public String getOrganization(){
        return String.format("%s\n%s %s", organizationName, organizationAddress, organizationCity);
    }

    public String getDateOfVisitFormatted() {
        return DateUtils.toTraditional(getDateOfVisit());
    }
}
