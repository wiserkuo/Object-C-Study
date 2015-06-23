//
//  NewsController.m
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/2.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import "DrawAndScrollController.h"
#import "IndexView.h"
#import "UpperView.h"
#import "UpperValueView.h"
#import "UpperDateView.h"
#import "BottonView.h"
#import "ValueUtil.h"
#import "EquityHistory.h"
#import "FSUIButton.h"
#import "SettingIndicatorsViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "ChangeStockViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "FSTeachPopView.h"
#import "FSActionPlanDatabase.h"
#import "UIView+HUD.h"
#import "FSPositionViewController.h"
#import "FSActionSheetCell.h"
#import "FigureSearchCheckBoxTableViewCell.h"
#import "FigureSearchCollectionViewCell.h"
#import "FSTechModel.h"
#import "MarqueeLabel.h"
#import "UIViewController+CustomNavigationBar.h"
#import "ExplanationViewController.h"
#import "FSBrokerParametersViewController.h"
#define indicatorNumberOfTables 12
#define IS_IPAD [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound

static NSCalendar *gCalendar;


@interface DrawAndScrollController()<FSTeachPopDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate,CustomIOS7AlertViewDelegate>{
    int section0CellNumber;
    int section1CellNumber;
    int section2CellNumber;
    int section3CellNumber;
    BOOL indicator0Show;
    BOOL indicator1Show;
    BOOL indicator2Show;
    BOOL indicator3Show;
    UITableView * actionTableView;
    NSMutableArray * figureSearchArray;
    NSMutableArray *showIndex;
    
    arrowData * nowArrowData;
    
    NSMutableArray * selectArray;
    NSMutableArray * numberArray;
    NSMutableArray * imgArray;
    
    UICollectionView *collectionView;
    
    NSMutableArray * drawLineTitleArray;
    UIActionSheet * drawLineActionSheet;
    
    NSMutableArray * eraserTitleArray;
    UIActionSheet * eraserActionSheet;
    
    UIActionSheet *parameterSheet;
    FSTechModel * techModel;
    
    FSUIButton * stockButton;
    MarqueeLabel * changeStockNameLabel;
    
    UILabel * changeStockSymbolLabel;
    
    CustomIOS7AlertView * cxAlertView;
    
    BOOL whetherCustomAlertIsOpen;
    NSMutableArray *newDataArray;
}

@property (nonatomic)float upperHight;
@property (nonatomic)float bottomHight;

@property (nonatomic) BOOL firstIn;
@property (nonatomic) BOOL first;
@property (nonatomic, strong) UIView *scaleView;
@property (nonatomic, strong) UIScrollView *scaleScrollView;
@property (nonatomic, strong) CrossLineView *crossLineView;
@property (nonatomic, strong) UIScrollView *upperDateScrollView;
@property (nonatomic, readonly) CrossInfoView *crossInfoView;
@property (nonatomic, assign) UIInterfaceOrientation newOrientation;
@property(nonatomic ,strong)FSDataModelProc * dataModal;
@property (strong, nonatomic) FSTeachPopView * explainView;
@property (strong, nonatomic) FSUIButton * checkBtn;
@property (strong, nonatomic) FigureSearchMyProfileModel *figureSearchMyProfileModel;
@property (strong, nonatomic)NSString * LandscapeString;

- (void)resetZoomTransform;
- (void)zoomToMinScale;
- (void)updateDateRange;
- (NSString *)titleForAnalysisPeriod:(AnalysisPeriod)period;

@end

@implementation DrawAndScrollController
@synthesize historicData;
@synthesize upperView; //upperView擺 indexView
@synthesize upperValueView;
@synthesize upperValueScrollView;
@synthesize upperDateView;
@synthesize upperDateScrollView;
@synthesize bottonView1; //bottonView先擺一個ScrollView
@synthesize bottonView2; //bottonView先擺一個ScrollView

@synthesize indexView,indexScaleView;
@synthesize indexScrollView;


@synthesize xLines,yLines;

@synthesize equityName;
@synthesize portfolioItem;
@synthesize portfolio;
@synthesize idSymbol;

@synthesize theHighestValue;
@synthesize theLowestValue;
@synthesize theHighestVolume;
@synthesize theLowestVolume;
@synthesize maxVolumeUnit;

@synthesize analysisPeriod;
@synthesize chartOldestDate;

@synthesize crossInfoPortrait;
@synthesize crossInfoLandscape;
@synthesize crossLineView;
@synthesize crossX;

@synthesize scaleView;
@synthesize scaleScrollView;

@synthesize watchListRowDataArray;
@synthesize watchListRowIndex;
@synthesize equityDrawViewController;

@synthesize drawAndScrollView;

@synthesize isPushFromWatchListController;

@synthesize upperViewIndicator;
@synthesize upperViewMainChar;

@synthesize crossInfoViewUpper;

@dynamic chartWidth, chartBarWidth, chartZoomMax, chartZoomOrigin, bottomChartLineWidth,lineWidth;
@dynamic historicType;

@synthesize isPushFfromMacro;

@synthesize isNeedOpenInformationMine;

+ (void)initialize
{
	
    if (self == [DrawAndScrollController class])
        gCalendar = [ValueUtil sharedGregorianCalendar];
}


+ (NSCalendar *)sharedGregorianCalendar
{
	
    return gCalendar;
}


+ (const float *)valueUnitBase 
{
	
    return valueUnitBase;
}


/*
 Implement loadView if you want to create a view hierarchy programmatically
 - (void)loadView {
 }
 */


- (CGFloat)chartWidth 
{
    return ChartWidth;
}

/*
 - (CGFloat)barWidthRatio {
 return BarWidthRatio;
 }
 */

- (CGFloat)chartBarWidth 
{
    return ChartBarWidth * ChartZoomOrigin;
}

- (CGFloat)barDateWidth
{
	return BarDateWidth;
}

- (CGFloat)chartZoomMax
{
    return ChartZoomMax;
}


- (CGFloat)chartZoomOrigin 
{
    return ChartZoomOrigin;
}


- (CGFloat)bottomChartLineWidth 
{
    return 1;//下方圖之線條寬度
}

-(CGFloat)lineWidth{
    return LineWidth;
}

-(CGFloat)ChartLineWidth{
    return ChartLineWidth;
}


- (UInt8)historicType 
{
	
	if(isPushFfromMacro)
	{
		//總體經濟用月線
		return [HistoricDataAgent tickTypeForAnalysisPeriod:AnalysisPeriodMonth];
	}
	else
	{
		return [HistoricDataAgent tickTypeForAnalysisPeriod:analysisPeriod];
	}
    
}


- (void)viewDidLoad{
    [self setUpImageBackButton];
    actionPlanModel = [FSActionPlanDatabase sharedInstances];
    historicData = [[HistoricDataAgent alloc] init];
    _comparedHistoricData = [[HistoricDataAgent alloc]init];;
    _dataModal = [FSDataModelProc sharedInstance];
    techModel = [[FSTechModel alloc]init];
    figureSearchArray = [[NSMutableArray alloc]init];
    selectArray = [[NSMutableArray alloc]init];
    numberArray = [[NSMutableArray alloc]init];
    imgArray = [[NSMutableArray alloc]init];
    showIndex = [[NSMutableArray alloc]init];
    figureSearchArray = [[_dataModal actionPlanModel]figureSearchArray];
    self.figureSearchMyProfileModel = [FigureSearchMyProfileModel sharedInstance];
    BarDateWidth = _dataModal.indicator.techViewBarWidth+1;//k棒寬＋左右空隔
    ChartBarWidth = _dataModal.indicator.techViewBarWidth;//k棒寬 （預設為3）
    ChartLineWidth = 1.0;
    ChartWidth = 275.0;
    ChartZoomMax = 4.0;
    ChartZoomOrigin = 1.0;
    LineWidth = 1.0;
    ValueViewWidth = 47.0;
    DateViewHeight = 14.0;
    ChartTop = 15.0;
    ChartButtom = 15.0; // for upperDateView的高度
    _firstIn = YES;
    _first = YES;

    
    [self prePareDrawLineData];
    
    self.autoLayout = [[NSArray alloc]initWithObjects:[NSNumber numberWithFloat:0.485],[NSNumber numberWithFloat:0.66],[NSNumber numberWithFloat:0.825], nil];
    self.autoLayoutSmall = [[NSArray alloc]initWithObjects:[NSNumber numberWithFloat:0.475],[NSNumber numberWithFloat:0.635],[NSNumber numberWithFloat:0.79], nil];
    self.autoLayoutArray = [[NSArray alloc]initWithObjects:@"V:|[_dayLine(44)][_twoStock(44)][upperView][bottonView1][bottonView2(==bottonView1)]|",@"V:|[_dayLine(44)][_twoStock(44)][upperView][bottonView1]|",@"V:|[_dayLine(44)][_twoStock(44)][upperView]", nil];
    _autoLayoutIndex = 0;
    _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:0]floatValue];
    _autoLayoutString =[_autoLayoutArray objectAtIndex:0];;
	_upperHight = self.view.frame.size.height*0.5;
    _bottomHight = self.view.frame.size.height*0.20;
    if(self.view.frame.size.width < self.view.frame.size.height){
        _bottomViewHeight =self.view.frame.size.height*0.20-30;
    }else{
        _bottomViewHeight = self.view.frame.size.height * 0.25;
    }
    

	indicator = _dataModal.indicator;

    _dataModal.operationalIndicator.drawAndScrollController = self;

	self.watchportfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    portfolioItem = _watchportfolio.portfolioItem;

//	if(isPushFfromMacro)
//		analysisPeriod = AnalysisPeriodMonth;
//	else
//		analysisPeriod = AnalysisPeriodDay;
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
    NSString *fileName = @"TechViewDefaultIndicator.plist";
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSMutableDictionary *techViewInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];

	hasArrive = NO;
    _comparedHasArrive = NO;
    if (_arrowUpDownType == 4 || _arrowUpDownType == 5){
        _twoLine =NO;
    }else{
        _twoLine =[(NSNumber *)[techViewInfo objectForKey:@"stockCompareValue"]intValue];
    }
    
//	NSString *title = NSLocalizedStringFromTable(@"Menu", @"Draw", @"The right navigation button of the realtime chart");
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(rightNavigationButtonClicked:)];
//    self.navigationItem.rightBarButtonItem = item;
	
	yLines = 8;//將下方圖分成4等分
	
    id view = [[UIScrollView alloc] init];
    self.scaleScrollView = view;
	
    scaleScrollView.delegate = self;
    
    CGRect upperBounds = CGRectMake(0, 0,  self.view.frame.size.width*0.87,  self.view.frame.size.height*_autoLayoutUpperView-30);// upperView.bounds;
	
	CGRect frameRect = CGRectMake(upperBounds.origin.x+1, upperBounds.origin.y+ChartTop, ChartWidth, upperBounds.size.height-(ChartTop+ChartButtom));
    CGRect chartRect = CGRectMake(1, 1, frameRect.size.width, upperBounds.size.height-(ChartTop+ChartButtom));
	
    chartRect.origin.x *= ChartZoomOrigin;
    chartRect.origin.y *= ChartZoomOrigin;
    chartRect.size.height *= ChartZoomOrigin;
	
    view = [[UIScrollView alloc] initWithFrame:frameRect];
    self.indexScrollView = view;
    self.indexScrollView.backgroundColor = [UIColor clearColor];
	
    view = [[IndexView alloc] initWithChartFrame:CGRectMake(0, 1, chartRect.size.width, chartRect.size.height) chartFrameOffset:chartRect.origin];
    self.indexView = view;
    
    indexView.frame = CGRectMake(0, 0, frameRect.size.width, (frameRect.size.height+2)*ChartZoomOrigin);
    indexView.drawAndScrollController = self;
    indexView.backgroundColor = [UIColor clearColor];
   
	view = [[IndexScaleView alloc] initWithFrame:CGRectMake(0, 0, frameRect.size.width, frameRect.size.height+1)];
	self.indexScaleView = view;
	self.indexScaleView.drawAndScrollController = self;
	self.indexScaleView.offsetX = 1;
	self.indexScaleView.offsetY = 1;
	indexScaleView.yLines = 6;
    indexScaleView.arrowDate = _arrowDate;
    indexScaleView.dateDictionary = _dateDictionary;
    indexScaleView.buyDay = _buyDay;
    indexScaleView.sellDay = _sellDay;
    indexScaleView.arrowType = _arrowType;
    indexScaleView.arrowUpDownType = _arrowUpDownType;
    self.indexScaleView.userInteractionEnabled = YES;
	//indexScaleView.alpha = 0.5;
	//indexScaleView.backgroundColor = [UIColor lightGrayColor];
    UIPinchGestureRecognizer * pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handPinch:)];
    [self.indexScaleView addGestureRecognizer:pinch];
    
    indexScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    indexScrollView.clipsToBounds = YES;
    indexScrollView.contentInset = UIEdgeInsetsMake(-1, -1, -1, -1);
    indexScrollView.delegate = self;
    indexScrollView.minimumZoomScale = 1;
    indexScrollView.maximumZoomScale = 1;
	
    CGFloat x = upperBounds.origin.x + ChartWidth + 2;
	
    view = [[UIScrollView alloc] initWithFrame:CGRectMake(x, upperBounds.origin.y+2, self.view.frame.size.width-x-1, upperBounds.size.height-3)];
    self.upperValueScrollView = view;
	
    CGRect r = upperValueScrollView.frame;
    r.size.height = (r.size.height + 1) * ChartZoomOrigin;
    view = [[UpperValueView alloc] initWithFrame:r];
    self.upperValueView = view;
	
    CGFloat y = frameRect.origin.y + frameRect.size.height + 1;
	
    view = [[UIScrollView alloc] initWithFrame:CGRectMake(frameRect.origin.x, y, frameRect.size.width, upperBounds.size.height-y-1)];
    self.upperDateScrollView = view;
	
    r = upperDateScrollView.bounds;
    r.size.width += 2;
    view = [[UpperDateView alloc] initWithFrame:r];
    self.upperDateView = view;
    
    upperView = [[UpperView alloc]init];
    [self.view addSubview:upperView];
    bottonView1 = [[BottonView alloc]init];
    bottonView1.drawAndScrollController = self;
    [self.view addSubview:bottonView1];
    bottonView2 = [[BottonView alloc]init];
    bottonView2.drawAndScrollController = self;
    [self.view addSubview:bottonView2];
    
    if (_arrowUpDownType == 5) {
        bottonView1.kNumberOfTables = 15;
        bottonView2.kNumberOfTables = 15;
    }else{
        bottonView1.kNumberOfTables = 14;
        bottonView2.kNumberOfTables = 14;
    }
	
    upperView.drawAndScrollController = self;
    upperValueView.drawAndScrollController = self;
    upperDateView.drawAndScrollController = self;
	drawAndScrollView.drawAndScrollController = self;

	//預設資訊指標
	upperViewIndicator = indicator.UpperViewDayIndicator;
    upperViewMainChar = indicator.upperViewDayMainChart;
	
	upperView.backgroundColor = [UIColor clearColor];
    upperValueView.backgroundColor = [UIColor clearColor];
    upperDateView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor  = [UIColor clearColor];

	
    upperValueScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    upperValueScrollView.showsHorizontalScrollIndicator = NO;
    upperValueScrollView.directionalLockEnabled = YES;
    upperValueScrollView.contentInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    upperValueScrollView.delegate = self;
    upperValueScrollView.minimumZoomScale = ChartZoomOrigin;
    upperValueScrollView.maximumZoomScale = 1;
	
    upperDateScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    upperDateScrollView.showsVerticalScrollIndicator = NO;
    upperDateScrollView.directionalLockEnabled = YES;
    upperDateScrollView.contentInset = UIEdgeInsetsMake(0, -1, 0, -1);
    upperDateScrollView.delegate = self;
    upperDateScrollView.minimumZoomScale = ChartZoomOrigin;
    upperDateScrollView.maximumZoomScale = 1;

    [upperView addSubview:upperValueScrollView];
    [upperValueScrollView addSubview:upperValueView];
	upperDateScrollView.bounces = NO;
    [upperView addSubview:upperDateScrollView];
    [upperDateScrollView addSubview:upperDateView];
	indexScrollView.bounces = NO;
	[upperView addSubview:indexScrollView];
	[indexScrollView addSubview:indexView];
	[indexScrollView addSubview:indexScaleView];

    
    self.indexScaleView.backgroundColor = [UIColor clearColor];
    //self.indexView.backgroundColor = [UIColor clearColor];
	self.indexView.backgroundColor = [UIColor clearColor];

	//預設技術指標
    [bottonView1 loadWithDefaultPage:indicator.bottomView1Indicator];
    [bottonView2 loadWithDefaultPage:indicator.bottomView2Indicator];


    CGRect crossRect = [indexScrollView convertRect:indexScrollView.bounds toView:self.view];
    crossRect.size.width++;
    crossRect.size.height = self.view.bounds.size.height - crossRect.origin.y - 1;
    view = [[CrossLineView alloc] initWithFrame:crossRect];
    self.crossLineView = view;
    crossLineView.backgroundColor = [UIColor clearColor];
	
    [self.view addSubview:crossLineView];
	
    [historicData.dataArray removeAllObjects];

    indexView.yLines = 6;
    bottonView1.yLines = yLines;
    bottonView2.yLines = yLines;

    [bottonView1 loadScrollViewPage];
    [bottonView2 loadScrollViewPage];

    [self updateDateRange];

	drawAndScrollView.frame = self.view.bounds;
    
    portfolio = _dataModal.portfolioData;
    
    crossInfoPortrait = [[CrossInfoView alloc]init];
    //crossInfoLandscape = [[CrossInfoView alloc]init];
    [self.view addSubview:crossInfoPortrait];
    //[self.view addSubview:crossInfoLandscape];
	crossInfoPortrait.viewController = self;

	[crossInfoPortrait setTitleStringWithType:1 realtimeOrHistoric:1]; //直式title
	crossInfoPortrait.portraitFlag = YES;
	//[crossInfoLandscape setTitleStringWithType:1 realtimeOrHistoric:1]; //橫式title
//	[self hideCrossInfo];
	//資訊地雷
	isNeedOpenInformationMine = YES;
	
	self.view.multipleTouchEnabled = NO;
	self.upperView.multipleTouchEnabled = NO;
    self.upperValueView.multipleTouchEnabled = NO;
    self.upperDateView.multipleTouchEnabled = NO;
    self.upperValueScrollView.multipleTouchEnabled = NO;
    self.upperDateScrollView.multipleTouchEnabled = NO;
	
	self.bottonView1.multipleTouchEnabled = NO;
    self.bottonView2.multipleTouchEnabled = NO;
	
	self.indexView.multipleTouchEnabled = NO;
	self.indexScaleView.multipleTouchEnabled = NO;
	
    self.indexScrollView.multipleTouchEnabled = NO;
	
	self.scaleView.multipleTouchEnabled = NO;
    
    [self setupActionButtons];
//    [self.view addSubview:_compareOtherStockButton];
//    [self.view addSubview:_intervalSettingButton];
    [self.view addSubview:_kLineParameterButton];
    [self.view addSubview:_blueStockName];
    [self.view addSubview:_blueCompareStockName];
    [self.view addSubview:_dayLine];
    [self.view addSubview:_weekLine];
    [self.view addSubview:_monthLine];
    [self.view addSubview:_minLine];
    [self.view addSubview:_rowButton];
    [self.view addSubview:_twoStock];
    [self.view addSubview:_penBtn];
    [self.view addSubview:_eraserBtn];
    [self.view addSubview:_biggerBtn];
    [self.view addSubview:_smallerBtn];
    [self.view addSubview:_changeCompareStockBtn];
    
    [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"",@"Draw",nil)];
    
//    self.drawingView = [[DrawView alloc] init];
//    self.drawingView.backgroundColor = [UIColor clearColor];
////    self.drawingView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.drawingView.userInteractionEnabled = NO;
//    [self.view addSubview:self.drawingView];
    
    //說明畫面
    
    NSString * show = [_figureSearchMyProfileModel searchInstructionByControllerName:[[self class] description]];
    if ([show isEqualToString:@"YES"]) {
        [self teachPop];
        _checkBtn.selected = NO;
    }
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 330)];
    customView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap)];
    customView.userInteractionEnabled = YES;
    [customView addGestureRecognizer:tap];
    
   
    doneButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    doneButton.frame = CGRectMake([[UIScreen mainScreen]bounds].size.width - 70, 300, 70, 30);
    [doneButton setTitle:NSLocalizedStringFromTable(@"確認", @"Draw", nil) forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:doneButton];
    
    noteView = [[UIView alloc]init];
    noteView.translatesAutoresizingMaskIntoConstraints = NO;
    noteView.backgroundColor = [UIColor whiteColor];
    noteView.layer.borderColor = [UIColor blackColor].CGColor;
    noteView.layer.borderWidth = 0.5;
    [noteView setBackgroundColor:[UIColor brownColor]];
    [self.view addSubview:noteView];
    
    noteTextView = [[UITextView alloc]init];
    noteTextView.translatesAutoresizingMaskIntoConstraints = NO;
    noteTextView.editable = YES;
    noteTextView.inputAccessoryView = customView;
    noteTextView.text = _performanceNote;
    noteTextView.delegate = self;
    noteTextView.font = [UIFont systemFontOfSize:18.0f];
    noteTextView.backgroundColor = [UIColor whiteColor];
    noteTextView.layer.borderColor = [UIColor blackColor].CGColor;
    noteTextView.layer.borderWidth = 0.5;
    [noteView addSubview:noteTextView];
    
    noteEditTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 240, [[UIScreen mainScreen]bounds].size.width-70, 90)];
    noteEditTextView.editable = YES;
    noteEditTextView.text = _performanceNote;
    noteEditTextView.delegate = self;
    noteEditTextView.font = [UIFont systemFontOfSize:18.0f];
    noteEditTextView.backgroundColor = [UIColor whiteColor];
    noteEditTextView.layer.borderColor = [UIColor blackColor].CGColor;
    noteEditTextView.layer.borderWidth = 0.5;
    [customView addSubview:noteEditTextView];

    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(25, 25);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 1;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
    layout.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[FigureSearchCollectionViewCell class] forCellWithReuseIdentifier:@"FigureSearchItemIdentifier"];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.bounces = NO;
    collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [noteView addSubview:collectionView];

    reasonBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    reasonBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [reasonBtn addTarget:self action:@selector(arrowBtnClick) forControlEvents:UIControlEventTouchUpInside];
    reasonBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [reasonBtn setTitle:NSLocalizedStringFromTable(@"訊號", @"Draw", nil) forState:UIControlStateNormal];
    [noteView addSubview:reasonBtn];

    noteLabel = [[UILabel alloc]init];
    noteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    noteLabel.numberOfLines = 2;
    noteLabel.font = [UIFont systemFontOfSize:12.0f];
    [noteView addSubview:noteLabel];
    
    notePlaceHolder = [[UILabel alloc]init];
    notePlaceHolder.translatesAutoresizingMaskIntoConstraints = NO;
    notePlaceHolder.userInteractionEnabled = NO;
    notePlaceHolder.text = NSLocalizedStringFromTable(@"請輸入此筆交易買賣的原因", @"Draw", nil);
    notePlaceHolder.font = [UIFont systemFontOfSize:14.0f];
    notePlaceHolder.textColor = [UIColor grayColor];
    [noteView addSubview:notePlaceHolder];
    
    if(![noteTextView.text isEqualToString:@""]){
        notePlaceHolder.hidden = YES;
    }else{
        notePlaceHolder.hidden = NO;
    }
    
    stockButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeFocusButton];
    stockButton.selected = YES;
    stockButton.userInteractionEnabled = NO;
    stockButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stockButton];
    
    changeStockNameLabel = [[MarqueeLabel alloc]init];
    changeStockNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [changeStockNameLabel setLabelize:NO];
    changeStockNameLabel.marqueeType = 4;
    changeStockNameLabel.continuousMarqueeExtraBuffer = 30.0f;
    changeStockNameLabel.backgroundColor = [UIColor clearColor];
    changeStockNameLabel.textColor = [UIColor whiteColor];
    changeStockNameLabel.textAlignment = NSTextAlignmentCenter;
    changeStockNameLabel.font = [UIFont systemFontOfSize:16.0f];
    
    changeStockSymbolLabel = [[UILabel alloc]init];
    changeStockSymbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
    changeStockSymbolLabel.backgroundColor = [UIColor clearColor];
    changeStockSymbolLabel.textColor = [UIColor whiteColor];
    changeStockSymbolLabel.font = [UIFont systemFontOfSize:12.0f];
    
    [stockButton addSubview:changeStockNameLabel];
    [stockButton addSubview:changeStockSymbolLabel];
    
    if (_arrowUpDownType == 3) {
        _rowButton.enabled = NO;
        noteView.hidden = NO;
        _touchView1.hidden = YES;
        bottonView2.hidden = YES;
        _autoLayoutIndex = 1;
        _autoLayoutString = [_autoLayoutArray objectAtIndex:(_autoLayoutIndex %3)];
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }else{
            _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }
        [self changeFrameSize];
    }else if (_arrowUpDownType == 4){
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            if(IS_IPAD){
                crossRect.size.height -= 183;
            }else{
                crossRect.size.height -= 205;
            }
        }else{
            if(IS_IPAD){
                crossRect.size.height -= 205;
            }else{
                crossRect.size.height -= 145;
            }
        }
        [crossLineView setFrame:crossRect];
        bottonView2.hidden = YES;
        _touchView1.hidden = YES;
        _autoLayoutIndex = 1;
        _autoLayoutString = [_autoLayoutArray objectAtIndex:(_autoLayoutIndex %3)];
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }else{
            _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }
        [self changeFrameSize];
    }
    else if (_arrowUpDownType == 5){
        bottonView2.hidden = YES;
        _touchView1.hidden =YES;
        noteView.hidden = YES;
        _autoLayoutIndex = 1;
        _autoLayoutString = [_autoLayoutArray objectAtIndex:(_autoLayoutIndex %3)];
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }else{
            _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }
        [self changeFrameSize];
    }
    else{
        noteView.hidden = YES;
        
    }
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {

        [self setLayout];
    }else {
        
        ChartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.825;
        if (_arrowUpDownType ==4 || _arrowUpDownType == 5) {
            ChartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.915;
        }
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:1]floatValue];
        }else{
            
            _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:1]floatValue];
        }

        _rowButton.hidden = YES;
        _kLineParameterButton.hidden = YES;
        _biggerBtn.hidden = YES;
        _smallerBtn.hidden = YES;
        bottonView2.hidden = YES;
        _touchView2.hidden = YES;
        _bottomView2ClickLabel.hidden = YES;
        
        if (_twoLine) {
            _blueCompareStockName.hidden = NO;
            _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_blueCompareStockName(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
        }else{
            _blueCompareStockName.hidden = YES;
            _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
        }
        [self LandscapeAutoLayout];
        
        [bottonView1 changeWidth];
        [self changeFrameSize];
        [self updateDateRange];

//        [indexView setNeedsDisplay];
//        [indexScaleView getHigestAndLowest];
//        [indexScaleView setNeedsDisplay];
//        [upperValueView updateLabels];
//        [upperDateView updateLabels];
//        [bottonView1 setNeedsDisplay];
//        [bottonView1.dataView setNeedsDisplay];
        CGRect crossRect = [indexScrollView convertRect:indexScrollView.bounds toView:self.view];
        crossRect.size.width++;
        crossRect.size.height = self.view.bounds.size.height;
        [crossLineView setFrame:crossRect];

    }

    if (_arrowUpDownType == 4) {
        UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [pointButton addTarget:self action:@selector(explantation:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barPointButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pointButton];
        NSArray *itemArray = [[NSArray alloc] initWithObjects:barPointButtonItem,nil];
        [self.navigationItem setRightBarButtonItems:itemArray];
    }

    
    [super viewDidLoad];
}

-(void)hideKeyboard{
    if (nowArrowData){
        [actionPlanModel updatePerformanceNote:noteEditTextView.text WithPerformanceNum:nowArrowData->date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSDate * date  = [dateFormatter dateFromString:nowArrowData->date];
        [indexScaleView changeNote:noteEditTextView.text Key:[NSNumber numberWithUnsignedInt:[date uint16Value]] arrowType:nowArrowData->arrowType];
    }
    
    
    noteTextView.text = noteEditTextView.text;
    if(![noteTextView.text isEqualToString:@""]){
        notePlaceHolder.hidden = YES;
    }else{
        notePlaceHolder.hidden = NO;
    }
    [noteEditTextView resignFirstResponder];
    [noteTextView resignFirstResponder];
}

-(void)viewTap{
    noteTextView.text = noteEditTextView.text;
    if(![noteTextView.text isEqualToString:@""]){
        notePlaceHolder.hidden = YES;
    }else{
        notePlaceHolder.hidden = NO;
    }
    [noteEditTextView resignFirstResponder];
    [noteTextView resignFirstResponder];
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView isEqual:noteTextView]) {
        noteEditTextView.text = noteTextView.text;
        if(![noteTextView.text isEqualToString:@""]){
            notePlaceHolder.hidden = YES;
        }else{
            notePlaceHolder.hidden = NO;
        }
        [noteEditTextView becomeFirstResponder];
        
    }
}

-(void)changeFrameSize{
    float width;
    float height;
    CGRect upperBounds;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        width = 320;
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            height = 414;
        }else{
           height = 502;
        }
        if(_arrowUpDownType == 4 || _arrowUpDownType == 5){
            _autoLayoutUpperView = 0.75;
            upperBounds = CGRectMake(0, 0,  width*0.87,  height*_autoLayoutUpperView);
        }else{
            upperBounds = CGRectMake(0, 0,  width,  height*_autoLayoutUpperView);
        }
        
    }else{
        double version = [[UIDevice currentDevice].systemVersion doubleValue];
        if(version>=8.0f){
            if (_arrowUpDownType == 4 || _arrowUpDownType == 5) {
                ChartWidth = [[UIScreen mainScreen] applicationFrame].size.width*0.915;
            }else{
                ChartWidth = [[UIScreen mainScreen] applicationFrame].size.width*0.825;
            }
            
            width = [[UIScreen mainScreen] applicationFrame].size.width;
        }
        else{
            if (_arrowUpDownType == 4 || _arrowUpDownType == 5) {
            ChartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.915;
            }else{
                ChartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.825;
            }
            
            width = [[UIScreen mainScreen] applicationFrame].size.height;
        }
        
        
        height = 300;
        
        if(_arrowUpDownType == 4 || _arrowUpDownType == 5){
            height = 245;
            _autoLayoutUpperView = 0.75;
        }
        upperBounds = CGRectMake(0, 0,  width,  height*_autoLayoutUpperView);
    }
    
    // upperView.bounds;
	
	CGRect frameRect = CGRectMake(upperBounds.origin.x+1, upperBounds.origin.y+ChartTop, ChartWidth, upperBounds.size.height-(ChartTop+ChartButtom));
    CGRect chartRect = CGRectMake(1, 1, frameRect.size.width, upperBounds.size.height-(ChartTop+ChartButtom));
	
    chartRect.origin.x *= ChartZoomOrigin;
    chartRect.origin.y *= ChartZoomOrigin;
    chartRect.size.height *= ChartZoomOrigin;
    
    [self.indexScrollView setFrame:frameRect];
    
    [self.indexView setChartFrame:CGRectMake(0, 1, chartRect.size.width, chartRect.size.height)];
    [self.indexView setChartFrameOffset:chartRect.origin];

    [self.indexView setFrame:CGRectMake(0, 0, frameRect.size.width, (frameRect.size.height+2)*ChartZoomOrigin)];
    
    [self.indexScaleView setFrame:CGRectMake(0, 0, frameRect.size.width, frameRect.size.height+1)];
    
    CGFloat x = upperBounds.origin.x + ChartWidth + 2;
    
    [self.upperValueScrollView setFrame:CGRectMake(x, upperBounds.origin.y+2, width-x-1, upperBounds.size.height-3)];
    
    CGRect r = CGRectMake(x, upperBounds.origin.y+2, width-x-1, upperBounds.size.height-3);
    r.size.height = (r.size.height + 1) * ChartZoomOrigin;
    
    [self.upperValueView setFrame:r];
    
    CGFloat y = frameRect.origin.y + frameRect.size.height + 1;
    
    [self.upperDateScrollView setFrame:CGRectMake(frameRect.origin.x, y, frameRect.size.width, upperBounds.size.height-y-1)];
    
    r = upperDateScrollView.bounds;
    r.size.width += 2;
    [self.upperDateView setFrame:r];
    
}

-(void)explantation:(UIButton *)sender
{
    [self.navigationController pushViewController:[[ExplanationViewController alloc] init] animated:NO];
}

-(void)changeSize:(BOOL)big{
    analysisPeriod = self.analysisPeriod;
    hasArrive = NO;
    [self updateDateRange];
    forceUpdate = YES;
	
    _comparedHasArrive = NO;
	[indexView prepareDataToDraw];
    [indexView setNeedsDisplay];
	[indexScaleView getHigestAndLowest];
	[indexScaleView setNeedsDisplay];
    
    
    theHighestVolume = [self getTheHightestVolume];
    theLowestVolume = [self getTheLowestVolume];
    [bottonView1 setNeedsDisplay];
    [bottonView2 setNeedsDisplay];
	upperValueView.highest = indexScaleView.highestValue;
	upperValueView.lowest = indexScaleView.lowestValue;
    [upperValueView updateLabels];
    [upperDateView updateLabels];
//	[self ClearTimer];
	[self SetTimer];
    
}

-(void)changeRangeWithAnalysisPeriod:(int)range{
    [indexScaleView.drawLinePoints removeAllObjects];
    _chartFrameOffset = CGPointMake(1, 1);
    _penBtn.selected = NO;
    _eraserBtn.selected = NO;
    indexScrollView.scrollEnabled = YES;
//    [self.drawingView resetView];
    
    if (analysisPeriod != range)
    {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"",@"Draw",nil)];
        [self.indexView setBaseIndex:-1];
        // stop target watch
//        [self stopWatch];
        
        // set new value
        analysisPeriod = range;
        //更新週期title and indicator value（歸零）
//        [upperView refleshPeriodTitleAndIndicatorValue];
        [upperView selectUpperViewType];
        if (analysisPeriod==AnalysisPeriodDay) {
            [bottonView1 selectAnalysisType:indicator.bottomView1Indicator];
            [bottonView2 selectAnalysisType:indicator.bottomView2Indicator];
        }else if (analysisPeriod == AnalysisPeriodWeek){
            [bottonView1 selectAnalysisType:indicator.bottomView1WeekIndicator];
            [bottonView2 selectAnalysisType:indicator.bottomView2WeekIndicator];
        }else if (analysisPeriod == AnalysisPeriodMonth) {
            [bottonView1 selectAnalysisType:indicator.bottomView1MonIndicator];
            [bottonView2 selectAnalysisType:indicator.bottomView2MonIndicator];
        }else{
            [bottonView1 selectAnalysisType:indicator.bottomView1MinIndicator];
            [bottonView2 selectAnalysisType:indicator.bottomView2MinIndicator];
        }
        
        
        [self resetDisplay];
        [self resetCrossView];
        
//        NSUInteger count = _comparisonSettingController.targetCount;
//        id<ComparisonTarget> target;
        
//        for (int i = 0; i < count; i++)
//        {
//            target = [_comparisonSettingController targetForLine:i];
            if (_comparedHasArrive)
            {
                _comparedHasArrive = NO;
                [_comparedHistoricData.dataArray removeAllObjects];
            }
//        }
        
        // start target watch
        [self startWatch];
//        [self SetTimer];
        
        
    }
}

-(void)setupActionButtons {
	NSString *indicatorSettingText = NSLocalizedStringFromTable(@"Setting Indicator Parameter", @"Draw", @"The compare button of the realtime chart");
    NSString * dayLineText = NSLocalizedStringFromTable(@"Daily",@"Draw",@"");
    NSString * weekLineText = NSLocalizedStringFromTable(@"Weekly",@"Draw",@"");
    NSString * monthLineText = NSLocalizedStringFromTable(@"Monthly",@"Draw",@"");
    NSString * minLineText = NSLocalizedStringFromTable(@"Minutely",@"Draw",@"");
    NSString * rowText = NSLocalizedStringFromTable(@"Row",@"Draw",@"");
    
    self.blueStockName = [[MarqueeLabel alloc]initWithFrame:CGRectMake(5, 5, 300, 30) duration:4.0 andFadeLength:0.0f];
    self.blueStockName.textAlignment = NSTextAlignmentCenter;
    self.blueStockName.font = [UIFont boldSystemFontOfSize:16.0];
    self.blueStockName.marqueeType = 4;
    self.blueStockName.continuousMarqueeExtraBuffer = 30.0f;
    self.blueStockName.layer.cornerRadius = 5.0f;
    self.blueStockName.backgroundColor = [UIColor colorWithRed:0 green:78.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
    [self.blueStockName setViewBackgroundColor:[UIColor colorWithRed:0 green:78.0f/255.0f blue:162.0f/255.0f alpha:1.0f]];
    self.blueStockName.textColor = [UIColor whiteColor];
//    [self.blueStockName setLabelize:YES];
    self.blueStockName.userInteractionEnabled = NO;
    
    self.blueCompareStockName = [[MarqueeLabel alloc]initWithFrame:CGRectMake(5, 5, 300, 30) duration:4.0 andFadeLength:0.0f];
    self.blueCompareStockName.textAlignment = NSTextAlignmentCenter;
    self.blueCompareStockName.font = [UIFont boldSystemFontOfSize:16.0];
    self.blueCompareStockName.marqueeType = 4;
    self.blueCompareStockName.continuousMarqueeExtraBuffer = 30.0f;
    self.blueCompareStockName.layer.cornerRadius = 5.0f;
    self.blueCompareStockName.backgroundColor = [UIColor colorWithRed:0 green:78.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
    [self.blueCompareStockName setViewBackgroundColor:[UIColor colorWithRed:0 green:78.0f/255.0f blue:162.0f/255.0f alpha:1.0f]];
    self.blueCompareStockName.textColor = [UIColor whiteColor];
//    [self.blueCompareStockName setLabelize:YES];
    self.blueCompareStockName.userInteractionEnabled = NO;
    
    
    self.dayLine = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_dayLine setTitle:dayLineText forState:UIControlStateNormal];
    [_dayLine sizeToFit];
    [_dayLine addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.weekLine = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_weekLine setTitle:weekLineText forState:UIControlStateNormal];
    [_weekLine sizeToFit];
    
    [_weekLine addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.monthLine = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_monthLine setTitle:monthLineText forState:UIControlStateNormal];
    [_monthLine sizeToFit];
    
    [_monthLine addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.minLine = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_minLine setTitle:minLineText forState:UIControlStateNormal];
    [_minLine sizeToFit];
    
    [_minLine addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    if (_twoLine) {
        _minLine.enabled = NO;
    }
    
    self.rowButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_rowButton setTitle:rowText forState:UIControlStateNormal];
    _rowButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"])
    {
        [_rowButton setImage:[UIImage imageNamed:@"Row按鍵1"] forState:UIControlStateNormal];
    }
    
    [_rowButton sizeToFit];
    
    [_rowButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.twoStock = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    self.twoStock.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [_twoStock setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    _twoStock.selected =_twoLine;
    
    [_twoStock addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.changeCompareStockBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    
    if  ([_watchportfolio comparedPortfolioItem] != nil){
        if ([group isEqualToString:@"us"])
        {
            [_changeCompareStockBtn setTitle:[_watchportfolio comparedPortfolioItem]->symbol forState:UIControlStateNormal];
            _blueCompareStockName.text = [_watchportfolio comparedPortfolioItem]->symbol;
        }else{
            [_changeCompareStockBtn setTitle:[_watchportfolio comparedPortfolioItem]->fullName forState:UIControlStateNormal];
            _blueCompareStockName.text = [_watchportfolio comparedPortfolioItem]->fullName;
        }
        
    }
    
    if (_watchportfolio.portfolioItem != nil) {
        if ([group isEqualToString:@"us"]) {
            _blueStockName.text = [_watchportfolio portfolioItem]->symbol;
        }else{
            _blueStockName.text = [_watchportfolio portfolioItem]->fullName;
        }
    }
if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        _changeCompareStockBtn.hidden =!_twoLine;
    }else{
        _blueCompareStockName.hidden = !_twoLine;
    }
    
    
    [_changeCompareStockBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.penBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    self.penBtn.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [_penBtn setImage:[UIImage imageNamed:@"tachart_paint"] forState:UIControlStateNormal];
    
    [_penBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.eraserBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    self.eraserBtn.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [_eraserBtn setImage:[UIImage imageNamed:@"tachart_eraser"] forState:UIControlStateNormal];
    
    [_eraserBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.biggerBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    self.biggerBtn.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [_biggerBtn setImage:[UIImage imageNamed:@"tachart_magnifier"] forState:UIControlStateNormal];
    
    [_biggerBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.smallerBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    self.smallerBtn.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    [_smallerBtn setImage:[UIImage imageNamed:@"tachart_narrow"] forState:UIControlStateNormal];
    
    [_smallerBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.kLineParameterButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _kLineParameterButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_kLineParameterButton setTitle:indicatorSettingText forState:UIControlStateNormal];
    [_kLineParameterButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)buttonClick:(FSUIButton *)btn{
    if ([btn isEqual:_dayLine]) {
        [self changeRangeWithAnalysisPeriod:0];
        _dayLine.selected = YES;
        _weekLine.selected = NO;
        _monthLine.selected = NO;
        _minLine.selected = NO;
        _kLineParameterButton.selected = NO;
        [_minLine setTitle:NSLocalizedStringFromTable(@"Minutely",@"Draw",@"") forState:UIControlStateNormal];
        _twoStock.enabled = YES;
    }else if ([btn isEqual:_weekLine]){
        [self changeRangeWithAnalysisPeriod:1];
        _dayLine.selected = NO;
        _weekLine.selected = YES;
        _monthLine.selected = NO;
        _minLine.selected = NO;
        _kLineParameterButton.selected = NO;
        [_minLine setTitle:NSLocalizedStringFromTable(@"Minutely",@"Draw",@"") forState:UIControlStateNormal];
        _twoStock.enabled = YES;
        if (_arrowUpDownType == 4 || _arrowUpDownType == 5) {
            [self reset];
        }
    }else if ([btn isEqual:_monthLine]){
        [self changeRangeWithAnalysisPeriod:2];
        _dayLine.selected = NO;
        _weekLine.selected = NO;
        _monthLine.selected = YES;
        _minLine.selected = NO;
        _kLineParameterButton.selected = NO;
        [_minLine setTitle:NSLocalizedStringFromTable(@"Minutely",@"Draw",@"") forState:UIControlStateNormal];
        _twoStock.enabled = YES;
        if (_arrowUpDownType == 4 || _arrowUpDownType == 5) {
            [self reset];
        }
    }else if ([btn isEqual:_minLine]){
        _dayLine.selected = NO;
        _weekLine.selected = NO;
        _monthLine.selected = NO;
        _minLine.selected = YES;
        _kLineParameterButton.selected = NO;
        periodsTypeSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"分線",@"Draw",@"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel",@"Draw",@"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"5Minutely",@"Draw",@""),NSLocalizedStringFromTable(@"15Minutely",@"Draw",@""),NSLocalizedStringFromTable(@"30Minutely",@"Draw",@""),NSLocalizedStringFromTable(@"60Minutely",@"Draw",@""),nil];
        [self showActionSheet:periodsTypeSheet];
        if (_arrowUpDownType == 4 || _arrowUpDownType == 5) {
            [self reset];
        }
    }else if ([btn isEqual:_kLineParameterButton]){
#ifdef StockPowerTW

        parameterSheet = [[UIActionSheet alloc]initWithTitle:@"設定類別" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"技術指標參數設定", @"主力買賣券商設定", nil];
        [self showActionSheet:parameterSheet];
#else
        SettingIndicatorsViewController * settingIndicators = [[SettingIndicatorsViewController alloc]init];
        [self.navigationController pushViewController:settingIndicators animated:NO];
#endif
    }else if ([btn isEqual:_rowButton]){
        _autoLayoutIndex +=1;
        
        _autoLayoutString = [_autoLayoutArray objectAtIndex:(_autoLayoutIndex %3)];
        
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }else{
            _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        }
        
        if ((_autoLayoutIndex %3)==0) {
            _upperViewClickLabel.hidden = NO;
            _bottomView1ClickLabel.hidden = NO;
            _bottomView2ClickLabel.hidden = NO;
            bottonView1.hidden = NO;
            bottonView2.hidden = NO;
            ChartTop = 15.0f;
            NSString * appid = [FSFonestock sharedInstance].appId;
            NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
            if ([group isEqualToString:@"us"])
            {
                [_rowButton setImage:[UIImage imageNamed:@"Row按鍵1"] forState:UIControlStateNormal];
            }
        }else if((_autoLayoutIndex %3)==1){
            bottonView2.hidden = YES;
            _bottomView2ClickLabel.hidden = YES;
            ChartTop = 15.0f;
            NSString * appid = [FSFonestock sharedInstance].appId;
            NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
            if ([group isEqualToString:@"us"])
            {
                [_rowButton setImage:[UIImage imageNamed:@"Row按鍵1"] forState:UIControlStateNormal];
            }

        }else{
            noteView.hidden = YES;
            bottonView1.hidden = YES;
            bottonView2.hidden = YES;
            _bottomView1ClickLabel.hidden = YES;
            _bottomView2ClickLabel.hidden = YES;
            ChartTop = 30.0f;
            NSString * appid = [FSFonestock sharedInstance].appId;
            NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
            if ([group isEqualToString:@"us"])
            {
                [_rowButton setImage:[UIImage imageNamed:@"Row按鍵2"] forState:UIControlStateNormal];
            }
        }
        
        [self changeFrameSize];
        [self updateDateRange];
        [self setLayout];
        [indexView setNeedsDisplay];
        [indexScaleView getHigestAndLowest];
        [indexScaleView setNeedsDisplay];
        [bottonView1 setNeedsDisplay];
        [bottonView2 setNeedsDisplay];
        
    }else if ([btn isEqual:_twoStock]){
        _twoStock.selected = !_twoStock.selected;
        _twoLine = !_twoLine;
        if (_twoLine) {
            _minLine.enabled = NO;
            _penBtn.enabled = NO;
            _eraserBtn.enabled = NO;
        }else{
            _minLine.enabled = YES;
            _penBtn.enabled = YES;
            _eraserBtn.enabled = YES;
        }
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            _changeCompareStockBtn.hidden = !_twoLine;
        }else{
            _blueCompareStockName.hidden = !_twoLine;
        }
        if (_blueCompareStockName.hidden == NO) {
            [self.blueCompareStockName setLabelize:NO];
        }
        if (self.crossVisible){
            [self openCrossView:YES];
        }else{
            [self openCrossView:NO];
        }
        [self startWatch];
        [indexView prepareDataToDraw];
        [indexView setNeedsDisplay];
        [indexScaleView getHigestAndLowest];
        [indexScaleView setNeedsDisplay];
        [upperView setNeedsDisplay];
        [upperValueView updateLabels];
        if (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            if (_twoLine) {
                _blueCompareStockName.hidden = NO;
                _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_blueCompareStockName(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
            }else{
                _blueCompareStockName.hidden = YES;
                _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
            }
            
            [self LandscapeAutoLayout];
        }
        
    }else if ([btn isEqual:_penBtn]){
        btn.selected = !btn.selected;
        indexScaleView.drawEnd = NO;
        if (btn.selected) {
//            self.drawingView.userInteractionEnabled = YES;
//            self.drawingView.eraseMode = NO;
            _eraserBtn.selected = NO;
            indexScrollView.scrollEnabled = NO;
            [self.indexView setChartFrameOffset:CGPointMake(-50, 1)];
            indexScaleView.offsetX = -50;
            self.chartFrameOffset = CGPointMake(-50, 1);
            [self openCrossView:NO];
            [indexView setNeedsDisplay];
            [indexScaleView setNeedsDisplay];
            [upperDateView updateLabels];
            [bottonView1 setNeedsDisplay];
            [bottonView2 setNeedsDisplay];
            [self showDrawLineActionSheet];
        } else {
            indexScrollView.scrollEnabled = YES;
            if ([indexScaleView.drawLinePoints count]==0) {
                [self.indexView setChartFrameOffset:CGPointMake(1, 1)];
                indexScaleView.offsetX = 1;
                indexScaleView.firstTouch = CGPointMake(0, 0);
                indexScaleView.lastTouch = CGPointMake(0, 0);
                _chartFrameOffset = CGPointMake(1, 1);
                [indexView setNeedsDisplay];
                [indexScaleView setNeedsDisplay];
                [upperDateView updateLabels];
                [bottonView1 setNeedsDisplay];
                [bottonView2 setNeedsDisplay];
            }
            
//            self.drawingView.userInteractionEnabled = NO;
        }
    }else if ([btn isEqual:_eraserBtn]){
        btn.selected = !btn.selected;
        indexScaleView.drawEnd = NO;
        if (btn.selected) {
//            self.drawingView.userInteractionEnabled = YES;
//            self.drawingView.eraseMode = YES;
            _penBtn.selected = NO;
            indexScrollView.scrollEnabled = NO;
            [self showEraserActionSheet];
        } else {
            indexScrollView.scrollEnabled = YES;
//            self.drawingView.userInteractionEnabled = NO;
        }
    }else if ([btn isEqual:_biggerBtn]){
        float winLocationX = self.indexScaleView.frame.origin.x;
        NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+self.indexScaleView.frame.size.width-1];
        
        _oldPoint = CGPointMake(indexScrollView.contentOffset.x+dataEndIndex+1, indexScrollView.contentOffset.y);
        if (ChartBarWidth<29) {
            ChartBarWidth +=1;
            BarDateWidth +=1;
            changeSizeFlag = YES;
            [self changeSize:YES];
        }
    }else if ([btn isEqual:_smallerBtn]){
        if (ChartBarWidth>1) {
            float winLocationX;
            if(self.indexScaleView.frame.size.width<273)
                winLocationX = 0;
            else
                winLocationX = self.indexScaleView.frame.origin.x;
            NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+self.indexScaleView.frame.size.width-1];
            if (indexScrollView.contentOffset.x-dataEndIndex<0) {
                _oldPoint = CGPointMake(1, indexScrollView.contentOffset.y);
            }else{
                _oldPoint = CGPointMake(indexScrollView.contentOffset.x-dataEndIndex-1, indexScrollView.contentOffset.y);
            }
            changeSizeFlag = YES;
            ChartBarWidth -=1;
            BarDateWidth -=1;
            [self changeSize:NO];
        }
    }else if ([btn isEqual:_changeCompareStockBtn]){
        ChangeStockViewController * changeStock = [[ChangeStockViewController alloc]initWithNumber:2];
        [self.navigationController pushViewController:changeStock animated:NO];
    }
}

- (void)startWatch
{
    newDataArray = [[NSMutableArray alloc]init];
    PortfolioTick *tickBank = _dataModal.historicTickBank;
	PortfolioTick *tickBank_P = _dataModal.portfolioTickBank;
    UInt8 type = self.historicType;
	NSMutableArray *addIdentSymbolArray = [[NSMutableArray alloc] init];

    if (portfolioItem != nil)
	{
        [tickBank watchTarget:self ForEquity:idSymbol tickType:type];
//		[tickBank_P watchTarget:self ForEquity:idSymbol GetTick:YES];
#ifdef LPCB
        [tickBank_P setTaget:self IdentCodeSymbol:idSymbol];
#endif
        [tickBank_P updateTickDataByIdentCodeSymbol:idSymbol];
		[addIdentSymbolArray addObject:idSymbol];
	}
    if (_twoLine)
	{
//		NSUInteger count = _comparisonSettingController.targetCount;
//        id<ComparisonTarget> target;
//        for (int i = 0; i < count; i++) 
//		{
//            target = [_comparisonSettingController targetForLine:i];
//            if (target != nil)
//			{
//				[addIdentSymbolArray addObject:target.identCodeSymbol];
//                [tickBank watchTarget:self ForEquity:target.identCodeSymbol tickType:type];
//				[tickBank_P watchTarget:self ForEquity:target.identCodeSymbol GetTick:YES];
//			}
//        }
        if(_watchportfolio.comparedPortfolioItem != nil){
            [addIdentSymbolArray addObject:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];

            [tickBank watchTarget:self ForEquity:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol] tickType:type];
            [tickBank_P setTaget:self IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
            [tickBank_P updateTickDataByIdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        }
        
        
//        [tickBank_P watchTarget:self ForEquity:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol] GetTick:YES];
		
		[portfolio addWatchListItemByIdentSymbolArray:addIdentSymbolArray];
		
    }
}
//-(void)getCommodityNo{
//    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//    [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[[_watchportfolio.portfolioItem getIdentCodeSymbol]]];
//    if (_twoLine) {
//        [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]]];
//    }
//}
-(void)TickDataNotification{
    PortfolioTick *tickBank_P = _dataModal.portfolioTickBank;

    [tickBank_P goGetTickByIdentSymbolForStock:idSymbol];
    if (_twoLine) {
        [tickBank_P goGetTickByIdentSymbolForStock:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
    }
}

- (void)stopWatch
{
    PortfolioTick *tickBank = _dataModal.historicTickBank;
    PortfolioTick *tickBank_P = _dataModal.portfolioTickBank;
#ifdef LPCB
//    [[[FSDataModelProc sharedInstance]portfolioTickBank] removeKeyWithTaget:self IdentCodeSymbol:idSymbol];
#endif
    if (portfolioItem != nil){
        [tickBank stopWatch:self ForEquity:idSymbol];
        [tickBank_P removeKeyWithTaget:self IdentCodeSymbol:idSymbol];
//        [tickBank removeEquity:idSymbol];

        if (_twoLine){
            [tickBank stopWatch:self ForEquity:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];;
            [tickBank_P removeKeyWithTaget:self IdentCodeSymbol:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol]];
        }
    }
}

- (void)chartWillAppear
{
    [self.view sendSubviewToBack:crossLineView];
	
    [self hideCrossInfo];

    [bottonView1 loadScrollViewPage];
    [bottonView2 loadScrollViewPage];

	
    NSString *equity = [portfolioItem getIdentCodeSymbol];
	
    if (![idSymbol isEqualToString:equity]) 
	{
        self.idSymbol = equity;
        [self resetDisplay];
    }
	else
	{
		[self SetTimer];
	}
    [self startWatch];
}


- (void)chartWillDisappear 
{
    [self ClearTimer];
    [self stopWatch];
}


- (void)viewWillAppear:(BOOL)animated 
{
    if(_arrowUpDownType == 4){

        [selectArray removeAllObjects];
        for (int i=0; i<48; i++) {
            [selectArray addObject:[NSNumber numberWithBool:NO]];
            
        }
    }else if (_arrowUpDownType == 5){
        
    }
    [self registerLoginNotificationCallBack:self seletor:@selector(TickDataNotification)];
    [self registerTickDataNotificationCallBack:self seletor:@selector(TickDataNotification)];

    _kLineParameterButton.selected = NO;
    [_dataModal.indicator readDefaultBottomViewIndicator];
    [self buttonSelected];
    
    if (!_firstIn && (_arrowUpDownType == 4 ||_arrowUpDownType == 5)) {

        [self reset];
    }else{
        _firstIn = NO;
    }
    
    if(_twoStock.selected){
        _minLine.enabled = NO;
        _penBtn.enabled = NO;
        _eraserBtn.enabled = NO;
    }
    
//	[self turnOnPaidFunction];
    //self.watchportfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    portfolioItem = _watchportfolio.portfolioItem;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        if (portfolioItem !=nil){
            changeStockNameLabel.text = portfolioItem->fullName;
            changeStockSymbolLabel.text = portfolioItem->symbol;
            self.blueStockName.text = portfolioItem->fullName;
        }
        
    }else {
        if (portfolioItem !=nil){
//            self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@ (%@)",self.navigationItem.title,portfolioItem->symbol,portfolioItem->fullName];
            changeStockNameLabel.text = portfolioItem->fullName;
            self.blueStockName.text = portfolioItem->fullName;
            changeStockSymbolLabel.text = portfolioItem->symbol;
        }
    }
    
    if ([_watchportfolio comparedPortfolioItem] !=nil){
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"])
        {
            [_changeCompareStockBtn setTitle:[_watchportfolio comparedPortfolioItem]->symbol forState:UIControlStateNormal];
            _blueCompareStockName.text = [_watchportfolio comparedPortfolioItem]->symbol;
        }else{
            [_changeCompareStockBtn setTitle:[_watchportfolio comparedPortfolioItem]->fullName forState:UIControlStateNormal];
            _blueCompareStockName.text = [_watchportfolio comparedPortfolioItem]->fullName;
        }
        
    }


	[self chartWillAppear];
    
}

-(void)reset{
    indexScaleView.dateDictionary = nil;
    indexScaleView.arrowType = 0;
    _dataModal.indicator.bottomView1Indicator = 13;
    bottonView1.kNumberOfTables = 14;
    bottonView2.kNumberOfTables = 14;
    //        [bottonView1 loadWithDefaultPage:indicator.bottomView1Indicator];
    [bottonView1 selectAnalysisType:BottomViewAnalysisTypeTower];
    if (_arrowUpDownType == 4) {
        noteView.hidden = NO;
    }else{
        noteView.hidden = YES;
    }
    
    _bottomView1ClickLabel.hidden = NO;
}

-(void)buttonSelected{
    _dayLine.selected = NO;
    _weekLine.selected = NO;
    _monthLine.selected = NO;
    _minLine.selected = NO;
    if (analysisPeriod==AnalysisPeriodDay) {
        _dayLine.selected = YES;
    }else if (analysisPeriod==AnalysisPeriodWeek){
        _weekLine.selected = YES;
    }else if (analysisPeriod==AnalysisPeriodMonth){
        _monthLine.selected = YES;
    }else if (analysisPeriod==AnalysisPeriod5Minute){
        _minLine.selected = YES;
        [_minLine setTitle:NSLocalizedStringFromTable(@"5分",@"Draw",nil) forState:UIControlStateNormal];
    }else if (analysisPeriod==AnalysisPeriod15Minute){
        _minLine.selected = YES;
        [_minLine setTitle:NSLocalizedStringFromTable(@"15分",@"Draw",nil) forState:UIControlStateNormal];
    }else if (analysisPeriod==AnalysisPeriod30Minute){
        _minLine.selected = YES;
        [_minLine setTitle:NSLocalizedStringFromTable(@"30分",@"Draw",nil) forState:UIControlStateNormal];
    }else if (analysisPeriod==AnalysisPeriod60Minute){
        _minLine.selected = YES;
        [_minLine setTitle:NSLocalizedStringFromTable(@"60分",@"Draw",nil) forState:UIControlStateNormal];
    }
}

-(void)handleTap:(UIGestureRecognizer *)sender{
    UIView * view = sender.view;
    if ([view isEqual:_touchView1]) {
        [bottonView1 openTypeControl:YES];
        _bottonView1Picker = YES;
    }else if ([view isEqual:_touchView2]){
        [bottonView2 openTypeControl:YES];
        _bottonView2Picker = YES;
    }else if ([view isEqual:_upperTouchView]){
        if(_twoLine) return;
        [upperView openUpperIndicatorPicker];
        _upperViewPicker = YES;
    }
    
    
}

-(void)viewDidLayoutSubviews{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        if (_upperTouchView) {
            [self.upperTouchView setFrame:CGRectMake(upperView.frame.size.width, upperView.frame.origin.y, 320-upperView.frame.size.width,upperView.frame.size.height)];
        }else{
            self.upperTouchView = [[UIView alloc]initWithFrame:CGRectMake(upperView.frame.size.width, upperView.frame.origin.y, 320-upperView.frame.size.width,upperView.frame.size.height)];
        }
        
    }else{
        _blueStockName.continuousMarqueeExtraBuffer = 10.0f;
        [_blueStockName beginScroll];
        _blueCompareStockName.continuousMarqueeExtraBuffer = 10.0f;
        [_blueCompareStockName beginScroll];
        
        if (_upperTouchView) {
            [self.upperTouchView setFrame:CGRectMake(upperView.frame.size.width-45, upperView.frame.origin.y, 45,upperView.frame.size.height)];
        }else{
            self.upperTouchView = [[UIView alloc]initWithFrame:CGRectMake(upperView.frame.size.width-45, upperView.frame.origin.y, 45,upperView.frame.size.height)];
        }
    }
    
    UITapGestureRecognizer *upperTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
//    if (_upperTouchView) {
//        if (upperView.frame.size.width>330) {
//            [self.upperTouchView setFrame:CGRectMake(upperView.frame.size.width-45, upperView.frame.origin.y, 45,upperView.frame.size.height)];
//        }else{
//            [self.upperTouchView setFrame:CGRectMake(upperView.frame.size.width, upperView.frame.origin.y, 320-upperView.frame.size.width,upperView.frame.size.height)];
//        }
//        
//    }else{
//        if (upperView.frame.size.width>330) {
//            self.upperTouchView = [[UIView alloc]initWithFrame:CGRectMake(upperView.frame.size.width-45, upperView.frame.origin.y, 45,upperView.frame.size.height)];
//        }else{
//            self.upperTouchView = [[UIView alloc]initWithFrame:CGRectMake(upperView.frame.size.width, upperView.frame.origin.y, 320-upperView.frame.size.width,upperView.frame.size.height)];
//        }
//        
//    }
    
    _upperTouchView.backgroundColor = [UIColor clearColor];
    [_upperTouchView addGestureRecognizer:upperTap];
    _upperTouchView.userInteractionEnabled = YES;
    [self.view addSubview:_upperTouchView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    if(_touchView1){
        [self.touchView1 setFrame:CGRectMake(bottonView1.frame.size.width-45, bottonView1.frame.origin.y, 45,bottonView1.frame.size.height )];
    }else{
        self.touchView1 = [[UIView alloc]initWithFrame:CGRectMake(bottonView1.frame.size.width-45, bottonView1.frame.origin.y, 45,bottonView1.frame.size.height )];
    }
    
    _touchView1.backgroundColor = [UIColor clearColor];
    [_touchView1 addGestureRecognizer:tap];
    if ((_autoLayoutIndex %3)==2) {
       _touchView1.userInteractionEnabled = NO;
    }else{
        _touchView1.userInteractionEnabled = YES;
    }
    [self.view addSubview:_touchView1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    if (_touchView2) {
        [self.touchView2 setFrame:CGRectMake(bottonView2.frame.size.width-45,bottonView2.frame.origin.y, 45,bottonView2.frame.size.height )];
    }else{
        self.touchView2 = [[UIView alloc]initWithFrame:CGRectMake(bottonView2.frame.size.width-45,bottonView2.frame.origin.y, 45,bottonView2.frame.size.height )];
    }
    
    _touchView2.backgroundColor = [UIColor clearColor];
    [_touchView2 addGestureRecognizer:tap2];
    _touchView2.userInteractionEnabled = YES;
    [self.view addSubview:_touchView2];

    //右下角黑色三角形
    if (!_upperViewClickLabel) {
        self.upperViewClickLabel = [[UILabel alloc]initWithFrame:CGRectMake(34, _upperTouchView.frame.size.height-10, 10, 10)];
        _upperViewClickLabel.backgroundColor = [UIColor clearColor];
        _upperViewClickLabel.font = [UIFont systemFontOfSize:10.0f];
        _upperViewClickLabel.textAlignment = NSTextAlignmentCenter;
        _upperViewClickLabel.text = @"◢";
        [self.upperTouchView addSubview:_upperViewClickLabel];
    }else{
        [self.upperViewClickLabel setFrame:CGRectMake(34, _upperTouchView.frame.size.height-10, 10, 10)];
    }
    
    
    if (!_bottomView1ClickLabel) {
        self.bottomView1ClickLabel = [[UILabel alloc]initWithFrame:CGRectMake(34, _touchView1.frame.size.height-10, 10, 10)];
        _bottomView1ClickLabel.backgroundColor = [UIColor clearColor];
        _bottomView1ClickLabel.font = [UIFont systemFontOfSize:10.0f];
        _bottomView1ClickLabel.textAlignment = NSTextAlignmentCenter;
        _bottomView1ClickLabel.text = @"◢";
        [self.touchView1 addSubview:_bottomView1ClickLabel];
    }else{
        [self.bottomView1ClickLabel setFrame:CGRectMake(34, _touchView1.frame.size.height-10, 10, 10)];
    }
    if (_arrowUpDownType != 0){
        if (_arrowUpDownType == 3) {
            _bottomView1ClickLabel.hidden = YES;
        }else{
            _bottomView1ClickLabel.hidden = NO;
        }
    }
    

    
    
    if (!_bottomView2ClickLabel) {
        self.bottomView2ClickLabel = [[UILabel alloc]initWithFrame:CGRectMake(34, _touchView2.frame.size.height-10, 10, 10)];
        _bottomView2ClickLabel.backgroundColor = [UIColor clearColor];
        _bottomView2ClickLabel.font = [UIFont systemFontOfSize:10.0f];
        _bottomView2ClickLabel.textAlignment = NSTextAlignmentCenter;
        _bottomView2ClickLabel.text = @"◢";
        [self.touchView2 addSubview:_bottomView2ClickLabel];
    }else{
        [self.bottomView2ClickLabel setFrame:CGRectMake(34, _touchView2.frame.size.height-10, 10, 10)];
    }
    
if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
//        [_drawingView setFrame:CGRectMake(upperView.frame.origin.x, upperView.frame.origin.y, upperView.frame.size.width, upperView.frame.size.height+bottonView1.frame.size.height+bottonView2.frame.size.height)];
    }else {
//        [_drawingView setFrame:CGRectMake(upperView.frame.origin.x, upperView.frame.origin.y, upperView.frame.size.width-45, upperView.frame.size.height+bottonView1.frame.size.height)];
    }
    
    if (_arrowUpDownType != 0){
        if (_arrowUpDownType == 3 ||_arrowUpDownType == 4 || _arrowUpDownType == 5) {
            _bottomView2ClickLabel.hidden = YES;
        }else{
            _bottomView2ClickLabel.hidden = NO;
        }
    }
    
    if ( _arrowUpDownType == 4 || _arrowUpDownType == 5) {
        _touchView1.userInteractionEnabled = NO;
        _touchView2.userInteractionEnabled = NO;
        _upperTouchView.userInteractionEnabled = NO;
        
        _upperViewClickLabel.hidden = YES;
        _bottomView1ClickLabel.hidden = YES;
        _bottomView2ClickLabel.hidden = YES;
    }
    
    
    if (_blueStockName.hidden == NO) {
        [self.blueStockName setLabelize:NO];
    }
    
    [self.view layoutSubviews];
}


- (void)dealloc
{
//    indexScrollView.delegate = nil;
//    scaleScrollView.delegate = nil;
//    upperValueScrollView.delegate = nil;
//    upperDateScrollView.delegate = nil;
    NSLog(@"DrawAndScrollController Dealloc");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterLoginNotificationCallBack:nil];
    [self unRegisterTickDataNotificationCallBack:nil];
    
    _dataModal.indicator.UpperViewAnalysisPeriod = analysisPeriod;
    _dataModal.indicator.techViewBarWidth = ChartBarWidth;
    _dataModal.indicator.twoStockCompare = _twoLine;
    [_dataModal.indicator writeDefaultBottomViewIndicator];

    [self chartWillDisappear];

    crossLineView.hidden = YES;
    self.crossInfoView.hidden = YES;
    
//    indicator = nil;
//    _dataModal.operationalIndicator.drawAndScrollController = nil;
//    indexView.drawAndScrollController = nil;
//    self.indexScaleView.drawAndScrollController = nil;
//
//    upperView.drawAndScrollController = nil;
//    upperValueView.drawAndScrollController = nil;
//    upperDateView.drawAndScrollController = nil;
//    drawAndScrollView.drawAndScrollController = nil;
//    crossInfoPortrait.viewController = nil;
//    
//    bottonView1.drawAndScrollController = nil;
//    bottonView2.drawAndScrollController = nil;
//    bottonView1.dataView.bottonView = nil;
//    bottonView2.dataView.bottonView = nil;
//    bottonView1.dataView.drawAndScrollController = nil;
//    bottonView2.dataView.drawAndScrollController = nil;
//
//    bottonView1.dataScrollView = nil;
//    bottonView2.dataScrollView = nil;
    
//    scaleScrollView.delegate = nil;
//    indexScrollView.delegate = nil;
//    upperValueScrollView.delegate = nil;
//    upperDateScrollView.delegate = nil;

    
}

-(void)turnOnPaidFunction
{
//	bPaid = [FidaAuth checkAuthID:2]; // K線
//	
//	if(bPaid)
//	{
//		if(floatingView)
//		{
//			[floatingView removeFromSuperview];
//			[floatingView release];
//			floatingView = nil;
//		}
//	}
//	else
//	{
//		if(!floatingView)
//		{
//			floatingView = [[FloatingPurchaseView alloc] initWithFrame:self.view.frame];
//			floatingView.viewController = self;
//			floatingView.authID = 2;
//			[self.view addSubview:floatingView];
//		}
//		else {
//			[floatingView reCheck];
//		}
		
//	}
//	
}

- (void)updateOldestDate 
{
	
    NSDate *oldestDate;
    UInt8 type = self.historicType;
	
    if ([historicData tickCount:type] == 0) 
	{
		
        oldestDate = [self setTodayDate];
    }
    else
	{
        DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:0];
        oldestDate = [ValueUtil nsDateFromStkDate:historic.date];
    }
	
    self.chartOldestDate = oldestDate;
}


- (NSDate *)getOldestDate 
{
    return chartOldestDate;
}


- (int)getDateNum 
{
	
    UInt32 count = [historicData tickCount:self.historicType];
	
    if (analysisPeriod == AnalysisPeriodDay) 
	{
		
        [self updateOldestDate];
		
    }
	
    return count;
}


- (void)timeout:(NSTimer *)tmr
{
	timer = nil;
	if(hasArrive == NO)
		hasArrive = YES;
	goUpdate = YES;
}

- (void)ClearTimer
{
	if (timer)
	{
		[timer invalidate];
		timer = nil;
	}
}

- (void)SetTimer
{
	//NSLog(@"SET TIMER");
	[self ClearTimer];

	timer = [NSTimer timerWithTimeInterval:45 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)notifyDataArrive:(NSObject<HistoricTickDataSourceProtocol> *)dataSource 
{
	NSString *arriveSymbol = [dataSource getIdenCodeSymbol];
	if([arriveSymbol length] == 0)
		return;
	
    
    
	if([dataSource isKindOfClass:[EquityTick class]])
	{
		PortfolioTick *tickBank = _dataModal.historicTickBank;
		UInt8 type = self.historicType;
		if (![arriveSymbol isEqualToString:idSymbol]) 
		{
			
//			if (_twoLine)
//			{
				
//				id<ComparisonTarget> target = [_comparisonSettingController targetForEquity:arriveSymbol];
//				if (target == nil) return;
				if(_comparedHasArrive == YES)
					[tickBank GetCurData:self ForEquity:[_watchportfolio.comparedPortfolioItem getIdentCodeSymbol] tickType:type];
				
//			}
			return;
		}
		else
		{
			 
			if(hasArrive == YES)
			{
                [tickBank GetCurData:self ForEquity:idSymbol tickType:type];
			//	NSLog(@"Tick");
				if(goUpdate)
				{
					goUpdate = NO;
			//		NSLog(@"GOUPDATE");
					
					[self SetTimer];
				}
				
			}
			return;		
		}
		
	}
	else if([dataSource isKindOfClass:[EquityHistory class]])
	{
		BOOL YESNO = NO;	
		if([dataSource isLatestData:self.historicType])
		{
			YESNO = YES;
		}
		
		//for走勢比較的identSymbol
		if (![arriveSymbol isEqualToString:idSymbol]) 
		{
		
//			if (_twoLine)
//			{
//				id<ComparisonTarget> target = [_comparisonSettingController targetForEquity:arriveSymbol];
//				if (target == nil) return;
//			
//				PortfolioItem *item = [[DataModalProc getDataModal].portfolioData findInPortfolio:target.identCode Symbol:target.symbol];
            
			
				if(_comparedHasArrive == NO)
				{
					if ([_comparedHistoricData updateData:dataSource forPeriod:analysisPeriod portfolioItem:_watchportfolio.comparedPortfolioItem])
					{
						//[indexView setNeedsDisplay];
						_comparedHasArrive = YES;
					}
				}
				else
				{
					BOOL hasUpdate =[_comparedHistoricData updateData:dataSource forPeriod:analysisPeriod portfolioItem:_watchportfolio.comparedPortfolioItem];
                    if (hasUpdate) {
                        indexScaleView.comparedHistoricData = _comparedHistoricData;
                    }
//					[indexView setNeedsDisplay];
					
				}
//			}
			//return;
		}else{
            [historicData updateData:dataSource forPeriod:analysisPeriod portfolioItem:portfolioItem];
        }
	
		
//		if (!forceUpdate && !hasUpdate)
//			return;
		
		if(hasArrive == NO)
		{
            
            
			forceUpdate = NO;
			dataSource = historicData;
            indexScaleView.comparedHistoricData = _comparedHistoricData;
			[self updateDateRange];
			if(hasArrive == NO && YESNO == YES)
			{
			//	NSLog(@"hasArr");
				hasArrive = YES;
                [self checkDate];
			}
			
			
			//NSLog(@"HDataArr");
			theHighestValue = [self getTheHightestValue];
			theLowestValue = [self getTheLowestValue];
			
//            NSLog(@"==========theHighestValue %f", theHighestValue);
//            NSLog(@"==========theLowestValue %f", theLowestValue);
            
			//[_comparedHistoricData updateData:dataSource forPeriod:analysisPeriod portfolioItem:_watchportfolio.comparedPortfolioItem];
			
			indexView.historicData = dataSource;
			indexScaleView.historicData = dataSource;
            if (analysisPeriod<3) {
                indexScaleView.comparedHistoricData = _comparedHistoricData;
            }
			_dataModal.operationalIndicator.historicData = dataSource;
            if ([newDataArray count] < [_comparedHistoricData.dataArray count]) {
                newDataArray = [[NSMutableArray alloc]initWithArray:_comparedHistoricData.dataArray];
                [_dataModal.operationalIndicator prepareDataToDrawByPeriod];
            }
        
            theHighestVolume = [self getTheHightestVolume];
			theLowestVolume = [self getTheLowestVolume];
			[indexView prepareDataToDraw];
			[indexView setNeedsDisplay];
			[indexScaleView getHigestAndLowest];
			[indexScaleView setNeedsDisplay];
			upperValueView.highest = indexScaleView.highestValue;
			upperValueView.lowest = indexScaleView.lowestValue;
			[upperValueView updateLabels];
			[upperDateView updateLabels];
			
			bottonView1.historicData = dataSource;
			[bottonView1 setNeedsDisplay];
			
			bottonView2.historicData = dataSource;
			[bottonView2 setNeedsDisplay];
            
            [self.view hideHUD];
			UInt8 type = self.historicType;
			int num = [self getDateNum];
			switch (analysisPeriod) 
			{   case AnalysisPeriodDay:
                    break;
				case AnalysisPeriodWeek:
				case AnalysisPeriodMonth: 
				{
					DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
					preDate = historic.date;
					break;
				}
									
				case AnalysisPeriod5Minute: 
				case AnalysisPeriod15Minute:
				case AnalysisPeriod30Minute:
				case AnalysisPeriod60Minute:
				{
					DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
					preDate = historic.date;
					preTime = historic.time;
					break;
				}
			}
			
            //wiser
            //[_dataModal.operationalIndicator prepareDataToDrawByPeriod];
		}
		else
		{
			float temp1,temp2 ;
			temp1 = [self getTheHightestValue];
			temp2 = [self getTheLowestValue];
			dataSource = historicData;
            indexScaleView.comparedHistoricData = _comparedHistoricData;
			int num = [self getDateNum];
			BOOL bChange = NO; 
			if(temp1 != theHighestValue || temp2 != theLowestValue)
			{
				theHighestValue = temp1;
				theLowestValue = temp2;
//                NSLog(@"==========temp1 theHighestValue %f", theHighestValue);
//                NSLog(@"==========temp2 theLowestValue %f", theLowestValue);
				bChange = YES;
			}
			if([indexView prepareDataToDraw])
				bChange = YES;
			if(bChange)  //最大最小值改變 
			{					
			//	NSLog(@"REDRAW ALL");
				[self updateDateRange];
				theHighestVolume = [self getTheHightestVolume];
				theLowestVolume = [self getTheLowestVolume];
				indexView.historicData = dataSource;
				indexScaleView.historicData = dataSource;
                indexScaleView.comparedHistoricData = _comparedHistoricData;
                _dataModal.operationalIndicator.historicData =dataSource;
                [_dataModal.operationalIndicator prepareDataToDrawByPeriod];
			//	[indexView prepareDataToDraw];
				[indexView setNeedsDisplay];
				[indexScaleView getHigestAndLowest];
				[indexScaleView setNeedsDisplay];
				upperValueView.highest = indexScaleView.highestValue;
				upperValueView.lowest = indexScaleView.lowestValue;
				[upperValueView updateLabels];
				[upperDateView updateLabels];
                
				bottonView1.historicData = dataSource;
				[bottonView1 setNeedsDisplay];
				
				bottonView2.historicData = dataSource;
				[bottonView2 setNeedsDisplay];
                
                [self.view hideHUD];
				UInt8 type = self.historicType;
				switch (analysisPeriod) 
				{
                    case AnalysisPeriodDay:
                        break;
					case AnalysisPeriodWeek:
					case AnalysisPeriodMonth: 
					{
						DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
						preDate = historic.date;
						break;
					}
						
					case AnalysisPeriod5Minute: 
					case AnalysisPeriod15Minute:
					case AnalysisPeriod30Minute:
					case AnalysisPeriod60Minute:
					{
						DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
						preDate = historic.date;
						preTime = historic.time;
						break;
					}
				}
				
			}
			else if(num >= DateNumMax)
			{   //wiser
               // [_dataModal.operationalIndicator prepareDataToDrawByPeriod];
				
                BOOL bRedrawAll = NO;
				UInt8 type = self.historicType;
				switch (analysisPeriod) 
				{
                    case AnalysisPeriodDay:
                        break;
					case AnalysisPeriodWeek:
					case AnalysisPeriodMonth: 
					{
						DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
						if(preDate != historic.date)
						{
							bRedrawAll = YES; 
							preDate = historic.date;
						}
						else
						{
							bRedrawAll = NO;
						}
						break;
					}
						
					case AnalysisPeriod5Minute: 
					case AnalysisPeriod15Minute:
					case AnalysisPeriod30Minute:
					case AnalysisPeriod60Minute:
					{
						DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
						if(	preDate == historic.date && preTime == historic.time)
						{
							bRedrawAll = NO; 
						}
						else
						{
							bRedrawAll = YES;
							preDate = historic.date;
							preTime = historic.time;
						}
						break;
					}
						
				}
				if(bRedrawAll)
				{
				//	NSLog(@"drawAll");
					theHighestVolume = [self getTheHightestVolume];
					theLowestVolume = [self getTheLowestVolume];
					indexView.historicData = dataSource;
					indexScaleView.historicData = dataSource;
                    indexScaleView.comparedHistoricData = _comparedHistoricData;
                    _dataModal.operationalIndicator.historicData =dataSource;
                    [_dataModal.operationalIndicator prepareDataToDrawByPeriod];
					//[indexView prepareDataToDraw];
					[indexView setNeedsDisplay];
					[indexScaleView getHigestAndLowest];
					[indexScaleView setNeedsDisplay];
					upperValueView.highest = indexScaleView.highestValue;
					upperValueView.lowest = indexScaleView.lowestValue;
					[upperValueView updateLabels];
					[upperDateView updateLabels];
					bottonView1.historicData = dataSource;
					[bottonView1 setNeedsDisplay];
					bottonView2.historicData = dataSource;
					[bottonView2 setNeedsDisplay];
                    
				}
				else
				{
				//	NSLog(@"redraw");
					CGRect frame = indexView.frame;
					float width = 2 * BarDateWidth + 1; // 重畫的大小
					float x = (frame.origin.x+frame.size.width) - width-1;
					
					theHighestVolume = [self getTheHightestVolume];
					theLowestVolume = [self getTheLowestVolume];
					indexView.historicData = dataSource;
					indexScaleView.historicData = dataSource;
                    indexScaleView.comparedHistoricData = _comparedHistoricData;
                    _dataModal.operationalIndicator.historicData =dataSource;
                    [_dataModal.operationalIndicator prepareDataToDrawByPeriod];
					//[indexView prepareDataToDraw];

                    [indexView setNeedsDisplay];
//                    [indexView setNeedsDisplayInRect:CGRectMake(x, indexView.frame.origin.y, width, indexView.frame.size.height)];

					float xStart,xEnd;
					xStart = indexScaleView.frame.origin.x;
					xEnd = xStart+indexScaleView.frame.size.width;
					if(x >= xStart && x <= xEnd)
					{
						if([indexScaleView getHigestAndLowest])
						{
							[indexScaleView setNeedsDisplay];
							upperValueView.highest = indexScaleView.highestValue;
							upperValueView.lowest = indexScaleView.lowestValue;
							[upperValueView updateLabels];
						}
						else
						{
							float drawWidth = width;
							if(width > indexScaleView.frame.size.width)
							{
								drawWidth = indexScaleView.frame.size.width;
							}
							[indexScaleView setNeedsDisplayInRect:CGRectMake(x-xStart, indexScaleView.frame.origin.y, drawWidth, indexScaleView.frame.size.height)];
							upperValueView.highest = indexScaleView.highestValue;
							upperValueView.lowest = indexScaleView.lowestValue;
							[upperValueView updateLabels];
                            [self.view hideHUD];

						}
						
					}
					
					theHighestVolume = [self getTheHightestVolume];
                    theLowestVolume = [self getTheLowestVolume];

					//[bottonView1 setNeedsDisplayInRect:CGRectMake(x, bottonView1.frame.origin.y, width, bottonView1.frame.size.height)];
					[bottonView1 setNeedsDisplay];
					bottonView2.historicData = dataSource;
					//[bottonView2 setNeedsDisplayInRect:CGRectMake(x, bottonView2.frame.origin.y, width, bottonView2.frame.size.height)];
					[bottonView2 setNeedsDisplay];
				}
				
			}
			else
			{
				int redrawXlines;
				int num = [self getDateNum];
				if(num != xLines && num>xLines)
				{
					
					redrawXlines = num - xLines;
					[self updateDateRange];
					[upperDateView updateLabels];
				}
				else
				{
					redrawXlines = 0;
				}
				CGRect frame = indexView.frame;
				float width = (redrawXlines+2) * BarDateWidth + 1; // 重畫的大小  加最右邊邊線
				float x = (frame.origin.x+frame.size.width) - width-1;
				
				theHighestVolume = [self getTheHightestVolume];
				theLowestVolume = [self getTheLowestVolume];
				indexView.historicData = dataSource;
				indexScaleView.historicData = dataSource;
                indexScaleView.comparedHistoricData = _comparedHistoricData;
                _dataModal.operationalIndicator.historicData =dataSource;
                
                if ([newDataArray count] < [_comparedHistoricData.dataArray count]) {
                    newDataArray = [[NSMutableArray alloc]initWithArray:_comparedHistoricData.dataArray];
                    [_dataModal.operationalIndicator prepareDataToDrawByPeriod];
                }
            
                [bottonView1 setNeedsDisplay];
                [bottonView2 setNeedsDisplay];
				//[indexView prepareDataToDraw];

                [indexView setNeedsDisplay];
//                [indexView setNeedsDisplayInRect:CGRectMake(x, indexView.frame.origin.y, width, indexView.frame.size.height)];
				float xStart,xEnd;
				xStart = indexScaleView.frame.origin.x;
				xEnd = xStart+indexScaleView.frame.size.width;
				if(x >= xStart && x <= xEnd)
				{
					if([indexScaleView getHigestAndLowest])
					{
						[indexScaleView setNeedsDisplay];
						upperValueView.highest = indexScaleView.highestValue;
						upperValueView.lowest = indexScaleView.lowestValue;
						[upperValueView updateLabels];
                        [self.view hideHUD];
					}
					else
					{
						//	NSLog(@"indexScaleView");
						float drawWidth = width;
						if(width > indexScaleView.frame.size.width)
						{
							drawWidth = indexScaleView.frame.size.width;
						}
						[indexScaleView setNeedsDisplayInRect:CGRectMake(x-xStart, indexScaleView.frame.origin.y, drawWidth, indexScaleView.frame.size.height)];
						upperValueView.highest = indexScaleView.highestValue;
						upperValueView.lowest = indexScaleView.lowestValue;
						[upperValueView updateLabels];
					}
					
				}
				
				
				bottonView1.historicData = dataSource;
			//	[bottonView1 setNeedsDisplayInRect:CGRectMake(x, bottonView1.frame.origin.y, width, bottonView1.frame.size.height)];
				[bottonView1 setNeedsDisplay];
				bottonView2.historicData = dataSource;
			//	[bottonView2 setNeedsDisplayInRect:CGRectMake(x, bottonView2.frame.origin.y, width, bottonView2.frame.size.height)];
				[bottonView2 setNeedsDisplay];
				UInt8 type = self.historicType;
				switch (analysisPeriod) 
				{
                    case AnalysisPeriodDay:
                        break;
					case AnalysisPeriodWeek:
					case AnalysisPeriodMonth: 
					{
						DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
						preDate = historic.date;
						break;
					}
						
					case AnalysisPeriod5Minute: 
					case AnalysisPeriod15Minute:
					case AnalysisPeriod30Minute:
					case AnalysisPeriod60Minute:
					{
						DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:num-1];
						preDate = historic.date;
						preTime = historic.time;
						break;
					}
				}
			}
			
						
		}
		if([self crossVisible])
			[self updateCrossView];
	}	
    //wiser
    [_dataModal.operationalIndicator prepareDataToDrawByPeriod];
	//資訊地雷 query date . (queryType = 0)
	if(isNeedOpenInformationMine)
	{
		
		if(!isQueryNewsCount)
		{
//			UInt16  todayDate = [ValueUtil stkDateFromNSDate:[NSDate date]];
//			[informationMine informationMineBySecurityNum:portfolioItem->commodityNo QueryType:0 SubType:1 TodayDate:todayDate
//												StartTime:[ValueUtil stkDateFromNSDate:chartOldestDate] EndTime:todayDate];
//			
			isQueryNewsCount = YES;
		}
		
	}

}




#pragma mark -
#pragma mark update and reset view data

- (void)updateDateRange 
{ // notify 回來才做
	
    [self resetZoomTransform];
	
    int dateNum = [self getDateNum];
	xLines = dateNum;
	//if (dateNum == xLines) return;
	
	float w0 = indexScrollView.bounds.size.width + 1;
	
    float w = BarDateWidth * xLines;
    float x;
	
    if (w+2 >= w0) 
	{
        x = 0;
		if(hasArrive == NO){
            if (changeSizeFlag) {
                indexScrollView.contentOffset = _oldPoint;
                changeSizeFlag = NO;
            }else{
                indexScrollView.contentOffset = CGPointMake(w+2-w0, indexScrollView.contentOffset.y);
            }
        }else{
            indexScrollView.contentOffset = CGPointMake(w+2-w0, indexScrollView.contentOffset.y);
        }
    }
    else
	{
        x = w0-(w+2)+1;
        if(hasArrive == NO)
			indexScrollView.contentOffset = CGPointMake(1, indexScrollView.contentOffset.y);
    }
	CGRect temp = indexScaleView.frame;
	if (w+2 >= w0) 
	{
		indexScaleView.frame = CGRectMake(indexScrollView.contentOffset.x, indexScaleView.frame.origin.y, indexScrollView.bounds.size.width, indexScaleView.frame.size.height);
		indexScaleView.offsetX = 1;
	}
	else
	{
		indexScaleView.frame = CGRectMake(x+1, indexScaleView.frame.origin.y, w-1, indexScaleView.frame.size.height);
		indexScaleView.offsetX = 0;
	}
	temp = indexScaleView.frame;
    upperDateScrollView.contentOffset = CGPointMake(indexScrollView.contentOffset.x, upperDateScrollView.contentOffset.y);
	
//	CGRect temp = CGRectMake(indexScrollView.contentOffset.x, indexScaleView.frame.origin.y, indexScaleView.frame.size.width, indexScaleView.frame.size.height);
	
    CGFloat width = w * ChartZoomOrigin;
    baseWidth = (w ? w+2 : 0) * ChartZoomOrigin;
	
    indexView.xLines = xLines;
    indexView.chartFrame = CGRectMake(0, 0, width, indexView.chartFrame.size.height);
	
    indexView.frame = CGRectMake(x, 0, baseWidth, indexView.frame.size.height);
    indexScrollView.contentSize = CGSizeMake(baseWidth, indexView.frame.size.height);
	
    upperDateView.frame = CGRectMake(x, 0, baseWidth, upperDateView.frame.size.height);
    upperDateScrollView.contentSize = CGSizeMake(baseWidth, upperDateScrollView.contentSize.height);
	
    [bottonView1 updateDateRange:xLines chartWidth:width frameX:x frameWidth:baseWidth];
    [bottonView2 updateDateRange:xLines chartWidth:width frameX:x frameWidth:baseWidth];
	
    [self zoomToMinScale];
    indexScaleView.hidden = NO;
	//	[indexScrollView bringSubviewToFront:indexScaleView];
    
}

-(void)checkDate{
    if (_arrowUpDownType != 0 && hasArrive && analysisPeriod == _arrowType) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[historicData.dataArray sortedArrayUsingDescriptors:sortDescriptors]];
        
        if ([sortedArray count]>0){
            DecompressedHistoricData *firstHistoric = [sortedArray objectAtIndex:0];
            DecompressedHistoricData *lastHistoric = [sortedArray lastObject];
            NSString * alertString = @"";
            if (_arrowUpDownType == 3) {
                if (firstHistoric.date>_buyDay || _buyDay>lastHistoric.date) {
                    alertString = NSLocalizedStringFromTable(@"買進日超出日期範圍", @"Draw", @"");
                }
                if (_sellDay>lastHistoric.date || firstHistoric.date>_sellDay ) {
                    if ([alertString isEqualToString:@""]) {
                        alertString = NSLocalizedStringFromTable(@"賣出日超出日期範圍", @"Draw", @"");
                    }else{
                        alertString = NSLocalizedStringFromTable(@"超出日期範圍同時成立", @"Draw", @"");
                    }
                }
            }else if(_arrowUpDownType == 4 || _arrowUpDownType == 5){
                
                for (NSNumber * dateNumber in [_dateDictionary allKeys]) {
                    NSMutableDictionary * dict =[_dateDictionary objectForKey:dateNumber];
                    for (NSString * type in [dict allKeys]) {
                        UInt16 date = [dateNumber intValue];
                        arrowData * data = [dict objectForKey:type];
                        if (data->arrowType==1 && firstHistoric.date>date) {
                            alertString = NSLocalizedStringFromTable(@"買進日超出日期範圍", @"Draw", @"");
                            break;
                        }
                    }
                }
                
                for (NSNumber * dateNumber in [_dateDictionary allKeys]) {
                    NSMutableDictionary * dict =[_dateDictionary objectForKey:dateNumber];
                    for (NSString * type in [dict allKeys]) {
                        UInt16 date = [dateNumber intValue];
                        arrowData * data = [dict objectForKey:type];
                        if (data->arrowType==2 && firstHistoric.date > date) {
                            if ([alertString isEqualToString:@""]) {
                                alertString = NSLocalizedStringFromTable(@"賣出日超出日期範圍", @"Draw", @"");
                            }else{
                                alertString = NSLocalizedStringFromTable(@"超出日期範圍同時成立", @"Draw", @"");
                            }
                            break;
                        }
                    }
                }
            }
            if (![alertString isEqualToString:@""]) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:alertString message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            }
        }
    }
}

- (void)updateUpperView:(int)index
{
//	NSMutableDictionary * data = [_dataModal.operationalIndicator getDataByIndex:[self getSeqNumberFromPointXValue:crossX]];
	//只在沒開啓多股走勢分析時執行
	if (!_twoLine)
	{
        int count = [historicData tickCount:analysisPeriod];
		// update upper view 的技術指標 數值 (移動平均線 布林格通道)		
		if(self.upperViewIndicator == UpperViewMAIndicator) // 移動平均線
		{
			double shortMAValue = [indexView getMovingAvergeValueFrom:index parm:0];		
			double middleMAValue = [indexView getMovingAvergeValueFrom:index parm:1];			
			double longMAValue = [indexView getMovingAvergeValueFrom:index parm:2];
            
            double beforeMA1Value = [indexView getMovingAvergeValueFrom:index-1 parm:0];
			double beforeMA2Value = [indexView getMovingAvergeValueFrom:index-1 parm:1];
			double beforeMA3Value = [indexView getMovingAvergeValueFrom:index-1 parm:2];
            
            double MA4Value = [indexView getMovingAvergeValueFrom:index parm:3];
			double MA5Value = [indexView getMovingAvergeValueFrom:index parm:4];
			double MA6Value = [indexView getMovingAvergeValueFrom:index parm:5];
            
            double beforeMA4Value = [indexView getMovingAvergeValueFrom:index-1 parm:3];
			double beforeMA5Value = [indexView getMovingAvergeValueFrom:index-1 parm:4];
			double beforeMA6Value = [indexView getMovingAvergeValueFrom:index-1 parm:5];
			if (index<count) {
                [upperView loadUpperViewIndicatorValueFor:upperViewIndicator withParmValue1:shortMAValue parmValue2:middleMAValue parmValue3:longMAValue parmValue4:beforeMA1Value parmValue5:beforeMA2Value parmValue6:beforeMA3Value];
                [upperView loadMAValueFor:upperViewIndicator withMa4Param:MA4Value Ma5Param:MA5Value Ma6Param:MA6Value Ma4BeforeParam:beforeMA4Value Ma5BeforeParam:beforeMA5Value Ma6BeforeParam:beforeMA6Value];
            }
			
		}
		else if(self.upperViewIndicator == UpperViewBBIndicator) //布林格通道
		{
			double maValue = [indexView getBollingerFrom:index parm:0]; //抓 代布林格參數的ＭＡ
			double highBBValue = [indexView getBollingerFrom:index parm:1]; //抓 high BB value
			double lowBBalue = [indexView getBollingerFrom:index parm:2]; // 抓 low BB value
            
            double beforeMAValue = [indexView getBollingerFrom:index-1 parm:0]; //抓 代布林格參數的ＭＡ
			double beforeHighBBValue = [indexView getBollingerFrom:index-1 parm:1]; //抓 high BB value
			double beforeLowBBalue = [indexView getBollingerFrom:index-1 parm:2]; // 抓 low BB value
			
            if (index<count) {
                [upperView loadUpperViewIndicatorValueFor:upperViewIndicator withParmValue1:maValue parmValue2:highBBValue parmValue3:lowBBalue parmValue4:beforeMAValue parmValue5:beforeHighBBValue parmValue6:beforeLowBBalue];
            }
		}else if (self.upperViewIndicator == UpperViewSARIndicator){
            double sarValue = [_dataModal.operationalIndicator getValueFrom:index parm:@"SAR"];
			double beforeSarValue = [_dataModal.operationalIndicator getValueFrom:index-1 parm:@"SAR"];
            if (index<count) {
                [upperView loadUpperViewIndicatorValueFor:upperViewIndicator withParmValue1:sarValue parmValue2:beforeSarValue parmValue3:-1 parmValue4:-1 parmValue5:-1 parmValue6:-1];
            }
        }
		[upperView setNeedsDisplay]; 
		
        if (index<count) {
            [bottonView1 updateValueWithIndex:index];
            [bottonView2 updateValueWithIndex:index];
            [bottonView1 setNeedsDisplay];
            [bottonView2 setNeedsDisplay];
        }
		
		
	}else{
        int count = [historicData tickCount:analysisPeriod];
        float comClose = [(NSNumber *)[indexScaleView.compDictionary objectForKey:[NSNumber numberWithInt:index]]floatValue];
        float beforeComClose =[(NSNumber *)[indexScaleView.compDictionary objectForKey:[NSNumber numberWithInt:index-1]]floatValue];
        DecompressedHistoricData *hist=[indexScaleView.historicData copyHistoricTick:analysisPeriod sequenceNo:index];
        float close = hist.close;
        DecompressedHistoricData *beforeHist=[indexScaleView.historicData copyHistoricTick:analysisPeriod sequenceNo:index-1];
        float beforeClose = beforeHist.close;
        if (index<count) {
            [upperView loadUpperViewIndicatorValueFor:UpperViewTwoLine withParmValue1:close parmValue2:comClose parmValue3:beforeClose parmValue4:beforeComClose parmValue5:-1 parmValue6:-1];
        }
        [upperView setNeedsDisplay];
		
        if (index<count) {
            [bottonView1 updateValueWithIndex:index];
            [bottonView2 updateValueWithIndex:index];
            [bottonView1 setNeedsDisplay];
            [bottonView2 setNeedsDisplay];
        }
    }
	
	
	
}


- (void)resetDisplay 
{
    [historicData.dataArray removeAllObjects];
    forceUpdate = YES;
	hasArrive = NO;
    _comparedHasArrive = NO;
    
	[indexView prepareDataToDraw];
    [indexView setNeedsDisplay];

	[indexScaleView getHigestAndLowest];
	[indexScaleView setNeedsDisplay];

    theHighestVolume = [self getTheHightestVolume];
    theLowestVolume = [self getTheLowestVolume];
    [bottonView1 setNeedsDisplay];
    [bottonView2 setNeedsDisplay];
	upperValueView.highest = indexScaleView.highestValue;
	upperValueView.lowest = indexScaleView.lowestValue;

    [upperValueView updateLabels];
    [upperDateView updateLabels];
	[self SetTimer];
}

-(void)reDisplayIndicators
{
    theHighestVolume = [self getTheHightestVolume];
    theLowestVolume = [self getTheLowestVolume];
    [bottonView1 setNeedsDisplay];
    [bottonView2 setNeedsDisplay];
	[upperView setNeedsDisplay];
	[indexView prepareDataToDraw];
	[indexView setNeedsDisplay];
	[indexScaleView getHigestAndLowest];
	[indexScaleView setNeedsDisplay];
	
}

#pragma mark -
#pragma mark cross info view

- (DecompressedHistoricData *)copyHistoricDataAtX:(float)x 
{
	
	// seq 再開啓走勢比較後 可能會沒有值
	
    UInt8 type = self.historicType;
    UInt32 histCount = [historicData tickCount:type];
    if (histCount == 0) return nil;
	
    float xScale = indexView.chartFrame.size.width / xLines;
    int x0 = indexView.chartFrameOffset.x;
    int n = x > x0 ? (x - x0) / xScale : 0; //
    int seq;
	
    if (analysisPeriod == AnalysisPeriodDay) 
	{
		
        NSMutableArray *indexes = indexView.historicDataIndexes;
        NSUInteger indexCount = indexes.count;
        NSUInteger count = indexCount * 2 + 1;
        int n0 = n;
        NSNumber *s;
		
        for (int i = 2; i <= count; i++) 
		{
			
			if(n==0 || (n==1 && indexCount==1))
			{ //第一筆資料與第一筆資料之前的pixel || 只有一筆資料
				
				seq = 0;
				break;
				
			}
            else if (n >= 0 && n < indexCount)
			{
				
                s = [indexes objectAtIndex:n];
				
                if ((id)s != [NSNull null]) 
				{
					
                    seq = [s shortValue];
                    if (seq < histCount)
                        break;
                }
            }
			
			else if(n >= indexCount)
			{ //最後一筆資料或最後一筆資料之後的pixel
				
				seq = [[indexes objectAtIndex:[indexes count]-1] shortValue];
				break;
				
			}
			
            n = i%2==0 ? n0+i/2 : n0-i/2;
        }
    }
	
    else
	{
        if (n >= histCount)
            n = histCount - 1;
        seq = n;
    }
	
    crossX = n * xScale + indexView.chartFrameOffset.x;
	
    return [historicData copyHistoricTick:type sequenceNo:seq];
}

- (DecompressedHistoricData *)copyHistoricDataBeforeX:(float)x
{
	
	// seq 再開啓走勢比較後 可能會沒有值
	
    UInt8 type = self.historicType;
    UInt32 histCount = [historicData tickCount:type];
    if (histCount == 0) return nil;
	
    float xScale = indexView.chartFrame.size.width / xLines;
    int x0 = indexView.chartFrameOffset.x;
    int n = x > x0 ? (x - x0) / xScale : 0; //
    int seq;
	
    if (analysisPeriod == AnalysisPeriodDay)
	{
		
        NSMutableArray *indexes = indexView.historicDataIndexes;
        NSUInteger indexCount = indexes.count;
        NSUInteger count = indexCount * 2 + 1;
        int n0 = n;
        NSNumber *s;
		
        for (int i = 2; i <= count; i++)
		{
			
			if(n==0 || (n==1 && indexCount==1))
			{ //第一筆資料與第一筆資料之前的pixel || 只有一筆資料
				
				seq = 0;
				break;
				
			}
            else if (n >= 0 && n < indexCount)
			{
				
                s = [indexes objectAtIndex:n];
				
                if ((id)s != [NSNull null])
				{
					
                    seq = [s shortValue];
                    if (seq < histCount)
                        break;
                }
            }
			
			else if(n >= indexCount)
			{ //最後一筆資料或最後一筆資料之後的pixel
				
				seq = [[indexes objectAtIndex:[indexes count]-1] shortValue];
				break;
				
			}
			
            n = i%2==0 ? n0+i/2 : n0-i/2;
        }
    }
	
    else
	{
        if (n >= histCount)
            n = histCount - 1;
        seq = n;
    }
	
    crossX = n * xScale + indexView.chartFrameOffset.x;
    seq = (seq <= 0)?1:seq;
    return [historicData copyHistoricTick:type sequenceNo:seq-1];
}

//-(int)getSeqNumberFromPointXValue:(float)x
//{
//	
//	UInt8 type = self.historicType;
//    UInt32 histCount = [historicData tickCount:type];
//    if (histCount == 0) return -1;
//	
//    float xScale = indexView.chartFrame.size.width / xLines;
//    int x0 = indexView.chartFrameOffset.x;
//    int n = x > x0 ? (x - x0) / xScale : 0; //
//    int seq;
//	
//    if (analysisPeriod == AnalysisPeriodDay)
//	{
//		
//        NSMutableArray *indexes = indexView.historicDataIndexes;
//        NSUInteger indexCount = indexes.count;
//       // int count = indexCount * 2 + 1;
//		
//        NSNumber *s;
//		
//      //  for (int i = 2; i <= count; i++) 
//		//{
//			
//			if(n==0 || (n==1 && indexCount==1))//第一筆資料與第一筆資料之前的pixel || 只有一筆資料
//			{ 
//				
//				seq = 0;
//		//		break;
//				
//			}
//            else if (n >= 0 && n < indexCount)
//			{
//				
//                s = [indexes objectAtIndex:n];
//				
//                if ((id)s != [NSNull null])
//				{
//					
//                    seq = [s shortValue];
//           //         if (seq < histCount)
//          //              break;
//                }
//            }
//			
//			else if(n >= indexCount)//最後一筆資料或最後一筆資料之後的pixel
//			{ 
//				if ([indexes count]>0) {
//                    seq = [[indexes objectAtIndex:[indexes count]-1] shortValue];
//
//                }
//		//		break;
//				
//			}
//			
//      //  }
//    }
//	
//    else 
//	{
//        if (n >= histCount)
//            n = histCount - 1;
//        seq = n;
//    }
//	
//    return n;//seq;
//	
//}

-(int)getSeqNumberFromPointXValue:(float)x
{
    x-=_chartFrameOffset.x;
	UInt8 type = self.historicType;
    UInt32 histCount = [historicData tickCount:type];
    if (histCount == 0) return -1;
	
    float xScale = self.barDateWidth;
    int x0 =0;// offsetX;
    int n = x > x0 ? (x - x0) / xScale : 0;
	
    if (n >= histCount)
		n = histCount - 1;
    
	return n;
}

- (BOOL)crossVisible 
{
    return self.crossInfoView.isCrossInfoShowing;
}

- (CrossInfoView *)crossInfoView
{
	
    return crossInfoPortrait;
}

- (void)openCrossView:(BOOL)toOpen animated:(BOOL)animated 
{
	
    UIView *view = self.view;
    CrossInfoView *crossInfoView = self.crossInfoView;
    crossInfoView.isCrossInfoShowing = toOpen;
	crossInfoView.backgroundColor = [UIColor whiteColor];
    //crossInfoView.frame = CGRectMake(crossInfoView.frame.origin.x,crossInfoView.frame.origin.y,110, 190);
    
    if (_twoLine) {
        crossInfoView.frame = CGRectMake(crossInfoView.frame.origin.x,crossInfoView.frame.origin.y,124, 125);
        crossInfoView.dateLabel.hidden = NO;
        crossInfoView.openLabelTitle.hidden = YES;
        crossInfoView.openLabel.hidden = YES;
        crossInfoView.highLabelTitle.hidden = YES;
        crossInfoView.highLabel.hidden = YES;
        crossInfoView.lowLabelTitle.hidden = YES;
        crossInfoView.lowLabel.hidden = YES;
        crossInfoView.closeLabelTitle.hidden = YES;
        crossInfoView.closeLabel.hidden = YES;
        crossInfoView.chgLabelTitle.hidden = YES;
        crossInfoView.chgLabel.hidden = YES;
        crossInfoView.chgPerLabelTitle.hidden = YES;
        crossInfoView.chgPerLabel.hidden = YES;
        crossInfoView.volumeLabelTitle.hidden = YES;
        crossInfoView.volumeLabel.hidden = YES;
        
        crossInfoView.stock1CloseTitle.hidden = NO;
        crossInfoView.stock1Close.hidden = NO;
        crossInfoView.stock1VolumeTitle.hidden = NO;
        crossInfoView.stock1Volume.hidden = NO;
        crossInfoView.stock2CloseTitle.hidden = NO;
        crossInfoView.stock2Close.hidden = NO;
        crossInfoView.stock2VolumeTitle.hidden = NO;
        crossInfoView.stock2Volume.hidden = NO;
        
    }else{
        if (_arrowUpDownType == 4 || _arrowUpDownType == 5) {
            crossInfoView.chgPerLabelTitle.hidden = YES;
            crossInfoView.volumeLabelTitle.hidden = YES;
            crossInfoView.volumeLabel.hidden = YES;
            crossInfoView.frame = CGRectMake(crossInfoView.frame.origin.x,crossInfoView.frame.origin.y,124, 165);
        }else{
            crossInfoView.chgPerLabelTitle.hidden = NO;
            crossInfoView.volumeLabelTitle.hidden = NO;
            crossInfoView.volumeLabel.hidden = NO;
            crossInfoView.frame = CGRectMake(crossInfoView.frame.origin.x,crossInfoView.frame.origin.y,124, 185);
        }
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"tw"])
        {
            crossInfoView.chgPerLabelTitle.hidden = YES;
        }
        
        crossInfoView.dateLabel.hidden = NO;
        crossInfoView.openLabelTitle.hidden = NO;
        crossInfoView.openLabel.hidden = NO;
        crossInfoView.highLabelTitle.hidden = NO;
        crossInfoView.highLabel.hidden = NO;
        crossInfoView.lowLabelTitle.hidden = NO;
        crossInfoView.lowLabel.hidden = NO;
        crossInfoView.closeLabelTitle.hidden = NO;
        crossInfoView.closeLabel.hidden = NO;
        crossInfoView.chgLabelTitle.hidden = NO;
        crossInfoView.chgLabel.hidden = NO;
        crossInfoView.chgPerLabel.hidden = NO;
        
        crossInfoView.stock1CloseTitle.hidden = YES;
        crossInfoView.stock1Close.hidden = YES;
        crossInfoView.stock1VolumeTitle.hidden = YES;
        crossInfoView.stock1Volume.hidden = YES;
        crossInfoView.stock2CloseTitle.hidden = YES;
        crossInfoView.stock2Close.hidden = YES;
        crossInfoView.stock2VolumeTitle.hidden = YES;
        crossInfoView.stock2Volume.hidden = YES;
    }
    
    if (toOpen) 
	{
        [bottonView1 resetTypeControl];
        [bottonView2 resetTypeControl];
        crossLineView.hidden = NO;
        crossInfoView.hidden = NO;
        [view bringSubviewToFront:crossLineView];
        [view bringSubviewToFront:crossInfoView];
        if ((_autoLayoutIndex%3)==2) {
            crossLineView.frame =CGRectMake(crossLineView.frame.origin.x, upperView.frame.origin.y+30, crossLineView.frame.size.width, crossLineView.frame.size.height);
        }else{
           crossLineView.frame =CGRectMake(crossLineView.frame.origin.x, upperView.frame.origin.y+15, crossLineView.frame.size.width, crossLineView.frame.size.height);
        }
        
    }
    else 
	{
        [view sendSubviewToBack:crossLineView];
        crossLineView.hidden = YES;
        crossInfoView.hidden = YES;
        crossLineView.crossPoint = CGPointZero;
        crossLineView.horizontalHidden = NO;
//		indexScrollView.scrollEnabled = YES;
		//關掉croll info view 清除botton view的指標數值
		[bottonView1 updateValueWithIndex:-1];
		//[bottonView1.dataView setNeedsDisplay];
		[bottonView2 updateValueWithIndex:-1];
		//[bottonView2.dataView setNeedsDisplay];
		
		//為了清掉 upperView的技術指標數值
		//[upperView setNeedsDisplay];
		
		
    }
	
    if (animated)
	{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0];
    }
	
    CGRect r = crossInfoView.frame;
	
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))  
	{ //直式
        if (toOpen)
		{
			//			crossInfoView.alpha = 0.3;
            if ((_autoLayoutIndex %3)==2) {
                r.origin.y = 118;
            }else{
                r.origin.y = 103;
            }
            
		}
        else // close
		{
			//			crossInfoView.alpha = 0;
            r.origin.y = view.bounds.size.height;
		}
    }
    else 
	{ //橫式
        if (toOpen)
            r.origin.y = 15;
        else // close
            r.origin.y = view.bounds.size.height;
    }
    if (_arrowUpDownType == 4 || _arrowUpDownType == 5) {
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            r.origin.y = 57;
        }else{
            r.origin.y = 17;
        }
        
        
        
    }
    crossInfoView.frame = r;
    if (animated)
        [UIView commitAnimations];
}

- (void)openCrossView:(BOOL)toOpen {
	
    [self openCrossView:toOpen animated:NO];
}

- (void)resetCrossView
{
	
    pressTouching = NO;
    timestamp = 0;
	[bottonView1 updateValueWithIndex:-1];
	[bottonView1.dataView setNeedsDisplay];
	[bottonView2 updateValueWithIndex:-1];
	[bottonView2.dataView setNeedsDisplay];
	
    if (self.crossVisible)
        [self openCrossView:NO];
}

- (void)updateCrossView 
{
	
	DecompressedHistoricData *hist = [self copyHistoricDataAtX:crossX];
    DecompressedHistoricData *beforeHist = [self copyHistoricDataBeforeX:crossX];
	
    CGPoint crossPoint = CGPointZero;
	
    CrossInfoView *crossInfo = self.crossInfoView;
    UILabel *dateLabel = crossInfo.dateLabel;
    UILabel *openLabel = crossInfo.openLabel;
    UILabel *highLabel = crossInfo.highLabel;
    UILabel *lowLabel = crossInfo.lowLabel;
    UILabel *closeLabel = crossInfo.closeLabel;
    UILabel *volumeLabel = crossInfo.volumeLabel;
    UILabel *changeLabel = crossInfo.chgLabel;
    UILabel *changePerLabel = crossInfo.chgPerLabel;
    
	
    if (hist != nil) 
	{
		
        if (analysisPeriod < AnalysisPeriod5Minute){
            NSString * appid = [FSFonestock sharedInstance].appId;
            NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
            if ([group isEqualToString:@"us"])
            {
                dateLabel.text = [NSString stringWithFormat:@"%02d/%02d/%4d", (hist.date>>5)&0xF, hist.date&0x1F, (hist.date>>9)+1960];
            }else{
                dateLabel.text = [NSString stringWithFormat:@"%4d/%02d/%02d", (hist.date>>9)+1960, (hist.date>>5)&0xF, hist.date&0x1F];
            }
        }
            
        else 
		{
            DecompressedHistoric5Minute *hist5Min = (DecompressedHistoric5Minute *)hist;
            dateLabel.text = [NSString stringWithFormat:@"%02d   %02d:%02d", hist.date&0x1F,
							  hist5Min.time/60, hist5Min.time%60];
        }
		
        //NSString *format = hist.close < 1000 ? @"%.2f" : @"%.1f";
        openLabel.text = [CodingUtil ConvertPriceValueToString:hist.open withIdSymbol:idSymbol];//[NSString stringWithFormat:format, hist.open]; //開
        highLabel.text = [CodingUtil ConvertPriceValueToString:hist.high withIdSymbol:idSymbol]; //高
        lowLabel.text = [CodingUtil ConvertPriceValueToString:hist.low withIdSymbol:idSymbol];   //低
        closeLabel.text = [CodingUtil ConvertPriceValueToString:hist.close withIdSymbol:idSymbol]; //收
        float chg =hist.close-beforeHist.close;
        if (chg>0) {
            changeLabel.text =[NSString stringWithFormat:@"+%@",[CodingUtil ConvertPriceValueToString:chg withIdSymbol:idSymbol]]; //chg
        }else if (chg<0){
            changeLabel.text = [CodingUtil ConvertPriceValueToString:hist.close-beforeHist.close withIdSymbol:idSymbol]; //chg
        }
        
        float value =((hist.close-beforeHist.close)/beforeHist.close);
        if (value>0) {
            changePerLabel.text =[NSString stringWithFormat:@"+%@%%",[CodingUtil ConvertPriceValueToString:value * 100 withIdSymbol:idSymbol]]; //chg
        }else if (value<0){
            changePerLabel.text = [NSString stringWithFormat:@"%@%%",[CodingUtil ConvertPriceValueToString:((hist.close-beforeHist.close)/beforeHist.close)*100 withIdSymbol:idSymbol]]; //chg
        }

        if(beforeHist == nil){
            changeLabel.text = @"";
            changePerLabel.text = @"";
        }
        
        
        volumeLabel.text = [CodingUtil volumeRoundRownWithDouble:hist.volume * pow(1000, hist.volumeUnit)];
                
        UIColor *color = hist.close > hist.open ? [StockConstant PriceUpColor] :
		hist.close < hist.open ? [StockConstant PriceDownColor] : [UIColor blueColor];
        
        
        crossInfo.stock1Close.text = [CodingUtil ConvertPriceValueToString:hist.close withIdSymbol:idSymbol];
        crossInfo.stock1Volume.text =[CodingUtil volumeRoundRownWithDouble:hist.volume ];
        
        float stock2Close =[(NSNumber *)[indexScaleView.compDictionary objectForKey:[NSNumber numberWithInt:[self getSeqNumberFromPointXValue:crossX]]]floatValue];
        crossInfo.stock2Close.text =[NSString stringWithFormat:@"%.2f",stock2Close];
        
        float stock2Volume =[(NSNumber *)[indexScaleView.compVolumeDictionary objectForKey:[NSNumber numberWithInt:[self getSeqNumberFromPointXValue:crossX]]]floatValue];
        
        crossInfo.stock2Volume.text = [CodingUtil volumeRoundRownWithDouble:stock2Volume];
        
        
        
        openLabel.textColor = color;
        highLabel.textColor = color;
        lowLabel.textColor = color;
        closeLabel.textColor = color;
        volumeLabel.textColor = color;
        changeLabel.textColor = color;
        changePerLabel.textColor = color;
        		
//        if (_twoLine)
//		{
            //CGFloat h = indexScaleView.frame.size.height;
            int seq = [self getSeqNumberFromPointXValue:crossX];
            float y = [(NSNumber *)[indexScaleView.pointDictionary objectForKey:[NSNumber numberWithInt:seq]]floatValue];
            crossPoint = CGPointMake(crossX,y);
            //crossPoint = CGPointMake(crossX, 1 + h - (hist.close-indexScaleView.twoStockLowValue) / (indexScaleView.twoStockHighValue-indexScaleView.twoStockLowValue) * h);
			//crossPoint = CGPointMake(crossX+self.chartBarWidth/2, [indexView comparisonYfromPrice:hist.close]);
//        }
//        else 
//		{
//            CGFloat h = indexScaleView.frame.size.height;
//            crossPoint = CGPointMake(crossX, 1 + h - (hist.close-indexScaleView.lowestValue) / (indexScaleView.highestValue-indexScaleView.lowestValue) * h);
//        }
        crossPoint = [indexView convertPoint:crossPoint toView:crossLineView];
		
    }
    else 
	{
		
        dateLabel.text = nil;
        openLabel.text = nil;
        highLabel.text = nil;
        lowLabel.text = nil;
        closeLabel.text = nil;
        volumeLabel.text = nil;
        changeLabel.text = nil;
        changePerLabel.text = nil;
    }
	if (crossPoint.x<ChartWidth) {
        if (!CGPointEqualToPoint(crossLineView.crossPoint, crossPoint))
        {
            CGPoint point = [crossLineView convertPoint:crossPoint toView:indexScrollView];
            crossLineView.horizontalHidden = ![indexScrollView pointInside:point withEvent:nil];
            
            crossLineView.crossPoint = crossPoint;
            [crossLineView setNeedsDisplay];
        }
    }

}

- (void)hideCrossInfo
{
	
    CGRect r;
	
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))  
	{
        r = crossInfoPortrait.frame;
        r.origin.y = self.view.bounds.size.height+100;
        crossInfoPortrait.frame = r;
    }
	
    r = crossInfoLandscape.frame;
    r.origin.y = self.view.frame.size.height;
    crossInfoLandscape.frame = r;
}

- (CGFloat)crossXfromTouch:(UITouch *)touch 
{
	
	return [touch locationInView:indexView].x;
	
}


- (void)doTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if (_penBtn.selected == YES || _eraserBtn.selected == YES) {
        return;
    }
	
	UITouch *touch = [touches anyObject];
	crossX = [self crossXfromTouch:touch];
    if (self.crossVisible)
	{
		[self updateCrossView];
		[self updateUpperView:[self getSeqNumberFromPointXValue:crossX]];
        [self openCrossView:YES];
		
	}
	
    else
	{
		timestamp = [event timestamp];
	}
	
	if([[touches allObjects] count] == 1)
	{
		CGPoint touchPoint = [touch locationInView:self.view];	
		if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) 
        {
            if(touchPoint.x > 138)
                crossInfoPortrait.frame = CGRectMake(2, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
            else
                crossInfoPortrait.frame = CGRectMake(150, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
        }else{
            if(touchPoint.x > 250)
                crossInfoPortrait.frame = CGRectMake(2, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
            else
                if(IS_IPAD)
                    crossInfoPortrait.frame = CGRectMake(330, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
                else{
                    int aa = (self.view.frame.size.width == 568.0)?395:410;
                    crossInfoPortrait.frame = CGRectMake(aa, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
                }
        }
	}
//	if (pressTouching) {
//        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(checkPressTouch:) userInfo:nil repeats:NO];
//    }else{
        pressTouching = YES;
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(checkPressTouch:) userInfo:nil repeats:NO];
//    }
    
	
}

- (void)doTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (_penBtn.selected == YES || _eraserBtn.selected == YES) {
        return;
    }
    
    if (self.crossVisible) 
	{

        crossX = [self crossXfromTouch:[touches anyObject]];
        [self updateCrossView];
		[self updateUpperView:[self getSeqNumberFromPointXValue:crossX]];
        [self openCrossView:YES];
        
		if([[touches allObjects] count] == 1)
		{
			CGPoint touchPoint = [[touches anyObject] locationInView:self.view];	
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
            if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) 
            {
                if(touchPoint.x > 138){
                    crossInfoPortrait.frame = CGRectMake(2, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
                }
                else{
                    crossInfoPortrait.frame = CGRectMake(150, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
                }
            }else{
                if(touchPoint.x > 250){
                    crossInfoPortrait.frame = CGRectMake(2, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
                }
                else{
                    if(IS_IPAD){
                        crossInfoPortrait.frame = CGRectMake(330, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
                    }
                    else{
                        int aa = (self.view.frame.size.width == 568.0)?395:410;
                        crossInfoPortrait.frame = CGRectMake(aa, crossInfoPortrait.frame.origin.y, crossInfoPortrait.frame.size.width, crossInfoPortrait.frame.size.height);
                    }
                }
            }
			
			[UIView commitAnimations];
		}		
    }
    else 
	{
        timestamp = 0;
        //pressTouching = NO;
    }
}

- (void)doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (_penBtn.selected == YES || _eraserBtn.selected == YES) {
        return;
    }
    //pressTouching = NO;
//    indexScrollView.scrollEnabled = YES;
	
	if (event.timestamp - timestamp < 0.2)
	{
		
		//有開啓多股走勢比較 則不//開啓 upper view的技術指標 (移動平均線, 布林格通道..)
		//if (!_comparisonSettingController.comparing)
			//[upperView openUpperIndicatorPicker];
		
	}
	else
	{
		
		if (!self.crossVisible) 
		{ // crossInfo不顯在營幕範圍上
			
			[self updateCrossView];
			[self updateUpperView:[self getSeqNumberFromPointXValue:crossX]];
			[self openCrossView:YES];
            
		}
		
	}
	
}

- (void)checkPressTouch:(NSTimer*)timer {
	
    if (pressTouching) {
//        [self updateCrossView];
//        [self updateUpperView:[self getSeqNumberFromPointXValue:crossX]];
//		[self openCrossView:YES];
//        indexScrollView.scrollEnabled = NO;
        if (!self.crossVisible)
		{
            [self openCrossView:YES];
            [self updateCrossView];
			[self updateUpperView:[self getSeqNumberFromPointXValue:crossX]];
            
            //[self nslogIndicatorPara];
        }
    }
}

#pragma mark -
#pragma mark 資訊地雷

- (void)notifyInformationMine:(NSNumber *)queryType {
	
	if([queryType intValue]==0)
	{
		//日期回來了 , query for data
		//[informationMine setSubType:1]; //歷史新聞
//		UInt16  todayDate = [ValueUtil stkDateFromNSDate:[NSDate date]];
//		[informationMine informationMineBySecurityNum:portfolioItem->commodityNo QueryType:1 SubType:1 TodayDate:todayDate
//											StartTime:[ValueUtil stkDateFromNSDate:chartOldestDate] EndTime:todayDate];
//		
		
	}
	else
	{
		//[upperDateView updateLabels];
		[indexScaleView getHigestAndLowest];
		[indexScaleView setNeedsDisplay];
	}
	
}

- (void)openInformationNewsTitleViewControllerByStartDate:(UInt16)startDate endDate:(UInt16)endDate
{
	
	BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
	if(isLandscape)
	{
		UINavigationController *controller = self.navigationController;
		[controller setNavigationBarHidden:NO animated:NO];
		self.hidesBottomBarWhenPushed = YES;
		UIViewController *tmpController = [[UIViewController alloc] init];
		[controller pushViewController:tmpController animated:NO];
		[controller popViewControllerAnimated:NO];
	}
}

- (DecompressedHistoricData *)copyHistoricData:(UInt8)type ForDate:(NSDate **)date AtSequence:(int *)seq 
{
    NSDateComponents *nextDay = [[NSDateComponents alloc] init];
    [nextDay setDay:1];
	
    int weekday;
	
    weekday = (int)[[gCalendar components:NSWeekdayCalendarUnit fromDate:*date] weekday];
	
	
    UInt16 d = [ValueUtil stkDateFromNSDate:*date];
	
    UInt32 seqCount = [historicData tickCount:type];
	
    DecompressedHistoricData *histData = nil;
    DecompressedHistoricData *hist;
	
    for ( ; *seq < seqCount; (*seq)++) 
	{
		
        hist = [historicData copyHistoricTick:type sequenceNo:*seq];
        if (hist == nil) continue;
		
        if (hist.date >= d) 
		{
            if (hist.date == d)
                histData = hist;
            break;
        }
    }
	
    *date = [gCalendar dateByAddingComponents:nextDay toDate:*date options:0];
    
    return histData;
}


/*
 -(void)scrollViewWillBeginDragging:(UIScrollView*)scrollView {
 
 //[targetChartView removeFromSuperview];
 //[targetChartView sendSubviewToBack:upperView];	
 } 
 
 - (void)scrollViewDidScroll:(UIScrollView *)sender {
 
 //[dataView sendSubviewToBack:[subDataViews objectAtIndex:page]];
 
 CGFloat pageHeight = scrollView.frame.size.height;
 
 int page = floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;  //
 
 currentPage = page;
 
 
 // scroll完後 顯示當前資料	
 //[self loadScrollViewWithPage:page - 1];
 [self loadScrollViewWithPage:page];		
 //[self loadScrollViewWithPage:page + 1];	
 
 
 }
 
 
 // set visable frame range & load table data
 - (void)loadScrollViewWithPage:(int)page{ 
 
 
 
 if (page < 0) return;
 if (page >= kNumberOfTables) return;
 
 
 CGRect frame = scrollView.frame;
 frame.origin.x = 0;
 frame.origin.y = scrollView.frame.size.height * (page); 
 CGRect rectDataView;
 //rectDataView = CGRectMake(frame.origin.x, frame.origin.y, 320, 180);	 // view在 scroll view上的Ｙ軸位置
 rectDataView = CGRectMake(frame.origin.x, frame.origin.y, 320, dataView.frame.size.height);	 // view在 scroll view上的Ｙ軸位置
 [dataView setFrame:rectDataView]; // scroll view的 sub view
 //dataView.hidden=YES;
 
 
 //交換subView view, 將目前顯示的view放在screen後面(sendSubviewToBack), 再將欲顯示的與拉到screen上顯示(bringSubviewToFront)
 [dataView sendSubviewToBack:[subDataViews objectAtIndex:subDataViewsIndex]]; 
 [dataView bringSubviewToFront:[subDataViews objectAtIndex:page]];
 
 subDataViewsIndex = page;
 
 
 }
 */


- (void)updateZoomScale:(float)scale andWidth:(float)w 
{
	
    indexView.transform = CGAffineTransformMakeScale(scale, scale);
    indexView.frame = CGRectMake(0, 0, indexView.frame.size.width, indexView.frame.size.height);
	
    CGFloat h = (indexScrollView.frame.size.height + 2) * ChartZoomOrigin * scale;
    indexScrollView.contentSize = CGSizeMake(w, h);
	
    [bottonView1 updateZoomScale:scale andWidth:w];
    [bottonView2 updateZoomScale:scale andWidth:w];
	
    upperDateView.transform = CGAffineTransformMakeScale(scale, 1);
    upperDateView.frame = CGRectMake(0, 0, upperDateView.frame.size.width, upperDateView.frame.size.height);
    upperDateScrollView.contentSize = CGSizeMake(w, upperDateScrollView.contentSize.height);
	
    upperValueView.transform = CGAffineTransformMakeScale(1, scale);
    upperValueView.frame = CGRectMake(0, 0, upperValueView.frame.size.width, upperValueView.frame.size.height);
	
    h = (upperValueScrollView.bounds.size.height + 1) * ChartZoomOrigin * scale;
    upperValueScrollView.contentSize = CGSizeMake(upperValueScrollView.contentSize.width, h);
	
    [upperValueView resetLabelTransform];
    [upperDateView resetLabelTransform];
}

- (void) performTransition:(int)leftOrRight {
	
	// First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	
	// Animate over 3/4 of a second
	transition.duration = 0.0;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// Now to set the type of transition. Since we need to choose at random, we'll setup a couple of arrays to help us.
	NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};
	NSString *subtypes[2] = {kCATransitionFromLeft, kCATransitionFromRight};
	//int rnd = random() % 4;
	int rnd = 3;
	transition.type = types[rnd];
	
	transition.subtype = subtypes[leftOrRight];
	
	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	transitioning = YES;
	transition.delegate = self;
	
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[self.view.layer addAnimation:transition forKey:nil];
	
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	transitioning = NO;
}

#pragma mark -
#pragma mark scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    if ([scrollView isEqual:collectionView] || [scrollView isEqual:actionTableView]) {
        return;
    }
	//[indexScrollView bringSubviewToFront:indexView];
	indexScaleView.hidden = NO;
	upperValueView.highest = theHighestValue;
	upperValueView.lowest = theLowestValue;
	[upperValueView updateLabels];
   
 	if (self.crossVisible)
	{
		// for 清除 bottomView的技術指標數值
		[self resetCrossView];	
	}		
	
	if (scrollView == scaleScrollView && (indexScrollView.zooming || upperValueScrollView.zooming || upperDateScrollView.zooming || bottonView1.dataScrollView.zooming || bottonView2.dataScrollView.zooming))
	{
		return;
		float scale = scaleView.transform.a / ChartZoomOrigin;
		[self updateZoomScale:scale andWidth:baseWidth*scale];
	}
	
	if (scrollView == indexScrollView || scrollView == upperDateScrollView) 
	{
		//			NSLog(@"offset x = %f, %f, %f ,%d ",scrollView.contentOffset.x,scrollView.contentSize.width,ChartWidth,curShowPos );
		UIScrollView *view = bottonView1.dataScrollView;
		view.contentOffset = CGPointMake(scrollView.contentOffset.x, view.contentOffset.y);
		
		view = bottonView2.dataScrollView;
		view.contentOffset = CGPointMake(scrollView.contentOffset.x, view.contentOffset.y);
		
		if (scrollView == indexScrollView)
			upperDateScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, upperDateScrollView.contentOffset.y);
		else
			indexScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, indexScrollView.contentOffset.y);
	}
	
	if (scrollView == indexScrollView || scrollView == upperValueScrollView) {
		
		if (scrollView == indexScrollView)
			upperValueScrollView.contentOffset = CGPointMake(upperValueScrollView.contentOffset.x, scrollView.contentOffset.y);
		else
			indexScrollView.contentOffset = CGPointMake(indexScrollView.contentOffset.x, scrollView.contentOffset.y);
		
		[upperValueView checkLabelStatus];
	}
	
	//[self performTransition:0];
	indexScaleView.frame = CGRectMake(scrollView.contentOffset.x, indexScaleView.frame.origin.y, indexScaleView.frame.size.width, indexScaleView.frame.size.height);
	//	[indexScrollView bringSubviewToFront:indexScaleView];
	indexScaleView.hidden = NO;
	[indexScaleView getHigestAndLowest];
	[indexScaleView setNeedsDisplay];
	upperValueView.highest = indexScaleView.highestValue;
	upperValueView.lowest = indexScaleView.lowestValue;
    //[upperValueView updateLabels];
    theHighestVolume = [self getTheHightestVolume];
    theLowestVolume = [self getTheLowestVolume];
    [bottonView1 setNeedsDisplay];
    [bottonView2 setNeedsDisplay];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:collectionView] || [scrollView isEqual:actionTableView]) {
        return;
    }
	if(!decelerate)
	{
        if(scrollView.contentSize.width>scrollView.frame.size.width){
            //[self performTransition:0];
            indexScaleView.frame = CGRectMake(scrollView.contentOffset.x, indexScaleView.frame.origin.y, indexScaleView.frame.size.width, indexScaleView.frame.size.height);
        //	[indexScrollView bringSubviewToFront:indexScaleView];
            indexScaleView.hidden = NO;
            [indexScaleView getHigestAndLowest];
            [indexScaleView setNeedsDisplay];
            upperValueView.highest = indexScaleView.highestValue;
            upperValueView.lowest = indexScaleView.lowestValue;
            [upperValueView updateLabels];
            theHighestVolume = [self getTheHightestVolume];
            theLowestVolume = [self getTheLowestVolume];
            [bottonView1 setNeedsDisplay];
            [bottonView2 setNeedsDisplay];
        }
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:collectionView] || [scrollView isEqual:actionTableView]) {
        return;
    }
	//[self performTransition:0];
	indexScaleView.frame = CGRectMake(scrollView.contentOffset.x, indexScaleView.frame.origin.y, indexScaleView.frame.size.width, indexScaleView.frame.size.height);
	//	[indexScrollView bringSubviewToFront:indexScaleView];
	indexScaleView.hidden = NO;
	[indexScaleView getHigestAndLowest];
	[indexScaleView setNeedsDisplay];
	upperValueView.highest = indexScaleView.highestValue;
	upperValueView.lowest = indexScaleView.lowestValue;
    [upperValueView updateLabels];
    theHighestVolume = [self getTheHightestVolume];
    theLowestVolume = [self getTheLowestVolume];
    [bottonView1 setNeedsDisplay];
    [bottonView2 setNeedsDisplay];
}

//set最新日期
-(NSDate *)setTodayDate
{
	
    return [NSDate date]; //取得今日date
}


//畫邊框
-(void)drawChartFrameWithChartOffset:(CGPoint)chartFrameOffset frameWidth:(float)frameWidth frameHeight:(float)frameHeight {
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	
	//畫diagram frame
    
    CGFloat length[]={2,1};
    //劃線 (未滿畫面的情況 最左邊的直線)
    [[UIColor lightGrayColor] set];
    CGContextSetLineDash(context, 0, length, 1);
    CGContextMoveToPoint(context, chartFrameOffset.x, chartFrameOffset.y);
    CGContextAddLineToPoint(context, chartFrameOffset.x, frameHeight + chartFrameOffset.y);
    CGContextStrokePath(context);

    CGContextSetLineDash(context, 0, NULL, 0);

//	CGRect myFrame = CGRectMake(chartFrameOffset.x, chartFrameOffset.y, frameWidth, frameHeight);
//	CGContextSetLineWidth(context, ChartZoomOrigin);
//	
//	[[UIColor blackColor] set];
	//UIRectFrame(myFrame);
	
	//CGContextStrokePath(context);
	
	
}


- (void)drawBottomChartFrameWithOffset:(CGPoint)offset frameWidth:(float)width frameHeight:(float)height 
{
	
//	CGRect rect = CGRectMake(offset.x-ChartZoomOrigin, -ChartZoomOrigin*2, width+ChartZoomOrigin*2, height+ChartZoomOrigin*4);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat length[]={2,1};
    //劃線 (未滿畫面的情況 最左邊的直線)
    [[UIColor lightGrayColor] set];
    CGContextSetLineWidth(context, 1);
    CGContextSetLineDash(context, 0, length, 1);
    CGContextMoveToPoint(context, offset.x-ChartZoomOrigin, -ChartZoomOrigin*2);
    CGContextAddLineToPoint(context, offset.x-ChartZoomOrigin, height+ChartZoomOrigin*4 + -ChartZoomOrigin*2);
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0, NULL, 0);
}


//畫直線 （考慮type）
-(void)drawChartFrameXScaleWithChartOffset:(CGPoint)chartFrameOffset frameWidth:(float)frameWidth frameHeight:(float)frameHeight xLines:(NSInteger)linesOfX xScaleType:(int)type 
{
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 	
//    CGFloat dash[] = { 1.5 };

	switch (type)
	{
			
			float scale;	
			
		case 0:			
			
            scale = (float) frameWidth / linesOfX;		
			for(int i=0; i <= (linesOfX/60) ; i++)
			{ //
//                CGContextSetLineDash(context, 0, length, 1);
//				CGContextMoveToPoint(context, (60*i)*scale + chartFrameOffset.x,chartFrameOffset.y);
//				CGContextAddLineToPoint(context, (60*i)*scale + chartFrameOffset.x,frameHeight + chartFrameOffset.y);
				CGContextSetLineWidth(context, 1);
//				CGContextStrokePath(context);
			}
			break;
		case 1:
			//日刻度
			scale = (float)frameWidth / linesOfX;
			
            [[UIColor lightGrayColor] set];
            
            
            CGContextSetLineWidth(context, 0.8);
            //CGContextSetLineDash(context, 2, dash, 1);
			
            for (int i = 1; i < linesOfX; i++)
			{
//				CGContextSetLineDash(context, 0, length, 1);
//				CGContextMoveToPoint(context, i*scale + chartFrameOffset.x,chartFrameOffset.y);
//				CGContextAddLineToPoint(context, i*scale + chartFrameOffset.x,frameHeight + chartFrameOffset.y);
//				CGContextStrokePath(context);
			}
			break;
		case 2: // 週刻度需從資料的日期中找出每週的第一天
			
			scale = (float)frameWidth / linesOfX;
			
            //CGContextSetLineDash(context, 2, dash, 1);
            //[[UIColor lightGrayColor] set];
            [[UIColor darkGrayColor] set];
            for (int i = 1; i < linesOfX; i++)
			{
				
				if(type ==1 || fmod(i,5)>0)
				{ // fmod(k,5)為true (除法除不盡) 或 x軸刻度線為日刻度樣式 則不加粗
					//CGContextSetLineWidth(context, 0.3);
                    continue;
				}
				else{ //除法除的盡 (週線 加粗)
					//CGContextSetLineWidth(context, 0.8*ChartZoomOrigin);
					CGContextSetLineWidth(context, ChartZoomOrigin);
				}
				
//                CGContextSetLineDash(context, 0, length, 1);
//				CGContextMoveToPoint(context, i*scale + chartFrameOffset.x,chartFrameOffset.y);
//				CGContextAddLineToPoint(context, i*scale + chartFrameOffset.x,frameHeight + chartFrameOffset.y);
//				CGContextStrokePath(context);
			}
			break;
		case 3:
			//月刻度 //總月數條 刻度線
			scale = (float)frameWidth / linesOfX;
			
            //CGContextSetLineDash(context, 2, dash, 1);
            [[UIColor lightGrayColor] set];
			
            for (int i = 1; i < linesOfX; i++) 
			{
				
				if(type ==1 || fmod(i,5)>0)
				{ // fmod(k,5)為true (除法除不盡) 或 x軸刻度線為日刻度樣式 則不加粗
					//CGContextSetLineWidth(context, 0.3);
                    continue;
				}
				else{ //除法除的盡 (週線 加粗)
					CGContextSetLineWidth(context, 0.8*ChartZoomOrigin);									
				}
//                CGContextSetLineDash(context, 0, length, 1);
//				CGContextMoveToPoint(context, i*scale + chartFrameOffset.x,chartFrameOffset.y);
//				CGContextAddLineToPoint(context, i*scale + chartFrameOffset.x,frameHeight + chartFrameOffset.y);
//				CGContextStrokePath(context);
			}
			break;
			
	}
	
	
	
}

//upperView畫橫線
-(void)drawChartFrameYScaleWithChartOffset:(CGPoint)chartFrameOffset frameWidth:(float)frameWidth frameHeight:(float)frameHeight yLines:(NSInteger)linesOfY 
{
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 	
	
    [[UIColor lightGrayColor] set];
	
	//畫橫線 (由最高值開始畫)
	float scale = (float)frameHeight / linesOfY;		
	CGFloat length[]={2,1};
	for(int i= 1; i<linesOfY ; i++)  // 邊框有就別畫了
	{
		
		//CGContextSetLineWidth(context, 0.5);		
		//CGContextSetLineWidth(context, 0.8*ChartZoomOrigin);
		CGContextSetLineWidth(context, 0.5);
		CGContextSetLineDash(context, 0, length, 1);
		CGContextMoveToPoint( context, chartFrameOffset.x , frameHeight - i*scale + chartFrameOffset.y);
		CGContextAddLineToPoint( context, frameWidth + chartFrameOffset.x , frameHeight - i*scale + chartFrameOffset.y);
		CGContextStrokePath(context);
		
	}
	
    CGContextSetLineDash(context, 0, NULL, 0);
}

//bottonView畫橫線
- (void)drawChartFrameYScaleWithChartOffset:(CGPoint)frameOffset frameWidth:(float)width frameHeight:(float)height yLines:(NSInteger)linesOfY lineIncrement:(int)increment
{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    [[UIColor lightGrayColor] set];
	
	float scale = (float)height / linesOfY;
	CGFloat length[]={2,1};
	for (int i = 2; i < linesOfY; i += increment)
	{
		
		CGContextSetLineWidth(context, 0.5);
        
        CGContextSetLineDash(context, 0, length, 1);
		CGContextMoveToPoint(context, frameOffset.x, height - i*scale + frameOffset.y);
		CGContextAddLineToPoint(context, width + frameOffset.x, height - i*scale + frameOffset.y);
		CGContextStrokePath(context);
	}
	
    CGContextSetLineDash(context, 0, NULL, 0);
}


- (float)getTheHightestValue 
{
	
    float maxNumber = 0;
	
    float xSize = indexScaleView.frame.size.width;
    float ySize = indexScaleView.frame.size.height;
    ySize -=1;
    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = indexScaleView.frame.origin.x;
    int dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    int dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    
    if (analysisPeriod == AnalysisPeriodDay)
	{
		
        //set最新日期
//        NSDate *endDate = [self setTodayDate];
//		
//        //計算給定月區間範圍 最遠古的日期
//        NSDate *startDate = [self getOldestDate];
//		
//        UInt16 start_d = [ValueUtil stkDateFromNSDate:startDate];
//        UInt16 end_d = [ValueUtil stkDateFromNSDate:endDate];
//		
//        UInt32 count = [historicData tickCount:kTickTypeDay];
        DecompressedHistoricData *historic;
		
       //        for (int i = 0; i < count; i++) 
//		{
//            if (historic.date >= start_d && historic.date <= end_d)
        for (int i = dataStartIndex; i <= dataEndIndex; i++)

			{
                historic = [historicData copyHistoricTick:kTickTypeDay sequenceNo:i];
                if (historic == nil) continue;
//                if (maxNumber < historic.high)
//                    maxNumber = historic.high;
                maxNumber = MAX(maxNumber, historic.high);
            }
//        }
        }
        else
        {
		
            UInt8 type = self.historicType;
//            UInt32 count = [historicData tickCount:type];
            DecompressedHistoricData *historic;
            
            for (int i = dataStartIndex; i <= dataEndIndex; i++)
            {
                
                historic = [historicData copyHistoricTick:type sequenceNo:i];
                if (historic == nil) continue;
                
    //            if (maxNumber < historic.high)
    //                maxNumber = historic.high;
                maxNumber = MAX(maxNumber, historic.high);
            }
        }
    return maxNumber;
}

- (float)getTheLowestValue 
{
	
    float minNumber = 0;
	
    if (analysisPeriod == AnalysisPeriodDay) 
	{
		
        //set最新日期
        NSDate *endDate = [self setTodayDate];
		
        //計算給定月區間範圍 最遠古的日期
        NSDate *startDate = [self getOldestDate];
		
        UInt16 start_d = [ValueUtil stkDateFromNSDate:startDate];
        UInt16 end_d = [ValueUtil stkDateFromNSDate:endDate];
		
        UInt32 count = [historicData tickCount:kTickTypeDay];
        DecompressedHistoricData *historic;
		
        for (int i = 0; i < count; i++) 
		{
			
            historic = [historicData copyHistoricTick:kTickTypeDay sequenceNo:i];
            if (historic == nil) continue;
			
            if (historic.date >= start_d && historic.date <= end_d) 
			{
				
                if (minNumber > historic.low || minNumber == 0)
                    minNumber = historic.low;
            }
        }
    }
    else 
	{
		
        UInt8 type = self.historicType;
        UInt32 count = [historicData tickCount:type];
        DecompressedHistoricData *historic;
		
        for (int i = 0; i < count; i++) 
		{
			
            historic = [historicData copyHistoricTick:type sequenceNo:i];
            if (historic == nil) continue;
			
            if (minNumber > historic.low || minNumber == 0)
                minNumber = historic.low;
        }
    }
	
	return minNumber;
}

//
//求區間資料內最高量
-(float)getTheHightestVolume
{
	
    float maxNumber = 0;
    UInt8 maxUnit = 0;
        
        UInt8 type = self.historicType;
        float xSize = indexScaleView.frame.size.width;
        float ySize = indexScaleView.frame.size.height;
        ySize -=1;
        float winLocationX;
        if(xSize<273)
            winLocationX = 0;
        else
            winLocationX = indexScaleView.frame.origin.x;
        
        
        int dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
        int dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
        
        DecompressedHistoricData *hist;
        
        hist = [historicData copyHistoricTick:type sequenceNo:(int)dataStartIndex];

        hist = [historicData copyHistoricTick:type sequenceNo:(int)dataEndIndex];
//        UInt16 start_d = hist.date;
//        UInt16 end_d = hist.date;
		
//        //set最新日期
//        NSDate *endDate = [self setTodayDate];
//		
//        //計算給定月區間範圍 最遠古的日期
//        NSDate *startDate = [self getOldestDate];
//		
//        UInt16 start_d = [ValueUtil stkDateFromNSDate:startDate];
//        UInt16 end_d = [ValueUtil stkDateFromNSDate:endDate];
		
//        UInt32 count = [historicData tickCount:type];
        DecompressedHistoricData *historic;
//        float vol;
		
        for (int i = dataStartIndex; i <= dataEndIndex; i++)
		{
			
            historic = [historicData copyHistoricTick:type sequenceNo:i];
            if (historic == nil) continue;
            
            float vol = historic.volume * pow(1000,historic.volumeUnit);
            if (vol > maxNumber){
                maxNumber = vol;
            }
            
            
			
//            if (historic.date >= start_d && historic.date <= end_d) 
//			{
//				
//                vol = historic.volume;
//				
//                if (vol > 0) 
//				{
//					
//                    if (historic.volumeUnit > maxUnit)
//					{
//                        if (maxNumber == 0)
//                            maxUnit = historic.volumeUnit;
//                        else
//                            vol *= valueUnitBase[historic.volumeUnit - maxUnit];
//                    }
//                    else if (maxUnit > historic.volumeUnit)
//					{
//                        maxNumber *= valueUnitBase[maxUnit - historic.volumeUnit];
//                        maxUnit = historic.volumeUnit;
//                    }
//					
//                    if (maxNumber < vol)
//                        maxNumber = vol;
//                }
//            }
			
        }
    for (int i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [_dataModal.operationalIndicator getValueFrom:i parm:@"AVS"];
        if (v>maxNumber) {
            maxNumber = v;
            maxUnit =0;
        }
        
        
    }
    
    for (int i = dataStartIndex; i <= dataEndIndex; i++) {
        float v = [_dataModal.operationalIndicator getValueFrom:i parm:@"AVL"];
        if (v>maxNumber) {
            maxNumber = v;
            maxUnit =0;
        }
    }
//
//    }
//    else
//	{
//		
//        UInt8 type = self.historicType;
//        UInt32 count = [historicData tickCount:type];
//        DecompressedHistoricData *historic;
//        float vol;
//		
//        for (int i = 0; i < count; i++)
//		{
//			
//            historic = [historicData copyHistoricTick:type sequenceNo:i];
//            if (historic == nil) continue;
//			
//            vol = historic.volume;
//			
//            if (vol > 0)
//			{
//				
//                if (historic.volumeUnit > maxUnit)
//				{
//                    if (maxNumber == 0)
//                        maxUnit = historic.volumeUnit;
//                    else
//                        vol *= valueUnitBase[historic.volumeUnit - maxUnit];
//                }
//                else if (maxUnit > historic.volumeUnit)
//				{
//                    maxNumber *= valueUnitBase[maxUnit - historic.volumeUnit];
//                    maxUnit = historic.volumeUnit;
//                }
//				
//                if (maxNumber < vol)
//                    maxNumber = vol;
//            }
//			
//            [historic release];
//        }
//    }
	
    maxVolumeUnit = maxUnit;
	return maxNumber;
	
}

//求區間資料內最低量
-(float)getTheLowestVolume
{
	
    return 0; // 量圖以0為最低點
}


//取得每月第一天的陣列
- (NSMutableArray *)getMonthArrayFromTodayDate:(NSDate *)today toOldestDate:(NSDate *)oldestDate 
{
	
    NSDateComponents *componentsFirstDayDate = [gCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    [componentsFirstDayDate setDay:1];
	
    NSDate *firstDayDateOfMonth = [gCalendar dateFromComponents:componentsFirstDayDate];
	
    NSMutableArray *monthsArray = [NSMutableArray array];
	
    NSDateComponents *nextDay = [[NSDateComponents alloc] init];
    [nextDay setDay:1];
	
    NSDateComponents *prevMonth = [[NSDateComponents alloc] init];
    [prevMonth setMonth:-1]; 
	
    NSDate *date;
    //int weekday;
	
    while (TRUE) 
	{
		
        date = firstDayDateOfMonth;
		
        if ([date compare:oldestDate] < 0)
            break;
		
        // 取每個月第一天 存入陣列
        [monthsArray addObject:date];
		
        firstDayDateOfMonth = [gCalendar dateByAddingComponents:prevMonth toDate:firstDayDateOfMonth options:0];
    }
    return monthsArray;
}


//畫月份線 真正在畫直線的地方
- (void)drawMonthLineWithChartFrame:(CGRect)frame xLines:(NSInteger)lineOfX offsetStartPoint:(CGPoint)offsetStartPoint
{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSDate *today = [self setTodayDate];
    NSDate *theOrdestDate = [self getOldestDate];
	
	//取得每月第一天的陣列
	NSMutableArray *firstDateDateArray = [self getMonthArrayFromTodayDate:today toOldestDate:theOrdestDate];
    NSUInteger cntFirstDayDate = [firstDateDateArray count];
	
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextSetLineWidth(context, 0.5);
	
    for (int i = 0; i < cntFirstDayDate; i++) 
	{
		
        NSDate *tmpDate = [firstDateDateArray objectAtIndex:i];
		
        //每個月第一天的SLI （從最近期的月份開始）
        int scaleLocationIndex = [self scaleLocationIndexValueFromDate:tmpDate ordestDate:theOrdestDate];
		
        float scale = (float) frame.size.width / lineOfX;
        float lineXcoordinate = (float)scale * scaleLocationIndex;
		
        CGPoint startPoint = CGPointMake(lineXcoordinate,0);
        CGPoint endPoint = CGPointMake(lineXcoordinate,frame.size.height);
		CGFloat length[]={2,1};
        //劃線 (直線)
		[[UIColor lightGrayColor] set];
        CGContextSetLineDash(context, 0, length, 1);
        CGContextMoveToPoint(context, startPoint.x + offsetStartPoint.x, startPoint.y + offsetStartPoint.y);
        CGContextAddLineToPoint(context, endPoint.x + offsetStartPoint.x, endPoint.y + offsetStartPoint.y);
        CGContextStrokePath(context);
	}
	
    CGContextSetLineDash(context, 0, NULL, 0);
}

//真正在畫直線的地方
- (void)drawDateGridWithChartFrame:(CGRect)frame xLines:(NSInteger)lineOfX offsetStartPoint:(CGPoint)offsetStartPoint
{
	
    UInt8 type = self.historicType;
    UInt32 count = [historicData tickCount:type];
    if (count == 0) return;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    [[UIColor lightGrayColor] set];
	
    float x;
    float scale = frame.size.width / lineOfX;
	CGFloat length[]={2,1};
    
    switch (analysisPeriod) 
	{
        case AnalysisPeriodDay:
            break;
        case AnalysisPeriodWeek:
        {
            int bitOffset = analysisPeriod == AnalysisPeriodWeek ? 5 : 9;
            int date, prevDate;
			
            DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:0];
            prevDate = (historic.date >> bitOffset)& 0xF;
            if (prevDate>=1 && prevDate<=3) {
                prevDate=1;
            }else if (prevDate>=4 && prevDate<=6){
                prevDate = 2;
            }else if (prevDate>=7 && prevDate<=9){
                prevDate = 3;
            }else if (prevDate>=10 && prevDate<=12){
                prevDate = 4;
            }
			
            for (int i = 1; i < count; i++)
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:i];
                date = (historic.date >> bitOffset)& 0xF;
                if (date>=1 && date<=3) {
                    date=1;
                }else if (date>=4 && date<=6){
                    date = 2;
                }else if (date>=7 && date<=9){
                    date = 3;
                }else if (date>=10 && date<=12){
                    date = 4;
                }
				
                if (prevDate != date)
				{
					
					prevDate = date;
                    x = offsetStartPoint.x + scale * i;
                    CGContextSetLineDash(context, 0, length, 1);
                    CGContextMoveToPoint(context, x, offsetStartPoint.y);
                    CGContextAddLineToPoint(context, x, frame.size.height + offsetStartPoint.y);
                    CGContextStrokePath(context);
                }
            }
            break;
        }
        case AnalysisPeriodMonth:
		{
			
            int bitOffset = analysisPeriod == AnalysisPeriodWeek ? 5 : 9;
            int date, prevDate;
			
            DecompressedHistoricData *historic = [historicData copyHistoricTick:type sequenceNo:0];
            prevDate = (historic.date >> bitOffset);
			
            for (int i = 1; i < count; i++) 
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:i];
                date = (historic.date >> bitOffset);
				
                if (prevDate != date)
				{
					
					prevDate = date;
                    x = offsetStartPoint.x + scale * i;
                    CGContextSetLineDash(context, 0, length, 1);
                    CGContextMoveToPoint(context, x, offsetStartPoint.y);
                    CGContextAddLineToPoint(context, x, frame.size.height + offsetStartPoint.y);
                    CGContextStrokePath(context);
                }
            }
            break;
        }
			
        case AnalysisPeriod5Minute:
        {
			
            int date, prevDate;
            int time, prevTime;
			
            DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:0];
            prevDate = historic.date;
            prevTime = historic.time;
			
            for (int i = 1; i < count; i++)
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:i];
                date = historic.date;
                time = historic.time;
				
                if (prevDate != date || prevTime/60 != time/60)
				{
					CGContextSetLineDash(context, 0, length, 1);
                    x = offsetStartPoint.x + scale * i;
                    CGContextMoveToPoint(context, x, offsetStartPoint.y);
                    CGContextAddLineToPoint(context, x, frame.size.height + offsetStartPoint.y);
                    CGContextStrokePath(context);
					
                    prevDate = date;
                    prevTime = time;
                }
            }
            break;
        }
		case AnalysisPeriod15Minute:
        {
			
            int date, prevDate;
            int time, prevTime;
			
            DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:0];
            prevDate = historic.date;
            prevTime = historic.time;
			int hr=0;
            for (int i = 1; i < count; i++)
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:i];
                date = historic.date;
                time = historic.time;
				
                if (prevDate != date || prevTime/60 != time/60)
				{
                    if (hr==2 || prevDate != date) {
                        CGContextSetLineDash(context, 0, length, 1);
                        x = offsetStartPoint.x + scale * i;
                        CGContextMoveToPoint(context, x, offsetStartPoint.y);
                        CGContextAddLineToPoint(context, x, frame.size.height + offsetStartPoint.y);
                        CGContextStrokePath(context);
                        
                        prevDate = date;
                        prevTime = time;
                        hr = 0;
                        
                    }else{
                        hr+=1;
                        prevDate = date;
                        prevTime = time;
                    }
					
                }
            }
            break;
        }
		case AnalysisPeriod30Minute:
        {
			
            int date, prevDate;
            int time, prevTime;
			
            DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:0];
            prevDate = historic.date;
            prevTime = historic.time;
			
            for (int i = 1; i < count; i++)
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:i];
                date = historic.date;
                time = historic.time;
				
                if (prevDate != date)
				{
					CGContextSetLineDash(context, 0, length, 1);
                    x = offsetStartPoint.x + scale * i;
                    CGContextMoveToPoint(context, x, offsetStartPoint.y);
                    CGContextAddLineToPoint(context, x, frame.size.height + offsetStartPoint.y);
                    CGContextStrokePath(context);
					
                    prevDate = date;
                    prevTime = time;
                }
            }
            break;
        }
		case AnalysisPeriod60Minute:
		{
			
            int date, prevDate;
            int time, prevTime;
			
            DecompressedHistoric5Minute *historic = [historicData copyHistoricTick:type sequenceNo:0];
            prevDate = historic.date;
            prevTime = historic.time;
			BOOL day = YES;//兩天畫一條
            for (int i = 1; i < count; i++) 
			{
				
                historic = [historicData copyHistoricTick:type sequenceNo:i];
                date = historic.date;
                time = historic.time;
				
                if (prevDate != date)
				{
                    if (day) {
                        day=NO;
                        prevDate = date;
                        prevTime = time;
                    }else{
                        CGContextSetLineDash(context, 0, length, 1);
                        x = offsetStartPoint.x + scale * i;
                        CGContextMoveToPoint(context, x, offsetStartPoint.y);
                        CGContextAddLineToPoint(context, x, frame.size.height + offsetStartPoint.y);
                        CGContextStrokePath(context);
                        
                        prevDate = date;
                        prevTime = time;
                        day = YES;
                    }
                }
            }
            break;
        }
    }
	
    CGContextSetLineDash(context, 0, NULL, 0);
}

//抓月線的座標index
-(int)scaleLocationIndexValueFromDate:(NSDate *)date ordestDate:(NSDate *)ordestDate
{
	
	UInt16 dateNumber = [ValueUtil stkDateFromNSDate:date];
	UInt16 year;
	UInt8 month,day;
	
	[CodingUtil getDate:dateNumber year:&year month:&month day:&day];
	
	//scale location index 0:最左邊的historic data , 最後一筆historic data為最右邊 (資料不間斷)
	
	DecompressedHistoricData *hist;
	int scaleLocationIndex = -1;
	
    UInt32 seqCount = [historicData tickCount:kTickTypeDay];	
    int seq = 0;	
	
	
	for ( ; seq < seqCount; seq++) 
	{
		
		hist = [historicData copyHistoricTick:kTickTypeDay sequenceNo:seq];
		UInt16 tmpYear;
		UInt8 tmpMonth,tmpDay;
		UInt16 stkDate = [hist date];
		[CodingUtil getDate:stkDate year:&tmpYear month:&tmpMonth day:&tmpDay];
		
		if((tmpYear == year) && (tmpMonth == month)) // 同年且同月 
		{
			
			scaleLocationIndex = seq;
			break;
			
		}
		
	}
	return scaleLocationIndex;
}


// 在指定rect中畫數字
-(void) drawString:(NSString*)string InRect:(CGRect)rect fontName:(NSString*)name fontSize:(CGFloat)size alignment:(NSTextAlignment)alignment
{
	
	UIFont *font = [UIFont fontWithName:name size:size];
	    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = alignment;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blackColor],
                                  NSParagraphStyleAttributeName: paragraphStyle };
	[string drawInRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height) withAttributes:attributes];
//	[string drawInRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height) withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:alignment];
}


- (NSString *)titleForAnalysisPeriod:(AnalysisPeriod)period 
{
	
    switch (period) 
	{
        case AnalysisPeriodDay: return NSLocalizedStringFromTable(@"Daily", @"Draw", @"The daily K-line navigation button");
        case AnalysisPeriodWeek: return NSLocalizedStringFromTable(@"Weekly", @"Draw", @"The weekly K-line navigation button");
        case AnalysisPeriodMonth: return NSLocalizedStringFromTable(@"Monthly", @"Draw", @"The monthly K-line navigation button");
        case AnalysisPeriod5Minute: return NSLocalizedStringFromTable(@"5Minutely", @"Draw", @"The 5-minutely K-line navigation button");
        case AnalysisPeriod15Minute: return NSLocalizedStringFromTable(@"15Minutely", @"Draw", @"The 15-minutely K-line navigation button");
        case AnalysisPeriod30Minute: return NSLocalizedStringFromTable(@"30Minutely", @"Draw", @"The 30-minutely K-line navigation button");
        case AnalysisPeriod60Minute: return NSLocalizedStringFromTable(@"60Minutely", @"Draw", @"The 60-minutely K-line navigation button");
        default: return nil;
    }
}

#pragma mark -
#pragma mark actionSheet 功能選單相關

- (IBAction)rightNavigationButtonClicked:(id)sender 
{
	
    [self resetCrossView];
	[upperView refleshPeriodTitleAndIndicatorValue];
	
    NSString *compareText = NSLocalizedStringFromTable(@"Compare", @"Draw", @"The compare button of the realtime chart");	
	NSString *periodText = NSLocalizedStringFromTable(@"period",@"Draw",@"k線週期");	
	NSString *indicatorSettingText = NSLocalizedStringFromTable(@"Setting Indicator Parameter", @"Draw", @"The compare button of the realtime chart");
    NSString *cancelText = NSLocalizedStringFromTable(@"取消",@"CompanyProfile",@"取消按鈕");
	
	
	//功能表 sheet
	if(functionsSheet==nil)
	{
		
		//總體經濟不能調整週期
		if(isPushFfromMacro)
		{
			
			functionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelText destructiveButtonTitle:nil
												otherButtonTitles:compareText,indicatorSettingText,nil];
			
		}
		else
		{
			
			functionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelText destructiveButtonTitle:nil
												otherButtonTitles:compareText,periodText,indicatorSettingText,nil];
			
		}
	}
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (![actionSheet isEqual:drawLineActionSheet] && ![actionSheet isEqual:eraserActionSheet] ) {
        if (buttonIndex == actionSheet.cancelButtonIndex){
            [self buttonSelected];
            return;
        }
		
        
        if(actionSheet == functionsSheet)	//功能表 sheet
        {
            
            if(isPushFfromMacro)
            {
                
                if (buttonIndex == 0) //走勢比較
                {
                    [self.indexView setBaseIndex:-1];
                    
                }
                
            }
            else
            {
                
                if (buttonIndex == 0) //走勢比較
                {
                    [self.indexView setBaseIndex:-1];
                    
                }
                
            }
            
        }
        
        else //k線週期 sheet
        {
//            [self.drawingView resetView];
            
            if (analysisPeriod != buttonIndex+3)
            {
                [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"",@"Draw",nil)];
                [self.indexView setBaseIndex:-1];
                // stop target watch
                [self stopWatch];
                
                // set new value
                analysisPeriod = (int)buttonIndex+3;
                if (analysisPeriod == 3) {
                    //五分線
                    [_minLine setTitle:NSLocalizedStringFromTable(@"5分",@"Draw",nil) forState:UIControlStateNormal];
                    _twoStock.enabled = NO;
                }else if (analysisPeriod ==4){
                    //十五分線
                    [_minLine setTitle:NSLocalizedStringFromTable(@"15分",@"Draw",nil) forState:UIControlStateNormal];
                    _twoStock.enabled = NO;
                }else if (analysisPeriod == 5){
                    //三十分線
                    [_minLine setTitle:NSLocalizedStringFromTable(@"30分",@"Draw",nil) forState:UIControlStateNormal];
                    _twoStock.enabled = NO;
                }else if (analysisPeriod ==6){
                    //六十分線
                    [_minLine setTitle:NSLocalizedStringFromTable(@"60分",@"Draw",nil) forState:UIControlStateNormal];
                    _twoStock.enabled = NO;
                }
                
                //更新週期title and indicator value（歸零）
                [upperView refleshPeriodTitleAndIndicatorValue];
                [upperView selectUpperViewType];
                if (analysisPeriod==AnalysisPeriodDay) {
                    [bottonView1 selectAnalysisType:indicator.bottomView1Indicator];
                    [bottonView2 selectAnalysisType:indicator.bottomView2Indicator];
                }else if (analysisPeriod == AnalysisPeriodWeek){
                    [bottonView1 selectAnalysisType:indicator.bottomView1WeekIndicator];
                    [bottonView2 selectAnalysisType:indicator.bottomView2WeekIndicator];
                }else if (analysisPeriod == AnalysisPeriodMonth) {
                    [bottonView1 selectAnalysisType:indicator.bottomView1MonIndicator];
                    [bottonView2 selectAnalysisType:indicator.bottomView2MonIndicator];
                }else{
                    [bottonView1 selectAnalysisType:indicator.bottomView1MinIndicator];
                    [bottonView2 selectAnalysisType:indicator.bottomView2MinIndicator];
                }
                if (_comparedHasArrive)
                {
                    _comparedHasArrive = NO;
                    [_comparedHistoricData.dataArray removeAllObjects];
                }
                [self resetDisplay];
                [self resetCrossView];
                
                //			NSUInteger count = _comparisonSettingController.targetCount;
                //			id<ComparisonTarget> target;
                //			
                //			for (int i = 0; i < count; i++) 
                //			{
                //				target = [_comparisonSettingController targetForLine:i];
				
                //			}
                
                // start target watch
                [self startWatch];
//                [self SetTimer];
                
                
            }
            
        }
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
	
    if (![actionSheet isEqual:drawLineActionSheet] && ![actionSheet isEqual:eraserActionSheet]) {
        if (buttonIndex == actionSheet.cancelButtonIndex)
            return;
        
        if(actionSheet == functionsSheet)	//功能表 sheet
        {
            
            if(isPushFfromMacro)
            {
                
                return;
                
            }
            else
            {
                
                if (buttonIndex == 0) //走勢比較
                {
                    //
                }
                
                else if(buttonIndex == 1) //k線週期
                {
                    
                    if(periodsTypeSheet == nil)
                    {
                        
                        NSString *dayText = NSLocalizedStringFromTable(@"DailyChart", @"Draw", @"The daily button for selecting K-line period");
                        NSString *weekText = NSLocalizedStringFromTable(@"WeeklyChart", @"Draw", @"The weekly button for selecting K-line period");
                        NSString *monthText = NSLocalizedStringFromTable(@"MonthlyChart", @"Draw", @"The monthly button for selecting K-line period");
                        NSString *minuteText = NSLocalizedStringFromTable(@"5MinutelyChart", @"Draw", @"The 5-minutely button for selecting K-line period");
                        NSString *minuteText2 = NSLocalizedStringFromTable(@"15MinutelyChart", @"Draw", @"The 5-minutely button for selecting K-line period");
                        NSString *minuteText3 = NSLocalizedStringFromTable(@"30MinutelyChart", @"Draw", @"The 5-minutely button for selecting K-line period");
                        NSString *minuteText4 = NSLocalizedStringFromTable(@"60MinutelyChart", @"Draw", @"The 5-minutely button for selecting K-line period");
                        NSString *cancelText = NSLocalizedStringFromTable(@"取消",@"CompanyProfile",@"取消按鈕");
                        
                        periodsTypeSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelText destructiveButtonTitle:nil
                                                              otherButtonTitles:dayText,weekText,monthText,minuteText,minuteText2,minuteText3,minuteText4,nil];
                        
                        
                    }
                    
                    
                }
                
                else if(buttonIndex == 2) //指標參數設定
                {
                    //
                }
                
                
            }
            
            
        }
        else //k線週期 sheet
        {
        }
        
        return;
    }
}


#pragma mark -

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	
    return scaleView;
}


// ????
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//	return;
//    [self resetCrossView];
//	
//    scale /= ChartZoomOrigin;
//    [self updateZoomScale:scale andWidth:baseWidth*scale];
//}


- (void)resetZoomTransform 
{
	
    [self resetCrossView];
	[upperView refleshPeriodTitleAndIndicatorValue];
	
    if (!CGAffineTransformIsIdentity(scaleView.transform)) 
	{
		
        [scaleView removeFromSuperview];
		
        UIView *view = [[UIView alloc] init];
        self.scaleView = view;
		
        [scaleScrollView addSubview:scaleView];
    }
	
    [self updateZoomScale:1 andWidth:baseWidth];
}


- (void)zoomToMinScale 
{
	
    float scale = 1/ChartZoomOrigin;
    indexView.zoomTransform = CGAffineTransformMakeScale(scale, scale);
	
    CGFloat w = baseWidth / ChartZoomOrigin;
	
    indexScrollView.contentSize = CGSizeMake(w, indexScrollView.frame.size.height + 2);
	
    [bottonView1 postZoomToScale:scale andWidth:w];
    [bottonView2 postZoomToScale:scale andWidth:w];
	
    upperDateView.zoomTransform = CGAffineTransformMakeScale(scale, 1);
    upperDateScrollView.contentSize = CGSizeMake(w, upperDateScrollView.contentSize.height);
	
    upperValueView.zoomTransform = CGAffineTransformMakeScale(1, scale);
    upperValueScrollView.contentSize = CGSizeMake(upperValueScrollView.contentSize.width, upperValueScrollView.frame.size.height+1);

    //indexScrollView.contentOffset = CGPointMake(indexScrollView.contentOffset.x, 1);
    //upperValueScrollView.contentOffset = CGPointMake(upperValueScrollView.contentOffset.x, 1);
}

#pragma mark -
#pragma mark 換股

-(void)previousEquityName
{ 
	
	
	BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
	
	if(landscape || isPushFromWatchListController == NO)
	{
		
		return;
		
	}
	else
	{
		
		[self chartWillDisappear];
		
		//  add animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 0.75];
		[UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
		[UIView commitAnimations];	
		
		
		NSUInteger previousIndex;
		
		if(watchListRowIndex==0)
			previousIndex = [watchListRowDataArray count]-1;
		else
			previousIndex = watchListRowIndex-1;
		
		watchListRowIndex = previousIndex;	
						
		[self.indexView setBaseIndex:-1];
		portfolioItem =_watchportfolio.portfolioItem; //[portfolio findItemByIdentCodeSymbol:watchEquit.identCodeSymbol];
		
		[self chartWillAppear];		
		
		[self refleshEquityDrawViewControllerEquityData];	
		
	}		
	
}

-(void)nextEquityName
{
	
	BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
	
	if(landscape || isPushFromWatchListController == NO)
	{
		
		return;
		
	}
	else
	{
		
		[self chartWillDisappear];		
		
		//  add animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 0.75];
		[UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:self.view cache:YES];	
		[UIView commitAnimations];		
		
		
		NSUInteger nextIndex;
		
		if(watchListRowIndex==[watchListRowDataArray count]-1)
			nextIndex = 0;
		else
			nextIndex = watchListRowIndex+1;
		
		
		watchListRowIndex = nextIndex;
						
		[self.indexView setBaseIndex:-1];		
		portfolioItem =_watchportfolio.portfolioItem; //[portfolio findItemByIdentCodeSymbol:watchEquit.identCodeSymbol];
		
		[self chartWillAppear];		
		
		[self refleshEquityDrawViewControllerEquityData];
		
	}
	
}

-(void)refleshEquityDrawViewControllerEquityData
{
	
//	//更新前一個畫面的 equityName & equityData
//	
//	NSArray *controllers = self.navigationController.viewControllers;
//	
//	EquityDrawViewController *previousViewController = [controllers objectAtIndex:[controllers count]-2]; //倒數第二個為 EquityDrawViewController
//	
//	WatchListEquityData *watchEquit = [watchListRowDataArray objectAtIndex:watchListRowIndex];
//	
//	PortfolioItem *item = [portfolio findItemByIdentCodeSymbol:watchEquit.identCodeSymbol];
//	
//	
//	previousViewController.watchListRowDataArray = watchListRowDataArray;
//	previousViewController.equityName = watchEquit.fullName;				
//	previousViewController.watchListRowIndex = watchListRowIndex;
//	previousViewController.portfolioItem = item; 
	
}

#pragma mark - Layout

-(void)setLayout
{
//    [super updateViewConstraints];
//    [self.view removeConstraints:self.view.constraints];
    //    if (UIDeviceOrientationIsPortrait(_newOrientation)) {
//    UIView *superview = self.view;

    _compareOtherStockButton.translatesAutoresizingMaskIntoConstraints = NO;
    _intervalSettingButton.translatesAutoresizingMaskIntoConstraints = NO;
    _kLineParameterButton.translatesAutoresizingMaskIntoConstraints = NO;
    _dayLine.translatesAutoresizingMaskIntoConstraints = NO;
    _weekLine.translatesAutoresizingMaskIntoConstraints = NO;
    _monthLine.translatesAutoresizingMaskIntoConstraints = NO;
    _minLine.translatesAutoresizingMaskIntoConstraints = NO;
    _rowButton.translatesAutoresizingMaskIntoConstraints = NO;
    _twoStock.translatesAutoresizingMaskIntoConstraints = NO;
    _changeCompareStockBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _penBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _eraserBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _biggerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _smallerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    upperView.translatesAutoresizingMaskIntoConstraints = NO;
    bottonView1.translatesAutoresizingMaskIntoConstraints = NO;
    bottonView2.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_dayLine, _weekLine,_monthLine,_minLine,_rowButton, _kLineParameterButton,_twoStock,_changeCompareStockBtn,_penBtn,_eraserBtn,_biggerBtn,_smallerBtn, upperView, bottonView1, bottonView2 , indexScrollView, upperDateScrollView, upperValueScrollView,collectionView,reasonBtn,noteLabel,noteTextView,stockButton,notePlaceHolder);
    NSDictionary * widthDictionary = @{@"btnWidth":@((self.view.frame.size.width-1)/6.0f),@"secBtnWidth":@((self.view.frame.size.width-1)/8.0f),@"compareStockBtnWidth":@(self.view.frame.size.width/2-46)};
    _blueStockName.hidden = YES;
    _blueCompareStockName.hidden = YES;
    if(_arrowUpDownType == 4 || _arrowUpDownType == 5){
        noteLabel.font = [UIFont systemFontOfSize:12.0f];
        _dayLine.hidden = YES;
        _weekLine.hidden = YES;
        _monthLine.hidden = YES;
        _minLine.hidden = YES;
        _kLineParameterButton.hidden = YES;
        _rowButton.hidden = YES;
        _twoStock.hidden = YES;
        _changeCompareStockBtn.hidden = YES;
        _penBtn.hidden = YES;
        _eraserBtn.hidden = YES;
        _biggerBtn.hidden = YES;
        _smallerBtn.hidden = YES;
        bottonView2.hidden = YES;
        stockButton.hidden = NO;
        changeStockNameLabel.hidden = NO;
        changeStockSymbolLabel.hidden = NO;
        
        _autoLayoutUpperView = 0.75;
        
        [self updateNotesAndGainTitle:NO];

        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stockButton(40)][upperView][bottonView1]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stockButton]|" options:0 metrics:nil views:viewsDictionary]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:stockButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:stockButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:stockButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
        
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:changeStockSymbolLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:stockButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:changeStockSymbolLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:stockButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        //upperView佔整個畫面的六成
        [constraints addObject:[NSLayoutConstraint constraintWithItem:upperView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:_autoLayoutUpperView
                                                               constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:bottonView1
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1
                                                               constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[noteLabel(30)][noteTextView]|" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[noteLabel(190)][reasonBtn(80)][collectionView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(30)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reasonBtn(30)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[noteTextView]|" options:0 metrics:nil views:viewsDictionary]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:notePlaceHolder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:noteTextView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:notePlaceHolder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:noteTextView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
    }else{
        stockButton.hidden = YES;
       [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:_autoLayoutString options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dayLine(btnWidth)][_weekLine(btnWidth)][_monthLine(btnWidth)][_minLine(btnWidth)][_kLineParameterButton(btnWidth)][_rowButton(btnWidth)]" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:widthDictionary views:viewsDictionary]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_twoStock(46)][_changeCompareStockBtn(compareStockBtnWidth)][_penBtn(secBtnWidth)][_eraserBtn(secBtnWidth)][_biggerBtn(secBtnWidth)][_smallerBtn(secBtnWidth)]" options:NSLayoutFormatAlignAllTop metrics:widthDictionary views:viewsDictionary]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_twoStock]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_changeCompareStockBtn(==_twoStock)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_penBtn(==_twoStock)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_eraserBtn(==_twoStock)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_biggerBtn(==_twoStock)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_smallerBtn(==_twoStock)]" options:0 metrics:nil views:viewsDictionary]];
        //upperView佔整個畫面的六成
        [constraints addObject:[NSLayoutConstraint constraintWithItem:upperView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:_autoLayoutUpperView
                                                               constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:bottonView1
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1
                                                               constant:0]];
    }
    

    

    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:upperView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.87
                                                           constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:bottonView2
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];

    [self replaceCustomizeConstraints:constraints];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
	self.newOrientation = toInterfaceOrientation;
    
    if (_upperViewPicker) {
        [upperView closeUpperIndicatorPicker];
    }
    
    if (_bottonView1Picker) {
        [bottonView1 closeUpperIndicatorPicker];
    }
    if (_bottonView2Picker) {
        [bottonView2 closeUpperIndicatorPicker];
    }
//    BOOL fromLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
//    BOOL toLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
//    if (fromLandscape == toLandscape) return;
//	
//    UIView *view = self.view;
//    view.window.backgroundColor = view.backgroundColor;
//	
//    bottonView1.hidden = toLandscape;
//    bottonView2.hidden = toLandscape;
//	
//    [self openCrossView:NO animated:NO];
//    [self resetZoomTransform];
//	   
//    CGFloat valueWidth = ValueViewWidth;
//    CGFloat dateHeight = DateViewHeight;
//    CGRect frame;
//    CGRect viewFrame;
//	CGRect screen;
//	
//    if (toLandscape)
//	{
//        valueWidth += 13;
//        dateHeight += 8;
//        frame = CGRectMake(0, 0, 480, 300);
//		viewFrame = CGRectMake(1, ChartTop, frame.size.width-valueWidth, frame.size.height-ChartTop-dateHeight-1);
//		screen = CGRectMake(0, 0, 480, 320);
//    }
//    else
//	{
//        frame = CGRectMake(0, 0, 320, bottonView1.frame.origin.y+1);
//		viewFrame = CGRectMake(1, ChartTop, ChartWidth, frame.size.height-ChartTop-dateHeight);
//		screen = CGRectMake(0, 0, 320, 480);
//    }
//	
//    CGRect chartRect = CGRectMake(1, 1, viewFrame.size.width+1, viewFrame.size.height);
//    chartRect.origin.x *= ChartZoomOrigin;
//    chartRect.origin.y *= ChartZoomOrigin;
//    chartRect.size.height *= ChartZoomOrigin;
//	
//    upperView.frame = frame;
//    indexScrollView.frame = viewFrame;
//	drawAndScrollView.frame = screen;
//
//    indexView.frame = CGRectMake(0, 0, indexView.frame.size.width, (viewFrame.size.height+2)*ChartZoomOrigin);
//    indexView.chartFrame = CGRectMake(0, 0, indexView.chartFrame.size.width, chartRect.size.height);
//	
//	indexScaleView.frame = CGRectMake(indexScrollView.contentOffset.x, 0, viewFrame.size.width, viewFrame.size.height+1);
//	
//    CGRect r = CGRectMake(viewFrame.size.width+2, 2, valueWidth-3, frame.size.height-3);
//    upperValueScrollView.frame = r;
//    upperValueView.frame = CGRectMake(0, 0, r.size.width, (r.size.height+1)*ChartZoomOrigin);
//	
//    r = CGRectMake(viewFrame.origin.x, CGRectGetMaxY(viewFrame)+1, viewFrame.size.width, dateHeight-2);
//    upperDateScrollView.frame = r;
//    upperDateView.frame = CGRectMake(0, 0, upperDateView.frame.size.width, r.size.height);
//	
//    r = [indexScrollView convertRect:indexScrollView.bounds toView:self.view];
//    r.size.width++;
//    if (!toLandscape)
//        r.size.height = self.view.bounds.size.height - r.origin.y - 1;
//	
//    
//	// set cross line view rect
//    if (!toLandscape)
//	{
//		// 橫式 -> 直式
//		float h = self.view.bounds.size.width; //橫式的寬將成為直式的高
//        r.size.height = h - r.origin.y - 1;
//		crossLineView.frame = r;
//	}
//	else
//	{
//		// 橫式 -> 直式
//		crossLineView.frame = r;
//	}
//	
//	[upperView setNeedsDisplay];
//    [indexView setNeedsDisplay];
//	[indexScaleView getHigestAndLowest];
//	[indexScaleView setNeedsDisplay];
//	upperValueView.highest = indexScaleView.highestValue;
//	upperValueView.lowest = indexScaleView.lowestValue;
//    [upperValueView updateLabels];
//    [upperValueView adjustForOrientation:toLandscape];
//    [upperDateView adjustForOrientation:toLandscape];
//	
//	if(fromLandscape)
//        [self updateDateRange];
//	
//	if(toLandscape)
//		indexScaleView.offsetX = 1;
//	[upperView setNeedsDisplay];
//    [indexView setNeedsDisplay];
//	[indexScaleView getHigestAndLowest];
//	[indexScaleView setNeedsDisplay];
//	upperValueView.highest = indexScaleView.highestValue;
//	upperValueView.lowest = indexScaleView.lowestValue;
//    [upperValueView updateLabels];
//    [upperValueView adjustForOrientation:toLandscape];
//    [upperDateView adjustForOrientation:toLandscape];
//	
//	indexScaleView.hidden = NO;
//    //[indexScrollView bringSubviewToFront:indexScaleView];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(whetherCustomAlertIsOpen){
        [cxAlertView close];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        self.blueCompareStockName.tapToScroll = YES;
        self.blueStockName.tapToScroll = YES;
        [self.blueStockName setLabelize:NO];
        [self.blueCompareStockName setLabelize:NO];
        //調整bottomView 的高在這裡！
        _bottomViewHeight =[[UIScreen mainScreen]bounds].size.height*0.20+20;
        [doneButton setFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width - 70, 300, 70, 30)];
        [noteEditTextView setFrame:CGRectMake(0, 240, [[UIScreen mainScreen]bounds].size.width-70, 90)];
        ChartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.825;
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:1]floatValue];
        }else{
            _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:1]floatValue];
            if(_arrowUpDownType == 4 || _arrowUpDownType == 5){
                _autoLayoutUpperView = 0.75;
            }
        }
        _rowButton.hidden = YES;
        _kLineParameterButton.hidden = YES;
        _biggerBtn.hidden = YES;
        _smallerBtn.hidden = YES;
        bottonView2.hidden = YES;
        _touchView2.hidden = YES;
        _bottomView2ClickLabel.hidden = YES;
        if (_twoLine) {
            _blueCompareStockName.hidden = NO;
            _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_blueCompareStockName(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
        }else{
            _blueCompareStockName.hidden = YES;
            _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
        }
        [self LandscapeAutoLayout];
        
    }else if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
       
        [doneButton setFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width - 70, 300, 70, 30)];
        [noteEditTextView setFrame:CGRectMake(0, 240, [[UIScreen mainScreen]bounds].size.width-70, 90)];
        ChartWidth = 275.0;
        _rowButton.hidden = NO;
        _kLineParameterButton.hidden = NO;
        _biggerBtn.hidden = NO;
        _smallerBtn.hidden = NO;
        bottonView2.hidden = NO;
        _touchView2.hidden = NO;
        _bottomView2ClickLabel.hidden = NO;
        _changeCompareStockBtn.hidden = !_twoLine;
        _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:(_autoLayoutIndex %3)]floatValue];
        [self setLayout];
        _bottomViewHeight =self.view.frame.size.height*0.20-26;
        
    }
    
    
    if (!UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        bottonView1.hidden = NO;
    }else{
        if ((_autoLayoutIndex %3)==0) {
            _upperViewClickLabel.hidden = NO;
            _bottomView1ClickLabel.hidden = NO;
            _bottomView2ClickLabel.hidden = NO;
            bottonView1.hidden = NO;
            bottonView2.hidden = NO;
            ChartTop = 15.0f;
        }else if((_autoLayoutIndex %3)==1){
            bottonView2.hidden = YES;
            _bottomView2ClickLabel.hidden = YES;
            ChartTop = 15.0f;
        }else{
            bottonView1.hidden = YES;
            bottonView2.hidden = YES;
            _bottomView1ClickLabel.hidden = YES;
            _bottomView2ClickLabel.hidden = YES;
            ChartTop = 30.0f;
        }
    }
    [bottonView1 changeWidth];
    [self changeFrameSize];
    [self updateDateRange];
    [indexView setNeedsDisplay];
    [indexScaleView getHigestAndLowest];
    [indexScaleView setNeedsDisplay];
    [upperValueView updateLabels];
    [upperDateView updateLabels];
    [bottonView1 setNeedsDisplay];
    [bottonView1.dataView setNeedsDisplay];
    CGRect crossRect = [indexScrollView convertRect:indexScrollView.bounds toView:self.view];
    crossRect.size.width++;
    crossRect.size.height = [[UIScreen mainScreen] applicationFrame].size.height;
    [crossLineView setFrame:crossRect];
    
    
    if (_upperViewPicker) {
        [upperView openUpperIndicatorPicker];
        _upperViewPicker = YES;
    }
    if (_bottonView1Picker) {
        [bottonView1 openTypeControl:YES];
        _bottonView1Picker = YES;
    }
    
    if (_bottonView2Picker) {
        [bottonView2 openTypeControl:YES];
        _bottonView2Picker = YES;
    }
    
//    BOOL fromLandscape = UIInterfaceOrientationIsLandscape(fromInterfaceOrientation);
//    BOOL toLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
//    if (fromLandscape == toLandscape) return;
//	
//    UINavigationController *controller = self.navigationController;
//    [controller setNavigationBarHidden:toLandscape animated:NO];
//    self.hidesBottomBarWhenPushed = toLandscape;
//	
//	UIViewController *tmpController = [[UIViewController alloc] init];
//	[controller pushViewController:tmpController animated:NO];
//	[controller popViewControllerAnimated:NO];
	
    if(whetherCustomAlertIsOpen){
        [self arrowBtnClick];
    }
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


-(void)LandscapeAutoLayout{
    _compareOtherStockButton.translatesAutoresizingMaskIntoConstraints = NO;
    _intervalSettingButton.translatesAutoresizingMaskIntoConstraints = NO;
    _kLineParameterButton.translatesAutoresizingMaskIntoConstraints = NO;
    _blueStockName.translatesAutoresizingMaskIntoConstraints = NO;
    _blueCompareStockName.translatesAutoresizingMaskIntoConstraints = NO;
    _dayLine.translatesAutoresizingMaskIntoConstraints = NO;
    _weekLine.translatesAutoresizingMaskIntoConstraints = NO;
    _monthLine.translatesAutoresizingMaskIntoConstraints = NO;
    _minLine.translatesAutoresizingMaskIntoConstraints = NO;
    _rowButton.translatesAutoresizingMaskIntoConstraints = NO;
    _twoStock.translatesAutoresizingMaskIntoConstraints = NO;
    _changeCompareStockBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _penBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _eraserBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _biggerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _smallerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    upperView.translatesAutoresizingMaskIntoConstraints = NO;
    bottonView1.translatesAutoresizingMaskIntoConstraints = NO;
    bottonView2.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self updateNotesAndGainTitle:YES];
//    [self.view removeConstraints:self.view.constraints];
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_blueCompareStockName,_blueStockName,_dayLine, _weekLine,_monthLine,_minLine,_rowButton, _kLineParameterButton,_twoStock,_changeCompareStockBtn,_penBtn,_eraserBtn,_biggerBtn,_smallerBtn, upperView, bottonView1, bottonView2 , indexScrollView, upperDateScrollView, upperValueScrollView,collectionView,reasonBtn,noteLabel,noteTextView,notePlaceHolder);
    
    stockButton.hidden = YES;
    changeStockNameLabel.hidden = YES;
    changeStockSymbolLabel.hidden = YES;
    _changeCompareStockBtn.hidden = YES;
    if(_arrowUpDownType == 4 || _arrowUpDownType == 5){
        _blueStockName.hidden = YES;
        _dayLine.hidden = YES;
        _weekLine.hidden = YES;
        _monthLine.hidden = YES;
        _minLine.hidden = YES;
        _kLineParameterButton.hidden = YES;
        _rowButton.hidden = YES;
        _twoStock.hidden = YES;
        
        _penBtn.hidden = YES;
        _eraserBtn.hidden = YES;
        _biggerBtn.hidden = YES;
        _smallerBtn.hidden = YES;
        bottonView2.hidden = YES;
        noteLabel.font = [UIFont systemFontOfSize:16.0f];
        
        
//        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upperView]|" options:0 metrics:nil views:viewsDictionary]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:upperView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1
                                                               constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:upperView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.68 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:noteView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bottonView1 attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[noteLabel(30)][noteTextView]|" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[noteLabel(240)][reasonBtn(80)][collectionView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[collectionView(30)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reasonBtn(30)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[noteTextView]|" options:0 metrics:nil views:viewsDictionary]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:notePlaceHolder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:noteTextView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:notePlaceHolder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:noteTextView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottonView1]|" options:0 metrics:nil views:viewsDictionary]];
    }else{
        _blueStockName.hidden = NO;
        if (_twoLine) {
            _blueCompareStockName.hidden = NO;
        }else{
            _blueCompareStockName.hidden = YES;
        }
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:_LandscapeString options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_dayLine(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_weekLine(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_monthLine(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_minLine(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_twoStock(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_penBtn(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_eraserBtn(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_blueCompareStockName(_blueStockName)]" options:0 metrics:nil views:viewsDictionary]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upperView][_blueStockName]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDictionary]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:upperView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.91
                                                               constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:upperView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.67 constant:0]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[bottonView1(upperView)]" options:0 metrics:nil views:viewsDictionary]];
    }
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[upperView][bottonView1]|" options:0 metrics:nil views:viewsDictionary]];
//


    
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_drawingView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:upperView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_drawingView]|" options:0 metrics:0 views:viewsDictionary]];
    
    
    
    [self replaceCustomizeConstraints:constraints];

}

-(void)handPinch:(UIPinchGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        _pinchNum =sender.scale;
    }else if (sender.state == UIGestureRecognizerStateChanged){
        if (sender.scale-_pinchNum>0.2f) {
            float winLocationX = self.indexScaleView.frame.origin.x;
            NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+self.indexScaleView.frame.size.width-1];
            
            _oldPoint = CGPointMake(indexScrollView.contentOffset.x+dataEndIndex+1, indexScrollView.contentOffset.y);
            if (ChartBarWidth<29) {
                ChartBarWidth +=1;
                BarDateWidth +=1;
                
                [self changeSize:YES];
            }
        }else if(_pinchNum-sender.scale>0.2f){
            if (ChartBarWidth>3) {
                float winLocationX;
                if(self.indexScaleView.frame.size.width<273)
                    winLocationX = 0;
                else
                    winLocationX = self.indexScaleView.frame.origin.x;
                NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+self.indexScaleView.frame.size.width-1];
                if (indexScrollView.contentOffset.x-dataEndIndex<0) {
                    _oldPoint = CGPointMake(1, indexScrollView.contentOffset.y);
                }else{
                    _oldPoint = CGPointMake(indexScrollView.contentOffset.x-dataEndIndex-1, indexScrollView.contentOffset.y);
                }
                
                
                ChartBarWidth -=1;
                BarDateWidth -=1;
                [self changeSize:NO];
            }
        }
    }
    
}

-(void)setDefaultValue{
    float xSize = indexScaleView.frame.size.width;
    float ySize = indexScaleView.frame.size.height;
    ySize -=1;
    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = indexScaleView.frame.origin.x;
    
    
    int dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    if (dataEndIndex==0) {
        dataEndIndex=1;
    }
    [self updateUpperView:dataEndIndex];
}

-(void)nslogIndicatorPara{
    NSMutableDictionary * data = [_dataModal.operationalIndicator getDataByIndex:[self getSeqNumberFromPointXValue:crossX]];
    
    NSLog(@"MA1 : %f",[[data objectForKey:@"MA1"] doubleValue]);
    NSLog(@"MA2 : %f",[[data objectForKey:@"MA2"] doubleValue]);
    NSLog(@"MA3 : %f",[[data objectForKey:@"MA3"] doubleValue]);
    NSLog(@"MA4 : %f",[[data objectForKey:@"MA4"] doubleValue]);
    NSLog(@"MA5 : %f",[[data objectForKey:@"MA5"] doubleValue]);
    NSLog(@"MA6 : %f",[[data objectForKey:@"MA6"] doubleValue]);
    NSLog(@"AV-L : %f",[[data objectForKey:@"AVL"] doubleValue]);
    NSLog(@"AV-S : %f",[[data objectForKey:@"AVS"] doubleValue]);
    NSLog(@"PSY : %f",[[data objectForKey:@"PSY"] doubleValue]);
    NSLog(@"BB1 : %f",[[data objectForKey:@"BB1"] doubleValue]);
    NSLog(@"BB2 : %f",[[data objectForKey:@"BB2"] doubleValue]);
    NSLog(@"W%%R : %f",[[data objectForKey:@"WR"] doubleValue]);
    NSLog(@"VR : %f",[[data objectForKey:@"VR"] doubleValue]);
    NSLog(@"RSI-1 : %f",[[data objectForKey:@"RSI1"] doubleValue]);
    NSLog(@"RSI-2 : %f",[[data objectForKey:@"RSI2"] doubleValue]);
    NSLog(@"OBV : %f",[[data objectForKey:@"OBV"] doubleValue]);
    NSLog(@"OSC : %f",[[data objectForKey:@"OSC"] doubleValue]);
    NSLog(@"OSC MA : %f",[[data objectForKey:@"OSCMA"] doubleValue]);
    NSLog(@"AR : %f",[[data objectForKey:@"AR"] doubleValue]);
    NSLog(@"BR : %f",[[data objectForKey:@"BR"] doubleValue]);
    NSLog(@"BIAS : %f",[[data objectForKey:@"BIAS"] doubleValue]);
    NSLog(@"DMI + : %f",[[data objectForKey:@"DMIplus"] doubleValue]);
    NSLog(@"DMI - : %f",[[data objectForKey:@"DMIminus"] doubleValue]);
    NSLog(@"DMI adx : %f",[[data objectForKey:@"DMIadx"] doubleValue]);
    NSLog(@"KD K : %f",[[data objectForKey:@"KDK"] doubleValue]);
    NSLog(@"KD D : %f",[[data objectForKey:@"KDD"] doubleValue]);
    NSLog(@"KD J : %f",[[data objectForKey:@"KDJ"] doubleValue]);
    NSLog(@"MTM : %f",[[data objectForKey:@"MTM"] doubleValue]);
    NSLog(@"MTM MA : %f",[[data objectForKey:@"MTMMA"] doubleValue]);
    NSLog(@"diffEMA : %f",[[data objectForKey:@"diffEMA"] doubleValue]);
    NSLog(@"MACD : %f",[[data objectForKey:@"MACD"] doubleValue]);
    NSLog(@"D-M : %f",[[data objectForKey:@"diffEMA"] doubleValue]-[[data objectForKey:@"MACD"] doubleValue]);
    NSLog(@"SAR : %f",[[data objectForKey:@"SAR"] doubleValue]);
    NSLog(@"SAR Break : %f",[[data objectForKey:@"SARBreak"] doubleValue]);
    NSLog(@"TLB Open : %f",[[data objectForKey:@"TLBopen"] doubleValue]);
    NSLog(@"TLB Close : %f",[[data objectForKey:@"TLBclose"] doubleValue]);
}

#pragma mark -
#pragma mark 教學畫面

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
//    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];
    
    [_explainView showMenuWithRect:CGRectMake(50, 105, 0, 0) String:NSLocalizedStringFromTable(@"選擇期間", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(30, 55, 30, 56)];
    
    [_explainView showMenuWithRect:CGRectMake(250, 105, 0, 0) String:NSLocalizedStringFromTable(@"設定參數", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(240, 55, 30, 56)];
    
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [_explainView showMenuWithRect:CGRectMake(290, 360, 0, 0) String:NSLocalizedStringFromTable(@"選擇技術圖", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionDown];
        [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(280, 340, 30, 56)];
    }else{
        [_explainView showMenuWithRect:CGRectMake(290, 410, 0, 0) String:NSLocalizedStringFromTable(@"選擇技術圖", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionDown];
        [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(280, 390, 30, 56)];
    }
    
    
    
}

-(void)closeTeachPop:(UIView *)view{
    [view removeFromSuperview];
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    if (teachPopView.checkBtn.selected) {
        [_figureSearchMyProfileModel editInstructionByControllerName:[[self class]description] Show:@"NO"];
    }else{
        [_figureSearchMyProfileModel editInstructionByControllerName:[[self class]description] Show:@"YES"];
    }
}


-(void)arrowTapWithArrowData:(arrowData *)arrowData{
    if (arrowData && _arrowUpDownType == 4) {
        _autoLayoutIndex = 1;
        _autoLayoutString = [_autoLayoutArray objectAtIndex:(_autoLayoutIndex %3)];
        bottonView1.hidden = YES;
        bottonView2.hidden = YES;
        _bottomView1ClickLabel.hidden = YES;
        _bottomView2ClickLabel.hidden = YES;
        ChartTop = 15.0f;
        [_rowButton setImage:[UIImage imageNamed:@"Row按鍵2"] forState:UIControlStateNormal];
        [self changeFrameSize];
        [self updateDateRange];
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            [self setLayout];
        }else {
            [self LandscapeAutoLayout];
        }
        
//        [indexView setNeedsDisplay];
//        [indexScaleView getHigestAndLowest];
//        [indexScaleView setNeedsDisplay];
//        [bottonView1 setNeedsDisplay];
//        [bottonView2 setNeedsDisplay];
        
        _touchView1.hidden = YES;
        nowArrowData = arrowData;
        
        [selectArray removeAllObjects];
        [imgArray removeAllObjects];
        [numberArray removeAllObjects];
        for (int i=0; i<48; i++) {
            [selectArray addObject:[NSNumber numberWithBool:NO]];
    
        }
        NSString * type = arrowData -> type;
        NSString *typeText = @"";
        
        if (arrowData->arrowType==1) {
//            type = @"Buy";
            typeText = NSLocalizedStringFromTable(@"買", @"Draw", nil);
        }else{
//            type = @"Sell";
            typeText = NSLocalizedStringFromTable(@"賣", @"Draw", nil);
        }
        
        NSMutableArray * detailArray = [actionPlanModel searchSameDayBuyOrSellAVGWithIdentCodeSymbol:idSymbol Date:arrowData->date Deal:type];
        NSMutableArray * countArray = [detailArray objectAtIndex:0];
        NSMutableArray * priceArray = [detailArray objectAtIndex:1];
        int totalCount = 0;
        double totalPrice = 0;
        for (int i=0; i<[countArray count]; i++) {
            int count = [(NSNumber *)[countArray objectAtIndex:i]intValue];
            double price = [[priceArray objectAtIndex:i]doubleValue];
            totalPrice += count * price;
            totalCount += count;
        }
        
        noteLabel.text = [NSString stringWithFormat:@"%@ %.2f %@ %d %@",arrowData->date,totalPrice/totalCount,typeText,totalCount, NSLocalizedStringFromTable(@"張", @"Draw", nil)];        
                
        numberArray = [actionPlanModel searchReasonWithIdSymbol:idSymbol andDate:arrowData->date Type:type];
        
        for (int i=0; i<[numberArray count]; i++) {
            int num = [(NSNumber *)[numberArray objectAtIndex:i]intValue];
            [selectArray setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:num];
            [imgArray addObject:[actionPlanModel searchimageWithFigureSearchId:[NSNumber numberWithInt:num+1]]];
        }
        [collectionView reloadData];
        noteTextView.text = arrowData->note;
        if(![noteTextView.text isEqualToString:@""]){
            notePlaceHolder.hidden = YES;
        }else{
            notePlaceHolder.hidden = NO;
        }
//        NSLog(@"drawView:%d",arrowData->arrowType);
        
    }
    
}

-(void)arrowBtnClick{
    
    whetherCustomAlertIsOpen = YES;
    cxAlertView = [[CustomIOS7AlertView alloc]init];
    UIView * view = [[UIView alloc]init];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 280, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = NSLocalizedStringFromTable(@"選擇型態", @"Draw", nil);
    [cxAlertView setTitleLabel:label];
    [cxAlertView setContainerView:view];
    [cxAlertView setButtonTitles:@[NSLocalizedStringFromTable(@"確定", @"watchlists", nil)]];
    cxAlertView.delegate = self;
//    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        view.frame = CGRectMake(0, 0, 280, 300);
        actionTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 40, 260, 280) style:UITableViewStylePlain];
    }else{
        view.frame = CGRectMake(0, 0, 280, 200);
        actionTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 40, 260, 180) style:UITableViewStylePlain];
    }
    
    
    actionTableView.delegate = self;
    actionTableView.dataSource = self;
    actionTableView.bounces = NO;
    actionTableView.backgroundView = nil;
    
    section0CellNumber = 1;
    section1CellNumber = 1;
    section2CellNumber = 1;
    section3CellNumber = 1;
    indicator0Show = NO;
    indicator1Show = NO;
    indicator2Show = NO;
    indicator3Show = NO;
    
    [view addSubview:actionTableView];
    [cxAlertView show];
}

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSString * type = @"";
        if (nowArrowData) {
//            if (nowArrowData->arrowType==1) {
//                type = @"Buy";
//                
//            }else{
//                type = @"Sell";
//            }
            type = nowArrowData -> type;
            [actionPlanModel deleteReasonWithIdSymbol:idSymbol andDate:nowArrowData->date Type:type];
            
            
            for (int i=0; i<[selectArray count]; i++) {
                BOOL isSelect = [[selectArray objectAtIndex:i]boolValue];
                if (isSelect) {
                    [actionPlanModel insertReasonWithIdSymbol:idSymbol Date:nowArrowData->date num:[NSNumber numberWithInt:i] Type:type];
                }
            }
            numberArray = [actionPlanModel searchReasonWithIdSymbol:idSymbol andDate:nowArrowData->date Type:type];
            [imgArray removeAllObjects];
            for (int i=0; i<[numberArray count]; i++) {
                int num = [(NSNumber *)[numberArray objectAtIndex:i]intValue];
                [imgArray addObject:[actionPlanModel searchimageWithFigureSearchId:[NSNumber numberWithInt:num+1]]];
            }
            
            [collectionView reloadData];
        }
        [cxAlertView close];
        whetherCustomAlertIsOpen = NO;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return section0CellNumber;
    }else if (section == 1){
        return section1CellNumber;
    }else if (section == 2){
        return section2CellNumber;
    }else{
        return section3CellNumber;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"ActionPlanCell";
        FSActionSheetCell *cell = (FSActionSheetCell *)[actionTableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell=[[FSActionSheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        if (indexPath.section == 0) {
            cell.textLabel.text = NSLocalizedStringFromTable(@"系統型態(多)", @"Draw", nil);
        }else if (indexPath.section == 1){
            cell.textLabel.text = NSLocalizedStringFromTable(@"系統型態(空)", @"Draw", nil);
        }else if (indexPath.section == 2){
            cell.textLabel.text = NSLocalizedStringFromTable(@"自訂型態(多)", @"Draw", nil);
        }else if (indexPath.section == 3){
            cell.textLabel.text = NSLocalizedStringFromTable(@"自訂型態(空)", @"Draw", nil);
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"ActionPlanCell";
        FigureSearchCheckBoxTableViewCell *cell = (FigureSearchCheckBoxTableViewCell *)[actionTableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell=[[FigureSearchCheckBoxTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        if (indexPath.section == 0) {
            for (int i = 0; i < 12; i++) {
                if (indexPath.row == i + 1) {
                    cell.titleLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                    cell.checkBtn.selected = [[selectArray objectAtIndex:i]boolValue];
                    cell.searchImageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                }
            }
        }
        if (indexPath.section == 1) {
            for (int i = 12; i < 24; i++) {
                if (indexPath.row == i - 11) {
                    cell.titleLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                    cell.checkBtn.selected = [[selectArray objectAtIndex:i]boolValue];
                    cell.searchImageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                }
            }
        }
        if (indexPath.section == 2) {
            for (int i = 24; i < 36; i++) {
                if (indexPath.row == i - 23) {
                    cell.titleLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                    cell.checkBtn.selected = [[selectArray objectAtIndex:i]boolValue];
                    cell.searchImageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                }
            }
        }
        if (indexPath.section == 3) {
            for (int i = 36; i < 48; i++) {
                if (indexPath.row == i - 35) {
                    cell.titleLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                    cell.checkBtn.selected = [[selectArray objectAtIndex:i]boolValue];
                    cell.searchImageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                }
            }
        }
        return cell;
    }
}

- (void)insertRow:(NSIndexPath *)indexPath Section:(NSInteger)section{
    [showIndex removeAllObjects];
    
    if (section == 0) {
        indicator0Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:0];
            [showIndex addObject:indexPathToInsert];
        }
        section0CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 1) {
        indicator1Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:1];
            [showIndex addObject:indexPathToInsert];
        }
        section1CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 2){
        indicator2Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:2];
            [showIndex addObject:indexPathToInsert];
        }
        section2CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 3){
        indicator3Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:3];
            [showIndex addObject:indexPathToInsert];
        }
        section3CellNumber = indicatorNumberOfTables + 1;
    }
    
    [actionTableView beginUpdates];
    [actionTableView insertRowsAtIndexPaths:showIndex withRowAnimation:UITableViewRowAnimationTop];
    [actionTableView endUpdates];
}

- (void)deleteRow:(NSIndexPath *)RowtoDelete Section:(NSInteger)section{
    if (section == 0) {
        indicator0Show = NO;
        section0CellNumber = 1;
    }
    
    if (section == 1) {
        indicator1Show = NO;
        section1CellNumber = 1;
    }
    
    if (section == 2) {
        indicator2Show = NO;
        section2CellNumber = 1;
    }
    
    if (section == 3) {
        indicator3Show = NO;
        section3CellNumber = 1;
    }
    
    NSMutableArray* rowToDelete = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [showIndex count]; i++) {
        NSIndexPath* indexPathToDelete = [showIndex objectAtIndex:i];
        [rowToDelete addObject:indexPathToDelete];
    }
    [actionTableView beginUpdates];
    [actionTableView deleteRowsAtIndexPaths:rowToDelete withRowAnimation:UITableViewRowAnimationLeft];
    [actionTableView endUpdates];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!indicator0Show && indexPath.section == 0 && indexPath.row == 0) {
        if (indicator1Show) {
            [self deleteRow:indexPath Section:1];
        }
        if (indicator2Show) {
            [self deleteRow:indexPath Section:2];
        }
        if (indicator3Show) {
            [self deleteRow:indexPath Section:3];
        }
        [self insertRow:indexPath Section:0];
    }else if (indicator0Show && indexPath.section == 0 && indexPath.row == 0){
        [self deleteRow:indexPath Section:0];
    }else if (!indicator1Show && indexPath.section == 1 && indexPath.row == 0) {
        if (indicator0Show) {
            [self deleteRow:indexPath Section:0];
        }
        if (indicator2Show) {
            [self deleteRow:indexPath Section:2];
        }
        if (indicator3Show) {
            [self deleteRow:indexPath Section:3];
        }
        [self insertRow:indexPath Section:1];
    }else if (indicator1Show && indexPath.section == 1 && indexPath.row == 0){
        [self deleteRow:indexPath Section:1];
    }else if (!indicator2Show && indexPath.section == 2 && indexPath.row == 0) {
        if (indicator0Show) {
            [self deleteRow:indexPath Section:0];
        }
        if (indicator1Show) {
            [self deleteRow:indexPath Section:1];
        }
        if (indicator3Show) {
            [self deleteRow:indexPath Section:3];
        }
        [self insertRow:indexPath Section:2];
    }else if (indicator2Show && indexPath.section == 2 && indexPath.row == 0){
        [self deleteRow:indexPath Section:2];
    }else if (!indicator3Show && indexPath.section == 3 && indexPath.row == 0) {
        if (indicator0Show) {
            [self deleteRow:indexPath Section:0];
        }
        if (indicator1Show) {
            [self deleteRow:indexPath Section:1];
        }
        if (indicator2Show) {
            [self deleteRow:indexPath Section:2];
        }
        [self insertRow:indexPath Section:3];
    }else if (indicator3Show && indexPath.section == 3 && indexPath.row == 0){
        [self deleteRow:indexPath Section:3];
    }else{
        NSUInteger num = -1;
         if (indexPath.section == 0) {
             num = indexPath.row-1;
         }else if (indexPath.section == 1){
             num = indexPath.row+11;
         }else if (indexPath.section == 2){
             num = indexPath.row+23;
         }else if (indexPath.section == 3){
             num = indexPath.row+35;
         }
        
        if (num != -1) {
            BOOL isSelect = [[selectArray objectAtIndex:num]boolValue];
            [selectArray setObject:[NSNumber numberWithBool:!isSelect] atIndexedSubscript:num];
        }
//        [actionPlanModel updateReason:reasonBtn.titleLabel.text WithPerformanceNum:nowArrowData->date];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
//        NSDate * date  = [dateFormatter dateFromString:nowArrowData->date];
//        [indexScaleView changReason:reasonBtn.titleLabel.text Key:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
        
        NSArray * array = [[NSArray alloc]initWithObjects:indexPath, nil];
        [actionTableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
        
    }
    
    
    
//    for (int i = 0; i < indicatorNumberOfTables; i++) {
//            }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet isEqual:drawLineActionSheet]) {
        if (buttonIndex==9) {
            indexScrollView.scrollEnabled = YES;
            _penBtn.selected = NO;
            if ([indexScaleView.drawLinePoints count]==0) {
                [self.indexView setChartFrameOffset:CGPointMake(1, 1)];
                indexScaleView.offsetX = 1;
                _chartFrameOffset = CGPointMake(1, 1);
                [indexView setNeedsDisplay];
                [indexScaleView setNeedsDisplay];
                [upperDateView updateLabels];
                [bottonView1 setNeedsDisplay];
                [bottonView2 setNeedsDisplay];
            }
        }else if (buttonIndex==0){
            //上次圖
            _lineType = PreviousLines;
            NSMutableArray * pointArray = [techModel selectUserLineByIdentCode:idSymbol analysisPeriod:[NSNumber numberWithInt:analysisPeriod]];
            indexScaleView.drawLinePoints = pointArray;
            [indexScaleView setNeedsDisplay];
        }
        else{
            _lineType = buttonIndex-1;
        }
    }
    
    if ([actionSheet isEqual:eraserActionSheet]){
        if (buttonIndex==1) {
            indexScrollView.scrollEnabled = YES;
            _eraserBtn.selected = NO;
            [indexScaleView.drawLinePoints removeAllObjects];
            [self.indexView setChartFrameOffset:CGPointMake(1, 1)];
            indexScaleView.offsetX = 1;
            _chartFrameOffset = CGPointMake(1, 1);
            [indexView setNeedsDisplay];
            [indexScaleView setNeedsDisplay];
            [upperDateView updateLabels];
            [bottonView1 setNeedsDisplay];
            [bottonView2 setNeedsDisplay];

        }else if (buttonIndex==2){
            //存檔
            [techModel deleteUserLineByIdentCode:idSymbol analysisPeriod:[NSNumber numberWithInt:analysisPeriod]];
            
            for (int i=0; i<[indexScaleView.drawLinePoints count]; i++) {
                Line * line = [indexScaleView.drawLinePoints objectAtIndex:i];
                
                [techModel insertUserLineByIdentCode:idSymbol analysisPeriod:[NSNumber numberWithInt:analysisPeriod] lineType:[NSNumber numberWithInt:line.lineType] lineNumber:[NSNumber numberWithInt:line.lineNum] pointA:line.pointA pointB:line.pointB];
            }
        }
    }
    
    if ([actionSheet isEqual:parameterSheet]) {
        if (buttonIndex == 0) {
            SettingIndicatorsViewController * settingIndicators = [[SettingIndicatorsViewController alloc]init];
            [self.navigationController pushViewController:settingIndicators animated:NO];
        }else if(buttonIndex == 1){
            FSBrokerParametersViewController *brokerOptional = [[FSBrokerParametersViewController alloc]init];
            [self.navigationController pushViewController:brokerOptional animated:NO];
        }
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [numberArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FigureSearchCollectionViewCell *cell = (FigureSearchCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:@"FigureSearchItemIdentifier" forIndexPath:indexPath];
    if(!cell){
        cell = [[FigureSearchCollectionViewCell alloc] initWithFrame:CGRectZero];
    }
    cell.imageView.image = [UIImage imageWithData:[imgArray objectAtIndex:indexPath.row]];
    cell.title.text = @"";
    cell.title.adjustsFontSizeToFitWidth = NO;
    cell.title.lineBreakMode = NSLineBreakByWordWrapping;
    cell.title.numberOfLines = 2;
    cell.title.font = [UIFont boldSystemFontOfSize:10.0f];
    return cell;
}

-(void)prePareDrawLineData{
    drawLineTitleArray = [[NSMutableArray alloc]initWithObjects:
                            NSLocalizedStringFromTable(@"趨勢線", @"Draw", nil),
                            NSLocalizedStringFromTable(@"平行線", @"Draw", nil),
                            NSLocalizedStringFromTable(@"黃金分割線", @"Draw", nil),
                            NSLocalizedStringFromTable(@"甘氏角度線", @"Draw", nil),
                            NSLocalizedStringFromTable(@"黃金扇", @"Draw", nil),
                            NSLocalizedStringFromTable(@"阻速線", @"Draw", nil),
                            NSLocalizedStringFromTable(@"黃金弧", @"Draw", nil),
                            NSLocalizedStringFromTable(@"費波南希轉折", @"Draw", nil),nil];
    
    eraserTitleArray = [[NSMutableArray alloc] initWithObjects:
                        NSLocalizedStringFromTable(@"清除單線", @"Draw", nil),
                        NSLocalizedStringFromTable(@"清除全部", @"Draw", nil),
                        NSLocalizedStringFromTable(@"劃線儲存", @"Draw", nil), nil];
}


-(void)showDrawLineActionSheet{
    //NSLocalizedStringFromTable(@"選擇畫線種類", @"Draw", nil) ← 原本的title 字樣
    drawLineActionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedStringFromTable(@"選擇畫線種類", @"Draw", @"選擇畫線種類") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    [drawLineActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"顯示上次內容", @"Draw", nil)];
    
    for (int i=0 ;i<[drawLineTitleArray count];i++) {
        NSString * title = [drawLineTitleArray objectAtIndex:i];
        [drawLineActionSheet addButtonWithTitle:title];
    }
    
    [drawLineActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"Draw", nil)];
    
    [self showActionSheet:drawLineActionSheet];
}

-(void)showEraserActionSheet{
    eraserActionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedStringFromTable(@"選擇清除工具", @"Draw", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for (int i=0 ;i<[eraserTitleArray count];i++) {
        NSString * title = [eraserTitleArray objectAtIndex:i];
        [eraserActionSheet addButtonWithTitle:title];
    }
    
    [eraserActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"Cancel", @"Draw", nil)];
    
    [self showActionSheet:eraserActionSheet];
}


-(void)allUserLineRemove{
    [self.indexView setChartFrameOffset:CGPointMake(1, 1)];
    indexScaleView.offsetX = 1;
    _chartFrameOffset = CGPointMake(1, 1);
    [indexView setNeedsDisplay];
    [indexScaleView setNeedsDisplay];
    [upperDateView updateLabels];
    [bottonView1 setNeedsDisplay];
    [bottonView2 setNeedsDisplay];
}


-(void)drawOver{
    if ([indexScaleView.objDataArray count]>0) {
        NSMutableDictionary * dic =[_dateDictionary objectForKey:[indexScaleView.objDataArray lastObject]];
        arrowData * data = [[arrowData alloc]init];
        
        data = [dic objectForKey:@"BUY"];
        
        if (data==nil) {
            data = [dic objectForKey:@"SHORT"];
        }
        if (data==nil) {
            data = [dic objectForKey:@"SELL"];
        }
        if (data==nil) {
            data = [dic objectForKey:@"COVER"];
        }
        if (_first) {
            _first = NO;
            [self arrowTapWithArrowData:data];
        }
        
    }

}


-(void)rotate{
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
//        if(_arrowUpDownType == 4){
//            self.navigationItem.title = NSLocalizedStringFromTable(@"Notes", @"Draw", @"");
//        }else if (_arrowUpDownType == 5){
//            self.navigationItem.title = NSLocalizedStringFromTable(@"Gain", @"Draw", @"");
//        }
        if (portfolioItem !=nil){
            changeStockNameLabel.text = portfolioItem->fullName;
            changeStockSymbolLabel.text = portfolioItem->symbol;
        }
        ChartWidth = [[UIScreen mainScreen] applicationFrame].size.width*0.86;
        
        if (_arrowUpDownType == 4){
            [crossLineView setFrame:CGRectMake(0, 0, ChartWidth, [[UIScreen mainScreen] applicationFrame].size.height-200)];
            bottonView2.hidden = YES;
            _touchView1.hidden = YES;
            _autoLayoutIndex = 1;
            _autoLayoutString = [_autoLayoutArray objectAtIndex:(_autoLayoutIndex %3)];
            int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
            if (screenHeight==460) {
                _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:(_autoLayoutIndex %3)]floatValue];
            }else{
                _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:(_autoLayoutIndex %3)]floatValue];
            }
            [self changeFrameSize];
        }
        else if (_arrowUpDownType == 5){
            [crossLineView setFrame:CGRectMake(0, 0, ChartWidth, [[UIScreen mainScreen] applicationFrame].size.height)];
            bottonView2.hidden = YES;
            _touchView1.hidden =YES;
            noteView.hidden = YES;
            _autoLayoutIndex = 1;
            _autoLayoutString = [_autoLayoutArray objectAtIndex:(_autoLayoutIndex %3)];
            int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
            if (screenHeight==460) {
                _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:(_autoLayoutIndex %3)]floatValue];
            }else{
                _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:(_autoLayoutIndex %3)]floatValue];
            }
            [self changeFrameSize];
        }
        
        [self setLayout];
        
        [bottonView1 changeWidth];
//        [self changeFrameSize];
        [self updateDateRange];
        
        [indexView setNeedsDisplay];
        [indexScaleView getHigestAndLowest];
        [indexScaleView setNeedsDisplay];
//        [upperValueView updateLabels];
//        [upperDateView updateLabels];
        [bottonView1 setNeedsDisplay];
        [bottonView1.dataView setNeedsDisplay];
    }else {
        if (portfolioItem !=nil){
//            if(_arrowUpDownType == 4){
//                self.navigationItem.title = NSLocalizedStringFromTable(@"Notes", @"Draw", @"");
//            }else if (_arrowUpDownType == 5){
//                self.navigationItem.title = NSLocalizedStringFromTable(@"Gain", @"Draw", @"");
//            }
//            self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@ (%@)",self.navigationItem.title,portfolioItem->symbol,portfolioItem->fullName];
            changeStockNameLabel.text = portfolioItem->fullName;
            changeStockSymbolLabel.text = portfolioItem->symbol;
        }
        ChartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.825;
        if (_arrowUpDownType ==4 || _arrowUpDownType == 5) {
            ChartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.915;
        }
        
        if (_arrowUpDownType == 4) {
            [crossLineView setFrame:CGRectMake(0, 0, ChartWidth, [[UIScreen mainScreen] applicationFrame].size.width-145)];
        }else{
            [crossLineView setFrame:CGRectMake(0, 0, ChartWidth, [[UIScreen mainScreen] applicationFrame].size.width)];
        }
        
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            _autoLayoutUpperView = [(NSNumber *)[_autoLayoutSmall objectAtIndex:1]floatValue];
        }else{
            
            _autoLayoutUpperView = [(NSNumber *)[_autoLayout objectAtIndex:1]floatValue];
        }
        
        
        _rowButton.hidden = YES;
        _kLineParameterButton.hidden = YES;
        _biggerBtn.hidden = YES;
        _smallerBtn.hidden = YES;
        bottonView2.hidden = YES;
        _touchView2.hidden = YES;
        _bottomView2ClickLabel.hidden = YES;
        
        if (_twoLine) {
            _blueCompareStockName.hidden = NO;
            _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_blueCompareStockName(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
        }else{
            _blueCompareStockName.hidden = YES;
            _LandscapeString = @"V:|[_blueStockName][_dayLine(_blueStockName)][_weekLine(_blueStockName)][_monthLine(_blueStockName)][_minLine(_blueStockName)][_twoStock(_blueStockName)][_penBtn(_blueStockName)][_eraserBtn(_blueStockName)]|";
        }
        [self LandscapeAutoLayout];
        
        [bottonView1 changeWidth];
        [self changeFrameSize];
        [self updateDateRange];
        
        [indexView setNeedsDisplay];
        [indexScaleView getHigestAndLowest];
        [indexScaleView setNeedsDisplay];
        [upperValueView updateLabels];
        [upperDateView updateLabels];
        [bottonView1 setNeedsDisplay];
        [bottonView1.dataView setNeedsDisplay];
        
        
    }
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}
-(void)updateNotesAndGainTitle:(BOOL)isNotes{
    if(_arrowUpDownType == 4){
        self.navigationItem.title = NSLocalizedStringFromTable(@"Notes", @"Draw", @"");
    }else if (_arrowUpDownType == 5){
        self.navigationItem.title = NSLocalizedStringFromTable(@"Gain", @"Draw", @"");
    }
    if (isNotes) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@ (%@)",self.navigationItem.title,portfolioItem->fullName,portfolioItem->symbol];
    }
}
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
