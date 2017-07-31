//
//  PDFViewController.m
//  SF
//
//  Created by Sviatoslav Yakobchuk on 7/11/12.
//  Copyright (c) 2012 QAP Int. All rights reserved.
//

#import "PDFViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>

@interface PDFViewController () <MFMailComposeViewControllerDelegate, UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *btnClose;

- (void)stylizeUIElements;
- (void)loadPDF;
- (IBAction)onBtnCloseTap:(UIBarButtonItem *)sender;

@end


@implementation PDFViewController

@synthesize webView;
@synthesize urlToPDF;
@synthesize btnClose;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self stylizeUIElements];
    [self loadPDF];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if ([self.delegate respondsToSelector:@selector(pdfViewControllerDidAppear:)])
    {
		[self.delegate pdfViewControllerDidAppear:self];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	if ([self.delegate respondsToSelector:@selector(pdfViewControllerDidDisappear:)])
    {
		[self.delegate pdfViewControllerDidDisappear:self];
	}
}

- (void)stylizeUIElements
{
    NSInteger fontSize = [self isIpad] ? 15 : 10;
    [self.btnClose setTitle:AMLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    self.btnClose.layer.cornerRadius = 4;
    self.btnClose.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:fontSize];
}

- (BOOL)isIpad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (void)loadPDF
{
	[self.webView loadRequest:[NSURLRequest requestWithURL:self.urlToPDF]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)setUrlToPDF:(NSURL *)newUrlToPDF
{
	[newUrlToPDF retain];
	[urlToPDF release];
	urlToPDF = newUrlToPDF;
	
	[self loadPDF];
}

- (IBAction)onBtnCloseTap:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([url.scheme isEqualToString:@"file"])
    {
        return YES;
    }
    [[UIApplication sharedApplication] openURL:url];
    return NO;
}

#pragma mark -

- (void)dealloc
{
	self.delegate = nil;
	self.webView = nil;
	self.urlToPDF = nil;
    self.btnClose = nil;
    
	[super dealloc];
}

@end
