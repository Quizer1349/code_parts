/*
 * Surfaxin iOS
 *
 * Code by Charles Cheskiewicz & Nathaniel Kirby
 * OPTiMO Information Technology
 *
 */

#import "Constants.h"
#import "ProductInfoViewController.h"
#import "ReaderDocument.h"
#import "AboutViewController.h"

@interface ProductInfoViewController ()

@end

@implementation ProductInfoViewController

// ===============================================================
#pragma mark - Init, etc...

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// ===============================================================

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ===============================================================
#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationItem.title = @"Product Information";
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [a1 addTarget:self action:@selector(infoTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:a1];

}

// ===============================================================
#pragma mark - Actions

- (void)backTapped:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// ===============================================================

- (IBAction)factBookTapped:(id)sender {
    NSString *filePath = [[[NSBundle mainBundle] URLForResource:@"FAQ_FINAL" withExtension:@"pdf" subdirectory:nil] path];
    
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
    
    document.pageNumber = [NSNumber numberWithInt:1];
    
    if (document != nil) {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController.pdfNumber  = kProductFactBookNumber;
        readerViewController.delegate = self;
        
        [self presentModalViewController:readerViewController animated:YES];
    }
}

// ===============================================================

- (IBAction)prescribingClicked:(id)sender {
    NSString *filePath = [[[NSBundle mainBundle] URLForResource:@"PrescribingInfo_FINAL" withExtension:@"pdf" subdirectory:nil] path];
    
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
    
    document.pageNumber = [NSNumber numberWithInt:1];
    
    if (document != nil) {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        readerViewController.pdfNumber  = kPrescribingInfoNumber;
        readerViewController.delegate = self;
    
        [self presentModalViewController:readerViewController animated:YES];
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

@end
