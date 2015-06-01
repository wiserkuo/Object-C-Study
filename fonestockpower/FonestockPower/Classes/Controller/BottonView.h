//
//  BottonView.h
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/2.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawAndScrollController.h"
#import "Indicator.h"
#import <QuartzCore/QuartzCore.h>
#import "BottomDataView.h"

@class IndexView, RSIView, MACDView, KDView,VolumeView, DrawAndScrollController;

@interface BottonView : UIView <UIScrollViewDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,CustomIOS7AlertViewDelegate> {
    
	UIView *targetView;

    BottomDataView *dataView;
    NSMutableArray *subDataViews;

    UIScrollView *dataScrollView;

    CustomIOS7AlertView *cxAlertView;
    
    NSInteger currentPage;
    NSUInteger subDataViewsIndex;

    int yLines;
    DrawAndScrollController *drawAndScrollController;

    CGRect subViewFrame;
    CGRect subViewChartFrame;
    CGPoint subViewChartFrameOffset;
    CGAffineTransform subViewTransform;

    NSTimeInterval timestamp;

	int indicatorTableNumber; // 0:上面的技術指標圖, 1:下面的技術指標圖.
	Indicator *indicator;
	BottomViewAnalysisType selectedIndicator;
	int selectedIndicatorParameterCount;
	int pickerType; //type 0 : 選擇技術指標 , type 1:選擇技術指標參數
	//int indicatorParameter1;
	//int indicatorParameter2;	
	//int indicatorParameter3;	

	int selectPickerIndex;
    UITableView *tableview;
    BOOL ShowPicker;
    //NSMutableArray *ShowIndex;
    NSInteger cellNumber;

	
	BOOL haveCross;
}

@property (nonatomic) int kNumberOfTables;//( all bottom view indicator)
@property (nonatomic,strong) NSMutableArray *ShowIndex;

@property (nonatomic,strong) UIView *targetView; 

@property (nonatomic,strong) BottomDataView *dataView;
@property (nonatomic,strong) UIScrollView *dataScrollView;
@property (nonatomic,strong) NSMutableArray *subDataViews;

@property (nonatomic) NSUInteger subDataViewsIndex;

@property (nonatomic,strong,setter=setHistoricData:) NSObject<HistoricTickDataSourceProtocol> *historicData;
@property (nonatomic) int yLines;

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,readonly) CGRect subViewChartFrame;
@property (nonatomic,readonly) CGPoint subViewChartFrameOffset;

@property (nonatomic,readwrite) int indicatorTableNumber; // 0:上面的技術指標, 1:下面的技術指標.
@property (nonatomic,strong) Indicator *indicator;
@property (nonatomic,readwrite) BottomViewAnalysisType selectedIndicator;
@property (nonatomic,readwrite) int selectedIndicatorParameterCount;
//@property (nonatomic,readwrite) int indicatorParameter1;
//@property (nonatomic,readwrite) int indicatorParameter2;	
//@property (nonatomic,readwrite) int indicatorParameter3;	

- (void)loadScrollViewPage;
-(void)changeWidth;

- (void)loadWithDefaultPage:(NSInteger)page;

- (void)updateDateRange:(int)xLines chartWidth:(float)width frameX:(float)x frameWidth:(float)frameWidth;

- (void)updateZoomScale:(float)scale andWidth:(float)width;
- (void)postZoomToScale:(float)scale andWidth:(float)width;

- (void)resetTypeControl;

- (void)doTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)doTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event timeInterval:(NSTimeInterval)interval;

- (void)updateValueWithIndex:(int)index;		//畫技術分析值用

- (void)dismissActionSheet;
- (void)openTypeControl:(BOOL)toOpen;
- (void)closeUpperIndicatorPicker;
- (void)selectAnalysisType:(BottomViewAnalysisType)select;

@end


@protocol AnalysisChart

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;
@property (nonatomic, strong) NSObject <HistoricTickDataSourceProtocol> *historicData;
@property (nonatomic, strong) BottonView *bottonView;
@property (nonatomic) CGRect chartFrame;
@property (nonatomic) NSInteger xLines;
@property (nonatomic) NSInteger yLines;
@property (nonatomic) CGAffineTransform zoomTransform;


- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;

@optional

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3;
- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double*)value4;
- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3 Value4:(double*)value4 Value5:(double*)value5 Value6:(double*)value6;

@end
