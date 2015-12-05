/*
 * Surfaxin iOS
 *
 * Code by Charles Cheskiewicz & Nathaniel Kirby
 * OPTiMO Information Technology
 *
 */

#import "Constants.h"
#import "HomeViewController.h"
#import "ReaderDocument.h"

#import "ProductInfoViewController.h"
#import "DosingChartViewController.h"
#import "WarmingCradleViewController.h"
#import "ContactDLViewController.h"
#import "AboutViewController.h"

@implementation HomeViewController

// ===============================================================
#pragma mark - Init, etc...

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

   }
   return self;
}

// ===============================================================

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// ===============================================================
#pragma mark - View Lifecycle
// ===============================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title view
    //
    
    UIView* titleView = [[UIView alloc] init];
    titleView.frame   = self.navigationController.navigationBar.bounds;
    
    
    // Title attributed text
    //
    
    NSString* title = @"Surfaxin®";
    
    NSMutableAttributedString* attributedTitle = [[NSMutableAttributedString alloc] initWithString: title];
    
    [attributedTitle addAttribute: NSFontAttributeName
                            value: [UIFont boldSystemFontOfSize: 17]
                            range: NSMakeRange(0, title.length)];
    
    [attributedTitle setAttributes: @{NSFontAttributeName : [UIFont fontWithName: @"American Typewriter"
                                                                            size: 20]}
                             range: [title rangeOfString: @"®"]];
    
    // Title label
    //
    CGFloat leftOffset = 40;
    
    UILabel* titleLabel = [[UILabel alloc] init];
    
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.attributedText   = attributedTitle;
    titleLabel.frame            = CGRectMake(leftOffset,
                                             0,
                                             titleView.frame.size.width - leftOffset,
                                             titleView.frame.size.height);
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textAlignment    = NSTextAlignmentCenter;
    
    [titleView addSubview: titleLabel];
    
    self.navigationItem.titleView = titleView;
    
    self.navigationController.navigationItem.backBarButtonItem.title = nil;
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [a1 addTarget:self action:@selector(infoTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:a1];
}

// ===============================================================
#pragma mark - View Lifecycle
// ===============================================================

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            self.productInformationButton.center = CGPointMake(180, 190);
            self.administrationButton.center = CGPointMake(510, 190);
            self.monographButton.center = CGPointMake(850, 190);
            self.dosingButton.center = CGPointMake(180, 520);
            self.cradleButton.center = CGPointMake(510, 520);
            self.contactButton.center = CGPointMake(850, 520);
        } else {
            self.productInformationButton.center = CGPointMake(210, 165);
            self.administrationButton.center = CGPointMake(560, 165);
            self.monographButton.center = CGPointMake(210, 480);
            self.dosingButton.center = CGPointMake(560, 480);
            self.cradleButton.center = CGPointMake(210, 790);
            self.contactButton.center = CGPointMake(560, 790);
        }
    }
}

// ===============================================================

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }else{
        return NO;
    }
    
}

// ===============================================================

-(NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
    
}

// ===============================================================

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            self.productInformationButton.center = CGPointMake(170, 200);
            self.administrationButton.center = CGPointMake(384, 200);
            self.monographButton.center = CGPointMake(600, 200);
            self.dosingButton.center = CGPointMake(170, 720);
            self.cradleButton.center = CGPointMake(384, 720);
            self.contactButton.center = CGPointMake(600, 720);
        } else {
            self.productInformationButton.center = CGPointMake(220, 160);
            self.administrationButton.center = CGPointMake(800, 160);
            self.monographButton.center = CGPointMake(220, 350);
            self.dosingButton.center = CGPointMake(800, 350);
            self.cradleButton.center = CGPointMake(220, 540);
            self.contactButton.center = CGPointMake(800, 540);
        }
    }
}

// ===============================================================
#pragma mark - Actions

- (IBAction)productInfoTapped:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ProductInfoViewController *productInfoView = [[ProductInfoViewController alloc] initWithNibName:@"ProductInfoViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:productInfoView animated:YES];        
    } else {
        ProductInfoViewController *productInfoView = [[ProductInfoViewController alloc] initWithNibName:@"ProductInfoViewController" bundle:nil];
        [self.navigationController pushViewController:productInfoView animated:YES];
    }
}

// ===============================================================

- (IBAction)administrationTapped:(id)sender {
    NSURL *theMovieURL = nil;
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle) {
        NSString *moviePath = [bundle pathForResource:@"Surfaxin Administration_05" ofType:@"mp4"];
        if (moviePath) {
            theMovieURL = [NSURL fileURLWithPath:moviePath];
        }
    }
    
    moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:theMovieURL];
    
    if (moviePlayerController){
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    }
}

// ===============================================================

- (IBAction)monographTapped:(id)sender {
    NSString *filePath = [[[NSBundle mainBundle] URLForResource:@"Monograph_FINAL" withExtension:@"pdf" subdirectory:nil] path];
    
	ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
    document.pageNumber = [NSNumber numberWithInt:1];
    
	if (document != nil) {
		ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController.pdfNumber  = kMonographNumber;
		readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
		[self presentModalViewController:readerViewController animated:YES];
    }
}

// ===============================================================

- (IBAction)dosingTapped:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        DosingChartViewController *dosingChart = [[DosingChartViewController alloc] initWithNibName:@"DosingChartViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:dosingChart animated:YES];
        
    } else {
        DosingChartViewController *dosingChart = [[DosingChartViewController alloc] initWithNibName:@"DosingChartViewController" bundle:nil];
        [self.navigationController pushViewController:dosingChart animated:YES];
    }
}

// ===============================================================

- (IBAction)warmingCradleTapped:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        WarmingCradleViewController *warmingCradle = [[WarmingCradleViewController alloc] initWithNibName:@"WarmingCradleViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:warmingCradle animated:YES];        
    } else {
        WarmingCradleViewController *warmingCradle = [[WarmingCradleViewController alloc] initWithNibName:@"WarmingCradleViewController" bundle:nil];
        [self.navigationController pushViewController:warmingCradle animated:YES];
    }
}

// ===============================================================

- (IBAction)contactTapped:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ContactDLViewController *contact = [[ContactDLViewController alloc] initWithNibName:@"ContactDLViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:contact animated:YES];
    } else {
        ContactDLViewController *contact = [[ContactDLViewController alloc] initWithNibName:@"ContactDLViewController" bundle:nil];
        [self.navigationController pushViewController:contact animated:YES];
    }
}

// ===============================================================

- (void)infoTapped:(id)sender {
    AboutViewController *viewController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        viewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController_iPad" bundle:nil];
    } else {
        viewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

// ===============================================================
#pragma mark - ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setProductInformationButton:nil];
    [self setAdministrationButton:nil];
    [self setMonographButton:nil];
    [self setDosingButton:nil];
    [self setCradleButton:nil];
    [self setContactButton:nil];
    [super viewDidUnload];
}
@end
