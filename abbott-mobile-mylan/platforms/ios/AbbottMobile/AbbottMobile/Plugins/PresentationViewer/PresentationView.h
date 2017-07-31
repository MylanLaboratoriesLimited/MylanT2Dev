//
//  PresentationView.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 5/8/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresentationView : UIWebView

- (void)scaleForIPhone;
- (NSString *)getKPI;
- (void)clearKPI;

@end
