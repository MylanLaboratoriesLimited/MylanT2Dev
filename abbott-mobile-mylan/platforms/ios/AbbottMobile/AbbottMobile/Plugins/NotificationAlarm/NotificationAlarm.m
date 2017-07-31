//
//  NotificationAlarm.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 10/6/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "NotificationAlarm.h"
#import "Notification.h"
#import "NotificationServiceManager.h"
#import "Underscore.h"
#import "CallReport.h"
#import "CallReportsController.h"
#import "Setting.h"
#import "SettingsController.h"
#import "Constants.h"

@interface NotificationAlarm()

@property (nonatomic, retain) NotificationServiceManager *notificationsManager;
@property (nonatomic, retain) CallReportsController *callReportsController;
@property (nonatomic, retain) SettingsController *settingsController;

- (void)removeScheduledNotifications;
- (Notification *)notificationFromCallReport:(CallReport *)callReport;
- (NSInteger)alarmDelayMinutes;
- (void)sendOKPluginResultForCallbackId:(NSString *)callbackId;
- (void)sendErrorPluginResultWithMessage:(NSString *)message forCallbackId:(NSString *)callbackId;

@end


@implementation NotificationAlarm

@synthesize notificationsManager;
@synthesize callReportsController;
@synthesize settingsController;

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView
{
    if (self = [super initWithWebView:theWebView])
    {
        NSLog(@"********************** Notification Alarm **********************");
        self.notificationsManager = [[NotificationServiceManager new] autorelease];
        self.callReportsController = [[CallReportsController new] autorelease];
        self.settingsController = [[SettingsController new] autorelease];
    }
    return self;
}

- (void)scheduleNextVisits:(CDVInvokedUrlCommand *)command
{
    if ([self alarmDelayMinutes] > 0)
    {
        [self removeScheduledNotifications];
        NSLog(@"********************** Notification Alarm: scheduleNextVisits");
        NSTimeInterval offset = [self alarmDelayMinutes] * SECONDS_IN_MINUTE;
        NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow:offset];
        NSArray *callReports = [self.callReportsController fetchCallReportsAfterDate:futureDate];
        Underscore.arrayEach(callReports, ^(CallReport *callReport) {
            Notification *notification = [self notificationFromCallReport:callReport];
            [self.notificationsManager enqueueNotification:notification];
        });
        [self sendOKPluginResultForCallbackId:command.callbackId];
    }
    else
    {
        [self cancelNotification:command];
    }
}

- (void)removeScheduledNotifications
{
    UIApplication *application = [UIApplication sharedApplication];
    Underscore.arrayEach([application scheduledLocalNotifications], ^(UILocalNotification *notification) {
        [application cancelLocalNotification:notification];
    });
}

- (void)cancelNotification:(CDVInvokedUrlCommand *)command
{
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self.notificationsManager resetNotificationService];
    [self sendOKPluginResultForCallbackId:command.callbackId];
}

- (Notification *)notificationFromCallReport:(CallReport *)callReport
{
    Notification *notification = [Notification new];
    notification.identifier = callReport.identifier;
    notification.title = callReport.organizationName;
    notification.comment = [callReport fullAddress];
    notification.startDate = callReport.dateOfVisit;
    notification.durationMinutes = callReport.duration.integerValue;
    notification.alarmOffsetMinutes = [self alarmDelayMinutes];
    return [notification autorelease];
}

- (NSInteger)alarmDelayMinutes
{
    Setting *setting = [self.settingsController fetchSettingsByKey:ALARM_DELAY_KEY];
    return setting.value.integerValue;
}

- (void)sendOKPluginResultForCallbackId:(NSString *)callbackId
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:callbackId];
}

- (void)sendErrorPluginResultWithMessage:(NSString *)message forCallbackId:(NSString *)callbackId
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message] callbackId:callbackId];
}

#pragma mark - 

- (void)dealloc
{
    self.notificationsManager = nil;
    self.callReportsController = nil;
    self.settingsController = nil;
    [super dealloc];
}

@end
