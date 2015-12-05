//
//  KSCommunities	ViewController.m
//  klitch
//
//  Created by Алекс Скляр on 15.02.14.
//  Copyright (c) 2014 seanetix. All rights reserved.
//

#import "KSCommunitiesViewController.h"
#import "KSCommViewCell.h"
#import "KSCommScreenViewController.h"
#import "KSApiClient+Communities.h"
#import "SVPullToRefresh.h"

#define PLACEHOLDER_IMAGE [UIImage imageNamed:@"placeholder.jpg"]

@interface KSCommunitiesViewController ()

@end

@implementation KSCommunitiesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //Load data
    [self refreshData];
    
    //Add side menu
    [self addSideMenu];
    
    //Pull to refresh
    [self.commTableView addPullToRefreshWithActionHandler:^{
        [self refreshData];
    } position:SVPullToRefreshPositionTop];
    [self.commTableView triggerPullToRefresh];
    
    self.commTableView.pullToRefreshView.arrowColor = [UIColor whiteColor];
    self.commTableView.pullToRefreshView.textColor = [UIColor whiteColor];
    
    //Table costomization
    self.commTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    // This will remove extra separators from tableview
    self.commTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)joinButtonPressed:(UIButton*)sender {
    
    KSCommScreenViewController *commScreenVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commScreenVC"];
    
    commScreenVC.commData = self.communities[sender.tag];
    [self.navigationController pushViewController:commScreenVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - TableView methods

-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.communities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellID = @"commCellOut";
    
    KSCommViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[KSCommViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    
    //Customize imageView
    cell.commImageView.layer.borderWidth = 2.0f;
    cell.commImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.commImageView.layer.cornerRadius = 5.0f;
    cell.commImageView.layer.masksToBounds = YES;
    
    //Set cell data
    cell.commTitleLabel.text = self.communities[indexPath.row][@"name"];
    cell.joinButton.tag = indexPath.row;
    [cell.joinButton addTarget:self action:@selector(joinButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //Load images async
    [[KSApiClient sharedClient] setImageForCommWithId:self.communities[indexPath.row][@"id"] placeholderImage:PLACEHOLDER_IMAGE forImageView:cell.commImageView];

    return cell;
}

#pragma mark -
#pragma mark - Refresh data
- (void)refreshData {
    
   [[KSApiClient sharedClient] getAllCommunitiesWithBlock:^(NSArray *response, NSError *error) {
       if(response){
           self.communities = response;
           [self.commTableView reloadData];
           [self.commTableView.pullToRefreshView stopAnimating];
       } else if (error){
           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
           [alertView show];
       }
   }];

}

@end
