//
//  DateUtils.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 16/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+ (NSDate *)dateFromStringInSFFormat:(NSString *)dateString;
+ (NSString *)stringFromDateInSFFormat:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date inFormat:(NSString *)format;
+ (NSDate *)dateFromStringInGMT:(NSString *)dateString format:(NSString *)format;
+ (NSString *)stringInGMTFromDate:(NSDate *)date inFormat:(NSString *)format;

@end
