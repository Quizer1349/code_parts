//
//  KSCompletionBlocks.h
//  klitch
//
//  Created by admin on 21.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KSCompletionBlock)(NSError *error);
typedef void (^KSResponseCompletionBlock)(NSHTTPURLResponse *response, id responseObject, NSError *error);
typedef void (^KSBooleanCompletionBlock)(BOOL result, NSError *error);
typedef void (^KSObjectCompletionBlock)(id object, NSError *error);
typedef void (^KSArrayCompletionBlock)(NSArray *response, NSError *error);
typedef void (^KSDictionaryCompletionBlock)(NSDictionary *response, NSError *error);

