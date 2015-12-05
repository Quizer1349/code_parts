//
//  PGShareMenu.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 26.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGShareMenu.h"
#import <ShareKit/ShareKit.h>
#import "SHKFacebook.h"
#import <ShareKit/SHKTwitter.h>
#import "SHKVkontakte.h"
#import "SHKMail.h"
#import "SHKiOSTwitter.h"
#import "SHKTwitterCommon.h"
#import "SHKiOSFacebook.h"
#import "SHKFacebookCommon.h"
#import "SHKInstagram.h"
#import "PGInstagramSharer.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import  <FacebookSDK/FBLinkShareParams.h>
#import <FacebookSDK/FacebookSDK.h>


@interface PGShareMenu () <UIDocumentInteractionControllerDelegate, SHKSharerDelegate>{

    ACAccountStore *_accountStore;
}

@property (nonatomic, retain) UIDocumentInteractionController *dic;

@end


@implementation PGShareMenu

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;
}

#define IPAD_VIEW_SUFFIX @"-ipad"
#define MINI_VIEW_SUFFIX @"@mini"


-(void)baseInit {
    
    if (IS_IPAD()) {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), IPAD_VIEW_SUFFIX] owner:self options:nil];
    } else {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    }
    
    
    [self setAutoresizesSubviews:YES];
    
    
    if (!CGRectIsEmpty(self.frame)) {
        if(self.frame.size.height < self.view.frame.size.height){
            
            
            if (IS_IPAD()) {
                [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@%@%@", NSStringFromClass([self class]), MINI_VIEW_SUFFIX, IPAD_VIEW_SUFFIX] owner:self options:nil];
            } else {
                [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), MINI_VIEW_SUFFIX] owner:self options:nil];
            }
            self.minimalView.backgroundColor = [UIColor clearColor];
            [self.minimalView setFrame:self.bounds];
            [self addSubview:self.minimalView];
        }else{
            [self.view setFrame:self.bounds];
            [self addSubview:self.view];
        }
    }else{
        [self setFrame:self.view.frame];
        [self addSubview:self.view];
    }
    
    //Set clear for colored IB xib viewing
    self.view.backgroundColor = [UIColor clearColor];
    
    self.shareMenuLabel.text = NSLocalizedString(const_local_shareMenuLabel, nil);
    DLog(@"self.frame - %@", NSStringFromCGRect(self.frame));

}


#pragma mark - Button actions

- (IBAction)mailPressed:(id)sender {

    if(self.shareItem){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.title =  NSLocalizedString(const_local_shareDefaultText, nil);
        self.shareItem.text  =  NSLocalizedString(const_local_shareMailDefaultText, nil);
        SHKMail *mailShare = [[SHKMail alloc] init];
        mailShare.shareDelegate = self;
        
        [mailShare loadItem:self.shareItem];
        [mailShare share];
        
    }
}

- (IBAction)instagrammPressed:(id)sender {

    if(self.shareItem.image){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.title =  NSLocalizedString(const_local_shareDefaultText, nil);
        self.shareItem.text  =  NSLocalizedString(const_local_shareMailDefaultText, nil);
        if([SHKInstagram canShare]){
            SHKInstagram *instaShare = [[SHKInstagram alloc] init];
            instaShare.shareDelegate = self;
            
            [instaShare loadItem:self.shareItem];
            [instaShare share];
        }else{
            ALERT(NSLocalizedString(const_local_shareInstaAlertTitle, nil) , NSLocalizedString(const_local_shareInstaAlertMsg, nil));
        }
    }
}

- (IBAction)twitterPressed:(id)sender {

    if(self.shareItem){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.text =  NSLocalizedString(const_local_shareDefaultText, nil);
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType  options:nil completion:^(BOOL granted, NSError *error) {
            //completion handling is on indeterminate queue so I force main queue inside
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!granted || [self twitterAvailableAccounts].count == 0){
                    [SHKTwitter shareItem:self.shareItem];
                }else{
                    if([SHKTwitterCommon socialFrameworkAvailable]){
                        SHKiOSTwitter * iosTwitter = [[SHKiOSTwitter alloc] init];
                        iosTwitter.quiet = YES;
                        iosTwitter.shareDelegate = self;
                        [iosTwitter loadItem:self.shareItem];
                        [iosTwitter share];
                        
                    }else{

                        [SHKTwitter shareItem:self.shareItem];
                    }
                }
            });
        }];
    }
}

- (IBAction)facebookPressed:(id)sender {

    if(self.shareItem){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        //self.shareItem.title =  NSLocalizedString(const_local_shareDefaultText, nil);
        //self.shareItem.shareType = SHKShareTypeImage;
    }
    
////        NSDictionary *options = @{ACFacebookAppIdKey : const_apiKey_Facebook,
////                                  ACFacebookPermissionsKey : @[@"email"]};
////        
////        ACAccountType *faceBookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
////        [self.accountStore requestAccessToAccountsWithType:faceBookAccountType  options:options completion:^(BOOL granted, NSError *error) {
////            //completion handling is on indeterminate queue so I force main queue inside
////            dispatch_async(dispatch_get_main_queue(), ^{
////
//                if([self facebookAvailableAccounts].count == 0){
//                    [SHKFacebook shareItem:self.shareItem];
//                }else{
//                
//                    if([SHKFacebookCommon socialFrameworkAvailable]){
//                        SHKiOSFacebook * iosFacebook = [[SHKiOSFacebook alloc] init];
//                        iosFacebook.quiet = YES;
//                        iosFacebook.shareDelegate = self;
//                        [iosFacebook loadItem:self.shareItem];
//                        [iosFacebook share];
//                        
//                    }else{
//                        [SHKFacebook shareItem:self.shareItem];
//                    }
//                }
////            });
////        }];
//
//    }
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [controller addImage:self.shareItem.image];
            
            // Sets the completion handler.  Note that we don't know which thread the
            // block will be called on, so we need to ensure that any UI updates occur
            // on the main queue
            controller.completionHandler = ^(SLComposeViewControllerResult result) {
                switch(result) {
                        //  This means the user cancelled without sending the Tweet
                    case SLComposeViewControllerResultCancelled:
                        
                        break;
                        //  This means the user hit 'Send'
                    case SLComposeViewControllerResultDone:
                        [[NSNotificationCenter defaultCenter] postNotificationName:PGShareMenuSendDidFinishNotification object:nil];
                        break;
                }
            };
            
            
            [self.baseVC presentViewController:controller animated:YES completion:Nil];
            
        }else{
            FBPhotoParams *photoParams = [[FBPhotoParams alloc] initWithPhotos:@[self.shareItem.image]];
            // If the Facebook app is installed and we can present the share dialog
            if ([FBDialogs canPresentShareDialogWithPhotos]) {
                
                [self openFBShareDialogWithParams:photoParams];
            } else {
                self.shareItem.text = nil;
                self.shareItem.title = nil;
                SHKFacebook *faceShare = [[SHKFacebook alloc] init];
                faceShare.shareDelegate = self;
                
                [faceShare loadItem:self.shareItem];
                [faceShare share];
            }
        }
}

-(void) openFBShareDialogWithParams:(FBPhotoParams *)params {
    
    // Present share dialog

    [FBDialogs presentShareDialogWithPhotoParams:params
                                     clientState:nil
                                         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                            if(error) {
                                                // An error occurred, we need to handle the error
                                                DLog(@"Error publishing story: %@", error.description);
                                            } else {
                                                [[NSNotificationCenter defaultCenter] postNotificationName:PGShareMenuSendDidFinishNotification object:nil];
                                                DLog(@"result %@", results);

                                            }
                                         }];
}



// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (IBAction)vkPressed:(id)sender {

    if(self.shareItem){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.text =  NSLocalizedString(const_local_shareDefaultText, nil);
        [SHKVkontakte shareItem:self.shareItem];
    }
}

#pragma mark - SHKSharerDelegate
-(void)sharerFinishedSending:(SHKSharer *)sharer{

    //[[NSNotificationCenter defaultCenter] postNotificationName:PGShareMenuSendDidFinishNotification object:nil];
    
}

-(void)sharerShowBadCredentialsAlert:(SHKSharer *)sharer{

    DLog(@"sharer alerts - %@", sharer.description);
}

-(void)sharer:(SHKSharer *)sharer failedWithError:(NSError *)error shouldRelogin:(BOOL)shouldRelogin{
    DLog(@"sharer alerts - %@", sharer.description);
}

-(void)sharerShowOtherAuthorizationErrorAlert:(SHKSharer *)sharer {
    DLog(@"sharer alerts - %@", sharer.description);
}

-(void)sharerCancelledSending:(SHKSharer *)sharer {
    DLog(@"sharer alerts - %@", sharer.description);
}
-(void)sharerAuthDidFinish:(SHKSharer *)sharer success:(BOOL)success {

    if ([sharer isKindOfClass:[SHKiOSFacebook class]] && !success) {
        [SHKFacebook shareItem:self.shareItem];
    }else if([sharer isKindOfClass:[SHKiOSTwitter class]] && !success) {
        [SHKTwitter shareItem:self.shareItem];
    }
}

- (void)showProgress:(CGFloat)progress forSharer:(SHKSharer *)sharer {

}

-(void)hideActivityIndicatorForSharer:(SHKSharer *)sharer{

}

-(void)sharerStartedSending:(SHKSharer *)sharer{

}

-(void)displayActivity:(NSString *)activityDescription forSharer:(SHKSharer *)sharer{

}

-(void)displayCompleted:(NSString *)completionText forSharer:(SHKSharer *)sharer{


}

#pragma mark - Watermark
- (UIImage *)addWatermarkToImage:(UIImage *)image {
    
    UIImage *watermarkImage;
    
    if (Is4Inches()) {
        watermarkImage = [UIImage imageNamed:RETINA4_FILENAME(const_fileName_watermarkImage, RETINA4_PREFIX)];
    }else{
        watermarkImage = [UIImage imageNamed:const_fileName_watermarkImage];
    }
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [watermarkImage drawInRect:CGRectMake(image.size.width - watermarkImage.size.width, image.size.height - watermarkImage.size.height, watermarkImage.size.width, watermarkImage.size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

#pragma mark - Authorization helpers

- (NSArray *)twitterAvailableAccounts {
    
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *result = [self.accountStore accountsWithAccountType:twitterAccountType];
    return result;
}

- (NSArray *)facebookAvailableAccounts {
    
    ACAccountType *facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *result = [self.accountStore accountsWithAccountType:facebookAccountType];
    return result;
}


#pragma mark - ACAccountStore lazy loading

- (ACAccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

@end
