/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Foundation/Foundation.h>
#import "CDVPlugin.h"

typedef int CDVPresentationTransferError;

typedef int CDVPresentationTransferDirection;

// Magic value within the options dict used to set a cookie.
extern NSString* const kKeyCookie;

@interface CDVPresentationTransfer : CDVPlugin {}

- (void)upload:(CDVInvokedUrlCommand*)command;
- (void)download:(CDVInvokedUrlCommand*)command;
- (NSString*)escapePathComponentForUrlString:(NSString*)urlString;

// Visible for testing.
- (NSURLRequest*)requestForUploadCommand:(CDVInvokedUrlCommand*)command fileData:(NSData*)fileData;
- (NSMutableDictionary*)createPresentationTransferError:(int)code AndSource:(NSString*)source AndTarget:(NSString*)target;

- (NSMutableDictionary*)createPresentationTransferError:(int)code
       AndSource                                   :(NSString*)source
       AndTarget                                   :(NSString*)target
   AndHttpStatus                               :(int)httpStatus;
@property (readonly) NSMutableDictionary* activeTransfers;
@end

@interface CDVPresentationTransferDelegate : NSObject {}

@property (strong) NSMutableData* responseData; // atomic
@property (nonatomic, strong) NSFileHandle* fileHandle;
@property (nonatomic, strong) CDVPresentationTransfer* command;
@property (nonatomic, assign) CDVPresentationTransferDirection direction;
@property (nonatomic, strong) NSURLConnection* connection;
@property (nonatomic, copy) NSString* callbackId;
@property (nonatomic, copy) NSString* objectId;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, copy) NSString* target;
@property (assign) int responseCode; // atomic
@property (nonatomic, assign) NSInteger bytesTransfered;
@property (nonatomic, assign) NSInteger bytesExpected;
@property (nonatomic, assign) double percentsLoaded;
@property (nonatomic, assign) BOOL trustAllHosts;

@end;