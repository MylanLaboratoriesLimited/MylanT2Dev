//
//  Locale.h
//  AbbottMobile
//
//  Created by Alexander Voronov on 20/8/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "CDVPlugin.h"

@interface Locale : CDVPlugin

- (void)setLanguage:(CDVInvokedUrlCommand *)command;

@end
