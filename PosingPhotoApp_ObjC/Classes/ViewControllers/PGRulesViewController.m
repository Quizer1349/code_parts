//
//  PGRulesViewController.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 16.09.14.
//  Copyright (c) 2014 mainsoft. All rights reserved.
//

#import "PGRulesViewController.h"
#import "Rule.h"
#import "PGRuleView.h"
#import "PGRuleShareViewController.h"

@interface PGRulesViewController () {

    PGRuleView *_selectedRuleView;
    BOOL _isEntrance;
}

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) BOOL wrap;

@end

@implementation PGRulesViewController


#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
   
    //Title
    self.title = [NSLocalizedString(@"rules", nil) uppercaseString];
    
    //configure carousel
    self.carousel.type = iCarouselTypeCustom;
    self.carousel.delegate = self;
    
    //Google Analytics Params
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"Rules Slider Screen"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    _isEntrance = YES;
    
    if(_isEntrance){
        [[PGAppodealManager shared] checkControllerToShowAds:self];
        _isEntrance = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if(!IS_IPAD()){
        self.navigationController.navigationBarHidden = NO;
    }else{
        self.titleLabel.text = self.title;
    }
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    
}


-(void)dealloc{

    self.carousel = nil;
    
}

#pragma mark -
#pragma mark - Data Loading

- (void)setUp{
    
    //set up data
    self.wrap = NO;
    self.items = [NSMutableArray array];
    [self fetchRulesData];
}

- (void) fetchRulesData{
    
    PGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:const_coreData_rulesEntity];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ruleId"
                                                                     ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.items = [[appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(__unused iCarousel *)carousel {

    return (NSInteger)[self.items count];
}

- (UIView *)carousel:(__unused iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(PGRuleView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        
        if (IS_IPAD()) {
         
            view = [[PGRuleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 400.f, 560.f)];
        }else{
        
            view = [[PGRuleView alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 300.f)];
            view.ruleTitleLabel.font = [UIFont fontWithName:@"TaurusLightNormal" size:13.0f];;
        }
        
        
        [view setRule:self.items[index]];

    }else{
        [view setRule:self.items[index]];
    }
    
    view.userInteractionEnabled = NO;
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [[(Rule *)self.items[(NSUInteger)index] ruleId] stringValue];
    
    return view;
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {

    /*Simple in line scrolling*/
    CGFloat distance = 75.0f; //number of pixels to move the items away from camera
    CGFloat z = - fminf(1.0f, fabs(offset)) * distance;
    return CATransform3DTranslate(transform, offset * self.carousel.itemWidth, 0.0f, z);

    /*3 items scrolling in line*/
//    CGFloat MAX_SCALE = 1.0f; //max scale of center item
//    CGFloat MAX_SHIFT = -140.0f; //amount to shift items to keep spacing the same
//    CGFloat distance = 75.0f; //number of pixels to move the items away from camera
//    CGFloat z = - fminf(1.0f, fabs(offset)) * distance;
//
//    
//    CGFloat shift = fminf(1.0f, fmaxf(-1.0f, offset));
//    CGFloat scale = 1.0f + (1.0f - fabs(shift)) * (MAX_SCALE - 1.0f);
//    transform = CATransform3DTranslate(transform, offset * self.carousel.itemWidth * 1.08f + shift * MAX_SHIFT, 0.0f, z);
//    return CATransform3DScale(transform, scale, scale, scale);
}

- (CGFloat)carousel:(__unused iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return self.wrap;
            break;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 0.1f;
            break;
        }
        case iCarouselOptionFadeMax:
        {
            return value;
            break;
        }
        case iCarouselOptionShowBackfaces:
        {
            return NO;
            break;
        }
        case iCarouselOptionRadius:
        case iCarouselOptionAngle:
        case iCarouselOptionArc:
        case iCarouselOptionTilt:
        case iCarouselOptionCount:
        case iCarouselOptionFadeMin:
        case iCarouselOptionFadeMinAlpha:
        case iCarouselOptionFadeRange:
        case iCarouselOptionOffsetMultiplier:
        case iCarouselOptionVisibleItems:
        {
            return value;
            break;
        }

    }
}


#pragma mark iCarousel taps

- (void)carousel:(__unused iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    
    //NSNumber *item = (self.items)[(NSUInteger)index];
    _selectedRuleView = [[PGRuleView alloc] initWithFrame:CGRectZero];
    [_selectedRuleView setRule:self.items[index]];
    [self performSegueWithIdentifier:const_segueId_RulesToOneRule sender:self];
}

- (void)carouselCurrentItemIndexDidChange:(__unused iCarousel *)carousel {
    
    DLog(@"Index: %@", @(self.carousel.currentItemIndex));
}

#pragma mark -
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:const_segueId_RulesToOneRule]){
        PGRuleShareViewController *ruleShareVC = segue.destinationViewController;
        ruleShareVC.ruleView = _selectedRuleView;
    }
    
    _isEntrance = NO;
}


- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
