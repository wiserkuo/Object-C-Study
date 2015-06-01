//
//  FSPaymentViewController.m
//  DivergenceStock
//
//  Created by Connor on 2014/11/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPaymentViewController.h"
#import "FSURLParser.h"

@interface FSPaymentViewController() {
    SEL goBackFunction;
}
@end

@implementation FSPaymentViewController

- (instancetype)initWithPaymentURL:(NSString *)paymentURL {
    if (self = [super init]) {
        _paymentURL = paymentURL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    webview.delegate = self;
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_paymentURL]]];
}

# pragma mark -
# pragma mark webview delegate
# pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    currentPageURL = [[request URL] absoluteString];
    FSURLParser *parser = [[FSURLParser alloc] initWithURLString:currentPageURL];

    // URL攔截模式
    if ([@"1" isEqualToString:[parser valueForVariable:@"forapp"]]) {
        // 
        if ([@"1" isEqualToString:[parser valueForVariable:@"request_iap"]]) {
            iapRequestFlag = YES;
        }
        if ([@"1" isEqualToString:[parser valueForVariable:@"openurl"]]) {
            
            
            NSURL *newURL = [[NSURL alloc] initWithScheme:[[request URL] scheme]
                                                      host:[[request URL] host]
                                                      path:[[request URL] path]];
            
            [[UIApplication sharedApplication] openURL:newURL];
            
            return NO;
        }
        
        // 購買商品
        if ([@"1" isEqualToString:[parser valueForVariable:@"goshopping"]]) {
            NSString *productId = [parser valueForVariable:@"product_id"];
            FSDataModelProc *dataModelProc = [FSDataModelProc sharedInstance];
            
            [hud show:YES];
            
            BOOL canBuy = [dataModelProc.iapHelper buyProductWithIdentifier:productId completionHandler:^(BOOL success) {
                [hud hide:YES];
                
                if (success) {
                    FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
                    [loginService loginAuthUsingSelfAccount];
                }
            }];
                           
            if (!canBuy) {
                [hud hide:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"無法購買" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil];
                [alertView show];
            }
            return NO;
        }
        // 關閉webview
        if ([@"1" isEqualToString:[parser valueForVariable:@"close"]]) {
            [self closeViewController];
            return NO;
        }
        
        if ([@"card.ok" isEqualToString:[parser valueForVariable:@"status"]]) {
            goBackFunction = @selector(closeViewController);
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [hud show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (iapRequestFlag) {
        iapRequestFlag = NO;
        
        [hud show:YES];
        
        // In App Purchase API 取得商品資訊
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        [dataModel.iapHelper requestProductsDataWithCompletion:^(NSArray *products) {
            NSString *base64String = [dataModel.iapHelper productToBase64String:products];
            NSString *js_showProduct = [NSString stringWithFormat:@"showProduct('%@');", base64String];
            [webView stringByEvaluatingJavaScriptFromString:js_showProduct];
            
            [hud hide:NO];
            
        } error:^(NSError *error) {
            //
        }];
    }
    else {
        [hud hide:YES];
    }
    
    // webview內容自動捲到最上方
//    NSString *js_scrollToTop = @"scrollTo(0, 0)";
//    [webview stringByEvaluatingJavaScriptFromString:js_scrollToTop];
    
    // 禁止用戶選擇
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // 禁止長按彈出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeViewController {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [[[FSDataModelProc sharedInstance] accountManager] isReadyLogin];
}




- (void)goBack {
    
    if (goBackFunction) {
        [self performSelectorOnMainThread:goBackFunction withObject:nil waitUntilDone:NO];
    }
    
    if ([webview canGoBack]) {
        [webview goBack];
    }
    else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
@end
