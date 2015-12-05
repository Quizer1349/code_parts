//
//  APViewController.m
//  aParts
//
//  Created by admin on 09.04.14.
//  Copyright (c) 2014 alex. All rights reserved.
//

#import "APMainViewController.h"
#import "SWRevealViewController.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>

@interface APMainViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>{

    UITableView *searchTable;
    BOOL isMenuOpen;
    UIImageView *backImage;
}

@end

@implementation APMainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = NSLocalizedString((NSString *)const_locStr_MainTitle, nil);
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.menuBarItem.target = self;
    self.menuBarItem.action = @selector(revealToggle:);
    
    self.revealViewController.rearViewRevealWidth = const_ui_sideMenuWidth;
    
    backImage = [[UIImageView alloc] initWithImage:
                 [UIImage imageNamed:(NSString *)const_ui_backgrPortrate]];
    
    backImage.contentMode = UIViewContentModeScaleAspectFill;
    
    [backImage setFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
    [self.view addSubview:backImage];
    [self.view sendSubviewToBack:backImage];
    
    // Set the gesture
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.searchBarItem setAction:@selector(displaySearchBar:)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.blurVIew.tintColor = [UIColor clearColor];
    self.blurVIew.blurRadius = 15.f;
    self.blurVIew.alpha = 1.f;
}

-(void)revealToggle:(id)sender {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    [self.revealViewController revealToggle:sender];

    if (isMenuOpen) {
        [self.blurVIew.underlyingView setCenter:CGPointMake(_blurVIew.center.x, _blurVIew.center.y)];
        isMenuOpen = NO;
    }else{
        [self.blurVIew.underlyingView setCenter:CGPointMake(_blurVIew.center.x - 200.f, _blurVIew.center.y) ];
        isMenuOpen = YES;
    }
    
    [UIView commitAnimations];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            
            backImage.frame = CGRectMake(backImage.frame.origin.x, backImage.frame.origin.y, backImage.frame.size.height, backImage.frame.size.width);
            
            backImage.contentMode = UIViewContentModeScaleAspectFill;
            
           // self.blurVIew.frame = CGRectMake(_backImage.frame.origin.x, _backImage.frame.origin.y, _backImage.frame.size.height, _backImage.frame.size.width);
            
            break;
            
        default:
            backImage.frame = CGRectMake(backImage.frame.origin.x, backImage.frame.origin.y, backImage.frame.size.width, backImage.frame.size.height);
            backImage.contentMode = UIViewContentModeScaleAspectFill;
            break;
    }
}
#pragma mark -
#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"cell"];
    }
    
    return cell;
}


#pragma mark - 
#pragma mark - Buttons Actions
-(IBAction)displaySearchBar:(id)sender {
//
//    if (searchTable == nil) {
//        //CGRect frame = CGRectMake(0.f, -44.f, self.view.frame.size.width, self.view.frame.size.height - 120.f);
//        
//        searchTable = [[UITableView alloc] init];
//        searchTable.delegate = self;
//        searchTable.dataSource = self;
//        searchTable.backgroundView = nil;
//        
//        searchTable.tableHeaderView = self.searchFieldBar;
//    }
//    
//    [self.view addSubview:searchTable];
    
    [self.searchFieldBar becomeFirstResponder];
}

#pragma mark -
#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;
    [self.searchFieldBar resignFirstResponder];
    if(searchTable != nil){
        [searchTable removeFromSuperview];
    }
}
@end
