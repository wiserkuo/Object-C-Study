//
//  NewsController.h
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/2.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Portfolio.h"
#import "HistoricDataAgent.h"
#import "CrossLineView.h"
#import "CrossInfoView.h"
#import "DrawAndScrollView.h"
#import "Indicator.h"
#import "IndexScaleView.h"
#import "DataArriveProtocol.h"
#import "HistoricDataTypes.h"

typedef NS_ENUM(NSUInteger, userLineType) {
    TrendLine,
    ParallelLine,
    FibonacciLine,
    TrendlineAngle,
    FibonacciFanLine,
    SpeedResistanceLine,
    FibonacciArc,
    FibonacciRetracement,
    PreviousLines = 99
};


@class arrowData;
@class IndexView,MACDView;
@class UpperView, UpperValueView, UpperDateView, BottonView;
@class DrawAndScrollView;
@class EquityDrawViewController,FSInstantInfoWatchedPortfolio;
@class FSActionPlanDatabase;

@interface DrawAndScrollController : FSUIViewController <HistoricDataArriveProtocol,DataArriveProtocol, UIScrollViewDelegate, UIActionSheetDelegate,CrollInfoProtocol> {
	
    CGFloat BarDateWidth;//k棒寬＋左右空隔
    CGFloat ChartBarWidth;//k棒寬
    CGFloat ChartLineWidth;
    CGFloat ChartWidth;
    CGFloat ChartZoomMax;
    CGFloat ChartZoomOrigin;
    CGFloat LineWidth;
    CGFloat ValueViewWidth;
    CGFloat DateViewHeight;
    CGFloat ChartTop;
    CGFloat ChartButtom; // for upperDateView的高度
    
	Indicator *indicator;
    HistoricDataAgent *historicData;
	
    UpperView *upperView;
    UpperValueView *upperValueView;
    UpperDateView *upperDateView;
    UIScrollView *upperValueScrollView;
    UIScrollView *upperDateScrollView;
	
    BottonView *bottonView1;
    BottonView *bottonView2;
	
	// 技術指標view
	IndexView *indexView;
	IndexScaleView* indexScaleView;
	
    UIScrollView *indexScrollView;
	
    BOOL lastComparing;
    NSMutableArray *lastCompSymbols;
	
	int xLines;
	int yLines;
	
    NSString *equityName;
    PortfolioItem *portfolioItem;
	Portfolio *portfolio;
    NSString *idSymbol;
	BOOL hasArrive;
	
    float theHighestValue;
    float theLowestValue;
    float theHighestVolume;
    float theLowestVolume;
    UInt8 maxVolumeUnit;
	
    UIView *scaleView;
    UIScrollView *scaleScrollView;
    CGFloat baseWidth;
	
    AnalysisPeriod analysisPeriod;
	
    NSDate *chartOldestDate;
    int chartDayCount;
    int chartOldestWeekday;
	
	// cross info view
    //長按線圖之後會出現的十字線
    CrossLineView *crossLineView;
    //直立的資訊框
    CrossInfoView *crossInfoPortrait;
    //橫式的資訊框
    CrossInfoView *crossInfoLandscape;
    CGFloat crossX;	
    BOOL pressTouching;
    NSTimeInterval timestamp;
	
    BOOL forceUpdate;
	
	
	NSArray *watchListRowDataArray;
	NSUInteger watchListRowIndex;
		
	DrawAndScrollView *drawAndScrollView;
	
	BOOL isPushFromWatchListController;
	
    UIActionSheet *functionsSheet; //功能表sheet
	UIActionSheet *periodsTypeSheet; //k線週期
	
	UpperViewIndicator upperViewIndicator;
    UpperViewMainChar pperViewMainChar;
	
	UIView *crossInfoViewUpper;
	
	//push from 總體經濟type
	BOOL isPushFfromMacro;
	
	//資訊地雷
	BOOL isQueryNewsCount;
	BOOL isNeedOpenInformationMine;
	
	BOOL bPaid;
	NSTimer* timer;
	UInt16 preDate;
	UInt16 preTime;
	BOOL transitioning;
	BOOL goUpdate;
    
    BOOL changeSizeFlag;
    
    UIView * noteView;
    UILabel * noteLabel;
    UILabel * notePlaceHolder;
    UITextView * noteTextView;
    UITextView * noteEditTextView;
    FSUIButton * reasonBtn;
    FSUIButton *doneButton;
    FSActionPlanDatabase * actionPlanModel;
}
@property (nonatomic)userLineType lineType;
@property (nonatomic)CGPoint chartFrameOffset;

@property (nonatomic)UInt16 arrowDate;
@property (nonatomic) UInt16 buyDay;
@property (nonatomic) UInt16 sellDay;
@property (strong, nonatomic) NSMutableDictionary * dateDictionary;
@property (strong, nonatomic) NSMutableDictionary * gainDateDictionary;
@property (nonatomic)AnalysisPeriod arrowType;
@property (nonatomic) int arrowUpDownType;//1:Long 2.short 4.交易記錄 5.報酬率
@property (nonatomic) int performanceNum;
@property (strong, nonatomic) NSString * performanceNote;
@property (nonatomic) BOOL status;//YES:Long NO:Short

@property (nonatomic, strong) NSArray * autoLayoutArray;
@property (nonatomic, strong) NSArray * autoLayout;
@property (nonatomic, strong) NSArray * autoLayoutSmall;
@property (nonatomic, strong) NSString * autoLayoutString;
@property (nonatomic)int autoLayoutIndex;
@property (nonatomic)float autoLayoutUpperView;

@property (nonatomic,readonly) HistoricDataAgent *historicData;
@property (nonatomic,strong) HistoricDataAgent *comparedHistoricData;
@property (strong, nonatomic) FSInstantInfoWatchedPortfolio * watchportfolio;

@property (nonatomic, strong) NSString *idSymbol;

@property (nonatomic, strong) UpperView *upperView;
@property (nonatomic, strong) UpperValueView *upperValueView;
@property (nonatomic, strong) UpperDateView *upperDateView;
@property (nonatomic, strong) UIScrollView *upperValueScrollView;
@property (nonatomic, strong) BottonView *bottonView1;
@property (nonatomic, strong) BottonView *bottonView2;
@property (nonatomic, strong) UIView * upperTouchView;
@property (nonatomic, strong) UIView * touchView1;
@property (nonatomic, strong) UIView * touchView2;

@property (nonatomic,strong) IndexView *indexView;
@property (nonatomic,strong) IndexScaleView* indexScaleView;

@property (nonatomic,strong) UIScrollView *indexScrollView;


@property (nonatomic,readwrite) int xLines;
@property (nonatomic,readwrite) int yLines;

@property(nonatomic) BOOL twoLine;
@property(nonatomic) BOOL comparedHasArrive;

@property (nonatomic,strong) NSString *equityName;
@property (nonatomic,strong) PortfolioItem *portfolioItem;
@property (nonatomic, strong) Portfolio *portfolio;

@property (nonatomic, strong) NSDate *chartOldestDate;
@property (nonatomic) float theHighestValue;
@property (nonatomic) float theLowestValue;
@property (nonatomic,readonly) float theHighestVolume;
@property (nonatomic,readonly) float theLowestVolume;
@property (nonatomic,readonly) UInt8 maxVolumeUnit;

@property (nonatomic,assign) AnalysisPeriod analysisPeriod;

@property (nonatomic,readonly) UInt8 historicType;

@property (nonatomic,strong) CrossInfoView *crossInfoPortrait;
@property (nonatomic,strong) CrossInfoView *crossInfoLandscape;
@property (nonatomic) CGFloat crossX;

@property (nonatomic, readonly) CGFloat chartWidth;
@property (nonatomic, readonly) CGFloat chartBarWidth;
@property (nonatomic, readonly) CGFloat ChartLineWidth;
@property (nonatomic, readonly) CGFloat barDateWidth;
@property (nonatomic, readonly) CGFloat chartZoomMax;
@property (nonatomic, readonly) CGFloat chartZoomOrigin;
@property (nonatomic, readonly) CGFloat lineWidth;
@property (nonatomic, readonly) CGFloat bottomChartLineWidth;
@property (nonatomic, readonly) CGFloat bottomViewHeight;

@property (nonatomic,strong)  NSArray *watchListRowDataArray;	// add by mingzhe
@property (nonatomic)  NSUInteger watchListRowIndex; // add by mingzhe

@property (nonatomic,assign) EquityDrawViewController *equityDrawViewController;

@property (nonatomic,strong) DrawAndScrollView *drawAndScrollView;

@property (nonatomic,readwrite) BOOL isPushFromWatchListController;

@property (nonatomic,readwrite) UpperViewIndicator upperViewIndicator;
@property (nonatomic,readwrite) UpperViewMainChar upperViewMainChar;

@property (nonatomic,strong) UIView *crossInfoViewUpper;

@property (nonatomic,readwrite) BOOL isPushFfromMacro;

//資訊地雷
@property (nonatomic,readwrite) BOOL isNeedOpenInformationMine;

@property (nonatomic, strong) UIButton *compareOtherStockButton;
@property (nonatomic, strong) UIButton *intervalSettingButton;
@property (nonatomic, strong) UIButton *kLineParameterButton;
@property (nonatomic, strong) MarqueeLabel * blueStockName;
@property (nonatomic, strong) MarqueeLabel * blueCompareStockName;
@property (nonatomic, strong) UIButton * dayLine;
@property (nonatomic, strong) UIButton * weekLine;
@property (nonatomic, strong) UIButton * monthLine;
@property (nonatomic, strong) UIButton * minLine;
@property (nonatomic, strong) UIButton * rowButton;
@property (nonatomic, strong) UIButton * twoStock;
@property (nonatomic, strong) UIButton * penBtn;
@property (nonatomic, strong) UIButton * eraserBtn;
@property (nonatomic, strong) UIButton * biggerBtn;
@property (nonatomic, strong) UIButton * smallerBtn;
@property (nonatomic, strong) UIButton * changeCompareStockBtn;
//@property (nonatomic, strong) FSPopoverController *kLineParameterPopover;

@property (nonatomic)CGPoint oldPoint;

@property (nonatomic)float pinchNum;

@property (nonatomic, strong) UILabel * upperViewClickLabel;
@property (nonatomic, strong) UILabel * bottomView1ClickLabel;
@property (nonatomic, strong) UILabel * bottomView2ClickLabel;

@property (nonatomic) BOOL upperViewPicker;
@property (nonatomic) BOOL bottonView1Picker;
@property (nonatomic) BOOL bottonView2Picker;

-(NSDate *)setTodayDate; 

- (void)resetDisplay;
- (void)reDisplayIndicators;

- (void)drawChartFrameWithChartOffset:(CGPoint)chartStartPoint frameWidth:(float)frameWidth frameHeight:(float)frameHeight; //畫邊框
- (void)drawBottomChartFrameWithOffset:(CGPoint)offset frameWidth:(float)width frameHeight:(float)height;
- (void)drawChartFrameXScaleWithChartOffset:(CGPoint)chartStartPoint frameWidth:(float)frameWidth frameHeight:(float)frameHeight xLines:(NSInteger)linesOfX xScaleType:(int)type; //畫直線
- (void)drawChartFrameYScaleWithChartOffset:(CGPoint)chartStartPoint frameWidth:(float)frameWidth frameHeight:(float)frameHeight yLines:(NSInteger)linesOfY; //畫橫線
- (void)drawChartFrameYScaleWithChartOffset:(CGPoint)frameOffset frameWidth:(float)width frameHeight:(float)height yLines:(NSInteger)yLines lineIncrement:(int)increment;
- (float)getTheHightestValue;
- (float)getTheLowestValue;
- (float)getTheHightestVolume;
- (float)getTheLowestVolume;


-(int)scaleLocationIndexValueFromDate:(NSDate *)date ordestDate:(NSDate *)ordestDate;

-(void) drawString:(NSString*)string InRect:(CGRect)rect fontName:(NSString*)name fontSize:(CGFloat)size alignment:(NSTextAlignment)alignment;

//取得每月第一天的陣列
- (NSMutableArray *)getMonthArrayFromTodayDate:(NSDate *)today toOldestDate:(NSDate *)oldestDate;

- (void)drawMonthLineWithChartFrame:(CGRect)frame xLines:(NSInteger)lineOfX offsetStartPoint:(CGPoint)offsetStartPoint;
- (void)drawDateGridWithChartFrame:(CGRect)frame xLines:(NSInteger)lineOfX offsetStartPoint:(CGPoint)offsetStartPoint;

- (NSDate *)getOldestDate;

- (DecompressedHistoricData *)copyHistoricData:(UInt8)type ForDate:(NSDate **)date AtSequence:(int *)seq;

- (IBAction)rightNavigationButtonClicked:(id)sender;

- (void)doTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)doTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)openCrossView:(BOOL)toOpen;
- (void)resetCrossView;
- (void)updateUpperView:(int)index;
- (void)hideCrossInfo;

+ (NSCalendar *)sharedGregorianCalendar;
+ (const float *)valueUnitBase;

//for multi-touch
-(void)previousEquityName; 
-(void)nextEquityName; 
-(void)refleshEquityDrawViewControllerEquityData;

-(void)updateCrossView;

-(void)turnOnPaidFunction;

-(BOOL)crossVisible;

- (void)SetTimer;
- (void)ClearTimer;

-(void)drawOver;
//資訊地雷
- (void)openInformationNewsTitleViewControllerByStartDate:(UInt16)startDate endDate:(UInt16)endDate;

-(void)setDefaultValue;

-(void)arrowTapWithArrowData:(arrowData *)arrowData;

-(void)allUserLineRemove;

-(void)rotate;
@end
