//
//  FSIAPHelper.m
//  DivergenceStock
//
//  Created by Connor on 2014/11/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSIAPHelper.h"
#import "ZipArchive.h"
#import "FSFile.h"
#import "NSData+MD5.h"

@implementation FSIAPHelper

/*
    1. 跟server取得ProductID, 如 27A2200001, 27A2200002
    2. 取得ProductID後送至APPLE取得商品名稱與價錢
    3.
*/

// 跟server取得ProductID, 如 27A2200001, 27A2200002
- (instancetype)initWithProductsListsURL:(NSString *)productListURLString verifyReceiptURL:(NSString *)verifyReceiptURLString {
    if (self = [super init]) {
        
        productListURL = productListURLString;
        verifyReceiptURL = verifyReceiptURLString;
        
        productObjects = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        [self initWebUI];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSuccessNotification:)
                                                     name:@"loginAuthStatus"
                                                   object:nil];
    }
    return self;
}

- (void)addTransactionObserver {
    // 啟動payment機制
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)removeTransactionObserver {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


- (void)loginSuccessNotification:(NSNotification *)note {
    FSLoginResultType authResultType = [[note object] intValue];
    if (authResultType == FSLoginResultTypeAuthLoginSuccess ||
        authResultType == FSLoginResultTypePaymentRequired) {
        [self checkSubscription];
        [self syncFonestockAppProductLists];
    }
}

- (void)checkSubscription {
    NSString *account = [[FSDataModelProc sharedInstance] loginService].account;
    if (account == nil) return;
    
    NSURLRequest *requset = [[[FSDataModelProc sharedInstance] signupModel] checkSubscriptionStatus:account];
    [NSURLConnection sendAsynchronousRequest:requset queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *jsonParseError;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParseError];
            if (!jsonParseError) {
                _subscriptionStatus = [jsonDict objectForKey:@"status"];
                
                /*
                 
                 錯誤訊息(status欄位)：
                 
                 stat.ok
                 comm.001 無效的帳戶(無法解密也可能)
                 comm.002 無效的APPID
                 stat.001 MIS查詢失敗
                 stat.002 蘋果訂閱中(message欄位為到期時間)
                 stat.003 非訂閱期限未到結束前七天(message欄位為開放時間)
                 
                 */
                if ([@"stat.ok" isEqualToString:_subscriptionStatus]) {
                    _canSubscription = YES;
                }
                else {
                    _canSubscription = NO;
                    
                    if ([@"comm.001" isEqualToString:_subscriptionStatus]) {
                        
                    } else if ([@"comm.002" isEqualToString:_subscriptionStatus]) {
                        
                    } else if ([@"stat.001" isEqualToString:_subscriptionStatus]) {
                        
                    } else if ([@"stat.002" isEqualToString:_subscriptionStatus]) {
                        _canSubscriptionDate = [jsonDict objectForKey:@"message"];
                    } else if ([@"stat.003" isEqualToString:_subscriptionStatus]) {
                        _canSubscriptionDate = [jsonDict objectForKey:@"message"];
                    }
                    
                }
            } else {
                _canSubscription = NO;
            }
        }
    }];
}

- (void)initWebUI {
    
    BOOL checkFile = [FSFile fileExistsInCacheDirectory:@"inapp_apple" fileName:@"subscription.html"];

    if (!checkFile) {
        NSString *zipPath = [[NSBundle mainBundle] pathForResource:@"inapp_apple" ofType:@"zip"];
        
        NSString *path = [CodingUtil fonestockDocumentsPath];
        
        ZipArchive *za = [[ZipArchive alloc] init];
        if ([za UnzipOpenFile: zipPath]) {
            // 2
            BOOL ret = [za UnzipFileTo: path overWrite: YES];
            if (ret) {
            
                NSData *localFileData = [NSData dataWithContentsOfFile:zipPath];
                NSString *localFileData_md5 = [localFileData MD5];
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:localFileData_md5 forKey:@"inapp_apple.zip"];
                [userDefault synchronize];
                
            }
            
            [za UnzipCloseFile];
            
            // 3
            //                    NSString *imageFilePath = [path stringByAppendingPathComponent:@"photo.png"];
            //                    NSString *textFilePath = [path stringByAppendingPathComponent:@"text.txt"];
            //                    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
            //                    UIImage *img = [UIImage imageWithData:imageData];
            //                    NSString *textString = [NSString stringWithContentsOfFile:textFilePath
            //                                                                     encoding:NSASCIIStringEncoding error:nil];
            
            // 4
            dispatch_async(dispatch_get_main_queue(), ^{
                //                        self.imageView.image = img;
                //                        self.label.text = textString;
                
                [self updateWebUI];
            });
        }
    }
    else
    {
        NSLog(@"檔案已存在");
        [self updateWebUI];
    }
    
    
    
}

- (void)updateWebUI {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        NSData *data;
        
        NSString *urlString = [NSString stringWithFormat:
                               @"http://www.fonestock.com.tw/fs_download/inapp_apple.log?timestamp=%f",
                               [NSDate timeIntervalSinceReferenceDate]];
        NSURL *url = [NSURL URLWithString:urlString];
        
        
        data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        
        NSString *fileContent = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        
        
        NSArray *allLinedStrings = [fileContent componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        
        
        NSMutableDictionary *md5MAP = [[NSMutableDictionary alloc] init];
        for (NSString *record in allLinedStrings) {
            NSArray *data = [record componentsSeparatedByString:@"  "];
            if ([data count] == 2) {
                [md5MAP setObject:[data objectAtIndex:0] forKey:[data objectAtIndex:1]];
            }
        }
        
        NSString *inapp_apple_md5 = [md5MAP objectForKey:@"inapp_apple.zip"];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *inapp_apple_save_md5 = [userDefault objectForKey:@"inapp_apple.zip"];
        
        if (inapp_apple_save_md5) {
            if (inapp_apple_md5) {
                if (![inapp_apple_save_md5 isEqualToString:inapp_apple_md5]) {
                    urlString = [NSString stringWithFormat:
                                 @"http://www.fonestock.com.tw/fs_download/inapp_apple.zip?md5=%@",
                                 inapp_apple_md5];
                    
                    
                    url = [NSURL URLWithString:urlString];
                    
                    
                    
                    data = [NSData dataWithContentsOfURL:url options:0 error:&error];
                    
                    if(!error)
                    {
                        
                        NSString *path = [CodingUtil fonestockDocumentsPath];
                        NSString *zipPath = [path stringByAppendingPathComponent:@"inapp_apple.zip"];
                        
                        [data writeToFile:zipPath options:0 error:&error];
                        
                        if(!error)
                        {
                            // TODO: Unzip
                            ZipArchive *za = [[ZipArchive alloc] init];
                            // 1
                            if ([za UnzipOpenFile: zipPath]) {
                                // 2
                                BOOL ret = [za UnzipFileTo: path overWrite: YES];
                                if (ret){
                                    
                                    // 儲存成功, 更新md5
                                    NSString *downloadFileMD5 = [data MD5];
                                    if ([inapp_apple_md5 isEqualToString:downloadFileMD5]) {
                                        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                                        [userDefault setObject:inapp_apple_md5 forKey:@"inapp_apple.zip"];
                                        [userDefault synchronize];
                                    }
                                }
                                
                                [za UnzipCloseFile];
                                
                                // 3
                                //                    NSString *imageFilePath = [path stringByAppendingPathComponent:@"photo.png"];
                                //                    NSString *textFilePath = [path stringByAppendingPathComponent:@"text.txt"];
                                //                    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath options:0 error:nil];
                                //                    UIImage *img = [UIImage imageWithData:imageData];
                                //                    NSString *textString = [NSString stringWithContentsOfFile:textFilePath
                                //                                                                     encoding:NSASCIIStringEncoding error:nil];
                                
                                // 4
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //                        self.imageView.image = img;
                                    //                        self.label.text = textString;
                                });
                            }
                        }
                        else
                        {
                            NSLog(@"Error saving file %@",error);
                        }
                    }
                    else
                    {
                        NSLog(@"Error downloading zip file: %@", error);
                    }
                    
                    
                    
                } else {
                    NSLog(@"檔案是最新的");
                }
            }
        }
        
        
        
        
        
    });
}

- (void)requestProductsDataWithCompletion:(void (^)(NSArray *))completion error:(void (^)(NSError *))error {
    _requestProductsCompletion = completion;
    [self requestProductAllData];
}

- (void)syncFonestockAppProductLists {
    
//    FSFonestock *fonestock = [FSFonestock sharedInstance];
    
//    NSString *product1 = [NSString stringWithFormat:@"%@.01.02", fonestock.appId];
//    NSString *product2 = [NSString stringWithFormat:@"%@.02.02", fonestock.appId];
//    NSString *product3 = [NSString stringWithFormat:@"%@.03.02", fonestock.appId];
    
//    _productIdList = @[product1, product3];
    
//    [self requestProductAllData];
    
    FSFonestock *fonestock = [FSFonestock sharedInstance];
    NSDictionary *productList = [[NSMutableDictionary alloc] initWithCapacity:1];
    [productList setValue:fonestock.appId forKey:@"app_id"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productList options:0 error:&error];
    
    NSURL *URL = [NSURL URLWithString:productListURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSError *error = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if (error != nil) {
                NSLog(@"Error parsing JSON.");
            }
            else {
                _productIdList = [jsonDict objectForKey:@"productList"];
                _productNameDict = [jsonDict objectForKey:@"productName"];
                 
                
            }
        }
    }];
}

// 取得ProductID後送至APPLE取得商品名稱與價錢
- (void)requestProductAllData {
    if ([SKPaymentQueue canMakePayments]) {
        // 非同步取得全部商品資訊
        NSSet *productSet = [NSSet setWithArray:_productIdList];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
        request.delegate = self; // SKProductsRequestDelegate
        [request start];
    } else {
        NSLog(@"不允許程式內支付購買功能");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"不允許程式內支付購買功能", @"AccountSetting", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil)  otherButtonTitles:nil];
        [alertView show];
    }
}

// 購買某件商品
- (BOOL)buyProductWithIdentifier:(NSString *)productID completionHandler:(CompletionHandler)handler {
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"允許程式內支付購買功能");
        
        SKProduct *productItem = [productObjects objectForKey:productID];
        if (productItem != nil) {
            // 加入購買商品
            SKPayment *payment = [SKPayment paymentWithProduct:productItem];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            
            iapHandler = handler;
            
            return YES;
        }
        else {
            NSLog(@"商品資訊已過期, 請重新取得商品清單");
        }
    } else {
        NSLog(@"不允許程式內支付購買功能");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"不允許程式內支付購買功能", @"AccountSetting", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil)  otherButtonTitles:nil];
        [alertView show];
    }
    
    return NO;
}


- (void)restoreItem:(int)type {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    _myProduct = response.products;
    NSLog(@"無效的產品:%@", response.invalidProductIdentifiers);
    NSLog(@"產品付費數量: %lu", (unsigned long)[_myProduct count]);
    
    if ([_myProduct count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"無法取得產品訊息，購買失敗", @"AccountSetting", nil)  delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil)  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    [productObjects removeAllObjects];
    for (SKProduct *product in _myProduct) {
        [productObjects setObject:product forKey:product.productIdentifier];
    }
    _requestProductsCompletion(_myProduct);
}

#pragma mark SKPaymentTransactionObserver methods
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:    // 交易成功
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:       // 交易失敗
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:     //  已經購買的商品
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:   //  商品添加進列表
                NSLog(@"商品添加進列表");
                break;
            default:
                break;
        }
    };
}

- (BOOL)checkReceiptForVerifyServer:(NSData *)receiptData {
    
    NSString *receiptDataAsString = [receiptData base64EncodedStringWithOptions:0];
    NSDictionary *productList = [[NSMutableDictionary alloc] initWithCapacity:3];
    FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
    
    [productList setValue:loginService.account forKey:@"id"];
    [productList setValue:@"buy" forKey:@"mode"];
    [productList setValue:receiptDataAsString forKey:@"receipt"];
    [productList setValue:[FSFonestock sharedInstance].appId forKey:@"app_id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productList options:0 error:&error];
    NSData *postBase64Data = [jsonData base64EncodedDataWithOptions:0];

    NSURL *URL = [NSURL URLWithString:verifyReceiptURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postBase64Data];
    
    NSURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!error) {
        NSDictionary *retDict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        if (!error) {
            NSString *status = [retDict objectForKey:@"status"];
            
            NSLog(@"%@", status);
            
            /*
            以下為可刪收據的情況：
            subs.004(無新收據資料)
            subs.005(MIS錯誤)
            subs.006(原APPLIE ID仍在扣款中)
            subs.ok(收據更新成功)
            
            以下為不可刪除收據的情況：
            comm.001(帳號無效)
            comm.002(APP ID無效)
            subs.001(收據無效)
            subs.002(蘋果官方之錯誤訊息)
            subs.003(無法儲存收據)
             */

            if ([@"subs.ok" isEqualToString:status]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"交易成功", @"AccountSetting", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
                [alertView show];
                return YES;
            }
            
            else if ([@"subs.004" isEqualToString:status] ||
                     [@"subs.005" isEqualToString:status] ||
                     [@"subs.006" isEqualToString:status]) {
                return YES;
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"交易出現問題，請稍候確認", @"AccountSetting", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil) otherButtonTitles:nil];
                [alertView show];
                return NO;
            }
            
            
        }
        else {
            NSLog(@"retDict BUG");
            NSLog(@"%@", error);
            return NO;
        }
    }
    else {
        NSLog(@"responseData BUG");
        NSLog(@"%@", error);
        return NO;
    }
}

//- (BOOL)checkReceipt:(NSData *)receiptData {
//    
//    NSString *receiptDataAsString = [receiptData base64EncodedStringWithOptions:0];
//    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:receiptDataAsString,
//                          @"receipt-data", @"177bfd7099444c86b20fb33bfd43e85c", @"password",nil];
//
////                          @"receipt-data", nil];
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
//    
//    
//    NSString *str = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
//    NSLog(@"往APPLE檢驗的收據: %@", str);
//
//    
//    NSURL *sandboxStoreURL = [[NSURL alloc] initWithString: @"https://sandbox.itunes.apple.com/verifyReceipt"];
//    NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:sandboxStoreURL];
//    [connectionRequest setHTTPMethod:@"POST"];
//    [connectionRequest setTimeoutInterval:FS_REQUEST_TIMEOUT];
//    [connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
//    [connectionRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [connectionRequest setHTTPBody:postData];
//    
//    NSURLResponse *response = nil;
//    NSError *error = nil;
//    NSData *retData = [NSURLConnection sendSynchronousRequest:connectionRequest
//                                            returningResponse:&response
//                                                        error:&error];
//    if (error == nil) {
//        NSError *localError;
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:retData options:kNilOptions error:&localError];
//        
//        NSString *aa = [[NSString alloc] initWithData:retData encoding:NSUTF8StringEncoding];
//        NSLog(@"APPLE回傳的資訊: %@", aa);
//        if (localError == nil) {
//            int status = [(NSNumber *)[result objectForKey:@"status"] intValue];
//            
//            if (status == 0) {
////                NSDictionary *receipt = [result objectForKey:@"receipt"];
//                
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"購物" message:@"交易成功" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
//                [alertView show];
//                return YES;
//                
//            } else {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"購物" message:@"交易出現問題，請稍候確認" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
//                [alertView show];
//            }
//        }
//    }
//    return NO;
//}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"SKPaymentTransactionStatePurchased");
    
    NSData *receipt = [self appStoreReceiptForPaymentTransaction:transaction];
    BOOL receiptSuccessful = [self checkReceiptForVerifyServer:receipt];
//    BOOL receiptSuccessful = [self checkReceipt:receipt];
    
    
    NSError *error;

    NSURL *URL = [NSURL URLWithString:@"http://www.fonestock.com.tw/m/log.php"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
    NSData *receiptData = [receipt base64EncodedDataWithOptions:0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:receiptData];
    
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    
    if (!error) {
//        [[[UIAlertView alloc] initWithTitle:@"給脆迪酥訊息" message:@"寫入SERVER囉" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil] show];
    }
    
    [self finishTransaction:transaction wasSuccessful:receiptSuccessful];
    
    if (iapHandler) {
        iapHandler(receiptSuccessful);
    }
}


// 交易失敗, 交易取消
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"SKPaymentTransactionStateFailed");
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"交易失敗", @"AccountSetting", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil)  otherButtonTitles:nil];
        [alertView show];
        
    } else {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"交易取消", @"AccountSetting", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil)  otherButtonTitles:nil];
        [alertView show];
    }
    
    if (iapHandler) {
        iapHandler(NO);
    }
}

// 交易結束
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful {
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    
    if (wasSuccessful) {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
        
    } else {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

// 還原交易狀態
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"SKPaymentTransactionStateRestored");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"還原交易狀態" delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"AccountSetting", nil)  otherButtonTitles:nil];
    [alertView show];
    
    [self finishTransaction:transaction wasSuccessful:YES];
}

- (NSData *)appStoreReceiptForPaymentTransaction:(SKPaymentTransaction *)transaction {
    NSURL *receiptFileURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptFileURL];
    return receiptData;
}




// 傳給脆迪酥網站用的格式

/*
 
 {
 "product_name" : "台股圖示力",
 "product_count" : 3,
 "products" : [
 {
 "localized_description" : "圖示力1個月的描述說明",
 "price" : 30,
 "localized_title" : "1個月",
 "productIdentifier" : "027A2200004",
 "formattedPrice" : "NT$30.00"
 },
 {
 "localized_description" : "圖示力LPCB版(半年繳)",
 "price" : 60,
 "localized_title" : "6個月",
 "productIdentifier" : "027A2200005",
 "formattedPrice" : "NT$60.00"
 },
 {
 "localized_description" : "圖示力LPCB版(年繳)的描述說明",
 "price" : 90,
 "localized_title" : "12個月",
 "productIdentifier" : "027A2200006",
 "formattedPrice" : "NT$90.00"
 }
 ]
 
 }
 ewogICJwcm9kdWN0X25hbWUiIDogIuWPsOiCoeWcluekuuWKmyIsCiAgInByb2R1Y3RfY291bnQiIDogMywKICAicHJvZHVjdHMiIDogWwogICAgewogICAgICAibG9jYWxpemVkX2Rlc2NyaXB0aW9uIiA6ICLlnJbnpLrlipsx5YCL5pyI55qE5o+P6L+w6Kqq5piOIiwKICAgICAgInByaWNlIiA6IDMwLAogICAgICAibG9jYWxpemVkX3RpdGxlIiA6ICIx5YCL5pyIIiwKICAgICAgInByb2R1Y3RJZGVudGlmaWVyIiA6ICIwMjdBMjIwMDAwNCIsCiAgICAgICJmb3JtYXR0ZWRQcmljZSIgOiAiTlQkMzAuMDAiCiAgICB9LAogICAgewogICAgICAibG9jYWxpemVkX2Rlc2NyaXB0aW9uIiA6ICLlnJbnpLrliptMUENC54mIKOWNiuW5tOe5sykiLAogICAgICAicHJpY2UiIDogNjAsCiAgICAgICJsb2NhbGl6ZWRfdGl0bGUiIDogIjblgIvmnIgiLAogICAgICAicHJvZHVjdElkZW50aWZpZXIiIDogIjAyN0EyMjAwMDA1IiwKICAgICAgImZvcm1hdHRlZFByaWNlIiA6ICJOVCQ2MC4wMCIKICAgIH0sCiAgICB7CiAgICAgICJsb2NhbGl6ZWRfZGVzY3JpcHRpb24iIDogIuWcluekuuWKm0xQQ0LniYgo5bm057mzKeeahOaPj+i/sOiqquaYjiIsCiAgICAgICJwcmljZSIgOiA5MCwKICAgICAgImxvY2FsaXplZF90aXRsZSIgOiAiMTLlgIvmnIgiLAogICAgICAicHJvZHVjdElkZW50aWZpZXIiIDogIjAyN0EyMjAwMDA2IiwKICAgICAgImZvcm1hdHRlZFByaWNlIiA6ICJOVCQ5MC4wMCIKICAgIH0KICBdCn0=
 
 */

- (NSString *)productToBase64String:(NSArray *)products {
    NSMutableDictionary *productList = [[NSMutableDictionary alloc] init];
    
    NSString *appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    [productList setValue:appName forKey:@"product_name"];
    [productList setValue:[NSNumber numberWithInteger:[products count]] forKey:@"product_count"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (SKProduct *product in products) {
        
        NSMutableDictionary *productData = [[NSMutableDictionary alloc] initWithCapacity:5];
        
        // 商品顯示名稱
        [productData setValue:[_productNameDict objectForKey:product.productIdentifier] forKey:@"localized_title"];
        // 商品描述
        [productData setValue:product.localizedDescription forKey:@"localized_description"];
        // 商品價格
        [productData setValue:product.price forKey:@"price"];
        // 商品唯一識別(MIS用)
        [productData setValue:product.productIdentifier forKey:@"productIdentifier"];
        
        // 轉換多國貨幣
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
        
        // 多國貨幣
        [productData setValue:formattedPrice forKey:@"formattedPrice"];
        
        [array addObject:productData];
    }
    
    [productList setValue:array forKey:@"products"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productList options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *base64String = [jsonData base64EncodedStringWithOptions:0];
    return base64String;
}

- (void)dealloc {
    
}


@end
