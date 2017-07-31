//
//  PresentationViewer.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 4/8/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "PresentationViewer.h"

static NSString* const MESSAGE_DID_LOAD = @"DID_LOAD";
static NSString* const MESSAGE_ON_COMPLETE = @"ON_COMPLETE";


@interface PresentationViewer()

@property (nonatomic, retain) NSString *commandId;

@end


@implementation PresentationViewer

@synthesize presentationViewer;
@synthesize commandId;

#pragma mark - Open Presentation

- (void)openPresentation:(CDVInvokedUrlCommand *)command
{
    self.commandId = command.callbackId;
    [self initializePresentationView];
    [self.viewController presentViewController:self.presentationViewer animated:YES completion:^{
        NSString *host = (NSString *)command.arguments[0];
        NSString *structure = command.arguments.count > 1 ? (NSString *)command.arguments[1] : nil;
        if (host)
        {
            [self.presentationViewer loadURL:[self prepareUrlWithHost:host andStructure:structure]];
        }
        else
        {
            [self sendErrorPluginResult:@"Empty URL"];
        }
    }];
}

- (NSString*) prepareUrlWithHost: (NSString*) host andStructure:(NSString*)structure
{
    NSString *url;
    //TO DO need to refactor and remove hardcode
    NSRange actionTextRange = [[host lowercaseString] rangeOfString:@"engine"];
    
    url = actionTextRange.location == NSNotFound ? host :
        [[[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"www"] stringByDeletingLastPathComponent] stringByAppendingPathComponent:host];
    
    return structure ? [url stringByAppendingString:[NSString stringWithFormat:@"?structure=%@",structure]] : url;
}


- (void)initializePresentationView
{
    NSString *nibName = [self isIpad] ? @"PresentationViewController" : @"PresentationViewController_iPhone";
    self.presentationViewer = [[[PresentationViewController alloc] initWithNibName:nibName bundle:nil] autorelease];
    self.presentationViewer.delegate = self;
}

- (BOOL)isIpad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (void)sendErrorPluginResult:(NSString *)errorMsg
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMsg];
    [pluginResult setKeepCallback:@YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
}

- (void)sendSuccessPluginResultWithMessage:(NSString *)message
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [pluginResult setKeepCallback:@YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
}

#pragma mark - PresentationViewController delegate

- (void)presentationViewControllerOnComplete:(PresentationViewController *)presentationViewController
{
    [self sendSuccessPluginResultWithMessage:MESSAGE_ON_COMPLETE];
}

- (void)presentationViewControllerDidFinishLoading:(PresentationViewController *)presentationViewController
{
    [self sendSuccessPluginResultWithMessage:MESSAGE_DID_LOAD];
}

- (void)presentationViewController:(PresentationViewController *)presentationViewController didFailLoadingWithError:(NSError *)error
{
    [self sendErrorPluginResult:error.localizedDescription];
}

#pragma mark - Close Presentation

- (void)closePresentation:(CDVInvokedUrlCommand *)command
{
    if (self.presentationViewer)
    {
        [self.presentationViewer clearKPI];
        [self.viewController dismissViewControllerAnimated:YES completion:^{
            [self.presentationViewer resetPresentationView];
            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
            self.presentationViewer = nil;
        }];
    }
    else
    {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

#pragma mark - Get KPI

- (void)getKPI:(CDVInvokedUrlCommand *)command
{
    if (self.presentationViewer)
    {
        NSString *kpi = [self.presentationViewer getKPI];
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:kpi] callbackId:command.callbackId];
    }
    else
    {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:command.callbackId];
    }
}

#pragma mark -

- (void)dealloc
{
    self.presentationViewer = nil;
    self.commandId = nil;
    [super dealloc];
}

@end
