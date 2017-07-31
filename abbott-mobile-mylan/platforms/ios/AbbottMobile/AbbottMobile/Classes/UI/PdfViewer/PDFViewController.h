//
//  PDFViewController.h
//  SF
//
//  Created by Sviatoslav Yakobchuk on 7/11/12.
//  Copyright (c) 2012 QAP Int. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PDFViewControllerDelegate;


@interface PDFViewController : UIViewController

@property (nonatomic, retain) NSURL	*urlToPDF;
@property (nonatomic, assign) id<PDFViewControllerDelegate>	delegate;

@end


@protocol PDFViewControllerDelegate <NSObject>

@required
- (void)pdfViewControllerDidAppear:(PDFViewController *)pdfViewController;
- (void)pdfViewControllerDidDisappear:(PDFViewController *)pdfViewController;

@end