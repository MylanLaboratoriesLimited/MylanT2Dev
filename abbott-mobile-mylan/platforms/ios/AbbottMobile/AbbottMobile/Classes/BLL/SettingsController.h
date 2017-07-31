//
//  SettingsController.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntitiesController.h"
#import "Setting.h"

@interface SettingsController : EntitiesController

- (Setting *)fetchSettingsByKey:(NSString *)key;
- (NSArray *)upsertSettings:(NSArray *)settings;

@end
