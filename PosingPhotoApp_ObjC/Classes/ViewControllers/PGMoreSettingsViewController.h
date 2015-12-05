//
//  PGMoreSettingsViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGMoreSettingsViewController : PGViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet UIButton *changeLangButton;
@property (weak, nonatomic) IBOutlet UIButton *appVideoButton;

@property (weak, nonatomic) IBOutlet UIButton *rulesListButton;
@property (weak, nonatomic) IBOutlet UIButton *beachListButton;
@property (weak, nonatomic) IBOutlet UIButton *buduarListButton;

@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UILabel *changLangLabel;

@property (weak, nonatomic) IBOutlet UILabel *comingSoonLabel;


- (IBAction)backButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;

- (IBAction)changeLangPressed:(id)sender;
- (IBAction)appVideoPressed:(id)sender;

//- (IBAction)rulesListPressed:(id)sender;
//- (IBAction)beachListPressed:(id)sender;
//- (IBAction)buduarListPressed:(id)sender;

- (IBAction)ratePressed:(id)sender;
- (IBAction)sharePressed:(id)sender;
- (IBAction)feedbackPressed:(id)sender;


@end
