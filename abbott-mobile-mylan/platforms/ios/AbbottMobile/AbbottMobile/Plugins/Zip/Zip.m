#import "Zip.h"
#import "CDVFile.h"

@implementation Zip

- (NSString *)pathForURL:(NSString *)filePath
{
    NSString *path = nil;
    if (path == nil) {
        if ([filePath hasPrefix:@"file:"]) {
            path = [[NSURL URLWithString:filePath] path];
        }
    }
    return path;
}

- (void)unzip:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        
        @try {
            NSString *zipURL = [command.arguments objectAtIndex:0];
            NSString *destinationURL = [command.arguments objectAtIndex:1];
            NSError *error;

            if([SSZipArchive unzipFileAtPath:zipURL toDestination:destinationURL overwrite:YES password:nil error:&error]) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                NSLog(@"%@ - %@", @"Error occurred during unzipping", [error localizedDescription]);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error occurred during unzipping"];
            }
        } @catch(NSException* exception) {
            NSLog(@"%@ - %@", @"Error occurred during unzipping", [exception debugDescription]);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error occurred during unzipping"];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
