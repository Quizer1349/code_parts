//
//  PGNavigationController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 18.12.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGNavigationController.h"

@interface PGNavigationController ()

@end

@implementation PGNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:const_fileName_navBarBG] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setFrame:CGRectMake(0.f, 0.f, DEVICE_WIDTH, 44.f)];
    [self.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"TaurusLightNormal" size:21.0], NSFontAttributeName, nil]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
    
    return [[self topViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
   
    return [[self topViewController] preferredInterfaceOrientationForPresentation];
}
@end
