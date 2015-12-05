//
//  PGCircleMenu.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 07.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGCircleMenu.h"
#import "ShareKit.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"
#import "SHKVkontakte.h"
#import "SHKInstagram.h"
#import "SHKMail.h"
#import "SHKiOSTwitter.h"
#import "SHKiOSFacebook.h"
#import "SHKTwitterCommon.h"
#import "SHKFacebookCommon.h"
#import "PGInstagramSharer.h"
#import "PGTextArcView2.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import  <FacebookSDK/FBLinkShareParams.h>
#import <FacebookSDK/FacebookSDK.h>


@interface PGCircleMenu () <SHKSharerDelegate> {

    PGTextArcView2 *curveLabel;
    ACAccountStore *_accountStore;
}

@end

@implementation PGCircleMenu

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

-(void)baseInit {

    if(IS_IPAD()){
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"-ipad"] owner:self options:nil];
    }else{
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    }
    
    if (!CGRectIsEmpty(self.frame)) {
    
        [self.view setFrame:self.bounds];
        
    }else{
        
        [self setFrame:self.view.frame];
    }
        
    [self hideMenuWithAnimation:NO];
    [self addSubview:self.view];
    
    [self textDrawingTool];
}

#pragma mark -
#pragma mark - Circle text

- (void)textDrawingTool {
    //
    //    CTFontRef fontRef =
    //    CTFontCreateWithName((CFStringRef)@"Chalkduster", 36.0f, NULL); // 9-1
    //    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(id)[[UIColor blueColor] CGColor], (NSString *)(kCTForegroundColorAttributeName), (id)[[UIColor redColor] CGColor], (NSString *) kCTStrokeColorAttributeName, (id)[NSNumber numberWithFloat:-3.0], (NSString *)kCTStrokeWidthAttributeName, nil]; // 10-1
    //    CFRelease(fontRef); // 11-1
    //
    //
    //    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"ИЗБРАННОЕ" attributes:attrDictionary];
    
    curveLabel = [[PGTextArcView2 alloc] init];
    if(IS_IPAD()){
        
        curveLabel.frame  = CGRectMake(X(self.menuBackground), Y(self.menuBackground) + 15.f, WIDTH(self) + 30.f, HEIGHT(self) + 30.f);
    }else{
        
        curveLabel.frame  = CGRectMake(X(self.menuBackground), Y(self.menuBackground), WIDTH(self), HEIGHT(self));
    }

    curveLabel.userInteractionEnabled = NO;
    NSMutableString *menuTextItems = [[NSMutableString alloc] init];
    for (int i = 0; i < CIRCLE_POSE_MENU_LABEL_ITEMS.count; i++) {
        if (i != CIRCLE_POSE_MENU_LABEL_ITEMS.count - 1 && i != 0) {
            if([CIRCLE_POSE_MENU_LABEL_ITEMS[i] length] > 10){
                [menuTextItems appendFormat:@"   %@    ", NSLocalizedString(CIRCLE_POSE_MENU_LABEL_ITEMS[i], nil)];
            }else{
                [menuTextItems appendFormat:@"    %@    ", NSLocalizedString(CIRCLE_POSE_MENU_LABEL_ITEMS[i], nil)];
            }
            
        }else if(i == CIRCLE_POSE_MENU_LABEL_ITEMS.count - 1){
            [menuTextItems appendFormat:@"       %@   ", NSLocalizedString(CIRCLE_POSE_MENU_LABEL_ITEMS[i], nil)];
        }else{
            [menuTextItems appendString:NSLocalizedString(CIRCLE_POSE_MENU_LABEL_ITEMS[i], nil)];
        }
    }
    //curveLabel.text = @"ИЗБРАННОЕ      ПРАВИЛА        ПОЛНАЯ ВЕРСИЯ      БОЛШЕ...";
    curveLabel.text = menuTextItems;
    curveLabel.backgroundColor = [UIColor clearColor];
    //curveLabel.center = CGPointMake(X(curveLabel) + WIDTH(curveLabel)/2, Y(curveLabel) - 135.f);
    DLog(@"curveLabel.center  - %@", NSStringFromCGPoint(curveLabel.center));
    
    if(IS_IPAD()){
        [curveLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-44))];
    }else{
        [curveLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45))];
    }

    
    curveLabel.hidden = YES;
    
    [self addSubview:curveLabel];
    
}


#pragma mark - 
#pragma mark - Button actions

- (IBAction)mainButtonPressed:(id)sender {

    if(_isMenuVisible){
        
        [self hideMenuWithAnimation:YES];
    } else {
        
        [self showMenuWithAnimation:YES];
    }
    
    if(!self.delegate)
        return;
    
    if(![self.delegate respondsToSelector:@selector(circleMenu:mainButtonPressed:)]){
        return;
    }
    
    [self.delegate circleMenu:self mainButtonPressed:sender];

}

- (IBAction)savePressed:(UIButton *)sender {
    
    
     if(_isShareMenuVisible){
         
         [self hideShareMenu];
     } else {
         
         [self showShareMenu];
     }
}

- (IBAction)favoritesPressed:(id)sender {

    if(!self.delegate)
        return;
    
    [self.delegate circleMenu:self favoritesPressed:sender];
}

- (IBAction)tipsPressed:(id)sender {

    if(!self.delegate)
        return;
    
    [self.delegate circleMenu:self tipsPressed:sender];
}

- (IBAction)photoPressed:(id)sender {

    if(!self.delegate)
        return;
    
    [self.delegate circleMenu:self photoPressed:sender];
}

#pragma mark -
#pragma mark - Show / Hide menu

- (void)hideMenuWithAnimation:(BOOL)isAnimation {
    
    _isMenuVisible = NO;
    
    curveLabel.hidden = YES;
    self.buttonView.hidden = YES;
    self.menuBackground.hidden = YES;
    self.mainMenuButton.selected = NO;
    
    [self hideShareMenu];
}

-(void)showMenuWithAnimation:(BOOL)isAnimation {

    _isMenuVisible = YES;
    
    curveLabel.hidden = NO;
    self.buttonView.hidden = NO;
    self.menuBackground.hidden = NO;
    self.mainMenuButton.selected = YES;
}

#pragma mark -
#pragma mark - Share menu

-(void)showShareMenu {

    _isShareMenuVisible = YES;
    self.shareMenuView.hidden = NO;
    self.saveMenuButton.selected = YES;
}

-(void)hideShareMenu {
    
    _isShareMenuVisible = NO;
    self.shareMenuView.hidden = YES;
    self.saveMenuButton.selected = NO;
}


#pragma mark -
#pragma mark - Share menu actions

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
    //
    //        NSDictionary *options = @{ACFacebookAppIdKey : const_apiKey_Facebook,
    //                                  ACFacebookPermissionsKey : @[@"email"]};
    //        
    //        ACAccountType *faceBookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    //        [self.accountStore requestAccessToAccountsWithType:faceBookAccountType  options:options completion:^(BOOL granted, NSError *error) {
    //            //completion handling is on indeterminate queue so I force main queue inside
    //            dispatch_async(dispatch_get_main_queue(), ^{
//            
//                    if([self facebookAvailableAccounts].count == 0){
//                        [SHKFacebook shareItem:self.shareItem];
//                    }else{
//                        
//                        if([SHKFacebookCommon socialFrameworkAvailable]){
//                            SHKiOSFacebook * iosFacebook = [[SHKiOSFacebook alloc] init];
//                            iosFacebook.quiet = YES;
//                            iosFacebook.shareDelegate = self;
//                            [iosFacebook loadItem:self.shareItem];
//                            [iosFacebook share];
//                            
//                        }else{
//                            [SHKFacebook shareItem:self.shareItem];
//                        }
//                    }
//    //            });
//    //        }];
        
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
                [SHKFacebook shareItem:self.shareItem];
            }
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
                                                 // Success
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

#pragma mark -
#pragma mark - Gestures handler
-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if ([hitView isEqual:self.view])
    {
        return nil;
    }
    else
    {
        return hitView;
    }
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

#pragma mark -
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

@end
