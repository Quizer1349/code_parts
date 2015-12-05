//
//  PGInstructionViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 01.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGInstructionViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, PGDownloadManagerDeleagte>


@property (strong, nonatomic) UIPageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UIButton *rightArrowBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowBtn;
@property (weak, nonatomic) IBOutlet UIPageControl *pageDots;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet UIView *progresView;

- (IBAction)rightArrowPressed:(id)sender;
- (IBAction)leftArrowPressed:(id)sender;
- (IBAction)skipButtonPressed:(id)sender;

@end
