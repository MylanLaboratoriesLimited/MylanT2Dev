//
//  NotificationServiceManager.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 11/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"

@interface NotificationServiceManager : NSObject

- (void)resetNotificationService;
- (void)enqueueNotification:(Notification *)notification;

@end
