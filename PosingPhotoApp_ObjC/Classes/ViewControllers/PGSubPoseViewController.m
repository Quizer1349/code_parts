//
//  PGSubPoseViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 26.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGSubPoseViewController.h"
#import "PGPoseMenuViewController.h"
#import "Pose.h"
#import "PGShareMenu.h"
#import <CoreText/CoreText.h>
#import "PGMainViewController.h"

@interface PGSubPoseViewController () <UIGestureRecognizerDelegate>

@end

@implementation PGSubPoseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavigationBar];
    [self configureUIElements];
    [self addSwipeGesture];
    
    if(!IS_IPAD()){
    
        UIImage *image = [UIImage imageNamed:@"header-arrow-back"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
       
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
    
    //Google Analytics Params
    Pose *currentPose = [self.subPoses firstObject];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:F(@"Subpose Screen - Pose:%@ Subpose:%@", currentPose.mainPose, currentPose.poseTitle)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(!IS_IPAD()){
        self.navigationController.navigationBarHidden = NO;
    }else{
        //Logo
//        NSString *curLangCode = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_KEY_LANGUAGE_CODE];
//        
//        if(![curLangCode isEqualToString:@"ru"]){
//            self.logoImageViewIpad.image = [UIImage imageNamed:@"logo_en"];
//        }
    }

}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark -
#pragma mark - UI configuration

-(void)configureNavigationBar {

    //NSString *curLangCode = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_KEY_LANGUAGE_CODE];
    UIImage *logoImage = [[UIImage alloc] init];
    logoImage = [UIImage imageNamed:const_fileName_headerLogo];
//    if([curLangCode isEqualToString:@"ru"]){
//        logoImage = [UIImage imageNamed:const_fileName_headerLogo];
//    }else{
//        logoImage = [UIImage imageNamed:const_fileName_headerLogoEn];
//    }
    
    
    UIImageView *logoTitle = [[UIImageView alloc] initWithImage:logoImage];
    [logoTitle setFrame:CGRectMake(X(logoTitle), Y(logoTitle), (WIDTH(logoTitle) * 0.7f), HEIGHT(logoTitle) * 0.7f)];
    logoTitle.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoTitle;
}

-(void)configureUIElements {
    
    self.pageIndicator.numberOfPages = 2;
    
    if (self.subPoses.count == 1) {
        self.nextSubPoseButton.hidden = YES;
        self.rightArrow.hidden = YES;
        self.prevSubPoseButton.hidden = NO;
        self.leftArrow.hidden = NO;
        self.pageIndicator.currentPage = 1;
        [self.prevSubPoseButton setTitle:NSLocalizedString(self.prevSubPoseButton.titleLabel.text, nil) forState:UIControlStateNormal];
        
        if ([[[self.subPoses objectAtIndex:0] mainPose] isEqualToString:@"portrait"]) {
            self.prewNextPoseLabel.text = F(@"«%@»", NSLocalizedString(self.nextPrevTitle, nil));
        }else{
            self.prewNextPoseLabel.text = F(@"«%@ %@»", [NSLocalizedString([(Pose *)[self.subPoses objectAtIndex:0] mainPose], nil) capitalizedString], NSLocalizedString(self.nextPrevTitle, nil));
        }

    }else if (self.subPoses.count > 1){
        self.nextSubPoseView.hidden = NO;
        self.rightArrow.hidden = NO;
        self.leftArrow.hidden = YES;
        self.pageIndicator.currentPage = 0;
        [self.nextSubPoseButton setTitle:NSLocalizedString(self.nextSubPoseButton.titleLabel.text, nil) forState:UIControlStateNormal];
        
        if ([[[self.subPoses objectAtIndex:0] mainPose] isEqualToString:@"portrait"]) {
            self.prewNextPoseLabel.text = F(@"«%@»", NSLocalizedString([(Pose *)[self.subPoses objectAtIndex:1] poseTitle], nil));
        }else{
            self.prewNextPoseLabel.text = F(@"«%@ %@»", [NSLocalizedString([(Pose *)[self.subPoses objectAtIndex:1] mainPose], nil) capitalizedString], NSLocalizedString([(Pose *)[self.subPoses objectAtIndex:1] poseTitle], nil));
        }
    }
    Pose *currentPose = [self.subPoses firstObject];
    
    self.subPoseImage.image = [UIImage imageNamed:currentPose.poseImage];
    self.subPoseImage.userInteractionEnabled = YES;
    
    /*Pose image tap action*/
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPoseButtonPressed:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.subPoseImage addGestureRecognizer:tapGesture];
    
    self.subPoseLabel.text = [F(@"%@", NSLocalizedString(currentPose.poseTitle, nil)) lowercaseString];
    NSArray *linesPoseLabel = [self getLinesArrayOfStringInLabel:self.subPoseLabel];
    
    if (linesPoseLabel.count > 1) {
        float heightCoef = (linesPoseLabel.count == 3) ? 2.2f : 1.6f;
        self.selectPoseButton.frame = CGRectMake(X(self.selectPoseButton), Y(self.selectPoseButton), WIDTH(self.selectPoseButton), HEIGHT(self.selectPoseButton) * heightCoef);
        self.subPoseLabel.center = self.subPoseImage.center;
        self.selectPoseButton.center = self.subPoseImage.center;
        
    }
    
    self.shareMenu.shareItem = [SHKItem image:self.subPoseImage.image title:self.subPoseLabel.text];
    self.shareMenu.baseVC = self;
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
    
        [self nextSubPoseButtonPressed:nil];
    }
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight ){
        
        [self prevSubPoseButtonPressed:nil];
    }
    
}

#pragma mark -
#pragma mark - Buttons Actions

- (IBAction)backButtonPressed:(id)sender {

    UIViewController *targetVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    if([targetVC isKindOfClass:[PGMainViewController class]]){
        if(![[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
            [Appodeal show:targetVC adType:INTERSTITIAL];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextSubPoseButtonPressed:(id)sender {

    UIStoryboard *storyboard;
    
    if(IS_IPAD()){
    
        storyboard = [UIStoryboard storyboardWithName:const_fileName_ipadStoryboard bundle: nil];
    }else{
    
        storyboard = [UIStoryboard storyboardWithName:const_fileName_iphoneStoryboard bundle: nil];
    }
    

    PGSubPoseViewController *newSubPoseVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PGSubPoseViewController class])];
   // PGSubPoseViewController *newSubPoseVC = [[PGSubPoseViewController alloc] init];
    NSMutableArray *nextPoseScreenArray = [NSMutableArray array];
    
    //Without first subPose
    for (int i = 1; i < self.subPoses.count; i++) {
        [nextPoseScreenArray addObject:self.subPoses[i]];
    }
    
    if (nextPoseScreenArray.count < 1) {
        return;
    }
    
    newSubPoseVC.subPoses = nextPoseScreenArray;
    Pose *currentPose = [self.subPoses firstObject];
    newSubPoseVC.nextPrevTitle = currentPose.poseTitle;
    [self.navigationController pushViewController:newSubPoseVC animated:YES];
}

- (IBAction)prevSubPoseButtonPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectPoseButtonPressed:(id)sender {

    [self performSegueWithIdentifier:const_segueId_subPoseToPoseMenu sender:self];
}

-(NSArray *)getLinesArrayOfStringInLabel:(UILabel *)label
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    
    CTFontRef myFont = CTFontCreateWithName(( CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CFRelease(myFont);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(( CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = ( NSArray *)CTFrameGetLines(frame);
    
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge  CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        lineString = [lineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithFloat:0.0]));
        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, lineRange, kCTKernAttributeName, (CFTypeRef)([NSNumber numberWithInt:0.0]));
        
        //NSLog(@"''''''''''''''''''%@",lineString);
        [linesArray addObject:lineString];
        
    }
    
    CGPathRelease(path);
    CFRelease( frame );
    CFRelease(frameSetter);
    
    
    return (NSArray *)linesArray;
}

#pragma mark -
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:const_segueId_subPoseToPoseMenu]) {
        PGPoseMenuViewController *poseMenuVC = [segue destinationViewController];
        poseMenuVC.pose = [self.subPoses firstObject];
    }
    
}
@end
