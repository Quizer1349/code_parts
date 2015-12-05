//
//  IAPHelper.m
//  PosingGuide
//
//  Created by Alex Sklyarenko on 09.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//

#import "IAPHelper.h"
#import "MISAlertController.h"

//static bool hasAddObserver=NO;

@interface IAPHelper (){

    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    NSArray * _skProducts;
}

@end

@implementation IAPHelper

+ (BOOL)canMakePayments {
    
    return [SKPaymentQueue canMakePayments];
}


+ (IAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static IAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      const_iap_productId,
                                      nil];
        
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        _skProducts = [NSArray array];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
    }
    return self;
}

#pragma mark Observers

- (void)addStoreObserver:(id<IAPStoreObserver>)observer {

    [self addStoreObserver:observer selector:@selector(storePaymentTransactionFailed:) notificationName:IAPHelperProductPurchasedFailedNotification];
    [self addStoreObserver:observer selector:@selector(storePaymentTransactionFinished:) notificationName:IAPHelperProductPurchasedNotification];
    [self addStoreObserver:observer selector:@selector(storeRefreshReceiptFailed:) notificationName:IAPHelperProductRecieptFailedNotification];
    [self addStoreObserver:observer selector:@selector(storeRefreshReceiptFinished:) notificationName:IAPHelperProductRecieptVerifiedNotification];
    [self addStoreObserver:observer selector:@selector(storeRestoreTransactionsFailed:) notificationName:IAPHelperProductRestoreFailedNotification];
    [self addStoreObserver:observer selector:@selector(storeRestoreTransactionsFinished:) notificationName:IAPHelperProductRestoredNotification];
}

- (void)removeStoreObserver:(id<IAPStoreObserver>)observer {
    
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:IAPHelperProductPurchasedFailedNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:IAPHelperProductPurchasedNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:IAPHelperProductRecieptFailedNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:IAPHelperProductRecieptVerifiedNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:IAPHelperProductRestoreFailedNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:IAPHelperProductRestoredNotification object:self];

}

// Private

- (void)addStoreObserver:(id)observer selector:(SEL)aSelector notificationName:(NSString*)notificationName
{
    if ([observer respondsToSelector:aSelector])
    {
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:notificationName object:self];
    }
}


- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    DLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)restoreCompletedTransactions {

    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    _skProducts = response.products;
    for (SKProduct * skProduct in _skProducts) {
        DLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, _skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    DLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}


// Logs all transactions that have been removed from the payment queue
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    
    for(SKPaymentTransaction * transaction in transactions)
    {
        NSLog(@"%@ was removed from the payment queue.", transaction.payment.productIdentifier);
    }
}


-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads{


    for (SKDownload *download in downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
                DLog(@"SKDownloadStateActive");
                break;
            case SKDownloadStateCancelled:
                DLog(@"SKDownloadStateCancelled");
                break;
            case SKDownloadStateFailed:
                DLog(@"SKDownloadStateFailed");
                break;
            case SKDownloadStateFinished:
                DLog(@"SKDownloadStateFinished");
                break;
            case SKDownloadStatePaused:
                DLog(@"SKDownloadStatePaused");
                break;
            case SKDownloadStateWaiting:
                DLog(@"SKDownloadStateWaiting");
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {

    
    if (error.code != SKErrorPaymentCancelled){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreFailedNotification object:self userInfo:nil];
        DLog(@"Transaction error: %@", error.localizedDescription);
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    DLog(@"completeTransaction...");
    
    NSMutableDictionary * extraData = [NSMutableDictionary dictionary];
    extraData[IAPHelperTransaction] = transaction;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:self userInfo:extraData];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    DLog(@"restoreTransaction...");
    
    NSMutableDictionary * extraData = [NSMutableDictionary dictionary];
    extraData[IAPHelperTransaction] = transaction;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredNotification object:self userInfo:extraData];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    DLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSMutableDictionary * extraData = [NSMutableDictionary dictionary];
        extraData[IAPHelperTransaction] = transaction;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedFailedNotification object:self userInfo:extraData];
        DLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }else{
    
        /*Google analytics*/
        [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"full_version_action"
                                                                                            action:@"button_press"
                                                                                             label:@"cancell_buying_button"
                                                                                             value:nil] build]];
    }
}


- (void)provideContentForProductIdentifier:(NSArray *)transactions {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:const_iap_statusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)localizedProductPrice{
    
    if(_skProducts.count == 0){
        
        return @"";
    }
    
    SKProduct *product = _skProducts.lastObject ;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    
   return [formattedString stringByReplacingOccurrencesOfString:@"₽" withString:@"руб."];
}

#pragma mark - Error Alerts

-(void)showProductErrorAlertForController:(UIViewController *)vc{

    if(!vc){
    
        return;
    }
    
    MISAlertController *alertController = [MISAlertController alertControllerWithTitle:NSLocalizedString(@"Products Request Failed", @"")
                                                                               message:NSLocalizedString(const_local_itunesConnectError, @"")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    MISAlertAction *cancelAction = [MISAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:^(MISAlertAction *action) {
        NSLog(@"Cancel");
    }];
    
    [alertController addAction:cancelAction];
    [alertController showInViewController:vc animated:YES];
}

-(void)showTransactionErrorAlertForController:(UIViewController *)vc{
    
    if(!vc){
        
        return;
    }
    
    MISAlertController *alertController = [MISAlertController alertControllerWithTitle:NSLocalizedString(@"Payment Transactions Failed", @"")
                                                                               message:F(@"%@\n%@", NSLocalizedString(const_local_downloadError, nil), NSLocalizedString(const_local_tryLaterError, nil))
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    MISAlertAction *cancelAction = [MISAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:^(MISAlertAction *action) {
        NSLog(@"Cancel");
    }];
    
    [alertController addAction:cancelAction];
    [alertController showInViewController:vc animated:YES];
}

-(void)showRestoreErrorAlertForController:(UIViewController *)vc{
    
    if(!vc){
        
        return;
    }
    
    MISAlertController *alertController = [MISAlertController alertControllerWithTitle:NSLocalizedString(@"Restore Transactions Failed", @"")
                                                                               message:F(@"%@\n%@", NSLocalizedString(const_local_downloadError, nil), NSLocalizedString(const_local_tryLaterError, nil))
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    MISAlertAction *cancelAction = [MISAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleCancel handler:^(MISAlertAction *action) {
        NSLog(@"Cancel");
    }];
    
    [alertController addAction:cancelAction];
    [alertController showInViewController:vc animated:YES];
}


@end
