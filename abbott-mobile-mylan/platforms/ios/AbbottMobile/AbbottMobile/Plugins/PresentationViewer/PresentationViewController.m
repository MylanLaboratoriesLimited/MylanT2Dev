//
//  PresentationViewController.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 4/8/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "PresentationViewController.h"
#import "PDFViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PresentationViewController ()

@property (nonatomic, retain) IBOutlet UIView *toolbarMode;
@property (nonatomic, retain) IBOutlet UIButton *btnComplete;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)stylizeUIElements;
- (IBAction)onPresentationDoubleTap:(id)sender;
- (IBAction)onToolbarTap:(id)sender;
- (void)toggleToolbar;
- (IBAction)onCompleteTap:(id)sender;

@end


@implementation PresentationViewController

@synthesize webView;
@synthesize toolbarMode;
@synthesize delegate;
@synthesize btnComplete;
@synthesize activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self stylizeUIElements];
}


- (void)stylizeUIElements
{
    NSInteger fontSize = [self isIpad] ? 15 : 10;
    [self.btnComplete setTitle:AMLocalizedString(@"Complete", nil) forState:UIControlStateNormal];
    self.btnComplete.layer.cornerRadius = 4;
    self.btnComplete.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:fontSize];
}

- (BOOL)isIpad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (void)loadURL:(NSString *)url
{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
}

- (void)resetPresentationView
{
    self.toolbarMode.hidden = YES;
    [self.webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
    [self clearKPI];
}

- (NSString *)getKPI
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.invokeEvent('suspend')"]];
    return [self.webView getKPI];
}

- (void)clearKPI
{
    [self.webView clearKPI];
}

- (IBAction)onPresentationDoubleTap:(id)sender
{
    [self toggleToolbar];
}

- (IBAction)onToolbarTap:(id)sender
{
    [self toggleToolbar];
}

- (void)toggleToolbar
{
    self.toolbarMode.hidden = !self.toolbarMode.hidden;
}

- (IBAction)onCompleteTap:(id)sender
{
    [self.delegate presentationViewControllerOnComplete:self];
}

#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"URL: %@", request);
    if ([self requestIsForOpeningPdfFromURL:request])
    {
        [self openPdfViewerWithURL:request.URL];
        return NO;
    }
    return YES;
}

- (void)openPdfViewerWithURL:(NSURL *)url
{
    NSString *nibName = [self isIpad] ? @"PDFViewController" : @"PDFViewController_iPhone";
    PDFViewController *pdfViewer = [[PDFViewController alloc] initWithNibName:nibName bundle:nil];
    [pdfViewer setUrlToPDF:url];
    [self presentViewController:pdfViewer animated:YES completion:^{
        [pdfViewer release];
    }];
}

- (BOOL)requestIsForOpeningPdfFromURL:(NSURLRequest *)request
{
    return ([request.URL.scheme isEqualToString:@"file"] && [request.URL.lastPathComponent.pathExtension caseInsensitiveCompare:@"pdf"] == NSOrderedSame);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.delegate presentationViewControllerDidFinishLoading:self];
    [self scalePresentationForIPhone];
    [self.activityIndicator stopAnimating];
}



- (void)scalePresentationForIPhone
{
    if (![self isIpad])
    {
        [self.webView scaleForIPhone];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.delegate presentationViewController:self didFailLoadingWithError:error];
    [self.activityIndicator stopAnimating];
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark -

- (void)dealloc
{
    self.toolbarMode = nil;
    self.webView = nil;
    self.delegate = nil;
    self.btnComplete = nil;
    self.activityIndicator = nil;

    [super dealloc];
}

@end
