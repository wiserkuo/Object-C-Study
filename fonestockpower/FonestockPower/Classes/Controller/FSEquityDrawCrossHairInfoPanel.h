//
//  FSEquityDrawCrossHairInfoPanel.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSEquityDrawCrossHairInfo;

@interface FSEquityDrawCrossHairInfoPanel : UIView

@property (nonatomic, strong) UILabel *bidTitleLabel;
@property (nonatomic, strong) UILabel *bidContentLabel;

@property (nonatomic, strong) UILabel *askTitleLabel;
@property (nonatomic, strong) UILabel *askContentLabel;

@property (nonatomic, strong) UILabel *lastPriceTitleLabel;
@property (nonatomic, strong) UILabel *lastPriceContentLabel;

@property (nonatomic, strong) UILabel *changeTitleLabel;
@property (nonatomic, strong) UILabel *changeContentLabel;

@property (nonatomic, strong) UILabel *volTitleLabel;
@property (nonatomic, strong) UILabel *volContentLabel;

@property (nonatomic, strong) UILabel *comparedPriceTitleLabel;
@property (nonatomic, strong) UILabel *comparedPriceContentLabel;

@property (nonatomic, strong) UILabel *comparedVolTitleLabel;
@property (nonatomic, strong) UILabel *comparedVolContentLabel;

@property (nonatomic, strong) UILabel *timeTitleLabel;//時間標題
@property (nonatomic, strong) UILabel *timeContentLabel;//時間內容


@property (nonatomic, strong) UILabel *newsLabel;//相關新聞
@property (nonatomic, assign) BOOL warrantFlag;

@property (nonatomic, assign) BOOL comparedMode;

- (void)updateTime:(UInt16) time openTime:(UInt16) openTime;
- (void)updateTimeNoTick;
- (void)updatePanelWithInfo:(FSEquityDrawCrossHairInfo *) crossHairInfo referencePrice:(NSNumber *) referencePrice comparedReferencePriceNumber:(NSNumber *) comparedReferencePriceNumber;
- (void)updatePanelWithColorInfo:(FSEquityDrawCrossHairInfo *) crossHairInfo referencePrice:(NSNumber *) referencePrice comparedReferencePriceNumber:(NSNumber *) comparedReferencePriceNumber;
-(void)setLayout;
- (id)initWithFrameByWarrant:(CGRect)frame;

@end
