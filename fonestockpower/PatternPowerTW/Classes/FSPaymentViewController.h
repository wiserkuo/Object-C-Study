//
//  FSPaymentViewController.h
//  DivergenceStock
//
//  Created by Connor on 2014/11/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FSIAPHelper.h"
#import "FSWebViewController.h"

@interface FSPaymentViewController : FSWebViewController {
    NSString *_paymentURL;
    BOOL iapRequestFlag;
}

- (instancetype)initWithPaymentURL:(NSString *)paymentURL;

@end
