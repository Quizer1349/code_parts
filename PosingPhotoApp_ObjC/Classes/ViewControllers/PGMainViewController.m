//
//  PGViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 12.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGMainViewController.h"
#import "PGCurveLabel.h"
#import "PGTextArcView.h"
#import <CoreText/CoreText.h>
#import "DKHelper.h"
#import "PGSubPoseViewController.h"
#import "PGPoseMenuViewController.h"
#import "Pose.h"
#import "PGRateAppHelper.h"
#import "PGScrollIndicator.h"
#import "PGFreeDownloadManager.h"
#import "PGInstructionViewController.h"
#import "PGFullVersionViewController.h"
#import "OBShapedButton.h"

@interface PGMainViewController () {
    
    NSArray *selectedPoses;
    BOOL _viewWasJustLoaded;
}

@end

@implementation PGMainViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self configureUIElements];
    
    [self textDrawingTool];
    
    //Google Analytics Params
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Main Screen"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    _viewWasJustLoaded = YES;
    
    
    //    PGInstructionViewController *instructionVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PGInstructionViewController class])];
    //    [self presentViewController:instructionVC animated:YES completion:nil];
    //CheckFree content and download if needed
    if(![PGFreeDownloadManager isFreeContentAvailable]){
        
        PGInstructionViewController *instructionVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PGInstructionViewController class])];
        
        [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:instructionVC animated:YES completion:^{
            PGFreeDownloadManager *freeDowbloader = [PGFreeDownloadManager shared];
            freeDowbloader.rootVC = instructionVC;
            [freeDowbloader listObjects:nil];
        }];
    }
    
    [Appodeal show:self adType:INTERSTITIAL];
    [Appodeal hide:INTERSTITIAL];
    
    [[PGAppodealManager shared] checkControllerToShowAds:self];
}

- (void)viewDidDisappear:(BOOL)animated{

    self.scrollIndicator.visible = NO;
    
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
   
    [self unlockPoseButtons];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self checkPaymentContentEnabled];
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{

    self.scrollIndicator.visible = YES;

    [super viewDidAppear:animated];
    
    //Rate App Helper
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"showRateAlertAfterTimesOpened"]){
        [PGRateAppHelper showRateAlertAfterTimesOpened:8];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showRateAlertAfterTimesOpened"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    //Show Full version screen after two days
    BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
    BOOL isNotifiedToBuy = [[NSUserDefaults standardUserDefaults] boolForKey:@"PGWasNotifiedToBuy"];
    if(!isPurchased && !isNotifiedToBuy){
    
        int days = (int)[PGRateAppHelper calculateDaysFromStart];
        
        if(days >= 1){
            PGFullVersionViewController *fullVerVC = [[PGFullVersionViewController alloc] init];
            fullVerVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PGFullVersionViewController class])];
            fullVerVC.isModal = YES;
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PGWasNotifiedToBuy"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self presentViewController:fullVerVC animated:YES completion:nil];
        }
        

        
    }
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {

    return YES;
}

-(BOOL)shouldAutorotate{

    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}

- (void)configureUIElements {
    
    //Logo
//    NSString *curLangCode = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_KEY_LANGUAGE_CODE];
//    
//    if(![curLangCode isEqualToString:@"ru"]){
//        self.logoImageView.image = [UIImage imageNamed:@"logo_en"];
//    }
    
    [self.poseButtonsScrollView setScrollEnabled:YES];
//    self.poseButtonsScrollView.canCancelContentTouches = YES;
    self.poseButtonsScrollView.exclusiveTouch = YES;
    
    float scrollHeight = 0.f;
    
    for(UIView *button in [self.poseButtonsScrollView subviews]){
        
        scrollHeight = scrollHeight + HEIGHT(button);
    }
    
    self.poseButtonsScrollView.contentSize = CGSizeMake(DEVICE_WIDTH, (scrollHeight/2 - 163.f));
    
    UIBezierPath *maskPath;
    
    if (IS_IPAD()) {

        maskPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.circleMenuView.bounds.origin.x - 20, self.circleMenuView.bounds.origin.y, self.circleMenuView.bounds.size.width + 40.f, self.circleMenuView.bounds.size.height)];
    }else{
        
        maskPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.circleMenuView.bounds.origin.x + 5, self.circleMenuView.bounds.origin.y + 10.0, self.circleMenuView.bounds.size.width - 10.0, self.circleMenuView.bounds.size.height - 15.0)];
    }

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];

    maskLayer.path = maskPath.CGPath;
    self.circleMenuView.layer.mask = maskLayer;

    //Configure images for diff devices
    if(Is4Inches()){
        
        CGFloat retina4Height = 285;
        
        self.transperantShadowImage.image = [UIImage imageNamed:RETINA4_FILENAME(const_fileName_mainScreenShadow, RETINA4_PREFIX)];
        
        [self.poseMenuButtonPortrait setFrame:CGRectMake(X(self.poseMenuButtonPortrait), Y(self.poseMenuButtonPortrait), WIDTH(self.poseMenuButtonPortrait), retina4Height)];

        [self.poseMenuButtonStanding setFrame:CGRectMake(X(self.poseMenuButtonStanding), Y(self.poseMenuButtonStanding), WIDTH(self.poseMenuButtonStanding), retina4Height)];

        
        [self.poseMenuButtonOnKnees setFrame:CGRectMake(X(self.poseMenuButtonOnKnees), Y(self.poseMenuButtonOnKnees)+ 7.0, WIDTH(self.poseMenuButtonOnKnees), retina4Height)];
       // [self.poseMenuButtonLying setCenter:CGPointMake(self.poseMenuButtonLying.center.x,self.poseMenuButtonLying.center.y + 10.0)];
  
        
        [self.poseMenuButtonSitting setFrame:CGRectMake(X(self.poseMenuButtonSitting), Y(self.poseMenuButtonSitting), WIDTH(self.poseMenuButtonSitting), retina4Height)];
        [self.poseMenuButtonSitting setCenter:CGPointMake(self.poseMenuButtonSitting.center.x,self.poseMenuButtonSitting.center.y + 7.0)];

        
        [self.poseMenuButtonLying setFrame:CGRectMake(X(self.poseMenuButtonLying), Y(self.poseMenuButtonLying), WIDTH(self.poseMenuButtonLying), retina4Height)];
        [self.poseMenuButtonLying setCenter:CGPointMake(self.poseMenuButtonLying.center.x,self.poseMenuButtonLying.center.y + 14.0)];

        
        [self.poseMenuButtonMoving setFrame:CGRectMake(X(self.poseMenuButtonMoving), Y(self.poseMenuButtonMoving), WIDTH(self.poseMenuButtonMoving), retina4Height)];
        [self.poseMenuButtonMoving setCenter:CGPointMake(self.poseMenuButtonMoving.center.x,self.poseMenuButtonMoving.center.y + 14.0)];

        float scrollHeight = 0.f;
        
        for(UIView *button in [self.poseButtonsScrollView subviews]){
            
            scrollHeight = scrollHeight + HEIGHT(button);
        }
        
        self.poseButtonsScrollView.contentSize = CGSizeMake(DEVICE_WIDTH, (scrollHeight/2 - 160.f));
    }
    
    /*Add bounces*/
    self.poseButtonsScrollView.bounces = YES;
    self.poseButtonsScrollView.delegate = self;
    
    [self addPhotoCountLabel];
}


#pragma mark
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float pullingDetectFrom = 35;
    if (scrollView.contentOffset.y < -pullingDetectFrom) {
        
        scrollView.contentOffset = CGPointMake(0.f, -pullingDetectFrom);
        
    }else if(scrollView.contentSize.height > scrollView.frame.size.height &&
             scrollView.contentSize.height-scrollView.frame.size.height-scrollView.contentOffset.y < -pullingDetectFrom){

        scrollView.contentOffset = CGPointMake(0.f, scrollView.contentSize.height - scrollView.frame.size.height + pullingDetectFrom);
    }
    
    if(IS_IPAD()){
        
        return;
    }
    
    if (scrollView.contentOffset.y < 70) {
        
        self.scrollIndicator.hidden = NO;
    }
    else if (scrollView.contentOffset.y >= 70) {
        
        self.scrollIndicator.hidden = YES;
    }
}


#pragma mark -
#pragma mark - Rounded text

- (void)textDrawingTool {
//   
//    CTFontRef fontRef =
//    CTFontCreateWithName((CFStringRef)@"Chalkduster", 36.0f, NULL); // 9-1
//    NSDictionary *attrDictionary = [NSDictionary dictionaryWithObjectsAndKeys:(id)[[UIColor blueColor] CGColor], (NSString *)(kCTForegroundColorAttributeName), (id)[[UIColor redColor] CGColor], (NSString *) kCTStrokeColorAttributeName, (id)[NSNumber numberWithFloat:-3.0], (NSString *)kCTStrokeWidthAttributeName, nil]; // 10-1
//    CFRelease(fontRef); // 11-1
//    
//    
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"ИЗБРАННОЕ" attributes:attrDictionary];

    PGTextArcView *curveLabel = [[PGTextArcView alloc] init];
    if(IS_IPAD()){
        
        curveLabel.frame  = CGRectMake(-1.f, -197.f, DEVICE_WIDTH, DEVICE_HEIGHT + 300.f);
    }else{
        
        curveLabel.frame  = CGRectMake(-1.f, 0.f, DEVICE_WIDTH, (is4InchScreen) ? DEVICE_HEIGHT : DEVICE_HEIGHT + 70);
    }

    curveLabel.userInteractionEnabled = NO;
    
    NSArray *menuArray = [NSArray array];
    NSMutableString *menuTextItems = [[NSMutableString alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]) {
        
        menuArray = CIRCLE_MENU_LABEL_ITEMS_FULL;
    }else{
        
        menuArray = CIRCLE_MENU_LABEL_ITEMS;
    }
    
    for (int i = 0; i < menuArray.count; i++) {
        if (i != menuArray.count - 1) {
            if([menuArray[i] length] > 10){
                [menuTextItems appendFormat:@"     %@      ", NSLocalizedString(menuArray[i], nil)];

            }else{
                [menuTextItems appendFormat:@"%@      ", NSLocalizedString(menuArray[i], nil)];
            }
        }else{
            [menuTextItems appendString:NSLocalizedString(menuArray[i], nil)];
        }
    }
    //curveLabel.text = @"ИЗБРАННОЕ      ПРАВИЛА        ПОЛНАЯ ВЕРСИЯ      БОЛШЕ...";
    curveLabel.text = menuTextItems;
    curveLabel.backgroundColor = [UIColor clearColor];
    curveLabel.center = CGPointMake(X(curveLabel) + WIDTH(curveLabel)/2, Y(curveLabel) - 135.f);
    DLog(@"curveLabel.center  - %@", NSStringFromCGPoint(curveLabel.center));
    
    [self.view addSubview:curveLabel];
    [self.view bringSubviewToFront:self.poseMenuButtonStanding];
    [self.view bringSubviewToFront:self.poseMenuButtonSitting];

    
}



#pragma mark -
#pragma mark - Data Loading


- (NSArray *)fetchRulesDataForPose:(NSString *)pose{
    
    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:const_coreData_posesEntity];
    
    NSPredicate *predicateMainPose = [NSPredicate predicateWithFormat:@"mainPose == %@", pose];
    [fetchRequest setPredicate:predicateMainPose];
    
    return [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

#pragma mark -
#pragma mark - Buttons Actions

- (IBAction)poseStandingPressed:(id)sender {
    
    selectedPoses = [self fetchRulesDataForPose:const_pose_standing];
    [self posePressedByButton:sender];
}

- (IBAction)poseSittingPressed:(id)sender {

    selectedPoses = [self fetchRulesDataForPose:const_pose_sitting];
    [self posePressedByButton:sender];
}

- (IBAction)poseLyingPressed:(id)sender {

    selectedPoses = [self fetchRulesDataForPose:const_pose_lying];
    [self posePressedByButton:sender];
}

- (IBAction)poseOnKneesPressed:(id)sender {

    selectedPoses = [self fetchRulesDataForPose:const_pose_knees];
    [self posePressedByButton:sender];
}

- (IBAction)posePortraitPressed:(id)sender {
    
    selectedPoses = [self fetchRulesDataForPose:const_pose_portrait];
    [self posePressedByButton:sender];

}

- (IBAction)poseMovingPressed:(id)sender {
    
    selectedPoses = [self fetchRulesDataForPose:const_pose_moving];
    [self posePressedByButton:sender];
}

/*Button animation*/
- (IBAction)poseButtonTouchBegan:(UIButton *)sender {
    
    [self lockPoseButtons];
    if(sender.selected){
        return;
    }
    
    sender.highlighted = YES;

}

- (IBAction)mainButtonReleased:(UIButton *)sender{

    [self unlockPoseButtons];

    sender.highlighted = NO;
}

/*Common button logic*/
- (void) posePressedByButton:(UIButton *)button {

    Pose *pose = [selectedPoses firstObject];
    if(pose.isFree && ![PGFreeDownloadManager isFreeContentAvailable]){
        return;
    }
    
   
    if (button.selected) {
        
        UIImage *sImage = [button backgroundImageForState:UIControlStateSelected];
        UIImage *nImage = [button backgroundImageForState:UIControlStateNormal];
        UIColor *shadowColor = [UIColor colorWithWhite:0.f alpha:0.5f];
        
        [UIView transitionWithView:button
                          duration:0.1
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [button setBackgroundImage:[self.class colorizeImage:nImage withColor:shadowColor] forState:UIControlStateSelected];
                        }
                        completion:^(BOOL finished){
                            if(finished){
                                
                                [button setBackgroundImage:sImage forState:UIControlStateSelected];
                                [self performSegueWithIdentifier:const_segueId_mainToFullVerSegue sender:self];
                            }
                        }];
        
        return;
    }
    
    UIImage *nImage = [button backgroundImageForState:UIControlStateNormal];
    UIImage *hImage = [button backgroundImageForState:UIControlStateHighlighted];
    
    [UIView transitionWithView:button
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [button setBackgroundImage:hImage forState:UIControlStateNormal];
                    }
                    completion:^(BOOL finished){
                        if(finished){
                            [UIView transitionWithView:button duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                [button setBackgroundImage:nImage forState:UIControlStateNormal];
                            } completion:^(BOOL finished) {
                                
                                if(selectedPoses.count == 1){
                                    [self performSegueWithIdentifier:const_segueId_MainToPoseMenu sender:self];
                                }else if (selectedPoses.count > 1){
                                    [self performSegueWithIdentifier:const_segueId_MainToSubPose sender:self];
                                }
                            }];
                        }
                    }];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:const_segueId_MainToSubPose]) {
        PGSubPoseViewController *subPoseVC = [segue destinationViewController];
        subPoseVC.subPoses = selectedPoses;
    }
    
    if ([segue.identifier isEqualToString:const_segueId_MainToPoseMenu]) {
        PGPoseMenuViewController *poseMenuVC = [segue destinationViewController];
        poseMenuVC.pose = [selectedPoses firstObject];
    }
    
    if([segue.identifier isEqualToString:const_segueId_mainToFullVerSegue]){
        Pose *inPose = [selectedPoses firstObject];
        PGFullVersionViewController *fullVerVC = [segue destinationViewController];
        fullVerVC.initialPose = inPose.mainPose;
    }
}

#pragma mark - Enabled Content 

-(void)checkPaymentContentEnabled{


   if([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
       
       self.poseMenuButtonLying.selected = NO;
       self.poseMenuButtonMoving.selected = NO;
       self.poseMenuButtonSitting.selected = NO;
       self.poseMenuButtonStanding.selected = NO;
       
       [self.circleMenuButtonFullVersion setImage:[UIImage imageNamed:@"top_menu_restore"] forState:UIControlStateNormal];
   }else{
   
       self.poseMenuButtonLying.selected = YES;
       self.poseMenuButtonMoving.selected = YES;
       self.poseMenuButtonSitting.selected = YES;
       self.poseMenuButtonStanding.selected = YES;
   }
    
}


#pragma mark - Buttons Managment

- (void) lockPoseButtons {
    
    self.poseMenuButtonLying.userInteractionEnabled = NO;
    self.poseMenuButtonMoving.userInteractionEnabled = NO;
    self.poseMenuButtonOnKnees.userInteractionEnabled = NO;
    self.poseMenuButtonPortrait.userInteractionEnabled = NO;
    self.poseMenuButtonSitting.userInteractionEnabled = NO;
    self.poseMenuButtonStanding.userInteractionEnabled = NO;
}

-(void) unlockPoseButtons {

    self.poseMenuButtonLying.userInteractionEnabled = YES;
    self.poseMenuButtonMoving.userInteractionEnabled = YES;
    self.poseMenuButtonOnKnees.userInteractionEnabled = YES;
    self.poseMenuButtonPortrait.userInteractionEnabled = YES;
    self.poseMenuButtonSitting.userInteractionEnabled = YES;
    self.poseMenuButtonStanding.userInteractionEnabled = YES;
}

-(void)addPhotoCountLabel{

    NSArray *buttonsArray = [NSArray arrayWithObjects:self.poseMenuButtonPortrait,
                                                      self.poseMenuButtonStanding,
                                                      self.poseMenuButtonOnKnees,
                                                      self.poseMenuButtonSitting,
                                                      self.poseMenuButtonLying,
                                                      self.poseMenuButtonMoving, nil];
    
    for (UIButton *btn in buttonsArray) {
        CGPoint titleCenter = btn.titleLabel.center;
        
        UILabel *photoCountLbl = nil;
        if(IS_IPAD()){
        
            photoCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 180.f, 56.f)];
            photoCountLbl.textColor = [UIColor colorWithRed:253.f/255.f green:3.f/255.f blue:250.f/255.f alpha:1.0f];
            photoCountLbl.font = [UIFont systemFontOfSize:28.f];
            
            if ([btn.titleLabel.text rangeOfString:@"\n"].location != NSNotFound){
                photoCountLbl.center = CGPointMake(titleCenter.x, titleCenter.y + 87.f);
            }else{
            
                photoCountLbl.center = CGPointMake(titleCenter.x, titleCenter.y + 65.f);
            }
            
        }else{
        
            photoCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 120.f, 36.f)];
            photoCountLbl.textColor = [UIColor colorWithRed:253.f/255.f green:3.f/255.f blue:250.f/255.f alpha:1.0f];
            photoCountLbl.font = [UIFont systemFontOfSize:18.f];
            
            if(Is3_5Inches())
                photoCountLbl.center = CGPointMake(titleCenter.x, 170.f);
            if(Is4Inches())
                photoCountLbl.center = CGPointMake(titleCenter.x, 200.f);
        }
        NSInteger poseNumberInMenu = [buttonsArray indexOfObject:btn];
        photoCountLbl.text = F(@"%@ %@", POSE_BUTTONS_ORDER[poseNumberInMenu], NSLocalizedString(@"photos", nil));
        photoCountLbl.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:photoCountLbl];
        
        
        
    }
}

+ (UIImage *)colorizeImage:(UIImage *)image withColor:(UIColor *)color {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -area.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, area, image.CGImage);
    
    [color set];
    CGContextFillRect(context, area);
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, area, image.CGImage);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}

@end
