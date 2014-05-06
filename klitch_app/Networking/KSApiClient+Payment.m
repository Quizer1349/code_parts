//
//  KSApiClient+Payment.m
//  Клич
//
//  Created by Kirill Matskevich on 3/20/14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient+Payment.h"
#import "Constants.h"

@implementation KSApiClient(Payment)

- (void) getSubsribtionsWithBlock:(KSArrayCompletionBlock)completion{
    NSString *endpointURL = @"services";
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
    
    return;
}

- (void) buySubscribtionWithID:(NSString *)subscriptionID withBlock:(KSBooleanCompletionBlock)completion{
    NSDictionary *params = @{@"sku":subscriptionID, @"processed_by":@""};
    
    NSString *endpointURL = @"current/subscriptions";
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self PUT:URLString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(YES, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(NO, error);
    }];
}

- (void) getSubscribtionsWithBlock:(KSArrayCompletionBlock)completion{
    
    NSString *endpointURL = @"current/subscriptions";
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
}

- (void) getSubscriptionStatusWithBlock:(KSDictionaryCompletionBlock)completion{
    NSString *endpointURL = @"current";
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
}

@end
