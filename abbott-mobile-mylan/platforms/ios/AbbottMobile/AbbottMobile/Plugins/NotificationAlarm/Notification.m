//
//  Notification.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 11/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@synthesize identifier;
@synthesize title;
@synthesize comment;
@synthesize startDate;
@synthesize durationMinutes;
@synthesize alarmOffsetMinutes;

- (void)dealloc
{
    self.identifier = nil;
    self.title = nil;
    self.comment = nil;
    self.startDate = nil;
    [super dealloc];
}

@end
