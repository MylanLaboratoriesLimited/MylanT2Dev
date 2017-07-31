//
//  Locale.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 20/8/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "Locale.h"

@implementation Locale

- (void)setLanguage:(CDVInvokedUrlCommand *)command
{
    NSString *lang = [command.arguments objectAtIndex:0];
    if (lang)
    {
        LocalizationSetLanguage(lang);
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }
    else
    {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Not all arguments passed"] callbackId:command.callbackId];
    }
}

@end
