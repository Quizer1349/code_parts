//
//  UIViewController+backNavButton.m
//  klitch
//
//  Created by Алекс Скляр on 15.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "UIViewController+backNavButton.h"

@implementation UIViewController (backNavButton)

- (void)setUpImageBackButton
{
    UIBarButtonItem *it = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleBordered target:nil action:NULL];
    [it setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor clearColor], NSForegroundColorAttributeName , nil] forState:UIControlStateNormal];
    [it setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor clearColor], NSForegroundColorAttributeName , nil] forState:UIControlStateHighlighted];
    UIImage * btBack = [[UIImage imageNamed:@"back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    UIImage * btBackPressed = [[UIImage imageNamed:@"backPressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    [it setBackButtonBackgroundImage:btBack forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [it setBackButtonBackgroundImage:btBackPressed forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = it;
}

@end
