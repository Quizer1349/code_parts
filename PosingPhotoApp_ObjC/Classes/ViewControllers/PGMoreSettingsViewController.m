//
//  PGMoreSettingsViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGMoreSettingsViewController.h"
#import <MessageUI/MessageUI.h>

@interface PGMoreSettingsViewController () <MFMailComposeViewControllerDelegate> {

    MFMailComposeViewController *mailComposer;
}

@end

@implementation PGMoreSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Title
    self.title = [NSLocalizedString(const_title_more, nil) uppercaseString];
    
    //Buttons settings
    [self.rulesListButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.beachListButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.buduarListButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self locolizeLables];
    
    //Google Analytics Params
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"More Settings Screen"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(!IS_IPAD()){
        self.navigationController.navigationBarHidden = NO;
    }else{
        self.titleLabel.text = self.title;
    }
}

- (void)locolizeLables {


    self.comingSoonLabel.text = NSLocalizedString(self.comingSoonLabel.text, nil);
    self.changLangLabel.text = NSLocalizedString(self.changLangLabel.text, nil);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark -
#pragma mark - Buttons Actions

- (IBAction)backButtonPressed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeButtonPressed:(id)sender {

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)changeLangPressed:(id)sender {

}

- (IBAction)appVideoPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppPortalAddressVideo]];
}


- (IBAction)ratePressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreAddress]];
}

- (IBAction)sharePressed:(id)sender {

}

- (IBAction)feedbackPressed:(id)sender {
    
    if (![MFMailComposeViewController canSendMail]) {
        ALERT(NSLocalizedString(const_local_feedbackEmailErrorAlertTitle, nil), NSLocalizedString(const_local_feedbackEmailErrorAlertMsg, nil));
        return;
    }
    mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    
    [mailComposer setToRecipients:@[kFeedbackEmail]];
    [mailComposer setSubject:NSLocalizedString(const_local_feedbackEmailSubject, nil)];
    [mailComposer setMessageBody:NSLocalizedString(const_local_feedbackEmailBody, nil) isHTML:NO];
    
    [self presentViewController:mailComposer animated:YES completion:nil];
    
}

#pragma mark -
#pragma mark - MFMailComposeViewController delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if (result) {
        DLog(@"Result : %d",result);
    }
    if (error) {
        DLog(@"Error : %@", [error localizedDescription]);
        ALERT(NSLocalizedString(const_local_feedbackEmailErrorAlertTitle, nil), NSLocalizedString(const_local_feedbackEmailErrorAlertMsg, nil));
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
