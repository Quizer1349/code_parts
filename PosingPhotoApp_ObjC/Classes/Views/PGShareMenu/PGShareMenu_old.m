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
        [SHKMail shareItem:self.shareItem];
        
    }
}

- (IBAction)instagrammPressed:(id)sender {

    if(self.shareItem.image){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.title =  NSLocalizedString(const_local_shareDefaultText, nil);
        self.shareItem.text  =  NSLocalizedString(const_local_shareMailDefaultText, nil);
        if([SHKInstagram canShare]){
            [SHKInstagram shareItem:self.shareItem];
        }else{
            ALERT(NSLocalizedString(const_local_shareInstaAlertTitle, nil) , NSLocalizedString(const_local_shareInstaAlertMsg, nil));
        }
    }
}

- (IBAction)twitterPressed:(id)sender {

    if(self.shareItem){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.text =  NSLocalizedString(const_local_shareDefaultText, nil);
//        [SHKTwitter shareItem:self.shareItem];
        
        if([self twitterAvailableAccounts].count == 0){

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
    }
}

- (IBAction)facebookPressed:(id)sender {

    if(self.shareItem){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.text =  NSLocalizedString(const_local_shareDefaultText, nil);
        
        NSDictionary *options = @{ACFacebookAppIdKey : const_apiKey_Facebook,
                                  ACFacebookPermissionsKey : @[@"email, publish_actions"]};
        
        ACAccountType *faceBookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [self.accountStore requestAccessToAccountsWithType:faceBookAccountType  options:options completion:^(BOOL granted, NSError *error) {
            //completion handling is on indeterminate queue so I force main queue inside
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!granted || [self facebookAvailableAccounts].count == 0){
                    [SHKFacebook shareItem:self.shareItem];
                }else{

                    if([SHKFacebookCommon socialFrameworkAvailable]){
                        SHKiOSFacebook * iosFacebook = [[SHKiOSFacebook alloc] init];
                        iosFacebook.quiet = YES;
                        iosFacebook.shareDelegate = self;
                        [iosFacebook loadItem:self.shareItem];
                        [iosFacebook share];
                        
                    }else{
                        [SHKFacebook shareItem:self.shareItem];
                    }
                }
            });
        
        }];
    }
}

- (IBAction)vkPressed:(id)sender {

    if(self.shareItem){
        self.shareItem.image = [self addWatermarkToImage:self.shareItem.image];
        self.shareItem.text =  NSLocalizedString(const_local_shareDefaultText, nil);
        
        [SHKVkontakte shareItem:self.shareItem];

    }
}

#pragma mark - SHKSharerDelegate
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

     NSLog(@"sharer sharerAuthDidFinish alerts - %@", sharer.description);
    
    if ([sharer isKindOfClass:[SHKiOSFacebook class]] && !success) {
        [SHKFacebook shareItem:self.shareItem];
    }else if([sharer isKindOfClass:[SHKiOSTwitter class]] && !success) {
        [SHKTwitter shareItem:self.shareItem];
    }

}

-(void)displayActivity:(NSString *)activityDescription forSharer:(SHKSharer *)sharer{
    
    DLog(@"sharer displayActivity alerts - %@", sharer.description);
}

-(void)hideActivityIndicatorForSharer:(SHKSharer *)sharer{
 
    DLog(@"sharer hideActivityIndicatorForSharer alerts - %@", sharer.description);
}

- (void)sharerStartedSending:(SHKSharer *)sharer{
    
    DLog(@"sharer sharerStartedSending alerts - %@", sharer.description);
}

- (void)showProgress:(CGFloat)progress forSharer:(SHKSharer *)sharer{

    DLog(@"sharer showProgress alerts - %@", sharer.description);
}

-(void)displayCompleted:(NSString *)completionText forSharer:(SHKSharer *)sharer{

    DLog(@"sharer displayCompleted alerts - %@", sharer.description);
}

-(void)sharerFinishedSending:(SHKSharer *)sharer{
    
    DLog(@"sharer sharerFinishedSending alerts - %@", sharer.description);
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
