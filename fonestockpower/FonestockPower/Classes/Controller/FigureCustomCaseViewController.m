//
//  FigureCustomCaseViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureCustomCaseViewController.h"
#import "FigureCustomEditViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "KxMenu.h"
#import "FSTeachPopView.h"
#import "FigureSetFlatTrendViewController.h"
#import "FSTeachPopDelegate.h"

#import "CXAlertView.h"

#define IS_IOS8 [[UIDevice currentDevice] systemVersion].floatValue >= 8.0

@interface FigureCustomCaseViewController()<UITextFieldDelegate,UIAlertViewDelegate,FSTeachPopDelegate,CustomIOS7AlertViewDelegate>{
    UIAlertView * noKlineAlert;
    CustomIOS7AlertView *hintAlertView;//bug#10581 wiser.kuo
    int newId;

}

@property (nonatomic)int analysisPeriod;
@property (nonatomic)BOOL changeNameFlag;

@property (nonatomic) int kRectWidth;//k棒寬
@property (nonatomic) BOOL trendLine;//是否開啟趨勢線
@property (strong, nonatomic)FSUIButton * trendBtn;
@property (strong, nonatomic)FSUIButton *storeBtn;
@property (nonatomic) int oldTrend;

@property (strong, nonatomic) UIView * trendSettingView;
@property (strong, nonatomic) UILabel * textLabel;
@property (nonatomic, readwrite)trendType trend;
@property (strong, nonatomic) UIImageView * upLineImage;
@property (strong, nonatomic) UIImageView * downLineImage;
@property (strong, nonatomic) UIImageView * flatLineImage;

@property (strong, nonatomic) UIButton * upLineBtn;
@property (strong, nonatomic) UIButton * downLineBtn;
@property (strong, nonatomic) UIButton * upDownLineBtn;
@property (strong, nonatomic) FSUIButton * skipBtn;
@property (strong, nonatomic) FSUIButton * doneBtn;

@property (strong, nonatomic) UISlider * upLineSlider;
@property (strong, nonatomic) UILabel * upZeroLabel;
@property (strong, nonatomic) UILabel * upSixtyLabel;
@property (strong, nonatomic) UILabel * upTextLabel;

@property (strong, nonatomic) UISlider * downLineSlider;
@property (strong, nonatomic) UILabel * downZeroLabel;
@property (strong, nonatomic) UILabel * downSixtyLabel;
@property (strong, nonatomic) UILabel * downTextLabel;

@property (strong, nonatomic) UISlider * upDownLineSlider;
@property (strong, nonatomic) UILabel * upDownZeroLabel;
@property (strong, nonatomic) UILabel * upDownSixtyLabel;
@property (strong, nonatomic) UILabel * upDownTextLabel;
@property (strong, nonatomic) FSUIButton * setUpDownTrend;

@property (nonatomic) int searchNum;
@property (nonatomic) int currentOption;
@property (strong , nonatomic) NSString * gategory;
@property (strong , nonatomic) UIButton * backBtn;
@property (strong, nonatomic) UITextField * titleText;
@property (strong , nonatomic) UIButton * deleteBtn;

@property (strong, nonatomic) UIView *allRectView;
@property (strong, nonatomic) UIView *numberRectView;
@property (strong, nonatomic) UILabel *rangeLabel;
@property (strong, nonatomic) UIView *rectView;
@property (strong , nonatomic)UIView * kBackGroundView;
@property (strong , nonatomic)UIView * kRectView;
@property (strong , nonatomic)UIView * kUpLineView;
@property (strong , nonatomic)UIView * kDownLineView;
@property (strong,nonatomic)NSMutableDictionary * dictionary;
@property (strong,nonatomic)NSMutableDictionary * viewDictionary;
@property (nonatomic)float viewX;

//用來記錄使用者切換到日線、週線還是月線
@property (nonatomic) int storeDWM;
@property (strong , nonatomic) UIView * zeroLineView;
@property (strong , nonatomic) UILabel * zeroPercentLabel;
@property (strong , nonatomic) UILabel * percentLabel;
@property (strong , nonatomic) UILabel * negativePercentLabel;
@property (strong , nonatomic) UILabel * percentLabel1;
@property (strong , nonatomic) UILabel * negativePercentLabel1;
@property (strong , nonatomic) UILabel * percentLabel2;
@property (strong , nonatomic) UILabel * negativePercentLabel2;
@property (nonatomic) float num1;
@property (nonatomic) float num2;

@property (nonatomic)float defaultHeight;
@property(nonatomic)float changeY;
@property (nonatomic)float range;
@property (nonatomic)float negativeRange;

@property (strong, nonatomic) UIColor * kRectUpColor;
@property (strong, nonatomic) UIColor * kRectDownColor;
@property (strong, nonatomic) UIColor * kUpLineColor;
@property (strong, nonatomic) UIColor * kDownLineColor;
@property (strong, nonatomic) UIColor * kRectBorderUpColor;
@property (strong, nonatomic) UIColor * kRectBorderDownColor;

@property (strong)NSMutableArray * canMoveArray;
@property (strong) NSMutableArray * figureSearchArray;

@property (strong) FigureSearchMyProfileModel * customModel;
@property (strong, nonatomic) FSTeachPopView * explainView;
@property (strong, nonatomic) FSTeachPopView * trendExplainView;
@property (strong, nonatomic) FSUIButton * trendCheckBtn;
@property (nonatomic) BOOL firstIn;
@property (nonatomic) BOOL trendFirstIn;
@property (strong, nonatomic) UIButton * closeBtn;
@property (strong, nonatomic) UIButton * trendCloseBtn;


@property (strong, nonatomic) UIAlertView * deleteAlert;
@property (strong, nonatomic) UIAlertView * backAlert;
@property (strong, nonatomic) UIAlertView * deleteOneAlert;
@property (strong, nonatomic) UIAlertView * trendLineBackAlert;
@property (strong, nonatomic) UIAlertView * checkTitleAlert;
@property (strong, nonatomic) UIAlertController *deleteAlertController;
@property (strong, nonatomic) UIAlertController *deleteOneAlertController;
@property (strong, nonatomic) UIAlertController *checkTitleAlertController;

@property (strong, nonatomic) UIView * topView;
@property (strong, nonatomic) UIView * centerView;
@property (strong, nonatomic) UIView * bottomView;

@property (nonatomic) int deleteKbar;
@property (nonatomic) int selectNum;


@property (strong, nonatomic) UILabel * topTitle;
@property (strong, nonatomic) UILabel * centerTitle;
@property (strong, nonatomic) UILabel * bottomTitle;
//bug#10581 wiser start
@property (nonatomic, strong) FSUIButton *checkBtn;
@property (nonatomic, strong) UILabel *checkLabel;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIView *checkView;
//bug#10581 wiser end
@end

@implementation FigureCustomCaseViewController

- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.currentOption = current;
        self.searchNum = searchNumber;
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    if (_currentOption ==0) {
        self.gategory = @"LongSystem";
    }else if (_currentOption ==1){
        self.gategory = @"ShortSystem";
    }else if (_currentOption ==2){
        self.gategory = @"LongCustom";
    }else if (_currentOption ==3){
        self.gategory = @"ShortCustom";
    }
    self.figureSearchArray =[_customModel searchFigureSearchIdWithGategory:self.gategory ItemOrder:[NSNumber numberWithInt:_searchNum]];
    [self setTitle];
    
    if(_firstIn){
        newId =[(NSNumber *)[_figureSearchArray objectAtIndex:0]intValue] *10;
        [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
        for (int i=0; i<5; i++) {
            [_customModel editKbarFigureSearchId:[_figureSearchArray objectAtIndex:0] NewFigureSearchId:[NSNumber numberWithInt:newId] TNumber:[NSNumber numberWithInt:i]];
        }
    }
    _firstIn = NO;
    
    
    [self setDefaultTrendSettingView];
    
    
    int trend = [_customModel searchTrendTypeByFigureSearch_ID:[_figureSearchArray objectAtIndex:0]];
    if(trend!=-1){
        _trendLine=YES;
        if(trend==0){
            _trend=upTrend;
            _selectNum=0;
        }
        else if(trend==1){
            _trend=downTrend;
            _selectNum=1;
        }
        else if(trend==2){
            _trend=flatTrend;
            _selectNum=2;
        }
    }
    
    [self setKLineWidth];
    [self setkBackGroundViewFrame];
  //  [self setKbar];

    [self showTrendLine];
    [self showTeachPop];
    for (int i=0; i<=4; i++) {
        UIView * rectView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d",i]];
        rectView.layer.borderWidth = 2;
    }
//    [self setKbar];
    
    //[self setTitle];
    if (_trendFirstIn) {
        NSString * show = [_customModel searchInstructionByControllerName:[NSString stringWithFormat:@"%@3",[[self class] description]]];
        if ([show isEqualToString:@"YES"]) {
            
            UIView * alertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
            
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 70)];
            label.backgroundColor  = [UIColor clearColor];
            label.numberOfLines = 0;
            label.text = NSLocalizedStringFromTable(@"請由右往左開始編輯一根以上的K棒", @"FigureSearch", nil);
            [alertView addSubview:label];
            
            FSUIButton * checkBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
            [checkBtn setFrame:CGRectMake(0, 80, 40, 40)];
            [checkBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [alertView addSubview:checkBtn];
            
            UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(50, 80, 200, 50)];
            label2.backgroundColor  = [UIColor clearColor];
            label2.numberOfLines = 0;
            label2.text = NSLocalizedStringFromTable(@"下次不顯示此訊息", @"FigureSearch", nil);
            [alertView addSubview:label2];
            
#pragma mark 發生問題的是下方的CXAlertView
//            return;
            CXAlertView * alert = [[CXAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"用戶自定", @"FigureSearch", nil) contentView:alertView cancelButtonTitle:nil];
            alert.contentScrollViewMinHeight = 100;
            [alert.contentView setFrame:CGRectMake(20, 0, 280, 130)];
            [alert addButtonWithTitle:NSLocalizedStringFromTable(@"確認", @"SecuritySearch", nil) type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alert, CXAlertButtonItem *button) {
                if (checkBtn.selected) {
                    [_customModel editInstructionByControllerName:[NSString stringWithFormat:@"%@3",[[self class] description]] Show:@"NO"];
                }else{
                    [_customModel editInstructionByControllerName:[NSString stringWithFormat:@"%@3",[[self class] description]] Show:@"YES"];
                }
                [alert dismiss];
            }];
            
            [alert show];
        }
        _trendFirstIn = NO;
    }
    
//    if (_trendFirstIn) {
//        NSString * show = [_customModel searchInstructionByControllerName:[NSString stringWithFormat:@"%@1",[[self class] description]]];
//        if ([show isEqualToString:@"YES"]) {
//            [self trendTeachPop];
//        }
//        _trendFirstIn = NO;
//    }

}

//bug#10581 wiser start
- (void)showHint
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCheckBox)];
    
    hintAlertView = [[CustomIOS7AlertView alloc]init];
    UIView * view;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width-30, 90)];
    }
    else {
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width-30, 60)];
    }
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width-30, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    [label setNumberOfLines:2];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    label.text = NSLocalizedStringFromTable(@"我的型態", @"FigureSearch", nil);
    [hintAlertView setTitleLabel:label];
    [hintAlertView setContainerView:view];
    [hintAlertView setButtonTitles:@[NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil)]];
    hintAlertView.delegate = self;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,view.frame.size.width, 60)];
        _checkView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, view.frame.size.width, 30)];
    }
    else {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,view.frame.size.width, 30)];
        _checkView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, view.frame.size.width, 30)];
    }
    
    [_msgLabel setFont:[UIFont boldSystemFontOfSize:16]];
    _msgLabel.backgroundColor = [UIColor whiteColor];
    [_msgLabel setNumberOfLines:2];
    _msgLabel.text = NSLocalizedStringFromTable(@"請由右往左開始編輯一根以上的K棒", @"FigureSearch", nil);
    [view addSubview:_msgLabel];
    
    _checkView.backgroundColor = [UIColor whiteColor];
    _checkView.userInteractionEnabled = YES;
    [_checkView addGestureRecognizer:tapGestureRecognizer];
    [view addSubview:_checkView];
    
    _checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, _checkView.frame.size.width-30, 30)];
    [_checkLabel setFont:[UIFont boldSystemFontOfSize:16]];
    _checkLabel.text = NSLocalizedStringFromTable(@"下次不顯示此信息", @"FigureSearch", nil);
    [_checkView addSubview:_checkLabel];
    
    
    _checkBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    [_checkBtn addTarget:self action:@selector(tapCheckBox) forControlEvents:UIControlEventTouchUpInside];
    _checkBtn.frame = CGRectMake(0, 0, 30, 30);
    [_checkView addSubview:_checkBtn];
    
    [hintAlertView show];
    
}
-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [hintAlertView close];
}

-(void)tapCheckBox
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(_checkBtn.selected){
        [userDefaults setBool:NO forKey:@"Don't show?"];
        [userDefaults synchronize];
        _checkBtn.selected = NO;
        
    }else{
        [userDefaults setBool:YES forKey:@"Don't show?"];
        [userDefaults synchronize];
        _checkBtn.selected = YES;
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL dont_show = [userDefaults boolForKey:@"Don't show?"];
    //NSLog(@"Dont'Show? %@",dont_show?@"YES":@"NO");
    //printf("======From MyFigureSearchViewController? %s=======\n",_firstTimeFlag?"YES":"NO");
    if(_firstTimeFlag ==YES && dont_show == NO){//從我的型態MyFigureSearchViewController進來的
        //且don't show next time沒被打勾
        [self showHint];
        _firstTimeFlag = NO;
    }
   // [self setKbar];
}
//bug#10581 wiser end

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//-(void)viewWillDisappear:(BOOL)animated{
//    for (int i=0; i<5; i++) {
//        
//        UIView * rectView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d",i]];
//        UIView * lineView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kLineView%d",i]];
//        
//        float high = lineView.frame.origin.y;
//        float low = lineView.frame.origin.y+lineView.frame.size.height;
//        float open;
//        float close;
//        
//        if ([rectView.backgroundColor isEqual:[UIColor redColor]]) {
//            open = rectView.frame.origin.y;
//            close = rectView.frame.origin.y+rectView.frame.size.height;
//        }else{
//            close = rectView.frame.origin.y;
//            open = rectView.frame.origin.y+rectView.frame.size.height;
//        }
//        //NSLog(@"H:%f ,L:%f ,O:%f ,C:%f ",(_range*2+1-high/_defaultHeight)/100,(_range*2+1-low/_defaultHeight)/100,(_range*2+1-open/_defaultHeight)/100,(_range*2+1-close/_defaultHeight)/100);
//        
//        //save the new value
//    }
//    
//    
//    
//    [super viewWillDisappear:animated];
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dictionary = [[NSMutableDictionary alloc]init];
    self.viewDictionary = [[NSMutableDictionary alloc]init];
    self.canMoveArray = [[NSMutableArray alloc]init];
    self.figureSearchArray = [[NSMutableArray alloc]init];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    _analysisPeriod = 0;
    [self setKLineWidth];
    [self initTitle];
    [self initView];
    [self initTrendSettinfView];
    _trendSettingView.hidden = YES;
    _titleText.userInteractionEnabled = YES;
    [self setLayout];
    [self setTrendViewLayout];
    _firstIn = YES;
    _trendFirstIn = YES;
	// Do any additional setup after loading the view.

    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_percentLabel,_negativePercentLabel,_percentLabel1,_negativePercentLabel1,_percentLabel2,_negativePercentLabel2);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_percentLabel(45)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_negativePercentLabel(45)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_percentLabel1(45)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel1 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_negativePercentLabel1(45)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_percentLabel2(45)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel2 attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_negativePercentLabel2(45)]" options:0 metrics:nil views:viewControllers]];
}

-(void)showTeachPop{
    if (_firstIn) {
        NSString * show = [_customModel searchInstructionByControllerName:[NSString stringWithFormat:@"%@2",[[self class] description]]];
        if ([show isEqualToString:@"YES"]) {
            [self teachPop];
        }
        _firstIn = NO;
    }
}

-(void)initTrendSettinfView{
    self.trendSettingView = [[UIView alloc]init];
    _trendSettingView.translatesAutoresizingMaskIntoConstraints = NO;
    _trendSettingView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_trendSettingView];
    
    self.topView = [[UIView alloc] init];
    _topView.layer.borderWidth = 1.0f;
    _topView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    _topView.translatesAutoresizingMaskIntoConstraints = NO;
    [_trendSettingView addSubview:_topView];
    
    self.centerView = [[UIView alloc] init];
    _centerView.layer.borderWidth = 1.0f;
    _centerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    _centerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_trendSettingView addSubview:_centerView];
    
    self.bottomView = [[UIView alloc] init];
    _bottomView.layer.borderWidth = 1.0f;
    _bottomView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [_trendSettingView addSubview:_bottomView];
    
    self.textLabel = [[UILabel alloc]init];
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.text =NSLocalizedStringFromTable(@"設定趨勢線", @"FigureSearch", nil);
    _textLabel.numberOfLines = 2;
    [_trendSettingView addSubview:_textLabel];
    
    self.upLineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _upLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_upLineBtn setImage:[UIImage imageNamed:@"upLineBtn"] forState:UIControlStateNormal];
    [_upLineBtn setAlpha:0.2f];
    [_upLineBtn addTarget:self action:@selector(trendSettingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_upLineBtn];
    
    self.downLineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _downLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_downLineBtn setImage:[UIImage imageNamed:@"downLineBtn"] forState:UIControlStateNormal];
    [_downLineBtn setAlpha:0.2f];
    [_downLineBtn addTarget:self action:@selector(trendSettingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_centerView addSubview:_downLineBtn];
    
    self.upDownLineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _upDownLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_upDownLineBtn setImage:[UIImage imageNamed:@"upDownLineBtn"] forState:UIControlStateNormal];
    [_upDownLineBtn setAlpha:0.2f];
    [_upDownLineBtn addTarget:self action:@selector(trendSettingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_upDownLineBtn];
    
    self.skipBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenButton];
    _skipBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_skipBtn setTitle:NSLocalizedStringFromTable(@"跳過", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_skipBtn addTarget:self action:@selector(trendSettingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_trendSettingView addSubview:_skipBtn];
    
    self.doneBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenButton];
    _doneBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_doneBtn setTitle:NSLocalizedStringFromTable(@"確定2", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(trendSettingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_trendSettingView addSubview:_doneBtn];
   
    //upLineSlider
    self.upLineSlider = [[UISlider alloc]init];
    _upLineSlider.translatesAutoresizingMaskIntoConstraints = NO;
    _upLineSlider.minimumTrackTintColor = [UIColor colorWithRed:27.0f/255.0f green:158.0f/255.0f blue:79.0f/255.0f alpha:1.0f];
    _upLineSlider.minimumValue = 5;
    _upLineSlider.maximumValue = 60;
    _upLineSlider.enabled = NO;
    
    [_upLineSlider addTarget:self action:@selector(sliderMove:) forControlEvents:UIControlEventValueChanged];
    [_topView addSubview:_upLineSlider];
    
    
    self.upZeroLabel = [[UILabel alloc]init];
    _upZeroLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _upZeroLabel.text = @"5";
    [_topView addSubview:_upZeroLabel];
    
    self.upSixtyLabel = [[UILabel alloc]init];
    _upSixtyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _upSixtyLabel.text = @"60";
    [_topView addSubview:_upSixtyLabel];
    
    self.upTextLabel = [[UILabel alloc]init];
    _upTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_topView addSubview:_upTextLabel];
    
    self.topTitle = [[UILabel alloc] init];
    _topTitle.text = NSLocalizedStringFromTable(@"上漲趨勢", @"FigureSearch", nil);
    _topTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [_topView addSubview:_topTitle];
    
    //downLineSlider
    self.downLineSlider = [[UISlider alloc]init];
    _downLineSlider.translatesAutoresizingMaskIntoConstraints = NO;
    _downLineSlider.minimumTrackTintColor = [UIColor redColor];
    _downLineSlider.minimumValue = 5;
    _downLineSlider.maximumValue = 60;
    _downLineSlider.enabled = NO;
    
    [_downLineSlider addTarget:self action:@selector(sliderMove:) forControlEvents:UIControlEventValueChanged];
    [_centerView addSubview:_downLineSlider];
    
    
    self.downZeroLabel = [[UILabel alloc]init];
    _downZeroLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _downZeroLabel.text = @"5";
    [_centerView addSubview:_downZeroLabel];
    
    self.downSixtyLabel = [[UILabel alloc]init];
    _downSixtyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _downSixtyLabel.text = @"60";
    [_centerView addSubview:_downSixtyLabel];
    
    self.downTextLabel = [[UILabel alloc]init];
    _downTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_centerView addSubview:_downTextLabel];
    
    self.centerTitle = [[UILabel alloc] init];
    _centerTitle.text = NSLocalizedStringFromTable(@"下跌趨勢", @"FigureSearch", nil);
    _centerTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [_centerView addSubview:_centerTitle];
    
    
    //upDownLineSlider
    self.upDownLineSlider = [[UISlider alloc]init];
    _upDownLineSlider.translatesAutoresizingMaskIntoConstraints = NO;
    _upDownLineSlider.minimumTrackTintColor = [UIColor blueColor];
    _upDownLineSlider.minimumValue = 5;
    _upDownLineSlider.maximumValue = 60;
    _upDownLineSlider.enabled = NO;
    
    [_upDownLineSlider addTarget:self action:@selector(sliderMove:) forControlEvents:UIControlEventValueChanged];
    [_bottomView addSubview:_upDownLineSlider];
    
    
    self.upDownZeroLabel = [[UILabel alloc]init];
    _upDownZeroLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _upDownZeroLabel.text = @"5";
    [_bottomView addSubview:_upDownZeroLabel];
    
    self.upDownSixtyLabel = [[UILabel alloc]init];
    _upDownSixtyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _upDownSixtyLabel.text = @"60";
    [_bottomView addSubview:_upDownSixtyLabel];
    
    self.upDownTextLabel = [[UILabel alloc]init];
    _upDownTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _upDownTextLabel.numberOfLines = 2;
    [_bottomView addSubview:_upDownTextLabel];
    
    self.setUpDownTrend = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _setUpDownTrend.enabled = NO;
    [_setUpDownTrend setAlpha:0.2f];
    _setUpDownTrend.translatesAutoresizingMaskIntoConstraints = NO;
    [_setUpDownTrend addTarget:self action:@selector(setFlatTrend) forControlEvents:UIControlEventTouchUpInside];
    [_setUpDownTrend setTitle:NSLocalizedStringFromTable(@"設定", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_bottomView addSubview:_setUpDownTrend];
    
    self.bottomTitle = [[UILabel alloc] init];
    _bottomTitle.text = NSLocalizedStringFromTable(@"橫盤整理", @"FigureSearch", nil);
    _bottomTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [_bottomView addSubview:_bottomTitle];
    
}

-(void)setDefaultTrendSettingView{
    NSMutableArray * trendValue = [_customModel searchTrendValueByFigureSearch_ID:[_figureSearchArray objectAtIndex:0]];
    if ([trendValue count]==0) {
        [trendValue addObject:[NSNumber numberWithInt:5]];
        [trendValue addObject:[NSNumber numberWithInt:5]];
        [trendValue addObject:[NSNumber numberWithInt:5]];
    }
    _upLineSlider.value = [(NSNumber *)[trendValue objectAtIndex:0]floatValue];
    _upTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Up trend", @"FigureSearch", nil),[(NSNumber *)[trendValue objectAtIndex:0]floatValue]];
    _downLineSlider.value = [(NSNumber *)[trendValue objectAtIndex:1]floatValue];
    _downTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Down trend", @"FigureSearch", nil),[(NSNumber *)[trendValue objectAtIndex:1]floatValue]];
    _upDownLineSlider.value = [(NSNumber *)[trendValue objectAtIndex:2]floatValue];
    _upDownTextLabel.text =[NSString stringWithFormat:NSLocalizedStringFromTable(@"Flat trend", @"FigureSearch", nil),[(NSNumber *)[trendValue objectAtIndex:2]floatValue]];
    int trend = [_customModel searchTrendTypeByFigureSearch_ID:[_figureSearchArray objectAtIndex:0]];
    _oldTrend = trend;
    
    if (_selectNum==0) {
        [_upLineBtn setAlpha:1.0f];
        _topView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        _upLineBtn.selected = YES;
        _upLineSlider.enabled = YES;
    }else if (_selectNum==1){
        [_downLineBtn setAlpha:1.0f];
        _centerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        _downLineBtn.selected = YES;
        _downLineSlider.enabled = YES;
    }else if (_selectNum==2){
        _upDownLineBtn.selected = YES;
        [_upDownLineBtn setAlpha:1.0f];
        _bottomView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
        _upDownLineSlider.enabled = YES;
        [_setUpDownTrend setAlpha:1.0f];
        _setUpDownTrend.enabled = YES;
    }
}

-(void)sliderMove:(UISlider*)slider{
    
    if ([slider isEqual:_upLineSlider]) {
        _upTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Up trend", @"FigureSearch", nil),slider.value];
    }else if ([slider isEqual:_downLineSlider]){
        _downTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Down trend", @"FigureSearch", nil),slider.value];
    }else if ([slider isEqual:_upDownLineSlider]){
        _upDownTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"Flat trend", @"FigureSearch", nil),slider.value];
    }
}

-(void)trendSettingBtnClick:(UIButton *)btn{

    if ([btn isEqual:_skipBtn]) {
        _trendSettingView.hidden = YES;
        _titleText.userInteractionEnabled = YES;
        _trendLine = NO;
        [_customModel editTrendValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] UpLine:[NSNumber numberWithFloat:_upLineSlider.value] DownLine:[NSNumber numberWithFloat:_downLineSlider.value] FlatLine:[NSNumber numberWithFloat:_upDownLineSlider.value]];
        [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:-1]];
        [self setKLineWidth];
        [self setkBackGroundViewFrame];
        [self setKbar];
        [self showTrendLine];
//        [self showTeachPop];
        for (int i=0; i<=4; i++) {
            UIView * rectView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d",i]];
            rectView.layer.borderWidth = 2;
        }
     }else if ([btn isEqual:_doneBtn]){
        if (_upLineBtn.selected) {
            _trend = upTrend;
            _trendLine = YES;
            [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:0]];
            _selectNum = 0;
        }
        if (_downLineBtn.selected) {
            _trend = downTrend;
            _trendLine = YES;
            [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:1]];
            _selectNum = 1;
        }
        if (_upDownLineBtn.selected) {
            _trend = flatTrend;
            _trendLine = YES;
            [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:2]];
            _selectNum = 2;
        }
        _trendSettingView.hidden = YES;
         _titleText.userInteractionEnabled = YES;
        [_customModel editTrendValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] UpLine:[NSNumber numberWithFloat:_upLineSlider.value] DownLine:[NSNumber numberWithFloat:_downLineSlider.value] FlatLine:[NSNumber numberWithFloat:_upDownLineSlider.value]];
        [self setKLineWidth];
        [self setkBackGroundViewFrame];
        [self setKbar];
        [self showTrendLine];
        [self showTeachPop];
        for (int i=0; i<=4; i++) {
            UIView * rectView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d",i]];
            rectView.layer.borderWidth = 2;
        }
    }else{
        _upLineSlider.enabled = NO;
        _downLineSlider.enabled = NO;
        _upDownLineSlider.enabled = NO;
        _setUpDownTrend.enabled = NO;
        _upLineBtn.selected = NO;
        _downLineBtn.selected = NO;
        _upDownLineBtn.selected = NO;
        
        _topView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
        _centerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
        _bottomView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
        [_upLineBtn setAlpha:0.2f];
        [_downLineBtn setAlpha:0.2f];
        [_upDownLineBtn setAlpha:0.2f];
        [_setUpDownTrend setAlpha:0.2f];
        
        if ([btn isEqual:_upLineBtn]) {
            _upLineSlider.enabled = YES;
            _upLineBtn.selected = YES;
            _topView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
            [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:0]];
            _selectNum = 0;
        }else if ([btn isEqual:_downLineBtn]){
            _downLineSlider.enabled = YES;
            _downLineBtn.selected = YES;
            _centerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
            [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:1]];
            _selectNum = 1;
        }else if ([btn isEqual:_upDownLineBtn]){
            _upDownLineSlider.enabled = YES;
            _upDownLineBtn.selected = YES;
             _bottomView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
            [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:2]];
            _selectNum = 2;
            _setUpDownTrend.enabled = YES;
            [_setUpDownTrend setAlpha:1.0f];
        }
        [btn setAlpha:1.0f];
    }
    
    if ([btn isEqual:_skipBtn] || [btn isEqual:_doneBtn]) {
        _deleteBtn.hidden = NO;

    }
}

-(void)checkBtnClick:(FSUIButton*)btn{
    btn.selected = !btn.selected;
    
}

-(void)setFlatTrend{
    FigureSetFlatTrendViewController * flatTrenfView = [[FigureSetFlatTrendViewController alloc]initWithGategory:_gategory SearchNum:_searchNum];
    [self.navigationController pushViewController:flatTrenfView animated:NO];
}
-(void)showTrendLine{
    _upLineImage.hidden = YES;
    _downLineImage.hidden = YES;
    _flatLineImage.hidden = YES;
    if (_trendLine) {
        if (_trend==upTrend) {
            _upLineImage.hidden = NO;
        }else if (_trend == downTrend){
            _downLineImage.hidden = NO;
        }else if (_trend == flatTrend){
            _flatLineImage.hidden = NO;
        }
    }
}

-(void)setKLineWidth{
    if (_trendLine) {
        _kRectWidth = 30;
    }else{
        _kRectWidth = 50;
    }
}

- (void)setLayout {
    
    //[self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_backBtn,_titleText,_deleteBtn,_allRectView,_numberRectView,_rectView,_zeroLineView,_trendBtn,_storeBtn,_upLineImage,_flatLineImage,_rangeLabel);
    
    if ([FSUtility isGraterThanSupportVersion:7]) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-23-[_backBtn(44)]-3-[_allRectView]-2-[_trendBtn(40)]-2-|" options:0 metrics:nil views:viewControllers]];
    }else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_backBtn(44)]-3-[_allRectView]-2-[_trendBtn(40)]-2-|" options:0 metrics:nil views:viewControllers]];
    }
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_backBtn(44)]-15-[_titleText]-15-[_deleteBtn(44)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.allRectView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_rectView][_numberRectView(45)]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_allRectView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.allRectView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-35-[_rectView]-20-|" options:0 metrics:nil views:viewControllers]];
    [self.allRectView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_numberRectView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rangeLabel(15)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_rangeLabel]|" options:0 metrics:nil views:viewControllers]];


    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_storeBtn(40)]-2-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_storeBtn(80)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_trendBtn(130)]-5-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_zeroLineView(1)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_zeroLineView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_zeroLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_zeroLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-1]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_zeroPercentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];

    
    //upLineImg
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upLineImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upLineImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1 constant:-20]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_upLineImage(150)]" options:0 metrics:nil views:viewControllers]];
    
    //downLineImg
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downLineImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downLineImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1 constant:-20]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_downLineImage(150)]" options:0 metrics:nil views:viewControllers]];
    
    //upDownLineImg
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_flatLineImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_flatLineImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_flatLineImage(100)]" options:0 metrics:nil views:viewControllers]];
    
    
    

    //[super updateViewConstraints];
}

-(void)setTrendViewLayout{
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_backBtn,_trendSettingView,_textLabel,_upLineBtn,_downLineBtn,_upDownLineBtn,_skipBtn,_doneBtn,_upLineSlider,_upZeroLabel,_upSixtyLabel,_upTextLabel,_downLineSlider,_downZeroLabel,_downSixtyLabel,_downTextLabel,_upDownLineSlider,_upDownZeroLabel,_upDownSixtyLabel,_upDownTextLabel,_setUpDownTrend, _topView, _centerView, _bottomView);
    
    //設定趨勢線頁
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_backBtn(44)]-3-[_trendSettingView]-2-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_trendSettingView]|" options:0 metrics:nil views:viewControllers]];

    if (self.view.frame.size.height > 480) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_textLabel(33)][_topView]-5-[_centerView(_topView)]-5-[_bottomView(_topView)]-5-[_skipBtn(35)]-2-|" options:0 metrics:nil views:viewControllers]];
    }
    else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textLabel][_topView(99)]-5-[_centerView(99)]-5-[_bottomView(130)]-5-[_skipBtn(35)]-2-|" options:0 metrics:nil views:viewControllers]];
    }
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_textLabel]-15-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_topView]-15-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_centerView]-15-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_bottomView]-15-|" options:0 metrics:nil views:viewControllers]];
    
    
    //upLineSlider
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_upLineSlider]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_upTextLabel(30)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[_upLineBtn(60)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_upLineBtn(80)]-10-[_upLineSlider]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upZeroLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_upLineSlider attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upZeroLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_upLineSlider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upSixtyLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_upLineSlider attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upSixtyLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_upLineSlider attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_upLineSlider attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_upLineSlider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upTextLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_upLineSlider attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_topTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_upLineBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_topTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_upLineBtn attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    
    //downLineSlider
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_downLineSlider]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[_downLineBtn(60)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_downLineBtn(80)]-10-[_downLineSlider]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downZeroLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_downLineSlider attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downZeroLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_downLineSlider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downSixtyLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_downLineSlider attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downSixtyLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_downLineSlider attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_downLineSlider attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_downTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_downLineSlider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_centerTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_downLineBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_centerTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_downLineBtn attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    //upDownLineSlider
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_upDownLineSlider]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upDownLineBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_upDownLineBtn.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_upDownLineBtn(80)]-10-[_upDownLineSlider]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_upDownTextLabel(120)]" options:0 metrics:nil views:viewControllers]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_upDownTextLabel(50)][_setUpDownTrend(33)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_setUpDownTrend attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_upDownZeroLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_setUpDownTrend attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_upDownZeroLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-20]];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_setUpDownTrend(130)]" options:0 metrics:nil views:viewControllers]];
    }
    else{
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_setUpDownTrend(80)]" options:0 metrics:nil views:viewControllers]];
    }
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_setUpDownTrend(30)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upDownZeroLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upDownZeroLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upDownSixtyLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upDownSixtyLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upDownTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_upDownTextLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomTitle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_upDownLineBtn attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomTitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_upDownLineBtn attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];

    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_setUpDownTrend attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_setUpDownTrend attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_upDownLineSlider attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_doneBtn(==_skipBtn)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-85-[_skipBtn(80)]-3-[_doneBtn(==_skipBtn)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
}



-(void)viewDidLayoutSubviews{
    if (_changeNameFlag) {
        _changeNameFlag = NO;
    }else{
        [self.upLineImage setFrame:CGRectMake(-20,_allRectView.frame.size.height/2+10, 150, _allRectView.frame.size.height/2-45)];
        [self.downLineImage setFrame:CGRectMake(-20, -10, 150, _allRectView.frame.size.height/2-55)];
        [self.flatLineImage setFrame:CGRectMake(0, (_allRectView.frame.size.height/2)-_allRectView.frame.origin.y-55, 100, 150)];
        
        
        self.defaultHeight = (_allRectView.frame.size.height-15)/22;
        float percentNum =10*_defaultHeight;
        float percent1Num = 4*_defaultHeight;
        float percent2Num = 8*_defaultHeight;
        printf("%f %f\n",_defaultHeight,_allRectView.frame.size.height);
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_rectView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:percentNum*-1]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:percentNum]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(percent1Num*-1)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel1 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:percent1Num]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_percentLabel2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(percent2Num*-1)]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_negativePercentLabel2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_zeroPercentLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:percent2Num]];
        
        float width,height;
        double version = [[UIDevice currentDevice].systemVersion doubleValue];
        if(version>=8.0f){
            width = _rectView.frame.size.width;
            height = _rectView.frame.size.height;
        }else{
            NSLog(@"width:%f height:%f",self.view.frame.size.width,self.view.frame.size.height);
            width = self.view.frame.size.width-50;
            height = self.view.frame.size.height-160;
        }

        
        for (int i=0; i<5; i++) {
            UIView * view =[_viewDictionary objectForKey:[NSString stringWithFormat:@"_kBackGroundView%d",i]];
            view.frame = CGRectMake(width-i*(_kRectWidth+3)-(_kRectWidth+3), 0, _kRectWidth, height);
            
        }
        
       
        [self.view layoutSubviews];
        
        [self setKbar];
        
    }
    
    
}
-(void)setLabelText{
    float num  = 1;
    if ((_analysisPeriod % 3) ==0) {
        num = 1;
        _storeDWM = FSFigureDWMForD;
    }else if ((_analysisPeriod % 3) ==1) {
        _storeDWM = FSFigureDWMForW;
        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);;
    }else{
        _storeDWM = FSFigureDWMForM;
        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
    }

    
    if(_range>10){
        _percentLabel.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10 *num];
        _negativePercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*num];
        
        _percentLabel1.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(2.0f/5.0f)*num];
        _negativePercentLabel1.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(2.0f/5.0f)*num];
        
        _percentLabel2.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(4.0f/5.0f)*num];
        _negativePercentLabel2.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(4.0f/5.0f)*num];
    }
    else{
        _percentLabel.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*num];
        _negativePercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*num];
        
        _percentLabel1.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(2.0f/5.0f)*num];
        _negativePercentLabel1.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(2.0f/5.0f)*num];
        
        _percentLabel2.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(4.0f/5.0f)*num];
        _negativePercentLabel2.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(4.0f/5.0f)*num];
    }
//_changeNameFlag = YES;
//_analysisPeriod+=1;
//float num  = 1;
//if ((_analysisPeriod % 3) ==0) {
//    num = 1;
//    _storeDWM = FSFigureDWMForD;
//    _rangeLabel.text = NSLocalizedStringFromTable(@"Daily",@"Draw",@"");
//}else if ((_analysisPeriod % 3) ==1) {
//    _storeDWM = FSFigureDWMForW;
//    num = ([(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);;
//    _rangeLabel.text = NSLocalizedStringFromTable(@"Weekly",@"Draw",@"");
//}else{
//    _storeDWM = FSFigureDWMForM;
//    num = ([(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
//    _rangeLabel.text = NSLocalizedStringFromTable(@"Monthly",@"Draw",@"");
//}
//_percentLabel.text = [NSString stringWithFormat:@"-%.1f%%",_range*num];
//_negativePercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",_range*num];
//_percentLabel1.text = [NSString stringWithFormat:@"-%.1f%%",_range*(2.0f/5.0f)*num];
//_negativePercentLabel1.text = [NSString stringWithFormat:@"--%.1f%%",_range*(2.0f/5.0f)*num];
//
//_percentLabel2.text = [NSString stringWithFormat:@"-%.1f%%",_range*(4.0f/5.0f)*num];
//_negativePercentLabel2.text = [NSString stringWithFormat:@"--%.1f%%",_range*(4.0f/5.0f)*num];
}

-(void)setkBackGroundViewFrame{
    float width,height;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if(version>=8.0f){
        width = _rectView.frame.size.width;
        height = _rectView.frame.size.height;
    }else{
        NSLog(@"width:%f height:%f",self.view.frame.size.width,self.view.frame.size.height);
        width = self.view.frame.size.width-50;
        height = self.view.frame.size.height-160;
    }
    for (int i=0; i<5; i++) {
        UIView * view =[_viewDictionary objectForKey:[NSString stringWithFormat:@"_kBackGroundView%d",i]];
        view.frame = CGRectMake(width-i*(_kRectWidth+3)-(_kRectWidth+3), 0, _kRectWidth, height);
        
    }
}

-(void)setTitle{
    _titleText.text = [_figureSearchArray objectAtIndex:1];
}

-(void)setKbar{
    _range =0.0f;
    _negativeRange=0.0f;
    
    
    [_canMoveArray removeAllObjects];
    
    int figureSearchId = newId;//[(NSNumber *)[_figureSearchArray objectAtIndex:0]intValue];
    float zero = 0.0f;
    for (int i=4; i>=0; i--) { // 掃過所有K棒的high,low找上下極值
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        dataArray = [_customModel searchCustomKbarWithFigureSearchId:[NSNumber numberWithInt:figureSearchId] TNumber:[NSNumber numberWithInt:i]];
        if (![dataArray count]==0) {//不為空 有存k棒
            if (([(NSNumber *)[dataArray objectAtIndex:0]floatValue]+zero)*100>_range) {//這一天的high是否超過上極值
                _range = ([(NSNumber *)[dataArray objectAtIndex:0]floatValue]+zero)*100;
            }
            if (([(NSNumber *)[dataArray objectAtIndex:1]floatValue]+zero)*100<_negativeRange) {//這一天的low是否低於下極值
                _negativeRange = ([(NSNumber *)[dataArray objectAtIndex:1]floatValue]+zero)*100;
            }
            zero +=[(NSNumber *)[dataArray objectAtIndex:3]floatValue];//這一天的close收盤價為下一天的0%起點
        }
    }
    printf("range=%f , negative range=%f\n",_range,_negativeRange);
//    if (_range>0) {
        _range = fabs(_range); //絕對值
//    }else{
//        _range = abs(floorf(_range));
//    }
//    if (_negativeRange>0) {
        _negativeRange = fabs(_negativeRange);
//    }else{
//        _negativeRange = abs(floorf(_negativeRange));
//    }
    _range = MAX(_range,_negativeRange);//上下極值比較
    //_range = [(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]/2;
    //_range = [(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]/2;
        printf("range=%f\n",_range);
    [self setLabelText];
//    [self setTitle];
    float defaultZero =0.0f;
    for (int i=4; i>=0; i--) {
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        dataArray = [_customModel searchCustomKbarWithFigureSearchId:[NSNumber numberWithInt:newId] TNumber:[NSNumber numberWithInt:i]];
        
        UIView * rectView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d",i]];
        UIView * upLineView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kUpLineView%d",i]];
        UIView * downLineView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kDownLineView%d",i]];
        
        if (![dataArray count]==0) { //不為空
            [self setDefaultColorWithkNumber:i];
            
            float width,height;
            double version = [[UIDevice currentDevice].systemVersion doubleValue];
            if(version>=8.0f){
                width = _rectView.frame.size.width;
                height = _rectView.frame.size.height;
            }else{
                NSLog(@"width:%f height:%f",self.view.frame.size.width,self.view.frame.size.height);
                width = self.view.frame.size.width-50;
                height = self.view.frame.size.height-160;
            }
//            self.defaultHeight = height/(_range*4);
//            float high = (_range*2-([(NSNumber *)[dataArray objectAtIndex:0]floatValue]+defaultZero)*100)*_defaultHeight;
//            float low = (_range*2-([(NSNumber *)[dataArray objectAtIndex:1]floatValue]+defaultZero)*100)*_defaultHeight;
//            float open = (_range*2-([(NSNumber *)[dataArray objectAtIndex:2]floatValue]+defaultZero)*100)*_defaultHeight;
//            float close = (_range*2-([(NSNumber *)[dataArray objectAtIndex:3]floatValue]+defaultZero)*100)*_defaultHeight;
            //rectView在allRectView裡面 扣除numberRectView跟上下部分多出非range的空間
            printf("%f\n",_rectView.frame.size.height);
            float high =_rectView.frame.size.height/2 -([(NSNumber *)[dataArray objectAtIndex:0]floatValue]+defaultZero)*100* _rectView.frame.size.height/20 ;
            float low = _rectView.frame.size.height/2 -([(NSNumber *)[dataArray objectAtIndex:1]floatValue]+defaultZero)*100* _rectView.frame.size.height/20;
            float open =_rectView.frame.size.height/2 -([(NSNumber *)[dataArray objectAtIndex:2]floatValue]+defaultZero)*100* _rectView.frame.size.height/20;
            float close=_rectView.frame.size.height/2 -([(NSNumber *)[dataArray objectAtIndex:3]floatValue]+defaultZero)*100* _rectView.frame.size.height/20;
            if(_range>10){
                high  =_rectView.frame.size.height/2 - ([(NSNumber *)[dataArray objectAtIndex:0]floatValue]+defaultZero)*100* _rectView.frame.size.height/20*10/_range ;
                low   =_rectView.frame.size.height/2 - ([(NSNumber *)[dataArray objectAtIndex:1]floatValue]+defaultZero)*100* _rectView.frame.size.height/20*10/_range ;
                open  =_rectView.frame.size.height/2 - ([(NSNumber *)[dataArray objectAtIndex:2]floatValue]+defaultZero)*100* _rectView.frame.size.height/20*10/_range ;
                close =_rectView.frame.size.height/2 - ([(NSNumber *)[dataArray objectAtIndex:3]floatValue]+defaultZero)*100* _rectView.frame.size.height/20*10/_range ;
            }
            if (open>close) {
                rectView.frame = CGRectMake(width-i*(_kRectWidth+3)-(_kRectWidth+3), close, _kRectWidth, open-close);
                rectView.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
                rectView.backgroundColor = _kRectUpColor;
                rectView.layer.borderColor = _kRectBorderUpColor.CGColor;
                upLineView.frame = CGRectMake(rectView.center.x-1.5, high, 5, close-high);
                downLineView.frame = CGRectMake(rectView.center.x-1.5, open, 5, low-open);
            }else if (close>open){
                rectView.frame = CGRectMake(width-i*(_kRectWidth+3)-(_kRectWidth+3), open, _kRectWidth, close-open);
                rectView.backgroundColor = _kRectDownColor;
                rectView.layer.borderColor = _kRectBorderDownColor.CGColor;
                upLineView.frame = CGRectMake(rectView.center.x-1.5, high, 5, open-high);
                downLineView.frame = CGRectMake(rectView.center.x-1.5, close, 5, low-close);
            }else{
                rectView.frame = CGRectMake(width-i*(_kRectWidth+3)-(_kRectWidth+3), open, _kRectWidth, 3);
                rectView.backgroundColor = [UIColor blueColor];
                rectView.layer.borderColor = [UIColor blueColor].CGColor;
                upLineView.frame = CGRectMake(rectView.center.x-1.5, high, 5, close-high);
                downLineView.frame = CGRectMake(rectView.center.x-1.5, open, 5, low-open);
            }
            
            rectView.layer.borderWidth = 2;
            
            [_canMoveArray addObject:@"YES"];
            defaultZero +=[(NSNumber *)[dataArray objectAtIndex:3]floatValue];
            upLineView.backgroundColor = _kUpLineColor;
            downLineView.backgroundColor = _kDownLineColor;
        }else{ //沒有值
            float width,height;
            double version = [[UIDevice currentDevice].systemVersion doubleValue];
            if(version>=8.0f){
                width = _rectView.frame.size.width;
                height = _rectView.frame.size.height;
            }else{
                NSLog(@"width:%f height:%f",self.view.frame.size.width,self.view.frame.size.height);
                width = self.view.frame.size.width-50;
                height = self.view.frame.size.height-160;
            }
            
            rectView.frame = CGRectMake(width-i*(_kRectWidth+3)-(_kRectWidth+3), height/2-50, _kRectWidth, 100);
            rectView.layer.borderColor = [UIColor blackColor].CGColor;
            if (_firstIn) {
                rectView.layer.borderWidth = 0;
            }else{
                rectView.layer.borderWidth = 2;
            }
            
            rectView.backgroundColor = [UIColor clearColor];
            upLineView.backgroundColor = [UIColor lightGrayColor];
            downLineView.backgroundColor = [UIColor lightGrayColor];
            upLineView.frame = CGRectMake(rectView.center.x-1.5, rectView.center.y-100, 5, 50);
            downLineView.frame = CGRectMake(rectView.center.x-1.5, rectView.center.y+50, 5, 50);
            
            [_canMoveArray addObject:@"NO"];
        }
    }
}


-(void)initTitle{
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_backBtn];
    
    self.titleText = [[UITextField alloc]init];
    _titleText.translatesAutoresizingMaskIntoConstraints = NO;
    _titleText.borderStyle = UITextBorderStyleRoundedRect;
    _titleText.textAlignment = NSTextAlignmentCenter;
    _titleText.font = [UIFont systemFontOfSize:22.0f];
    _titleText.delegate = self;
//    _titleText.userInteractionEnabled = NO;
    [self.view addSubview:_titleText];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setImage:[UIImage imageNamed:@"RedDeleteButton"] forState:UIControlStateNormal];
    _deleteBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_deleteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    
}

-(void)initView{
    self.allRectView = [[UIView alloc] init];
    self.allRectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.allRectView.layer.borderColor = [UIColor blackColor].CGColor;
    self.allRectView.layer.borderWidth = 1;
    [self.view addSubview:self.allRectView];
    
    self.numberRectView = [[UIView alloc] init];
    self.numberRectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberRectView.layer.borderColor = [UIColor blackColor].CGColor;
    self.numberRectView.layer.borderWidth = 1;
    self.numberRectView.userInteractionEnabled = YES;
    [self.allRectView addSubview:self.numberRectView];
    
    UITapGestureRecognizer * tapNumberRectView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeNumberView)];
    
    [_numberRectView addGestureRecognizer:tapNumberRectView];
    
    
    self.rangeLabel = [[UILabel alloc]init];
    self.rangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rangeLabel.textAlignment = NSTextAlignmentCenter;
    self.rangeLabel.font = [UIFont systemFontOfSize:14.0f];
    self.rangeLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    _rangeLabel.text = NSLocalizedStringFromTable(@"Daily",@"Draw",@"");
    _rangeLabel.textColor = [UIColor whiteColor];
    [self.numberRectView addSubview:_rangeLabel];
    
    self.rectView = [[UIView alloc] init];
    self.rectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.allRectView addSubview:self.rectView];
    
    self.zeroLineView = [[UIView alloc]init];
    _zeroLineView.translatesAutoresizingMaskIntoConstraints = NO;
    _zeroLineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashLine"]];
    [self.rectView addSubview:_zeroLineView];
    
    self.percentLabel = [[UILabel alloc]init];
    _percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _percentLabel.backgroundColor = [UIColor clearColor];
    _percentLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:_percentLabel];
    
    self.zeroPercentLabel = [[UILabel alloc]init];
    _zeroPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _zeroPercentLabel.text = @"-0%";
    _zeroPercentLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.allRectView addSubview:_zeroPercentLabel];
    
    self.negativePercentLabel = [[UILabel alloc]init];
    _negativePercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
     _negativePercentLabel.backgroundColor = [UIColor clearColor];
    _negativePercentLabel.adjustsFontSizeToFitWidth = YES;
    [self.allRectView addSubview:_negativePercentLabel];
    
    self.percentLabel1 = [[UILabel alloc]init];
    _percentLabel1.translatesAutoresizingMaskIntoConstraints = NO;
    _percentLabel1.backgroundColor = [UIColor clearColor];
    _percentLabel1.adjustsFontSizeToFitWidth = YES;
    [self.allRectView addSubview:_percentLabel1];
    self.negativePercentLabel1 = [[UILabel alloc]init];
    _negativePercentLabel1.translatesAutoresizingMaskIntoConstraints = NO;
    _negativePercentLabel1.backgroundColor = [UIColor clearColor];
    _negativePercentLabel1.adjustsFontSizeToFitWidth = YES;
    [self.allRectView addSubview:_negativePercentLabel1];
    
    self.percentLabel2 = [[UILabel alloc]init];
    _percentLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    _percentLabel2.backgroundColor = [UIColor clearColor];
    _percentLabel2.adjustsFontSizeToFitWidth = YES;
    _percentLabel2.backgroundColor =[UIColor clearColor];
    [self.allRectView addSubview:_percentLabel2];
    self.negativePercentLabel2 = [[UILabel alloc]init];
    _negativePercentLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    _negativePercentLabel2.backgroundColor = [UIColor clearColor];
    _negativePercentLabel2.adjustsFontSizeToFitWidth = YES;
    [self.allRectView addSubview:_negativePercentLabel2];
    
    
    [_viewDictionary removeAllObjects];
    for (int i=0; i<5; i++) {
        self.kUpLineView = [[UIView alloc] init];
        _kUpLineView.tag = 4-i;
        _kUpLineView.backgroundColor = [UIColor blueColor];
        [self.rectView addSubview:_kUpLineView];
        [_viewDictionary setObject:_kUpLineView forKey:[NSString stringWithFormat:@"_kUpLineView%d",4-i]];
        
        self.kDownLineView = [[UIView alloc] init];
        _kDownLineView.tag = 4-i;
        _kDownLineView.backgroundColor = [UIColor blueColor];
        [self.rectView addSubview:_kDownLineView];
        [_viewDictionary setObject:_kDownLineView forKey:[NSString stringWithFormat:@"_kDownLineView%d",4-i]];
        
        self.kRectView = [[UIView alloc] init];
        _kRectView.tag = 4-i;
        _kRectView.backgroundColor = [UIColor redColor];
        [self.rectView addSubview:_kRectView];
        [_viewDictionary setObject:_kRectView forKey:[NSString stringWithFormat:@"_kRectView%d",4-i]];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap:)];
//        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(viewLongPress:)];
        
        self.kBackGroundView = [[UIView alloc] init];
        _kBackGroundView.tag = 4-i;
        _kBackGroundView.backgroundColor = [UIColor clearColor];
        [_kBackGroundView addGestureRecognizer:tap];
        [_kBackGroundView addGestureRecognizer:longPress];
        //[_kBackGroundView addGestureRecognizer:pan];
        _kBackGroundView.userInteractionEnabled = YES;
        [self.rectView addSubview:_kBackGroundView];
        [_viewDictionary setObject:_kBackGroundView forKey:[NSString stringWithFormat:@"_kBackGroundView%d",4-i]];
        
    }
    
    self.storeBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenButton];
    [_storeBtn setTitle:NSLocalizedStringFromTable(@"儲存", @"FigureSearch", nil) forState:UIControlStateNormal];
    _storeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_storeBtn addTarget:self action:@selector(storeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_storeBtn];
    
    self.trendBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenButton];
    [_trendBtn setTitle:NSLocalizedStringFromTable(@"選取趨勢線", @"FigureSearch", nil) forState:UIControlStateNormal];
    _trendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_trendBtn addTarget:self action:@selector(trendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_trendBtn];
    
    
    self.upLineImage = [[UIImageView alloc]init];
//    _upLineImage.translatesAutoresizingMaskIntoConstraints = NO;
    [_upLineImage setImage:[UIImage imageNamed:@"upLine-green"]];
    _upLineImage.hidden = YES;
    [_rectView addSubview:_upLineImage];
    
    self.downLineImage = [[UIImageView alloc]init];
//    _downLineImage.translatesAutoresizingMaskIntoConstraints = NO;
    [_downLineImage setImage:[UIImage imageNamed:@"downLine-red"]];
    _downLineImage.hidden = YES;
    [_rectView addSubview:_downLineImage];
    
    self.flatLineImage = [[UIImageView alloc]init];
//    _flatLineImage.translatesAutoresizingMaskIntoConstraints = NO;
    [_flatLineImage setImage:[UIImage imageNamed:@"upDownLine-blue"]];
    _flatLineImage.hidden = YES;
    [_rectView addSubview:_flatLineImage];
    
}

-(void)changeNumberView{
    _changeNameFlag = YES;
    _analysisPeriod+=1;
//    float num  = 1;
//    if ((_analysisPeriod % 3) ==0) {
//        num = 1;
//        _storeDWM = FSFigureDWMForD;
//        _rangeLabel.text = NSLocalizedStringFromTable(@"Daily",@"Draw",@"");
//    }else if ((_analysisPeriod % 3) ==1) {
//        _storeDWM = FSFigureDWMForW;
//        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);;
//        _rangeLabel.text = NSLocalizedStringFromTable(@"Weekly",@"Draw",@"");
//    }else{
//        _storeDWM = FSFigureDWMForM;
//        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
//        _rangeLabel.text = NSLocalizedStringFromTable(@"Monthly",@"Draw",@"");
//    }
//    _percentLabel.text = [NSString stringWithFormat:@"-%.1f%%",_range*num];
//    _negativePercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",_range*num];
//    _percentLabel1.text = [NSString stringWithFormat:@"-%.1f%%",_range*(2.0f/5.0f)*num];
//    _negativePercentLabel1.text = [NSString stringWithFormat:@"--%.1f%%",_range*(2.0f/5.0f)*num];
//    
//    _percentLabel2.text = [NSString stringWithFormat:@"-%.1f%%",_range*(4.0f/5.0f)*num];
//    _negativePercentLabel2.text = [NSString stringWithFormat:@"--%.1f%%",_range*(4.0f/5.0f)*num];
    float num  = 1;
    if ((_analysisPeriod % 3) ==0) {
        num = 1;
        _storeDWM = FSFigureDWMForD;
        _rangeLabel.text = NSLocalizedStringFromTable(@"Daily",@"Draw",@"");
    }else if ((_analysisPeriod % 3) ==1) {
        _storeDWM = FSFigureDWMForW;
        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);;
        _rangeLabel.text = NSLocalizedStringFromTable(@"Weekly",@"Draw",@"");
    }else{
        _storeDWM = FSFigureDWMForM;
        num = ([(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
        _rangeLabel.text = NSLocalizedStringFromTable(@"Monthly",@"Draw",@"");
    }
    
    
    if(_range>10){
        _percentLabel.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10 *num];
        _negativePercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*num];
        
        _percentLabel1.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(2.0f/5.0f)*num];
        _negativePercentLabel1.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(2.0f/5.0f)*num];
        
        _percentLabel2.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(4.0f/5.0f)*num];
        _negativePercentLabel2.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*_range/10*(4.0f/5.0f)*num];
    }
    else{
        _percentLabel.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*num];
        _negativePercentLabel.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*num];
        
        _percentLabel1.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(2.0f/5.0f)*num];
        _negativePercentLabel1.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(2.0f/5.0f)*num];
        
        _percentLabel2.text = [NSString stringWithFormat:@"-%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(4.0f/5.0f)*num];
        _negativePercentLabel2.text = [NSString stringWithFormat:@"--%.1f%%",[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]*(4.0f/5.0f)*num];
    }
}

-(void)trendBtnClick{
    _trendSettingView.hidden = NO;
    _deleteBtn.hidden = YES;
}

#pragma mark Store Button Event
-(void)storeBtnClick:(FSUIButton *)btn{
    //int plus10 = [_customModel getCounts:[NSNumber numberWithInt:newId]];
   // int origin = [_customModel getCounts:[NSNumber numberWithInt:newId/10]];
    
   // FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
   // if((![_titleText.text isEqualToString:[_figureSearchArray objectAtIndex:1]] || dataModel.figureSearchModel.beSubmit) || (plus10 == origin)){
        [self storeTitleText];
    /*}else{
        if(btn == _storeBtn) {
            [_customModel doneEditKBarFigureSearchID:[NSNumber numberWithInt:newId/10] NewFigureSearchId:[NSNumber numberWithInt:newId] TNumber:nil theData:nil type:FSFigureCustomStoreTypeSubmitStore];
            [self storeAction];
        }else{
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }*/
}

-(void)storeTitleText
{
    if ([_titleText.text isEqualToString:@""]) {
        [FSHUD showMsg:[NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"名稱不可空白", @"FigureSearch",nil)]];

    }else{
        if([_customModel checkFigureSearchTitle:_titleText.text SearchID:[_figureSearchArray objectAtIndex:0] System:self.gategory] == 0){
            if(IS_IOS8){
                _checkTitleAlertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTable(@"Ask to save", @"FigureSearch", nil) preferredStyle:UIAlertControllerStyleAlert];
                [_checkTitleAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"離開", @"FigureSearch", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self alertControllerAction:0 sender:_checkTitleAlertController];}]];
                [_checkTitleAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確認", @"FigureSearch", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self alertControllerAction:1 sender:_checkTitleAlertController];}]];
                [self presentViewController:_checkTitleAlertController animated:YES completion:nil];
            }else{
                _checkTitleAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"Ask to save", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"離開", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
                [_checkTitleAlert show];
            }
        }else{
            [FSHUD showMsg:NSLocalizedStringFromTable(@"此名稱已存在,請重新輸入",@"FigureSearch",nil)];
        }
    }
}

-(void)storeAction
{
    //存圖
    BOOL save = NO;
    for (int i =0; i<5; i++) {
        
        if ([[_canMoveArray objectAtIndex:4-i]isEqualToString:@"NO"]) {
            UIView * view =[_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d",i]];
            UIView * upLine = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kUpLineView%d",i]];
            UIView * downLine = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kDownLineView%d",i]];
            
            view.hidden = YES;
            upLine.hidden = YES;
            downLine.hidden = YES;
        }else{
            save = YES;
        }
    }
    int kNum = 0;
    for (int i =0; i<5; i++) {
        
        if ([[_canMoveArray objectAtIndex:i]isEqualToString:@"NO"]) {
            _upLineImage.frame = CGRectMake(_upLineImage.frame.origin.x-15, _upLineImage.frame.origin.y-40, _upLineImage.frame.size.width+70, _upLineImage.frame.size.height+40);
            _downLineImage.frame = CGRectMake(_downLineImage.frame.origin.x, _downLineImage.frame.origin.y, _downLineImage.frame.size.width+35, _downLineImage.frame.size.height+40);
            _flatLineImage.frame = CGRectMake(_flatLineImage.frame.origin.x-15, _flatLineImage.frame.origin.y-15, _flatLineImage.frame.size.width+50, _flatLineImage.frame.size.height+30);

            _upLineImage.frame = CGRectMake(_upLineImage.frame.origin.x+30, _upLineImage.frame.origin.y+40, _upLineImage.frame.size.width-70, _upLineImage.frame.size.height-30);
            _downLineImage.frame = CGRectMake(_downLineImage.frame.origin.x+10, _downLineImage.frame.origin.y-10, _downLineImage.frame.size.width-30, _downLineImage.frame.size.height-30);
            _flatLineImage.frame = CGRectMake(_flatLineImage.frame.origin.x+20, _flatLineImage.frame.origin.y, _flatLineImage.frame.size.width-30, _flatLineImage.frame.size.height-5);
            
        }else{
            kNum=i;
            break;
        }
    }
    
    
    if (save) {
        if (kNum>=3) {
            [_upLineImage setImage:[self imageWithImageSimple:[UIImage imageNamed:@"upLine-green"] scaledToSize:_upLineImage.frame.size]];
            
            [_downLineImage setImage:[self imageWithImageSimple:[UIImage imageNamed:@"downLine-red"] scaledToSize:_downLineImage.frame.size]];
            [_flatLineImage setImage:[self imageWithImageSimple:[UIImage imageNamed:@"upDownLine-blue"] scaledToSize:_flatLineImage.frame.size]];
            
        }else{
            [_upLineImage setImage:[self imageWithImageSimple:[UIImage imageNamed:@"upLine-green-bold"] scaledToSize:_upLineImage.frame.size]];
            
            [_downLineImage setImage:[self imageWithImageSimple:[UIImage imageNamed:@"downLine-red-bold"] scaledToSize:_downLineImage.frame.size]];
            [_flatLineImage setImage:[self imageWithImageSimple:[UIImage imageNamed:@"upDownLine-blue-bold"] scaledToSize:_flatLineImage.frame.size]];
        }
        _allRectView.layer.borderWidth = 0;
        _zeroLineView.hidden = YES;
        
        UIImageView * customImage;
        if (_currentOption ==2){
            customImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"DIY Pattern-Long icon"]];
        }else if (_currentOption ==3){
            customImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"DIY Pattern-Short icon"]];
        }
        
        customImage.frame = CGRectMake(0, 0, 131, 131);
        
        UIGraphicsBeginImageContext(CGSizeMake(_allRectView.bounds.size.width-45, _allRectView.bounds.size.height) );
        [_allRectView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView * newImage = [[UIImageView alloc]initWithImage:image];
        newImage.frame = CGRectMake(0, 0, 85, 85);
        [customImage addSubview:newImage];
        newImage.center = customImage.center;
        
        UIGraphicsBeginImageContext(customImage.bounds.size);
        [customImage.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *finishImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(finishImage);
        [_customModel changeFigureSearchImageWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Image:imageData];
//        [_customModel changeFigureSearchTitleWithFigureSearchId:[_figureSearchArray objectAtIndex:0] String:_titleText.text];
        //writeToFile
        //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        //        NSString *cachesDirectory = [paths objectAtIndex:0];
        //        NSString *imagePath =  [cachesDirectory stringByAppendingPathComponent:@"myImage.png"];
        //        [imageData writeToFile:imagePath atomically:YES];
        
        _rectView.layer.borderWidth = 1;
        _zeroLineView.hidden = NO;
        [self deleteOldData];
        
        
    }
    [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
    [self.navigationController popToViewController:[_customModel popBackTo:@"MyFigureSearchViewController" from:self.navigationController.childViewControllers] animated:NO];
}

-(void)viewTap:(UITapGestureRecognizer *)sender{
    NSLog(@"-------%d----", (int)sender.view.tag);
    int editedKBarTag = (int)sender.view.tag;
//    if (sender.view.tag == 0 || [[_canMoveArray objectAtIndex:4]isEqualToString:@"YES"]) {
    if(editedKBarTag == 0 || [_canMoveArray[4 - editedKBarTag + 1] isEqualToString:@"YES"]){
        FigureCustomEditViewController * editView = [[FigureCustomEditViewController alloc]initWithCurrentOption:_currentOption SearchNum:_searchNum kNumber:(int)sender.view.tag forDWM:_storeDWM];
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.figureSearchModel.beSubmit = NO;
        [self.navigationController pushViewController:editView animated:NO];
    }else{
        [FSHUD showMsg:NSLocalizedStringFromTable(@"請由右往左開始編輯一根以上的K棒", @"FigureSearch", nil)];
    }
    
}

-(void)viewLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state==1) {
        if ([[_canMoveArray objectAtIndex:4-sender.view.tag]isEqualToString:@"YES"] && [[_canMoveArray objectAtIndex:4-sender.view.tag - 1]isEqualToString:@"NO"]) {
            _deleteKbar = (int)sender.view.tag;
            if(IS_IOS8){
                self.deleteOneAlertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTable(@"刪除一根圖形", @"FigureSearch", nil) preferredStyle:UIAlertControllerStyleAlert];
                [_deleteOneAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self alertControllerAction:0 sender:_deleteOneAlertController];}]];
                [_deleteOneAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self alertControllerAction:1 sender:_deleteOneAlertController];}]];
                [self presentViewController:_deleteOneAlertController animated:YES completion:nil];
            }else{
                self.deleteOneAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"刪除一根圖形", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
                [_deleteOneAlert show];
            }
        }
    }
}

-(void)viewPan:(UIPanGestureRecognizer *)sender{
    if ([[_canMoveArray objectAtIndex:sender.view.tag]isEqualToString:@"YES"]) {
        UIView * view =[_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d", (int)sender.view.tag]];
        UIView * line = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kLineView%d", (int)sender.view.tag]];
        if ([sender state] == 1) {
            _viewX = sender.view.frame.origin.x;
            _changeY = view.center.y-line.center.y;
        }else if ([sender state] == 2){
            if (line.frame.origin.y>=0 && (line.frame.origin.y+line.frame.size.height+_rectView.frame.origin.y)<=(_rectView.frame.origin.y+_rectView.frame.size.height)) {
                CGPoint location = [sender locationInView:self.rectView];
                if (location.y<line.frame.size.height/2) {
                    [line setCenter:CGPointMake(_viewX+_kRectView.frame.size.width/2, line.frame.size.height/2)];
                    [view setCenter:CGPointMake(_viewX+_kRectView.frame.size.width/2, line.center.y+_changeY)];
                }else if (location.y>(_rectView.frame.origin.y+_rectView.frame.size.height)-(line.frame.size.height/2)-_rectView.frame.origin.y){
                    [line setCenter:CGPointMake(_viewX+_kRectView.frame.size.width/2, (_rectView.frame.origin.y+_rectView.frame.size.height)-(line.frame.size.height/2)-_rectView.frame.origin.y)];
                    [view setCenter:CGPointMake(_viewX+_kRectView.frame.size.width/2, line.center.y+_changeY)];
                }else{
                    //_changeY = location.y - view.center.y;
                    [line setCenter:CGPointMake(view.center.x, location.y)];
                    [view setCenter:CGPointMake(_viewX+_kRectView.frame.size.width/2, line.center.y+_changeY)];
                    
                    
                }
            }
            
        }else if ([sender state] == 3){
            if (sender.view.frame.origin.y<0) {
                [sender.view setCenter:CGPointMake(_viewX+_kRectView.frame.size.width/2, sender.view.frame.size.height/2)];
            }
            if ((sender.view.frame.origin.y+sender.view.frame.size.height+_rectView.frame.origin.y)>(self.rectView.frame.origin.y+self.rectView.frame.size.height)) {
                [sender.view setCenter:CGPointMake(_viewX+_kRectView.frame.size.width/2,(self.rectView.frame.origin.y+self.rectView.frame.size.height)-(sender.view.frame.size.height/2)-_rectView.frame.origin.y)];
            }
        }
    }
}



-(void)btnClick:(FSUIButton *)btn{
    if ([btn isEqual:_backBtn]) {
        if (_trendSettingView.hidden == NO) {
            _trendSettingView.hidden = YES;
            
            //趨勢線設定頁存在
//            self.trendLineBackAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"not finish", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
//            [_trendLineBackAlert show];
        }else{
            [self storeBtnClick:btn];
            /*
            BOOL save = NO;
            for (int i =0; i<5; i++) {
                if ([[_canMoveArray objectAtIndex:4-i]isEqualToString:@"YES"]) {
                    save = YES;
                }
            }
            if (save) {
                if ([_titleText.text isEqualToString:@""]) {
//                    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"Enter pattern name" delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"確認", @"FigureSearch",nil), nil];
//                    [alert show];
                    [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"請輸入圖示名稱", @"FigureSearch",nil)] bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
                }else{
                    if([_customModel checkFigureSearchTitle:_titleText.text SearchID:[_figureSearchArray objectAtIndex:0] System:self.gategory] == 0){
                        self.backAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"Ask to save", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
                        [_backAlert show];
                    }else{
                        [SGInfoAlert showInfo:@"此名稱已存在,請重新輸入" bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
                    }
                }
            }else{
                if (_upLineImage.hidden == NO || _downLineImage.hidden == NO || _flatLineImage.hidden == NO) {
                    noKlineAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"請設定至少1根K棒", @"FigureSearch",nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
                    [noKlineAlert show];
                }else{
                    UIImage * defaultImage;
                    if (_currentOption ==2){
                        defaultImage = [UIImage imageNamed:@"DIY Pattern - Long Default"];
                    }else if (_currentOption ==3){
                        defaultImage = [UIImage imageNamed:@"DIY Pattern - Short Default"];
                    }
                    NSData *imageData = UIImagePNGRepresentation(defaultImage);
                    [_customModel changeFigureSearchImageWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Image:imageData];
                    [self.navigationController popViewControllerAnimated:NO];
                }
                
            }*/
        }
        
    }else if ([btn isEqual:_deleteBtn]){
        if(IS_IOS8){
            self.deleteAlertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTable(@"刪除圖形", @"FigureSearch", nil) preferredStyle:UIAlertControllerStyleAlert];
            [_deleteAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self alertControllerAction:0 sender:_deleteAlertController];}]];
            [_deleteAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self alertControllerAction:1 sender:_deleteAlertController];}]];
            [self presentViewController:_deleteAlertController animated:YES completion:nil];
        }else{
            self.deleteAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"刪除圖形", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
            [_deleteAlert show];
        }
    }
}

-(void)deleteOldData{
    [_customModel deleteAllTrackWithFigureSearchId:[NSNumber numberWithInt:newId]];
    NSMutableArray * deleteArray = [_customModel searchResultInfoWithFigureSearchId:[NSNumber numberWithInt:newId]];
    [_customModel deleteResultInfoWithFigureSearchId:[NSNumber numberWithInt:newId]];
    
    for (int i=0; i<[deleteArray count]; i++) {
        [_customModel deleteFigureSearchResultDataWithFigureSearchResultInfoId:[deleteArray objectAtIndex:i]];
    }
}

-(void)alertControllerAction:(int)target sender:(UIAlertController *)sender
{
    if(sender == _checkTitleAlertController){
        if(target == 1){
            //bug#10713 start
            if([[_canMoveArray objectAtIndex:4]isEqualToString:@"NO"]){
                [FSHUD showMsg:[NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"請設定至少1根k棒", @"FigureSearch",nil)]];
                return;
            }
            //bug#10713 end
            [_customModel changeFigureSearchTitleWithFigureSearchId:[_figureSearchArray objectAtIndex:0] String:_titleText.text];
            [_customModel doneEditKBarFigureSearchID:[NSNumber numberWithInt:newId/10] NewFigureSearchId:[NSNumber numberWithInt:newId] TNumber:nil theData:nil type:FSFigureCustomStoreTypeSubmitStore];
            
            [self storeAction];
        }else if(target == 0){
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }else if(sender == _deleteAlertController){
        if (target==1) {
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId/10]];
            int figureSearchId = [(NSNumber *)[_figureSearchArray objectAtIndex:0]intValue];
            [_customModel setFigureSearchToDefaultWithFigureSearchId: [NSNumber numberWithInt:figureSearchId]];
            [_customModel editTrendValueWithFigureSearchId:[NSNumber numberWithInt:newId] UpLine:[NSNumber numberWithFloat:5] DownLine:[NSNumber numberWithFloat:5] FlatLine:[NSNumber numberWithFloat:5]];
            
            UIImage * defaultImage;
            if (_currentOption ==2){
                defaultImage = [UIImage imageNamed:@"DIY Pattern - Long Default"];
            }else if (_currentOption ==3){
                defaultImage = [UIImage imageNamed:@"DIY Pattern - Short Default"];
            }
            NSData *imageData = UIImagePNGRepresentation(defaultImage);
            [_customModel changeFigureSearchImageWithFigureSearchId:[NSNumber numberWithInt:newId/10] Image:imageData];
            _trendLine = NO;
            [self deleteOldData];
            [self setKLineWidth];
            [self setKbar];
            [self showTrendLine];
            
            self.figureSearchArray =[_customModel searchFigureSearchIdWithGategory:self.gategory ItemOrder:[NSNumber numberWithInt:_searchNum]];
            
            _percentLabel.text = [NSString stringWithFormat:@"-%@%%",[_figureSearchArray objectAtIndex:2]];
            _negativePercentLabel.text = [NSString stringWithFormat:@"--%@%%",[_figureSearchArray objectAtIndex:2]];
            [self setLayout];
            
        }
    }else if(sender == _deleteOneAlertController){
        if (target == 1) {
            [_customModel deleteKbarWithFigureSearchId:[NSNumber numberWithInt:newId] tNum:[NSNumber numberWithInt:_deleteKbar]];
            //if(_deleteKbar==0)
            //    [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId/10]];
            [self deleteOldData];
            [self setKbar];
            [self setLayout];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:_deleteAlert]) {
        if (buttonIndex==1) {
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId/10]];
            int figureSearchId = [(NSNumber *)[_figureSearchArray objectAtIndex:0]intValue];
            [_customModel setFigureSearchToDefaultWithFigureSearchId: [NSNumber numberWithInt:figureSearchId]];
            //[_customModel setFigureSearchToDefaultWithFigureSearchId:(NSNumber *)[_figureSearchArray objectAtIndex:0]];
            [_customModel editTrendValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] UpLine:[NSNumber numberWithFloat:5] DownLine:[NSNumber numberWithFloat:5] FlatLine:[NSNumber numberWithFloat:5]];
            
            UIImage * defaultImage;
            if (_currentOption ==2){
                defaultImage = [UIImage imageNamed:@"DIY Pattern - Long Default"];
            }else if (_currentOption ==3){
                defaultImage = [UIImage imageNamed:@"DIY Pattern - Short Default"];
            }
            NSData *imageData = UIImagePNGRepresentation(defaultImage);
            
            [_customModel changeFigureSearchImageWithFigureSearchId:[NSNumber numberWithInt:newId/10] Image:imageData];
            _trendLine = NO;
            [self deleteOldData];
            [self setKLineWidth];
            [self setKbar];
            [self showTrendLine];
            
            self.figureSearchArray =[_customModel searchFigureSearchIdWithGategory:self.gategory ItemOrder:[NSNumber numberWithInt:_searchNum]];
            
            _percentLabel.text = [NSString stringWithFormat:@"-%@%%",[_figureSearchArray objectAtIndex:2]];
            _negativePercentLabel.text = [NSString stringWithFormat:@"--%@%%",[_figureSearchArray objectAtIndex:2]];
            [self setLayout];
            
        }
    }else if ([alertView isEqual:_backAlert]){
        if (buttonIndex == 1) {
            [self storeTitleText];
            [self storeAction];
        }else if (buttonIndex ==0){
            [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:_oldTrend]];
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];

            for (int i=0; i<5; i++) {
                [_customModel editKbarFigureSearchId:[NSNumber numberWithInt:newId] NewFigureSearchId:[NSNumber numberWithInt:newId] TNumber:[NSNumber numberWithInt:i]];
            }
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
            [self.navigationController popViewControllerAnimated:NO];
        }
        
    }else if ([alertView isEqual:_deleteOneAlert]){
        if (buttonIndex == 1) {
            [_customModel deleteKbarWithFigureSearchId:[NSNumber numberWithInt:newId] tNum:[NSNumber numberWithInt:_deleteKbar]];
            //if(_deleteKbar==0)
            //    [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId/10]];
            
            [self deleteOldData];
            [self setKbar];
            [self setLayout];
        }
    }/*else if ([alertView isEqual:_trendLineBackAlert]){
        if (buttonIndex==1) {
            if (_upLineBtn.selected) {
                _trend = upTrend;
                _trendLine = YES;
                [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:0]];
            }
            if (_downLineBtn.selected) {
                _trend = downTrend;
                _trendLine = YES;
                [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:1]];
            }
            if (_upDownLineBtn.selected) {
                _trend = flatTrend;
                _trendLine = YES;
                [_customModel editTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Trend:[NSNumber numberWithInt:2]];
            }
            _trendSettingView.hidden = YES;
            _titleText.userInteractionEnabled = YES;
            [_customModel editTrendValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] UpLine:[NSNumber numberWithFloat:_upLineSlider.value] DownLine:[NSNumber numberWithFloat:_downLineSlider.value] FlatLine:[NSNumber numberWithFloat:_upDownLineSlider.value]];
            [self setKLineWidth];
            [self setkBackGroundViewFrame];
            [self setKbar];
            [self showTrendLine];
            [self showTeachPop];
            for (int i=0; i<=4; i++) {
                UIView * rectView = [_viewDictionary objectForKey:[NSString stringWithFormat:@"_kRectView%d",i]];
                rectView.layer.borderWidth = 2;
            }
        }else{
            [self.navigationController popViewControllerAnimated:NO];
        }
    }*/else if (noKlineAlert){
        if (buttonIndex == 0) {
            UIImage * defaultImage;
            if (_currentOption ==2){
                defaultImage = [UIImage imageNamed:@"DIY Pattern - Long Default"];
            }else if (_currentOption ==3){
                defaultImage = [UIImage imageNamed:@"DIY Pattern - Short Default"];
            }
            NSData *imageData = UIImagePNGRepresentation(defaultImage);
            [_customModel changeFigureSearchImageWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Image:imageData];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }else if([alertView isEqual:_checkTitleAlert]){
        if(buttonIndex == 1){
            if([[_canMoveArray objectAtIndex:4]isEqualToString:@"NO"]){//bug#10713 start
                [FSHUD showMsg:[NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"請設定至少1根k棒", @"FigureSearch",nil)]];
                return;
            }//bug#10713 end
            [_customModel doneEditKBarFigureSearchID:[NSNumber numberWithInt:newId/10] NewFigureSearchId:[NSNumber numberWithInt:newId] TNumber:nil theData:nil type:FSFigureCustomStoreTypeSubmitStore];
            
            [_customModel changeFigureSearchTitleWithFigureSearchId:[_figureSearchArray objectAtIndex:0] String:_titleText.text];
            [self storeAction];
        }else if(buttonIndex == 0){
            [_customModel deleteAllKbarWithFigureSearchId:[NSNumber numberWithInt:newId]];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//textField為尚未被更動過的文字內容，string 為更動過後的文字內容，而textField與string 不同的地方，將會被記錄在range 裡面（range.length指新增的文字長度，range.location指新增的文字位置）
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.length + range.location > textField.text.length){
        return NO;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 15)? NO : YES;
}


-(void)setDefaultColorWithkNumber:(int)kNumber{
    NSMutableArray * conditionArray = [_customModel searchkBarConditionsWithFigureSearchId:[NSNumber numberWithInt:newId] tNumber:[NSNumber numberWithInt:kNumber]];
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

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
//    float width,height;
//    if (image.size.height >= (newSize.height/newSize.width)*image.size.width){
//        width=image.size.width/image.size.height*newSize.height;
//        height=newSize.height;
//    }else{
//        height=image.size.height/image.size.width*newSize.height;
//        width=newSize.width;
//    }
//    newSize.width=width;
//    newSize.height=height;
    UIGraphicsBeginImageContext(newSize);
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];
    
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [_explainView showMenuWithRect:CGRectMake(150, 300, 0, 0) String:NSLocalizedStringFromTable(@"編輯K棒", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionUp];
        [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(150, 250, 30, 56)];
    }else{
        [_explainView showMenuWithRect:CGRectMake(150, 330, 0, 0) String:NSLocalizedStringFromTable(@"編輯K棒", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionUp];
        [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(150, 280, 30, 56)];
    }
    
}

-(void)trendTeachPop{
    
    
    self.trendExplainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _trendExplainView.delegate = self;
    _trendExplainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    
    [_trendExplainView showMenuWithRect:CGRectMake(80, 160, 0, 0) String:NSLocalizedStringFromTable(@"選擇趨勢線", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionDown];
    [_trendExplainView addHandImageWithType:@"handTap"Rect:CGRectMake(80, 160, 30, 56)];
    
    
    
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [_trendExplainView showMenuWithRect:CGRectMake(150, 320, 0, 0) String:NSLocalizedStringFromTable(@"趨勢線範圍", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
        [_trendExplainView addHandImageWithType:@"handMoveRight"Rect:CGRectMake(130, 260, 30, 56)];
    }else{
        [_trendExplainView showMenuWithRect:CGRectMake(150, 350, 0, 0) String:NSLocalizedStringFromTable(@"趨勢線範圍", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
        [_trendExplainView addHandImageWithType:@"handMoveRight"Rect:CGRectMake(140, 300, 30, 56)];
    }
    
    [[[UIApplication sharedApplication]delegate].window addSubview:_trendExplainView];
    
}

-(void)closeTeachPop:(UIView *)view{
    //存資料庫
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    [view removeFromSuperview];
    if ([view isEqual:_explainView]) {
        if (teachPopView.checkBtn.selected) {
            [_customModel editInstructionByControllerName:[NSString stringWithFormat:@"%@2",[[self class] description]] Show:@"NO"];
        }else{
            [_customModel editInstructionByControllerName:[NSString stringWithFormat:@"%@2",[[self class] description]] Show:@"YES"];
        }
    }else{
        if (teachPopView.checkBtn.selected) {
            [_customModel editInstructionByControllerName:[NSString stringWithFormat:@"%@1",[[self class] description]] Show:@"NO"];
        }else{
            [_customModel editInstructionByControllerName:[NSString stringWithFormat:@"%@1",[[self class] description]] Show:@"YES"];
        }
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
