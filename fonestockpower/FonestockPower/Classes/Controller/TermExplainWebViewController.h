//
//  TermExplainWebViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/11/22.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TermExplainWebViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView * webView;

@property (strong ,nonatomic)NSString * webUrl;

- (id)initWithWebUrl:(NSString *)url;

@end
