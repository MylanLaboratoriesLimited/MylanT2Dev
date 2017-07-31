//
//  PresentationViewer.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 4/8/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "CDVPlugin.h"
#import "PresentationViewController.h"

@interface PresentationViewer : CDVPlugin <PresentationViewControllerDelegate>

@property (nonatomic, retain) PresentationViewController *presentationViewer;

- (void)openPresentation:(CDVInvokedUrlCommand *)command;
- (void)closePresentation:(CDVInvokedUrlCommand *)command;
- (void)getKPI:(CDVInvokedUrlCommand *)command;

@end
