//
//  PGFavoritesViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGFavoritesViewController.h"
#import "PGPoseMenuViewController.h"
#import "Pose.h"
#import "Favorites.h"
#import "PGFavsTableCell.h"
#import "PoseImage.h"

@interface PGFavoritesViewController () <UITableViewDataSource, UITableViewDelegate, PGFavsTableCellDelegate>{

    NSMutableArray *_posesArray;
    Favorites  *_selectedItem;
    NSArray *_otherFavItems;
    BOOL _isEntrance;
}

@end

@implementation PGFavoritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Title
    self.title = [NSLocalizedString(const_title_favorites, nil) uppercaseString];
    
    //Load data
    [self setUp];
    
    //Google Analytics Params
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Favorites Screen"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    _isEntrance = YES;
    
    [[PGAppodealManager shared]checkControllerToShowAds:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(!IS_IPAD()){
        self.navigationController.navigationBarHidden = NO;
    }else{
        self.titleLabel.text = self.title;
    }
    
    //Load data
    [self setUp];
    
}

- (void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
    //ads
    if(!_isEntrance){

        [[PGAppodealManager shared]checkControllerToShowAds:self];
        _isEntrance = YES;
    }
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - Data Loading

- (void)setUp{
    
    //set up data
    //self.wrap = NO;
    //self.items = [NSMutableArray array];
    [self fetchRulesData];
    
    [self.tableView reloadData];
    if (!self.itemsDictionary.count > 0) {
        self.emptyFavsText.hidden = NO;
        self.tableView.hidden = YES;
    }else{
        self.emptyFavsText.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (void) fetchRulesData{
    
    NSError * error;
    
    self.itemsDictionary = [[NSMutableDictionary alloc] init];
    
    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:const_coreData_posesEntity];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
    
    NSArray *posesArray = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
   
    self.itemsDictionary = [NSMutableDictionary dictionary];
    _posesArray = [NSMutableArray array];
    
    for (Pose *pose in posesArray) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                        initWithEntityName:const_coreData_favsEntity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favsPose.poseTitle == %@", pose.poseTitle];
        
        [fetchRequest setPredicate:predicate];
        [fetchRequest setIncludesSubentities:YES];
        
        
        NSArray* favsArray = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (favsArray.count > 0) {
                       
            [self.itemsDictionary addEntriesFromDictionary:@{pose.poseTitle : favsArray}];
            [_posesArray addObject:pose];
        }
        
    }
}

#pragma mark -
#pragma mark - TableView methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _posesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PGFavsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PGFavsTableCell class]) forIndexPath:indexPath];
   
    if (IS_IPAD()) {
        cell.backgroundColor = [UIColor clearColor];
    }
    
    //DLog(@"self.itemsDictionary objectForKey:_posesArray[indexPath.row - %@", _posesArray[indexPath.row]);
    cell.favsArray = [self.itemsDictionary objectForKey:[_posesArray[indexPath.row] poseTitle]];
    
    NSString *poseTitle = [_posesArray[indexPath.row] poseTitle];
    NSString *mainPoseTitle = [_posesArray[indexPath.row] mainPose];
    if([poseTitle isEqualToString:mainPoseTitle]){
        cell.poseTitleLabel.text = [NSLocalizedString(poseTitle , nil) lowercaseString];
    }else{
        cell.poseTitleLabel.text = [F(@"%@ %@",NSLocalizedString(mainPoseTitle, nil), NSLocalizedString(poseTitle , nil)) lowercaseString];
    }
    cell.delegate = self;
    cell.shareMenu.baseVC = self;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (Is3_5Inches()) {
        return 170.f;
    }else if(IS_IPAD()){
        return 365.f;
    }else{
        return 205.f;
    }
}

#pragma mark -
#pragma mark - PGFavsTableCellDelegate

-(void)cellView:(PGFavsTableCell *)cellView didSelectItemAtIndex:(NSInteger)index {

    _selectedItem = cellView.favsArray[index];
    _otherFavItems = cellView.favsArray;
    [self performSegueWithIdentifier:const_segueId_favsToPoseMenu sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:const_segueId_favsToPoseMenu]) {
        if(_selectedItem){
            PGPoseMenuViewController *poseMenuVC = [segue destinationViewController];
            poseMenuVC.singleFavImage = _selectedItem;
            poseMenuVC.otherFavImages = [_otherFavItems mutableCopy];
            poseMenuVC.pose = _selectedItem.favsPose;
        }
    }
    
    _isEntrance = NO;
}

#pragma mark - Top bar actions
- (IBAction)backButtonPressed:(id)sender {

    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
