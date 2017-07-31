//
//  DateUtils.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 16/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

+ (NSDate *)dateFromStringInSFFormat:(NSString *)dateString
{
	// SalesForce date format sample
	// 2012-02-09T10:39:54.000+0000

	NSUInteger indexOfDot = [dateString rangeOfString:@"."].location;
	NSString *dateTimeNoTimezone = [dateString substringToIndex:indexOfDot];
	return [DateUtils dateFromStringInGMT:dateTimeNoTimezone format:@"yyyy-MM-dd'T'HH:mm:ss"];
}

+ (NSDate *)dateFromStringInGMT:(NSString *)dateString format:(NSString *)format
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:format];
	[dateFormatter setLocale:locale];
	[dateFormatter setTimeZone:timeZone];
	NSDate *date = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
    [locale release];
	return date;
}

+ (NSString *)stringFromDateInSFFormat:(NSDate *)date
{
    return [DateUtils stringInGMTFromDate:date inFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000+0000'"];
}

+ (NSString *)stringFromDate:(NSDate *)date inFormat:(NSString *)format
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:format];
	[dateFormatter setLocale:locale];
	NSString *dateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	[locale release];
	return dateString;
}

+ (NSString *)stringInGMTFromDate:(NSDate *)date inFormat:(NSString *)format
{
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	[dateFormatter setDateFormat:format];
	[dateFormatter setLocale:locale];
	[dateFormatter setTimeZone:timeZone];
	NSString *dateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	[locale release];
	return dateString;
}



@end
