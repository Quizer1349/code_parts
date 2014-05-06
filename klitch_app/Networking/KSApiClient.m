//
//  NSApiClient.m
//  klitch
//
//  Created by admin on 20.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//
#import "KSApiClient.h"
#import "JSONResponseSerializerWithData.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "XRSA.h"
#import "Constants.h"
#include <openssl/rsa.h>
#include <openssl/rand.h>
#include <openssl/pem.h>
#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/sha.h>

#define PEM_FOLDER_PATH @"Certificates"
#define PEM_CERTIFICATE_PATH_POSTFIX [NSString stringWithFormat:@"%@/public_key.pem", PEM_FOLDER_PATH]

@implementation KSApiClient

//static NSString * const kKSClientAPIBaseURLString = @"";

#warning developer API server
static NSString * const kKSClientAPIBaseURLString = @"";

#pragma mark - Class Methods

+ (instancetype)sharedClient{
    static dispatch_once_t onceQueue;
    static KSApiClient *__sharedClient = nil;
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

+ (NSURL *)APIBaseURL{

    return [NSURL URLWithString:kKSClientAPIBaseURLString];
}

#pragma mark -
#pragma mark - Network status methods
- (BOOL)connected
{
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

-(void)  showNoConnectionAlert {

    UIAlertView *alertViewError = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                             message:@"Для работы данного приложения необходим Интернет!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alertViewError show];

}

- (void)startMonitoringConnection{

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

- (void)stopMonitoringConnection{

    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)startNetworkActivity {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopNetworkActivity {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark - API methods
- (void) registerUserWithName:(NSString *)name andPhone:(NSString *)phone withBlock:(KSDictionaryCompletionBlock)completion
{
    NSString *URLString = [[NSURL URLWithString:@"register" relativeToURL:self.baseURL] absoluteString];
#if (TARGET_IPHONE_SIMULATOR)
    NSString *token = @"Hhjhf234auhsd234njUIHSDJS7fas23JKHASJsaHFAS2345";
#else
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"push_id"];
#endif
    
//    token = @"Hhjhf234auhsd234njUIHSDJS7fas23JKHASJsaHFAS2345";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            phone, @"phone",
                            token, @"push_id",
                            @"ios", @"type",nil];
    [self PUT:URLString
   parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject){
          [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"activationData"];
          completion(responseObject, nil);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error){
          completion(nil, error);
      }];
}


#pragma mark
#pragma mark - activate user
- (void) activateUserWithPin:(NSString *)pin withBlock:(KSDictionaryCompletionBlock)completion{
    
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       
       NSDictionary *activationData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)const_ActivationDataKey];
       
       NSString *registration = [activationData objectForKey:(NSString *)const_RegistrationIDKey];
       NSString *salt = [activationData objectForKey:(NSString *)const_PinSaltKey];
       NSMutableDictionary *requestDict = [self generateActivationDataWithPin:pin andSalt:salt];
       [requestDict setObject:registration forKey:(NSString *)const_RegistrationIDKey];
       dispatch_async(dispatch_get_main_queue(), ^{
           [self sendActivationRequestWithParameters:requestDict andWithBlock:completion];
       });
   });
    
}

- (void) sendActivationRequestWithParameters:(NSDictionary *)params andWithBlock:(KSDictionaryCompletionBlock)completion{
    NSString *URLString = [[NSURL URLWithString:@"confirm" relativeToURL:self.baseURL] absoluteString];
    //NSDictionary *activationData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:(NSString *)const_ActivationDataKey];
    [self POST:URLString
    parameters:params
       success:^(NSURLSessionDataTask *task, id responseObject) {
           //Server temp activation
           NSDictionary *keyHashData = [self generateKeyHashWithKey:params[const_Key]];
           NSDictionary *activationData = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"activationData"];
           
           NSDictionary *userData =[NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%@", responseObject[@"user"]], @"user",
                                    [NSString stringWithFormat:@"%@", responseObject[@"device"]], @"device",
                                    activationData[@"x_key_hash"], @"key_hash",
                                    activationData[@"x_temp_salt"], @"temp_salt", nil];
           [[NSUserDefaults standardUserDefaults] setObject:userData forKey:(NSString *)const_userHeadersKey];
           completion(responseObject, nil);
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           completion(nil, error);
       }];
}

#pragma mark
#pragma mark - generate data for activation user
- (NSMutableDictionary *) generateActivationDataWithPin:(NSString *)pin andSalt:(NSString *)pinSalt{
    NSMutableDictionary *resultDict = [NSMutableDictionary new];
    
    [resultDict addEntriesFromDictionary:[self generateEncryptedKey:[self loadPEMCertificate]]];
    [resultDict addEntriesFromDictionary:[self generatePinHash:pin andWithPinSalt:pinSalt]];
    
    return resultDict;
}

#pragma mark
#pragma mark - load certificate
- (NSString *) loadPEMCertificate{
    
    NSURL *docDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                            inDomains:NSUserDomainMask] lastObject];
    
    NSString *path = [docDir.path stringByAppendingPathComponent:(NSString *)PEM_CERTIFICATE_PATH_POSTFIX];

    if(![[NSFileManager defaultManager] isReadableFileAtPath:path]){
        
        NSError* flError;
        
        [[NSFileManager defaultManager] createDirectoryAtPath:[docDir.path stringByAppendingPathComponent:(NSString *)PEM_FOLDER_PATH] withIntermediateDirectories:YES attributes:nil error:&flError];
        
        if(![[NSFileManager defaultManager] createFileAtPath:path contents:[NSData new] attributes:nil]){
            NSLog(@"[%@] ERROR: attempting to write create Certificate directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
        
        //should load PEM certificate
        NSString *urlString = [[NSURL URLWithString:@"pubkey" relativeToURL:self.baseURL] absoluteString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setHTTPShouldHandleCookies:YES];
        [request setAllowsCellularAccess:YES];
        
        [request setURL:[NSURL URLWithString:urlString]];
        [request setValue:@"text/plain" forHTTPHeaderField:@"Accept"];
        [request setValue:@"text/plain" forHTTPHeaderField:@"Content-type"];
        
        [request setHTTPMethod:@"GET"];
        
        NSError *error = nil;
        NSURLResponse* response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (error != nil && [data length] == 0){
            NSLog(@"%@", error);
            return nil;
        }
        
        NSString *responseStr = [[NSString alloc] initWithData:data
                                                      encoding:NSASCIIStringEncoding];
        
        if([responseStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]){
            NSLog(@"key saved");
            NSLog(@"%@", path);
        }
    }
    return path;
}

#pragma mark
#pragma mark - generation encrypted key
- (NSDictionary *) generateEncryptedKey:(NSString *)certificatePath{
    
    unsigned char generatedKey[64];
    RAND_pseudo_bytes(generatedKey, sizeof(generatedKey));
    
    NSData *encodedGeneretedKey_data = [NSData dataWithBytes:generatedKey length:sizeof(generatedKey)];
    NSString *encodedGeneretedKey_string =  [encodedGeneretedKey_data base64EncodedString];
    
    const char *pub_key_pem = [certificatePath UTF8String];
    FILE *rsa_pkey_file = fopen(pub_key_pem, "r");
    
    EVP_PKEY *evpKey = PEM_read_PUBKEY(rsa_pkey_file, NULL, NULL, NULL);
    RSA *rsa_pub = EVP_PKEY_get1_RSA(evpKey);
    
    unsigned char encodedKey[128];
    
    RSA_public_encrypt(sizeof(generatedKey), generatedKey, encodedKey, rsa_pub, RSA_PKCS1_OAEP_PADDING);
    
    NSData *encodedKey_data = [NSData dataWithBytes:encodedKey length:sizeof(encodedKey)];
    NSString *encodedKey_string =  [encodedKey_data base64EncodedString];

    return @{(NSString *)const_EncryptedKey:encodedKey_string, (NSString *)const_Key:encodedGeneretedKey_string};
}

#pragma mark
#pragma mark - generation pin_hash

#define TEMP_SALT_SIZE 32
- (NSDictionary *) generatePinHash:(NSString *)pin andWithPinSalt:(NSString *)pinSalt{

    NSData *saltData = [NSData dataFromBase64String:pinSalt];
    NSUInteger saltSize = [saltData length] / sizeof(unsigned char);
    unsigned char pinSalt_ch[saltSize];
    [saltData getBytes:&pinSalt_ch length:saltSize];
    unsigned char pin_derived[SHA512_DIGEST_LENGTH];

    PKCS5_PBKDF2_HMAC_SHA1([pin UTF8String], -1, pinSalt_ch, sizeof(pinSalt_ch), 1000, SHA512_DIGEST_LENGTH, pin_derived);
    
    unsigned char tempSalt[TEMP_SALT_SIZE];
    RAND_pseudo_bytes(tempSalt, sizeof(tempSalt));
    
    NSMutableData *pinHash_data = [NSMutableData dataWithBytes:tempSalt length:sizeof(tempSalt)];
    [pinHash_data appendBytes:pin_derived length:SHA512_DIGEST_LENGTH];
    
    unsigned char pin_hash[SHA512_DIGEST_LENGTH];
    
    NSUInteger pinHashSize = [pinHash_data length] / sizeof(unsigned char);
    unsigned char pin_hash_data[pinHashSize];
    [pinHash_data getBytes:&pin_hash_data length:pinHashSize];
    
    SHA512((unsigned char*)&pin_hash_data, pinHashSize, (unsigned char*)&pin_hash);

    NSString *pin_hash_string = [[NSData dataWithBytes:pin_hash length:sizeof(pin_hash)] base64EncodedString];
    
    NSData *tempSalt_data = [NSMutableData dataWithBytes:tempSalt length:sizeof(tempSalt)];
    NSString *temp_salt_string = [tempSalt_data base64EncodedString];
    
    return @{(NSString *)const_PinHashKey: pin_hash_string, (NSString *)const_TempSaltKey:temp_salt_string};
}

#pragma mark
#pragma mark - generation key_hash
- (NSDictionary *) generateKeyHashWithKey:(NSString *)key{
    
    NSData *keyData = [NSData dataFromBase64String:key];
    NSUInteger keySize = [keyData length] / sizeof(unsigned char);
    unsigned char key_ch[keySize];
    [keyData getBytes:&key_ch length:keySize];
    
    unsigned char tempSalt[TEMP_SALT_SIZE];
    RAND_pseudo_bytes(tempSalt, sizeof(tempSalt));
    
    NSMutableData *keyHash_data = [NSMutableData dataWithBytes:tempSalt length:sizeof(tempSalt)];
    [keyHash_data appendBytes:key_ch length:SHA512_DIGEST_LENGTH];
    
    unsigned char key_hash[SHA512_DIGEST_LENGTH];
    NSUInteger keyHashSize = [keyHash_data length] / sizeof(unsigned char);
    unsigned char key_hash_data[keyHashSize];
    [keyHash_data getBytes:&key_hash_data length:keyHashSize];

    
    SHA512((unsigned char*)&key_hash_data, keyHashSize, (unsigned char*)&key_hash);
    
    NSString *key_hash_string = [[NSData dataWithBytes:key_hash length:sizeof(key_hash)] base64EncodedString];
    NSData *tempSalt_data = [NSMutableData dataWithBytes:tempSalt length:sizeof(tempSalt)];
    NSString *temp_salt_string = [tempSalt_data base64EncodedString];
    
    return @{(NSString *)const_HeaderKey:key_hash_string, (NSString *)const_HeaderTempSalt:temp_salt_string};
}

@end
