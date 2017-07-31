//
//  CallReportsController.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 12/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntitiesController.h"

@interface CallReportsController : EntitiesController

- (NSArray *)fetchCallReportsAfterDate:(NSDate *)filterDate;

@end
