//
//  KSCustomViewController.m
//  klitch
//
//  Created by admin on 14.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSCustomViewController.h"
#import "UIViewController+backNavButton.h"
#import "KSMyCommsViewController.h"
#import "KSInfoViewController.h"
#import "KSCommunitiesViewController.h"
#import "KSMyOptionsViewController.h"
#import "Constants.h"

@interface KSCustomViewController() <UIGestureRecognizerDelegate>

    @property (nonatomic, strong) UIGestureRecognizer *dragGestureRecognizer;
    @property (nonatomic, assign) CGFloat dragContentStartX;
    @property (nonatomic, assign) CGFloat dragContentEndX;

@end


@implementation KSCustomViewController;

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    //Set customization for back button in nav bar
    [self setUpImageBackButton];
    
    //Set background
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_960"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    //Create GestureRecognizers for SideMenu
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragGestureRecognizerDrag:)];
    panGR.delegate = self;
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    self.dragGestureRecognizer = panGR;
    [self.view addGestureRecognizer:panGR];
    
    //Set adaptive title font size
    UILabel* titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 100, 40)];
    titleLabel.text = self.navigationItem.title;
    titleLabel.textColor = [UIColor colorWithRed:(72.0/255.0) green:(72.0/255.0) blue:(72.0/255.0) alpha:1.0f];;
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    self.navigationItem.titleView=titleLabel;
}

-(void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    if (self.sideMenu.isOpen)
        [self.sideMenu close];
}

- (void)addSideMenu{
    
    //Add button
    [self addMenuButton];
    
    if(self.sideMenu){
        return;
    }
    
    //Add Side menu view
    CGRect itemFrame = CGRectMake(0, 0, 60, 60);
    
    //All Communities button
    UIView *allCommItem = [[UIView alloc] initWithFrame:itemFrame];
    [allCommItem setMenuActionWithBlock:^{
        UIStoryboard *App = [UIStoryboard storyboardWithName:@"App" bundle:nil];
        UIViewController *CommunitiesController = (KSCommunitiesViewController *)[App instantiateViewControllerWithIdentifier:@"communitiesVC"];
        if([[self.navigationController visibleViewController] isKindOfClass:[CommunitiesController class]]){
            [self.sideMenu close];
        }else{
            [self.navigationController pushViewController:CommunitiesController animated:YES];
            [self.sideMenu close];
        }
    }];
    
    UIImageView *allCommIcon = [[UIImageView alloc] initWithFrame:itemFrame];
    [allCommIcon setImage:[UIImage imageNamed:@"icon-community"]];
    [allCommItem addSubview:allCommIcon];
    
    //My Communities button
    UIView *myCommItem = [[UIView alloc] initWithFrame:itemFrame];
    [myCommItem setMenuActionWithBlock:^{
        UIStoryboard *App = [UIStoryboard storyboardWithName:@"App" bundle:nil];
        UIViewController *MyCommsController = (KSMyCommsViewController *)[App instantiateViewControllerWithIdentifier:(NSString *)id_MyCommsVC];
        if([NSStringFromClass([[self.navigationController visibleViewController] class]) isEqualToString:NSStringFromClass([MyCommsController class])]){
            [self.sideMenu close];
        }else{
            [self.navigationController pushViewController:MyCommsController animated:YES];
            [self.sideMenu close];
        }
    }];
    
    UIImageView *myCommIcon = [[UIImageView alloc] initWithFrame:itemFrame];
    [myCommIcon setImage:[UIImage imageNamed:@"icon-profile"]];
    [myCommItem addSubview:myCommIcon];
    
    //My Options button
    UIView *optionsItem = [[UIView alloc] initWithFrame:itemFrame];
    [optionsItem setMenuActionWithBlock:^{
        UIStoryboard *App = [UIStoryboard storyboardWithName:@"App" bundle:nil];
        UIViewController *MyOptionsController = (KSMyOptionsViewController *)[App instantiateViewControllerWithIdentifier:@"myOptionsVC"];
        if([NSStringFromClass([[self.navigationController visibleViewController] class]) isEqualToString:NSStringFromClass([MyOptionsController class])]){
            [self.sideMenu close];
        }else{
            [self.navigationController pushViewController:MyOptionsController animated:YES];
            [self.sideMenu close];
        }
        
    }];
    UIImageView *optionsIcon = [[UIImageView alloc] initWithFrame:itemFrame];
    [optionsIcon setImage:[UIImage imageNamed:@"icon-options"]];
    [optionsItem addSubview:optionsIcon];
    
    //Info button
    UIView *infoItem = [[UIView alloc] initWithFrame:itemFrame];
    [infoItem setMenuActionWithBlock:^{
        UIStoryboard *App = [UIStoryboard storyboardWithName:@"App" bundle:nil];
        UIViewController *InfoController = (KSInfoViewController *)[App instantiateViewControllerWithIdentifier:@"infoVC"];
        [self.navigationController pushViewController:InfoController animated:YES];
        [self.sideMenu close];
    }];
    UIImageView *infoIcon = [[UIImageView alloc] initWithFrame:itemFrame];
    [infoIcon setImage:[UIImage imageNamed:@"icon-info"]];
    [infoItem addSubview:infoIcon];
    
    self.sideMenu = [[KSSideMenu alloc] initWithItems:@[allCommItem, myCommItem, optionsItem, infoItem]];
    [self.sideMenu setItemSpacing:10.0f];
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(menuBackgroundTap:)];
    [self.sideMenu.mainView addGestureRecognizer:singleFingerTap];
    [self.view addSubview:self.sideMenu];
}

- (void) addMenuButton{
    
    UIImage * btMenu = [UIImage imageNamed:@"menu-button"];
    UIImage * btMenuPressed = [UIImage imageNamed:@"menu-button-hover"];
    UIButton *customMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customMenuButton setFrame:CGRectMake(0.0f, 0.0f, 24.0f, 22.0f)];
    [customMenuButton setBackgroundImage:btMenu
                                forState:UIControlStateNormal];
    
    [customMenuButton setBackgroundImage:btMenuPressed
                                forState:UIControlStateHighlighted];
    [customMenuButton addTarget:self action:@selector(menuButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView: customMenuButton];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpace.width = -6;
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:menuButton, nil] animated:YES];

}

- (void)menuButtonPressed{
    
    if (self.sideMenu.isOpen)
        [self.sideMenu close];
    else
        [self.sideMenu open];
}

- (void)menuBackgroundTap:(UITapGestureRecognizer *)recognizer {
    
    if (self.sideMenu.isOpen)
        [self.sideMenu close];
}

- (void) dragGestureRecognizerDrag:(UIPanGestureRecognizer*)sender {
    
    CGPoint translation = [sender translationInView:self.view];
    CGFloat xTranslation = translation.x;
    UIGestureRecognizerState state = sender.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.dragContentStartX = xTranslation;
            break;
        case UIGestureRecognizerStateEnded:
            self.dragContentEndX = xTranslation;
            if(self.dragContentStartX > 0.0 && self.dragContentEndX > 0.0){
                if(self.dragContentStartX < self.dragContentEndX && !self.sideMenu.isOpen){
                    [self.sideMenu open];
                }
            }else if (self.dragContentStartX < 0.0 && self.dragContentStartX < 0.0){
                if (self.dragContentStartX > self.dragContentEndX && self.sideMenu.isOpen){
                    [self.sideMenu close];
                }
            }
            break;
        default:
            break;
    }
}

@end