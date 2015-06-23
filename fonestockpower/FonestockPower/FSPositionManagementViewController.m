//
//  FSPositionManagementViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/11/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPositionManagementViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "MarqueeLabel.h"
#import "UIView+NewComponent.h"
#import "FSInvestedViewController.h"
#import "FSActionPlanDatabase.h"
#import "NetWorthViewController.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "DrawAndScrollController.h"
#import "FSTradeHistoryViewController.h"
#import "ExplanationViewController.h"
#import "MarqueeLabel.h"

@interface FSPositionManagementViewController (){
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    FSUIButton *fundButton;
    FSUIButton *netWorthButton;
    MarqueeLabel * fundButtonLabel;
    MarqueeLabel * netWorthButtonLabel;

    UIView *infoView;
    UIScrollView *infoScrollView;
    
    UILabel *fundLabel;
    UILabel *netWorthLabel;
    UILabel *unrealizedTitleLabel;
    UILabel *unrealizedLabel;
    UILabel *riskExposureTitleLabel;
    UILabel *riskExposureLabel;
    UILabel *riskExposurePercentLabel;
    UILabel *positionTitleLabel;
    UILabel *positionLabel;
    UILabel *costTitleLabel;
    UILabel *costLabel;
    UILabel *cashTitleLabel;
    UILabel *cashLabel;
    UILabel *titleLabel;

    NSUInteger time;
    NSTimer *timer;
    
    UIButton *pointButton;
    FSUIButton *moreOptionBtnNav;
    FSUIButton *zeroOptionBtnNav;
    
    NSMutableArray *positionArray;
    NSMutableArray *investedFunds;
    NSMutableArray *layoutContraints;
    NSMutableArray *layoutContraints1;
    NSMutableArray *layoutContraints2;

    NSMutableDictionary *alertDict;
    
    FSActionPlanDatabase *actionPlanDB;
    FSActionPlanModel *actionPlanModel;
    FSPositionModel *positionModel;
    FSPositions *positions;
    FSInstantInfoWatchedPortfolio *watchedPortfolio;
    
    BOOL status;//YES:Long NO:Short
    float lastFund;
}

@end

@implementation FSPositionManagementViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    positionModel = [[FSDataModelProc sharedInstance] positionModel];
    actionPlanDB = [FSActionPlanDatabase sharedInstances];
    watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    actionPlanModel = [[FSDataModelProc sharedInstance] actionPlanModel];
    alertDict = [[NSMutableDictionary alloc] init];

    layoutContraints = [[NSMutableArray alloc] init];
    layoutContraints1 = [[NSMutableArray alloc] init];
    layoutContraints2 = [[NSMutableArray alloc] init];

    [self initView];
    [self.view setNeedsUpdateConstraints];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self initData];
    [self showInfoViewData];
    [self setNavigation];
    [self setNavigationBtn];
    [self alertTimer];
    [self buttonStatusControll];
    time = 0;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
    titleLabel.text = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 說明頁
-(void)explantation:(UIButton *)sender{
    [self.navigationController pushViewController:[[ExplanationViewController alloc] init] animated:NO];
}

#pragma mark - set navigation
-(void)setNavigation{
    [self setUpImageBackButton];
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"Positions", @"Launcher", nil)];
    pointButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [pointButton addTarget:self action:@selector(explantation:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"Trade", nil);
    moreOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionBtnNav.frame = CGRectMake(0, 0, 132, 33);
    [moreOptionBtnNav setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"Trade", nil);
    zeroOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionBtnNav.frame = CGRectMake(0, 0, 132, 33);
    [zeroOptionBtnNav setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barAddButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pointButton];
    UIBarButtonItem *moreBtnItem = [[UIBarButtonItem alloc] initWithCustomView:moreOptionBtnNav];
    UIBarButtonItem *zeroBtnItem = [[UIBarButtonItem alloc] initWithCustomView:zeroOptionBtnNav];
    NSArray *itemArray = [[NSArray alloc] initWithObjects:barAddButtonItem, zeroBtnItem, moreBtnItem, nil];
    [self.navigationItem setRightBarButtonItems:itemArray];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-8, 66)];
    }else{
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.height-8, 66)];
    }
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:titleLabel];
}

-(void)setNavigationBtn{
    titleLabel.text = NSLocalizedStringFromTable(@"Positions", @"Launcher", nil);
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        titleLabel.hidden = NO;
        moreOptionBtnNav.hidden = YES;
        zeroOptionBtnNav.hidden = YES;
    }else{
        titleLabel.hidden = YES;
        moreOptionBtnNav.hidden = NO;
        zeroOptionBtnNav.hidden = NO;
    }
}

#pragma mark - init View
-(void)initView{
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"Trade", nil);
    moreOptionButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    moreOptionButton.selected = YES;
    [moreOptionButton setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreOptionButton];
    
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"Trade", nil);
    zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zeroOptionButton];
    
    _tableView = [[FSPositionManagementTableView alloc] initWithfixedColumnWidth:80 mainColumnWidth:100 AndColumnHeight:50];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    infoView = [[UIView alloc] init];
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    infoView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
    
    infoScrollView = [[UIScrollView alloc] init];
    infoScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    infoScrollView.backgroundColor = [UIColor clearColor];
    infoScrollView.bounces = NO;
    infoScrollView.contentSize = CGSizeMake(infoView.frame.size.width, infoView.frame.size.height);
    [infoScrollView addSubview:infoView];
    [self.view addSubview:infoScrollView];
    
    fundButton =[infoView newButton:FSUIButtonTypeBlueGreenButton];
    [fundButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [fundButton setTitle:NSLocalizedStringFromTable(@"投入資金", @"ActionPlan", nil) forState:UIControlStateNormal];
    [fundButton addTarget:self action:@selector(InventedFundsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    fundButtonLabel = [[MarqueeLabel alloc]init];
    fundButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    fundButtonLabel.text = NSLocalizedStringFromTable(@"投入資金", @"ActionPlan", nil);
    [fundButtonLabel setLabelize:NO];
    fundButtonLabel.marqueeType = 4;
    fundButtonLabel.continuousMarqueeExtraBuffer = 30.0f;
    fundButtonLabel.backgroundColor = [UIColor clearColor];
    fundButtonLabel.textColor = [UIColor whiteColor];
    fundButtonLabel.font = [UIFont systemFontOfSize:16.0f];
    fundButtonLabel.textAlignment = NSTextAlignmentLeft;
    fundButtonLabel.lineBreakMode = NSLineBreakByClipping;
    [fundButton addSubview:fundButtonLabel];
    
    netWorthButton = [infoView newButton:FSUIButtonTypeBlueGreenButton];
//    [netWorthButton setTitle:NSLocalizedStringFromTable(@"資產淨值", @"ActionPlan", nil) forState:UIControlStateNormal];
    [netWorthButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//    netWorthButton.textLabel.textAlignment = NSTextAlignmentLeft;
    [netWorthButton addTarget:self action:@selector(NetAssetsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    netWorthButtonLabel = [[MarqueeLabel alloc]init];
    netWorthButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    netWorthButtonLabel.text = NSLocalizedStringFromTable(@"資產淨值", @"ActionPlan", nil);
    [netWorthButtonLabel setLabelize:NO];
    netWorthButtonLabel.marqueeType = 4;
    netWorthButtonLabel.continuousMarqueeExtraBuffer = 30.0f;
    netWorthButtonLabel.backgroundColor = [UIColor clearColor];
    netWorthButtonLabel.textColor = [UIColor whiteColor];
    netWorthButtonLabel.font = [UIFont systemFontOfSize:16.0f];
    netWorthButtonLabel.textAlignment = NSTextAlignmentLeft;
    netWorthButtonLabel.lineBreakMode = NSLineBreakByClipping;
    [netWorthButton addSubview:netWorthButtonLabel];
    
    //投入資金
    fundLabel = [[UILabel alloc] init];
    fundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    fundLabel.backgroundColor = [UIColor clearColor];
    fundLabel.adjustsFontSizeToFitWidth = YES;
    fundLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:fundLabel];
    
    //資產淨值
    netWorthLabel = [[UILabel alloc]init];
    netWorthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    netWorthLabel.adjustsFontSizeToFitWidth = YES;
    netWorthLabel.backgroundColor = [UIColor clearColor];
    netWorthLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:netWorthLabel];
    
    //未實現損益
    unrealizedTitleLabel = [[UILabel alloc]init];
    unrealizedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    unrealizedTitleLabel.backgroundColor = [UIColor clearColor];
    unrealizedTitleLabel.adjustsFontSizeToFitWidth = YES;
    unrealizedTitleLabel.text = NSLocalizedStringFromTable(@"Unrealized Gains", @"ActionPlan", nil);
    [infoView addSubview:unrealizedTitleLabel];
    
    unrealizedLabel = [[UILabel alloc] init];
    unrealizedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    unrealizedLabel.backgroundColor = [UIColor clearColor];
    unrealizedLabel.adjustsFontSizeToFitWidth = YES;
    unrealizedLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:unrealizedLabel];
    
    //曝顯金額
    riskExposureTitleLabel = [[UILabel alloc]init];
    riskExposureTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    riskExposureTitleLabel.backgroundColor = [UIColor clearColor];
    riskExposureTitleLabel.adjustsFontSizeToFitWidth = YES;
    riskExposureTitleLabel.text = NSLocalizedStringFromTable(@"Risk", @"ActionPlan", nil);
    [infoView addSubview:riskExposureTitleLabel];
    
    riskExposureLabel = [[UILabel alloc]init];
    riskExposureLabel.translatesAutoresizingMaskIntoConstraints = NO;
    riskExposureLabel.backgroundColor = [UIColor clearColor];
    riskExposureLabel.adjustsFontSizeToFitWidth = YES;
    riskExposureLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:riskExposureLabel];
    
    riskExposurePercentLabel = [[UILabel alloc] init];
    riskExposurePercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    riskExposurePercentLabel.adjustsFontSizeToFitWidth = YES;
    riskExposurePercentLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:riskExposurePercentLabel];
    
    //成本
    positionTitleLabel = [[UILabel alloc]init];
    positionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    positionTitleLabel.backgroundColor = [UIColor clearColor];
    positionTitleLabel.adjustsFontSizeToFitWidth = YES;
    positionTitleLabel.text = NSLocalizedStringFromTable(@"Positions", @"ActionPlan", nil);
    [infoView addSubview:positionTitleLabel];
    
    positionLabel = [[UILabel alloc]init];
    positionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    positionLabel.backgroundColor = [UIColor clearColor];
    positionLabel.adjustsFontSizeToFitWidth = YES;
    positionLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:positionLabel];
    
    //庫存成本
    costTitleLabel = [[UILabel alloc] init];
    costTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    costTitleLabel.backgroundColor = [UIColor clearColor];
    costTitleLabel.adjustsFontSizeToFitWidth = YES;
    costTitleLabel.text = NSLocalizedStringFromTable(@"Position Cost", @"ActionPlan", nil);
    [infoView addSubview:costTitleLabel];
    
    costLabel = [[UILabel alloc] init];
    costLabel.translatesAutoresizingMaskIntoConstraints = NO;
    costLabel.backgroundColor = [UIColor clearColor];
    costLabel.adjustsFontSizeToFitWidth = YES;
    costLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:costLabel];
    
    //現金餘額
    cashTitleLabel = [[UILabel alloc] init];
    cashTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cashTitleLabel.backgroundColor = [UIColor clearColor];
    cashTitleLabel.adjustsFontSizeToFitWidth = YES;
    cashTitleLabel.text = NSLocalizedStringFromTable(@"Cash", @"ActionPlan", nil);
    [infoView addSubview:cashTitleLabel];
    
    cashLabel = [[UILabel alloc] init];
    cashLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cashLabel.backgroundColor = [UIColor clearColor];
    cashLabel.adjustsFontSizeToFitWidth = YES;
    cashLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:cashLabel];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    [self.view removeConstraints:layoutContraints1];
    [self.view removeConstraints:layoutContraints2];

    [layoutContraints removeAllObjects];
    [layoutContraints1 removeAllObjects];
    [layoutContraints2 removeAllObjects];

    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        NSDictionary *viewController = NSDictionaryOfVariableBindings(moreOptionButton, zeroOptionButton, _tableView, infoView, infoScrollView, fundButton, fundButtonLabel, netWorthButton , netWorthButtonLabel, unrealizedTitleLabel, riskExposureTitleLabel, positionTitleLabel, fundLabel,netWorthLabel, unrealizedLabel, riskExposureLabel, riskExposurePercentLabel,positionLabel, costTitleLabel, costLabel, cashTitleLabel, cashLabel);
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-2-[zeroOptionButton(==moreOptionButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[moreOptionButton(44)]-2-[_tableView][infoScrollView(50)]|" options:0 metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoScrollView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];

        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoView(743)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[infoView(50)]" options:0 metrics:nil views:viewController]];
        [layoutContraints2 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[fundButton(25)][netWorthButton(25)]|" options:0 metrics:nil views:viewController]];
        [layoutContraints2 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[fundButton(80)]-2-[fundLabel(90)]-[positionTitleLabel(70)]-1-[positionLabel(90)]-[unrealizedTitleLabel(120)]-1-[unrealizedLabel(80)]-[riskExposureTitleLabel(65)]-1-[riskExposureLabel(115)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints2 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[netWorthButton(80)]-2-[netWorthLabel(90)]-[cashTitleLabel(70)]-1-[cashLabel(90)]-[costTitleLabel(120)]-1-[costLabel(80)]-74-[riskExposurePercentLabel(115)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        
        [self.view addConstraints:layoutContraints];
        [infoScrollView addConstraints:layoutContraints1];
        [infoView addConstraints:layoutContraints2];
    }else{
        NSDictionary *viewController = NSDictionaryOfVariableBindings(_tableView, infoView, infoScrollView, fundButton, fundButtonLabel, netWorthButton, netWorthButtonLabel, unrealizedTitleLabel, riskExposureTitleLabel, positionTitleLabel, fundLabel,netWorthLabel, unrealizedLabel, riskExposureLabel, riskExposurePercentLabel,positionLabel, costTitleLabel, costLabel, cashTitleLabel, cashLabel);
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView][infoScrollView(50)]|" options:0 metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoScrollView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoView(743)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[infoView(50)]" options:0 metrics:nil views:viewController]];
        [layoutContraints2 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[fundButton(25)][netWorthButton(25)]|" options:0 metrics:nil views:viewController]];
        [layoutContraints2 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[fundButton(80)]-2-[fundLabel(90)]-[positionTitleLabel(70)]-1-[positionLabel(90)]-[unrealizedTitleLabel(120)]-1-[unrealizedLabel(80)]-[riskExposureTitleLabel(65)]-1-[riskExposureLabel(115)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints2 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[netWorthButton(80)]-2-[netWorthLabel(90)]-[cashTitleLabel(70)]-1-[cashLabel(90)]-[costTitleLabel(120)]-1-[costLabel(80)]-74-[riskExposurePercentLabel(115)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:fundButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
        [layoutContraints2 addObject:[NSLayoutConstraint constraintWithItem:netWorthButtonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:netWorthButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        
        [self.view addConstraints:layoutContraints];
        [infoScrollView addConstraints:layoutContraints1];
        [infoView addConstraints:layoutContraints2];
    }
}

#pragma mark - initData
-(void)initData{
    investedFunds = [[NSMutableArray alloc] init];
    if (moreOptionButton.selected == YES || moreOptionBtnNav.selected) {
        [actionPlanModel loadActionPlanLongData];
        investedFunds = [actionPlanDB searchInvestedByTerm:@"Long"];
        [positionModel loadPositionData:@"Long"];
        positionArray = positionModel.positionArray;
        status = YES;
    }else if (zeroOptionButton.selected == YES || zeroOptionBtnNav.selected == YES){
        [actionPlanModel loadActionPlanShortData];
        investedFunds = [actionPlanDB searchInvestedByTerm:@"Short"];
        [positionModel loadPositionData:@"Short"];
        positionArray = positionModel.positionArray;
        status = NO;
    }
    [_tableView reloadData];
}

-(void)showInfoViewData{
    //投入資金
    lastFund = [(NSNumber *)[[investedFunds valueForKey:@"Total_Amount"] valueForKey:@"@firstObject"] floatValue];
    fundLabel.text = [NSString stringWithFormat:@"$%@", [self determineCountry:lastFund Decimal:0 IsInfo:YES]];
    fundLabel.textColor = [self setTextColor:lastFund];
    
    //資產淨值
    netWorthLabel.textColor = [self setTextColor:positionModel.netWorth];
    netWorthLabel.text = [NSString stringWithFormat:@"$%@", [self determineCountry:positionModel.netWorth Decimal:0 IsInfo:YES]];
    
    //持有部位
    positionLabel.textColor = [self setTextColor:positionModel.position];
    positionLabel.text = [NSString stringWithFormat:@"$%@", [self determineCountry:positionModel.position * positionModel.suggestCount Decimal:0 IsInfo:YES]];

    //現金餘額
    if (positionModel.netWorth - positionModel.unrealized * positionModel.suggestCount - positionModel.totalCost * positionModel.suggestCount > 0) {
        cashLabel.textColor = [StockConstant PriceUpColor];
    }else if (positionModel.netWorth - positionModel.unrealized * positionModel.suggestCount - positionModel.totalCost * positionModel.suggestCount < 0){
        cashLabel.textColor = [StockConstant PriceDownColor];
    }else{
        cashLabel.textColor = [UIColor blackColor];
    }

    cashLabel.text = [NSString stringWithFormat:@"$%@", [self determineCountry:positionModel.netWorth - positionModel.unrealized * positionModel.suggestCount - positionModel.totalCost * positionModel.suggestCount Decimal:0 IsInfo:YES]];
    
    //未實現損益
    if (positionModel.unrealized > 0) {
        unrealizedLabel.textColor = [StockConstant PriceUpColor];
    }else if (positionModel.unrealized < 0){
        unrealizedLabel.textColor = [StockConstant PriceDownColor];
    }else{
        unrealizedLabel.textColor = [UIColor blackColor];
    }
    unrealizedLabel.text = [NSString stringWithFormat:@"$%@", [self determineCountry:positionModel.unrealized * positionModel.suggestCount Decimal:0 IsInfo:YES]];
    
    //庫存成本
    if (positionModel.totalCost == 0 || isnan(positionModel.totalCost)) {
        costLabel.textColor = [UIColor blackColor];
    }else{
        costLabel.textColor = [StockConstant PriceUpColor];
    }
    if (!isnan(positionModel.totalCost)) {
        costLabel.text = [NSString stringWithFormat:@"$%@", [self determineCountry:positionModel.totalCost * positionModel.suggestCount Decimal:0 IsInfo:YES]];
    }else{
        costLabel.text = @"$0";
    }

    //曝險金額 & 曝險金額(%)
    if (positionModel.totalRiskDollar != 0) {
        riskExposureLabel.textColor = [StockConstant PriceDownColor];
    }else{
        riskExposureLabel.textColor = [UIColor blackColor];
        riskExposurePercentLabel.textColor = [UIColor blackColor];
    }
    
    float totalRiskRatio = 0;
    totalRiskRatio = positionModel.totalRiskDollar*positionModel.suggestCount / positionModel.netWorth;
    riskExposureLabel.text = [NSString stringWithFormat:@"$%@", [self determineCountry:positionModel.totalRiskDollar * positionModel.suggestCount Decimal:0 IsInfo:YES]];
    if ([positionModel.positionDataArray count] == 0) {
        riskExposurePercentLabel.text = @"----";
    }else if(totalRiskRatio == 0){
        riskExposurePercentLabel.text = @"(0.00%)";
    }else{
        riskExposurePercentLabel.text = [NSString stringWithFormat:@"(%.2f%%)", totalRiskRatio * 100];
        riskExposurePercentLabel.textColor = [StockConstant PriceDownColor];
    }
}

#pragma mark - Alert Timer
-(void)alertTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(showAlert:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)showAlert:(NSTimer *)timer{
    time ++;
    for (NSString *aKey in [alertDict allKeys]) {
        UILabel *label = [alertDict objectForKey:aKey];
        [label.layer removeAllAnimations];
        if (time % 2 == 0) {
            label.layer.backgroundColor = [UIColor yellowColor].CGColor;
        }else{
            label.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
    }
}

#pragma mark - Button Action
-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:moreOptionButton] || [btn isEqual:moreOptionBtnNav]) {
        zeroOptionButton.selected = NO;
        moreOptionButton.selected = YES;
        zeroOptionBtnNav.selected = NO;
        moreOptionBtnNav.selected = YES;
    }else if ([btn isEqual:zeroOptionButton] || [btn isEqual:zeroOptionBtnNav]){
        zeroOptionButton.selected = YES;
        moreOptionButton.selected = NO;
        zeroOptionBtnNav.selected = YES;
        moreOptionBtnNav.selected = NO;
    }
    [self initData];
    [self showInfoViewData];
}

-(void)InventedFundsTapped:(FSUIButton *)sender{
    FSInvestedViewController *term = [[FSInvestedViewController alloc] init];
    [self.navigationController pushViewController:term animated:NO];
    if (moreOptionButton.selected == YES) {
        term.termStr = @"Long";
    }else{
        term.termStr = @"Short";
    }
}

-(void)NetAssetsTapped:(FSUIButton *)sender{
    NetWorthViewController * netWorthView =[[NetWorthViewController alloc] init];
    [self.navigationController pushViewController:netWorthView animated:NO];
    if (moreOptionButton.selected == YES) {
        netWorthView.termStr = @"Long";
    }else{
        netWorthView.termStr = @"Short";
    }
    netWorthView.dealStr = @"BUY";
}

-(void)hBtnAction:(FSUIButton *)sender{
    positions =[positionArray objectAtIndex:sender.tag];

    FSTradeHistoryViewController *tradeHistoryView = [[FSTradeHistoryViewController alloc] init];
    if (moreOptionButton.selected == YES) {
        tradeHistoryView.termStr = @"Long";
    }else{
        tradeHistoryView.termStr = @"Short";
    }
    tradeHistoryView.symbolStr = positions.identCodeSymbol;
    [self.navigationController pushViewController:tradeHistoryView animated:NO];
}

-(void)nBtnAction:(FSUIButton *)sender{
    positions =[positionArray objectAtIndex:sender.tag];

    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePortRelateKLine showAlertViewToShopping:YES]) {
        
        NSString *idSymbol =positions.identCodeSymbol;
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (moreOptionButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:positions.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:positions.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:positionModel.dateFormatter];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"BUY"] || [[dict objectForKey:@"Deal"] isEqualToString:@"COVER"]) {
                data->arrowType = 1;
            }else{
                data->arrowType = 2;
            }
            data->type = [dict objectForKey:@"Deal"];
            data->date = [dict objectForKey:@"Date"];
            data->note = [dict objectForKey:@"Note"];
            data->reason = [dict objectForKey:@"Reason"];
            
            NSDate * date  = [dateFormatter dateFromString:data->date];
            
            NSMutableDictionary * sameDateDic = [dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
            if (sameDateDic) {
                [sameDateDic setObject:data forKey:[dict objectForKey:@"Deal"]];
            }else{
                sameDateDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:data,[dict objectForKey:@"Deal"], nil];
            }
            
            [dataDictionary setObject:sameDateDic forKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
        }
        
        DrawAndScrollController *viewController = [[DrawAndScrollController alloc] init];
        viewController.analysisPeriod = AnalysisPeriodDay;
        viewController.dateDictionary = dataDictionary;
        viewController.arrowType = AnalysisPeriodDay;
        viewController.arrowUpDownType = 4;
        [self.navigationController pushViewController:viewController animated:NO];
    }

}

-(void)gBtnAction:(FSUIButton *)sender{
    positions =[positionArray objectAtIndex:sender.tag];

    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePortRelateKLine showAlertViewToShopping:YES]) {
        
        NSString *idSymbol =positions.identCodeSymbol;
        
        //        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        
        dataModal.indicator.bottomView1Indicator = 14;
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (moreOptionButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:positions.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:positions.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:positionModel.dateFormatter];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"BUY"] || [[dict objectForKey:@"Deal"] isEqualToString:@"COVER"]) {
                data->arrowType = 1;
            }else{
                data->arrowType = 2;
            }
            data->type = [dict objectForKey:@"Deal"];
            data->date = [dict objectForKey:@"Date"];
            data->note = [dict objectForKey:@"Note"];
            data->reason = [dict objectForKey:@"Reason"];
            
            NSDate * date  = [dateFormatter dateFromString:data->date];
            
            NSMutableDictionary * sameDateDic = [dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
            if (sameDateDic) {
                [sameDateDic setObject:data forKey:[dict objectForKey:@"Deal"]];
            }else{
                sameDateDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:data,[dict objectForKey:@"Deal"], nil];
            }
            
            [dataDictionary setObject:sameDateDic forKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
        }
        
        NSMutableArray *gainDataArray = [[NSMutableArray alloc] init];
        NSMutableDictionary * gainDataDictionary = [[NSMutableDictionary alloc]init];
        if (moreOptionButton.selected == YES) {
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Long" DealBuy:@"BUY" DealSell:@"SELL"];
        }else{
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Short" DealBuy:@"SHORT" DealSell:@"COVER"];
        }
        
        for (int i = 0; i < [gainDataArray count]; i++) {
            float totalBuy = 0;
            float totalSell = 0;
            float count = 0;
            
            totalBuy = [(NSNumber *)[[gainDataArray objectAtIndex:i] objectForKey:@"TotalBuy"] floatValue];
            totalSell = fabsf([(NSNumber *)[[gainDataArray objectAtIndex:i] objectForKey:@"TotalSell"] floatValue]);
            count = fabsf([(NSNumber *)[[gainDataArray objectAtIndex:i] objectForKey:@"Count"] floatValue]);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:positionModel.dateFormatter];
            NSDate * date  = [dateFormatter dateFromString:[[gainDataArray objectAtIndex:i] objectForKey:@"Date"]];
            UInt16 dateInt = [CodingUtil makeDateFromDate:date];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithFloat:totalBuy] forKey:@"totalBuy"];
            [dict setObject:[NSNumber numberWithFloat:totalSell] forKey:@"totalSell"];
            [dict setObject:[NSNumber numberWithFloat:count] forKey:@"count"];
            [gainDataDictionary setObject:dict forKey:[NSNumber numberWithUnsignedInt:dateInt]];
        }
        
        NSDate *beginDate = [dateFormatter dateFromString:[[gainDataArray objectAtIndex:0] objectForKey:@"Date"]];
        UInt16 beginDateInt = [CodingUtil makeDateFromDate:beginDate];
        UInt16 today = [CodingUtil makeDateFromDate:[NSDate date]];
        UInt16 date = beginDateInt;
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
        
        for (int i = beginDateInt; i <= today; i++) {
            NSMutableDictionary * dic = [gainDataDictionary objectForKey:[NSNumber numberWithInt:i]];
            if (dic != nil) {
                date = i;
                
            }else{
                dic = [gainDataDictionary objectForKey:[NSNumber numberWithInt:date]];
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[dic objectForKey:@"totalBuy"] forKey:@"totalBuy"];
            [dict setObject:[dic objectForKey:@"totalSell"] forKey:@"totalSell"];
            [dict setObject:[dic objectForKey:@"count"] forKey:@"count"];
            [dataDict setObject:dict forKey:[NSNumber numberWithUnsignedInt:i]];
        }
        
        DrawAndScrollController *viewController = [[DrawAndScrollController alloc] init];
        viewController.analysisPeriod = AnalysisPeriodDay;
        viewController.dateDictionary = dataDictionary;
        viewController.gainDateDictionary = dataDict;
        viewController.arrowType = AnalysisPeriodDay;
        viewController.arrowUpDownType = 5;
        viewController.status = status;
        [self.navigationController pushViewController:viewController animated:NO];
    }
}

-(void)buttonStatusControll{
    if (status) {
        moreOptionButton.selected = moreOptionBtnNav.selected = YES;
        zeroOptionButton.selected = zeroOptionBtnNav.selected = NO;
    }else{
        moreOptionButton.selected = moreOptionBtnNav.selected = NO;
        zeroOptionButton.selected = zeroOptionBtnNav.selected = YES;
    }
}
#pragma mark - TableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [positionArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"Symbol", @"ActionPlan", nil)];
}

-(NSArray *)columnsFirstInMainTableView{
    return @[NSLocalizedStringFromTable(@"張數", @"Position", nil)];
}

-(NSArray *)columnsSecondInMainTableView{
    if (moreOptionButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"買進均價", @"Position", nil), NSLocalizedStringFromTable(@"總成本", @"Position", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"放空均價", @"Position", nil), NSLocalizedStringFromTable(@"總成本", @"Position", nil)];
    }
}

-(NSArray *)columnsThirdInMainTableView{
    return @[NSLocalizedStringFromTable(@"現價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"價值", @"Position", nil)];
}

-(NSArray *)columnsFourthInMainTableView{
    return @[NSLocalizedStringFromTable(@"獲利", @"Position", nil), NSLocalizedStringFromTable(@"曝險金額", @"Position", nil)];
}

-(void)updateFixedTableViewCellSymbolLabel:(UILabel *)symbolLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSPositionFixedTableViewCell *)cell{
    positions = [positionArray objectAtIndex:indexPath.row];
    NSString *string = positions.identCodeSymbol;
    NSString *identCode = [string substringToIndex:2];
    NSString *symbol = [string substringFromIndex:3];
    NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
    symbolLabel.textColor = [UIColor blueColor];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        symbolLabel.text = symbol;
    }else {
        symbolLabel.text = fullName;
    }
    
    if ((positions.riskDollar * positionModel.suggestCount / positionModel.netWorth) * 100 > 2) {
        symbolLabel.tag = 1;
        [alertDict setObject:symbolLabel forKey:positions.identCodeSymbol];
    }
}

-(void)updateMainTableViewCellqtyLabel:(UILabel *)qtyLabel avgCostLabel:(UILabel *)avgCostLabel totalCostLabel:(UILabel *)totalCostLabel lastLabel:(UILabel *)lastLabel totalValLabel:(UILabel *)totalValLabel gainLabel:(UILabel *)gainLabel gainPercentLabel:(UILabel *)gainPercentLabel riskLabel:(UILabel *)riskLabel riskPercentLabel:(UILabel *)riskPercentLabel hBtn:(FSUIButton *)hBtn nBtn:(FSUIButton *)nBtn gBtn:(FSUIButton *)gBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSPositionMainTableViewCell *)cell{
    positions = [positionArray objectAtIndex:indexPath.row];
    
    //股數
    qtyLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:positions.qty DecimalPoint:0]];
    
    //平均成本
    avgCostLabel.text = [self determineCountry:positions.avgCost Decimal:2 IsInfo:NO];
    
    //總成本
    totalCostLabel.text = [self determineCountry:positions.total * positionModel.suggestCount Decimal:0 IsInfo:NO];
    
    //現價
    if (positions.cng > 0) {
        if (zeroOptionBtnNav.selected || zeroOptionButton.selected) {
            lastLabel.textColor = [StockConstant PriceDownColor];
        }else{
            lastLabel.textColor = [StockConstant PriceUpColor];
        }
        
    }else if (positions.cng < 0){
        if (zeroOptionBtnNav.selected || zeroOptionButton.selected) {
            lastLabel.textColor = [StockConstant PriceUpColor];
        }else{
            lastLabel.textColor = [StockConstant PriceDownColor];
        }
    }else{
        lastLabel.textColor = [UIColor blueColor];
    }

    lastLabel.text = [self determineCountry:positions.last Decimal:2 IsInfo:NO];
    if (isnan(positions.cng)) {
        lastLabel.text = @"----";
    }
    //價值
    totalValLabel.text = [self determineCountry:positions.totalVal * positionModel.suggestCount Decimal:0 IsInfo:NO];
    
    //獲利
    if ((positions.gainDollar) * positionModel.suggestCount == 0/* || abs(positions.gainDollar * positionModel.suggestCount) < 1*/){
        gainLabel.textColor = [UIColor blueColor];
        gainPercentLabel.textColor = [UIColor blueColor];
        gainLabel.text = @"0";
        gainPercentLabel.text = @"(0.00%)";

    }else if ((positions.gainDollar) * positionModel.suggestCount > 0) {
        gainLabel.textColor = [StockConstant PriceUpColor];
        gainPercentLabel.textColor = [StockConstant PriceUpColor];
    }else{
        gainLabel.textColor = [StockConstant PriceDownColor];
        gainPercentLabel.textColor = [StockConstant PriceDownColor];
    }
    gainLabel.text = [self determineCountry:positions.gainDollar * positionModel.suggestCount Decimal:0 IsInfo:YES];
    gainPercentLabel.text = [NSString stringWithFormat:@"(%@%%)", [CodingUtil CoverFloatWithComma:positions.gainPercent*100 DecimalPoint:2]];
    
    //曝險金額
    riskLabel.textColor = [StockConstant PriceDownColor];
    riskPercentLabel.textColor = [StockConstant PriceDownColor];
    riskLabel.text = [self determineCountry:positions.riskDollar * positionModel.suggestCount Decimal:0 IsInfo:YES];
    
    //曝險金額(%)
    if (!positionModel.netWorth == 0 && lastFund != 0) {
        riskPercentLabel.text = [NSString stringWithFormat:@"(%@%%)", [CodingUtil CoverFloatWithComma:(positions.riskDollar*positionModel.suggestCount / positionModel.netWorth) * 100 DecimalPoint:2]];
    }else{
        riskPercentLabel.text = @"(0.00%)";
    }
    
    if ((positions.riskDollar*positionModel.suggestCount / positionModel.netWorth) * 100 > 2) {
        riskLabel.tag = 2;
        riskPercentLabel.tag = 3;
        [alertDict setObject:riskLabel forKey:[NSString stringWithFormat:@"%@Risk", positions.identCodeSymbol]];
        [alertDict setObject:riskPercentLabel forKey:[NSString stringWithFormat:@"%@RiskPercent", positions.identCodeSymbol]];
    }
    
    hBtn.tag = indexPath.row;
    [hBtn addTarget:self action:@selector(hBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    nBtn.tag = indexPath.row;
    [nBtn addTarget:self action:@selector(nBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    gBtn.tag = indexPath.row;
    [gBtn addTarget:self action:@selector(gBtnAction:) forControlEvents:UIControlEventTouchUpInside];

}

-(NSString *)determineCountry:(double)price Decimal:(int)decimal IsInfo:(BOOL)isInfo{
    NSString *returnStr = @"";
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){
        returnStr = [CodingUtil CoverFloatWithComma:price DecimalPoint:decimal];
    }else if([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
        if (isInfo) {
            returnStr = [CodingUtil CoverFloatWithCommaPositionInfoForCN:price];
        }else{
            returnStr = [CodingUtil CoverFloatWithCommaPositionForCN:price];
        }
    }else{
        returnStr = [CodingUtil CoverFloatWithCommaPositionInfoForCN:price];
    }
    return returnStr;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    positions = [positionArray objectAtIndex:indexPath.row];
    NSString *idSymbol =positions.identCodeSymbol;
    
    FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
    watchedPortfolio.portfolioItem = portfolioItem;
    mainViewController.firstLevelMenuOption = 1;
    [self.navigationController pushViewController:mainViewController animated:NO];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.view setNeedsUpdateConstraints];
    [self setNavigationBtn];
}

-(UIColor *)setTextColor:(double)price{
    if (price != 0) {
        return [StockConstant PriceUpColor];
    }else{
        return [UIColor blackColor];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
@end
