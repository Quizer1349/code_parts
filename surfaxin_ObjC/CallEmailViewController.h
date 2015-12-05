/*
 * Surfaxin iOS
 *
 * Code by Charles Cheskiewicz & Nathaniel Kirby
 * OPTiMO Information Technology
 *
 */

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface CallEmailViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIButton *emailButton;
@property (nonatomic, assign) BOOL emailHidden;
@property (nonatomic, retain) NSString *thePhoneNumber;
@property (nonatomic, retain) NSString *emailAddress;

- (IBAction)emailToAddress:(id)sender;
- (IBAction)callUs:(id)sender;

@end
