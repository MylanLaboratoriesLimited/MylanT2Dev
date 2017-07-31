//
//  PresentationView.m
//  AbbottMobile
//
//  Created by Alexander Voronov on 5/8/14.
//  Copyright (c) 2014 Qap, Inc. All rights reserved.
//

#import "PresentationView.h"

static CGFloat const IPHONE_SCALE = 0.425;

@implementation PresentationView

- (NSString *)executeMethodWithName:(NSString *)methodName
{
	return [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"executeMethod('%@');", methodName]];
}

- (NSString *)invokeEventWithName:(NSString *)eventName
{
	return [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"invokeEvent('%@');", eventName]];
}

- (NSString *)getKPI
{
    return [self executeMethodWithName:@"getKPI"];
}

- (void)clearKPI
{
    [self executeMethodWithName:@"clearStorage"];
}

- (void)scaleForIPhone
{
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.style.zoom = %f;", IPHONE_SCALE]];
}

@end
