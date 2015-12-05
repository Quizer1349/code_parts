//
//  PGRuleShareViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 24.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PGRuleView;
@class PGShareMenu;


@interface PGRuleShareViewController : PGViewController


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) PGRuleView *ruleView;
@property (nonatomic, strong) NSArray *ruleItems;
@property (nonatomic, strong) PGShareMenu *shareMenu;

@property (weak, nonatomic) IBOutlet UIButton *ipadBackButton;
@property (weak, nonatomic) IBOutlet UIButton *ipadHomeButton;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)homeButtonPressed:(id)sender;

@end
