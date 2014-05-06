/*
 * Surfaxin iOS
 *
 * Code by Charles Cheskiewicz & Nathaniel Kirby
 * OPTiMO Information Technology
 *
 */

#import "Constants.h"

#import "CallEmailViewController.h"
#import "AboutViewController.h"

// ===============================================================

@interface CallEmailViewController ()

@end

// ===============================================================

@implementation CallEmailViewController

@synthesize thePhoneNumber;
@synthesize emailAddress, emailHidden, emailButton;

// ===============================================================
#pragma mark - Init, etc...

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// ===============================================================
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (emailHidden) {
        emailButton.hidden = YES;
    }else{
        emailButton.hidden = NO;
    }

    self.navigationItem.title = @"Contact Us";
    
    self.navigationController.navigationItem.backBarButtonItem.title = nil;
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [a1 addTarget:self action:@selector(infoTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:a1];

}

// ===============================================================

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// ===============================================================

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

// ===============================================================
#pragma mark - Actions

- (void)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// ===============================================================

- (IBAction)emailToAddress:(id)sender {
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	if([MFMailComposeViewController canSendMail]) {

        controller.mailComposeDelegate = self;
        [controller setToRecipients:[NSArray arrayWithObject:self.emailAddress]];
        controller.navigationBar.tintColor = [UIColor colorWithRed: kColorSchemeRed_TintColor
                                                             green: kColorSchemeGreen_TintColor
                                                              blue: kColorSchemeBlue_TintColor
                                                             alpha: kColorSchemeAlpha_TintColor];
        
        
        [self presentModalViewController:controller animated:YES];
	} else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Send Mail"
                                                            message:@"Please set up an email address before sending an email."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

// ===============================================================

- (IBAction)callUs:(id)sender {
    
    NSString *originalPhoneNumber = thePhoneNumber;
    NSString *prefix = @"tel://";
    NSString *phoneNumber = [originalPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"/" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    phoneNumber = [prefix stringByAppendingString:phoneNumber];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        return;
    } else {
        NSString *frontText = @"You must be running on a phone that can make calls to use this feature. To make this call use another phone to call ";
        frontText = [frontText stringByAppendingString:originalPhoneNumber];
        frontText = [frontText stringByAppendingString:@"."];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"No phone calling available"
                                                        message:frontText
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert setDelegate:nil];
        [alert show];
        return;
        
    }
}

// ===============================================================

- (void)infoTapped:(id)sender {
    AboutViewController *viewController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        viewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iPad" bundle:nil];
    } else {
        viewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

// ===============================================================
#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			NSLog(@"message sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"message failed");
			break;
			
		default: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email"
															message:@"Sending Failed – Unknown Error"
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles: nil];
			[alert show];
		}
			
			break;
	}
    
    [self dismissModalViewControllerAnimated:YES];
}



@end
