//
//  PGSubPoseViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 26.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PGShareMenu;
@class Pose;

@interface PGSubPoseViewController : PGViewController

@property (weak, nonatomic) IBOutlet UIImageView *subPoseImage;
@property (weak, nonatomic) IBOutlet UIImageView *pinkTitleLayer;
@property (weak, nonatomic) IBOutlet UILabel *subPoseLabel;
@property (weak, nonatomic) IBOutlet UIView *nextSubPoseView;
@property (weak, nonatomic) IBOutlet PGShareMenu *shareMenu;
@property (weak, nonatomic) IBOutlet UIButton *nextSubPoseButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;
@property (weak, nonatomic) IBOutlet UIButton *prevSubPoseButton;
@property (weak, nonatomic) IBOutlet UIImageView *leftArrow;
@property (weak, nonatomic) IBOutlet UIButton *selectPoseButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (weak, nonatomic) IBOutlet UILabel *prewNextPoseLabel;
@property (strong, nonatomic) NSString *nextPrevTitle;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageViewIpad;

@property (strong, nonatomic) NSArray *subPoses;
@property (strong, nonatomic) NSString *imageName;


- (IBAction)backButtonPressed:(id)sender;

- (IBAction)nextSubPoseButtonPressed:(id)sender;
- (IBAction)prevSubPoseButtonPressed:(id)sender;
- (IBAction)selectPoseButtonPressed:(id)sender;

@end
