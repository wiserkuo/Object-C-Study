//
//  KDJView.h
//  Bullseye
//
//  Created by Yehsam on 2009/9/1.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"

@class DrawAndScrollController;

@interface KDJView : UIView <AnalysisChart> {
	
	DrawAndScrollController *drawAndScrollController;	
    BottonView *bottonView;
	
    NSObject<HistoricTickDataSourceProtocol> *historicData;
	
	CGRect chartFrame;
	CGPoint chartFrameOffset;
	
	NSInteger xLines;
	NSInteger yLines;
    float xScale;	
	float yScale;	
	int kdParameter;	
	int kExponentialSmoothing;
	int dExponentialSmoothing;	
	int theKDJMaxValue;
	int theKDJMinValue;
	
    CGAffineTransform zoomTransform;
	NSMutableDictionary *KDdictionary;
    
    UInt8 type;
}

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,strong) BottonView *bottonView;

@property (nonatomic,strong) NSObject<HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;	
@property (nonatomic,readwrite) float xScale;	
@property (nonatomic,readwrite) float yScale;

@property (nonatomic,strong) NSMutableDictionary *KDdictionary;


@property (nonatomic) CGAffineTransform zoomTransform;



- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;


- (NSMutableDictionary *)KDindexWithParameter:(int)nDays kExponentialSmoothing:(int)kExponentialSmoothing dExponentialSmoothing:(int)dExponentialSmoothing;

- (UIColor *)viewColorWithIndex:(NSUInteger)index;
-(void)drawLineOnStartPoint:(CGPoint)point1 EndPoint:(CGPoint)point2 Offset:(CGPoint)chartStartPoint withColorIndex:(int)colorIndex;
- (void)drawPercentLineWithThresholdLine:(float)thresholdLine withColorIndex:(int)colorIndex chartFrameOffset:(CGPoint)offsetPoint;
- (float)maxValue;
- (float)minValue;

@end
