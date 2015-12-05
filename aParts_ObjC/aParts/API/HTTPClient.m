//
//  HTTPClient.m
//  MyLibrary
//
//  Created by Eli Ganem on 8/7/13.
//  Copyright (c) 2013 Eli Ganem. All rights reserved.
//

#import "HTTPClient.h"
#import "JSONResponseSerializerWithData.h"

@implementation HTTPClient


static NSString * const kKSClientAPIBaseURLString = @"http://62.76.187.102:8001/api/";

#pragma mark - Class Methods

+ (instancetype)sharedClient{
    static dispatch_once_t onceQueue;
    static HTTPClient *__sharedClient = nil;
    dispatch_once(&onceQueue, ^{
        __sharedClient = [[self alloc] init];
    });
    NSDictionary *userData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)const_userHeadersKey];
    if(userData != nil){
        [__sharedClient.requestSerializer setValue:userData[@"user"] forHTTPHeaderField:@"X-User"];
        [__sharedClient.requestSerializer setValue:userData[@"device"] forHTTPHeaderField:@"X-Device"];
        [__sharedClient.requestSerializer setValue:userData[@"key_hash"] forHTTPHeaderField:@"X-Key-Hash"];
        [__sharedClient.requestSerializer setValue:userData[@"temp_salt"] forHTTPHeaderField:@"X-Temp-Salt"];
    }
    
    //NSLog(@"Headers: %@", __sharedClient.requestSerializer.HTTPRequestHeaders);
    
    return __sharedClient;
}


- (id)init{
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                      diskCapacity:50 * 1024 * 1024
                                                          diskPath:nil];
    
    [config setURLCache:cache];
    
    if (self = [super initWithBaseURL:[[self class] APIBaseURL] sessionConfiguration:config])
    {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [JSONResponseSerializerWithData serializer];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    
    [self startMonitoringConnection];
    
    return self;
}

-(void)  showNoConnectionAlert {
    
    UIAlertView *alertViewError = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                             message:@"Для работы данного приложения необходим Интернет!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertViewError show];
    
}

- (void)startMonitoringConnection {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                [self cancelAllOperations];
                [self showNoConnectionAlert];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                break;
            default:
                NSLog(@"Unknown network");
                break;
        }
    }];
    
}

-(void)cancelAllOperations {
    [[self.operationQueue operations] makeObjectsPerformSelector:@selector(cancel)];
}

- (void)stopMonitoringConnection {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)startNetworkActivity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopNetworkActivity {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (NSURL *)APIBaseURL{
    return [NSURL URLWithString:kKSClientAPIBaseURLString];
}

- (BOOL)connected {
    
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

- (id)getRequest:(NSString*)url {
    return nil;
}

- (id)postRequest:(NSString*)url body:(NSString*)body{
    return nil;
}

- (UIImage*)downloadImage:(NSString*)url{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [UIImage imageWithData:data];
}

@end
