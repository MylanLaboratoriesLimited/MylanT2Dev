//
//  Notification.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 11/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, assign) NSUInteger durationMinutes;
@property (nonatomic, assign) NSInteger alarmOffsetMinutes;

@end
