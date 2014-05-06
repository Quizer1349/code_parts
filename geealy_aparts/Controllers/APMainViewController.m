//
//  APViewController.m
//  aParts
//
//  Created by admin on 09.04.14.
//  Copyright (c) 2014 alex. All rights reserved.
//

#import "APMainViewController.h"
#import "SWRevealViewController.h"

@interface APMainViewController ()

@end

@implementation APMainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"ГЛАВНАЯ";
    
    // Change button color
    //self.menuBarItem.tintColor = [UIColor colorWithWhite:0.1f alpha:0.9f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.menuBarItem.target = self.revealViewController;
    self.menuBarItem.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}

#pragma mark - 
#pragma mark - Buttons Actions

@end
