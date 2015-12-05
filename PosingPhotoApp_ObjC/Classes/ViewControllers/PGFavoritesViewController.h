//
//  PGFavoritesViewController.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGFavoritesViewController : PGViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emtyFavsLabel;

@property (strong, nonatomic) NSMutableDictionary *itemsDictionary;

@property (weak, nonatomic) IBOutlet UIView *emptyFavsText;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)backButtonPressed:(id)sender;

@end
