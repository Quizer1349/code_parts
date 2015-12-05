//
//  PGShareMenu.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 26.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHKItem.h"

static NSString * const PGShareMenuSendDidFinishNotification = @"PGShareMenuSendDidFinish";

@interface PGShareMenu : UIView

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIView *viewIpad;
@property (strong, nonatomic) IBOutlet UIView *minimalViewIpad;
@property (strong, nonatomic) IBOutlet UIView *minimalView;
@property (strong, nonatomic) SHKItem *shareItem;

@property (strong, nonatomic) UIViewController *baseVC;

@property (strong, nonatomic) NSArray *shareItemsArray;

@property (weak, nonatomic) IBOutlet UILabel *shareMenuLabel;

//Share buttons
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *VKButton;

//Share buttons actions
- (IBAction)mailPressed:(id)sender;
- (IBAction)instagrammPressed:(id)sender;
- (IBAction)twitterPressed:(id)sender;
- (IBAction)facebookPressed:(id)sender;
- (IBAction)vkPressed:(id)sender;


@end
