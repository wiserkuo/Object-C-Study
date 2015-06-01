//
//  FigureCustomDetailViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2015/1/12.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FigureCustomDetailViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "FigureSearchDrawView.h"
#import "FigureCustomEditViewController.h"
#import "FSLineActivity.h"
#import "FSFaceBookActivity.h"
#import <Social/Social.h>
#import "SGInfoAlert.h"

#define IS_IPAD [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound

@interface FigureCustomDetailViewController ()<UIActionSheetDelegate>

@property (nonatomic) BOOL firstIn;
@property (nonatomic) BOOL forActionSheet2;

@property (nonatomic) int kNumber;
@property (nonatomic) int figureSearchID;
@property (strong ,nonatomic) NSMutableArray *searchKeyArray;
@property (strong ,nonatomic) NSDictionary *needObj;
//用來記錄使用者切換到日線、週線還是月線
@property (nonatomic) int storeDWM;

@property (strong ,nonatomic) FigureSearchDrawView *rectView;

//four triangle in _rectView
@property (strong, nonatomic) FigureSearchDrawView *tr1;
@property (strong, nonatomic) FigureSearchDrawView *tr2;
@property (strong, nonatomic) FigureSearchDrawView *tr3;
@property (strong, nonatomic) FigureSearchDrawView *tr4;

@property (nonatomic)double high;
@property (nonatomic)double low;
@property (nonatomic)double open;
@property (nonatomic)double close;

//UIView for kBar
@property (strong ,nonatomic)UIView * kBackGroundView;
@property (strong ,nonatomic)UIView * kView;
@property (strong ,nonatomic)UIView * kLineView;
@property (strong ,nonatomic)UIView * downKLineView;
@property (strong ,nonatomic)UIView * kRectView;

@property(nonatomic)double lineDefaultX;
@property(nonatomic)double rectDefaultX;
@property(nonatomic)double rectDefaultY;
@property(nonatomic)double yOffset;

@property (strong, nonatomic) UIColor * kRectUpColor;
@property (strong, nonatomic) UIColor * kRectDownColor;
@property (strong, nonatomic) UIColor * kUpLineColor;
@property (strong, nonatomic) UIColor * kDownLineColor;
@property (strong, nonatomic) UIColor * kRectBorderUpColor;
@property (strong, nonatomic) UIColor * kRectBorderDownColor;

@property (strong ,nonatomic) FigureSearchMyProfileModel * customModel;

//UIView for hint section
//Buttons with values will have two labels on it
@property (strong, nonatomic) UIView *hintBaseView;
@property (strong, nonatomic) UILabel *upLine;
@property (strong, nonatomic) UILabel *mainBody;
@property (strong, nonatomic) UILabel *downLine;
@property (strong, nonatomic) UILabel *upDown;
@property (strong, nonatomic) FSUIButton *upLineBtn;
@property (strong, nonatomic) FSUIButton *kBarMainBodyBtn;
@property (strong, nonatomic) FSUIButton *kBarColorBtn;
@property (strong, nonatomic) FSUIButton *downLineBtn;
@property (strong, nonatomic) FSUIButton *upDownBtn;
@property (strong, nonatomic) UIView *kBarContainer;

//storeDataArray要存range,color,upLine,kLine,downLine
//前五個是字串，後四個是浮點數，依序
//color 是指kbar 主體的顏色，kLine 則是kbar 的外框線
//storeDataArray 只負責將資料從DB內取出的資料儲存起來
//insertToDBArray 則是將storeDataArray 的資料轉存，並儲存使用者所做的任何修改，最後視需求回存回DB
@property (strong, nonatomic) NSArray *storeDataArray;
@property (strong, nonatomic) NSMutableArray *insertToDBArray;

//for draw the four lines
@property (nonatomic) CGPoint upLinePoint;
@property (nonatomic) CGPoint mainBodyPoint;
@property (nonatomic) CGPoint upDownPoint;
@property (nonatomic) CGPoint downLinePoint;

//用來儲存是否需顯示kbar 外框線的布林值變數
@property (nonatomic) BOOL isShowBorder;

//bottom buttons
@property (strong, nonatomic) FSUIButton *backBtn;
@property (strong, nonatomic) FSUIButton *submitBtn;

//four values from DB
@property (nonatomic) CGFloat highValue;
@property (nonatomic) CGFloat lowValue;
@property (nonatomic) CGFloat openValue;
@property (nonatomic) CGFloat closeValue;

@property (strong, nonatomic) UIActionSheet *actionSheet; //for 上影線跟下影線
@property (strong, nonatomic) UIActionSheet *actionSheet1; //for 顏色
@property (strong, nonatomic) UIActionSheet *actionSheet2; //for 漲跌幅
@property (strong, nonatomic) UIAlertController *alertController; //like actionSheet
@property (strong, nonatomic) UIAlertController *alertController1;//like actionSheet1
@property (strong, nonatomic) UIAlertController *alertController2;//like actionSheet2
@property (strong, nonatomic) FSUIButton *triggerBtn; //to know which btn has been clicked

//store stuff for return to editViewController
@property (nonatomic) int searchNum;
@property (nonatomic) int currentOption;
@property (nonatomic) int initKNum;

@end

#define IS_COLOR YES
#define OUT_OF_COLOR NO
#define IS_IOS8 [[UIDevice currentDevice] systemVersion].floatValue >= 8.0

@implementation FigureCustomDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _firstIn = YES;
    _customModel = [[FigureSearchMyProfileModel alloc] init];
    [self initVar];
    [self initView];
    [self.view setNeedsUpdateConstraints];
    //如果直接執行drawTheLineFromKBarToLabel的話，會因為某部份數值尚未產生而使得線畫不出來，所以才要延後0.2 秒才進行畫線的動作
    [self performSelector:@selector(drawTheLineFromKBarToLabel) withObject:nil afterDelay:0.2];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES];
    [self setKBar];
    _storeDataArray = [_customModel searchKBarDetailWithFigureSearchID:[NSNumber numberWithInt:_figureSearchID] tNumber:[NSNumber numberWithInt:_kNumber]];
    _insertToDBArray = [[NSMutableArray alloc] initWithArray:_storeDataArray];
    [_insertToDBArray setObject:[self changeTheZeroToLast:[_storeDataArray objectAtIndex:FSFigureDBColumnRange] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnRange];
    [_insertToDBArray setObject:[self changeTheZeroToLast:[_storeDataArray objectAtIndex:FSFigureDBColumnColor] isItColor:IS_COLOR] atIndexedSubscript:FSFigureDBColumnColor];
    [_insertToDBArray setObject:[self changeTheZeroToLast:[_storeDataArray objectAtIndex:FSFigureDBColumnUpLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnUpLine];
    [_insertToDBArray setObject:[self changeTheZeroToLast:[_storeDataArray objectAtIndex:FSFigureDBColumnKLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnKLine];
    [_insertToDBArray setObject:[self changeTheZeroToLast:[_storeDataArray objectAtIndex:FSFigureDBColumnDownLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnDownLine];
    _highValue = [(NSNumber *)[_storeDataArray objectAtIndex:5] floatValue];
    _lowValue = [(NSNumber *)[_storeDataArray objectAtIndex:6] floatValue];
    _openValue = [(NSNumber *)[_storeDataArray objectAtIndex:7] floatValue];
    _closeValue = [(NSNumber *)[_storeDataArray objectAtIndex:8] floatValue];
    _isShowBorder = [[_storeDataArray objectAtIndex:FSFigureDBColumnKLine] boolValue];

    //「實體線」及arrow ，的顏色判斷上以開盤價及收盤價為準才是正確的
//    if([[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] isEqualToString:@"0"] || [[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] isEqualToString:@"YES"]){
//        _rectView.isRedColor = YES;
//    }
    if(_openValue <= _closeValue){
        _rectView.isRedColor = YES;
    }else{
        _rectView.isRedColor = NO;
    }

    _mainBody.textColor = _rectView.isRedColor?[StockConstant PriceUpColor]:[StockConstant PriceDownColor];
    [self initColor];
    [self setBtnTitle];
    [self setKBarColorBtnTitle];
    [self setKBarBorderColor];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)initColor
{
    NSMutableArray * conditionArray = [_customModel searchkBarConditionsWithFigureSearchId:[NSNumber numberWithInt:_figureSearchID] tNumber:[NSNumber numberWithInt:_kNumber]];
    if ([conditionArray count]==0){
        _kUpLineColor = [UIColor grayColor];
        _kDownLineColor = [UIColor grayColor];
        _kRectUpColor = [StockConstant PriceUpColor];
        _kRectDownColor = [StockConstant PriceDownColor];
        _kRectBorderUpColor = [StockConstant PriceUpColor];
        _kRectBorderDownColor = [StockConstant PriceDownColor];
    }else{
        if ([[conditionArray objectAtIndex:FSFigureDBColumnColor]boolValue]) {
            _kRectUpColor = [StockConstant PriceUpColor];
            _kRectDownColor = [StockConstant PriceDownColor];
        }else{
            _kRectUpColor = [UIColor grayColor];
            _kRectDownColor = [UIColor grayColor];
        }
        if ([[conditionArray objectAtIndex:FSFigureDBColumnUpLine]boolValue]) {
            _kUpLineColor = [UIColor blueColor];
        }else{
            _kUpLineColor = [UIColor grayColor];
        }
        if ([[conditionArray objectAtIndex:FSFigureDBColumnKLine] isEqualToString:@"YES"] || [(NSNumber *)[conditionArray objectAtIndex:FSFigureDBColumnKLine]intValue] == 1) {
            _kRectBorderUpColor = [StockConstant PriceUpColor];
            _kRectBorderDownColor = [StockConstant PriceDownColor];
        }else if([[conditionArray objectAtIndex:FSFigureDBColumnKLine] isEqualToString:@"YES"] || [(NSNumber *)[conditionArray objectAtIndex:FSFigureDBColumnKLine]intValue] == 2) {
            _kRectBorderUpColor = [StockConstant PriceDownColor];
            _kRectBorderDownColor = [StockConstant PriceUpColor];
        }else{
            _kRectBorderUpColor = [UIColor grayColor];
            _kRectBorderDownColor = [UIColor grayColor];
        }
        if ([[conditionArray objectAtIndex:FSFigureDBColumnDownLine]boolValue]) {
            _kDownLineColor = [UIColor blueColor];
        }else{
            _kDownLineColor = [UIColor grayColor];
        }
    }
}

-(instancetype)initWithNeededObjectFromDictionary:(NSDictionary *)sendObj :(int)currentOption :(int)searchNum :(int)kNumber
{
    self = [super init];
    if(self){
        _needObj = sendObj;
        _currentOption = currentOption;
        _searchNum = searchNum;
        _initKNum = kNumber;
    }
//    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString* cachePath = [cachePathArray lastObject];
//    NSLog(@"%@",cachePath );
    return self;
}

-(void)initView
{
    UIFont *ff = [UIFont systemFontOfSize:17.0];
    
    self.title = [_searchKeyArray objectAtIndex:_kNumber + _storeDWM * 5];
    
    //for kBar
    self.rectView = [[FigureSearchDrawView alloc] init];
    self.rectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rectView.backgroundColor = [UIColor clearColor];
    [self.rectView setMultipleTouchEnabled:YES];
    [self.view addSubview:self.rectView];
    
    //add k棒
    self.kView = [[UIView alloc] init];
    _kView.backgroundColor = [UIColor clearColor];
    [self.rectView addSubview:_kView];
    
    self.kLineView = [[UIView alloc] init];
    [self.kView addSubview:_kLineView];
    
    self.downKLineView = [[UIView alloc]init];
    [self.kView addSubview:_downKLineView];
    
    self.kRectView = [[UIView alloc] init];
    _kRectView.backgroundColor = [UIColor clearColor];
    [self.kView addSubview:_kRectView];
    
    self.kBackGroundView = [[UIView alloc] init];
    _kBackGroundView.userInteractionEnabled = YES;
    _kBackGroundView.backgroundColor = [UIColor orangeColor];
    [self.rectView addSubview:_kBackGroundView];
    
    //two buttons at bottom
    self.backBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenButton];
    [self.backBtn setTitle:NSLocalizedStringFromTable(@"lastMove", @"FigureSearch", nil) forState:UIControlStateNormal];
    self.backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backBtn.titleLabel setFont:ff];
    [self.backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.submitBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenButton];
    [self.submitBtn setTitle:NSLocalizedStringFromTable(@"submit", @"FigureSearch", nil) forState:UIControlStateNormal];
    self.submitBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.submitBtn.titleLabel setFont:ff];
    [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitBtn];
    
    //for hint section
    self.hintBaseView = [[UIView alloc] init];
    self.hintBaseView.translatesAutoresizingMaskIntoConstraints = NO;
    self.hintBaseView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.hintBaseView];
    
    self.upLine = [[UILabel alloc] init];
    self.upLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.upLine.textAlignment = NSTextAlignmentLeft;
    self.upLine.textColor = [UIColor blueColor];
    self.upLine.numberOfLines = 0;
    [self.upLine setText:NSLocalizedStringFromTable(@"upLine", @"FigureSearch", nil)];
    self.upLine.font = ff;
    [self.hintBaseView addSubview:self.upLine];
    
    self.mainBody = [[UILabel alloc] init];
    self.mainBody.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainBody.textAlignment = NSTextAlignmentLeft;
    [self.mainBody setText:NSLocalizedStringFromTable(@"mainBody", @"FigureSearch", nil)];
    self.mainBody.font = ff;
    [self.hintBaseView addSubview:self.mainBody];
    
    self.downLine = [[UILabel alloc] init];
    self.downLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.downLine.textAlignment = NSTextAlignmentLeft;
    self.downLine.textColor = [UIColor blueColor];
    self.downLine.numberOfLines = 0;
    [self.downLine setText:NSLocalizedStringFromTable(@"downLine", @"FigureSearch", nil)];
    self.downLine.font = ff;
    [self.hintBaseView addSubview:self.downLine];
    
    self.upDown = [[UILabel alloc] init];
    self.upDown.translatesAutoresizingMaskIntoConstraints = NO;
    self.upDown.textAlignment = NSTextAlignmentLeft;
    self.upDown.textColor = [UIColor blueColor];
    self.upDown.backgroundColor = [UIColor clearColor];
    self.upDown.numberOfLines = 0;
    [self.upDown setText:NSLocalizedStringFromTable(@"upDown", @"FigureSearch", nil)];
    self.upDown.font = ff;
    [self.hintBaseView addSubview:self.upDown];
    
    self.upLineBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.upLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.upLineBtn.textLabel.font = ff;
    self.upLineBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.upLineBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.hintBaseView addSubview:self.upLineBtn];
    
    self.kBarContainer = [[UIView alloc] init];
    self.kBarContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.kBarContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.kBarContainer];
    
    self.kBarMainBodyBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.kBarMainBodyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.kBarMainBodyBtn.textLabel.font = ff;
    self.kBarMainBodyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.kBarMainBodyBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.kBarContainer addSubview:self.kBarMainBodyBtn];
    
    self.kBarColorBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.kBarColorBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.kBarColorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.kBarColorBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.kBarColorBtn.textLabel.font = ff;
    [self.kBarContainer addSubview:self.kBarColorBtn];
    
    self.downLineBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.downLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.downLineBtn.textLabel.font = ff;
    self.downLineBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.downLineBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.hintBaseView addSubview:self.downLineBtn];
    
    self.upDownBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.upDownBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.upDownBtn.textLabel.font = ff;
    self.upDownBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.upDownBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.hintBaseView addSubview:self.upDownBtn];
    
}

-(void)initVar{
    self.searchKeyArray = [[NSMutableArray alloc] initWithObjects:
                           NSLocalizedStringFromTable(@"當日", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前一日", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前二日", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前三日", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前四日", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"當週", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前一週", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前二週", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前三週", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前四週", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"當月", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前一月", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前二月", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前三月", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"前四月", @"FigureSearch", nil),nil];
    self.kNumber = [(NSNumber *)[self.needObj objectForKey:@"kNumber"] intValue];
    self.figureSearchID = [(NSNumber *)[self.needObj objectForKey:@"figureSearchID"] intValue];
    self.kUpLineColor = [self.needObj objectForKey:@"kLineBackColor"];
    self.kDownLineColor = [self.needObj objectForKey:@"downKLineBackColor"];
    self.lineDefaultX = [(NSNumber *)[self.needObj objectForKey:@"lineDefaultX"] floatValue];
    self.kRectUpColor = [self.needObj objectForKey:@"kRectUpColor"];
    self.kRectDownColor = [self.needObj objectForKey:@"kRectDownColor"];
    self.kRectBorderUpColor = [self.needObj objectForKey:@"kRectBorderUpColor"];
    self.kRectBorderDownColor = [self.needObj objectForKey:@"kRectBorderDownColor"];
    self.open = [(NSNumber *)[self.needObj objectForKey:@"open"] floatValue];
    self.high = [(NSNumber *)[self.needObj objectForKey:@"high"] floatValue];
    self.low = [(NSNumber *)[self.needObj objectForKey:@"low"] floatValue];
    self.close = [(NSNumber *)[self.needObj objectForKey:@"close"] floatValue];
    self.yOffset = [(NSNumber *)[self.needObj objectForKey:@"yOffset"] floatValue];
    self.storeDWM = [(NSNumber *)[self.needObj objectForKey:@"storeDWM"] intValue];
}

-(void)setBtnTitle
{
    [self.upLineBtn setTitle:[self setStringOrNumber:FSFigureDBColumnUpLine :_highValue :_openValue :_closeValue] forState:UIControlStateNormal];
    [self.kBarMainBodyBtn setTitle:[self setStringOrNumber:FSFigureDBColumnKLine :NAN :_openValue :_closeValue] forState:UIControlStateNormal];
    [self.downLineBtn setTitle:[self setStringOrNumber:FSFigureDBColumnDownLine :_lowValue :_openValue :_closeValue] forState:UIControlStateNormal];
    [self.upDownBtn setTitle:[self setStringOrNumber:FSFigureDBColumnRange :_closeValue :NAN :NAN] forState:UIControlStateNormal];
    [self setKBarBorderColor];
}

//按下實體線的顏色按鈕後所觸發的method
//需連動觸發更換外框線的method
-(void)setKBarColorBtnTitle
{
    NSString *str = @"";
    int theIndex = 0;
    if(_firstIn){
        if([[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] isEqualToString:@"2"] ||
           [[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] isEqualToString:@"NO"]){
            _firstIn = NO;
            [self setKBarColorBtnTitle];
            return;
        }
        if(_closeValue >= _openValue){
            theIndex = FSFigureCustomColorTypeRed;
        }else if(_closeValue < _openValue){
            theIndex = FSFigureCustomColorTypeGreen;
        }else {
            theIndex = [(NSNumber *)[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] intValue];
        }
        [_insertToDBArray setObject:[NSString stringWithFormat:@"%d",theIndex] atIndexedSubscript:FSFigureDBColumnColor];
        _firstIn = NO;
    }else{
        //k bar的顏色判斷上以開盤價及收盤價為準才是正確的
        theIndex = [(NSNumber *)[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] intValue];
        if(!theIndex){
            if([[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] isEqualToString:@"NO"]){
                theIndex = 0;
            }else if([[_insertToDBArray objectAtIndex:FSFigureDBColumnColor] isEqualToString:@"YES"]){
                if(_open >= _close){
                    theIndex = 1;
                }else if(_open < _close){
                    theIndex = 2;
                }
            }
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d",theIndex] atIndexedSubscript:FSFigureDBColumnColor];
        }
    }
    switch (theIndex) {
        case FSFigureCustomColorTypeNeverBother:
            str = NSLocalizedStringFromTable(@"任意顏色", @"FigureSearch", nil);
            _kRectView.backgroundColor = [UIColor grayColor];
            break;
        case FSFigureCustomColorTypeGreen:
            str = NSLocalizedStringFromTable(@"跌的顏色", @"FigureSearch", nil);
            _kRectView.backgroundColor = [StockConstant PriceDownColor];
//            [self checkTheOpenAndClose:theIndex];
            break;
        case FSFigureCustomColorTypeRed:
            str = NSLocalizedStringFromTable(@"漲的顏色", @"FigureSearch", nil);
            _kRectView.backgroundColor = [StockConstant PriceUpColor];
//            [self checkTheOpenAndClose:theIndex];
            break;
        default:
            break;
    }
    [self setKBarBorderColor];
    [_kBarColorBtn setTitle:str forState:UIControlStateNormal];
}

//外框線的method 直接以開盤價及收盤價做計算
-(void)setKBarBorderColor
{
    if(!_isShowBorder) return;
    if(_openValue == _closeValue){
        _kRectView.layer.borderColor = [UIColor blueColor].CGColor;
    }else if(_openValue > _closeValue){
        _kRectView.layer.borderColor = [StockConstant PriceDownColor].CGColor;
    }else if(_openValue < _closeValue){
        _kRectView.layer.borderColor = [StockConstant PriceUpColor].CGColor;
    }
}

//第一個參數是指要查詢哪個欄位，後面三個則是運算用，要傳出去的
-(NSString *)setStringOrNumber:(int)intPut :(CGFloat)para1 :(CGFloat)para2 :(CGFloat)para3
{
    NSString *str = @"";
    
    BOOL boolObj = [(NSNumber *)[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:intPut] isItColor:OUT_OF_COLOR]intValue];
    
    NSString *leftPart = [self findTheENUMbyString:intPut];
    NSString *rightPart;
    if(!isnan(para2) && !isnan(para3)){
        rightPart = [self setTheRValue:para1 :para2 :para3];
    }else{
        rightPart = [NSString stringWithFormat:@"%1.2f%%",para1 * 100];
    }
    
    if(boolObj){
        str = [NSString stringWithFormat:@"%@ %@",leftPart,rightPart];
    }else{
        str = leftPart;
    }
    
    return str;
}

//一次處理有數值的四個label，但是計算公式的關係，所以看起來不太友善
/*
 上影線：在漲時，high - close
        在跌時，high - open
 
 實體線、漲跌幅：open - close 取絕對值
 
 下影線：在漲時，open - low
        在跌時，close - low
*/
-(NSString *)setTheRValue:(CGFloat)para1 :(CGFloat)para2 :(CGFloat)para3
{
    CGFloat tmpFloat = 0.0;
    para1 = para1 * 100;
    para2 = para2 * 100;
    para3 = para3 * 100;
    if(!isnan(para1) && !isnan(para2) && !isnan(para3)){
        if(para1 >= para2 && para1 >= para3){
            if(para2 > para3){
                tmpFloat = para1 - para2;
            }else{
                tmpFloat = para1 - para3;
            }
        }else{
            if(para2 > para3){
                tmpFloat = para3 - para1;
            }else{
                tmpFloat = para2 - para1;
            }
        }
    }else{
        tmpFloat = fabsf(para3 - para2);
    }
    float aaa = 0.0;
    NSArray *percentAry = [_customModel getDWMRange:self.figureSearchID];
    if(_storeDWM == FSFigureDWMForD){
        aaa = 1;
    }else if(_storeDWM == FSFigureDWMForW){
        aaa = [(NSNumber *)[percentAry objectAtIndex:1]floatValue] / [(NSNumber *)[percentAry objectAtIndex:0]floatValue];
    }else if(_storeDWM == FSFigureDWMForM){
        aaa = [(NSNumber *)[percentAry objectAtIndex:2]floatValue] / [(NSNumber *)[percentAry objectAtIndex:0]floatValue];
    }
    float a =0.0;
    a=tmpFloat * aaa;
    if(tmpFloat * aaa- (int)(tmpFloat * aaa) >0){
        return [NSString stringWithFormat:@"%.1f%%",tmpFloat * aaa];
    }
    else{
        return [NSString stringWithFormat:@"%d%%",(int)(tmpFloat * aaa)];
    }
}

//eNumType 是指哪一個資料庫的欄位，在此method裡 取該欄位的值並做判斷
-(NSString *)findTheENUMbyString:(int)eNumType
{
    NSString *str = @"";
    int targetNum;// = eNumType;
    NSString *columnValue = [_insertToDBArray objectAtIndex:eNumType];
    if(![columnValue intValue]){
        if([columnValue isEqualToString:@"YES"]){
            targetNum = 1;
        }else {
            targetNum = 0;
        }
    }else{
        targetNum = [columnValue intValue];
    }

    switch(targetNum){
        case FSFigureCustomSearchTypeNothing :
            str = NSLocalizedStringFromTable(@"任意長度", @"FigureSearch", nil);
            if(eNumType == FSFigureDBColumnRange){
                str = NSLocalizedStringFromTable(@"任意值", @"FigureSearch", nil);
            }
            break;
        case FSFigureCustomSearchTypeEqualTo :
            str = NSLocalizedStringFromTable(@"約等於", @"FigureSearch", nil);
            break;
        case FSFigureCustomSearchTypeBigger :
            str = NSLocalizedStringFromTable(@"大於", @"FigureSearch", nil);
            break;
        case FSFigureCustomSearchTypeSmaller :
            str = NSLocalizedStringFromTable(@"小於", @"FigureSearch", nil);
            break;
        default:
            break;
    }
    return str;
}

-(void)checkTheOpenAndClose:(int)eNumType
{
    switch(eNumType){
        case FSFigureCustomColorTypeRed:
            if(_openValue > _closeValue){
                _openValue = _openValue + _closeValue;
                _closeValue = _openValue - _closeValue;
                _openValue = _openValue - _closeValue;
            }
            break;
        case FSFigureCustomColorTypeGreen:
            if(_openValue < _closeValue){
                _openValue = _openValue + _closeValue;
                _closeValue = _openValue - _closeValue;
                _openValue = _openValue - _closeValue;
            }
            break;
        default:
            break;
        //當刻意的改變實體線本身的顏色時，則必須讓開盤價與收盤價互換以符合該漲跌幅的顏色
        //上一頁的開盤價及收盤價的位置是直接使用db內的值的，所以這裡的交換仍可對上一頁產生效果
    }
    [_insertToDBArray setObject:[NSNumber numberWithDouble:_openValue] atIndexedSubscript:7];
    [_insertToDBArray setObject:[NSNumber numberWithDouble:_closeValue] atIndexedSubscript:8];
}

#pragma mark setKBar
-(void)setKBar{
    
    CGFloat forUpDownBottom = 0.0;
    
    _kBackGroundView.frame = CGRectMake(_rectView.center.x - 25, 0, 50, _rectView.frame.size.height);
    _kLineView.backgroundColor = _kUpLineColor;
    
    _downKLineView.backgroundColor = _kDownLineColor;
    
    _kRectView.frame = CGRectMake(_rectDefaultX, _close-_high, 50, _open-_close);
    _kRectView.layer.borderWidth = 3;
    if (_open>_close) {
        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
        _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
        _upLinePoint = CGPointMake(_lineDefaultX - 18, _high-_high + _yOffset);
        _downLinePoint = CGPointMake(_lineDefaultX - 18, _open-_high + _low-_open + _yOffset);
        forUpDownBottom = _close;
        _kRectView.backgroundColor = _kRectUpColor;
        _kRectView.layer.borderColor = _kRectBorderUpColor.CGColor;
    }else if (_close>_open){
        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
        _downKLineView.frame = CGRectMake(_lineDefaultX, _close-_high, 5, _low-_close);
        _upLinePoint = CGPointMake(_lineDefaultX - 18, _high-_high + _yOffset);
        _downLinePoint = CGPointMake(_lineDefaultX - 18, _close-_high+_low-_close + _yOffset);
        forUpDownBottom = _close;
        _kRectView.backgroundColor = _kRectDownColor;
        _kRectView.layer.borderColor = _kRectBorderDownColor.CGColor;
    }else{
        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
        _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
        _upLinePoint = CGPointMake(_lineDefaultX - 18, _high-_high + _yOffset);
        _downLinePoint = CGPointMake(_lineDefaultX - 18, _open-_high+_low-_open + _yOffset);
        forUpDownBottom = _close;
        _kRectView.backgroundColor = [UIColor blueColor];
        _kRectView.layer.borderColor = [UIColor blueColor].CGColor;
    }
    if (_low-_high==0) {
        _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, 3);
    }else{
        _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, _low-_high);
    }
    if (_open-_close==0) {
        _kRectView.frame = CGRectMake(_rectDefaultX, _close-_high, 50, 3);
        _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, 3);
    }
    
    _mainBodyPoint = CGPointMake(_rectDefaultX + 27, _close-_high + (_open - _close )/2 + _yOffset);
    _upDownPoint = CGPointMake(_rectDefaultX + 27, forUpDownBottom);
    
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    NSNumber *theHeight = [[NSNumber alloc] initWithFloat:self.view.frame.size.width * 2 /3];
    NSNumber *fixedButtonHeight = [[NSNumber alloc] initWithInt:35.0];
    NSNumber *fixedLabelHeight = [[NSNumber alloc] initWithInt:45.0];
    NSNumber *labelsHeight;
    if(IS_IPAD){
        labelsHeight = [[NSNumber alloc] initWithFloat:self.view.frame.size.width / 9];
    }else{
        labelsHeight = [[NSNumber alloc] initWithFloat:self.view.frame.size.width / 6];
    }
    NSDictionary *metrics = @{@"twoThird":theHeight, @"fixedButtonHeight":fixedButtonHeight,@"fixedLabelHeight":fixedLabelHeight, @"labelsHeight":labelsHeight};
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_rectView, _kView, _kBackGroundView, _kLineView, _kRectView, _downKLineView, _backBtn, _submitBtn, _hintBaseView, _upLine, _mainBody, _downLine, _upDown, _upLineBtn, _kBarMainBodyBtn, _kBarColorBtn, _downLineBtn, _upDownBtn, _kBarContainer);
    
    if ([FSUtility isGraterThanSupportVersion:7]) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_rectView]-10-[_backBtn(fixedButtonHeight)]-10-|" options:0 metrics:metrics views:allObj]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_hintBaseView]-10-[_submitBtn(fixedButtonHeight)]-10-|" options:0 metrics:metrics views:allObj]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_rectView]-5-[_backBtn(fixedButtonHeight)]-5-|" options:0 metrics:metrics views:allObj]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_hintBaseView]-5-[_submitBtn(fixedButtonHeight)]-5-|" options:0 metrics:metrics views:allObj]];
    }
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-35-[_titleLabel][_shareBtn(35)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
//    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_shareBtn(35)]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[_rectView][_hintBaseView(twoThird)]|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_hintBaseView(_rectView)]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_backBtn(90)]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_submitBtn(90)]-|" options:0 metrics:nil views:allObj]];
    
    //do autolayout in hintBaseView
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_upLine(fixedLabelHeight)]-(labelsHeight)-[_mainBody(_upLine)]-(labelsHeight)-[_downLine(_upLine)]-(labelsHeight)-[_upDown(_upLine)][_upDownBtn(fixedButtonHeight)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_upLineBtn(fixedButtonHeight)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_kBarContainer]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_downLineBtn(_upLineBtn)]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainBody(80)]-4-[_kBarContainer]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upLine]-4-[_upLineBtn(_kBarContainer)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_downLine]-4-[_downLineBtn(_kBarContainer)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upDown]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_upDownBtn]-3-|" options:0 metrics:nil views:allObj]];
    //kBarContainer
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_kBarMainBodyBtn]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_kBarColorBtn]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_kBarMainBodyBtn(_upLineBtn)]-2-[_kBarColorBtn(_upLineBtn)]|" options:0 metrics:nil views:allObj]];

    [self replaceCustomizeConstraints:constraints];
}

-(void)drawTheLineFromKBarToLabel
{
    [super viewDidLayoutSubviews];
    
    //畫單純直線的部份
//    self.rectView.type = FSDrawTypePlainLine;
    //畫箭頭的部份
    self.rectView.type = FSDrawTypeArrowHead;
    self.rectView.upLineArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:_upLinePoint], [NSValue valueWithCGPoint:CGPointMake(_rectView.frame.size.width, _upLine.frame.origin.y + _upLine.frame.size.height / 2)], nil];
    self.rectView.mainBodyArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:_mainBodyPoint], [NSValue valueWithCGPoint:CGPointMake(_rectView.frame.size.width, _mainBody.frame.origin.y + _mainBody.frame.size.height / 2)], nil];
    self.rectView.upDownArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:_upDownPoint], [NSValue valueWithCGPoint:CGPointMake(_rectView.frame.size.width, _upDown.frame.origin.y + _upDown.frame.size.height / 2)], nil];
    self.rectView.downLineArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:_downLinePoint], [NSValue valueWithCGPoint:CGPointMake(_rectView.frame.size.width, _downLine.frame.origin.y + _downLine.frame.size.height / 2)], nil];
    
    [self.rectView setNeedsDisplay];
}

-(void)shareAction:(FSUIButton *)sender
{
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version>=8.0f) {
        NSString *string = @"";
        UIImage *image = [self getImageFromView:[[UIApplication sharedApplication] keyWindow]];
        NSArray *activityItems = @[string, image];
        NSArray *applicationActivities = @[[[FSFaceBookActivity alloc] init], [[FSLineActivity alloc] init]];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypePostToFacebook];
        [self presentViewController:activityViewController animated:YES completion:NULL];
    }else{
        [self shareScreenToFB:[[UIApplication sharedApplication] keyWindow]];
    }
}
- (void)shareScreenToFB:(UIView *)screenView {
    
    //建立對應社群網站的ComposeViewController
    SLComposeViewController *mySocialComposeView = [[SLComposeViewController alloc] init];
    mySocialComposeView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    mySocialComposeView.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone: {
                NSString *account = [[FSDataModelProc sharedInstance] loginService].account;
                NSURLRequest *requset = [[[FSDataModelProc sharedInstance] signupModel] fbSharedRequestWithAccount:account];
                [NSURLConnection sendAsynchronousRequest:requset queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (!connectionError) {
                        NSError *jsonParseError;
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParseError];
                        if (!jsonParseError) {
                            NSString *status = [jsonDict objectForKey:@"status"];
                            if ([@"shar.ok" isEqualToString:status]) {
                                [[[FSDataModelProc sharedInstance] loginService] loginAuthUsingSelfAccount];
                                [SGInfoAlert showInfo:@"FB分享成功,謝謝您的分享,神乎贈送一天圖是力(一天一次)" bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:[[UIApplication sharedApplication] keyWindow]];
                            }
                            else {
                                [SGInfoAlert showInfo:@"FB分享成功,謝謝您的分享" bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:[[UIApplication sharedApplication] keyWindow]];
                            }
                        }
                    }
                }];
                break;
            }
        }
    };
    
    //插入文字
    [mySocialComposeView setInitialText:@""];
    
    //插入網址
    NSURL *myURL = [[NSURL alloc] initWithString:@"http://www.fonestock.com/"];
    [mySocialComposeView addURL: myURL];
    
    
    //插入圖片
    UIImage *myImage = [self getImageFromView:screenView];
    [mySocialComposeView addImage:myImage];
    
    //呼叫建立的SocialComposeView
    [self presentViewController:mySocialComposeView animated:YES completion:^{
        NSLog(@"成功呼叫 SocialComposeView ");
    }];
}
- (UIImage *)getImageFromView:(UIView *)orgView{
    UIGraphicsBeginImageContext(orgView.bounds.size);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//讀取及儲存回資料庫間的資料數值轉換，但是color的儲存上有些問題，所以抓出來另外做
-(NSString *)changeTheZeroToLast:(NSString *)target isItColor:(BOOL)iiC
{
    int returnInt = 0;
    if([target isEqualToString:@"YES"] && !iiC){
        return @"0";
    }else if([target isEqualToString:@"NO"] && !iiC){
        return @"3";
    }else if([target isEqualToString:@"YES"] && iiC){
        return @"0";
    }else if([target isEqualToString:@"NO"] && iiC){
        return @"2";
    }
    int targetInt = [target intValue];
    if(!iiC){
        switch(targetInt){
            case 0: returnInt = 3; break;
            case 1: returnInt = 1; break;
            case 2: returnInt = 2; break;
            case 3: returnInt = 0; break;
            default: break;
        }
    }else{
        switch(targetInt){
            case 0: returnInt = 2; break;
            case 1: returnInt = 0; break;
            case 2: returnInt = 1; break;
            default: break;
        }
    }
    return [NSString stringWithFormat:@"%d",returnInt];
}
//color儲存上做過修正的method，這樣子儲存過後其他viewController顯示的才是相同的
-(NSString *)changeTheZeroToLastForColorOnly:(NSString *)target
{
    int returnInt = 0;
    int targetInt = [target intValue];
    switch(targetInt){
        case 0: returnInt = 1; break;
        case 1: returnInt = 2; break;
        case 2: returnInt = 0; break;
        default: break;
    }
    return [NSString stringWithFormat:@"%d",returnInt];
}

-(CGFloat)getDegree:(double)startX :(double)startY :(double)endX :(double)endY
{
    //此公式可以算出角度
//    float x = 0 - 50 ;
//    float y = -(0 - 0);
//    float radian = atan2f(y, x);
//    float degree = radian *360 /(2*M_PI);
//    NSLog(@"ラジアン：%f　度：%f", radian, degree);
    float x = startX - endX;
    float y = -(startY - endY);
    float radian = atan2f(y, x);
    float degree = radian * 360 / (2 * M_PI);
    NSLog(@"degree = %f", degree);
    return degree ;
}

//判斷哪個按鈕被按下，並呼叫不同的actionSheet 來做對應的動作
-(void)btnClicked:(FSUIButton *)sender
{
    int wakeUpActionSheet = 1;
    //_triggerBtn用來記錄哪個按鈕被按下，以在actionSheet做出對應的動作
    _triggerBtn = sender;
    if(sender == _backBtn){
        wakeUpActionSheet = 0;
        [self storeTempData];
        [self.navigationController popViewControllerAnimated:NO];
    }else if(sender == _submitBtn){
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.figureSearchModel.beSubmit = YES;
        wakeUpActionSheet = 0;
        [self storeTempData];
        [self submitHappens];
        [self.navigationController popToViewController:[_customModel popBackTo:@"FigureCustomCaseViewController" from:self.navigationController.childViewControllers] animated:NO];
    }else if(sender == self.upLineBtn){
        
    }else if(sender == self.kBarMainBodyBtn){
        
    }else if(sender == self.kBarColorBtn){
        wakeUpActionSheet = 2;
    }else if(sender == self.downLineBtn){
        NSLog(@"downLineBtn");
    }else if(sender == self.upDownBtn){
        wakeUpActionSheet = 3;
    }
    if(wakeUpActionSheet == 1){
        if(IS_IOS8){
            _alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"請選擇", @"FigureSearch", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [self addActionTo:_alertController WithActionCancel:4 first:0 second:1 third:2 forth:3  ];
            [self presentViewController:_alertController animated:YES completion:nil];
        }else{
            _actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"請選擇", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"約等於", @"FigureSearch", nil),
                                          NSLocalizedStringFromTable(@"大於", @"FigureSearch", nil),
                                          NSLocalizedStringFromTable(@"小於", @"FigureSearch", nil),
                                          NSLocalizedStringFromTable(@"任意長度", @"FigureSearch", nil), nil];
            [_actionSheet showInView:self.view];
        }
    }else if(wakeUpActionSheet == 2){
        if(IS_IOS8){
            _alertController1 = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"請選擇", @"FigureSearch", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [self addActionTo:_alertController1 WithActionCancel:3 first:0 second:1 third:2 forth:-0];
            [self presentViewController:_alertController1 animated:YES completion:nil];
        }else{
            _actionSheet1 = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"請選擇", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"漲的顏色", @"FigureSearch", nil),
                                          NSLocalizedStringFromTable(@"跌的顏色", @"FigureSearch", nil),
                                          NSLocalizedStringFromTable(@"任意顏色", @"FigureSearch", nil), nil];
            [_actionSheet1 showInView:self.view];
        }
    }else if(wakeUpActionSheet == 3){
        if(IS_IOS8){
            _alertController2 = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"請選擇", @"FigureSearch", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [self addActionTo:_alertController2 WithActionCancel:4 first:0 second:1 third:2 forth:3];
            [self presentViewController:_alertController2 animated:YES completion:nil];
        }else{
            _actionSheet2 = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"請選擇", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"約等於", @"FigureSearch", nil),
                            NSLocalizedStringFromTable(@"大於", @"FigureSearch", nil),
                            NSLocalizedStringFromTable(@"小於", @"FigureSearch", nil),
                            NSLocalizedStringFromTable(@"任意值", @"FigureSearch", nil), nil];
            [_actionSheet2 showInView:self.view];
        }
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == _actionSheet){
        if(buttonIndex == 4) return;
        if(_triggerBtn == _upLineBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)buttonIndex] atIndexedSubscript:FSFigureDBColumnUpLine];
            if(!(buttonIndex == 3)){
                _kLineView.backgroundColor = [UIColor blueColor];
            }else{
                _kLineView.backgroundColor = [UIColor grayColor];
            }
        }else if(_triggerBtn == _kBarMainBodyBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)buttonIndex] atIndexedSubscript:FSFigureDBColumnKLine];
            //按下實體線有數值的按鈕時
            _isShowBorder = YES;
            if(buttonIndex == 3){
                //當按下任意值時，要讓kbar 的外框變成灰色
                _kRectView.layer.borderColor = [UIColor grayColor].CGColor;
                _isShowBorder = NO;
            }else{
                //當按下其他的選項時，則要讓kbar 的外框跟著_openValue 跟_closeValue 的值做變化
//                [self setKBarBorderColor];
            }
        }else if(_triggerBtn == _downLineBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)buttonIndex] atIndexedSubscript:FSFigureDBColumnDownLine];
            if(!(buttonIndex == 3)){
                _downKLineView.backgroundColor = [UIColor blueColor];
            }else{
                _downKLineView.backgroundColor = [UIColor grayColor];
            }
        }
        [self setBtnTitle];
    }else if(actionSheet == _actionSheet1){
        if(buttonIndex == 3) return;
        if(_triggerBtn == _kBarColorBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)buttonIndex] atIndexedSubscript:FSFigureDBColumnColor];
            [self setKBarColorBtnTitle];
            [self setKBarBorderColor];
            [self checkTheOpenAndClose:(int)buttonIndex];
            if(buttonIndex == 0){
                self.rectView.isRedColor = YES;
                _mainBody.textColor = [StockConstant PriceUpColor];
            }else if(buttonIndex == 1){
                self.rectView.isRedColor = NO;
                _mainBody.textColor = [StockConstant PriceDownColor];
            }else{
                if(_openValue > _closeValue){
                    self.rectView.isRedColor = NO;
                    _mainBody.textColor = [StockConstant PriceDownColor];
                }else if(_openValue < _closeValue){
                    self.rectView.isRedColor = YES;
                    _mainBody.textColor = [UIColor redColor];
                }
            }
            [self drawTheLineFromKBarToLabel];
        }
        [self setKBarColorBtnTitle];
    }else if(actionSheet == _actionSheet2){
        if(buttonIndex == 4)return;
        if(_triggerBtn == _upDownBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)buttonIndex] atIndexedSubscript:FSFigureDBColumnRange];
        }
        [self setBtnTitle];
    }
}

-(void)addActionTo:(UIAlertController *)targetController WithActionCancel:(NSInteger)can first:(NSInteger)fir second:(NSInteger)sec third:(NSInteger)third forth:(NSInteger)forth
{
    int count = 5;
    NSArray *clickData = [NSArray arrayWithObjects:[NSNumber numberWithInteger:can],[NSNumber numberWithInteger:fir],[NSNumber numberWithInteger:sec],[NSNumber numberWithInteger:third],[NSNumber numberWithInteger:forth], nil];
    NSArray *actionBtn;
    if(forth == -0){
        count -= 1;
        actionBtn = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil),NSLocalizedStringFromTable(@"漲的顏色", @"FigureSearch", nil),
                     NSLocalizedStringFromTable(@"跌的顏色", @"FigureSearch", nil),
                     NSLocalizedStringFromTable(@"任意顏色", @"FigureSearch", nil),nil];
    }
    if(count == 5){
        actionBtn = [NSArray arrayWithObjects:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil),NSLocalizedStringFromTable(@"約等於", @"FigureSearch", nil),
                     NSLocalizedStringFromTable(@"大於", @"FigureSearch", nil),
                     NSLocalizedStringFromTable(@"小於", @"FigureSearch", nil),
                     NSLocalizedStringFromTable(@"任意長度", @"FigureSearch", nil), nil];
    }
    for(int i = 0; i < count; i++){
        if(i == 0){
            [targetController addAction:[UIAlertAction actionWithTitle:actionBtn[i] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                [self alertController2BeClicked:[clickData[i] integerValue] target:targetController];
            }]];
        }else{
            [targetController addAction:[UIAlertAction actionWithTitle:actionBtn[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self alertController2BeClicked:[clickData[i] integerValue] target:targetController];
            }]];
        }
    }
}

-(void)alertController2BeClicked:(NSInteger)num target:(UIAlertController*)targetController
{
    if(targetController == _alertController){
        if(num == 4) return;
        if(_triggerBtn == _upLineBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)num] atIndexedSubscript:FSFigureDBColumnUpLine];
            if(!(num == 3)){
                _kLineView.backgroundColor = [UIColor blueColor];
            }else{
                _kLineView.backgroundColor = [UIColor grayColor];
            }
        }else if(_triggerBtn == _kBarMainBodyBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)num] atIndexedSubscript:FSFigureDBColumnKLine];
            //按下實體線有數值的按鈕時
            _isShowBorder = YES;
            if(num == 3){
                //當按下任意值時，要讓kbar 的外框變成灰色
                _kRectView.layer.borderColor = [UIColor grayColor].CGColor;
                _isShowBorder = NO;
            }else{
                //當按下其他的選項時，則要讓kbar 的外框跟著_openValue 跟_closeValue 的值做變化
                //                [self setKBarBorderColor];
            }
        }else if(_triggerBtn == _downLineBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)num] atIndexedSubscript:FSFigureDBColumnDownLine];
            if(!(num == 3)){
                _downKLineView.backgroundColor = [UIColor blueColor];
            }else{
                _downKLineView.backgroundColor = [UIColor grayColor];
            }
        }
        [self setBtnTitle];
    }else if(targetController == _alertController1){
        if(num == 3) return;
        if(_triggerBtn == _kBarColorBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)num] atIndexedSubscript:FSFigureDBColumnColor];
            [self setKBarColorBtnTitle];
            [self setKBarBorderColor];
            [self checkTheOpenAndClose:(int)num];
            if(num == 0){
                self.rectView.isRedColor = YES;
                _mainBody.textColor = [StockConstant PriceUpColor];
            }else if(num == 1){
                self.rectView.isRedColor = NO;
                _mainBody.textColor = [StockConstant PriceDownColor];
            }else{
                if(_openValue > _closeValue){
                    self.rectView.isRedColor = NO;
                    _mainBody.textColor = [StockConstant PriceDownColor];
                }else if(_openValue < _closeValue){
                    self.rectView.isRedColor = YES;
                    _mainBody.textColor = [UIColor redColor];
                }
            }
            [self drawTheLineFromKBarToLabel];
        }
        [self setKBarColorBtnTitle];
    }else if(targetController == _alertController2){
        if(num == 4)return;
        if(_triggerBtn == _upDownBtn){
            [_insertToDBArray setObject:[NSString stringWithFormat:@"%d", (int)num] atIndexedSubscript:FSFigureDBColumnRange];
        }
        [self setBtnTitle];
    }
}

-(void)storeTempData
{
    //儲存各個數值
    NSMutableArray *forDBUse = [NSMutableArray arrayWithArray:_insertToDBArray];
    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnRange] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnRange];
    [forDBUse setObject:[self changeTheZeroToLastForColorOnly:[_insertToDBArray objectAtIndex:FSFigureDBColumnColor]] atIndexedSubscript:FSFigureDBColumnColor];
    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnUpLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnUpLine];
    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnKLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnKLine];
    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnDownLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnDownLine];
    [forDBUse setObject:[NSNumber numberWithDouble:_highValue] atIndexedSubscript:5];
    [forDBUse setObject:[NSNumber numberWithDouble:_lowValue] atIndexedSubscript:6];
    [forDBUse setObject:[NSNumber numberWithDouble:_openValue] atIndexedSubscript:7];
    [forDBUse setObject:[NSNumber numberWithDouble:_closeValue] atIndexedSubscript:8];
    [_customModel doneEditKBarFigureSearchID:[NSNumber numberWithInt:_figureSearchID] NewFigureSearchId:[NSNumber numberWithInt:_figureSearchID] TNumber:[NSNumber numberWithInt:_kNumber] theData:forDBUse type:FSFigureCustomStoreTypeTempStore];
}

-(void)submitHappens
{
    //將有乘上10 的數字還原
//    NSMutableArray *forDBUse = [NSMutableArray arrayWithArray:_insertToDBArray];
//    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnRange] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnRange];
//    [forDBUse setObject:[self changeTheZeroToLastForColorOnly:[_insertToDBArray objectAtIndex:FSFigureDBColumnColor]] atIndexedSubscript:FSFigureDBColumnColor];
//    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnUpLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnUpLine];
//    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnKLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnKLine];
//    [forDBUse setObject:[self changeTheZeroToLast:[_insertToDBArray objectAtIndex:FSFigureDBColumnDownLine] isItColor:OUT_OF_COLOR] atIndexedSubscript:FSFigureDBColumnDownLine];
//    [forDBUse setObject:[NSNumber numberWithDouble:_highValue] atIndexedSubscript:5];
//    [forDBUse setObject:[NSNumber numberWithDouble:_lowValue] atIndexedSubscript:6];
//    [forDBUse setObject:[NSNumber numberWithDouble:_openValue] atIndexedSubscript:7];
//    [forDBUse setObject:[NSNumber numberWithDouble:_closeValue] atIndexedSubscript:8];
//    [_customModel doneEditKBarFigureSearchID:[NSNumber numberWithInt:_figureSearchID/10] NewFigureSearchId:[NSNumber numberWithInt:_figureSearchID] TNumber:[NSNumber numberWithInt:_kNumber] theData:forDBUse type:FSFigureCustomStoreTypeSubmitStore];
    //這裡的動作已經交給caseViewController 來做判斷了
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
