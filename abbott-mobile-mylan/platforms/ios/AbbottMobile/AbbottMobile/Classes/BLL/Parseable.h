//
//  ParseableProtocol.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"

@protocol Parseable <NSObject>

- (id<Entity>)parseEntity:(NSDictionary *)entityObj;

@end
