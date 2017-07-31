//
//  Setting.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "Setting.h"

@implementation Setting

@synthesize key;
@synthesize value;

+ (NSString *)tableName
{
    return @"Settings";
}

+ (NSString *)keyFieldName
{
    return @"key";
}

+ (NSString *)valueFieldName
{
    return @"value";
}

#pragma mark - 

- (void)dealloc
{
    self.key = nil;
    self.value = nil;

    [super dealloc];
}

@end
