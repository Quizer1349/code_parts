/*
 * Surfaxin iOS
 *
 * Code by Charles Cheskiewicz & Nathaniel Kirby
 * OPTiMO Information Technology
 *
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#import "ReaderViewController.h"

@interface HomeViewController : UIViewController <ReaderViewControllerDelegate> {
    MPMoviePlayerViewController         *moviePlayerController;
}
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *productInformationButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *administrationButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *monographButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *dosingButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cradleButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *contactButton;

- (IBAction)productInfoTapped:(id)sender;
- (IBAction)administrationTapped:(id)sender;
- (IBAction)monographTapped:(id)sender;
- (IBAction)dosingTapped:(id)sender;
- (IBAction)warmingCradleTapped:(id)sender;
- (IBAction)contactTapped:(id)sender;

@end
