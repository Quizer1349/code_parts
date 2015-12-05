//
//  PGViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 12.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PGCurveLabel;
@class PGScrollIndicator;

@interface PGMainViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *transperantShadowImage;
@property (weak, nonatomic) IBOutlet UIScrollView *poseButtonsScrollView;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

//Circle Menu Wrapper
@property (weak, nonatomic) IBOutlet UIView *circleMenuView;

//Circle Buttons
@property (weak, nonatomic) IBOutlet UIButton *circleMenuButtonFavorites;
@property (weak, nonatomic) IBOutlet UIButton *circleMenuButtonRules;
@property (weak, nonatomic) IBOutlet UIButton *circleMenuButtonFullVersion;
@property (weak, nonatomic) IBOutlet UIButton *circleMenuButtonMore;

//Circle Buttons Labels
@property (weak, nonatomic) IBOutlet UILabel *curveLabelFav;
@property (weak, nonatomic) IBOutlet UILabel *curveLabelRules;
@property (weak, nonatomic) IBOutlet UILabel *curveLabelFullVer;
@property (weak, nonatomic) IBOutlet UILabel *curveLabelMore;
@property (weak, nonatomic) IBOutlet PGCurveLabel *curveLabelsView;


//Pose Buttons
@property (weak, nonatomic) IBOutlet UIButton *poseMenuButtonStanding;
@property (weak, nonatomic) IBOutlet UIButton *poseMenuButtonSitting;
@property (weak, nonatomic) IBOutlet UIButton *poseMenuButtonLying;
@property (weak, nonatomic) IBOutlet UIButton *poseMenuButtonOnKnees;
@property (weak, nonatomic) IBOutlet UIButton *poseMenuButtonPortrait;
@property (weak, nonatomic) IBOutlet UIButton *poseMenuButtonMoving;

@property (weak, nonatomic) IBOutlet PGScrollIndicator *scrollIndicator;



- (IBAction)poseStandingPressed:(id)sender;
- (IBAction)poseSittingPressed:(id)sender;
- (IBAction)poseLyingPressed:(id)sender;
- (IBAction)poseOnKneesPressed:(id)sender;
- (IBAction)posePortraitPressed:(id)sender;
- (IBAction)poseMovingPressed:(id)sender;

- (IBAction)mainButtonReleased:(id)sender;

/*Button animation*/
- (IBAction)poseButtonTouchBegan:(UIButton *)sender;

@end
