//
//  PGPoseMenuViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 06.10.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGPoseMenuViewController.h"
#import "Pose.h"
//#import "PGCircleMenu.h"
#import "PGPoseScrollView.h"
#import "PoseImage.h"
#import "iCarousel.h"
#import "Favorites.h"
#import "TGCameraNavigationController.h"
#import "PGFullVersionViewController.h"
#import <CoreText/CoreText.h>
#import "UIImage+Resize.h"
@import AVFoundation;
#import "SHK.h"
#import "PGMainViewController.h"

#import "PGBuyFullPlaceholder.h"

@interface PGPoseMenuViewController (){

    BOOL _isFullScreen;
    PGBuyFullPlaceholder *_buyCenterView;
    BOOL _wasPurchased;
}

@end

@interface PGPoseMenuViewController ()<PGPoseScrollViewDelegate, UIGestureRecognizerDelegate> {
    
    PGPoseScrollView *_previewScrollView;
//    PGCircleMenu *_circleMenu;
    NSMutableArray *_currentImages;
    NSMutableArray *_dressTypesArray;
    
    NSBundle *_currentBundle;
    
    NSMutableArray *_dressButtonsArray;
    
    NSString *_posePathBeforeDresses;
    
    NSString *_currentDressType;
    
    UIImageView *_tipsView;
    CGAffineTransform	scaleTransform, rotateTransform, translateTransform, combinedTransform;
}

@end

@implementation PGPoseMenuViewController

#define DRESS_BUTTON_IMAGE @"button-%@"
#define DRESS_BUTTON_IMAGE_HOVER @"button-%@-hover"
#define DRESS_BUTTON_WIDTH_5 47.f
#define DRESS_BUTTON_WIDTH_4 47.f
#define DRESS_BUTTON_WIDTH_IPAD 75.f
#define DRESS_BUTTON_PADDING 4.f

#define FONT_SIZE_IPHONE 22.0f
#define FONT_SIZE_IPAD 32.0f

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self updateViewAndSubviews];
    
    [self addGesturesToViews];
    
    
//     _circleMenu.shareItem = [SHKItem image:self.poseImageFullscreen.image title:F(@"%@ %@", NSLocalizedString(self.pose.mainPose, nil),  NSLocalizedString(self.pose.poseTitle, nil))];
//     _circleMenu.baseVC = self;
    
    if([PoseImage isLandscapePhoto:self.poseImageFullscreen.image]){
        [self setLandscapeModeAnimated:NO];
    }
    
    _wasPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
    
    //Google Analytics Params
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:F(@"Pose Image Screen - Pose:%@ Subpose:%@", _pose.mainPose, _pose.poseTitle)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)updateViewAndSubviews{

    if(!self.singleFavImage){
        
        //Get dresses types
        [self getDressTypeForPath];
        
        //Load all pictures for first dress type
        DLog(@"dressCount = %d", [self.pose.dressCount intValue]);
        if([self.pose.dressCount intValue] > 0)
            [self getPhotoListForDressType:_dressTypesArray.firstObject];
        else
            [self getPhotoListForDressType:@""];
        
        [self addViews];
        
        self.poseImageFullscreen.image = [[_currentImages firstObject] image];
        [self loadTipForImage:[[_currentImages firstObject] fileName]];
        [_previewScrollView setCurrentIndex:0];
        
    }else if (self.singleFavImage) {
        
        self.poseImageFullscreen.image = [Favorites getImageForFavItem:self.singleFavImage];
        
        //        //Add circle menu
        //        _circleMenu = [[PGCircleMenu alloc] init];
        //
        //        /*Insert in right bottom corner*/
        //        [_circleMenu setFrame:CGRectMake(DEVICE_WIDTH - WIDTH(_circleMenu), DEVICE_HEIGHT - HEIGHT(_circleMenu), WIDTH(_circleMenu), HEIGHT(_circleMenu))];
        //        _circleMenu.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        //        [self.view addSubview:_circleMenu];
        //        _circleMenu.delegate = self;
        //
        _favButton.selected = YES;
        
        _posePathBeforeDresses = [NSString stringWithFormat:@"%@/%@/", self.pose.posePath, [self deviceType]];
        
        //Tip imageView
        _tipsView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _tipsView.backgroundColor = [UIColor clearColor];
        _tipsView.hidden = YES;
        _tipsView.autoresizingMask = AUTORESIZE_CENTER;
        _tipsView.userInteractionEnabled = NO;
        
        [self.view addSubview:_tipsView];
        
        NSString *freeContentBundlePath = [PGFreeDownloadManager freeContentBundlePath];
        _currentBundle = [NSBundle bundleWithPath:freeContentBundlePath];
        
        [self loadTipForImage:[self.singleFavImage imageName]];
        
        //self.previewMenuButton.hidden = YES;
        //
        if(IS_IPAD()){
            
            self.tipsButton.center = CGPointMake(self.tipsButton.center.x, self.tipsButton.center.y + 160.f);
            self.photoButton.center = CGPointMake(self.photoButton.center.x, self.photoButton.center.y + 160.f);
            
        }else{
            
            self.tipsButton.center = CGPointMake(self.tipsButton.center.x, self.tipsButton.center.y + 80.f);
            self.photoButton.center = CGPointMake(self.photoButton.center.x, self.photoButton.center.y + 80.f);
            
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self addObserver:self forKeyPath:@"poseImageFullscreen.image" options:NSKeyValueObservingOptionNew context:nil];

    self.navigationController.navigationBarHidden = YES;
    
    if(self.backButton.hidden){
    
        [self hideOrShowMenus];
    }
    
    if (_dressButtonsArray && _dressButtonsArray.count > 0) {
        for (UIButton *dressButton in _dressButtonsArray) {
            if(dressButton.enabled)
                dressButton.hidden = NO;
        }
    }
    
//    BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
//    if(!isPurchased){
//        if(_previewScrollView.currentIndex > _currentImages.count - 1){
//            [_previewScrollView.scrollerView scrollToItemAtIndex:_currentImages.count - 1 animated:NO];
//        }
//    }
    
    [self openPreviewScroller];
    
//    if(!_wasPurchased && _wasPurchased != [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
//        _previewScrollView = nil;
//        [self updateViewAndSubviews];
//        [self.view setNeedsDisplay];
//    }
    
}

-(void)dealloc{

    @try{
        [self removeObserver:self forKeyPath:@"poseImageFullscreen.image"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self closePreviewScroller];
    
    [self removeObserver:self forKeyPath:@"poseImageFullscreen.image"];
    
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    
    DLog(@"change - %@", change);
    
//     _circleMenu.shareItem = [SHKItem image:(UIImage *)[change objectForKey:@"new"] title:F(@"%@ %@", NSLocalizedString(self.pose.mainPose, nil),  NSLocalizedString(self.pose.poseTitle, nil))];
    
    if([PoseImage isLandscapePhoto:[change objectForKey:@"new"]]){
        [_previewScrollView.scrollerView stopAtItemBoundary];
        [self closePreviewScroller];
        [self setLandscapeModeAnimated:YES];
        [self openPreviewScroller];
    }else{
        [_previewScrollView.scrollerView stopAtItemBoundary];
        [self closePreviewScroller];
        [self setPortraitModeAnimated:YES];
        [self openPreviewScroller];
    }
    
    PoseImage *currentPoseImage = [_currentImages objectAtIndex:_previewScrollView.currentIndex];
    
    [self availableDressTypesForImageNamed:currentPoseImage.fileName];
}

- (void)setLandscapeModeAnimated:(BOOL)animated {

    if(_isLandscape){
        
        return;
    }
    
    CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
    landscapeTransform = CGAffineTransformTranslate(landscapeTransform, 0, 0);
    
    
    ///!!!
    if(animated){
        _previewScrollView.scrollerView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.6f animations:^{
            
            [self.view setTransform:landscapeTransform];
            self.view.frame = CGRectMake(0.f, 0.f, DEVICE_WIDTH, DEVICE_HEIGHT);
            
        } completion:^(BOOL finished) {
            _previewScrollView.scrollerView.scrollEnabled = YES;
        }];
    }else{
        
        [self.view setTransform:landscapeTransform];
        self.view.frame = CGRectMake(0.f, 0.f, DEVICE_WIDTH, DEVICE_HEIGHT);
    }

    

    
    if(_previewScrollView){
        CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
        landscapeTransform = CGAffineTransformTranslate(landscapeTransform, 0, 0);
        [_previewScrollView setTransform:landscapeTransform];
        _previewScrollView.frame = CGRectMake(0.f, 0.f - WIDTH(_previewScrollView), WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
        [_previewScrollView setLandscapeMode];
        _previewScrollView.isLandscape = YES;
        
    }
    
    if (_dressButtonsArray) {
        for (int i = 0; i < _dressButtonsArray.count; i++) {
            
            UIButton * button = _dressButtonsArray[i];
            float newXLeft = self.backButton.center.x + 120.f;
            float newXRight = self.favButton.center.x - 120.f;
            [button setCenter:CGPointMake(newXLeft + ((newXRight - newXLeft) / (_dressButtonsArray.count + 1)) * (i + 1), self.backButton.center.y)];
        }
    }
    
    if(IS_IPAD()){
        
        self.tipsButton.center = CGPointMake(self.tipsButton.center.x + WIDTH(_previewScrollView), self.view.frame.size.width - self.tipsButton.frame.size.height/2 - 10.f);
        self.photoButton.center = CGPointMake(self.photoButton.center.x, self.view.frame.size.width - self.photoButton.frame.size.height/2 - 10.f);
        
    }else{
        
        self.tipsButton.center = CGPointMake(self.tipsButton.center.x + WIDTH(_previewScrollView), self.view.frame.size.width - self.tipsButton.frame.size.height/2 - 10.f);
        self.photoButton.center = CGPointMake(self.photoButton.center.x, self.view.frame.size.width - self.photoButton.frame.size.height/2 - 10.f);
        
    }

    _isLandscape = YES;
}

- (void)setPortraitModeAnimated:(BOOL)animated {
    
    if(!_isLandscape){
    
        return;
    }
    
    
    CGAffineTransform portraitTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
    portraitTransform = CGAffineTransformTranslate(portraitTransform, 0, 0);
    
    
    ///!!!
    
    if(animated){
        
        _previewScrollView.scrollerView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.6f animations:^{
            
            [self.view setTransform:portraitTransform];
            self.view.frame = CGRectMake(0.f, 0.f, DEVICE_WIDTH, DEVICE_HEIGHT);
            
        } completion:^(BOOL finished) {
            _previewScrollView.scrollerView.scrollEnabled = YES;
        }];
    }else{
    
        [self.view setTransform:portraitTransform];
        self.view.frame = CGRectMake(0.f, 0.f, DEVICE_WIDTH, DEVICE_HEIGHT);
    }

    

    if(_previewScrollView){
        CGAffineTransform landscapeTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
        landscapeTransform = CGAffineTransformTranslate(landscapeTransform, 0, 0);
        [_previewScrollView setTransform:landscapeTransform];
        _previewScrollView.frame = CGRectMake(0.f, DEVICE_HEIGHT, WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
        [_previewScrollView setPortraitMode];
        _previewScrollView.isLandscape = NO;
        
    }

    if (_dressButtonsArray) {
        for (int i = 0; i < _dressButtonsArray.count; i++) {
            
            UIButton * button = _dressButtonsArray[i];
            if(Is3_5Inches())
                [button setFrame:CGRectMake(272.f, 68.f + i * DRESS_BUTTON_WIDTH_4 + i * DRESS_BUTTON_PADDING, DRESS_BUTTON_WIDTH_4, DRESS_BUTTON_WIDTH_4)];
            else if (IS_IPAD())
                [button setFrame:CGRectMake(668.f, 124.f + i * DRESS_BUTTON_WIDTH_IPAD + i * DRESS_BUTTON_PADDING, DRESS_BUTTON_WIDTH_IPAD, DRESS_BUTTON_WIDTH_IPAD)];
            else
                [button setFrame:CGRectMake(265.f, 68.f + i * DRESS_BUTTON_WIDTH_5 + i * DRESS_BUTTON_PADDING, DRESS_BUTTON_WIDTH_5, DRESS_BUTTON_WIDTH_5)];
        }
    }
    
    if(IS_IPAD()){
        
        self.tipsButton.center = CGPointMake(self.tipsButton.center.x - HEIGHT(_previewScrollView), self.view.frame.size.height - self.tipsButton.frame.size.height/2 - 10.f + - HEIGHT(_previewScrollView));
        self.photoButton.center = CGPointMake(self.photoButton.center.x, self.view.frame.size.height - self.photoButton.frame.size.height/2 - 10.f + - HEIGHT(_previewScrollView));
        
    }else{
        
        self.tipsButton.center = CGPointMake(self.tipsButton.center.x - HEIGHT(_previewScrollView), self.view.frame.size.height - self.tipsButton.frame.size.height/2 - 10.f + - HEIGHT(_previewScrollView));
        self.photoButton.center = CGPointMake(self.photoButton.center.x, self.view.frame.size.height - self.photoButton.frame.size.height/2 - 10.f + - HEIGHT(_previewScrollView));
        
    }
    
    _isLandscape = NO;

}



#pragma mark -
#pragma mark - Configure subviews

-(void)addViews{
   
    //Add and configure PGPreviewScrollView
    if(!_previewScrollView){
        _previewScrollView = [[PGPoseScrollView alloc] init];
        _previewScrollView.frame = CGRectMake(0.f, DEVICE_HEIGHT, WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
//        if(_isLandscape){
//            _previewScrollView.frame = CGRectMake(0.f, DEVICE_HEIGHT, WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
//        }else{
//            _previewScrollView.frame = CGRectMake(0.f, DEVICE_HEIGHT, WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
//        }
       // _previewScrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _previewScrollView.imagesArray = _currentImages;
        _previewScrollView.delegate = self;
        _previewScrollView.hidden = YES;
    
  
    
        [self.view addSubview:_previewScrollView];
    }
    
    //Add circle menu
//    _circleMenu = [[PGCircleMenu alloc] init];
//    
//    /*Insert in right bottom corner*/
//    [_circleMenu setFrame:CGRectMake(DEVICE_WIDTH - WIDTH(_circleMenu), DEVICE_HEIGHT - HEIGHT(_circleMenu), WIDTH(_circleMenu), HEIGHT(_circleMenu))];
//    _circleMenu.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
//    [self.view addSubview:_circleMenu];
//    _circleMenu.delegate = self;
//    
    //Is in  favorites
    if ([Favorites isAlreadyInFavsImageNamed:[[_currentImages firstObject] fileName] forPose:self.pose]) {
        _favButton.selected = YES;
    }else{
        _favButton.selected = NO;
    }
    
    
    //Tip imageView
    _tipsView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _tipsView.backgroundColor = [UIColor clearColor];
    _tipsView.hidden = YES;
    _tipsView.autoresizingMask = AUTORESIZE_CENTER;
    _tipsView.userInteractionEnabled = NO;
    
    [self.view addSubview:_tipsView];
}

- (void)addDressTypesButton{
    
    if(_dressTypesArray.count == 0){
        return;
    }
    _dressButtonsArray = [NSMutableArray array];
    
    for(int i = 0; i < _dressTypesArray.count; i++){
        
        UIButton *dressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if(Is3_5Inches())
            [dressButton setFrame:CGRectMake(270.f, 56.f + i * DRESS_BUTTON_WIDTH_4 + i * DRESS_BUTTON_PADDING, DRESS_BUTTON_WIDTH_4, DRESS_BUTTON_WIDTH_4)];
        else if (IS_IPAD())
            [dressButton setFrame:CGRectMake(668.f, 124.f + i * DRESS_BUTTON_WIDTH_IPAD + i * DRESS_BUTTON_PADDING, DRESS_BUTTON_WIDTH_IPAD, DRESS_BUTTON_WIDTH_IPAD)];
        else
            [dressButton setFrame:CGRectMake(267.f, 68.f + i * DRESS_BUTTON_WIDTH_5 + i * DRESS_BUTTON_PADDING, DRESS_BUTTON_WIDTH_5, DRESS_BUTTON_WIDTH_5)];
        
        NSString *dressButtonImageName = [_dressTypesArray[i] stringByReplacingCharactersInRange:NSRangeFromString(@"{0,2}") withString:@""];
        
        [dressButton setImage:[UIImage imageNamed:F(DRESS_BUTTON_IMAGE, dressButtonImageName)] forState:UIControlStateNormal];
        [dressButton setImage:[UIImage imageNamed:F(DRESS_BUTTON_IMAGE_HOVER,  dressButtonImageName)] forState:UIControlStateSelected];
        
        dressButton.tag = i;
        [dressButton addTarget:self action:@selector(dressButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        if(i == 0){
            dressButton.selected = YES;
        }
        
        dressButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        [_dressButtonsArray addObject:dressButton];
        
        [self.view addSubview:dressButton];
        
    }
}

#pragma mark -
#pragma mark - Add gestures
-(void)addGesturesToViews {
    [self addGesureToMainImageView];
    [self addGestureToTipView];
    [self addSwipeGesture];
}

-(void)addGestureToTipView {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipsImageTaped:)];
    tapGesture.numberOfTapsRequired = 1;
    
    [_tipsView addGestureRecognizer:tapGesture];
}

-(void)addGesureToMainImageView {

    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainImageTaped:)];
    tapGesture2.numberOfTapsRequired = 1;
    
    [self.poseImageFullscreen addGestureRecognizer:tapGesture2];
}

#pragma mark - Swipe Gestures
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
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft ){
        
        NSInteger nextIndex = _previewScrollView.currentIndex + 1;
        
        BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
        if(!isPurchased){
            if(nextIndex >= 0 && nextIndex < _currentImages.count + 1){
                [_previewScrollView.scrollerView scrollToItemAtIndex:nextIndex animated:NO];
            }
        }else{
            if(nextIndex >= 0 && nextIndex < _currentImages.count){
                [_previewScrollView.scrollerView scrollToItemAtIndex:nextIndex animated:NO];
            }
        }
        
        if(self.otherFavImages && self.otherFavImages.count > 1){
            int nextFavIndex = (int)[self.otherFavImages indexOfObject:self.singleFavImage] + 1;
            
            if(nextFavIndex >= 0 && nextFavIndex < self.otherFavImages.count){
                _singleFavImage = [self.otherFavImages objectAtIndex:nextFavIndex];
                self.poseImageFullscreen.image = [Favorites getImageForFavItem:[self.otherFavImages objectAtIndex:nextFavIndex]];
                [self loadTipForImage:_singleFavImage.imageName];
            }
        }
        
    }
    
    if ( sender.direction == UISwipeGestureRecognizerDirectionRight ){
        
        NSInteger nextIndex;
        BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
        if (isPurchased) {
            nextIndex = _previewScrollView.currentIndex - 1;
        }else{
            nextIndex = _previewScrollView.scrollerView.currentItemIndex - 1;
        }
        
        
        if(nextIndex >= 0 && nextIndex < _currentImages.count){
            [_previewScrollView.scrollerView scrollToItemAtIndex:nextIndex animated:NO];
        }
        
        if(self.otherFavImages && self.otherFavImages.count > 1){
            int nextFavIndex = (int)[self.otherFavImages indexOfObject:self.singleFavImage] - 1;
            
            if(nextFavIndex >= 0 && nextFavIndex < self.otherFavImages.count){
                _singleFavImage = [self.otherFavImages objectAtIndex:nextFavIndex];
                self.poseImageFullscreen.image = [Favorites getImageForFavItem:[self.otherFavImages objectAtIndex:nextFavIndex]];
                [self loadTipForImage:_singleFavImage.imageName];
            }
        }
    }
    
}


#pragma mark -
#pragma mark - Actions
-(void)dressButtonPressed:(UIButton *)sender {
    
    if(sender.selected){
    
        return;
    }
    
    
    for (UIButton *bottons in _dressButtonsArray) {
        bottons.selected = NO;
    }
    
    int prevIndex = (int)_previewScrollView.currentIndex;
    NSString *prevImage = [(PoseImage *)[_currentImages objectAtIndex:prevIndex] fileName];
    
    [self getPhotoListForDressType:[_dressTypesArray objectAtIndex:(int)sender.tag]];
    
    
    DLog(@"dressButtonPressed _currentImages - %d", (int)_currentImages.count);
    
    _previewScrollView.imagesArray = _currentImages;
    
    NSString *newImageName = [prevImage stringByReplacingCharactersInRange:NSRangeFromString(@"{2,1}") withString:F(@"%d", (int)sender.tag + 1)];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName == %@", newImageName];
    NSArray *filteredArray = [_currentImages filteredArrayUsingPredicate:predicate];
    int newIndexForNewName = (int)[_currentImages indexOfObject:filteredArray.lastObject];
    self.poseImageFullscreen.image = [[_currentImages objectAtIndex:newIndexForNewName] image];
    [_previewScrollView.scrollerView scrollToItemAtIndex:newIndexForNewName animated:NO];

    //Is in  favorites
    if ([Favorites isAlreadyInFavsImageNamed:[[_currentImages objectAtIndex:newIndexForNewName] fileName] forPose:self.pose]) {
        _favButton.selected = YES;
    }else{
        _favButton.selected = NO;
    }
    
    sender.selected = YES;
    
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:F(@"%@_%@_pose_action", _pose.mainPose, _pose.poseTitle)
                                                                                        action:@"button_press"
                                                                                         label:F(@"%@_dress_button", [_dressTypesArray objectAtIndex:(int)sender.tag])
                                                                                         value:nil] build]];
}

-(void)mainImageTaped:(id)gesture {
    
    [self hideOrShowMenus];
    
    if(!_tipsView.hidden){
    
        _tipsView.hidden = YES;
        _tipsView.userInteractionEnabled = NO;
    }
}

-(void)tipsImageTaped:(id)gesture {
    
    _tipsView.hidden = YES;
    _tipsView.userInteractionEnabled = NO;
    [self hideOrShowMenus];
    
    /*Google analytics*/
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:F(@"%@_%@_pose_action", _pose.mainPose, _pose.poseTitle)
                                                                                        action:@"button_press"
                                                                                         label:@"tips_hide_button"
                                                                                         value:nil] build]];
}

#pragma mark - IB Actions
- (IBAction)backButtonPressed:(id)sender {
    
    UIViewController *targetVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    if([targetVC isKindOfClass:[PGMainViewController class]]){
        if(![[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
            [Appodeal show:targetVC adType:INTERSTITIAL];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeButtonPressed:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)showPreviewScroller:(UIButton *)sender {
    
    if (!sender.selected) {
        
        [self.view bringSubviewToFront:sender];
        [self openPreviewScroller];
        sender.selected = YES;
        
    }else{
        
        [self closePreviewScroller];
        sender.selected = NO;
    }
}

- (IBAction)photoButtonPressed:(id)sender {

    __block TGCameraNavigationController *navigationController;


    //Is allow access to camera for app
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {

                [self hideOrShowMenus];

                if (_dressButtonsArray && _dressButtonsArray.count > 0) {
                    for (UIButton *dressButton in _dressButtonsArray) {
                        dressButton.hidden = YES;
                    }
                }

                if(!_currentImages && self.singleFavImage){

                    NSString *favImagePath = [Favorites getImagePathForFavItem:self.singleFavImage];
                    PoseImage * favPoseImage = [[PoseImage alloc] initWithPath:favImagePath];
                    navigationController = [TGCameraNavigationController newWithCameraDelegate:nil
                                                                                      withPose:self.pose
                                                                           andWithCurrentImage:favPoseImage];
                }else{

                    navigationController = [TGCameraNavigationController newWithCameraDelegate:nil
                                                                                      withPose:self.pose
                                                                           andWithCurrentImage:[_currentImages objectAtIndex:_previewScrollView.currentIndex]];
                }

                [self presentViewController:navigationController animated:YES completion:nil];
            } else {

                UIAlertView *notAllowedCameraAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(const_local_notAllowedCamAlertTitle, nil)
                                                                                message:NSLocalizedString(const_local_notAllowedCamAlertMsg, nil)
                                                                               delegate:nil
                                                                      cancelButtonTitle:NSLocalizedString(const_local_notAllowedCamCloseAppBtn, nil)
                                                                      otherButtonTitles:nil];
                
                [notAllowedCameraAlert show];
            }
        });
    }];
    
    /*Google analytics*/
   
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:F(@"%@_%@_pose_action", _pose.mainPose, _pose.poseTitle)
                                                          action:@"button_press"
                                                           label:@"photo_button"
                                                           value:nil] build]];
}



- (IBAction)tipsButtonPressed:(id)sender {

    if(_buyCenterView && !_buyCenterView.hidden){

        return;
    }

    if(_tipsView.hidden){

        _tipsView.hidden = NO;
        _tipsView.userInteractionEnabled = YES;
        [self hideOrShowMenus];
        
        /*Google analytics*/
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:F(@"%@_%@_pose_action", _pose.mainPose, _pose.poseTitle)
                                                                                            action:@"button_press"
                                                                                             label:@"tips_show_button"
                                                                                             value:nil] build]];
    }
}



- (IBAction)favButtonPressed:(id)sender {

    if (![sender isSelected]) {

        NSString *imageFileName = [[_currentImages objectAtIndex:_previewScrollView.currentIndex] fileName];
        [Favorites addFavoriteImage:imageFileName withPose:self.pose andDressType:_currentDressType];
        [sender setSelected:YES];
        
        /*Google analytics*/
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:F(@"%@_%@_pose_action", _pose.mainPose, _pose.poseTitle)
                                                                                            action:@"button_press"
                                                                                             label:@"favs_add_button"
                                                                                             value:nil] build]];
    }else{

        NSString *imageFileName;

        if(self.singleFavImage){
            _currentDressType = self.singleFavImage.dressType;
            imageFileName = self.singleFavImage.imageName;

            int nextFavIndex = (int)[self.otherFavImages indexOfObject:self.singleFavImage];

            [self.otherFavImages removeObject:self.singleFavImage];
            [Favorites removeFavoriteImage:imageFileName withPose:self.pose andDressType:_currentDressType];

            if(self.otherFavImages.count == 0){
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }

            if(nextFavIndex >= 0 && nextFavIndex < self.otherFavImages.count){
                _singleFavImage = [self.otherFavImages objectAtIndex:nextFavIndex];
                self.poseImageFullscreen.image = [Favorites getImageForFavItem:[self.otherFavImages objectAtIndex:nextFavIndex]];
            }else{
                _singleFavImage = [self.otherFavImages lastObject];
                self.poseImageFullscreen.image = [Favorites getImageForFavItem:[self.otherFavImages lastObject]];
            }

        }else{
            imageFileName = [[_currentImages objectAtIndex:_previewScrollView.currentIndex] fileName];
            [Favorites removeFavoriteImage:imageFileName withPose:self.pose andDressType:_currentDressType];
            [sender setSelected:NO];
        }
        
        /*Google analytics*/
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:F(@"%@_%@_pose_action", _pose.mainPose, _pose.poseTitle)
                                                                                            action:@"button_press"
                                                                                             label:@"favs_remove_button"
                                                                                             value:nil] build]];
        

    }

}

#pragma mark -
#pragma mark - Data preparation
-(NSString *)deviceType {

    NSString *deviceType;
    if(Is3_5Inches()) {
        deviceType = @"iphone4";
    }else if (IS_IPAD()){
        deviceType = @"ipad";
    }else{
        deviceType = @"iphone5";
    }
    
    return deviceType;
}

-(void)getPhotoListForDressType:(NSString *)dressType {
    
    _currentBundle = [NSBundle bundleWithPath:[PGFreeDownloadManager freeContentBundlePath]];
    
    _posePathBeforeDresses = [NSString stringWithFormat:@"%@/%@/", self.pose.posePath, [self deviceType]];
    
    NSString *imagesPath = [NSString stringWithFormat:@"%@photo/%@/", _posePathBeforeDresses, dressType];
    NSMutableArray *imagesArray = [[_currentBundle pathsForResourcesOfType:@"jpg" inDirectory:imagesPath] mutableCopy];
    imagesArray = [[imagesArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)] mutableCopy];
    
    /*Pay content*/
    if([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        directory = [directory stringByAppendingPathComponent:@"Downloads"];
        directory = [directory stringByAppendingPathComponent:F(@"%@.%@", const_fileName_payContentBundleName, @"bundle")];
        NSBundle *payBundle = [NSBundle bundleWithPath:directory];
        if(payBundle){
            _posePathBeforeDresses = [NSString stringWithFormat:@"%@/%@/", self.pose.posePath, [self deviceType]];
            
            NSString *payImagesPath = [NSString stringWithFormat:@"%@photo/%@/", _posePathBeforeDresses, dressType];
            NSMutableArray *payImagesArray = [[payBundle pathsForResourcesOfType:@"jpg" inDirectory:payImagesPath] mutableCopy];
            
            payImagesArray = [[payImagesArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)] mutableCopy];
            
            [imagesArray addObjectsFromArray:payImagesArray];
        }
    }
    
    /*End pay content*/

    _currentImages = [NSMutableArray array];
    @autoreleasepool {
        for (NSString *imagePath in imagesArray) {
            [_currentImages addObject:[[PoseImage alloc] initWithPath:imagePath]];
        }
    }
    _currentDressType = dressType;
}

-(void)getDressTypeForPath {
    
    if([self.pose.dressCount intValue] == 0){
        return;
    }

    _dressTypesArray = [NSMutableArray array];
    NSMutableArray *sortedArray = [NSMutableArray array];
    
    if(self.pose.isFree){
        
        NSString *freeContentBundlePath = [PGFreeDownloadManager freeContentBundlePath];
        
        NSString *dressFoldersPath = [NSString stringWithFormat:@"%@/%@/photo", self.pose.posePath, [self deviceType]];
        sortedArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:F(@"%@/%@", freeContentBundlePath, dressFoldersPath) error:nil] mutableCopy];
        
        for (NSString *folder in sortedArray) {
            if (![folder isEqualToString:@".DS_Store"]){
                [_dressTypesArray addObject:folder];
            }
        }
    }else{
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            NSString *directory = [paths objectAtIndex:0];
            directory = [directory stringByAppendingPathComponent:@"Downloads"];
            directory = [directory stringByAppendingPathComponent:F(@"%@.%@", const_fileName_payContentBundleName, @"bundle")];
            NSBundle *payBundle = [NSBundle bundleWithPath:directory];
            if(payBundle){
                NSString *dressFoldersPath = [NSString stringWithFormat:@"%@/%@/photo", self.pose.posePath, [self deviceType]];
                sortedArray = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:F(@"%@/%@", payBundle.bundlePath, dressFoldersPath) error:nil] mutableCopy];
                
                for (NSString *folder in sortedArray) {
                    if (![folder isEqualToString:@".DS_Store"]){
                        [_dressTypesArray addObject:folder];
                    }
                }
            }
        }
    }


    
    
    _dressTypesArray = [[_dressTypesArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)] mutableCopy];

    
    [self addDressTypesButton];
}

- (void)availableDressTypesForImageNamed:(NSString *)imageName{
    
    for (int i = 0; i < _dressTypesArray.count; i++) {
        BOOL isAvailable = NO;
        NSString *dressType =  _dressTypesArray[i];
        NSString *dressFolder =  [NSString stringWithFormat:@"%@/photo/%@/", _posePathBeforeDresses, dressType];
        
        NSString *dressNumberedImageName = [imageName stringByReplacingCharactersInRange:NSRangeFromString(@"{2,1}") withString:F(@"%d", i + 1)];
        
        
        BOOL isDir;
        
        NSString *fullPath = F(@"%@/%@/%@@2x.jpg",_currentBundle.bundlePath, dressFolder, dressNumberedImageName);
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDir];
        
        if(exists && !isDir){
            isAvailable = YES;
        }else{
            
            /*Pay content*/
            if([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
                NSString *directory = [paths objectAtIndex:0];
                directory = [directory stringByAppendingPathComponent:@"Downloads"];
                directory = [directory stringByAppendingPathComponent:F(@"%@.%@", const_fileName_payContentBundleName, @"bundle")];
                NSBundle *payBundle = [NSBundle bundleWithPath:directory];
                if(payBundle){
                    _posePathBeforeDresses = [NSString stringWithFormat:@"%@/%@/", self.pose.posePath, [self deviceType]];
                    
                    NSString *dressFolderPay = [NSString stringWithFormat:@"%@/photo/%@/", _posePathBeforeDresses, dressType];
                    
                    BOOL isDirPay;
                    NSString *fullImagePath = F(@"%@/%@/%@@2x.jpg", payBundle.bundlePath, dressFolderPay, dressNumberedImageName);
                    BOOL existsForPay = [[NSFileManager defaultManager] fileExistsAtPath:fullImagePath isDirectory:&isDirPay];
                    if(existsForPay && !isDirPay){
                        isAvailable = YES;
                    }
                }
            }
            
            /*End pay content*/
        }
        
        if (!isAvailable) {
            [[_dressButtonsArray objectAtIndex:i] setHidden:YES];
            [[_dressButtonsArray objectAtIndex:i] setEnabled:NO];
        }else{
            
            if(!_favButton.hidden)
                [[_dressButtonsArray objectAtIndex:i] setHidden:NO];
            
            [[_dressButtonsArray objectAtIndex:i] setEnabled:YES];

        }
        
        DLog(@"_dressTypesArray[i]- %@", _dressTypesArray[i]);
    }
}

#pragma mark -
#pragma mark - Scroll Preview View Methods
-(void)openPreviewScroller {

    if(!self.tipsButton.hidden)
        _previewScrollView.hidden = NO;
    
//    if(_isLandscape){
//    
//        if(_previewScrollView.imagesArray.count > 0){
//            for(int i = 0; i < _previewScrollView.imagesArray.count; i++){
//                UIView *itemView = [_previewScrollView.scrollerView itemViewAtIndex:i];
//                [itemView setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90))];
//            }
//        }
//    }
    
    DLog(@"Open _previewScrollView.frame - %@", NSStringFromCGRect(_previewScrollView.frame));
    
//    [UIView animateWithDuration:0.1f delay:0.2f options:(UIViewAnimationOptions)UIViewAnimationCurveEaseInOut
//                     animations:^{
                         
                         if(!_isLandscape){
                             
                             _previewScrollView.frame = CGRectMake(0.f, Y(_previewScrollView) - HEIGHT(_previewScrollView), WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
                             
                             //_circleMenu.center = CGPointMake(_circleMenu.center.x, _circleMenu.center.y - HEIGHT(_previewScrollView));
                         }else{
                         
                            _previewScrollView.frame = CGRectMake(X(_previewScrollView), Y(_previewScrollView) + WIDTH(_previewScrollView), WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
                              self.backButton.center = CGPointMake(self.backButton.center.x + WIDTH(_previewScrollView), self.backButton.center.y);
                         }

                     
 //                    }
//                     completion:nil];


}

- (void) closePreviewScroller {

//    [UIView animateWithDuration:0.1f delay:0.1f options:(UIViewAnimationOptions)UIViewAnimationCurveEaseIn
//                     animations:^{
                         if(!_isLandscape){

                            //_circleMenu.center = CGPointMake(_circleMenu.center.x, _circleMenu.center.y + HEIGHT(_previewScrollView));
                            _previewScrollView.frame = CGRectMake(0.f, Y(_previewScrollView) + HEIGHT(_previewScrollView), WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
                         }else{
                             
                            _previewScrollView.frame = CGRectMake(X(_previewScrollView), Y(_previewScrollView) - WIDTH(_previewScrollView), WIDTH(_previewScrollView), HEIGHT(_previewScrollView));
                            self.backButton.center = CGPointMake(self.backButton.center.x - WIDTH(_previewScrollView), self.backButton.center.y);
                         }
//                    }
//                    completion:nil];
    _previewScrollView.hidden = YES;
}

#pragma mark -
#pragma mark - PGPoseScrollViewDelegate methods
-(void)scrollView:(PGPoseScrollView *)scrollView didSecetItemAtIndex:(NSInteger)index {

    if(index >= 0 && index <= _currentImages.count){
        
//        BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
//        if(!isPurchased && index == 5){
//
////            [_previewScrollView.scrollerView scrollToItemAtIndex:4 animated:NO];
//            _previewScrollView.currentIndex = 4;
////            
//            [self loadFullVersionScreen];
//            return;
//        }
        
        UIImage *fullImage = [[_currentImages objectAtIndex:index] image];
        
        if([PoseImage isLandscapePhoto:fullImage]){
            self.poseImageFullscreen.image = [fullImage resizedImageToSize:CGSizeMake(DEVICE_HEIGHT, DEVICE_WIDTH)];
        }else{
            self.poseImageFullscreen.image = [fullImage resizedImageToSize:CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT)];
        }

//        if([PoseImage isLandscapePhoto:fullImage]){
//            self.poseImageFullscreen.image = [UIImage imageWithImage:fullImage scaledToSize:CGSizeMake(DEVICE_HEIGHT, DEVICE_WIDTH)];
//        }else{
//            self.poseImageFullscreen.image = [UIImage imageWithImage:fullImage scaledToSize:CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT)];
//        }
        
       [self loadTipForImage:[[_currentImages objectAtIndex:index] fileName]];
    }
}

-(void)scrollView:(PGPoseScrollView *)scrollView curentItemAtIndex:(NSInteger)index {
    
    if(index >= 0 && index <= _currentImages.count){
        
//        BOOL isPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey];
//        if(!isPurchased && _previewScrollView.currentIndex == 5){
//            _previewScrollView.currentIndex = 4;
//           //[_previewScrollView.scrollerView scrollToItemAtIndex:4 animated:YES];
//           //[_previewScrollView.scrollerView scrollToItemAtIndex:4 animated:YES];
//            
//            [self addBuyButtonToCenterOfView];
//            [self showCenterBuyView:YES];
//            
//            return;
//        }
        
//        if(_buyCenterView){
//            
//            [self hideCenterBuyView:YES];
//        }
        
        UIImage *fullImage = [[_currentImages objectAtIndex:index] image];

        if([PoseImage isLandscapePhoto:fullImage]){
            self.poseImageFullscreen.image = [fullImage resizedImageToSize:CGSizeMake(DEVICE_HEIGHT, DEVICE_WIDTH)];
        }else{
            self.poseImageFullscreen.image = [fullImage resizedImageToSize:CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT)];
        }
//        if([PoseImage isLandscapePhoto:fullImage]){
//
//            self.poseImageFullscreen.image = [UIImage imageWithImage:fullImage scaledToSize:CGSizeMake(DEVICE_HEIGHT, DEVICE_WIDTH)];
//        }else{
//            
//            self.poseImageFullscreen.image = [UIImage imageWithImage:fullImage scaledToSize:CGSizeMake(DEVICE_WIDTH, DEVICE_HEIGHT)];
//        }
//        
        [self loadTipForImage:[[_currentImages objectAtIndex:index] fileName]];
        
        //Is in  favorites
        if ([Favorites isAlreadyInFavsImageNamed:[[_currentImages objectAtIndex:index] fileName] forPose:self.pose]) {
            _favButton.selected = YES;
        }else{
            _favButton.selected = NO;
        }
    }
}


- (void) loadFullVersionScreen {
    
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    PGFullVersionViewController *fullVerVC = [[PGFullVersionViewController alloc] init];
    if (_isLandscape) {
        fullVerVC = [st instantiateViewControllerWithIdentifier:F(@"%@%@", NSStringFromClass([PGFullVersionViewController class]), @"Land")];
        fullVerVC.isLandscape = YES;
        [self.navigationController presentViewController:fullVerVC animated:YES completion:nil];
    }else{
        fullVerVC = [st instantiateViewControllerWithIdentifier:NSStringFromClass([PGFullVersionViewController class])];
        [self.navigationController pushViewController:fullVerVC animated:YES];
    }
}

#pragma mark -
#pragma mark - PGCircleMenuDelegate

//-(void)circleMenu:(PGCircleMenu *)circleMenu favoritesPressed:(id)sender {
//    
//    if (![sender isSelected]) {
//        
//        NSString *imageFileName = [[_currentImages objectAtIndex:_previewScrollView.currentIndex] fileName];
//        [Favorites addFavoriteImage:imageFileName withPose:self.pose andDressType:_currentDressType];
//        [sender setSelected:YES];
//    }else{
//        
//        NSString *imageFileName;
//        
//        if(self.singleFavImage){
//            _currentDressType = self.singleFavImage.dressType;
//            imageFileName = self.singleFavImage.imageName;
//            
//            int nextFavIndex = (int)[self.otherFavImages indexOfObject:self.singleFavImage];
//            
//            [self.otherFavImages removeObject:self.singleFavImage];
//            [Favorites removeFavoriteImage:imageFileName withPose:self.pose andDressType:_currentDressType];
//            
//            if(self.otherFavImages.count == 0){
//                [self.navigationController popViewControllerAnimated:YES];
//                return;
//            }
//            
//            if(nextFavIndex >= 0 && nextFavIndex < self.otherFavImages.count){
//                _singleFavImage = [self.otherFavImages objectAtIndex:nextFavIndex];
//                self.poseImageFullscreen.image = [Favorites getImageForFavItem:[self.otherFavImages objectAtIndex:nextFavIndex]];
//            }else{
//                _singleFavImage = [self.otherFavImages lastObject];
//                self.poseImageFullscreen.image = [Favorites getImageForFavItem:[self.otherFavImages lastObject]];
//            }
//            
//        }else{
//            imageFileName = [[_currentImages objectAtIndex:_previewScrollView.currentIndex] fileName];
//            [Favorites removeFavoriteImage:imageFileName withPose:self.pose andDressType:_currentDressType];
//            [sender setSelected:NO];
//        }
//        
//
//    }
//}
//
//-(void)circleMenu:(PGCircleMenu *)circleMenu photoPressed:(id)sender {
//   
//    __block TGCameraNavigationController *navigationController;
//    
//
//    //Is allow access to camera for app
//    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (granted) {
//
//                [self hideOrShowMenus];
//                
//                if (_dressButtonsArray && _dressButtonsArray.count > 0) {
//                    for (UIButton *dressButton in _dressButtonsArray) {
//                        dressButton.hidden = YES;
//                    }
//                }
//                
//                if(!_currentImages && self.singleFavImage){
//                    
//                    NSString *favImagePath = [Favorites getImagePathForFavItem:self.singleFavImage];
//                    PoseImage * favPoseImage = [[PoseImage alloc] initWithPath:favImagePath];
//                    navigationController = [TGCameraNavigationController newWithCameraDelegate:nil
//                                                                                      withPose:self.pose
//                                                                           andWithCurrentImage:favPoseImage];
//                }else{
//                    
//                    navigationController = [TGCameraNavigationController newWithCameraDelegate:nil
//                                                                                      withPose:self.pose
//                                                                           andWithCurrentImage:[_currentImages objectAtIndex:_previewScrollView.currentIndex]];
//                }
//                
//                [self presentViewController:navigationController animated:YES completion:nil];
//            } else {
//                
//                UIAlertView *notAllowedCameraAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(const_local_notAllowedCamAlertTitle, nil)
//                                                                                message:NSLocalizedString(const_local_notAllowedCamAlertMsg, nil)
//                                                                               delegate:nil
//                                                                      cancelButtonTitle:NSLocalizedString(const_local_notAllowedCamCloseAppBtn, nil)
//                                                                      otherButtonTitles:nil];
//                
//                [notAllowedCameraAlert show];
//            }
//        });
//    }];
//}
//
//-(void)circleMenu:(PGCircleMenu *)circleMenu tipsPressed:(id)sender {
//
//    if(_buyCenterView && !_buyCenterView.hidden){
//    
//        return;
//    }
//    
//    if(_tipsView.hidden){
//    
//        _tipsView.hidden = NO;
//        _tipsView.userInteractionEnabled = YES;
//        [self hideOrShowMenus];
//    }
//}

#pragma mark -
#pragma mark - Full screen methods

-(void)closeAllMenus {

    if(self.previewMenuButton.selected){
        //[self closePreviewScroller];
        //self.previewMenuButton.selected = NO;
    }
//    if([_circleMenu isMenuVisible])
//        [_circleMenu hideMenuWithAnimation:NO];
}

-(void)hideOrShowMenus {

    if (_favButton.hidden) {
        self.backButton.hidden = NO;
        self.favButton.hidden = NO;
        self.tipsButton.hidden = NO;
        self.photoButton.hidden = NO;
        
        if(!self.singleFavImage){
            
            //self.previewMenuButton.hidden = NO;
            _previewScrollView.hidden = NO;
        }

        
        for (UIButton *dressButton in _dressButtonsArray) {
            if(dressButton.enabled){
                dressButton.hidden = NO;
            }
        }
        
    }else{
        self.backButton.hidden = YES;
        self.favButton.hidden = YES;
        self.tipsButton.hidden = YES;
        self.photoButton.hidden = YES;
        //self.previewMenuButton.hidden = YES;
        _previewScrollView.hidden = YES;
        for (UIButton *dressButton in _dressButtonsArray) {
            if(dressButton.enabled){
                dressButton.hidden = YES;
            }
        }
        
        [self closeAllMenus];
    }
}


#pragma mark -
#pragma mark - Tips Data

#define TIPS_DATA_FOLDER @"tips_data"
#define FIGURE_FILENAME_MASK @"%@_%@"
#define FIGURES_ARRAY @[@"iphoneArrow1.png", @"iphoneArrow2.png", @"iphoneArrow3.png", @"iphoneCloud.png", @"iphoneArrow1R.png", @"iphoneArrow2R.png", @"iphoneArrow3R.png"]

- (void)loadTipForImage:(NSString *)poseImageName {

    NSString *tipsDataPath = [NSString stringWithFormat:@"%@/data/%@", _posePathBeforeDresses, TIPS_DATA_FOLDER];
    NSString *tipsImageFolderPath = [NSString stringWithFormat:@"%@/%@", tipsDataPath, poseImageName];
    
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:F(@"%@/%@", _currentBundle.bundlePath, tipsImageFolderPath) isDirectory:&isDir];
    NSMutableArray *figuresArray = [NSMutableArray array];
    
    if (exists && isDir) {
     
        figuresArray = [[_currentBundle pathsForResourcesOfType:@"plist" inDirectory:tipsImageFolderPath] mutableCopy];
        //figuresArray = [[figuresArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)] mutableCopy];
        
        
    }
    
    if(figuresArray.count == 0){
        /*Pay content*/
        if([[NSUserDefaults standardUserDefaults] boolForKey:const_iap_statusKey]){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
            NSString *directory = [paths objectAtIndex:0];
            directory = [directory stringByAppendingPathComponent:@"Downloads"];
            directory = [directory stringByAppendingPathComponent:F(@"%@.%@", const_fileName_payContentBundleName, @"bundle")];
            NSBundle *payBundle = [NSBundle bundleWithPath:directory];
            if(payBundle){
                
                NSMutableArray *payTipsArray = [[payBundle pathsForResourcesOfType:@"plist" inDirectory:tipsImageFolderPath] mutableCopy];
                
                if(payTipsArray.count > 0){
                    
                    //payTipsArray = [[payTipsArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)] mutableCopy];
                    
                    [figuresArray addObjectsFromArray:payTipsArray];
                }
            }
        }
        
        /*End pay content*/
    }

    if(figuresArray.count > 0){
        
        NSArray *sortedArray = [[figuresArray sortedArrayUsingSelector:@selector(localizedStandardCompare:)] mutableCopy];
        
        NSRange figureIdRange = NSMakeRange(0, 1);
        
        if (_tipsView.subviews.count > 0) {
            [_tipsView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        }
        
        
        
        for (NSString *figureDataPath in sortedArray) {
            NSString *figureDataFilename = [[figureDataPath lastPathComponent] stringByDeletingPathExtension];
            int figureId = [[figureDataFilename substringWithRange:figureIdRange] intValue];
            
            UIImageView *tipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:FIGURES_ARRAY[figureId]]];
            tipImageView = [self transforView:tipImageView byFromPlist:figureDataPath];
            
            CGPoint center = CGPointMake(_tipsView.frame.size.width/2, _tipsView.frame.size.height/2);
            
            tipImageView.center = center;//CGRectGetCenter(self.view.frame);
            tipImageView.autoresizingMask = AUTORESIZE_CENTER;
            tipImageView.autoresizesSubviews = YES;
            tipImageView.backgroundColor = [UIColor clearColor];
            
            //Add text label if cloud
            if(figureId == [FIGURES_ARRAY indexOfObject:@"iphoneCloud.png"]){
                [self addTextToCloudTip:tipImageView locatedAtPath:figureDataPath];
            }
            
            [_tipsView addSubview:tipImageView];
        }
    }
}
- (CGAffineTransform)combinedTransform {
    
    return CGAffineTransformConcat(CGAffineTransformConcat(scaleTransform, rotateTransform), translateTransform);
}

- (CGAffineTransform)transformFromDict:(NSDictionary *)dictionary {
    
    float a = [[dictionary objectForKey:@"a"] floatValue];
    float b = [[dictionary objectForKey:@"b"] floatValue];
    float c = [[dictionary objectForKey:@"c"] floatValue];
    float d = [[dictionary objectForKey:@"d"] floatValue];
    float tx = [[dictionary objectForKey:@"tx"] floatValue];
    float ty = [[dictionary objectForKey:@"ty"] floatValue];
    return CGAffineTransformMake(a, b, c, d, tx, ty);
}

- (UIImageView *)transforView:(UIImageView *)view byFromPlist:(NSString *)filepath {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:filepath];
    NSDictionary *scaleDict     = [plist objectForKey:@"scale"];
    NSDictionary *rotateDict    = [plist objectForKey:@"rotate"];
    NSDictionary *translateDict = [plist objectForKey:@"translate"];
    scaleTransform     = [self transformFromDict:scaleDict];
    rotateTransform    = [self transformFromDict:rotateDict];
    translateTransform = [self transformFromDict:translateDict];
    
    view.transform = self.combinedTransform;
    
    return  view;
}

-(void)addTextToCloudTip:(UIImageView *)cloudView locatedAtPath:(NSString *)plistPath{

    NSString *textPath = [plistPath stringByReplacingOccurrencesOfString:@"plist" withString:@"txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:textPath]) {
        
        NSMutableString *str = [[NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil] mutableCopy];
        str = [[str stringByReplacingOccurrencesOfString:@"\n" withString:@" "] mutableCopy];
        
        //DLog(@"TIPS::: Original string - %@", str);
        
        NSMutableString *trimmedStr = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
        trimmedStr = [[str stringByReplacingOccurrencesOfString:@"\n" withString:@" "] mutableCopy];
        
        //DLog(@"TIPS::: Trimmed string - %@", trimmedStr);
        
        trimmedStr = [NSLocalizedString(trimmedStr, nil) mutableCopy];

        
        //CGRect lblRect = CGRectMake(pictureView.frame.origin.x, pictureView.frame.origin.y, pictureView.frame.size.width - 34.f, pictureView.frame.size.height);
        UILabel *lbl = [[UILabel alloc] init];
        lbl.textColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.numberOfLines = 0;
        lbl.lineBreakMode = NSLineBreakByWordWrapping;
        
        
        UIFont *font;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            
            font = [UIFont fontWithName:@"StudioScriptTT" size:FONT_SIZE_IPAD];
        }else{
            
            font = [UIFont fontWithName:@"StudioScriptTT" size:FONT_SIZE_IPHONE];
        }
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setLineHeightMultiple:0.77f];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        //[paragraphStyle setFirstLineHeadIndent:20.f];
        
        //NSLog(@"Font lineHeight - %f", font.lineHeight);
        
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:trimmedStr attributes:attributes];
        
        [lbl setAttributedText:attributedString];
        
        /*Make cloud image*/
        CGRect labelRect = [lbl.text boundingRectWithSize:cloudView.frame.size
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        //            NSLog(@"current label size - %@", NSStringFromCGSize(lbl.frame.size));
        //            NSLog(@"current cloud size - %@", NSStringFromCGSize(pictureView.frame.size));
        
        lbl.frame = labelRect;
        [lbl sizeToFit];
        
        //if([[self getLinesArrayOfStringInLabel:lbl] count] > 1){
            //float newCloudWidth = cloudSize.height/pictureView.frame.size.height * pictureView.frame.size.width;
        if(WIDTH(cloudView) - WIDTH(lbl) < 30.f)
            [cloudView setFrame:CGRectMake(cloudView.frame.origin.x, cloudView.frame.origin.y, lbl.frame.size.width + font.lineHeight, cloudView.frame.size.height)];
        //}
        
        
        NSArray *linesArray = [self getLinesArrayOfStringInLabel:lbl];
        
        //DLog(@"TIPS::: Lines array - %@", linesArray);
        
        /*!!!!!!!!!*/
        if(linesArray.count > 2){
            
            NSMutableString *str1 = [NSMutableString stringWithString:linesArray[0]];
            NSMutableString *str2 = [NSMutableString stringWithString:linesArray[1]];
            NSMutableString *str3 = [NSMutableString stringWithString:linesArray[2]];
            
            //                UILabel *label1 = [[UILabel alloc] init];
            //                UILabel *label2 = [[UILabel alloc] init];
            //                UILabel *label3 = [[UILabel alloc] init];
            
            if([linesArray[0] length] > [linesArray[1] length]){
                
                str1 = [linesArray[0] mutableCopy];
                str1 = [[str1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                NSArray *arrayWords = [str1 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (arrayWords.count > 1) {
                    str2 = [linesArray[1] mutableCopy];
                    str2 = [[str2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                    str2 = [NSMutableString stringWithFormat:@"%@ %@", [arrayWords objectAtIndex:arrayWords.count - 1], str2];
                    
                    str1 = [[str1 stringByReplacingOccurrencesOfString:[arrayWords objectAtIndex:arrayWords.count - 1] withString:@""] mutableCopy];
                }
                
            }
            
            if([linesArray[2] length] > [str2 length]){
                
                str3 = [linesArray[2] mutableCopy];
                str3 = [[str3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                NSArray *arrayWords = [str3 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (arrayWords.count > 1) {
                    str2 = [linesArray[1] mutableCopy];
                    str2 = [[str2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                    str2 = [NSMutableString stringWithFormat:@"%@ %@", str2, [arrayWords objectAtIndex:0]];
                }
                
                str3 = [[str3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                str3 = [[str3 stringByReplacingOccurrencesOfString:[arrayWords objectAtIndex:0] withString:@""] mutableCopy];
            }
            
           
            /*Fixed 4 lines labels*/
            if(linesArray.count >= 4){
                
                NSMutableString *str4 = [NSMutableString stringWithString:linesArray[3]];
                
                str4 = [linesArray[3] mutableCopy];
                str4 = [[str4 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                NSArray *arrayWords = [str4 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                NSMutableString *tmp_str3 = [NSMutableString stringWithFormat:@"%@ %@", str3, [arrayWords objectAtIndex:0]];
                tmp_str3 = [[tmp_str3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                NSArray *arrayWords_tmpStr3 = [tmp_str3 componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if(tmp_str3.length >= str2.length){
                    str2 = [NSMutableString stringWithFormat:@"%@ %@", str2, [arrayWords_tmpStr3 objectAtIndex:0]];
                    str3 = [[tmp_str3 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
                    str3 = [[str3 stringByReplacingOccurrencesOfString:[arrayWords_tmpStr3 objectAtIndex:0] withString:@""] mutableCopy];
                    
                }
                
            }
            
            NSMutableString *newString = [NSMutableString stringWithFormat:@"%@\n%@\n%@", str1, str2, str3];
            
            NSAttributedString *attributedStringCuted = [[NSAttributedString alloc] initWithString:newString attributes:attributes];
            [lbl setAttributedText:attributedStringCuted];
            
            /*Make cloud image*/
            CGRect labelRectSecond = [lbl.text boundingRectWithSize:lbl.frame.size
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:attributes
                                                            context:nil];
            
            NSLog(@"current label size - %@", NSStringFromCGSize(lbl.frame.size));
            NSLog(@"current cloud size - %@", NSStringFromCGSize(cloudView.frame.size));
            
            CGSize cloudSize = CGSizeScaledToFillSize(CGSizeMake(lbl.frame.size.width, lbl.frame.size.height + 30.f), cloudView.frame.size);
            //float newCloudWidth = cloudSize.height/pictureView.frame.size.height * pictureView.frame.size.width;
            [cloudView setFrame:CGRectMake(cloudView.frame.origin.x, cloudView.frame.origin.y, cloudSize.width, cloudView.frame.size.height + font.lineHeight)];
            
            lbl.frame = labelRectSecond;
            [lbl sizeToFit];
            
            if(!IS_IPAD()){
            
                NSArray *linesArrayAfter = [self getLinesArrayOfStringInLabel:lbl];
                
                if(linesArrayAfter.count > 3){
                    lbl.frame = CGRectMake(X(lbl), Y(lbl), WIDTH(lbl) + 60.f, HEIGHT(lbl));
                    cloudView.frame = CGRectMake(X(cloudView) - 10.f, Y(cloudView) + 5.f, WIDTH(cloudView) + 55.f, HEIGHT(cloudView) - 20.f);
                    //[lbl sizeToFit];
                }
            }
        }
        
        lbl.center = CGRectGetCenter(cloudView.frame);
        //
        //            NSLog(@"after label size - %@", NSStringFromCGSize(lbl.frame.size));
        //            NSLog(@"after cloud size - %@", NSStringFromCGSize(pictureView.frame.size));
        
        [cloudView addSubview:lbl];
        
        if(!_isLandscape){
        
            if(cloudView.frame.origin.x < 0){
                
                cloudView.center = CGPointMake(cloudView.center.x - (cloudView.frame.origin.x / 2), cloudView.center.y);
            }else if ((cloudView.frame.origin.x + cloudView.frame.size.width) > DEVICE_WIDTH){
                
                cloudView.center = CGPointMake(cloudView.center.x - ((cloudView.frame.origin.x + cloudView.frame.size.width) - DEVICE_WIDTH), cloudView.center.y);
            }
        }
//        else{
//            if(cloudView.frame.origin.x < 0){
//                
//                cloudView.center = CGPointMake(cloudView.center.x - (cloudView.frame.origin.x / 2), cloudView.center.y);
//            }else if ((cloudView.frame.origin.x + cloudView.frame.size.width) > DEVICE_HEIGHT){
//                
//                cloudView.center = CGPointMake(cloudView.center.x - ((cloudView.frame.origin.x + cloudView.frame.size.width) - DEVICE_HEIGHT), cloudView.center.y);
//            }
//        
//        }
    }
}

CGSize CGSizeScaledToFillSize(CGSize size1, CGSize size2)
{
    float w, h;
    
    float k1 = size1.height / size1.width;
    float k2 = size2.height / size2.width;
    
    if (k1 > k2) {
        w = size2.width;
        h = size1.height * size2.width / size1.width;
    } else {
        w = size1.width * size2.height / size1.height;
        h = size2.height;
    }
    return CGSizeMake(w, h);
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
#pragma mark - Add Buy button in center

-(void)addBuyButtonToCenterOfView{

    if (!_buyCenterView) {

        _buyCenterView = [[PGBuyFullPlaceholder alloc] initWithFrame:CGRectZero];
        
        if(_isLandscape){
        
            [_buyCenterView setCenter:CGPointMake([self screenSizeOrientationIndependent].height + _buyCenterView.frame.size.width / 2, self.poseImageFullscreen.center.y)];
        }else{
        
            [_buyCenterView setCenter:CGPointMake([self screenSizeOrientationIndependent].width + _buyCenterView.frame.size.width / 2, self.poseImageFullscreen.center.y)];
        }
        
        [self.view addSubview:_buyCenterView];
        [self.view bringSubviewToFront:_buyCenterView];
        
        _buyCenterView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapBuyView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadFullVersionScreen)];
        [_buyCenterView addGestureRecognizer:tapBuyView];
    }
}

-(void)showCenterBuyView:(BOOL)animated{

    _buyCenterView.hidden = NO;
    
    if(!_tipsView.hidden){
        
        _tipsView.hidden = YES;
        _tipsView.userInteractionEnabled = NO;
    }
    
    if(animated){
    
        [UIView animateWithDuration:0.2f
                              delay:0.f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _buyCenterView.center = self.poseImageFullscreen.center;
                         } 
                         completion:nil];
        
    }else{
    
        _buyCenterView.center = self.poseImageFullscreen.center;
    }
}

-(void)hideCenterBuyView:(BOOL)animated{
    
    if(animated){
        [UIView animateWithDuration:0.2f
                              delay:0.f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if(_isLandscape){
                                 
                                 [_buyCenterView setCenter:CGPointMake([self screenSizeOrientationIndependent].height + _buyCenterView.frame.size.width / 2, self.poseImageFullscreen.center.y)];
                             }else{
                                 
                                 [_buyCenterView setCenter:CGPointMake([self screenSizeOrientationIndependent].width + _buyCenterView.frame.size.width / 2, self.poseImageFullscreen.center.y)];
                             }
                         }
                         completion:^(BOOL finished){
                             _buyCenterView.hidden = YES;
                         }];
        
    }else{
    
        if(_isLandscape){
            
            [_buyCenterView setCenter:CGPointMake([self screenSizeOrientationIndependent].height + _buyCenterView.frame.size.width / 2, self.poseImageFullscreen.center.y)];
        }else{
            
            [_buyCenterView setCenter:CGPointMake([self screenSizeOrientationIndependent].width + _buyCenterView.frame.size.width / 2, self.poseImageFullscreen.center.y)];
        }
        
        _buyCenterView.hidden = YES;
    }
}

#pragma mark -
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {


}

-(CGSize)screenSizeOrientationIndependent {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height));
}

@end
