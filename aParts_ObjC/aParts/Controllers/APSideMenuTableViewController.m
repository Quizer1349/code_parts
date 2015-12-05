//
//  APSideMenuTableViewController.m
//  aParts
//
//  Created by admin on 22.04.14.
//  Copyright (c) 2014 alex. All rights reserved.
//

#import "APSideMenuTableViewController.h"
#import "SWRevealViewController.h"
#import "FXBlurView.h"
#import <QuartzCore/QuartzCore.h>


@interface APSideMenuTableViewController (){
    NSArray *menuItems;
    UIImageView *backImage;
}

@end

@implementation APSideMenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style{
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    menuItems = @[const_cellId_menuItem1, const_cellId_menuItem2, const_cellId_menuItem3,
                  const_cellId_menuItem4, const_cellId_menuItem5];
    
    //self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];

    
    backImage = [[UIImageView alloc] initWithImage:
                 [UIImage imageNamed:(NSString *)const_ui_backgrPortrate]];
    
    backImage.contentMode = UIViewContentModeScaleAspectFill;
    
    [backImage setFrame:CGRectMake(0.f, - [[UIApplication sharedApplication] statusBarFrame].size.height, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    [self.view addSubview:backImage];
    [self.view sendSubviewToBack:backImage];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.imageCircle.layer.masksToBounds = YES;
    self.imageCircle.layer.cornerRadius = self.imageCircle.frame.size.width / 2;
    
}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

#pragma mark - TableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [menuItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:57.f/255.f green:57.f/255.f blue:49.f/255.f alpha:0.6f];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
