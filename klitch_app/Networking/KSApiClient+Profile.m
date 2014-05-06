//
//  KSApiClient+Profile.m
//  klitch
//
//  Created by admin on 27.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSApiClient+Profile.h"
#import "UIImageView+AFNetworking.h"
#import "NSData+Base64.h"
#import "JSONKit.h"

#define IMG_PARAMETER_NAME @"img"

@implementation KSApiClient (Profile)

- (void) sendCurrnetLocation:(NSDictionary *)currentLocation withBlock:(KSBooleanCompletionBlock)completion {
    
    NSString *URLString = [[NSURL URLWithString:@"current/location" relativeToURL:self.baseURL] absoluteString];
    
    [self POST:URLString
    parameters:currentLocation
       success:^(NSURLSessionDataTask *task, id responseObject) {
           completion(YES,nil);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           completion(NO, error);
       }];
}

- (void) postProfileData:(NSDictionary *)profileData withBlock:(KSBooleanCompletionBlock)completion {
    
    NSString *URLString = [[NSURL URLWithString:@"current" relativeToURL:self.baseURL] absoluteString];
    
    [self POST:URLString
    parameters:profileData
       success:^(NSURLSessionDataTask *task, id responseObject) {
           completion(YES,nil);
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           completion(NO, error);
       }];
}

- (void) getProfileDataWithBlock:(KSDictionaryCompletionBlock)completion {
    
    NSString *URLString = [[NSURL URLWithString:@"current" relativeToURL:self.baseURL] absoluteString];
    
    [self GET:URLString
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          completion(responseObject, nil);
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          completion(nil, error);
   }];
}

- (void) getProfileImageWithPaceholderImage:(UIImage *)placeholderImage forImageView:(UIImageView *)imageView {
    
    NSURL *imageURL = [NSURL URLWithString:@"current/avatar" relativeToURL:self.baseURL];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
    
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userData"];
    
    if(userData != nil){
        
        [request setValue:userData[@"user"] forHTTPHeaderField:@"X-User"];
        [request setValue:userData[@"device"] forHTTPHeaderField:@"X-Device"];
        [request setValue:userData[@"key_hash"] forHTTPHeaderField:@"X-Key-Hash"];
        [request setValue:userData[@"temp_salt"] forHTTPHeaderField:@"X-Temp-Salt"];
    }
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:placeholderImage success:nil failure:nil];

}

-(void) uploadProfileImage:(UIImage *)image withBlock:(KSBooleanCompletionBlock)completion{
    
//    NSString *urlString = [[NSURL URLWithString:@"current/avatar" relativeToURL:self.baseURL] absoluteString];

        //AFNetworking have an issue with content lenght https://github.com/AFNetworking/AFNetworking/issues/1398
        //that is why I rewrote it for avoiding using AFNetworking
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"current/avatar" relativeToURL:self.baseURL] ];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"userData"];
    
    if(userData != nil){
        [request setValue:userData[@"user"] forHTTPHeaderField:@"X-User"];
        [request setValue:userData[@"device"] forHTTPHeaderField:@"X-Device"];
        [request setValue:userData[@"key_hash"] forHTTPHeaderField:@"X-Key-Hash"];
        [request setValue:userData[@"temp_salt"] forHTTPHeaderField:@"X-Temp-Salt"];
    }
    
    NSDictionary *requestDictionary = @{IMG_PARAMETER_NAME : [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]};
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[requestDictionary JSONData]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
        
        if (error != nil && [data length] == 0){
            completion(NO, error);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES, nil);
            });
        }
        
        NSString *responseStr = [[NSString alloc] initWithData:data
                                                      encoding:NSASCIIStringEncoding];
        NSLog(@"%@", responseStr);
    }];
}

@end
