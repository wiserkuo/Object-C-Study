//
//  VRView.h
//  Bullseye
//
//  Created by Yehsam on 2009/9/2.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"
@interface VRView : UIView <AnalysisChart>{
	DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
	
    NSObject<HistoricTickDataSourceProtocol> *historicData;
	
	CGRect chartFrame;
	CGPoint chartFrameOffset;
	
	CGFloat maxValue;
    CGFloat minValue;
	
	NSInteger xLines;
	NSInteger yLines;
	int nDayParameter;
	NSMutableArray *vrValues;
	
	CGAffineTransform zoomTransform;
    
    UInt8 type;
	
}

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,strong) BottonView *bottonView;
@property (nonatomic,strong) NSObject<HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;

@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat minValue;


@property (nonatomic) CGAffineTransform zoomTransform;

-(id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;
- (void)drawPercentLineWithThresholdLine:(float)thresholdLine withColorIndex:(int)colorIndex chartFrameOffset:(CGPoint)offsetPoint;
- (void)drawLineOnStartPoint:(CGPoint)point1 EndPoint:(CGPoint)point2 Offset:(CGPoint)chartStartPoint withColorIndex:(int)colorIndex;

- (void)goVR;
- (void)getAVS:(double*)avs BVS:(double*)bvs CVS:(double*)cvs Index:(int)index;

@end
