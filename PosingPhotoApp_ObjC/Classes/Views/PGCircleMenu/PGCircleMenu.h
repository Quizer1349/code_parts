//
//  PGCircleMenu.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 07.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHKItem.h"

@protocol PGCircleMenuDelegate;


@interface PGCircleMenu : UIView


@property (weak) id<PGCircleMenuDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIView *viewIpad;
@property (weak, nonatomic) IBOutlet UIImageView *menuBackground;
@property (weak, nonatomic) IBOutlet UIImageView *mainButtonBackground;

@property (strong, nonatomic) UIViewController *baseVC;

@property (strong, nonatomic) SHKItem *shareItem;

/*States*/
@property BOOL isMenuVisible;
@property BOOL isShareMenuVisible;

/*Share menu wrapper*/
@property (weak, nonatomic) IBOutlet UIView *shareMenuView;
@property (weak, nonatomic) IBOutlet UIButton *mainMenuButton;
/*Buttons wrapper view*/
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *saveMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *favMenuButton;

/*Main button pressed*/
- (IBAction)mainButtonPressed:(id)sender;

/*Menu buttons*/
- (IBAction)savePressed:(id)sender;
- (IBAction)favoritesPressed:(id)sender;
- (IBAction)tipsPressed:(id)sender;
- (IBAction)photoPressed:(id)sender;

/*Share Menu buttons*/
- (IBAction)mailPressed:(id)sender;
- (IBAction)instagrammPressed:(id)sender;
- (IBAction)twitterPressed:(id)sender;
- (IBAction)facebookPressed:(id)sender;
- (IBAction)vkPressed:(id)sender;


/*Show / Hide*/
- (void)hideMenuWithAnimation:(BOOL)isAnimation;
-(void)showMenuWithAnimation:(BOOL)isAnimation;

@end



@protocol PGCircleMenuDelegate <NSObject>

@required

- (void)circleMenu:(PGCircleMenu *)circleMenu favoritesPressed:(id)sender;
- (void)circleMenu:(PGCircleMenu *)circleMenu tipsPressed:(id)sender;
- (void)circleMenu:(PGCircleMenu *)circleMenu photoPressed:(id)sender;

@optional
- (void)circleMenu:(PGCircleMenu *)circleMenu mainButtonPressed:(id)sender;


@end