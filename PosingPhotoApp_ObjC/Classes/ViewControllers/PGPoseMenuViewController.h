//
//  PGPoseMenuViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 06.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGViewController.h"


@class Pose;
@class Favorites;

@interface PGPoseMenuViewController : PGViewController

@property (strong, nonatomic) Pose *pose;
@property (strong, nonatomic) Favorites *singleFavImage;
@property (strong, nonatomic) NSMutableArray   *otherFavImages;
@property (nonatomic) BOOL isLandscape;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *previewMenuButton;
@property (weak, nonatomic) IBOutlet UIImageView *poseImageFullscreen;

@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *tipsButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)showPreviewScroller:(id)sender;

//New buttons
- (IBAction)photoButtonPressed:(id)sender;
- (IBAction)tipsButtonPressed:(id)sender;
- (IBAction)favButtonPressed:(id)sender;

@end
