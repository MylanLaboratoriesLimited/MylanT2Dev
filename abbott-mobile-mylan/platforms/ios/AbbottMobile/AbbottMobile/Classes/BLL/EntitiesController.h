//
//  EntitiesController.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parseable.h"
#import "SFSmartStore.h"
#import "SFQuerySpec.h"

@interface EntitiesController : NSObject <Parseable>

@property (nonatomic, retain) SFSmartStore *smartStore;

- (NSArray *)fetchEntitiesWithQuerySpec:(SFQuerySpec *)querySpec;
- (SFQuerySpec *)buildSmartQuery:(NSString *)query;

@end
