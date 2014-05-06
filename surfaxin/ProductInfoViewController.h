/*
 * Surfaxin iOS
 *
 * Code by Charles Cheskiewicz & Nathaniel Kirby
 * OPTiMO Information Technology
 *
 */

#import <UIKit/UIKit.h>
#import "ReaderViewController.h"

@interface ProductInfoViewController : UIViewController <ReaderViewControllerDelegate>

- (IBAction)factBookTapped:(id)sender;
- (IBAction)prescribingClicked:(id)sender;

@end
