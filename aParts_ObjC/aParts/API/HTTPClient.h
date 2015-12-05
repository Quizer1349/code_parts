//
//  HTTPClient.h
//  MyLibrary
//
//  Created by Eli Ganem on 8/7/13.
//  Copyright (c) 2013 Eli Ganem. All rights reserved.
//

#import <AFNetworking/AFHTTPSessionManager.h>

@interface HTTPClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

+ (NSURL *)APIBaseURL;

- (BOOL) connected;

- (UIImage*)downloadImage:(NSString*)url;

@end
