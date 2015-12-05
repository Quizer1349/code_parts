//
//  PGShareConfig.m
//  PosingGuide
//
//  Created by Алекс Скляр on 17.11.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGShareConfig.h"

@implementation PGShareConfig



#pragma mark - App Description

- (NSString*)appName {
    return @"PosingGuide";
}

- (NSString*)appURL {
    return @"https://posingguide.com/";
}

# pragma mark - API Keys

- (NSString*)vkontakteAppId {
    return const_apiKey_Vkontakte;
}

- (NSString*)facebookAppId {
    return const_apiKey_Facebook;
}

- (NSString*)facebookLocalAppId {
    return @"";
}

- (NSNumber*)forcePreIOS6FacebookPosting {
    return [NSNumber numberWithBool:true];
}

- (NSNumber*)forcePreIOS5TwitterAccess {
    return [NSNumber numberWithBool:false];
}

- (NSString*)twitterConsumerKey {
    return @"4sEqkmuuEmE5RvVjzaJbUSnik";
}

- (NSString*)twitterSecret {
    return @"ReLr0lgtb7jQDtgP6sJ7ViwBNlKwI3xS6xxjH5kPukEA633HUM";
}

- (NSString*)twitterCallbackUrl {
    return @"http://photoposingapp.com";
}

- (NSNumber*)twitterUseXAuth {
    return [NSNumber numberWithInt:0];
}

- (NSString*)twitterUsername {
    return @"PosingGuideApp";
}

#pragma mark - UI Configuration : Basic

- (NSNumber *)useAppleShareUI {
    return @YES;
}

- (UIColor*)barTintForView:(UIViewController*)vc {
    
    if ([NSStringFromClass([vc class]) isEqualToString:@"SHKTwitter"])
        return [UIColor colorWithRed:0 green:151.0f/255 blue:222.0f/255 alpha:1];
    
    if ([NSStringFromClass([vc class]) isEqualToString:@"SHKFacebook"])
        return [UIColor colorWithRed:59.0f/255 green:89.0f/255 blue:152.0f/255 alpha:1];
    
    return nil;
}


//-(NSString *)modalPresentationStyleForController:(UIViewController *)controller{
//    if(IS_IPAD()){
//        return @"UIModalPresentationFullScreen";
//    }else{
//        return @"UIModalPresentationFormSheet";
//    }
//}


@end
