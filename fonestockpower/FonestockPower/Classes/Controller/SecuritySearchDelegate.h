//
//  SecuritySearchDelegate.h
//  WirtsLeg
//
//  Created by Neil on 13/9/17.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomBtnInScrollView;
@class BtnCollectionView;

@protocol SecuritySearchDelegate <NSObject>
@optional
- (void)titleButtonClick:(FSUIButton *)button Object:(CustomBtnInScrollView *)scrl;
- (void)groupButtonClick:(FSUIButton *)button Object:(BtnCollectionView *)scrl;
-(void)goToWatchListWithSymbol:(NSString *)symbol;
- (void)titleButtonClick:(FSUIButton *)button;
-(void)buttonPan:(UILongPressGestureRecognizer *)sender;
-(void)navigationPop;
-(void)backToList;

-(void)changeStockWithPortfolioItem:(PortfolioItem *)item;
@end

