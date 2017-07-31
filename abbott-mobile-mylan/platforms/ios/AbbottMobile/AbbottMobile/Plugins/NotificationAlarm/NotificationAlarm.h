//
//  NotificationAlarm.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 10/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "CDVPlugin.h"

@interface NotificationAlarm : CDVPlugin

- (void)scheduleNextVisits:(CDVInvokedUrlCommand *)command;
- (void)cancelNotification:(CDVInvokedUrlCommand *)command;

@end
