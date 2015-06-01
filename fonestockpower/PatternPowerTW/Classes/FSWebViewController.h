//
//  FSWebViewController.h
//  FonestockPower
//
//  Created by Connor on 2015/1/5.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSUIViewController.h"
#import "FSURLParser.h"

@interface FSWebViewController : FSUIViewController <UIWebViewDelegate> {
    UIWebView *webview;
    NSString *currentPageURL;
    MBProgressHUD *hud;
}
@end
