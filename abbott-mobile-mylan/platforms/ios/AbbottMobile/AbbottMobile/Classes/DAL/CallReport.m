//
//  CallReport.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 12/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "CallReport.h"
#import "DateUtils.h"

@implementation CallReport

@synthesize identifier;
@synthesize dateOfVisit;
@synthesize type;
@synthesize duration;
@synthesize organizationName;
@synthesize organizationAddress;
@synthesize organizationCity;

+ (NSString *)tableName
{
    return @"CallReport";
}

+ (NSString *)idFieldName
{
    return @"Id";
}

+ (NSString *)dateFieldName
{
    return @"Date_Time__c";
}

+ (NSString *)typeFieldName
{
    return @"Type__c";
}

+ (NSString *)durationFieldName
{
    return @"Duration__c";
}

+ (NSString *)organisationFieldName
{
    return @"Organisation__r";
}

+ (NSString *)organisationNameFieldName
{
    return @"Name";
}

+ (NSString *)organisationCityFieldName
{
    return @"BillingCity";
}

+ (NSString *)organisationStreetFieldName
{
    return @"BillingStreet";
}

- (NSString *)fullAddress
{
    return [NSString stringWithFormat:@"%@ %@", self.organizationAddress, self.organizationCity];
}

#pragma mark - 

- (void)dealloc
{
    self.identifier = nil;
    self.dateOfVisit = nil;
    self.type = nil;
    self.duration = nil;
    self.organizationName = nil;
    self.organizationAddress = nil;
    self.organizationCity = nil;
    
    [super dealloc];
}

@end
