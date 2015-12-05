//
//  PGRuleShareViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 24.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGRuleShareViewController.h"
#import "Rule.h"
#import "PGRuleView.h"
#import "PGShareMenu.h"
#import "UIImage+Resize.h"

@interface PGRuleShareViewController () <PGRuleViewDelegate, UIGestureRecognizerDelegate>{

    PGShareMenu *_shareMenu;
    UINavigationBar *_navBar;
}

@end

@implementation PGRuleShareViewController

#pragma mark -
#pragma mark - Lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _shareMenu = [[PGShareMenu alloc] init];
    _shareMenu.baseVC = self;
    
    if (IS_IPAD()) {
        _shareMenu.frame = CGRectMake(0.f, (DEVICE_HEIGHT - HEIGHT(_shareMenu)), WIDTH(_shareMenu), HEIGHT(_shareMenu));
        [_shareMenu setCenter:CGPointMake(DEVICE_WIDTH / 2, _shareMenu.center.y)];

    } else if(Is3_5Inches()){
        _shareMenu.frame = CGRectMake(0.f, (DEVICE_HEIGHT - HEIGHT(_shareMenu)) - 5.f, WIDTH(_shareMenu), HEIGHT(_shareMenu));

    }else{
        _shareMenu.frame = CGRectMake(0.f, (DEVICE_HEIGHT - HEIGHT(_shareMenu)) - 14.f, WIDTH(_shareMenu), HEIGHT(_shareMenu));
    }
    
    DLog(@"_shareMenu.frame - %@", NSStringFromCGRect(_shareMenu.frame));
    
    if (self.ruleView) {
        if(IS_IPAD()){
            [self.ruleView setFrame:CGRectMake(0.f, 35.f, DEVICE_WIDTH, DEVICE_HEIGHT - 80.f)];
        }
        
        [self.ruleView addViewToViewController:self];
        self.title = self.ruleView.titleLabel.text;
        
        _shareMenu.shareItem = [SHKItem image:[UIImage imageWithView:self.ruleView] title:self.ruleView.titleLabel.text];
    }
    
    [self.view addSubview:_shareMenu];
    
    [self fetchRulesData];
    
    [self addSwipeGesture];
    
    if(!IS_IPAD())
        [self addHomeButton];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if(IS_IPAD()){
    
        self.navigationController.navigationBarHidden = YES;
        self.titleLabel.text = self.title;
        self.titleLabel.font = [UIFont fontWithName:@"StudioScriptTT" size:42.0];
        [self.view bringSubviewToFront:self.ipadBackButton];
        [self.view bringSubviewToFront:self.ipadHomeButton];
    }else{
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                         [UIFont fontWithName:@"StudioScriptTT" size:21.0], NSFontAttributeName, nil]];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    
    if (![self presentedViewController]) {
        [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                         [UIFont fontWithName:@"TaurusLightNormal" size:21.0], NSFontAttributeName, nil]];
    }
    
    [super viewWillDisappear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Gestures
-(void) addSwipeGesture {
    
    [self addSwipeGestureRight];
    [self addSwipeGestureLeft];
}

-(void) addSwipeGestureRight {

    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRecognizer:)];
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeGestureRight.numberOfTouchesRequired = 1;
    swipeGestureRight.delegate = self;
    [self.view addGestureRecognizer:swipeGestureRight];
}

-(void) addSwipeGestureLeft {
    
    UISwipeGestureRecognizer *addSwipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRecognizer:)];
    addSwipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    addSwipeGestureLeft.numberOfTouchesRequired = 1;
    addSwipeGestureLeft.delegate = self;
    [self.view addGestureRecognizer:addSwipeGestureLeft];
}

//Method to handle event on swipe
- (void) handleSwipeRecognizer:(UISwipeGestureRecognizer *)sender {
    
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ){
        
        [self ruleView:self.ruleView loadRuleWithId:[self.ruleView.rule.ruleId intValue] + 1];
        
    }
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight ){
        
        [self ruleView:self.ruleView loadRuleWithId:[self.ruleView.rule.ruleId intValue] - 1];
    }

}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIView class]])
    {
        return YES;
    }
    return NO;
}



#pragma mark -
#pragma mark - Load Data
- (void) fetchRulesData{
    
    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:const_coreData_rulesEntity];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ruleId"
                                                                     ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.ruleItems = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

#pragma mark -
#pragma mark - PGRuleViewDelegate
-(void)ruleView:(PGRuleView *)ruleView loadRuleWithId:(int)ruleId {
    
    if (ruleId - 1 < 0) {
        [self.ruleView setRule:[self.ruleItems lastObject]];
        self.title = self.ruleView.titleLabel.text;
        
        _shareMenu.shareItem = [SHKItem image:[UIImage imageWithView:self.ruleView] title:self.ruleView.titleLabel.text];
        
        if(IS_IPAD()){
            self.titleLabel.text = self.title;
        }
        return;
    }else if (ruleId > self.ruleItems.count){
        [self.ruleView setRule:self.ruleItems[0]];
        self.title = self.ruleView.titleLabel.text;
        
        _shareMenu.shareItem = [SHKItem image:[UIImage imageWithView:self.ruleView] title:self.ruleView.titleLabel.text];
        
        if(IS_IPAD()){
            self.titleLabel.text = self.title;
        }
        return;
    }
    [self.ruleView setRule:self.ruleItems[(ruleId - 1)]];
    //[self.ruleView addViewToViewController:self];

    _shareMenu.shareItem = [SHKItem image:[UIImage imageWithView:self.ruleView] title:self.ruleView.titleLabel.text];
    
    self.title = self.ruleView.titleLabel.text;
    if(IS_IPAD()){
        self.titleLabel.text = self.title;
    }
    
    //Google Analytics Params
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:F(@"Rule #%d Screen", ruleId)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}


#pragma mark -
#pragma mark - Navigation bar items

- (void) addHomeButton {

    UIImage *homeButtonImage = [UIImage imageNamed:const_fileName_navBarHome];
    UIImage *homeButtonImagePressed = [UIImage imageNamed:const_fileName_navBarHomeHover];
    
    UIButton *buttonHome = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 35.f, 35.f)];
    [buttonHome setImage:homeButtonImage forState:UIControlStateNormal];
    [buttonHome setImage:homeButtonImagePressed forState:UIControlStateHighlighted];
    [buttonHome addTarget:self action:@selector(homePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItemHome = [[UIBarButtonItem alloc] initWithCustomView:buttonHome];
    self.navigationItem.rightBarButtonItem = barButtonItemHome;
}

-(void)homePressed:(id)sender{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
