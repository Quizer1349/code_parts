//
//  PGFullPhotoViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 24.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGFullPhotoViewController.h"
#import "PGFullPhotoView.h"
#import "UIImage+Resize.h"

@interface PGFullPhotoViewController ()

@end

@implementation PGFullPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:const_fileName_mainBG]];
    [self.view addSubview:bgView];
    
    DLog(@"self.view.frame - %@", NSStringFromCGRect(self.view.frame));
    PGFullPhotoView *pageScrollView = [[PGFullPhotoView alloc] initWithFrame:self.view.frame];
    
    if(_imagesArray.count > 0 || _imagesDictionary.count > 0)
        [pageScrollView setScrollViewContents:(_imagesArray.count > 0) ? _imagesArray : _imagesDictionary];
    //easily setting pagecontrol pos, see PageControlPosition defination in PagedImageScrollView.h

    pageScrollView.pageControlPos = PageControlPositionCenterBottom;
    [pageScrollView scrollToPage:(self.currentPhoto - 1) animated:NO];
    
    [self.view addSubview:pageScrollView];
    
    [self configureBackButton];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

-(BOOL)shouldAutorotate{
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}


#pragma mark
#pragma mark - Back Button

- (void)configureBackButton {
    
    // Change the appearance of back button
    UIImage *backButtonImage = [UIImage imageNamed:const_fileName_navBarBack];
    UIImage *backButtonImagePressed = [UIImage imageNamed:const_fileName_navBarBackHover];
    UIButton *buttonBack;
    
    if(IS_IPAD()){
    
        buttonBack = [[UIButton alloc] initWithFrame:CGRectMake(25.f, 25.f, 75.f, 75.f)];
    }else{
        
        buttonBack = [[UIButton alloc] initWithFrame:CGRectMake(15.f, 25.f, 35.f, 35.f)];
    }
    
    [buttonBack setImage:backButtonImage forState:UIControlStateNormal];
    [buttonBack setImage:backButtonImagePressed forState:UIControlStateHighlighted];
    [buttonBack addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:buttonBack];
}

-(void)backPressed:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
