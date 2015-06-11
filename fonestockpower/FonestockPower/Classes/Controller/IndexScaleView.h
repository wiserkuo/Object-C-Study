//
//  IndexScaleView.h
//  Bullseye
//
//  Created by ilien.liao on 2009/12/31.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TickDataSource.h"
@class DrawAndScrollController;

typedef enum {
	KprepareAction,
	KPainAction,
    KMoveAction
}Action;

@interface IndexScaleView : UIView 
{
	NSObject <HistoricTickDataSourceProtocol> *historicData;
	
	DrawAndScrollController *drawAndScrollController;
	
	NSInteger offsetX;
	NSInteger offsetY;
	 
	NSInteger yLines;	
    float highestValue;
	float lowestValue;
	
	NSMutableDictionary *dateLabelInfoDict;
	NSMutableArray *newsBtnArray;
	id targetView;
    
    NSRecursiveLock * dataLock;
    
    NSMutableArray *objArray;
    
    
    float viewBottom;
    float firstX;
    float lastX;
    
    
    Action ac;
    
    BOOL secParallelLine;
    NSMutableArray * trendLineAngleArray;
    
    NSMutableArray * FibonacciRetracementArray;
    BOOL firstDraw;
}
@property (nonatomic, strong) NSMutableArray *objDataArray;

@property (nonatomic) CGPoint firstTouch;
@property (nonatomic) CGPoint lastTouch;

@property (nonatomic) BOOL drawEnd;
@property (nonatomic, strong) NSMutableArray *drawLinePoints;

@property (nonatomic, readonly) float highestValue;
@property (nonatomic, readonly) float lowestValue;

@property (nonatomic, readonly) float twoStockHighValue;
@property (nonatomic, readonly) float twoStockLowValue;

@property (nonatomic,strong) NSMutableDictionary * pointDictionary;

@property (nonatomic,strong) NSSet *touches;
@property (nonatomic,strong) UIEvent *event;

@property (nonatomic) UInt16 arrowDate;
@property (nonatomic) UInt16 buyDay;
@property (nonatomic) UInt16 sellDay;
@property (nonatomic, strong) NSMutableDictionary * dateDictionary;
@property (nonatomic)AnalysisPeriod arrowType;
@property (nonatomic) int arrowUpDownType;//1:Long 2.short


@property (nonatomic, readwrite) NSInteger offsetX;
@property (nonatomic, readwrite) NSInteger offsetY;
@property (nonatomic,strong) NSObject <HistoricTickDataSourceProtocol> *historicData;
@property (nonatomic,strong) NSObject <HistoricTickDataSourceProtocol> *comparedHistoricData;
@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;
@property (nonatomic,readwrite) NSInteger yLines;
@property (nonatomic,strong) NSMutableArray * compArray;
@property (nonatomic,strong) NSMutableDictionary * compDictionary;
@property (nonatomic,strong) NSMutableDictionary * compVolumeDictionary;

-(BOOL)getHigestAndLowest;

-(void)changeNote:(NSString *)note Key:(NSNumber *)key arrowType:(int)type;
-(void)changReason:(NSString *)reason Key:(NSNumber *)key;

@end

@interface Line : NSObject
@property (nonatomic, unsafe_unretained) CGPoint pointA;
@property (nonatomic, unsafe_unretained) CGPoint pointB;
@property (nonatomic, unsafe_unretained) int lineNum;
@property (nonatomic, unsafe_unretained) int lineType;
@end
