//
//  AttachmentsViewer.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 17/10/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "AttachmentsViewer.h"

@interface AttachmentsViewer() <UIDocumentInteractionControllerDelegate>

@property (nonatomic, retain) NSString *commandId;
@property (nonatomic, retain) UIDocumentInteractionController *documentInteractionController;

- (void)openAttachmentViewerWithURL:(NSURL *)url;
- (void)openOptionsMenuWithURL:(NSURL *)url;
- (void)sendErrorPluginResult:(NSString *)errorMsg;
- (void)sendSuccessPluginResult;
- (BOOL)isIpad;

@end


@implementation AttachmentsViewer

@synthesize commandId;
@synthesize documentInteractionController;

- (void)open:(CDVInvokedUrlCommand *)command
{
    self.commandId = command.callbackId;
    if (command.arguments.count > 0)
    {
        NSDictionary *params = command.arguments[0];
        NSString *filePath = [params objectForKey:@"filePath"];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        if(![fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir)
        {
            [self sendErrorPluginResult:@"Wrong path to file"];
        }
        else
        {
            [self openAttachmentViewerWithURL:url];
            [self sendSuccessPluginResult];
        }
    }
    else
    {
        [self sendErrorPluginResult:@"Not all arguments passed"];
    }
}

- (void)openAttachmentViewerWithURL:(NSURL *)url
{
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.documentInteractionController.delegate = self;
    BOOL canBeDisplayed = [self.documentInteractionController presentPreviewAnimated:YES];
    if (!canBeDisplayed)
    {
        [self openOptionsMenuWithURL:url];
    }
}

- (void)openOptionsMenuWithURL:(NSURL *)url
{
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    CGRect viewFrame = self.viewController.view.frame;
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(viewFrame)/2.5, CGRectGetHeight(viewFrame)/1.25);
    [self.documentInteractionController presentOptionsMenuFromRect:frame inView:self.viewController.view animated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self.viewController;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.viewController.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.viewController.view.frame;
}

#pragma mark - Helpers

- (void)sendErrorPluginResult:(NSString *)errorMsg
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMsg];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
}

- (void)sendSuccessPluginResult
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandId];
}

- (BOOL)isIpad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

#pragma mark -

- (void)dealloc
{
    self.commandId = nil;
    self.documentInteractionController.delegate = nil;
    self.documentInteractionController = nil;
    [super dealloc];
}

@end
