#import <Foundation/Foundation.h>
#import "CDVPlugin.h"
#import "SSZipArchive.h"

@interface Zip : CDVPlugin

- (void)unzip:(CDVInvokedUrlCommand*)command;

@end
