//
//  NotificationServiceManager.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 11/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "NotificationServiceManager.h"
#import "DateUtils.h"
#import "Constants.h"

@implementation NotificationServiceManager

- (void)resetNotificationService
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)enqueueNotification:(Notification *)notification
{
    UILocalNotification* localNotification = [UILocalNotification new];
    NSString *notificationStartDateString = [DateUtils stringFromDate:notification.startDate inFormat:@"HH:mm dd.MM.yyyy"];
    NSTimeInterval offset = -1 * (notification.alarmOffsetMinutes * SECONDS_IN_MINUTE);
    localNotification.fireDate = [notification.startDate dateByAddingTimeInterval:offset];
    localNotification.alertBody = [NSString stringWithFormat:AMLocalizedString(@"You are having appointment at _time_ to _account_", nil), notificationStartDateString, notification.title, notification.comment];
    localNotification.alertAction = AMLocalizedString(@"View appointment", nil);
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    localNotification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    localNotification.userInfo = @{ UNIQUE_NOTIFICATION_IDENTIFIER_KEY: notification.identifier };
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [localNotification release];
}

@end
