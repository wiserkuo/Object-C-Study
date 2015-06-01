//
//  FSEquityDrawButtonSection.h
//  WirtsLeg
//
//  Created by KevinShen on 2014/2/5.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSEquityDrawButtonSectionDelegate.h"
#import "MarqueeLabel.h"

@interface FSEquityDrawButtonSection : UIScrollView<UIActionSheetDelegate>

@property (nonatomic, weak) NSObject<FSEquityDrawButtonSectionDelegate, UIScrollViewDelegate> *delegate;
@property (nonatomic, strong) UIButton *compareOtherPortfoioButton;
@property (nonatomic, strong) FSUIButton *selectComparePortfoioButton;
@property (nonatomic, strong) FSUIButton *fitPriceGraphScopeButton;
@property (nonatomic, strong) FSUIButton *drawCDPButton;
@property (nonatomic, strong) FSUIButton *drawAverageLineButton;
@property (nonatomic, strong) UIButton *addUserStockButton;
@property (nonatomic, strong) NSMutableArray *dataIdArray;
@property (nonatomic, strong) NSMutableArray *categoryArray;
@property (nonatomic, strong) MarqueeLabel *selectComparePortfoioLabel;

-(void)hideAddUserStockBtn;
-(void)compareBtnClick;


@end
