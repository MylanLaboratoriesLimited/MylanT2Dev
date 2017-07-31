//
//  CallReportsController.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 12/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "CallReportsController.h"
#import "CallReport.h"
#import "Underscore.h"
#import "DateUtils.h"

@interface CallReportsController()

- (NSString *)callReportsFilteredByDateQuery:(NSDate *)filterDate;
- (NSString *)compoundOrganisationKey:(NSString *)secondPart;

@end


@implementation CallReportsController

- (NSArray *)fetchCallReportsAfterDate:(NSDate *)filterDate
{
    SFQuerySpec *querySpec = [self buildSmartQuery:[self callReportsFilteredByDateQuery:filterDate]];
    NSArray *callReports = [self fetchEntitiesWithQuerySpec:querySpec];
    return Underscore.arrayMap(callReports, ^(NSArray *callReportItem) {
        return [self parseEntity:callReportItem[0]];
    });
}

- (NSString *)callReportsFilteredByDateQuery:(NSDate *)filterDate
{
    NSString *tableName = [CallReport tableName];
    NSString *now = [DateUtils stringFromDateInSFFormat:filterDate];
    NSString *select = [NSString stringWithFormat:@"SELECT {%@:_soup} FROM {%@}", tableName, tableName];
    NSString *where = [NSString stringWithFormat:@"WHERE {%@:%@} = 'Appointment' AND {%@:%@} > '%@'", tableName, [CallReport typeFieldName], tableName, [CallReport dateFieldName], now];
    NSString *orderBy = [NSString stringWithFormat:@"ORDER BY {%@:%@} COLLATE NOCASE ASC", tableName, [CallReport dateFieldName]];
    return [NSString stringWithFormat:@"%@ %@ %@", select, where, orderBy];
}

#pragma mark - Parseable implementation

- (id<Entity>)parseEntity:(NSDictionary *)entityObj
{
    CallReport *callReport = [CallReport new];
    callReport.identifier = entityObj[[CallReport idFieldName]];
    callReport.dateOfVisit = [DateUtils dateFromStringInSFFormat:entityObj[[CallReport dateFieldName]]];
    callReport.type = entityObj[[CallReport typeFieldName]];
    callReport.duration = entityObj[[CallReport durationFieldName]];
    if (entityObj[[CallReport organisationFieldName]])
    {
        callReport.organizationName = ((NSDictionary *)entityObj[[CallReport organisationFieldName]])[[CallReport organisationNameFieldName]];
        callReport.organizationAddress = ((NSDictionary *)entityObj[[CallReport organisationFieldName]])[[CallReport organisationStreetFieldName]];
        callReport.organizationCity = ((NSDictionary *)entityObj[[CallReport organisationFieldName]])[[CallReport organisationCityFieldName]];
    }
    else
    {
        BOOL hasCompoundKey = Underscore.any([entityObj allKeys], ^BOOL (NSString *key) {
            return [key rangeOfString:[CallReport organisationFieldName]].location == 0;
        });
        if (hasCompoundKey)
        {
            callReport.organizationName = entityObj[[self compoundOrganisationKey:[CallReport organisationNameFieldName]]];
            callReport.organizationAddress = entityObj[[self compoundOrganisationKey:[CallReport organisationStreetFieldName]]];
            callReport.organizationCity = entityObj[[self compoundOrganisationKey:[CallReport organisationCityFieldName]]];
        }
    }
    return [callReport autorelease];
}

- (NSString *)compoundOrganisationKey:(NSString *)secondPart
{
    return [NSString stringWithFormat:@"%@.%@", [CallReport organisationFieldName], secondPart];
}

@end
