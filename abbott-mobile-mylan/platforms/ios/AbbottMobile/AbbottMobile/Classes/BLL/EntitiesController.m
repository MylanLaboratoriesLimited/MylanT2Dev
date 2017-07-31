//
//  EntitiesController.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "EntitiesController.h"
#import "Entity.h"

@implementation EntitiesController

@synthesize smartStore;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.smartStore = [SFSmartStore sharedStoreWithName:kDefaultSmartStoreName];
    }
    return self;
}

- (NSArray *)fetchEntitiesWithQuerySpec:(SFQuerySpec *)querySpec
{
    return [self.smartStore queryWithQuerySpec:querySpec pageIndex:0];
}

- (SFQuerySpec *)buildSmartQuery:(NSString *)query
{
    return [[SFQuerySpec newSmartQuerySpec:query withPageSize:[self pageSize]] autorelease];
}

- (NSInteger)pageSize
{
    return 1000;
}

#pragma mark - Parseable implementation

- (id<Entity>)parseEntity:(NSDictionary *)entityObj
{
    return nil;
}

#pragma mark -

- (void)dealloc
{
    self.smartStore = nil;
    [super dealloc];
}

@end
