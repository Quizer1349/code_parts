//
//  PGRuleView.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 23.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Rule;
@protocol PGRuleViewDelegate;

@interface PGRuleView : UIView

@property (nonatomic, strong) Rule *rule;

@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UIView *bgImageView;

@property (weak, nonatomic) IBOutlet UIView *titleBarView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *ruleTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *ruleDescription;

@property (weak, nonatomic) IBOutlet UIView *descrView;

@property (weak, nonatomic) IBOutlet UIView *portraitPhotoWrapper;
@property (weak, nonatomic) IBOutlet UIView *landscapePhotoWrapper;

@property (weak, nonatomic) IBOutlet UIImageView *portraitLeftBG;
@property (weak, nonatomic) IBOutlet UIImageView *portraitRightBG;
@property (weak, nonatomic) IBOutlet UIImageView *landTopBG;
@property (weak, nonatomic) IBOutlet UIImageView *landBottomBG;

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;

@property (weak) UIViewController <PGRuleViewDelegate> *delegate;

@property (weak, nonatomic) IBOutlet UIButton *leftNavArrow;
@property (weak, nonatomic) IBOutlet UIButton *rightNavArrow;

-(void)addViewToViewController:(UIViewController *)viewController;

- (IBAction)leftArrowPressed:(id)sender;
- (IBAction)rightArrowPressed:(id)sender;

@end



@protocol PGRuleViewDelegate <NSObject>

@required

//- (NSInteger)numberOfViewsForHorizontalScroller:(PGRuleView *)scroller;

- (void)ruleView:(PGRuleView *)ruleView loadRuleWithId:(int)ruleId;

//- (void)horizontalScroller:(PGRuleView *)scroller clickedViewAtIndex:(int)index;

@optional

- (NSInteger)initialViewIndexForHorizontalScroller:(PGRuleView *)scroller;

@end