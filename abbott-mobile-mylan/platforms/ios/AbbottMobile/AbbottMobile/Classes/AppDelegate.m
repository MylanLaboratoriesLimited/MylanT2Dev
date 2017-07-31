/*
 Copyright (c) 2011-2013, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
#import "SFAuthenticationManager.h"
#import "SFPushNotificationManager.h"
#import "SFLogger.h"
#import "Setting.h"
#import "SettingsController.h"
#import "Constants.h"

@interface AppDelegate ()

@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

- (void)initializeAppViewState;

/**
 * Handles the notification from SFAuthenticationManager that a logout has been initiated.
 * @param notification The notification containing the details of the logout.
 */
- (void)logoutInitiated:(NSNotification *)notification;

/**
 * Handles the notification from SFAuthenticationManager that the login host has changed in
 * the Settings application for this app.
 * @param The notification whose userInfo dictionary contains:
 *        - kSFLoginHostChangedNotificationOriginalHostKey: The original host, prior to host change.
 *        - kSFLoginHostChangedNotificationUpdatedHostKey: The updated (new) login host.
 */
- (void)loginHostChanged:(NSNotification *)notification;

- (void)updateStateOfApplication:(UIApplication *)application whenReceivingNotification:(UILocalNotification *)notification;
- (void)updateSettingsForNavigatingToApptScreenWithId:(NSString *)apptId;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize bgTask;

- (id)init
{
    self = [super init];
    if (self) {
#if defined(DEBUG)
        [SFLogger setLogLevel:SFLogLevelDebug];
#else
        [SFLogger setLogLevel:SFLogLevelInfo];
#endif
        
        // Logout and login host change handlers.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutInitiated:) name:kSFUserLogoutNotification object:[SFAuthenticationManager sharedManager]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginHostChanged:) name:kSFLoginHostChangedNotification object:[SFAuthenticationManager sharedManager]];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFUserLogoutNotification object:[SFAuthenticationManager sharedManager]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFLoginHostChangedNotification object:[SFAuthenticationManager sharedManager]];
}

#pragma mark - App event lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.autoresizesSubviews = YES;

    //
    // If you wish to register for push notifications, uncomment the line below.  Note that,
    // if you want to receive push notifications from Salesforce, you will also need to
    // implement the application:didRegisterForRemoteNotificationsWithDeviceToken: method (below).
    //
    //[[SFPushNotificationManager sharedInstance] registerForRemoteNotifications];
    //
    [self setMinimumIntervalForBackgroundFetchInApplication:application];

    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification)
    {
        [self updateStateOfApplication:application whenReceivingNotification:localNotification];
    }

    [self initializeAppViewState];
    return YES;
}

- (void)setMinimumIntervalForBackgroundFetchInApplication:(UIApplication *)application
{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)updateStateOfApplication:(UIApplication *)application whenReceivingNotification:(UILocalNotification *)notification
{
    [self updateSettingsForNavigatingToApptScreenWithId:[notification.userInfo valueForKey:UNIQUE_NOTIFICATION_IDENTIFIER_KEY]];
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
//    if (application.applicationIconBadgeNumber > 0) --application.applicationIconBadgeNumber;
}

- (void)updateSettingsForNavigatingToApptScreenWithId:(NSString *)apptId
{
    Setting *setting = [Setting new];
    setting.key = NAVIGATE_TO_APPOINTMENT_KEY;
    setting.value = apptId;
    SettingsController *settingsController = [SettingsController new];
    [settingsController upsertSettings:@[setting]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //
    // Uncomment the code below to register your device token with the push notification manager
    //
    //[[SFPushNotificationManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    //if ([SFAccountManager sharedInstance].credentials.accessToken != nil) {
    //    [[SFPushNotificationManager sharedInstance] registerForSalesforceNotifications];
    //}
    //
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // Respond to any push notification registration errors here.
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (url == nil) {
        return NO;
    }
    
    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AMLocalizedString(@"Reminder", nil)
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:AMLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self updateStateOfApplication:application whenReceivingNotification:notification];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

#pragma mark - App Settings helpers

- (void)logoutInitiated:(NSNotification *)notification
{
    [self log:SFLogLevelDebug msg:@"Logout notification received.  Resetting app."];
    self.viewController.appHomeUrl = nil;
    [self initializeAppViewState];
}

- (void)loginHostChanged:(NSNotification *)notification
{
    [self log:SFLogLevelDebug msg:@"Login host changed notification received.  Resetting app."];
    [self initializeAppViewState];
}

#pragma mark - Private methods

- (void)initializeAppViewState
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeAppViewState];
        });
        return;
    }
    
    self.viewController = [[SFHybridViewController alloc] init];
    self.viewController.useSplashScreen = YES;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
}

@end
