//
//  MACDView.h
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/13.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"

@class DrawAndScrollController;
@class BottonView;

@interface MACDView : UIView <AnalysisChart> {

	DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;

    NSObject<HistoricTickDataSourceProtocol> *historicData;

	CGRect chartFrame;
	CGPoint chartFrameOffset;

	NSInteger xLines;
	NSInteger yLines;
	int shortEMAParameter;
	int longEMAParameter;
	int macdParameter;

    float maxValue;

    CGAffineTransform zoomTransform;
	
	NSMutableArray *diffEMA;
	NSMutableArray *macd;
}

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,strong) BottonView *bottonView;

@property (nonatomic,strong) NSObject<HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;	

@property (nonatomic,readonly) float maxValue;

@property (nonatomic) CGAffineTransform zoomTransform;

@property (nonatomic,strong) NSMutableArray *diffEMA;
@property (nonatomic,strong) NSMutableArray *macd;



-(id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;

-(NSMutableArray *)diffEMAWithDataRange:(int)totalDayCnt emaParameter1:(int)p1 emaParameter2:(int)p2;
-(NSMutableArray *)macdWithGivenArray:(NSMutableArray *)emaArray hDays:(int)days emaParameter:(int)emaParameter;

// 計算 Demand Index 價格需求指數 (取t天)
-(float)demandIndexOnGivenDataIndex:(int)dataIndex type:(UInt8)type;

@end
