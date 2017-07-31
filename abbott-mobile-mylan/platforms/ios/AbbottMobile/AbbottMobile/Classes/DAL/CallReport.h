//
//  CallReport.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 12/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"

@interface CallReport : NSObject <Entity>

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSDate *dateOfVisit;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSNumber *duration;
@property (nonatomic, retain) NSString *organizationName;
@property (nonatomic, retain) NSString *organizationAddress;
@property (nonatomic, retain) NSString *organizationCity;

+ (NSString *)idFieldName;
+ (NSString *)dateFieldName;
+ (NSString *)typeFieldName;
+ (NSString *)durationFieldName;
+ (NSString *)organisationFieldName;
+ (NSString *)organisationNameFieldName;
+ (NSString *)organisationCityFieldName;
+ (NSString *)organisationStreetFieldName;

- (NSString *)fullAddress;

@end
