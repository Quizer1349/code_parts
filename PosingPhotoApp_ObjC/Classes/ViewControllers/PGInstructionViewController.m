//
//  PGInstructionViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 01.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "PGInstructionViewController.h"
#import "PGPageConentViewController.h"
#import "PGFreeDownloadManager.h"
#import "PGPageForDowloadViewController.h"
#import "FFCircularProgressView.h"
#import "MISAlertController.h"

@interface PGInstructionViewController (){

    NSUInteger _pageCounts;
    FFCircularProgressView *_circularPV;
}

@end

@implementation PGInstructionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    _pageCounts = [self getStepsCount];
    
    self.pageDots.numberOfPages = _pageCounts;
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
     self.pageViewController.delegate = self;
    
    UIViewController *startingViewController = [self viewControllerAtIndex:0];
    [self setUIForPageAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.view sendSubviewToBack:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.skipButton.enabled = NO;
    self.skipButton.hidden = YES;
    [self.skipButton setTitle:NSLocalizedString(@"download", nil) forState:UIControlStateNormal];
    self.progresView.hidden = YES;
    
    //Google Analytics Params
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Instruction"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    
    if(!_circularPV){
        _circularPV = [[FFCircularProgressView alloc] initWithFrame:self.progresView.frame];
        [self.progresView removeFromSuperview];
        [self.view addSubview:_circularPV];
    }
    
    [_circularPV startSpinProgressBackgroundLayer];
    
}


- (IBAction)rightArrowPressed:(id)sender {

    NSUInteger index = self.pageDots.currentPage;
    
    if (index == NSNotFound) {
        return;
    }
    
   
    index++;
    if (index == _pageCounts) {
        return;
    }
    [self setUIForPageAtIndex:index];
    UIViewController *startingViewController = [self viewControllerAtIndex:index];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (IBAction)leftArrowPressed:(id)sender {

    NSUInteger index = self.pageDots.currentPage;
   
    if ((index == 0) || (index == NSNotFound)) {
        
        return;
    }

    index--;
    [self setUIForPageAtIndex:index];
    self.pageDots.currentPage = index;
    UIViewController *startingViewController = [self viewControllerAtIndex:index];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

- (IBAction)skipButtonPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
   
    if(index == 0 && _pageCounts == 6){
    
        // Create a new view controller and pass suitable data.
        PGPageForDowloadViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PGPageForDowloadViewController class])];
        pageContentViewController.titleText = NSLocalizedString(INSTRUCTION_STEPS_TITLES_ARRAY[index], nil);
        pageContentViewController.descriptionText = NSLocalizedString(INSTRUCTION_STEPS_TEXTS_ARRAY[index], nil);
        pageContentViewController.pageIndex = index;
        
        return pageContentViewController;
        
    }else{
    
        // Create a new view controller and pass suitable data.
        PGPageConentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([PGPageConentViewController class])];
        if (_pageCounts == 5) {
            index++;
        }
        pageContentViewController.imageFile = F(@"intruction_step_%ld_%@", (unsigned long)index, @"en");
        
        pageContentViewController.titleText = NSLocalizedString(INSTRUCTION_STEPS_TITLES_ARRAY[index], nil);
        pageContentViewController.descriptionText = NSLocalizedString(INSTRUCTION_STEPS_TEXTS_ARRAY[index], nil);
        pageContentViewController.pageIndex = index;
        
        return pageContentViewController;
    }
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((PGPageConentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        
       [self setUIForPageAtIndex:index];
        return nil;
    }

    [self setUIForPageAtIndex:index];
    
    index--;
 
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((PGPageConentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    [self setUIForPageAtIndex:index];

    index++;
    if (index == _pageCounts) {

        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{

    NSUInteger index = ((PGPageConentViewController*) pendingViewControllers.lastObject).pageIndex;
    
    [self setUIForPageAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{

    NSUInteger index = ((PGPageConentViewController*) previousViewControllers.lastObject).pageIndex;
    if(!completed){
        [self setUIForPageAtIndex:index];
    }
}


#pragma mark - PGDownloadManagerDelegate

-(void)downloadManagerDidStartDownload{

    self.skipButton.enabled = NO;
    [self.skipButton setTitle:NSLocalizedString(@"download", nil) forState:UIControlStateNormal];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
}

-(void)downloadManagerDidUpdateDownloadProgressTo:(CGFloat)progress{

    
    dispatch_async(dispatch_get_main_queue(), ^{
        _circularPV.hideProgressIcons = YES;
        [_circularPV setProgress:progress];
    });
}

-(void)downloadManagerDidStopDownload{

//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_circularPV stopSpinProgressBackgroundLayer];
//    });

}

-(void)downloadManagerDidStopDownloadWithErro:(NSError *)error{

    dispatch_async(dispatch_get_main_queue(), ^{
        [_circularPV stopSpinProgressBackgroundLayer];
        
        MISAlertController *alertController = [MISAlertController alertControllerWithTitle:[NSLocalizedString(const_local_feedbackEmailErrorAlertTitle, nil) capitalizedString]
                                                                                   message:NSLocalizedString(const_local_downloadError, nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        
        MISAlertAction *cancelAction = [MISAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cancelAction];
        [alertController showInViewController:self animated:YES];
    });
}


-(void)downloadManagerDidStartUnpacking{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.skipButton setTitle:NSLocalizedString(@"extraction", nil) forState:UIControlStateNormal];
    });
}

-(void)downloadManagerDidStopUnpacking{

    dispatch_async(dispatch_get_main_queue(), ^{
        [_circularPV stopSpinProgressBackgroundLayer];
        self.skipButton.enabled = YES;
        [self.skipButton setTitle:NSLocalizedString(@"start", nil) forState:UIControlStateNormal];

        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    });
}

#pragma mark - Helpers methods

- (void)setUIForPageAtIndex:(NSUInteger)index{

    if (index == _pageCounts - 1) {
        self.rightArrowBtn.hidden = YES;
        self.leftArrowBtn.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.skipButton.hidden = NO;
        }];
        
    }else if(index == 0){
        self.rightArrowBtn.hidden = NO;
        self.leftArrowBtn.hidden = YES;
    }else{
        self.rightArrowBtn.hidden = NO;
        self.leftArrowBtn.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.skipButton.hidden = YES;
        }];
    }
    
    self.pageDots.currentPage = index;
}

- (NSUInteger)getStepsCount{

    if ([PGFreeDownloadManager isFreeContentAvailable]) {
        return 5;
    }else{
        return 6;
    }
}

-(NSString *)getCurrentLocalization {
    
    NSString *localeCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSDictionary *curLangCode = [NSLocale componentsFromLocaleIdentifier:localeCode];
    
    [[NSUserDefaults standardUserDefaults] setObject:[curLangCode objectForKey:@"kCFLocaleLanguageCodeKey"] forKey:CURRENT_KEY_LANGUAGE_CODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return [curLangCode objectForKey:@"kCFLocaleLanguageCodeKey"];
}


@end
