//
//  RSIView.h
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/13.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"

@class DrawAndScrollController;

@interface RSIView : UIView <AnalysisChart> {
	
    NSObject <HistoricTickDataSourceProtocol> *historicData;

	//controller
	DrawAndScrollController *drawAndScrollController;	
    BottonView *bottonView;

	//chart
	CGRect chartFrame;
	CGPoint chartFrameOffset;
	
	NSInteger xLines;
	NSInteger yLines;	
    float xScale;	
	float yScale;
	int rsiParameter;
    int rsi2Parameter;
	CGPoint currentTouchPosition;


    CGAffineTransform zoomTransform;
}



@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,strong) BottonView *bottonView;

@property (nonatomic,strong) NSObject <HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;	
@property (nonatomic,readwrite) float xScale;	
@property (nonatomic,readwrite) float yScale;

@property (nonatomic,readwrite) CGPoint currentTouchPosition;

@property (nonatomic) CGAffineTransform zoomTransform;



- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;
 
- (NSMutableArray *)rsiValueWithDayParameter:(int)ndays;


-(void)drawLineOnStartPoint:(CGPoint)point1 EndPoint:(CGPoint)point2 Offset:(CGPoint)chartStartPoint withColorIndex:(int)colorIndex;

// 給定門檻percent值 畫percentLine
- (void)drawPercentLineWithThresholdLine:(float)thresholdLine withColorIndex:(int)colorIndex chartFrameOffset:(CGPoint)offsetPoint;

- (UIColor *)viewColorWithIndex:(NSUInteger)index;


@end
