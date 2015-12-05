//
//  AboutViewController.m
//  Surfaxin
//
//  Created by Charles Cheskiewicz on 8/13/12.
//  Copyright (c) 2012 OPTiMO Information Technology. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

// ===============================================================
#pragma mark - Init, etc...

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// ===============================================================
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    //self.navigationController.navigationItem.backBarButtonItem.title = nil;
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [a1 addTarget:self action:@selector(infoTapped:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:a1];

    self.navigationItem.title = @"About";
}

// ===============================================================

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.aboutTextView flashScrollIndicators];
}

// ===============================================================

- (void)viewDidUnload {
    [self setAboutTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// ===============================================================

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	else
		return YES;
}

// ===============================================================
#pragma mark - Actions

- (void)backTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
