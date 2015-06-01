//
//  FigureCustomEditViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/29.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureCustomEditViewController.h"
#import "FigureRangeSetupViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "KxMenu.h"
#import "FSTeachPopView.h"
#import "FSTeachPopDelegate.h"
#import "FigureCustomDetailViewController.h"

@interface FigureCustomEditViewController ()<UIScrollViewDelegate,FSTeachPopDelegate>

@property (nonatomic)int analysisPeriod;
@property (strong, nonatomic) UIView *numberRectView;
@property (strong, nonatomic) UILabel *rangeLabel;
@property (nonatomic)BOOL changeNameFlag;

//@property (nonatomic) int searchNum;
//@property (nonatomic) int currentOption;
//@property (nonatomic) int kNumber;
@property (nonatomic) float range;

@property(nonatomic)float defaultHeight;
@property(nonatomic)float lineDefaultX;
@property(nonatomic)float rectDefaultX;
@property(nonatomic)float rectDefaultY;
@property(nonatomic)float changeY;

@property (nonatomic)float high;
@property (nonatomic)float low;
@property (nonatomic)float open;
@property (nonatomic)float close;

@property (strong , nonatomic) UIButton *goToDetailBtn;
@property (strong , nonatomic) UIButton * backBtn;
@property (strong , nonatomic) UIButton * editRangeBtn;
@property (strong , nonatomic) UILabel * titleLabel;
@property (strong) NSMutableArray * searchKeyArray;


@property (strong ,nonatomic) UIScrollView *mainScrollView;
@property (strong ,nonatomic)UIView * secView;
@property (strong ,nonatomic)UIButton * typeBtn;

//用來記錄使用者切換到日線、週線還是月線
@property (nonatomic) int storeDWM;
@property (strong ,nonatomic) UIView *rectView;
@property (strong ,nonatomic) UIView * zeroLineView;
@property (strong ,nonatomic) UILabel * fivePercentLabel;
@property (strong ,nonatomic) UILabel * negativeFivePercentLabel;
@property (strong ,nonatomic) UILabel * percentLabel;
@property (strong ,nonatomic) UILabel * negativePercentLabel;
@property (strong ,nonatomic) UILabel * percent2Label;
@property (strong ,nonatomic) UILabel * negativePercent2Label;

@property (strong ,nonatomic) UILabel * percentTextLabel;
@property (strong ,nonatomic) UILabel * negativePercentTextLabel;
@property (strong ,nonatomic) UILabel * percent2TextLabel;
@property (strong ,nonatomic) UILabel * negativePercent2TextLabel;


@property (strong ,nonatomic)UIView * kBackGroundView;
@property (strong ,nonatomic)UIView * kView;
@property (strong ,nonatomic)UIView * kLineView;
@property (strong ,nonatomic)UIView * downKLineView;
@property (strong ,nonatomic)UIView * kRectView;

@property (strong ,nonatomic)UIView * highView;
@property (strong ,nonatomic)UILabel * highLabel;
@property (strong ,nonatomic)UILabel * highDottedline;

@property (strong ,nonatomic)UIView * lowView;
@property (strong ,nonatomic)UILabel * lowLabel;
@property (strong ,nonatomic)UILabel * lowDottedline;

@property (strong ,nonatomic)UIView * openView;
@property (strong ,nonatomic)UILabel * openLabel;
@property (strong ,nonatomic)UILabel * openDottedline;

@property (strong ,nonatomic)UIView * closeView;
@property (strong ,nonatomic)UILabel * closeLabel;
@property (strong ,nonatomic)UILabel * closeDottedline;

@property (strong ,nonatomic) UILabel * tenPercentLabel;
@property (strong ,nonatomic) UILabel * zeroPercentLabel;
@property (strong ,nonatomic) UILabel * negativeTenPercentLabel;

@property (strong ,nonatomic)UIPanGestureRecognizer * highPan;
@property (strong ,nonatomic)UIPanGestureRecognizer * lowPan;
@property (strong ,nonatomic)UIPanGestureRecognizer * openPan;
@property (strong ,nonatomic)UIPanGestureRecognizer * closePan;
@property (strong ,nonatomic)UIPanGestureRecognizer * backGroundViewPan;

@property (strong) NSMutableArray * figureSearchArray;
@property (strong, nonatomic) FSTeachPopView * explainView;
//@property (nonatomic) BOOL firstIn;


@property (strong, nonatomic) UIColor * kRectUpColor;
@property (strong, nonatomic) UIColor * kRectDownColor;
@property (strong, nonatomic) UIColor * kUpLineColor;
@property (strong, nonatomic) UIColor * kDownLineColor;
@property (strong, nonatomic) UIColor * kRectBorderUpColor;
@property (strong, nonatomic) UIColor * kRectBorderDownColor;

@property (strong ,nonatomic) FigureSearchMyProfileModel * customModel;

//viewDidLayoutSubview 會執行兩次，讓內部的計算出現問題
@property (nonatomic) BOOL runTwice;
@property (nonatomic) BOOL alreadyHaveOne;
@end

@implementation FigureCustomEditViewController

- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber kNumber:(int)kNum forDWM:(int)dwm
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.currentOption = current;
        self.searchNum = searchNumber;
        self.kNumber = kNum;
        _storeDWM = dwm;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _runTwice = YES;
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    _changeNameFlag = NO;
    self.figureSearchArray = [[NSMutableArray alloc]init];
    self.lineDefaultX =22.5;//137.5;
    self.rectDefaultX =0;// 115;
    [self initTitle];
    [self initBtn];
    [self initView];
    [self initMoveLabel];
    [self initVar];
//    [self actionInit];
    [self.view setNeedsUpdateConstraints];
    _firstIn = YES;
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self reloadDBData];
}

-(void)reloadDBData
{
    [self setDefault];
//    if(_alreadyHaveOne)
//        [_customModel doneEditKBarFigureSearchID:[_figureSearchArray objectAtIndex:0] NewFigureSearchId:[NSNumber numberWithInt:[[_figureSearchArray objectAtIndex:0] intValue] * 10] TNumber:[NSNumber numberWithInt:_kNumber] theData:nil type:FSFigureCustomStoreTypeSubmitStore];
    NSMutableArray * conditionArray = [_customModel searchkBarConditionsWithFigureSearchId:[NSNumber numberWithInt:[[_figureSearchArray objectAtIndex:0] intValue] * 10] tNumber:[NSNumber numberWithInt:_kNumber]];
    if ([conditionArray count]==0){
        _kUpLineColor = [UIColor blueColor];
        _kDownLineColor = [UIColor blueColor];
        _kRectUpColor = [StockConstant PriceUpColor];
        _kRectDownColor = [StockConstant PriceDownColor];
        _kRectBorderUpColor = [StockConstant PriceUpColor];
        _kRectBorderDownColor = [StockConstant PriceDownColor];
    }else{
        if ([[conditionArray objectAtIndex:1]boolValue]) {
            _kRectUpColor = [StockConstant PriceUpColor];
            _kRectDownColor = [StockConstant PriceDownColor];
        }else{
            _kRectUpColor = [UIColor grayColor];
            _kRectDownColor = [UIColor grayColor];
        }
        if ([[conditionArray objectAtIndex:2]boolValue]) {
            _kUpLineColor = [UIColor blueColor];
        }else{
            _kUpLineColor = [UIColor grayColor];
        }
        if ([[conditionArray objectAtIndex:3]boolValue]) {
            _kRectBorderUpColor = [StockConstant PriceUpColor];
            _kRectBorderDownColor = [StockConstant PriceDownColor];
        }else{
            _kRectBorderUpColor = [UIColor grayColor];
            _kRectBorderDownColor = [UIColor grayColor];
        }
        if ([[conditionArray objectAtIndex:4]boolValue]) {
            _kDownLineColor = [UIColor blueColor];
        }else{
            _kDownLineColor = [UIColor grayColor];
        }
    }
    
    /*
     if ([[conditionArray objectAtIndex:3] isEqualToString:@"YES"] || [(NSNumber *)[conditionArray objectAtIndex:3]intValue] == 1) {
     _kRectBorderUpColor = [StockConstant PriceUpColor];
     _kRectBorderDownColor = [StockConstant PriceDownColor];
     }else if([[conditionArray objectAtIndex:3] isEqualToString:@"YES"] || [(NSNumber *)[conditionArray objectAtIndex:3]intValue] == 2) {
     _kRectBorderUpColor = [StockConstant PriceDownColor];
     _kRectBorderDownColor = [StockConstant PriceUpColor];
     }else{
     _kRectBorderUpColor = [UIColor grayColor];
     _kRectBorderDownColor = [UIColor grayColor];
     }
     */
    
    [self setKBar];
    //[self setRange];
    [_titleLabel setText:[_searchKeyArray objectAtIndex:_kNumber + _storeDWM * 5]];
    _analysisPeriod = _storeDWM - 1;
    _storeDWM = _kNumber + _storeDWM * 5;
    
    if (_firstIn) {
        NSString * show = [_customModel searchInstructionByControllerName:[[self class] description]];
        if ([show isEqualToString:@"YES"]) {
            [self teachPop];
        }
        _firstIn = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_backBtn,_titleLabel,_editRangeBtn,_mainScrollView,_rectView,_zeroLineView,_highView,_highLabel,_highDottedline,_lowDottedline,_lowLabel,_lowView,_openDottedline,_openLabel,_closeLabel,_closeDottedline,_tenPercentLabel,_negativeTenPercentLabel,_numberRectView,_rangeLabel,_goToDetailBtn);
    if ([FSUtility isGraterThanSupportVersion:7]) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-23-[_backBtn(44)]-3-[_mainScrollView(45)]-3-[_rectView]-35-|" options:0 metrics:nil views:viewControllers]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-118-[_numberRectView]-1-[_goToDetailBtn(33)]-1-|" options:0 metrics:nil views:viewControllers]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_backBtn(44)]-3-[_mainScrollView(45)]-3-[_rectView]-2-|" options:0 metrics:nil views:viewControllers]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-98-[_numberRectView]-2-|" options:0 metrics:nil views:viewControllers]];
    }
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_titleLabel(30)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_editRangeBtn(44)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_backBtn(44)]-5-[_titleLabel]-5-[_editRangeBtn(44)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_rectView][_numberRectView(45)]-5-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_mainScrollView]-5-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_goToDetailBtn(80)]-5-|" options:0 metrics:nil views:viewControllers]];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_rangeLabel]|" options:0 metrics:nil views:viewControllers]];
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rangeLabel(11)]" options:0 metrics:nil views:viewControllers]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rangeLabel(14)]" options:0 metrics:nil views:viewControllers]];
    }
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_zeroLineView(1)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_zeroLineView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_zeroLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_zeroLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    
    //high
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_highView(70)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_highView(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_highView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_kLineView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_highView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_kLineView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_highDottedline(32)][_highLabel(38)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_highDottedline(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_highLabel(40)]" options:0 metrics:nil views:viewControllers]];
    
    //low
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_lowView(70)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lowView(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_lowView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_downKLineView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_lowView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_downKLineView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_lowLabel(38)][_lowDottedline(32)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_lowLabel(40)]" options:0 metrics:nil views:viewControllers]];
    
    //open
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_openLabel(38)][_openDottedline(63)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_openLabel(40)]" options:0 metrics:nil views:viewControllers]];
    
    //close
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_closeDottedline(63)][_closeLabel(38)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_closeDottedline(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_closeLabel(40)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tenPercentLabel(20)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_negativeTenPercentLabel(20)]" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(void)viewDidLayoutSubviews{
    if (_changeNameFlag) {
        _changeNameFlag = NO;
    }else{
        NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_tenPercentLabel,_zeroPercentLabel,_negativeTenPercentLabel,_percentTextLabel,_negativePercentTextLabel,_percent2TextLabel,_negativePercent2TextLabel);
        self.defaultHeight = _rectView.frame.size.height/(_range*2+1);
        float defaultHeight = _rectView.frame.size.height/22;
        
        //虛線
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_fivePercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroLineView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-10*defaultHeight]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_fivePercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_fivePercentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativeFivePercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroLineView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:10*defaultHeight]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativeFivePercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativeFivePercentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroLineView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-4*defaultHeight]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroLineView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:4*defaultHeight]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percent2Label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroLineView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-8*defaultHeight]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percent2Label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percent2Label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercent2Label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroLineView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:8*defaultHeight]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercent2Label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercent2Label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        
        //右邊數字
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tenPercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_fivePercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:1]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_tenPercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_tenPercentLabel(45)]" options:0 metrics:nil views:viewControllers]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_zeroPercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_zeroPercentLabel(45)]" options:0 metrics:nil views:viewControllers]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativeTenPercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_negativeFivePercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-2]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativeTenPercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_negativeTenPercentLabel(45)]" options:0 metrics:nil views:viewControllers]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentTextLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_percentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_percentTextLabel(45)]" options:0 metrics:nil views:viewControllers]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentTextLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_negativePercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-2]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_negativePercentTextLabel(45)]" options:0 metrics:nil views:viewControllers]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percent2TextLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_percent2Label attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percent2TextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_percent2TextLabel(45)]" options:0 metrics:nil views:viewControllers]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercent2TextLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_negativePercent2Label attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-2]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercent2TextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_negativePercent2TextLabel(45)]" options:0 metrics:nil views:viewControllers]];
        
        [self setDefault];
        [self setKBar];
        
        [self.view layoutSubviews];
    }
    [self changeNumberView];

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
}

-(void)setDefault{
    
    NSString * gategory =@"";
    
    if (_currentOption ==0) {
        gategory = @"LongSystem";
    }else if (_currentOption ==1){
        gategory = @"ShortSystem";
    }else if (_currentOption ==2){
        gategory = @"LongCustom";
    }else if (_currentOption ==3){
        gategory = @"ShortCustom";
    }
    
    self.figureSearchArray =[_customModel searchFigureSearchIdWithGategory:gategory ItemOrder:[NSNumber numberWithInt:_searchNum]];
    int figureSearchId = [(NSNumber *)[_figureSearchArray objectAtIndex:0]intValue];
    [self setRange];
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    dataArray = [_customModel searchCustomKbarWithFigureSearchId:[NSNumber numberWithInt:figureSearchId] TNumber:[NSNumber numberWithInt:_kNumber]];
    _alreadyHaveOne = YES;
    if(!dataArray.count){
        figureSearchId = figureSearchId * 10;
        dataArray = [_customModel searchCustomKbarWithFigureSearchId:[NSNumber numberWithInt:figureSearchId] TNumber:[NSNumber numberWithInt:_kNumber]];
        _alreadyHaveOne = NO;
    }
    if (![dataArray count]==0) {
        _high = (_range+0.5-[(NSNumber *)[dataArray objectAtIndex:0]floatValue]*100)*_defaultHeight;
        _low = (_range+0.5-[(NSNumber *)[dataArray objectAtIndex:1]floatValue]*100)*_defaultHeight;
        _open = (_range+0.5-[(NSNumber *)[dataArray objectAtIndex:2]floatValue]*100)*_defaultHeight;
        _close = (_range+0.5-[(NSNumber *)[dataArray objectAtIndex:3]floatValue]*100)*_defaultHeight;
    }else{
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        dataArray = [_customModel searchDefaultKbarWithNumber:[NSNumber numberWithInt:1]];
        
        float changeRange = 10.0f/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue];
        
        _high = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:0]floatValue]/changeRange)*100)*_defaultHeight;
        _low = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:1]floatValue]/changeRange)*100)*_defaultHeight;
        _open = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:2]floatValue]/changeRange)*100)*_defaultHeight;
        _close = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:3]floatValue]/changeRange)*100)*_defaultHeight;
    }
    
}

-(void)setKBar{
    
    _kBackGroundView.frame = CGRectMake(_rectView.center.x-25, 0, 50, _rectView.frame.size.height);
    _kLineView.backgroundColor = _kUpLineColor;

    _downKLineView.backgroundColor = _kDownLineColor;
    
    _kRectView.frame = CGRectMake(_rectDefaultX, _close-_high, 50, _open-_close);
    _kRectView.layer.borderWidth = 3;
    if (_open>_close) {
        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
        _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
        _kRectView.backgroundColor = _kRectUpColor;
        _kRectView.layer.borderColor = _kRectBorderUpColor.CGColor;
    }else if (_close>_open){
        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
        _downKLineView.frame = CGRectMake(_lineDefaultX, _close-_high, 5, _low-_close);
        _kRectView.backgroundColor = _kRectDownColor;
        _kRectView.layer.borderColor = _kRectBorderDownColor.CGColor;
    }else{
        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
        _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
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
    
    _openView.frame = CGRectMake(_rectView.center.x-25-100, _open-20, 100, 40);
    _closeView.frame = CGRectMake(_rectView.center.x-25+50, _close-20, 100, 40);
    
}

-(void)setRange{
    _range = [(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue];
    _tenPercentLabel.text = [NSString stringWithFormat:@"-%.1f%%",_range];
    _negativeTenPercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",_range];
    
    float number1 = [(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*2.0f/5.0f;
    float number2 = [(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*4.0f/5.0f;
    
    _percentTextLabel.text = [NSString stringWithFormat:@"-%.1f%%",number1];
    _negativePercentTextLabel.text = [NSString stringWithFormat:@"--%.1f%%",number1];
    _percent2TextLabel.text = [NSString stringWithFormat:@"-%.1f%%",number2];
    _negativePercent2TextLabel.text = [NSString stringWithFormat:@"--%.1f%%",number2];
}

-(void)initTitle{
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_backBtn];
    
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_titleLabel];
    
    self.editRangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editRangeBtn setImage:[UIImage imageNamed:@"GearButton_Black"] forState:UIControlStateNormal];
    _editRangeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_editRangeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editRangeBtn];
    
}

-(void)initBtn{
    self.mainScrollView = [[UIScrollView alloc] init];
    _mainScrollView.backgroundColor = [UIColor whiteColor];
    _mainScrollView.bounces = NO;
    _mainScrollView.delegate = self;
    _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_mainScrollView];
    
    self.secView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 12*45, 45)];
    
    for (int i =0; i<12; i++) {
        self.typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _typeBtn.frame = CGRectMake(i*45, 0, 40, 45);
        //[_typeBtn setTitle:[NSString stringWithFormat:@"type%d",i] forState:UIControlStateNormal];
        [_typeBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"kbar%d",i+1]] forState:UIControlStateNormal];
        _typeBtn.tag = i+1;
        [_typeBtn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_secView addSubview:_typeBtn];
    }
    
    [_mainScrollView addSubview:_secView];

    [_mainScrollView setContentSize:CGSizeMake(45*12, 45)];
}

-(void)initView{
    self.rectView = [[UIView alloc] init];
    self.rectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rectView.layer.borderColor = [UIColor blackColor].CGColor;
    self.rectView.layer.borderWidth = 1;
    [self.rectView setMultipleTouchEnabled:YES];
    [self.view addSubview:self.rectView];
    
    self.numberRectView = [[UIView alloc] init];
    self.numberRectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberRectView.layer.borderColor = [UIColor blackColor].CGColor;
    self.numberRectView.layer.borderWidth = 1;
    [self.view addSubview:self.numberRectView];
    
    UITapGestureRecognizer * tapNumberRectView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeNumberView)];
    
    [_numberRectView addGestureRecognizer:tapNumberRectView];
    
    self.rangeLabel = [[UILabel alloc]init];
    self.rangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rangeLabel.textAlignment = NSTextAlignmentCenter;
    self.rangeLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    _rangeLabel.text = NSLocalizedStringFromTable(@"Daily",@"Draw",@"");
    [self.numberRectView addSubview:_rangeLabel];
    
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        self.rangeLabel.font = [UIFont systemFontOfSize:11.0f];

    }else{
        self.rangeLabel.font = [UIFont systemFontOfSize:14.0f];

    }
    
    UIFont *rightLabelFont = [UIFont systemFontOfSize:12.0f];
    
    self.tenPercentLabel = [[UILabel alloc]init];
    _tenPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_tenPercentLabel.text = @"10%";
    _tenPercentLabel.backgroundColor = [UIColor clearColor];
    _tenPercentLabel.font = rightLabelFont;
    [self.view addSubview:_tenPercentLabel];
    
    self.zeroPercentLabel = [[UILabel alloc]init];
    _zeroPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _zeroPercentLabel.text = @"-0%";
    _zeroPercentLabel.font = rightLabelFont;
    [self.view addSubview:_zeroPercentLabel];
    
    self.negativeTenPercentLabel = [[UILabel alloc]init];
    _negativeTenPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    //_negativeTenPercentLabel.text = @"-10%";
//    _negativeTenPercentLabel.font = rightLabelFont;
    _negativeTenPercentLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_negativeTenPercentLabel];
    
    self.percentTextLabel = [[UILabel alloc]init];
    _percentTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _percentTextLabel.font = rightLabelFont;
    [self.view addSubview:_percentTextLabel];
    
    self.percent2TextLabel = [[UILabel alloc]init];
    _percent2TextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _percent2TextLabel.font = rightLabelFont;
    [self.view addSubview:_percent2TextLabel];
    
    self.negativePercentTextLabel = [[UILabel alloc]init];
    _negativePercentTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _negativePercentTextLabel.font = rightLabelFont;
    [self.view addSubview:_negativePercentTextLabel];
    
    self.negativePercent2TextLabel = [[UILabel alloc]init];
    _negativePercent2TextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _negativePercent2TextLabel.font = rightLabelFont;
    [self.view addSubview:_negativePercent2TextLabel];
    
    
    self.zeroLineView = [[UIView alloc]init];
    _zeroLineView.translatesAutoresizingMaskIntoConstraints = NO;
    _zeroLineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashLine2"]];
    [self.rectView addSubview:_zeroLineView];
    
    self.fivePercentLabel = [[UILabel alloc]init];
    _fivePercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _fivePercentLabel.text = @"---------------------------------------------";
    _fivePercentLabel.backgroundColor = [UIColor clearColor];
    _fivePercentLabel.font = [UIFont systemFontOfSize:16.0f];
    _fivePercentLabel.lineBreakMode = NSLineBreakByClipping;
    [self.rectView addSubview:_fivePercentLabel];
    
    self.negativeFivePercentLabel = [[UILabel alloc]init];
    _negativeFivePercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _negativeFivePercentLabel.text = @"---------------------------------------------";
    _negativeFivePercentLabel.backgroundColor = [UIColor clearColor];
    _negativeFivePercentLabel.font = [UIFont systemFontOfSize:16.0f];
    _negativeFivePercentLabel.lineBreakMode = NSLineBreakByClipping;
    [self.rectView addSubview:_negativeFivePercentLabel];
    
    self.percentLabel = [[UILabel alloc]init];
    _percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _percentLabel.text = @"---------------------------------------------";
    _percentLabel.backgroundColor = [UIColor clearColor];
    _percentLabel.font = [UIFont systemFontOfSize:16.0f];
    _percentLabel.lineBreakMode = NSLineBreakByClipping;
    [self.rectView addSubview:_percentLabel];
    
    self.negativePercentLabel = [[UILabel alloc]init];
    _negativePercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _negativePercentLabel.text = @"---------------------------------------------";
    _negativePercentLabel.backgroundColor = [UIColor clearColor];
    _negativePercentLabel.font = [UIFont systemFontOfSize:16.0f];
    _negativePercentLabel.lineBreakMode = NSLineBreakByClipping;
    [self.rectView addSubview:_negativePercentLabel];
    
    self.percent2Label = [[UILabel alloc]init];
    _percent2Label.translatesAutoresizingMaskIntoConstraints = NO;
    _percent2Label.text = @"---------------------------------------------";
    _percent2Label.backgroundColor = [UIColor clearColor];
    _percent2Label.font = [UIFont systemFontOfSize:16.0f];
    _percent2Label.lineBreakMode = NSLineBreakByClipping;
    [self.rectView addSubview:_percent2Label];
    
    self.negativePercent2Label = [[UILabel alloc]init];
    _negativePercent2Label.translatesAutoresizingMaskIntoConstraints = NO;
    _negativePercent2Label.text = @"---------------------------------------------";
    _negativePercent2Label.backgroundColor = [UIColor clearColor];
    _negativePercent2Label.font = [UIFont systemFontOfSize:16.0f];
    _negativePercent2Label.lineBreakMode = NSLineBreakByClipping;
    [self.rectView addSubview:_negativePercent2Label];
    
    
    //add k棒
    self.kView = [[UIView alloc] init];
    _kView.backgroundColor = [UIColor clearColor];
    [self.rectView addSubview:_kView];
    
    self.kLineView = [[UIView alloc] init];
    [self.kView addSubview:_kLineView];
    
    self.downKLineView = [[UIView alloc]init];
    [self.kView addSubview:_downKLineView];
    
    self.kRectView = [[UIView alloc] init];
    _kRectView.backgroundColor = [UIColor redColor];
    [self.kView addSubview:_kRectView];
    
    self.backGroundViewPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
    self.kBackGroundView = [[UIView alloc] init];
    [_kBackGroundView addGestureRecognizer:_backGroundViewPan];
    _kBackGroundView.userInteractionEnabled = YES;
    _kBackGroundView.backgroundColor = [UIColor clearColor];
    [self.rectView addSubview:_kBackGroundView];

    self.goToDetailBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenButton];
    self.goToDetailBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.goToDetailBtn setTitle:NSLocalizedStringFromTable(@"下一步", @"FigureSearch", nil) forState:UIControlStateNormal];
    [self.goToDetailBtn addTarget:self action:@selector(goToDetailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.goToDetailBtn];
}

-(void)initMoveLabel{
    
    //open
    self.openPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
    self.openView = [[UIView alloc] init];
    //_openView.translatesAutoresizingMaskIntoConstraints = NO;
    [_openView addGestureRecognizer:_openPan];
    _openView.userInteractionEnabled = YES;
    _openView.backgroundColor = [UIColor clearColor];
    [self.rectView addSubview:_openView];
    
    self.openLabel = [[UILabel alloc]init];
    _openLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _openLabel.text = NSLocalizedStringFromTable(@"開", @"FigureSearch",nil);
    _openLabel.backgroundColor = [UIColor blueColor];//[UIColor colorWithRed:91.0f/255.0 green:123.0f/255.0 blue:253.0f/255.0 alpha:1.0f];
    _openLabel.textColor = [UIColor whiteColor];
    _openLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _openLabel.textAlignment = NSTextAlignmentCenter;
    [_openLabel.layer setMasksToBounds:YES];
    _openLabel.layer.cornerRadius = 10.0;
    [self.openView addSubview:_openLabel];
    
    self.openDottedline = [[UILabel alloc]init];
    _openDottedline.translatesAutoresizingMaskIntoConstraints = NO;
    _openDottedline.text = @"----------";
    _openDottedline.lineBreakMode = NSLineBreakByClipping;
    _openDottedline.backgroundColor = [UIColor clearColor];
    _openDottedline.font = [UIFont systemFontOfSize:16.0f];
    [self.openView addSubview:_openDottedline];
    
    //close
    self.closePan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
    self.closeView = [[UIView alloc] init];
    //_openView.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeView addGestureRecognizer:_closePan];
    _closeView.userInteractionEnabled = YES;
    _closeView.backgroundColor = [UIColor clearColor];
    [self.rectView addSubview:_closeView];
    
    self.closeLabel = [[UILabel alloc]init];
    _closeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _closeLabel.text = NSLocalizedStringFromTable(@"收", @"FigureSearch",nil);
    _closeLabel.backgroundColor = [UIColor blueColor];//[UIColor colorWithRed:91.0f/255.0 green:123.0f/255.0 blue:253.0f/255.0 alpha:1.0f];
    _closeLabel.textColor = [UIColor whiteColor];
    _closeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    _closeLabel.textAlignment = NSTextAlignmentCenter;
    [_closeLabel.layer setMasksToBounds:YES];
    _closeLabel.layer.cornerRadius = 10.0;
    [self.closeView addSubview:_closeLabel];
    
    self.closeDottedline = [[UILabel alloc]init];
    _closeDottedline.translatesAutoresizingMaskIntoConstraints = NO;
    _closeDottedline.text = @"----------";
    _closeDottedline.lineBreakMode = NSLineBreakByClipping;
    _closeDottedline.backgroundColor = [UIColor clearColor];
    _closeDottedline.font = [UIFont systemFontOfSize:16.0f];
    [self.closeView addSubview:_closeDottedline];
    
    //high
    self.highPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
    self.highView = [[UIView alloc] init];
    _highView.translatesAutoresizingMaskIntoConstraints = NO;
    [_highView addGestureRecognizer:_highPan];
    _highView.userInteractionEnabled = YES;
    _highView.backgroundColor = [UIColor clearColor];
    [self.rectView addSubview:_highView];
    
    self.highLabel = [[UILabel alloc]init];
    _highLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _highLabel.text = NSLocalizedStringFromTable(@"高", @"FigureSearch",nil);
    _highLabel.backgroundColor = [UIColor blueColor];//[UIColor colorWithRed:91.0f/255.0 green:123.0f/255.0 blue:253.0f/255.0 alpha:1.0f];
    _highLabel.textColor = [UIColor whiteColor];
    _highLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _highLabel.textAlignment = NSTextAlignmentCenter;
    [_highLabel.layer setMasksToBounds:YES];
    _highLabel.layer.cornerRadius = 10.0;
    [self.highView addSubview:_highLabel];
    
    self.highDottedline = [[UILabel alloc]init];
    _highDottedline.translatesAutoresizingMaskIntoConstraints = NO;
    _highDottedline.text = @"-----";
    _highDottedline.lineBreakMode = NSLineBreakByClipping;
    _highDottedline.backgroundColor = [UIColor clearColor];
    _highDottedline.font = [UIFont systemFontOfSize:16.0f];
    [self.highView addSubview:_highDottedline];
    
    //low
    self.lowPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
    self.lowView = [[UIView alloc] init];
    _lowView.translatesAutoresizingMaskIntoConstraints = NO;
    [_lowView addGestureRecognizer:_lowPan];
    _lowView.userInteractionEnabled = YES;
    _lowView.backgroundColor = [UIColor clearColor];
    [self.rectView addSubview:_lowView];
    
    self.lowLabel = [[UILabel alloc]init];
    _lowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _lowLabel.text = NSLocalizedStringFromTable(@"低", @"FigureSearch",nil);
    _lowLabel.backgroundColor = [UIColor blueColor];//[UIColor colorWithRed:91.0f/255.0 green:123.0f/255.0 blue:253.0f/255.0 alpha:1.0f];
    _lowLabel.textColor = [UIColor whiteColor];
    _lowLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _lowLabel.textAlignment = NSTextAlignmentCenter;
    [_lowLabel.layer setMasksToBounds: YES];
    _lowLabel.layer.cornerRadius = 10.0;
    [self.lowView addSubview:_lowLabel];
    
    self.lowDottedline = [[UILabel alloc]init];
    _lowDottedline.translatesAutoresizingMaskIntoConstraints = NO;
    _lowDottedline.text = @"-----";
    _lowDottedline.lineBreakMode = NSLineBreakByClipping;
    _lowDottedline.backgroundColor = [UIColor clearColor];
    _lowDottedline.font = [UIFont systemFontOfSize:16.0f];
    [self.lowView addSubview:_lowDottedline];
    

}


-(void)viewPan:(UIPanGestureRecognizer *)sender{
    CGPoint location = [sender locationInView:self.rectView];
    if ([sender state]==1) {
        self.rectDefaultY = _kView.center.y;
    }
    
    if ([sender isEqual:_highPan]) {
        if (location.y<_low && location.y>_fivePercentLabel.center.y) {
            if (location.y<=MIN(_open, _close) ) {
                if (location.y<_low) {
                    _high = location.y;
                    if (_open>_close) {
                        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
                        _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
                    }else{
                       _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
                       _downKLineView.frame = CGRectMake(_lineDefaultX, _close-_high, 5, _low-_close);
                    }
                    
                }else{
                    if (_open>_close) {
                        _kLineView.frame = CGRectMake(_lineDefaultX, _low-1-_high, 5, _close-_high);
                    }else{
                        _kLineView.frame = CGRectMake(_lineDefaultX, _low-1-_high, 5, _open-_high);
                    }
                    
                }
                if (_low-_high==0) {
                    _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, 3);
                }else{
                    _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, _low-_high);
                }
                if (_open>_close) {
                    _kRectView.frame =CGRectMake(_rectDefaultX, _close-_high, 50, _open-_close);
                }else if (_close>_open){
                    _kRectView.frame =CGRectMake(_rectDefaultX, _open-_high, 50, _close-_open);
                }else{
                    _kRectView.frame =CGRectMake(_rectDefaultX, _open-_high, 50, 3);

                }
            }
        }
    
    }else if ([sender isEqual:_lowPan]){
        if (location.y>_high && location.y<_negativeFivePercentLabel.center.y) {
            if (location.y>=MAX(_open, _close) ) {
                if (location.y>_high) {
                    _low = location.y;
                    if (_open>_close) {
                        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
                        _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
                    }else{
                        _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
                        _downKLineView.frame = CGRectMake(_lineDefaultX, _close-_high, 5, _low-_close);
                    }
                }else{
                    if (_open>_close) {
                        _downKLineView.frame = CGRectMake(_lineDefaultX, _low-1-_high, 5, _close-_high);
                    }else{
                        _downKLineView.frame = CGRectMake(_lineDefaultX, _low-1-_high, 5, _open-_high);
                    }
                }
                if (_low-_high==0) {
                    _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, 3);
                }else{
                    _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, _low-_high);
                }
            }
        }
    }else if ([sender isEqual:_openPan]){
        if (location.y>=_high && location.y<=_low) {
            _open = location.y;
            if (location.y>_close) {
                _kRectView.backgroundColor = _kRectUpColor;
                _kRectView.layer.borderColor = _kRectBorderUpColor.CGColor;
                _kRectView.frame =CGRectMake(_rectDefaultX, _close-_high, 50, _open-_close);
                _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
                _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
            }else if (location.y<_close){
                _kRectView.backgroundColor = _kRectDownColor;
                _kRectView.layer.borderColor = _kRectBorderDownColor.CGColor;
                _kRectView.frame =CGRectMake(_rectDefaultX, _open-_high, 50, _close-_open);
                _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
                _downKLineView.frame = CGRectMake(_lineDefaultX, _close-_high, 5, _low-_close);
            }else{
                _kRectView.backgroundColor = [UIColor blueColor];
                _kRectView.layer.borderColor = [UIColor blueColor].CGColor;
                _kRectView.frame =CGRectMake(_rectDefaultX, _open-_high, 50, 3);
                _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
            }
            _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, _low-_high);
            _openView.frame = CGRectMake(_rectView.center.x-25-100, _open-20, 100, 40);
        }
        
    }else if ([sender isEqual:_closePan]){
        if (location.y>=_high && location.y<=_low) {
            _close = location.y;
            if (location.y<_open) {
                _kRectView.backgroundColor = _kRectUpColor;
                _kRectView.layer.borderColor = _kRectBorderUpColor.CGColor;
                _kRectView.frame =CGRectMake(_rectDefaultX, _close-_high, 50, _open-_close);
                _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _close-_high);
                _downKLineView.frame = CGRectMake(_lineDefaultX, _open-_high, 5, _low-_open);
            }else if (location.y>_open){
                _kRectView.backgroundColor = _kRectDownColor;
                _kRectView.layer.borderColor = _kRectBorderDownColor.CGColor;
                _kRectView.frame =CGRectMake(_rectDefaultX, _open-_high, 50, _close-_open);
                _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
                _downKLineView.frame = CGRectMake(_lineDefaultX, _close-_high, 5, _low-_close);
            }else{
                _kRectView.backgroundColor = [UIColor blueColor];
                _kRectView.layer.borderColor = [UIColor blueColor].CGColor;
                _kLineView.frame = CGRectMake(_lineDefaultX, _high-_high, 5, _open-_high);
                _kRectView.frame =CGRectMake(_rectDefaultX, _open-_high, 50, 3);
            }
            _kView.frame = CGRectMake(_rectView.center.x-25, _high, 50, _low-_high);
            _closeView.frame = CGRectMake(_rectView.center.x-25+50, _close-20, 100, 40);

        }
    }else if ([sender isEqual:_backGroundViewPan]){
        if (_kView.frame.origin.y>=_fivePercentLabel.center.y && (_kView.frame.origin.y+_kView.frame.size.height)<=_negativeFivePercentLabel.center.y) {
            CGPoint location = [sender locationInView:self.rectView];
            if (location.y-_fivePercentLabel.center.y<_kView.frame.size.height/2) {
                _changeY = _kView.frame.size.height/2+_fivePercentLabel.center.y-_kView.center.y;
                [_kView setCenter:CGPointMake(_rectView.center.x, _kView.frame.size.height/2+_fivePercentLabel.center.y)];
            }else if (location.y>_negativeFivePercentLabel.center.y-_kView.frame.size.height/2){
                _changeY =_negativeFivePercentLabel.center.y -(_kView.center.y+_kView.frame.size.height/2);// (_rectView.frame.origin.y+_rectView.frame.size.height)-(_kView.frame.size.height/2)-_rectView.frame.origin.y-_kView.center.y;
                [_kView setCenter:CGPointMake(_rectView.center.x, _negativeFivePercentLabel.center.y-_kView.frame.size.height/2)];
            }else{
                _changeY = location.y-_kView.center.y;
                [_kView setCenter:CGPointMake(_rectView.center.x, location.y)];
                
            }
            _high += _changeY;
            _low += _changeY;
            _open += _changeY;
            _close += _changeY;
            _closeView.frame = CGRectMake(_rectView.center.x-25+50, _close-20, 100, 40);
            _openView.frame = CGRectMake(_rectView.center.x-25-100, _open-20, 100, 40);
        }
    }
}

-(void)changeNumberView{
    _runTwice = !_runTwice;
    if(_runTwice)return;
    _changeNameFlag = YES;
    _analysisPeriod+=1;
    float num  = 1;
    _rangeLabel.textColor = [UIColor whiteColor];
    if ((_analysisPeriod % 3) ==0) {
        num = 1;
        _storeDWM = 0;
        _rangeLabel.text = NSLocalizedStringFromTable(@"Daily",@"Draw",@"");
        [_titleLabel setText:[_searchKeyArray objectAtIndex:_kNumber + _storeDWM * 5]];
    }else if ((_analysisPeriod % 3) ==1) {
        _storeDWM = 1;
        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
        _rangeLabel.text = NSLocalizedStringFromTable(@"Weekly",@"Draw",@"");
        [_titleLabel setText:[_searchKeyArray objectAtIndex:_kNumber + _storeDWM * 5]];
    }else{
        _storeDWM = 2;
        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
        _rangeLabel.text = NSLocalizedStringFromTable(@"Monthly",@"Draw",@"");
        [_titleLabel setText:[_searchKeyArray objectAtIndex:_kNumber + _storeDWM * 5]];
    }

    _tenPercentLabel.text = [NSString stringWithFormat:@"-%.1f%%",_range*num];
    _negativeTenPercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",_range*num];
    
    float number1 = [(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*2.0f/5.0f;
    float number2 = [(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*4.0f/5.0f;
    
    _percentTextLabel.text = [NSString stringWithFormat:@"-%.1f%%",number1*num];
    _negativePercentTextLabel.text = [NSString stringWithFormat:@"--%.1f%%",number1*num];
    _percent2TextLabel.text = [NSString stringWithFormat:@"-%.1f%%",number2*num];
    _negativePercent2TextLabel.text = [NSString stringWithFormat:@"--%.1f%%",number2*num];
}

-(void)btnClick:(FSUIButton *)btn{
    //在detail的確認按鈕被按下前，所有編輯中的資料皆以ref_figureSearch_ID * 10為key 值儲存在DB 中
    //按下確認按鈕後，會將該主要key 值除上10 以達到還原的動作
    //而在此頁只要按下「上一頁」的動作，則會無條件的刪掉所有key 值仍是乘上10 的資料 - 取消
    if ([btn isEqual:_backBtn]) {
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        if(dataModel.figureSearchModel.beSubmit){
            [_customModel editKbarValueWithFigureSearchId:[NSNumber numberWithInt:(int)[_figureSearchArray objectAtIndex:0]*10] TNumber:[NSNumber numberWithInt:_kNumber] High:[NSNumber numberWithFloat:(_range+0.5-_high/_defaultHeight)/100] Low:[NSNumber numberWithFloat:(_range+0.5-_low/_defaultHeight)/100] Open:[NSNumber numberWithFloat:(_range+0.5-_open/_defaultHeight)/100] Close:[NSNumber numberWithFloat:(_range+0.5-_close/_defaultHeight)/100]];
//        }else if(!dataModel.figureSearchModel.beSubmit){
//            int targetID = [_figureSearchArray[0] intValue] * 10;
//            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:targetID]];
        }
        
        //hasBeenToDetail and beSubmit
        
//        }else{
//            [_customModel editKbarValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:0] High:[NSNumber numberWithFloat:(_range+1-_high/_defaultHeight)/100] Low:[NSNumber numberWithFloat:(_range+1-_low/_defaultHeight)/100] Open:[NSNumber numberWithFloat:(_range+1-_open/_defaultHeight)/100] Close:[NSNumber numberWithFloat:(_range+1-_close/_defaultHeight)/100]];
//        }
        
        [self.navigationController popViewControllerAnimated:NO];
    }else if ([btn isEqual:_editRangeBtn]){
//        [_customModel editKbarValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:_kNumber] High:[NSNumber numberWithFloat:(_range+0.5-_high/_defaultHeight)/100] Low:[NSNumber numberWithFloat:(_range+0.5-_low/_defaultHeight)/100] Open:[NSNumber numberWithFloat:(_range+0.5-_open/_defaultHeight)/100] Close:[NSNumber numberWithFloat:(_range+0.5-_close/_defaultHeight)/100]];
        FigureRangeSetupViewController * rangeSetupView = [[FigureRangeSetupViewController alloc]initWithCurrentOption:_currentOption SearchNum:_searchNum dataArray:_figureSearchArray kNumber:_kNumber];
        [self.navigationController pushViewController:rangeSetupView animated:NO];
    }
}

-(void)goToDetailBtnClick:(FSUIButton *)btn{
    int mutliTen = [_figureSearchArray[0] intValue] * 10;
    NSDictionary *sendObj = @{@"kLineBackColor":_kUpLineColor,
                              @"downKLineBackColor":_kDownLineColor,
                              @"lineDefaultX":[NSString stringWithFormat:@"%f",_lineDefaultX],
                              @"kRectUpColor":_kRectUpColor,
                              @"kRectDownColor":_kRectDownColor,
                              @"kRectBorderUpColor":_kRectBorderUpColor,
                              @"kRectBorderDownColor":_kRectBorderDownColor,
                              @"kNumber":[NSString stringWithFormat:@"%d",_kNumber],
                              @"figureSearchID":[NSNumber numberWithInt:mutliTen],
                              @"open":[NSString stringWithFormat:@"%f",_open],
                              @"high":[NSString stringWithFormat:@"%f",_high],
                              @"low":[NSString stringWithFormat:@"%f",_low],
                              @"close":[NSString stringWithFormat:@"%f",_close],
                              @"yOffset":[NSString stringWithFormat:@"%f",_kView.frame.origin.y],
                              @"storeDWM":[NSString stringWithFormat:@"%d",_storeDWM]};
    if(_alreadyHaveOne){
        [_customModel editTheOriginNum:[NSNumber numberWithInt:[_figureSearchArray[0] intValue]] ToMutliTen:[NSNumber numberWithInt:mutliTen] TNumber:[NSNumber numberWithInt:_kNumber]];
        
        [_customModel editKbarValueWithFigureSearchId:[NSNumber numberWithInt:mutliTen] TNumber:[NSNumber numberWithInt:_kNumber] High:[NSNumber numberWithFloat:(_range+0.5-_high/_defaultHeight)/100] Low:[NSNumber numberWithFloat:(_range+0.5-_low/_defaultHeight)/100] Open:[NSNumber numberWithFloat:(_range+0.5-_open/_defaultHeight)/100] Close:[NSNumber numberWithFloat:(_range+0.5-_close/_defaultHeight)/100]];
    }else{
        [_customModel editKbarValueWithFigureSearchId:[NSNumber numberWithInt:mutliTen] TNumber:[NSNumber numberWithInt:_kNumber] High:[NSNumber numberWithFloat:(_range+0.5-_high/_defaultHeight)/100] Low:[NSNumber numberWithFloat:(_range+0.5-_low/_defaultHeight)/100] Open:[NSNumber numberWithFloat:(_range+0.5-_open/_defaultHeight)/100] Close:[NSNumber numberWithFloat:(_range+0.5-_close/_defaultHeight)/100]];
    }
    
    FigureCustomDetailViewController *fcdvc = [[FigureCustomDetailViewController alloc] initWithNeededObjectFromDictionary:sendObj :_currentOption :_searchNum :_kNumber];
    [self.navigationController pushViewController:fcdvc animated:NO];
}

-(void)typeBtnClick:(UIButton *)btn{
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    dataArray = [_customModel searchDefaultKbarWithNumber:[NSNumber numberWithInteger:btn.tag]];
    
    float changeRange = 10.0f/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue];
    
    _high = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:0]floatValue]/changeRange)*100)*_defaultHeight;
    _low = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:1]floatValue]/changeRange)*100)*_defaultHeight;
    _open = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:2]floatValue]/changeRange)*100)*_defaultHeight;
    _close = (_range+0.5-([(NSNumber *)[dataArray objectAtIndex:3]floatValue]/changeRange)*100)*_defaultHeight;
    
    
    [self setKBar];
}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];

    [_explainView showMenuWithRect:CGRectMake(60, 70, 0, 0) String:NSLocalizedStringFromTable(@"選擇預設K棒", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionLeft];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(20, 50, 30, 56)];
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [_explainView showMenuWithRect:CGRectMake(210,220, 0, 0) String:NSLocalizedStringFromTable(@"調整K棒", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionDown];
        [_explainView addHandImageWithType:@"handLongTap"Rect:CGRectMake(190, 200, 30, 56)];
        [_explainView showMenuWithRect:CGRectMake(140, 335, 0, 0) String:NSLocalizedStringFromTable(@"移動K棒", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionUp];
        [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(140, 280, 30, 56)];
    }else{
        [_explainView showMenuWithRect:CGRectMake(200,240, 0, 0) String:NSLocalizedStringFromTable(@"調整K棒", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionDown];
        [_explainView addHandImageWithType:@"handLongTap"Rect:CGRectMake(190, 230, 30, 56)];
        [_explainView showMenuWithRect:CGRectMake(140, 390, 0, 0) String:NSLocalizedStringFromTable(@"移動K棒", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionUp];
        [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(140, 330, 30, 56)];
    }
}


-(void)closeTeachPop:(UIView *)view{
    //存資料庫
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    [view removeFromSuperview];
    if (teachPopView.checkBtn.selected) {
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"NO"];
    }else{
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"YES"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
