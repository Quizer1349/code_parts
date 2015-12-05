//
//  IAPHelper.h
//  PosingGuide
//
//  Created by Alex Sklyarenko on 09.07.15.
//  Copyright (c) 2015 mainsoft. All rights reserved.
//
#import <StoreKit/StoreKit.h>

@protocol IAPStoreObserver;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

static NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
static NSString *const IAPHelperProductRestoredNotification = @"IAPHelperProductRestoredNotification";
static NSString *const IAPHelperProductRecieptVerifiedNotification = @"IAPHelperProductRecieptVerifiedNotification";
static NSString *const IAPHelperProductPurchasedFailedNotification = @"IAPHelperProductPurchasedFailedNotification";
static NSString *const IAPHelperProductRestoreFailedNotification = @"IAPHelperProductRestoreFailedNotification";
static NSString *const IAPHelperProductRecieptFailedNotification = @"IAPHelperProductRecieptFailedNotification";

static NSString *const IAPHelperTransaction = @"IAPHelperTransaction";

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (BOOL)canMakePayments;
+ (IAPHelper *)sharedInstance;
- (void)provideContentForProductIdentifier:(NSArray *)transactions;

- (void)addStoreObserver:(id<IAPStoreObserver>)observer;
- (void)removeStoreObserver:(id<IAPStoreObserver>)observer;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (void)restoreCompletedTransactions;

- (NSString *)localizedProductPrice;

-(void)showProductErrorAlertForController:(UIViewController *)vc;
-(void)showTransactionErrorAlertForController:(UIViewController *)vc;
-(void)showRestoreErrorAlertForController:(UIViewController *)vc;

@end

@protocol IAPStoreObserver <NSObject>

@optional

-(void)storePaymentTransactionFailed:(NSNotification *)userData;
-(void)storePaymentTransactionFinished:(NSNotification *)userData;
-(void)storeRefreshReceiptFailed:(NSNotification *)userData;
-(void)storeRefreshReceiptFinished:(NSNotification *)userData;
-(void)storeRestoreTransactionsFailed:(NSNotification *)userData;
-(void)storeRestoreTransactionsFinished:(NSNotification *)userData;


@end
