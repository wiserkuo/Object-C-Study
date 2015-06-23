//
//  FSIAPHelper.h
//  DivergenceStock
//
//  Created by Connor on 2014/11/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

typedef void (^requestProductCompletion)(NSArray *products);
typedef void (^requestBuyProductCompletion)(void);
typedef void (^CompletionHandler)(BOOL success);

@interface FSIAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    NSArray *_productIdList;
    NSDictionary *_productNameDict;
    NSArray *_myProduct;
    NSMutableDictionary *productObjects;
    NSString *productListURL;
    NSString *verifyReceiptURL;
    CompletionHandler iapHandler;
}

- (instancetype)initWithProductsListsURL:(NSString *)productListURLString verifyReceiptURL:(NSString *)verifyReceiptURLString;

- (BOOL)buyProductWithIdentifier:(NSString *)productID completionHandler:(CompletionHandler)handler;
- (void)requestProductsDataWithCompletion:(void (^)(NSArray *products))completion error:(void (^)(NSError *error))error;
- (NSString *)productToBase64String:(NSArray *)products;

@property (nonatomic, copy) void (^requestProductsCompletion)(NSArray *products);
@property (readonly) NSString *subscriptionStatus;
@property (readonly) BOOL canSubscription;
@property (readonly) NSString *canSubscriptionDate;


- (void)addTransactionObserver;
- (void)removeTransactionObserver;

@end
