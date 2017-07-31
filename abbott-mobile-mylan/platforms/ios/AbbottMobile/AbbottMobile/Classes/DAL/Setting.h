//
//  Setting.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"

@interface Setting : NSObject <Entity>

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;

+ (NSString *)keyFieldName;
+ (NSString *)valueFieldName;

@end
