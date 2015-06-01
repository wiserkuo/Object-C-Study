//
//  FSIAPVerifyReceiptCenter.h
//  FonestockPower
//
//  Created by Connor on 14/5/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSURLConnectCenter.h"

@protocol FSIAPVerifyReceiptCenterDelegate;

@interface FSIAPVerifyReceiptCenter : NSObject

- (instancetype)initWithVerifyReceiptURL:(NSURL *)url;
- (BOOL)verifyPurchaseReceiptWithAccount:(NSString *)account
                       receiptBase64Data:(NSString *)receipt
                     isSandboxEnviroment:(BOOL)sandboxEnviroment;
@end
