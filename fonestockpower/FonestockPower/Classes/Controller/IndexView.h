//
//  IndexView.h
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/13.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TickDataSource.h"
@class DrawAndScrollController;


@interface IndexView : UIView {

    NSObject <HistoricTickDataSourceProtocol> *historicData;

	DrawAndScrollController *drawAndScrollController;

	CGRect chartFrame;
	CGPoint chartFrameOffset;
    CGAffineTransform zoomTransform;

	NSInteger xLines;
	NSInteger yLines;	
    float xScale;	
	float yScale;

    NSMutableArray *historicDataIndexes;

    NSMutableArray *tmpArray1;
    NSMutableArray *tmpArray2;
    NSMutableArray *tmpArray3;
    NSMutableArray *tmpArray4;
    NSMutableArray *tmpArray5;
    NSMutableArray *tmpArray6;
	NSMutableArray *newSBtnArray;

    float compHighScale;
    float compLowScale;
	
	NSInteger baseIndex;
	int refIndex[6];
    
    NSRecursiveLock * dataLock;
}

@property (nonatomic,strong) NSObject <HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;
@property (nonatomic) CGAffineTransform zoomTransform;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;	
@property (nonatomic,readwrite) float xScale;	
@property (nonatomic,readwrite) float yScale;

@property (nonatomic, strong) NSMutableArray *historicDataIndexes;
@property (nonatomic, readonly) float compHighScale;
@property (nonatomic, readonly) float compLowScale;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;

- (CGFloat)comparisonYfromPrice:(float)price;

-(void)drawLineOnStartPoint:(CGPoint)point1 EndPoint:(CGPoint)point2 Offset:(CGPoint)diagramAxisCenter;

-(BOOL)prepareDataToDraw;
- (double)getMovingAvergeValueFrom:(int)index parm:(int)maType; // MA
- (double)getBollingerFrom:(int)index parm:(int)maType; // BB
//- (void)drawInformationMineBtnFrom:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate; //Information Mine

- (void)drawMovingAverageWithBollingerParmFrom:(int)startIndex to:(int)endIndex oldestDate:(NSDate *)oldestDate;

- (void)setBaseIndex:(NSInteger)index;

@end
