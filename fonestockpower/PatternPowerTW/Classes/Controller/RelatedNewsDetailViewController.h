//
//  RelatedNewsDetailViewController.h
//  WirtsLeg
//
//  Created by Connor on 13/7/1.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Portfolio.h"
#import "RelatedNewsData.h"

@interface RelatedNewsDetailViewController : UIViewController{
    RelatedNewsData *relatedNewsData;
    UILabel *newsTitleLabel;
    UITextView *mainTextView;
    
    UIView *bottomView;
    FSUIButton *previewBtn;
    FSUIButton *nextBtn;
    UILabel *dateLabel;
    UILabel *pageLabel;
}
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, assign) NSInteger titleIndex;
@property (nonatomic, assign) NSInteger newsCount;

@end
