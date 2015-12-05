//
//  KSApiClient+Payment.h
//  Клич
//
//  Created by Kirill Matskevich on 3/20/14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient.h"

@interface KSApiClient(Payment)

- (void) getSubsribtionsWithBlock:(KSArrayCompletionBlock)completion;
- (void) buySubscribtionWithID:(NSString *)subscriptionID withBlock:(KSBooleanCompletionBlock)completion;

- (void) getSubscriptionStatusWithBlock:(KSDictionaryCompletionBlock)completion;
- (void) getSubscribtionsWithBlock:(KSArrayCompletionBlock)completion;

@end
