//
//  KSApiClient+Klitch.m
//  klitch
//
//  Created by admin on 03.03.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient+Klitch.h"

@implementation KSApiClient (Klitch)

- (void) createKlitchWithParams:(NSDictionary *)params withBlock:(KSDictionaryCompletionBlock)completion {
    
    NSString *URLString = [[NSURL URLWithString:@"current/outbound/requests" relativeToURL:self.baseURL] absoluteString];
    [self PUT:URLString parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
}

- (void) getMyKlitchDataById:(NSString *)klitchId withBlock:(KSDictionaryCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/outbound/requests/%@", klitchId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
}


- (void) deleteKlitchWithId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/outbound/requests/%@", klitchId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self POST:URLString
    parameters:@{@"status": @"cancelled"}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(YES, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(NO, error);
      }];
}

- (void) finishKlitchWithId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/outbound/requests/%@", klitchId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self POST:URLString
    parameters:@{@"status": @"finished"}
       success:^(NSURLSessionDataTask *task, id responseObject) {
           completion(YES, nil);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           completion(NO, error);
       }];
}

- (void) createMyOfferForKlitchId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion {
    
    NSString *URLString = [[NSURL URLWithString:@"current/outbound/offers" relativeToURL:self.baseURL] absoluteString];
    
    [self PUT:URLString
   parameters:@{@"request_id":klitchId}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(YES, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(NO, error);
      }];
}

- (void) setIncomingOfferStatus:(NSString *)status InKlitchId:(NSString *)klitchId
                             andForUserId:(NSString*)userId withBlock:(KSBooleanCompletionBlock)completion {
    
    NSString *URLString = [[NSURL URLWithString:@"current/inbound/offers" relativeToURL:self.baseURL] absoluteString];
    
    NSDictionary *params = [NSDictionary new];
    if(status){
        params = @{@"request_id":klitchId, @"user_id":userId, @"status":status};
    }
    else{
        params = @{@"request_id":klitchId, @"user_id":userId};
    }
    
    [self PUT:URLString
   parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(YES, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(NO, error);
      }];
}

- (void) getMyOfferForKlitchId:(NSString *)klitchId withBlock:(KSDictionaryCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/outbound/offers/%@", klitchId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
}

- (void) deleteMyOfferForKlitchId:(NSString *)klitchId withBlock:(KSBooleanCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/outbound/offers/%@", klitchId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self DELETE:URLString
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(YES, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(NO, error);
      }];
}

- (void) getWaitingHelpKlitchesForCommId:(NSString *)commId waithBlock:(KSArrayCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/inbound/requests/%@", commId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
}

- (void) getReadyHelpForMyKlitchWithCommId:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/inbound/offers/%@", commId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
}


@end
