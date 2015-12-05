//
//  KSApiClient+Users.m
//  klitch
//
//  Created by admin on 11.03.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient+Users.h"
#import "UIImageView+AFNetworking.h"


@implementation KSApiClient (Users)

- (void) setImageForUserWithId:(NSString *)userId andWithCommId:(NSString *)commId placeholderImage:(UIImage *)placeholderImage forImageView:(UIImageView *)imageView {

    NSString *imageURLString = [NSString stringWithFormat:@"current/memberships/%@/members/%@/avatar", commId, userId];
    NSString *URLString = [[NSURL URLWithString:imageURLString relativeToURL:self.baseURL] absoluteString];
    
    NSURL *imageURL = [NSURL URLWithString:URLString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userData"];
    
    if(userData != nil){
        [request setValue:userData[@"user"] forHTTPHeaderField:@"X-User"];
        [request setValue:userData[@"device"] forHTTPHeaderField:@"X-Device"];
        [request setValue:userData[@"key_hash"] forHTTPHeaderField:@"X-Key-Hash"];
        [request setValue:userData[@"temp_salt"] forHTTPHeaderField:@"X-Temp-Salt"];
    }
    [imageView setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (float) calculateDistanceToPointWithLatitude:(NSString *)latitude andLongitude:(NSString *) longitude {

    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    CLLocationDegrees latitudeCLL = [latitude doubleValue];
    CLLocationDegrees longitudeCLL = [longitude doubleValue];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitudeCLL longitude:longitudeCLL];
    
    CLLocation *currentLocation = locationManager.location;
    
    NSLog(@"Distance - %f", [currentLocation distanceFromLocation:location]);
    
    return [currentLocation distanceFromLocation:location] / 1000;
}

-(void) getOnlineUsersForCommID:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion {

    NSString *endpointURL = [NSString stringWithFormat:@"current/memberships/%@/members/online", commId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];

}

-(void) getReadyUsersForCommID:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/memberships/%@/members/ready", commId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
    
}

-(void) getWaitingUsersForCommID:(NSString *)commId withBlock:(KSArrayCompletionBlock)completion {
    
    NSString *endpointURL = [NSString stringWithFormat:@"current/memberships/%@/members/waiting", commId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];
    
}

-(void) getUserDataForId:(NSString *)userId
               andCommId:(NSString *)commId withBlock:(KSDictionaryCompletionBlock)completion {

    NSString *endpointURL = [NSString stringWithFormat:@"current/memberships/%@/members/%@", commId, userId];
    NSString *URLString = [[NSURL URLWithString:endpointURL relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
      }];

}

@end
