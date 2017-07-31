package com.qapint.app.utils;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class DateUtils {
    private static final String TIME_FORMAT = "HH:mm";
    private static final String DATE_FORMAT = "dd.MM.yyyy";
    private static final String DATE_TIME_FORMAT = String.format("%s %s", DATE_FORMAT, TIME_FORMAT);
    private static final String SALES_FORCE_DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";

    public static String localToSFGMT(Date date) {
        DateFormat gmtFormat = new SimpleDateFormat(SALES_FORCE_DATE_FORMAT);
        gmtFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        return gmtFormat.format(date);
    }

    public static Date SFGMTToLocal(String date) throws ParseException {
        DateFormat gmtFormat = new SimpleDateFormat(SALES_FORCE_DATE_FORMAT);
        gmtFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        return gmtFormat.parse(date);
    }

    public static String toTraditional(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_TIME_FORMAT);
        return sdf.format(date);
    }
}
