//
//  TechViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TechViewController.h"
#import "TechDrawTopView.h"
#import "TechDrawBottomView.h"
#import "TechIn.h"
#import "TechInfoView.h"
#define lineWidth 0.5
#define mNum1 5
#define mNum2 10
#define mNum3 20
#define topAndBottomHeight 15
#define bottomTopHeight 17
//要的k線筆數
#define dataCount 120
#define IS_IPAD [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound

@interface TechViewController () <UIScrollViewDelegate> {
    //K線圖的View
    TechDrawTopView *drawTopView;
    TechDrawDateView *monthView;
    
    
    //下方技術指標圖的View
    TechDrawBottomView *drawBottomView;
    UIScrollView *topScrollView;
    UIScrollView *bottomScrollView;
    //上方右邊K線格價的View
    UIView *topRightView;
    //下方右邊技術指標數值的View
    UIView *bottomRightView;
    
    FSDataModelProc *dataModel;
    double widthRange;
    NSMutableArray *layoutConstraints;
    
    NSMutableArray *drawArray;
    
    //K線價格間距的六個Label
    UILabel *priceLabel1;
    UILabel *priceLabel2;
    UILabel *priceLabel3;
    UILabel *priceLabel4;
    UILabel *priceLabel5;
    UILabel *priceLabel6;
    UILabel *priceLabel7;
    
    //技術指標數值的Label
    UILabel *brLabel1;
    UILabel *brLabel2;
    UILabel *brLabel3;
    
    //K線圖上方移動平均線數值的Label
    UILabel *mLabel1;
    UILabel *mLabel2;
    UILabel *mLabel3;
    
    //技術指標圖上方的Label
    UILabel *bLabel1;
    UILabel *bLabel2;
    UILabel *bLabel3;
    
    //十字線的水平線
    UILabel *horizontalLine;
    //十字線的垂直線
    UILabel *verticalLine;
    
    //點擊後出現的資訊面板
    TechInfoView *infoView;
    
    //上方右邊圖的Title
    UILabel *trTitleLabel;
    
    //下方右邊圖的Title
    UILabel *brTitleLabel;
    
    //十字線UIVIEW
    UIView *crossView;
    
    UIColor *upColor;
    UIColor *downColor;
    
    BOOL addFlag;
    
    NSDateFormatter *dateFormatter;
    
    CGFloat lastScale;
}

@end

@implementation TechViewController

-(id)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self){
        _symbolDict = dict;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpImageBackButton];
    
    //設定為5，表示每筆資料畫出來的間距差為5。
    widthRange = 5;
    
    //美股與台股時間顯示的格式不同
    dateFormatter = [[NSDateFormatter alloc] init];
    if([[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"us"]){
        upColor = [UIColor colorWithRed:82.0/255.0 green:186.0/255.0 blue:0 alpha:1];
        downColor = [UIColor redColor];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }else{
        downColor = [UIColor colorWithRed:82.0/255.0 green:186.0/255.0 blue:0 alpha:1];
        upColor = [UIColor redColor];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    
    [self initView];
    [self initModel];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(scale:)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:pinchRecognizer];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setPriceLabelFrame];
}
-(void)scale:(UIPinchGestureRecognizer*)sender {
    
    //当手指离开屏幕时,将lastscale设置为1.0
    if([sender state] == UIGestureRecognizerStateEnded) {
        lastScale = 1.0;
        dataModel.tech.pinchValue = _pinchValue;
        dataModel.tech.widthRange = widthRange;
        return;
    }

    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    
    if(widthRange <= 35){
        if(scale > 1){
            _pinchValue += 0.3;
            widthRange += 0.3;
            drawBottomView.widthRange = widthRange;
            drawTopView.widthRange = widthRange;
            monthView.widthRange = widthRange;
            [self setDrawView];
        }
    }
    if(widthRange >= 5.3){
        if(scale < 1){
            _pinchValue -= 0.3;
            widthRange -= 0.3;
            drawBottomView.widthRange = widthRange;
            drawTopView.widthRange = widthRange;
            monthView.widthRange = widthRange;
            [self setDrawView];
        }
    }
    
    lastScale = [sender scale];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //如果沒加這兩行，記憶體不會被釋放
    self.navigationItem.rightBarButtonItem = nil;
    [dataModel.tech setTarget:nil];
    topScrollView.delegate = nil;
    bottomScrollView.delegate = nil;
    drawTopView.obj = nil;
    drawBottomView.obj = nil;
//    [self.view removeFromSuperview];
//    self.view = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 初始化
-(void)initModel
{
    [FSHUD showHUDin:self.view title:@""];
    dataModel = [FSDataModelProc sharedInstance];
    
    if (dataModel.tech.widthRange == 0) dataModel.tech.widthRange = 5;
    _pinchValue = dataModel.tech.pinchValue;
    widthRange = dataModel.tech.widthRange;
    
    [dataModel.tech setTarget:self];
    
    //從資料庫取出現有該identCodeSymbol 的資料
    //所以當使用者按下沒讀取過的股名時，drawArray 會是空的，而notify 下來的資料會有東西
    drawArray = [dataModel.tech getKData:[_symbolDict objectForKey:@"IdentCodeSymbol"]];
    
    UInt16 endDate;
    //要K線資料為4年，起始日為4年前，結束日為前一天(因當天的資料日期server隔天早上10點才會有)
    endDate = [[NSDate date] uint16Value];
    
    //DB 已經有最新日期的資料則會直接抓資料庫的，DB 如果沒有才會送出電文
    if([dataModel.tech isTodayK:[_symbolDict objectForKey:@"IdentCodeSymbol"] Time:endDate]){
        [self initData];
    }
    else{
        [dataModel.tech performSelector:@selector(initDataModel:) onThread:dataModel.thread withObject:[_symbolDict objectForKey:@"IdentCodeSymbol"] waitUntilDone:YES];
    }
}

-(void)initView
{
    
    
    if([[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"us"]) {
        self.title = [NSString stringWithFormat:@"%@", [_symbolDict objectForKey:@"FullName"]];
    } else {
        self.title = [NSString stringWithFormat:@"%@ %@", [_symbolDict objectForKey:@"FullName"], [_symbolDict objectForKey:@"Symbol"]];
    }
    
    
    layoutConstraints = [[NSMutableArray alloc] init];

    topScrollView = [[UIScrollView alloc] init];
    topScrollView.delegate = self;
    topScrollView.bounces = NO;
    [topScrollView setShowsHorizontalScrollIndicator:NO];
    topScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topScrollView];
    
    bottomScrollView = [[UIScrollView alloc] init];
    bottomScrollView.delegate = self;
    bottomScrollView.bounces = NO;
    [bottomScrollView setShowsHorizontalScrollIndicator:NO];
    bottomScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomScrollView];
    
    drawTopView = [[TechDrawTopView alloc] init];
    drawTopView.userInteractionEnabled = YES;
    drawTopView.backgroundColor = [UIColor clearColor];
    drawTopView.layer.borderWidth = 0.5f;
    [topScrollView addSubview:drawTopView];
    
    monthView = [[TechDrawDateView alloc] init];
    monthView.layer.borderWidth = 0.5f;
    monthView.backgroundColor = [UIColor clearColor];
    [topScrollView addSubview:monthView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    [drawTopView addGestureRecognizer:longPress];
    
    
    drawBottomView = [[TechDrawBottomView alloc] initWithType:[_symbolDict objectForKey:@"Type"]];
    drawBottomView.translatesAutoresizingMaskIntoConstraints = NO;
    drawBottomView.backgroundColor = [UIColor clearColor];
    drawBottomView.layer.borderWidth = 0.5f;
    [bottomScrollView addSubview:drawBottomView];
    
    topRightView = [[UIView alloc] init];
    topRightView.translatesAutoresizingMaskIntoConstraints = NO;
    topRightView.layer.borderWidth = 0.5f;
    [self.view addSubview:topRightView];
    
    bottomRightView = [[UIView alloc] init];
    bottomRightView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomRightView.layer.borderWidth = 0.5f;
    [self.view addSubview:bottomRightView];
    
    UIFont *priceFont = [UIFont systemFontOfSize:13.0f];
    
    priceLabel1 = [[UILabel alloc] init];
    priceLabel1.adjustsFontSizeToFitWidth = YES;
    priceLabel1.font = priceFont;
    priceLabel1.textColor = [UIColor blueColor];
    [topRightView addSubview:priceLabel1];
    
    priceLabel2 = [[UILabel alloc] init];
    priceLabel2.adjustsFontSizeToFitWidth = YES;
    priceLabel2.font = priceFont;
    priceLabel2.textColor = [UIColor blueColor];
    [topRightView addSubview:priceLabel2];
    
    priceLabel3 = [[UILabel alloc] init];
    priceLabel3.adjustsFontSizeToFitWidth = YES;
    priceLabel3.font = priceFont;
    priceLabel3.textColor = [UIColor blueColor];
    [topRightView addSubview:priceLabel3];
    
    priceLabel4 = [[UILabel alloc] init];
    priceLabel4.adjustsFontSizeToFitWidth = YES;
    priceLabel4.font = priceFont;
    priceLabel4.textColor = [UIColor blueColor];
    [topRightView addSubview:priceLabel4];
    
    priceLabel5= [[UILabel alloc] init];
    priceLabel5.adjustsFontSizeToFitWidth = YES;
    priceLabel5.font = priceFont;
    priceLabel5.textColor = [UIColor blueColor];
    [topRightView addSubview:priceLabel5];
    
    priceLabel6 = [[UILabel alloc] init];
    priceLabel6.adjustsFontSizeToFitWidth = YES;
    priceLabel6.font = priceFont;
    priceLabel6.textColor = [UIColor blueColor];
    [topRightView addSubview:priceLabel6];
    
    priceLabel7 = [[UILabel alloc] init];
    priceLabel7.adjustsFontSizeToFitWidth = YES;
    priceLabel7.font = priceFont;
    priceLabel7.textColor = [UIColor blueColor];
    [topRightView addSubview:priceLabel7];
    
    brLabel1 = [[UILabel alloc] init];
    brLabel1.adjustsFontSizeToFitWidth = YES;
    brLabel1.font = priceFont;
    brLabel1.textColor = [UIColor blueColor];
    [bottomRightView addSubview:brLabel1];
    
    brLabel2 = [[UILabel alloc] init];
    brLabel2.adjustsFontSizeToFitWidth = YES;
    brLabel2.font = priceFont;
    brLabel2.textColor = [UIColor blueColor];
    [bottomRightView addSubview:brLabel2];
    
    brLabel3 = [[UILabel alloc] init];
    brLabel3.adjustsFontSizeToFitWidth = YES;
    brLabel3.font = priceFont;
    brLabel3.textColor = [UIColor blueColor];
    [bottomRightView addSubview:brLabel3];
    
    mLabel1 = [[UILabel alloc] init];
    mLabel1.font = priceFont;
    mLabel1.adjustsFontSizeToFitWidth = YES;
    mLabel1.backgroundColor = [UIColor whiteColor];
    [drawTopView addSubview:mLabel1];
    
    mLabel2 = [[UILabel alloc] init];
    mLabel2.font = priceFont;
    mLabel2.adjustsFontSizeToFitWidth = YES;
    mLabel2.backgroundColor = [UIColor whiteColor];
    [drawTopView addSubview:mLabel2];
    
    mLabel3 = [[UILabel alloc] init];
    mLabel3.font = priceFont;
    mLabel3.adjustsFontSizeToFitWidth = YES;
    mLabel3.backgroundColor = [UIColor whiteColor];
    [drawTopView addSubview:mLabel3];
    
    bLabel1 = [[UILabel alloc] init];
    bLabel1.font = priceFont;
    bLabel1.adjustsFontSizeToFitWidth = YES;
    bLabel1.backgroundColor = [UIColor whiteColor];
    [drawBottomView addSubview:bLabel1];
    
    bLabel2 = [[UILabel alloc] init];
    bLabel2.font = priceFont;
    bLabel2.adjustsFontSizeToFitWidth = YES;
    bLabel2.backgroundColor = [UIColor whiteColor];
    [drawBottomView addSubview:bLabel2];
    
    bLabel3 = [[UILabel alloc] init];
    bLabel3.font = priceFont;
    bLabel3.adjustsFontSizeToFitWidth = YES;
    bLabel3.backgroundColor = [UIColor whiteColor];
    [drawBottomView addSubview:bLabel3];
    
    trTitleLabel = [[UILabel alloc] init];
    trTitleLabel.textAlignment = NSTextAlignmentCenter;
    trTitleLabel.textColor = [UIColor whiteColor];
    trTitleLabel.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:143.0/255.0 blue:223.0/255.0 alpha:1];
    trTitleLabel.text = NSLocalizedStringFromTable(@"K線", @"DivergenceTips", nil);
    [topRightView addSubview:trTitleLabel];
    
    brTitleLabel = [[UILabel alloc] init];
    brTitleLabel.textAlignment = NSTextAlignmentCenter;
    brTitleLabel.textColor = [UIColor whiteColor];
    brTitleLabel.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:143.0/255.0 blue:223.0/255.0 alpha:1];
    if([drawBottomView.drawType isEqualToString:@"Vol"]){
        brTitleLabel.text = NSLocalizedStringFromTable(@"單量", @"DivergenceTips", nil);
    }else if([drawBottomView.drawType isEqualToString:@"KD"]){
        brTitleLabel.text = @"KD";
    }else if([drawBottomView.drawType isEqualToString:@"RSI"]){
        brTitleLabel.text = @"RSI";
    }else if([drawBottomView.drawType isEqualToString:@"MACD"]){
        brTitleLabel.text = @"MACD";
    }else if([drawBottomView.drawType isEqualToString:@"OBV"]){
        brTitleLabel.text = @"OBV";
    }
    
    [bottomRightView addSubview:brTitleLabel];
    
    crossView = [[UIView alloc] init];
    crossView.backgroundColor = [UIColor clearColor];
    crossView.userInteractionEnabled = NO;
    crossView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:crossView];
    
    horizontalLine = [[UILabel alloc] init];
    horizontalLine.backgroundColor = [UIColor blackColor];
    horizontalLine.hidden = YES;
    [crossView addSubview:horizontalLine];
    
    verticalLine = [[UILabel alloc] init];
    verticalLine.backgroundColor = [UIColor blackColor];
    verticalLine.hidden = YES;
    [crossView addSubview:verticalLine];
    
    infoView = [[TechInfoView alloc] init];
    infoView.frame = CGRectMake(0, 0, 90, 50);
    infoView.hidden = YES;
    infoView.layer.borderWidth = 1.0f;
    
    UITapGestureRecognizer *tapGestureCloseInfoView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenHandler)];
    [infoView addGestureRecognizer:tapGestureCloseInfoView];
    
    [self.view addSubview:infoView];
    
    [self.view setNeedsUpdateConstraints];
    
}

//如果不必送K線資料，則直拉抓DB
-(void)initData
{
    drawTopView.obj = self;
    //將K線資料的陣列給TopView畫出K線圖
    drawTopView.dataArray = drawArray;
    monthView.dataArray = drawArray;
    
    //將K線資料的陣列給Model
    dataModel.tech.dataArray = drawArray;
    //Model取得K線資料後，算出移動平均線的數值
    [dataModel.tech getMArray];
    //Model取得K線資料後，把技術指標的type代入，以便他算出各種技術指標的數值，例如:若要算KD，則Type代入KD
//    [dataModel.tech getVArrayType:[_symbolDict objectForKey:@"Type"]];
    [dataModel.tech performSelector:@selector(getVArrayType:) onThread:dataModel.thread withObject:[_symbolDict objectForKey:@"Type"] waitUntilDone:YES];
    
    //畫圖每筆資料的間距，在Controller的ViewDidLoad已設定為5
    
    drawTopView.widthRange = widthRange;
    //startDate與EndDate為趨勢線的起始點與終點，symbolType為YES:牛證  NO:熊證
    drawTopView.startDate = [(NSNumber *)[_symbolDict objectForKey:@"StartDate"]intValue]+20480;
    drawTopView.endDate = [(NSNumber *)[_symbolDict objectForKey:@"EndDate"]intValue]+20480;
    drawTopView.symbolType = [[_symbolDict objectForKey:@"SymbolType"]boolValue];
    
    monthView.widthRange = widthRange;
    monthView.dataArray = drawArray;
    monthView.startDate = [(NSNumber *)[_symbolDict objectForKey:@"StartDate"]intValue]+20480;
    monthView.endDate = [(NSNumber *)[_symbolDict objectForKey:@"EndDate"]intValue]+20480;
    
    //同上方註解
    drawBottomView.obj = self;
    drawBottomView.dataArray = drawArray;
    drawBottomView.widthRange = widthRange;
    drawBottomView.startDate = [(NSNumber *)[_symbolDict objectForKey:@"StartDate"]intValue]+20480;
    drawBottomView.endDate = [(NSNumber *)[_symbolDict objectForKey:@"EndDate"]intValue]+20480;
//    [FSHUD hideHUDFor:self.view];
}

#pragma mark 電文CallBack
-(void)notifyTechData:(NSMutableArray *)dataArray
{
    //將從server 取得的資料立刻存回資料庫去
    [dataModel.tech saveKData:dataArray Dict:self.symbolDict];
    
    drawArray = [dataModel.tech getKData:[_symbolDict objectForKey:@"IdentCodeSymbol"]];
    dataModel.tech.dataArray = drawArray;
    [dataModel.tech getMArray];
    [dataModel.tech getVArrayType:[_symbolDict objectForKey:@"Type"]];
    drawTopView.obj = self;
    drawTopView.dataArray = drawArray;
    drawTopView.widthRange = widthRange;
    drawTopView.startDate = [(NSNumber *)[_symbolDict objectForKey:@"StartDate"]intValue]+20480;
    drawTopView.endDate = [(NSNumber *)[_symbolDict objectForKey:@"EndDate"]intValue]+20480;
    drawTopView.symbolType = [[_symbolDict objectForKey:@"SymbolType"]boolValue];
    
    monthView.widthRange = widthRange;
    monthView.startDate = [(NSNumber *)[_symbolDict objectForKey:@"StartDate"]intValue]+20480;
    monthView.endDate = [(NSNumber *)[_symbolDict objectForKey:@"EndDate"]intValue]+20480;
    monthView.dataArray = drawArray;
    
    drawBottomView.obj = self;
    drawBottomView.dataArray = drawArray;
    drawBottomView.widthRange = widthRange;
    drawBottomView.startDate = [(NSNumber *)[_symbolDict objectForKey:@"StartDate"]intValue]+20480;
    drawBottomView.endDate = [(NSNumber *)[_symbolDict objectForKey:@"EndDate"]intValue]+20480;
//    [self setDrawView];
    [self performSelectorOnMainThread:@selector(setDrawView) withObject:nil waitUntilDone:YES];
//    [FSHUD hideHUDFor:self.view];
}

#pragma mark 設定Frame, ContentSize等
-(void)setDrawView
{
    //因為widthRange為5，表示資料間距為5，所以這邊判斷資料的筆數 * 5 有沒有大於ScrollView的寬
    if([drawTopView.dataArray count] * widthRange > topScrollView.frame.size.width){
        //把上方的K線圖的寬設定為資料筆數 * 5 + 5  (+5的目的是為了讓使用者能更好移動到最後一筆K線)
        //bug#10085 wiser start
        [monthView setFrame:CGRectMake(0, topScrollView.frame.size.height - 14, [drawTopView.dataArray count] * widthRange + widthRange, 14)];
        [drawTopView setFrame:CGRectMake(0, 0, [drawTopView.dataArray count] * widthRange + widthRange, topScrollView.frame.size.height - 14)];
        //bug#10085 wiser end
        //把上方的ScrollView的ContentSize設定為資料筆數 * 5 + 5
        
        
        [topScrollView setContentSize:CGSizeMake([drawTopView.dataArray count] * widthRange + widthRange, topScrollView.contentSize.height)];
        //接著把ScrollView的ContentOffset設定到最右邊，原因為使用者一開畫面時，就要出現到最後一筆K線的畫面上
        [topScrollView setContentOffset:CGPointMake([drawTopView.dataArray count] * widthRange - topScrollView.frame.size.width + widthRange, 0)];
        
        //同上註解
        [drawBottomView setFrame:CGRectMake(0, 0, [drawBottomView.dataArray count] * widthRange + widthRange, bottomScrollView.frame.size.height)];
        [bottomScrollView setContentSize:CGSizeMake([drawBottomView.dataArray count] * widthRange + widthRange, bottomScrollView.contentSize.height)];
        [bottomScrollView setContentOffset:CGPointMake([drawBottomView.dataArray count] * widthRange - bottomScrollView.frame.size.width + widthRange, 0)];
        
        //把整個ScrollView的寬帶給圖
        drawTopView.viewWidth = topScrollView.frame.size.width;
        monthView.viewWidth = topScrollView.frame.size.width;
        drawBottomView.viewWidth = bottomScrollView.frame.size.width;
    }else{
        //如果資料筆數 * 5 沒有大於ScrollView的寬，則View的寬都設定為自己
        [topScrollView setContentSize:CGSizeMake(topScrollView.frame.size.width, topScrollView.frame.size.height)];
        [topScrollView setContentOffset:CGPointMake(0, 0)];
        [bottomScrollView setContentSize:CGSizeMake(bottomScrollView.frame.size.width, bottomScrollView.contentSize.height)];
        [bottomScrollView setContentOffset:CGPointMake(0, 0)];
        //bug#10085 wiser start
        [drawTopView setFrame:CGRectMake(0, 0, topScrollView.frame.size.width, topScrollView.frame.size.height - 14)];
        [monthView setFrame:CGRectMake(0, topScrollView.frame.size.height - 14, topScrollView.frame.size.width, 14)];
        //bug#10085 wiser end
        [drawBottomView setFrame:CGRectMake(0, 0, bottomScrollView.frame.size.width, bottomScrollView.frame.size.height)];
        drawTopView.viewWidth = [drawArray count] * widthRange;
        monthView.viewWidth = [drawArray count] * widthRange;
        drawBottomView.viewWidth = [drawArray count] * widthRange;
    }
    //把contentOffset.x給畫圖的View以便畫圖計算用
    monthView.xPoint = topScrollView.contentOffset.x;
    drawTopView.xPoint = topScrollView.contentOffset.x;
    drawBottomView.xPoint = bottomScrollView.contentOffset.x;

    //重畫
    [monthView setNeedsDisplay];
    [drawTopView setNeedsDisplay];
    [drawBottomView setNeedsDisplay];
}

-(void)reDraw
{
    [FSHUD hideHUDFor:self.view];
}


#pragma mark設定Label
-(void)setPriceLabel
{
    //為了算出移動平均線價格區間，要算出畫面中的最高價與最低價
    double highPrice = -MAXFLOAT;
    double lowPrice = MAXFLOAT;
    //算出畫面中的第一筆資料
    int startCount = topScrollView.contentOffset.x / widthRange;
    //算出畫面中的最後一筆資料
    int endCount = topScrollView.frame.size.width / widthRange + startCount;
    //如果算出來最後一筆資料大於陣列的數，則等於陣列的最後一筆，以防止crush
    if(endCount >= [drawArray count]){
        endCount = (int)[drawArray count] - 1;
    }
    
    //跑迴圈算出畫面中的最高價與最低價 (除了K線本身的最高價與最低價以外，移動平均線的價格也要一起算)
    for(int i = startCount; i <=endCount; i ++){
        TechObject *obj = [drawArray objectAtIndex:i];
        double m1Value = [(NSNumber *)[dataModel.tech.m1Array objectAtIndex:i]doubleValue];
        double m2Value = [(NSNumber *)[dataModel.tech.m2Array objectAtIndex:i]doubleValue];
        double m3Value = [(NSNumber *)[dataModel.tech.m3Array objectAtIndex:i]doubleValue];
        if(isnan(m1Value) || isnan(m2Value) || isnan(m3Value)){
            highPrice = MAX(highPrice, obj.high);
            lowPrice = MIN(lowPrice, obj.low);
        }else{
            //只有MACD 三個label 都有，也只有MACD 會進來這
            highPrice = MAX(highPrice, obj.high);
            highPrice = MAX(highPrice, m1Value);
            highPrice = MAX(highPrice, m2Value);
            highPrice = MAX(highPrice, m3Value);
            lowPrice = MIN(lowPrice, obj.low);
            lowPrice = MIN(lowPrice, m1Value);
            lowPrice = MIN(lowPrice, m2Value);
            lowPrice = MIN(lowPrice, m3Value);
        }
        
    }
    
    //右邊價格有七個，除6取各個區間
    double priceRange = (highPrice - lowPrice) / 6;
    
    //價格由高至低
    priceLabel1.text = [NSString stringWithFormat:@"%.2f", highPrice];
    priceLabel2.text = [NSString stringWithFormat:@"%.2f", lowPrice + (priceRange * 5)];
    priceLabel3.text = [NSString stringWithFormat:@"%.2f", lowPrice + (priceRange * 4)];
    priceLabel4.text = [NSString stringWithFormat:@"%.2f", lowPrice + (priceRange * 3)];
    priceLabel5.text = [NSString stringWithFormat:@"%.2f", lowPrice + (priceRange * 2)];
    priceLabel6.text = [NSString stringWithFormat:@"%.2f", lowPrice + (priceRange * 1)];
    priceLabel7.text = [NSString stringWithFormat:@"%.2f", lowPrice];
}

//設定移動平均線的Label，這邊代入count為十字線點到哪筆資料代入的資料筆數
//如果滑動ScrollView則代入畫面中最後一筆資料的筆數
//移動平均線是drawTopView 後面三條不同顏色的線（上方M05 10 20為其顏色）
-(void)setMLabel:(int)count
{
    if(count >= [drawArray count]){
        count = (int)[drawArray count] - 1;
    }
    UIColor *m1Color;
    UIColor *m2Color;
    UIColor *m3Color;
    NSString *m1Text;
    NSString *m2Text;
    NSString *m3Text;
    //如果為第一筆資料顯示藍色
    if(count < mNum1-1){
        m1Color = [UIColor blueColor];
    }else{
        //判斷這筆資料是大於、小於還是等於前一筆資料，給他什麼顏色
        if([(NSNumber *)[dataModel.tech.m1Array objectAtIndex:count]doubleValue] > [(NSNumber *)[dataModel.tech.m1Array objectAtIndex:count-1]doubleValue]){
            m1Color = upColor;
            m1Text = [NSString stringWithFormat:@"%.2f↑",[(NSNumber *)[dataModel.tech.m1Array objectAtIndex:count]doubleValue]];
        }else if([[dataModel.tech.m1Array objectAtIndex:count]doubleValue] < [[dataModel.tech.m1Array objectAtIndex:count-1]doubleValue]){
            m1Color = downColor;
            m1Text = [NSString stringWithFormat:@"%.2f↓",[(NSNumber *)[dataModel.tech.m1Array objectAtIndex:count]doubleValue]];
        }else{
            m1Color = [UIColor blueColor];
            m1Text = [NSString stringWithFormat:@"%.2f",[(NSNumber *)[dataModel.tech.m1Array objectAtIndex:count]doubleValue]];
        }
    }
    if(count < mNum2-1){
        m2Color = [UIColor blueColor];
    }else{
        if([(NSNumber *)[dataModel.tech.m2Array objectAtIndex:count]doubleValue] > [(NSNumber *)[dataModel.tech.m2Array objectAtIndex:count-1]doubleValue]){
            m2Color = upColor;
            m2Text = [NSString stringWithFormat:@"%.2f↑",[(NSNumber *)[dataModel.tech.m2Array objectAtIndex:count]doubleValue]];
        }else if([[dataModel.tech.m2Array objectAtIndex:count]doubleValue] < [[dataModel.tech.m2Array objectAtIndex:count-1]doubleValue]){
            m2Color = downColor;
            m2Text = [NSString stringWithFormat:@"%.2f↓",[(NSNumber *)[dataModel.tech.m2Array objectAtIndex:count]doubleValue]];
        }else{
            m2Color = [UIColor blueColor];
            m2Text = [NSString stringWithFormat:@"%.2f",[(NSNumber *)[dataModel.tech.m2Array objectAtIndex:count]doubleValue]];
        }
    }
    if(count < mNum3-1){
        m3Color = [UIColor blueColor];
    }else{
        if([[dataModel.tech.m3Array objectAtIndex:count]doubleValue] > [(NSNumber *)[dataModel.tech.m3Array objectAtIndex:count-1]doubleValue]){
            m3Color = upColor;
            m3Text = [NSString stringWithFormat:@"%.2f↑",[(NSNumber *)[dataModel.tech.m3Array objectAtIndex:count]doubleValue]];
        }else if([[dataModel.tech.m3Array objectAtIndex:count]doubleValue] < [[dataModel.tech.m3Array objectAtIndex:count-1]doubleValue]){
            m3Color = downColor;
            m3Text = [NSString stringWithFormat:@"%.2f↓",[(NSNumber *)[dataModel.tech.m3Array objectAtIndex:count]doubleValue]];
        }else{
            m3Color = [UIColor blueColor];
            m3Text = [NSString stringWithFormat:@"%.2f",[(NSNumber *)[dataModel.tech.m3Array objectAtIndex:count]doubleValue]];
        }
    }
    
    //為了使同個Label顯示兩種不同顏色
    NSMutableAttributedString *m1String = [[NSMutableAttributedString alloc] initWithString:@"M05:" attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}];
    NSMutableAttributedString *m2String = [[NSMutableAttributedString alloc] initWithString:@"M10:" attributes:@{NSForegroundColorAttributeName:[UIColor brownColor]}];
    NSMutableAttributedString *m3String = [[NSMutableAttributedString alloc] initWithString:@"M20:" attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    
    //如果小於移動平均線參數的資料數是沒值的，所以只顯示前面的title
    if (count >= mNum1 - 1) {
        [m1String appendAttributedString:[[NSAttributedString alloc] initWithString:m1Text attributes:@{NSForegroundColorAttributeName:m1Color}]];
    }
    
    if (count >= mNum2 - 1) {
        [m2String appendAttributedString:[[NSAttributedString alloc] initWithString:m2Text attributes:@{NSForegroundColorAttributeName:m2Color}]];
    }
    
    if (count >= mNum3 - 1) {
        [m3String appendAttributedString:[[NSAttributedString alloc] initWithString:m3Text attributes:@{NSForegroundColorAttributeName:m3Color}]];
    }

    mLabel1.attributedText = m1String;
    mLabel2.attributedText = m2String;
    mLabel3.attributedText = m3String;
}

//下方技術指標的Label
-(void)setBLabel:(int)count
{
    if(count >= [drawArray count]){
        count = (int)[drawArray count] - 1;
    }
    UIColor *b1Color;
    UIColor *b2Color;
    UIColor *b3Color;
    NSString *b1Text;
    NSString *b2Text;
    NSString *b3Text;
    int value1;
    int value2;
    int value3;
    //在這邊下方技術指標有1到3個label不等，看技術指標的型態，如果沒有的設為0
    //value這裡表示，假如drawType型態是KD,如果value1 = 9, value2 = 9, 表示9K與9D
    if([drawBottomView.drawType isEqualToString:@"Vol"]){
        value1 = dataModel.tech.valueNum1;
        value2 = dataModel.tech.valueNum2;
        value3 = 0;
    }else if([drawBottomView.drawType isEqualToString:@"KD"]){
        value1 = dataModel.tech.kNum;
        value2 = dataModel.tech.dNum;
        value3 = 0;
    }else if([drawBottomView.drawType isEqualToString:@"RSI"]){
        value1 = dataModel.tech.rsiNum1;
        value2 = dataModel.tech.rsiNum2;
        value3 = 0;
    }else if([drawBottomView.drawType isEqualToString:@"MACD"]){
        value1 = dataModel.tech.emaNum1;
        value2 = dataModel.tech.emaNum2;
        value3 = dataModel.tech.macdNum;
    }else {
        value1 = dataModel.tech.obvNum;
        value2 = 0;
        value3 = 0;
    }
    
    if(count < value1-1){
        b1Color = [UIColor blueColor];
    }else{
        if(!isnan([(NSNumber *)[dataModel.tech.v1Array objectAtIndex:count]doubleValue])){
            if(count == 0){
                b1Color = [UIColor blueColor];
                b1Text = [NSString stringWithFormat:@"%@",[self getShowText:[(NSNumber *)[dataModel.tech.v1Array objectAtIndex:count]doubleValue]]];
            }else if([[dataModel.tech.v1Array objectAtIndex:count]doubleValue] > [(NSNumber *)[dataModel.tech.v1Array objectAtIndex:count-1]doubleValue]){
                //資料漲的話走這邊
                b1Color = upColor;
                b1Text = [NSString stringWithFormat:@"%@↑",[self getShowText:[(NSNumber *)[dataModel.tech.v1Array objectAtIndex:count]doubleValue]]];
            }else if([[dataModel.tech.v1Array objectAtIndex:count]doubleValue] < [(NSNumber *)[dataModel.tech.v1Array objectAtIndex:count-1]doubleValue]){
                //資料跌的話走這邊
                b1Color = downColor;
                b1Text = [NSString stringWithFormat:@"%@↓",[self getShowText:[(NSNumber *)[dataModel.tech.v1Array objectAtIndex:count]doubleValue]]];
            }else{
                b1Color = [UIColor blueColor];
                b1Text = [NSString stringWithFormat:@"%@",[self getShowText:[(NSNumber *)[dataModel.tech.v1Array objectAtIndex:count]doubleValue]]];
            }
        }else{
            b1Text = @"";
            b1Color = [UIColor blueColor];
        }
    }
    if(count < value2-1){
        b2Color = [UIColor blueColor];
    }else{
        if([dataModel.tech.v2Array count] !=0){
            if(!isnan([(NSNumber *)[dataModel.tech.v2Array objectAtIndex:count]doubleValue])) {
                if(count == 0){
                    b2Color = [UIColor blueColor];
                    b2Text = [NSString stringWithFormat:@"%@",[self getShowText:[(NSNumber *)[dataModel.tech.v2Array objectAtIndex:count]doubleValue]]];
                }else if([[dataModel.tech.v2Array objectAtIndex:count]doubleValue] > [(NSNumber *)[dataModel.tech.v2Array objectAtIndex:count-1]doubleValue]){
                    b2Color = upColor;
                    b2Text = [NSString stringWithFormat:@"%@↑",[self getShowText:[(NSNumber *)[dataModel.tech.v2Array objectAtIndex:count]doubleValue]]];
                }else if([[dataModel.tech.v2Array objectAtIndex:count]doubleValue] < [(NSNumber *)[dataModel.tech.v2Array objectAtIndex:count-1]doubleValue]){
                    b2Color = downColor;
                    b2Text = [NSString stringWithFormat:@"%@↓",[self getShowText:[(NSNumber *)[dataModel.tech.v2Array objectAtIndex:count]doubleValue]]];
                }else{
                    b2Color = [UIColor blueColor];
                    b2Text = [NSString stringWithFormat:@"%@",[self getShowText:[(NSNumber *)[dataModel.tech.v2Array objectAtIndex:count]doubleValue]]];
                }
            }else{
                b2Color = [UIColor blueColor];
                b2Text = @"";
            }
        }
    }

    
    if(count < value3-1){
        b3Color = [UIColor brownColor];
    }else{
        if([dataModel.tech.v3Array count] !=0){
            if(!isnan([(NSNumber *)[dataModel.tech.v3Array objectAtIndex:count]doubleValue])){
                if(count == 0){
                    b3Color = [UIColor brownColor];
                    b3Text = [NSString stringWithFormat:@"%@",[self getShowText:[(NSNumber *)[dataModel.tech.v3Array objectAtIndex:count]doubleValue]]];
                }else if([[dataModel.tech.v3Array objectAtIndex:count]doubleValue] > [(NSNumber *)[dataModel.tech.v3Array objectAtIndex:count-1]doubleValue]){
                    b3Color = [UIColor brownColor];
                    b3Text = [NSString stringWithFormat:@"%@↑",[self getShowText:[(NSNumber *)[dataModel.tech.v3Array objectAtIndex:count]doubleValue]]];
                }else if([[dataModel.tech.v3Array objectAtIndex:count]doubleValue] < [(NSNumber *)[dataModel.tech.v3Array objectAtIndex:count-1]doubleValue]){
                    b3Color = [UIColor grayColor];
                    b3Text = [NSString stringWithFormat:@"%@↓",[self getShowText:[(NSNumber *)[dataModel.tech.v3Array objectAtIndex:count]doubleValue]]];
                }else{
                    b3Color = [UIColor brownColor];
                    b3Text = [NSString stringWithFormat:@"%@",[self getShowText:[(NSNumber *)[dataModel.tech.v3Array objectAtIndex:count]doubleValue]]];
                }
            }else{
                b3Color = [UIColor blueColor];
                b3Text = @"";
            }
        }
    }
    
    //為了使同個Label顯示兩種不同顏色
    NSMutableAttributedString *b1String = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *b2String = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *b3String = [[NSMutableAttributedString alloc] init];

    if (count > value1-1) {
        if (value1 == 0) return;
        [b1String appendAttributedString:[[NSAttributedString alloc] initWithString:[self getTitleText:1] attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}]];
        [b1String appendAttributedString:[[NSAttributedString alloc] initWithString:b1Text attributes:@{NSForegroundColorAttributeName:b1Color}]];
    } else {
        [b1String appendAttributedString:[[NSAttributedString alloc] initWithString:[self getTitleText:1] attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}]];
    }

    if (count > value2-1) {
        if ([dataModel.tech.v2Array count] != 0){
            [b2String appendAttributedString:[[NSAttributedString alloc] initWithString:[self getTitleText:2] attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}]];
            [b2String appendAttributedString:[[NSAttributedString alloc] initWithString:b2Text attributes:@{NSForegroundColorAttributeName:b2Color}]];
        }
        if ([dataModel.tech.v3Array count] !=0) {
            [b3String appendAttributedString:[[NSAttributedString alloc] initWithString:[self getTitleText:3] attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}]];
            [b3String appendAttributedString:[[NSAttributedString alloc] initWithString:b3Text attributes:@{NSForegroundColorAttributeName:b3Color}]];
        }
        
    } else {
        
        [b2String appendAttributedString:[[NSAttributedString alloc] initWithString:[self getTitleText:2] attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}]];
        
        [b3String appendAttributedString:[[NSAttributedString alloc] initWithString:[self getTitleText:3] attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}]];
        
        if (b3Text != nil) {
            [b3String appendAttributedString:[[NSAttributedString alloc] initWithString:b3Text attributes:@{NSForegroundColorAttributeName:b3Color}]];
        }
    }
    
    bLabel1.attributedText = b1String;

    if ([dataModel.tech.v2Array count] != 0) {
        bLabel2.attributedText = b2String;
    }
    
    if ([dataModel.tech.v3Array count] != 0) {
        bLabel3.attributedText = b3String;
    }
    
}

//設定下方技術線圖右方的Label
-(void)setBRLabel
{
    //設定最大值與最小值
    double highValue = -MAXFLOAT;
    double lowValue = MAXFLOAT;
    double limiteValue;
    int startCount = bottomScrollView.contentOffset.x / widthRange;
    int endCount = bottomScrollView.frame.size.width / widthRange + startCount;
    if(endCount >= [drawArray count]){
        endCount = (int)[drawArray count] - 1;
    }else{
        endCount = bottomScrollView.frame.size.width / widthRange + startCount;
    }
    //算出量的最大最小值
    if([drawBottomView.drawType isEqualToString:@"Vol"]){
        for(int i = startCount; i <=endCount; i ++){
            TechObject *obj = [drawArray objectAtIndex:i];
            double v1Value = [(NSNumber *)[dataModel.tech.v1Array objectAtIndex:i]doubleValue];
            double v2Value = [(NSNumber *)[dataModel.tech.v2Array objectAtIndex:i]doubleValue];
            if(isnan(v1Value) || isnan(v2Value)){
                highValue = MAX(highValue, obj.volume);
                lowValue = MIN(lowValue, obj.volume);
            }else{
                highValue = MAX(highValue, obj.volume);
                highValue = MAX(highValue, v1Value);
                highValue = MAX(highValue, v2Value);
                lowValue = MIN(lowValue, obj.volume);
                lowValue = MIN(lowValue, v1Value);
                lowValue = MIN(lowValue, v2Value);
            }
        }
    //KD與RSI最大值是100，最小值是0
    }else if([drawBottomView.drawType isEqualToString:@"KD"] || [drawBottomView.drawType isEqualToString:@"RSI"]){
        highValue = 100;
        lowValue = 0;
    //算出MACD最大值，取出絕對值的最大值之後，負的為最小值
    }else if([drawBottomView.drawType isEqualToString:@"MACD"]){
        for(int i = startCount; i <=endCount; i ++){
            double v1Value = [(NSNumber *)[dataModel.tech.v1Array objectAtIndex:i]doubleValue];
            double v2Value = [(NSNumber *)[dataModel.tech.v2Array objectAtIndex:i]doubleValue];
            if(!(isnan(v1Value) || isnan(v2Value))){
                highValue = MAX(highValue, v1Value);
                highValue = MAX(highValue, v2Value);
                lowValue = MIN(lowValue, v1Value);
                lowValue = MIN((lowValue), v2Value);
            }
        }
        if(highValue > fabs(lowValue)){
            limiteValue = highValue;
        }else{
            limiteValue = fabs(lowValue);
        }
    //算出OBV的最大值與最小值
    }else if([drawBottomView.drawType isEqualToString:@"OBV"]){
        if(endCount < dataModel.tech.obvNum + 1){
            endCount = dataModel.tech.obvNum + 1;
        }
        for(int i = startCount; i <=endCount; i ++){
            double v1Value = [(NSNumber *)[dataModel.tech.v1Array objectAtIndex:i]doubleValue];
            if(!isnan(v1Value)){
                highValue = MAX(highValue, v1Value);
                lowValue = MIN(lowValue, v1Value);
            }
        }
        if(highValue > fabs(lowValue)){
            limiteValue = highValue;
        }else{
            limiteValue = fabs(lowValue);
        }
    }
    double volumeRange;
    if([drawBottomView.drawType isEqualToString:@"MACD"] || [drawBottomView.drawType isEqualToString:@"OBV"]){
        volumeRange = limiteValue / 2;
        if([drawBottomView.drawType isEqualToString:@"MACD"]){
            brLabel1.text = [NSString stringWithFormat:@"+%@", [self getShowRightText:volumeRange]];
            brLabel2.text = @"0.0";
        }else if([drawBottomView.drawType isEqualToString:@"OBV"]){
            brLabel1.text = [NSString stringWithFormat:@"%@", [self getShowRightText:volumeRange]];
            brLabel2.text = @"0";
        }
        brLabel3.text = [NSString stringWithFormat:@"-%@", [self getShowRightText:volumeRange]];
    }else{
        volumeRange = highValue / 4;
        brLabel1.text = [NSString stringWithFormat:@"%@", [self getShowRightText:volumeRange * 3]];
        brLabel2.text = [NSString stringWithFormat:@"%@", [self getShowRightText:volumeRange * 2]];
        brLabel3.text = [NSString stringWithFormat:@"%@", [self getShowRightText:volumeRange * 1]];
    }
}
//設定K線圖右邊Label的Frame
-(void)setPriceLabelFrame
{
    //bug#10085 wiser start
    double alignCenter=(priceLabel1.frame.size.height)/2;
    double dashHeight = (topRightView.frame.size.height -24-topAndBottomHeight) / 6;//24是三角形＋monthview.height
    [priceLabel1 setFrame:CGRectMake(5,topAndBottomHeight                               , 80, topAndBottomHeight)];
    [priceLabel2 setFrame:CGRectMake(5,topAndBottomHeight + (1 * dashHeight)-alignCenter, 80, topAndBottomHeight)];
    [priceLabel3 setFrame:CGRectMake(5,topAndBottomHeight + (2 * dashHeight)-alignCenter, 80, topAndBottomHeight)];
    [priceLabel4 setFrame:CGRectMake(5,topAndBottomHeight + (3 * dashHeight)-alignCenter, 80, topAndBottomHeight)];
    [priceLabel5 setFrame:CGRectMake(5,topAndBottomHeight + (4 * dashHeight)-alignCenter, 80, topAndBottomHeight)];
    [priceLabel6 setFrame:CGRectMake(5,topAndBottomHeight + (5 * dashHeight)-alignCenter, 80, topAndBottomHeight)];
    [priceLabel7 setFrame:CGRectMake(5,topAndBottomHeight + (6 * dashHeight)-alignCenter, 80, topAndBottomHeight)];
    //bug#10085 wiser end
}

//設定K線圖上方Label的Frame
-(void)setMLabelFrame
{
    [mLabel1 setFrame:CGRectMake(topScrollView.contentOffset.x+3, 0, topScrollView.frame.size.width/3, topAndBottomHeight)];
    [mLabel2 setFrame:CGRectMake(topScrollView.contentOffset.x+3 + topScrollView.frame.size.width/3, 0, topScrollView.frame.size.width/3, topAndBottomHeight)];
    [mLabel3 setFrame:CGRectMake(topScrollView.contentOffset.x+3 + topScrollView.frame.size.width/3*2, 0, topScrollView.frame.size.width/3, topAndBottomHeight)];
}

//設定技術指標圖上方Label的Frame
-(void)setBLabelFrame
{
    if([drawBottomView.drawType isEqualToString:@"MACD"]){
        [bLabel1 setFrame:CGRectMake(bottomScrollView.contentOffset.x+3, 0, bottomScrollView.frame.size.width/2, bottomTopHeight)];
        [bLabel2 setFrame:CGRectMake(bottomScrollView.contentOffset.x+3 + bottomScrollView.frame.size.width/3, 0, bottomScrollView.frame.size.width/3, bottomTopHeight)];
        [bLabel3 setFrame:CGRectMake(bottomScrollView.contentOffset.x+3 + bottomScrollView.frame.size.width/3 * 2, 0, bottomScrollView.frame.size.width/3, bottomTopHeight)];
    }else if([drawBottomView.drawType isEqualToString:@"OBV"]){
        [bLabel1 setFrame:CGRectMake(bottomScrollView.contentOffset.x+3, 0, bottomScrollView.frame.size.width, bottomTopHeight)];
    }else{
        [bLabel1 setFrame:CGRectMake(bottomScrollView.contentOffset.x+3, 0, bottomScrollView.frame.size.width/2, bottomTopHeight)];
        [bLabel2 setFrame:CGRectMake(bottomScrollView.contentOffset.x+3 + bottomScrollView.frame.size.width/2, 0, bottomScrollView.frame.size.width/2, bottomTopHeight)];
    }
}

//設定技術指標圖右邊Label的Frame
- (void)setBRLabelFrame {
    double dashHeight = (bottomRightView.frame.size.height - bottomTopHeight) / 4;
    if(IS_IPAD){
        [brLabel1 setFrame:CGRectMake(5, dashHeight * 2 - bottomTopHeight, 53, 25)];
        [brLabel2 setFrame:CGRectMake(5, dashHeight * 3 - bottomTopHeight, 53, 25)];
        [brLabel3 setFrame:CGRectMake(5, dashHeight * 4 - bottomTopHeight, 53, 25)];
        
    }else{
        [brLabel1 setFrame:CGRectMake(5, dashHeight * 2 - 30, 53, 25)];
        [brLabel2 setFrame:CGRectMake(5, dashHeight * 3 - 30, 53, 25)];
        [brLabel3 setFrame:CGRectMake(5, dashHeight * 4 - 30, 53, 25)];
    }
}

-(void)layout
{
    [self setDrawView];
    [self setPriceLabelFrame];
    [self setMLabelFrame];
    [self setBRLabelFrame];
    [self setBLabelFrame];
    [self setTitleLabel];
}

//設定右方titleLabel的位置
-(void)setTitleLabel
{
    [trTitleLabel setFrame:CGRectMake(0, 0, topRightView.frame.size.width, topAndBottomHeight)];
    [brTitleLabel setFrame:CGRectMake(0, 0, bottomRightView.frame.size.width, bottomTopHeight)];
}


#pragma mark AutoLayout
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    NSDictionary *metrics = @{@"viewHeight":@(self.view.bounds.size.height/4)};
    
    NSDictionary *dictionary = NSDictionaryOfVariableBindings(drawTopView, drawBottomView, topRightView, bottomRightView, topScrollView, bottomScrollView, crossView);
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topScrollView][bottomScrollView(==viewHeight)]|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:dictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topRightView][bottomRightView(==viewHeight)]|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:dictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topScrollView][topRightView(60)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomScrollView][bottomRightView(60)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[crossView]|" options:0 metrics:nil views:dictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[crossView]|" options:0 metrics:nil views:dictionary]];
    
    [self.view addConstraints:layoutConstraints];
    
    [self performSelector:@selector(layout) withObject:nil afterDelay:0.2];
    
}

#pragma mark ScrollView
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [topScrollView setContentOffset:scrollView.contentOffset];
    [bottomScrollView setContentOffset:scrollView.contentOffset];
    
    monthView.xPoint = topScrollView.contentOffset.x;
    drawTopView.xPoint = topScrollView.contentOffset.x;
    drawBottomView.xPoint = bottomScrollView.contentOffset.x;
    
    
    [drawTopView setNeedsDisplay];
    [drawBottomView setNeedsDisplay];

    [self setMLabelFrame];
    [self setBLabelFrame];
    
    verticalLine.hidden = YES;
    horizontalLine.hidden = YES;
    infoView.hidden = YES;
}

#pragma mark 點擊事件
//將drawTopView長按事件傳
-(void)longPressHandler:(UILongPressGestureRecognizer *)sender
{
    [drawTopView longPressHandler:_touch withEvent:_event];
}
-(void)touchHandler:(int)lineNum touch:(UITouch*)touch yPoint:(double)ypoint selectNum:(int)selectNum
{
    CGPoint touchPoint = [touch locationInView:self.view];
    if(touchPoint.x < topScrollView.frame.size.width){
        verticalLine.hidden = NO;
        horizontalLine.hidden = NO;
        if(drawTopView.startCount == 0 && topScrollView.contentOffset.x < 5)
            lineNum += 1;
        int width = lineNum * widthRange;
        int beforeDataCount = topScrollView.contentOffset.x / widthRange;
        double beforeCost = topScrollView.contentOffset.x - beforeDataCount * widthRange;
        double cost = widthRange - beforeCost;
        [self setMLabel:selectNum];
        [self setBLabel:selectNum];
        [verticalLine setFrame:CGRectMake(width + cost - 1.5 - (_pinchValue/2), topAndBottomHeight, lineWidth, topScrollView.frame.size.height + drawBottomView.frame.size.height)];
        [horizontalLine setFrame:CGRectMake(0, ypoint - 0.5, topScrollView.frame.size.width, lineWidth)];
        
        
        if(lineNum * widthRange >= topScrollView.frame.size.width / 2){
            [infoView setFrame:CGRectMake(5, topScrollView.frame.size.height - 240, 120, 200)];
        }else{
            [infoView setFrame:CGRectMake(topScrollView.frame.size.width - 120 - 5, topScrollView.frame.size.height - 240, 120, 200)];
        }
        [self setInfoViewValue:selectNum];
        infoView.hidden = NO;
    }
}


#pragma mark Other
-(void)setInfoViewValue:(int)selectNum
{
    UIColor *textColor;
    TechObject *obj = [drawArray objectAtIndex:selectNum];
    if(obj.last > obj.open){
        textColor = upColor;
    }else if(obj.last < obj.open){
        textColor = downColor;
    }else{
        textColor = [UIColor blueColor];
    }
    infoView.open.textColor = textColor;
    infoView.high.textColor = textColor;
    infoView.low.textColor = textColor;
    infoView.last.textColor = textColor;
    infoView.change.textColor = textColor;
    infoView.changeRate.textColor = textColor;
    infoView.volume.textColor = textColor;
    
    infoView.open.text = [NSString stringWithFormat:@"%.2f", obj.open];
    infoView.high.text = [NSString stringWithFormat:@"%.2f", obj.high];
    infoView.low.text = [NSString stringWithFormat:@"%.2f", obj.low];
    infoView.last.text = [NSString stringWithFormat:@"%.2f", obj.last];
    infoView.volume.text = [self getKString:obj.volume];
    
    if(selectNum == 0){
        infoView.change.text = @"";
        infoView.changeRate.text = @"";
    }else{
        TechObject *previousObj = [drawArray objectAtIndex:selectNum-1];
        double change = obj.last - previousObj.last;
        double changeRate = change / previousObj.last * 100;
        
        if(change > 0){
            infoView.change.text = [NSString stringWithFormat:@"+%.2f", change];
            infoView.changeRate.text = [NSString stringWithFormat:@"+%.2f%%", changeRate];
        }else{
            infoView.change.text = [NSString stringWithFormat:@"%.2f", change];
            infoView.changeRate.text = [NSString stringWithFormat:@"%.2f%%", changeRate];
        }
    }
    
    infoView.dateLabel.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[[NSNumber numberWithUnsignedInt:obj.date]uint16ToDate]]];
}

-(void)hiddenHandler
{
    infoView.hidden = YES;
    verticalLine.hidden = YES;
    horizontalLine.hidden = YES;
}

-(NSString *)getShowText:(double)value
{
    if([drawBottomView.drawType isEqualToString:@"Vol"]){
        return [NSString stringWithFormat:@"%.0f", value];
    }else if([drawBottomView.drawType isEqualToString:@"KD"] || [drawBottomView.drawType isEqualToString:@"RSI"] || [drawBottomView.drawType isEqualToString:@"MACD"]){
        return [NSString stringWithFormat:@"%.2f", value];
    }else if([drawBottomView.drawType isEqual:@"OBV"]){
        return [NSString stringWithFormat:@"%.0fK", value / 1000];
    }else{
        return [NSString stringWithFormat:@"%.2f", value];
    }
}

-(NSString *)getShowRightText:(double)value
{
    if([drawBottomView.drawType isEqualToString:@"KD"] || [drawBottomView.drawType isEqualToString:@"RSI"]){
        return [NSString stringWithFormat:@"%.0f", value];
    }else if([drawBottomView.drawType isEqualToString:@"MACD"]){
        return [NSString stringWithFormat:@"%.2f", value];
    }else if([drawBottomView.drawType isEqual:@"OBV"] || [drawBottomView.drawType isEqualToString:@"Vol"]){
        return [self getKString:value];
    }else{
        return [NSString stringWithFormat:@"%.2f", value];
    }
}

-(NSString *)getTitleText:(int)num
{
    if([drawBottomView.drawType isEqualToString:@"Vol"]){
        if(num == 1){
            return @"Vol05:";
        }else{
            return @"Vol10:";
        }
    }else if([drawBottomView.drawType isEqualToString:@"KD"]){
        if(num == 1){
            return @"9K:";
        }else{
            return @"9D:";
        }
    }else if([drawBottomView.drawType isEqualToString:@"RSI"]){
        if(num == 1){
            return @"RSI05:";
        }else{
            return @"RSI10:";
        }
    }else if([drawBottomView.drawType isEqual:@"MACD"]){
        if(num == 1){
            return @"9D:";
        }else if(num == 2){
            return @"9M:";
        }else{
            return @"D-M:";
        }
    }else if([drawBottomView.drawType isEqual:@"OBV"]){
        return @"OBV60:";
    }else{
        return @"";
    }
}

-(NSString *)getKString:(int)value
{
    if(value > 1000000){
        value = value / 1000;
        return [NSString stringWithFormat:@"%dK", value];
    }else{
        return [NSString stringWithFormat:@"%d", value];
    }
}

-(void)theTranportation:(BOOL)startOrEnd :(NSSet *)touch
{
    [drawTopView theTranportDestination:startOrEnd :touch];
}

-(void)dealloc
{
    
}

@end
