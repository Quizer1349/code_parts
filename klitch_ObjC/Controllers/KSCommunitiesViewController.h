//
//  KSCommunities	ViewController.h
//  klitch
//
//  Created by Алекс Скляр on 15.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSCustomViewController.h"

@interface KSCommunitiesViewController : KSCustomViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *commTableView;
@property (strong, nonatomic) NSArray * communities;

@end
