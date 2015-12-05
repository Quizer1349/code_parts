//
//  NSApiClient.h
//  klitch
//
//  Created by admin on 20.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "KSCompletionBlocks.h"


@interface KSApiClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

+ (NSURL *)APIBaseURL;

- (BOOL) connected;

- (void) registerUserWithName:(NSString *)name andPhone:(NSString *)phone withBlock:(KSDictionaryCompletionBlock)completion;

- (void) activateUserWithPin:(NSString *)pin withBlock:(KSDictionaryCompletionBlock)completion;

@end
