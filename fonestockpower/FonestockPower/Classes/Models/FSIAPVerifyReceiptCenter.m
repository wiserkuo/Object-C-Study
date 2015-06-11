//
//  FSIAPVerifyReceiptCenter.m
//  FonestockPower
//
//  Created by Connor on 14/5/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSIAPVerifyReceiptCenter.h"
#import "FSHUD.h"

@interface FSIAPVerifyReceiptCenter() <FSURLConnectCenterDelegate> {
    NSURL *verifyReceiptURL;
    FSURLConnectCenter *verifyReceiptConnect;
}
@end

@implementation FSIAPVerifyReceiptCenter

- (instancetype)initWithVerifyReceiptURL:(NSURL *)url {
    if (self = [super init]) {
        verifyReceiptURL = url;
    }
    return self;
}

- (BOOL)verifyPurchaseReceiptWithAccount:(NSString *)account
                       receiptBase64Data:(NSString *)receipt
                     isSandboxEnviroment:(BOOL)sandboxEnviroment {
    
    [FSHUD showGlobalProgressHUDWithTitle:@"購買資訊驗證中"];
    
    // php處理base64的不成文的規定轉換, server會做對應的解碼
    receipt = [receipt stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    receipt = [receipt stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    receipt = [receipt stringByReplacingOccurrencesOfString:@"=" withString:@","];
    
    NSString *requestString = [NSString stringWithFormat:@"account=%@&sandbox=%d&receipt=%@", account, sandboxEnviroment, receipt];
    NSData *requestData = [requestString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *connectionRequest = [NSMutableURLRequest requestWithURL:verifyReceiptURL];
	[connectionRequest setHTTPMethod:@"POST"];
	[connectionRequest setTimeoutInterval:120.0];
	[connectionRequest setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	[connectionRequest setHTTPBody:requestData];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:connectionRequest
                                            returningResponse:&response
                                                        error:&error];
    
    [FSHUD hideGlobalHUD];
    
    if (error == nil) {
        NSError *localError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:retData options:kNilOptions error:&localError];
        if (localError == nil) {
            int status = [(NSNumber *)[result objectForKey:@"status"] intValue];
            if (status == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"購物" message:@"交易成功" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
                [alertView show];
                return YES;
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"購物" message:@"1.交易出現問題，請稍候確認" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
                [alertView show];
                return NO;
            }
            NSLog(@"%@", result);
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"購物" message:@"2.交易出現問題，請稍候確認" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
        [alertView show];
    }
    
    return NO;
}

@end
