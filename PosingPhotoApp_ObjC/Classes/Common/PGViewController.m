//
//  PGViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 17.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGViewController.h"


@interface PGViewController ()

@end

@implementation PGViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureBackButton];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
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
#pragma mark - NavBar changes

- (void)configureBackButton {
    
    // Change the appearance of back button
    UIImage *backButtonImage = [UIImage imageNamed:const_fileName_navBarBack];
    UIImage *backButtonImagePressed = [UIImage imageNamed:const_fileName_navBarBackHover];
    
    UIButton *buttonBack = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 35.f, 35.f)];
    [buttonBack setImage:backButtonImage forState:UIControlStateNormal];
    [buttonBack setImage:backButtonImagePressed forState:UIControlStateHighlighted];
    [buttonBack addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithCustomView:buttonBack];
    self.navigationItem.leftBarButtonItem = barButtonItemBack;
}

-(void)backPressed:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
