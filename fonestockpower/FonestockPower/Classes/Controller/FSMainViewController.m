//
//  FSMainViewController.m
//  FonestockPower
//
//  Created by Connor on 14/3/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainViewController.h"
#import "UIView+FindUIViewController.h"
#import "UIView+NewComponent.h"
#import "FSRadioButtonSet.h"
#import "FSEquityDrawViewController.h"
#import "RealtimeListController.h"
#import "FSPriceByVolumeTableViewController.h"
#import "FSPriceVolumeViewController.h"
#import "DrawAndScrollController.h"
#import "TWCompanyProfileViewController.h"
#import "CompanyProfilePage1ViewController.h"
#import "TempCompanyProfileOnlyPage1ForCN.h"
#import "CompanyProfilePage2ViewController.h"
#import "CompanyProfilePage3ViewController.h"
#import "CompanyProfilePage4ViewController.h"
#import "CompanyProfilePage5ViewController.h"
#import "RevenueViewController.h"
#import "FSHistoricalEPSViewController.h"
#import "FinancialViewController.h"
#import "ChangeStockViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "MarqueeLabel.h"
#import "FSNavigationViewController.h"
#import "StockHolderMeetingViewController.h"
#import "FSMainForceViewController.h"
#import "InstitutionalBSViewController.h"
#import "MarginTradingViewController.h"
#import "TodayReserveViewController.h"
#import "RelatedNewsListViewController.h"
#import "PowerPPPViewController.h"
#import "PowerTwoPViewController.h"
#import "FSMainPlusViewController.h"
#import "FSNewPriceByVolumeViewController.h"


#define BUTTON_WIDTH 80
#define SCROLLVIEW_HEIGHT 44

typedef NS_ENUM(NSInteger, FSMainViewRowType) {
    FSMainViewRowType1,
    FSMainViewRowType2
};

@interface FSMainViewController () <FSRadioButtonSetDelegate, UIScrollViewDelegate> {
    FSDataModelProc *dataModel;
    
    UIToolbar *toolbar;
    
    FSRadioButtonSet *firstLevelMenu;
    FSRadioButtonSet *quoteLevel2Menu;
    FSRadioButtonSet *basicLevel2Menu;
    FSRadioButtonSet *cyqLevel2Menu;
    
    FSUIButton *level1QuoteButton;
    FSUIButton *level1TechButton;
    FSUIButton *level1BasicButton;
    
    // 台股專用
    FSUIButton *level1CYQButton;
    FSUIButton *level1NewsButton;
    
    
    FSUIButton *backButton;
    FSUIButton *changeStockButton;
    MarqueeLabel * changeStockNameLabel;
    UILabel * changeStockSymbolLabel;

    // second level
    FSUIButton *chartButton;
    FSUIButton *listButton;
    FSUIButton *distButton;
    FSUIButton *psButton;
    
    // second level
    FSUIButton *profileButton;
    FSUIButton *revButton;
    FSUIButton *epsButton;
    FSUIButton *xDXRButton;
    FSUIButton *financeButton;
    
    // second level
    FSUIButton *todayStockButton;
    FSUIButton *marginTradingButton;
    FSUIButton *institudeButton;
    FSUIButton *powerplusButton;
    FSUIButton *powerPButton;
    FSUIButton *powerPPButton;
    FSUIButton *powerPPPButton;
    
    UIView *level1MenuView;
    UIView *level2MenuView;
    UIView *mainframeView;
    
    UIView *secondLevelMenuQuoteView;
    UIView *secondLevelMenuBasicView;

#ifdef StockPowerTW
    /////////
    UIScrollView *secondLevelMenuCYQView;
#else
    UIView *secondLevelMenuCYQView;
#endif
    
    NSMutableArray *layoutConstraints;
    
    NSMutableArray *layoutConstraintOneLevelMenu;
    NSMutableArray *layoutConstraintTwoLevelMenu;
    
    FSMainViewRowType mainViewRowType;
    
    NSString *identCode;
    
}

@end

@implementation FSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    FSInstantInfoWatchedPortfolio * _watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    PortfolioItem * portfolioItem = _watchPortfolio.portfolioItem;
    if (portfolioItem !=nil){
        changeStockNameLabel.text = portfolioItem->fullName;
        changeStockSymbolLabel.text = portfolioItem->symbol;
        identCode = [NSString stringWithFormat:@"%c%c", portfolioItem->identCode[0], portfolioItem->identCode[1]];
    } else {
        
#ifdef PatternPowerUS
        identCode = @"US";
#endif
        
#ifdef PatternPowerTW
        identCode = @"TW";
#endif
        
#ifdef PatternPowerCN
        identCode = @"CN";
#endif
        
    }
    
    [self constructUIComponents];
    
    if (!_firstLevelMenuOption) {
        _firstLevelMenuOption = QuoteMenuItem;
        
    } else if (_firstLevelMenuOption == BasicMenuItem){
        if (_secondBasicMenuOption){
            basicLevel2Menu.selectedIndex = _secondBasicMenuOption;
        }
    } else if (_firstLevelMenuOption == ChipMenuItem){
        if (_secondChipMenuOption){
            cyqLevel2Menu.selectedIndex = _secondChipMenuOption;
            
        }
    }
    
//    如果沒選第一層或第二層自動選取第一個
    firstLevelMenu.selectedIndex = _firstLevelMenuOption;
    
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    FSInstantInfoWatchedPortfolio * _watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    PortfolioItem * portfolioItem = _watchPortfolio.portfolioItem;
    if (portfolioItem !=nil){
        changeStockNameLabel.text = portfolioItem->fullName;
        changeStockSymbolLabel.text = portfolioItem->symbol;
        identCode = [NSString stringWithFormat:@"%c%c", portfolioItem->identCode[0], portfolioItem->identCode[1]];
        if (portfolioItem->type_id == 3 || portfolioItem->type_id == 6) {
            psButton.hidden = YES;
        }else{
            psButton.hidden = NO;
        }
#ifdef LPCB
        [portfolioItem setTickFocus];
#endif
    }
//    即時的內頁選擇換股後都跳回走勢
    if (firstLevelMenu.selectedIndex == QuoteMenuItem){
        if (![_mainViewController isKindOfClass:[FSEquityDrawViewController class]]) {
            if (quoteLevel2Menu.selectedIndex != ChartMenuItem) {
                quoteLevel2Menu.selectedIndex = ChartMenuItem;
            }
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated {
#ifdef LPCB
    FSInstantInfoWatchedPortfolio * _watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    PortfolioItem * portfolioItem = _watchPortfolio.portfolioItem;
    if (portfolioItem != nil){
        [portfolioItem killTickFocus];
    }

#endif
    [super viewWillDisappear:animated];
    
}

- (void)buttonClick:(UIButton *)button {
    [button setSelected:YES];
}
- (void)constructUIComponents {
    
    layoutConstraints = [[NSMutableArray alloc] init];
    layoutConstraintOneLevelMenu = [[NSMutableArray alloc] initWithCapacity:3];
    layoutConstraintTwoLevelMenu = [[NSMutableArray alloc] initWithCapacity:3];
    
    /*
     第一層選單
     */
    backButton = [self.view newButton:FSUIButtonTypeBlackLeftArrow];
    [backButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    changeStockButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [changeStockButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    level1QuoteButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [level1QuoteButton setTitle:NSLocalizedStringFromTable(@"即時", @"Equity", @"走勢") forState:UIControlStateNormal];
    [level1QuoteButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];

    level1TechButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [level1TechButton setTitle:NSLocalizedStringFromTable(@"技術", @"Equity", @"技術") forState:UIControlStateNormal];
    [level1TechButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];

    level1BasicButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [level1BasicButton setTitle:NSLocalizedStringFromTable(@"基本", @"Equity", @"基本") forState:UIControlStateNormal];
    [level1BasicButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];

    // 台股含即時, 技術, 基本面, 籌碼面, 新聞
    if ([@"TW" isEqualToString:identCode]) {
        level1CYQButton = [self.view newButton:FSUIButtonTypeNormalRed];
        [level1CYQButton setTitle:NSLocalizedStringFromTable(@"籌碼", @"Equity", @"籌碼") forState:UIControlStateNormal];
        [level1CYQButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
#ifdef PatternPowerTW
        firstLevelMenu = [[FSRadioButtonSet alloc] initWithButtonArray:@[level1QuoteButton, level1TechButton, level1BasicButton, level1CYQButton] andDelegate:self];
#else
        level1NewsButton = [self.view newButton:FSUIButtonTypeNormalRed];
        [level1NewsButton setTitle:NSLocalizedStringFromTable(@"新聞", @"Equity", @"新聞") forState:UIControlStateNormal];
        [level1NewsButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        firstLevelMenu = [[FSRadioButtonSet alloc] initWithButtonArray:@[level1QuoteButton, level1TechButton, level1BasicButton, level1CYQButton, level1NewsButton] andDelegate:self];
#endif
        
    
    }
    // 美/陸股目前只有即時, 技術, 基本面
    else if ([@"US" isEqualToString:identCode] || [@"SS" isEqualToString:identCode] || [@"SZ" isEqualToString:identCode]) {
        firstLevelMenu = [[FSRadioButtonSet alloc] initWithButtonArray:@[level1QuoteButton, level1TechButton, level1BasicButton] andDelegate:self];
    }
    
    
    /*
     第二層選單
     */
    
    mainframeView = [[UIView alloc] init];
    mainframeView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:mainframeView];
    
    level2MenuView = [[UIView alloc] init];
    level2MenuView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:level2MenuView];
    
    secondLevelMenuQuoteView = [[UIView alloc] init];
    secondLevelMenuQuoteView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [level2MenuView addSubview:secondLevelMenuQuoteView];
    
    secondLevelMenuBasicView = [[UIView alloc] init];
    secondLevelMenuBasicView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [level2MenuView addSubview:secondLevelMenuBasicView];


#ifdef StockPowerTW
    ///////
    secondLevelMenuCYQView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCROLLVIEW_HEIGHT)];
    
    secondLevelMenuCYQView.userInteractionEnabled = YES;
    secondLevelMenuCYQView.scrollEnabled = YES;
    secondLevelMenuCYQView.delegate = self;
    secondLevelMenuCYQView.pagingEnabled = YES;
    secondLevelMenuCYQView.bounces = NO;
#else
    secondLevelMenuCYQView = [[UIView alloc] init];
    //WithFrame:CGRectMake(0, 0, self.view.frame.size.width, SCROLLVIEW_HEIGHT)
    secondLevelMenuCYQView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
#endif
//    secondLevelMenuCYQView.translatesAutoresizingMaskIntoConstraints = NO;
    [level2MenuView addSubview:secondLevelMenuCYQView];

    
    chartButton = [secondLevelMenuQuoteView newButton:FSUIButtonTypeNormalRed];
    [chartButton setTitle:NSLocalizedStringFromTable(@"走勢", @"Equity", @"走勢") forState:UIControlStateNormal];
    [chartButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    listButton = [secondLevelMenuQuoteView newButton:FSUIButtonTypeNormalRed];
    [listButton setTitle:NSLocalizedStringFromTable(@"明細", @"Equity", @"明細") forState:UIControlStateNormal];
    [listButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    distButton = [secondLevelMenuQuoteView newButton:FSUIButtonTypeNormalRed];
    [distButton setTitle:NSLocalizedStringFromTable(@"分價表", @"Equity", @"分價表") forState:UIControlStateNormal];
    [distButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    psButton = [secondLevelMenuQuoteView newButton:FSUIButtonTypeNormalRed];
    [psButton setTitle:NSLocalizedStringFromTable(@"支壓圖", @"Equity", @"支壓圖") forState:UIControlStateNormal];
    [psButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    quoteLevel2Menu = [[FSRadioButtonSet alloc] initWithButtonArray:@[chartButton, listButton, distButton, psButton] andDelegate:self];
    
    
    profileButton = [secondLevelMenuBasicView newButton:FSUIButtonTypeNormalRed];
    [profileButton setTitle:NSLocalizedStringFromTable(@"公司", @"Equity", @"公司") forState:UIControlStateNormal];
    [profileButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    revButton = [secondLevelMenuBasicView newButton:FSUIButtonTypeNormalRed];
    [revButton setTitle:NSLocalizedStringFromTable(@"營收", @"Equity", @"營收") forState:UIControlStateNormal];
    [revButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    // 台股
    if ([@"TW" isEqualToString:identCode]) {
        // 台股基本面
        xDXRButton = [secondLevelMenuBasicView newButton:FSUIButtonTypeNormalRed];
        [xDXRButton setTitle:NSLocalizedStringFromTable(@"除權息", @"Equity", @"除權息") forState:UIControlStateNormal];
        [xDXRButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // 台股籌碼面
        todayStockButton = [secondLevelMenuCYQView newButton:FSUIButtonTypeNormalRed];
        [todayStockButton setTitle:NSLocalizedStringFromTable(@"庫存", @"Equity", @"庫存") forState:UIControlStateNormal];
        [todayStockButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        marginTradingButton = [secondLevelMenuCYQView newButton:FSUIButtonTypeNormalRed];
        [marginTradingButton setTitle:NSLocalizedStringFromTable(@"融資券", @"Equity", @"融資券") forState:UIControlStateNormal];
        [marginTradingButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        institudeButton = [secondLevelMenuCYQView newButton:FSUIButtonTypeNormalRed];
        [institudeButton setTitle:NSLocalizedStringFromTable(@"三大", @"Equity", @"三大") forState:UIControlStateNormal];
        [institudeButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        powerplusButton = [secondLevelMenuCYQView newButton:FSUIButtonTypeNormalRed];
        [powerplusButton setTitle:NSLocalizedStringFromTable(@"主力", @"Equity", @"主力") forState:UIControlStateNormal];
        [powerplusButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    

#ifdef StockPowerTW
        ///////

        powerPButton = [secondLevelMenuCYQView newButton:FSUIButtonTypeNormalRed];
        [powerPButton setTitle:NSLocalizedStringFromTable(@"主力+", @"Equity", @"主力+") forState:UIControlStateNormal];
        [powerPButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        powerPPButton = [secondLevelMenuCYQView newButton:FSUIButtonTypeNormalRed];
        [powerPPButton setTitle:NSLocalizedStringFromTable(@"主力++", @"Equity", @"主力++") forState:UIControlStateNormal];
        [powerPPButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        powerPPPButton = [secondLevelMenuCYQView newButton:FSUIButtonTypeNormalRed];
        [powerPPPButton setTitle:NSLocalizedStringFromTable(@"主力+++", @"Equity", @"主力+++") forState:UIControlStateNormal];
        [powerPPPButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        cyqLevel2Menu = [[FSRadioButtonSet alloc] initWithButtonArray:@[todayStockButton, marginTradingButton, institudeButton, powerplusButton, powerPButton, powerPPButton, powerPPPButton] andDelegate:self];
#else
        cyqLevel2Menu = [[FSRadioButtonSet alloc] initWithButtonArray:@[todayStockButton, marginTradingButton, institudeButton, powerplusButton] andDelegate:self];
#endif
        
    }
    
    epsButton = [secondLevelMenuBasicView newButton:FSUIButtonTypeNormalRed];
    [epsButton setTitle:NSLocalizedStringFromTable(@"EPS", @"Equity", @"EPS") forState:UIControlStateNormal];
    [epsButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    financeButton = [secondLevelMenuBasicView newButton:FSUIButtonTypeNormalRed];
    [financeButton setTitle:NSLocalizedStringFromTable(@"財報", @"Equity", @"財報") forState:UIControlStateNormal];
    [financeButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    financeButton.hidden = YES;
    
    if ([@"TW" isEqualToString:identCode]) {
        basicLevel2Menu = [[FSRadioButtonSet alloc] initWithButtonArray:@[profileButton, revButton, xDXRButton, epsButton, financeButton] andDelegate:self];
    }
    else if ([@"US" isEqualToString:identCode] || [@"SS" isEqualToString:identCode] || [@"SZ" isEqualToString:identCode]) {
        basicLevel2Menu = [[FSRadioButtonSet alloc] initWithButtonArray:@[profileButton, revButton, epsButton, financeButton] andDelegate:self];

    }
    
    changeStockNameLabel = [[MarqueeLabel alloc]init];
    changeStockNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [changeStockNameLabel setLabelize:NO];
    changeStockNameLabel.marqueeType = 4;
    changeStockNameLabel.continuousMarqueeExtraBuffer = 30.0f;
    changeStockNameLabel.lineBreakMode = NSLineBreakByClipping;
    [changeStockNameLabel setTextAlignment:NSTextAlignmentCenter];
    changeStockNameLabel.backgroundColor = [UIColor clearColor];
    changeStockNameLabel.textColor = [UIColor whiteColor];
    changeStockNameLabel.font = [UIFont systemFontOfSize:18.0f];
    
    changeStockSymbolLabel = [[UILabel alloc]init];
    changeStockSymbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [changeStockSymbolLabel setTextAlignment:NSTextAlignmentCenter];
    changeStockSymbolLabel.backgroundColor = [UIColor clearColor];
    changeStockSymbolLabel.textColor = [UIColor whiteColor];
    changeStockSymbolLabel.font = [UIFont systemFontOfSize:14.0f];
    
    [changeStockButton addSubview:changeStockNameLabel];
    [changeStockButton addSubview:changeStockSymbolLabel];
}


- (void)setTWSecurityLayout {
    
    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:33]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:33]];
    
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20+5]];
    } else {
        
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:5]];
        
    }
    
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5]];
    

#ifdef PatternPowerTW
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[backButton]-5-[changeStockButton][level1QuoteButton(50)][level1TechButton(level1QuoteButton)][level1BasicButton(level1QuoteButton)][level1CYQButton(level1QuoteButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(backButton, changeStockButton, level1QuoteButton, level1TechButton, level1BasicButton, level1CYQButton)]];
    }
    
#else
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[backButton]-5-[changeStockButton][level1QuoteButton(40)][level1TechButton(40)][level1BasicButton(40)][level1CYQButton(40)][level1NewsButton(40)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(backButton, changeStockButton, level1QuoteButton, level1TechButton, level1BasicButton, level1CYQButton, level1NewsButton)]];
#endif
    
    NSDictionary *metrics = @{@"ButtonWidth":@BUTTON_WIDTH};

#ifdef StockPowerTW
    //////////
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[todayStockButton(ButtonWidth)][marginTradingButton(todayStockButton)][institudeButton(todayStockButton)][powerplusButton(todayStockButton)][powerPButton(todayStockButton)][powerPPButton(todayStockButton)][powerPPPButton(todayStockButton)]" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:NSDictionaryOfVariableBindings(todayStockButton, marginTradingButton, institudeButton, powerplusButton, powerPButton, powerPPButton, powerPPPButton)]];
#else
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[todayStockButton(ButtonWidth)][marginTradingButton(todayStockButton)][institudeButton(todayStockButton)][powerplusButton(todayStockButton)]" options:NSLayoutFormatAlignAllBaseline metrics:metrics views:NSDictionaryOfVariableBindings(todayStockButton, marginTradingButton, institudeButton, powerplusButton)]];
#endif
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainframeView)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[level2MenuView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(level2MenuView)]];
    FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    PortfolioItem * portfolioItem = watchPortfolio.portfolioItem;
    if (portfolioItem->type_id==6 || portfolioItem->type_id==3) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[chartButton][listButton(chartButton)][distButton(chartButton)]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(chartButton, listButton, distButton)]];
        psButton.hidden = YES;
    }else{
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[chartButton][listButton(chartButton)][distButton(chartButton)][psButton(chartButton)]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(chartButton, listButton, distButton, psButton)]];
        psButton.hidden = NO;
    }
    

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[chartButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chartButton)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[profileButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(profileButton)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[profileButton][revButton(profileButton)][xDXRButton(profileButton)][epsButton(profileButton)][financeButton(profileButton)]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(profileButton, revButton, xDXRButton, epsButton, financeButton)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[todayStockButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(todayStockButton)]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockSymbolLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockSymbolLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    if (mainViewRowType == FSMainViewRowType1) {
        
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            backButton.hidden = NO;
            changeStockButton.hidden = NO;
            level1QuoteButton.hidden = NO;
            level1TechButton.hidden = NO;
            level1BasicButton.hidden = NO;
            level1CYQButton.hidden = NO;
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton]-6-[mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backButton, mainframeView)]];
        }else{
            backButton.hidden = YES;
            changeStockButton.hidden = YES;
            level1QuoteButton.hidden = YES;
            level1TechButton.hidden = YES;
            level1BasicButton.hidden = YES;
            level1CYQButton.hidden = YES;
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings( mainframeView)]];
        }
        
    }
    else if (mainViewRowType == FSMainViewRowType2) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton]-6-[level2MenuView(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backButton, level2MenuView)]];
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[level2MenuView][mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainframeView, level2MenuView)]];
    }

}

- (void)setUSSecurityLayout {
    
    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:33]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:33]];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5]];
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:20+5]];
    }else{
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5]];
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:5]];
    }
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[backButton]-5-[changeStockButton][level1QuoteButton]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(backButton, changeStockButton, level1QuoteButton)]];

    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:level1QuoteButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:44]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[level1QuoteButton(60)][level1TechButton(60)][level1BasicButton(60)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(backButton, changeStockButton, level1QuoteButton, level1TechButton, level1BasicButton)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainframeView)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[level2MenuView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(level2MenuView)]];

    FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    PortfolioItem * portfolioItem = watchPortfolio.portfolioItem;
    
    if (portfolioItem->type_id==6 || portfolioItem->type_id==3) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[chartButton][listButton(chartButton)][distButton(chartButton)]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(chartButton, listButton, distButton)]];
    }else{
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[chartButton][listButton(chartButton)][distButton(chartButton)][psButton(chartButton)]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(chartButton, listButton, distButton, psButton)]];
    }
    
//    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[chartButton][listButton(chartButton)][distButton(chartButton)][psButton(chartButton)]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(chartButton, listButton, distButton, psButton)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[chartButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chartButton)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[profileButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(profileButton)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[profileButton][revButton(profileButton)][epsButton(profileButton)][financeButton(profileButton)]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(profileButton, revButton, epsButton, financeButton)]];

    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];

    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockNameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockSymbolLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:changeStockSymbolLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:changeStockButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];

    if (mainViewRowType == FSMainViewRowType1) {
//        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton]-6-[mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backButton, mainframeView)]];
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            backButton.hidden = NO;
            changeStockButton.hidden = NO;
            level1QuoteButton.hidden = NO;
            level1TechButton.hidden = NO;
            level1BasicButton.hidden = NO;
            level1CYQButton.hidden = NO;
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton]-6-[mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backButton, mainframeView)]];
        }else{
            backButton.hidden = YES;
            changeStockButton.hidden = YES;
            level1QuoteButton.hidden = YES;
            level1TechButton.hidden = YES;
            level1BasicButton.hidden = YES;
            level1CYQButton.hidden = YES;
            [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings( mainframeView)]];
        }
    }
    else if (mainViewRowType == FSMainViewRowType2) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton]-6-[level2MenuView(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backButton, level2MenuView)]];
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[level2MenuView][mainframeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainframeView, level2MenuView)]];
    }
    
}



- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if ([@"TW" isEqualToString:identCode]) {
        [self setTWSecurityLayout];
    }
    else {
        [self setUSSecurityLayout];
    }
    
    [self.view addConstraints:layoutConstraints];
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super updateViewConstraints];
    
    if ([@"TW" isEqualToString:identCode]) {
        [self setTWSecurityLayout];
    }
    else {
        [self setUSSecurityLayout];
    }
    
    [self.view addConstraints:layoutConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
#ifdef StockPowerTW
    ///////////
    [secondLevelMenuCYQView setContentSize:CGSizeMake(BUTTON_WIDTH * 7, SCROLLVIEW_HEIGHT)];
    if (_secondChipMenuOption > 3) {
        [secondLevelMenuCYQView setContentOffset:CGPointMake(BUTTON_WIDTH * 3, 0) animated:YES];
        
    }
#endif
}

- (void)clickMenu:(UIButton *)button {
    
    if (button == backButton) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else if (button == changeStockButton) {
        ChangeStockViewController * changeStockView = [[ChangeStockViewController alloc]initWithNumber:1];
        [self.navigationController pushViewController:changeStockView animated:NO];
    }
    
}

- (void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex {
    if (firstLevelMenu == controller) {
        UIButton *clickButton = [firstLevelMenu.buttons objectAtIndex:selectedIndex];
        if (clickButton == level1QuoteButton) {
            [self setScreen];
            if (mainViewRowType == FSMainViewRowType1) {
                mainViewRowType = FSMainViewRowType2;
                [self.view setNeedsUpdateConstraints];
            }
            
            if (quoteLevel2Menu.selectedIndex == NSNotFound) {
                quoteLevel2Menu.selectedIndex = 0;  // 第一個
            } else {
                quoteLevel2Menu.selectedIndex = quoteLevel2Menu.selectedIndex;
            }
            level2MenuView.userInteractionEnabled = YES;
            secondLevelMenuQuoteView.hidden = NO;
            secondLevelMenuBasicView.hidden = YES;
            secondLevelMenuCYQView.hidden = YES;
        }
        else if (clickButton == level1TechButton) {
            if (mainViewRowType == FSMainViewRowType2) {
                mainViewRowType = FSMainViewRowType1;
                [self.view setNeedsUpdateConstraints];
            }
            level2MenuView.userInteractionEnabled = NO;
            secondLevelMenuQuoteView.hidden = YES;
            secondLevelMenuBasicView.hidden = YES;
            secondLevelMenuCYQView.hidden = YES;
            
            DrawAndScrollController *viewController = [[DrawAndScrollController alloc] init];
            viewController.analysisPeriod = _techOption;
            viewController.arrowDate = _arrowDate;
            viewController.dateDictionary = _dateDictionary;
            viewController.gainDateDictionary = _gainDateDictionary;
            viewController.arrowType = _arrowType;
            viewController.buyDay = _buyDay;
            viewController.sellDay = _sellDay;
            viewController.arrowUpDownType = _arrowUpDownType;
            viewController.performanceNum = _performanceNum;
            viewController.performanceNote = _performanceNote;
            viewController.status = _status;
            [self insertViewControllerInMainFrameView:viewController];
        }
        else if (clickButton == level1BasicButton) {
            [self setScreen];
            if (mainViewRowType == FSMainViewRowType1) {
                mainViewRowType = FSMainViewRowType2;
                [self.view setNeedsUpdateConstraints];
            }
            
            if (basicLevel2Menu.selectedIndex == NSNotFound) {
                basicLevel2Menu.selectedIndex = 0;  // 第一個
            } else {
                basicLevel2Menu.selectedIndex = basicLevel2Menu.selectedIndex;
            }
            level2MenuView.userInteractionEnabled = YES;
            secondLevelMenuQuoteView.hidden = YES;
            secondLevelMenuBasicView.hidden = NO;
            secondLevelMenuCYQView.hidden = YES;
        }
        else if (clickButton == level1CYQButton) {
            [self setScreen];
            if (mainViewRowType == FSMainViewRowType1) {
                mainViewRowType = FSMainViewRowType2;
                [self.view setNeedsUpdateConstraints];
            }
            
            if (cyqLevel2Menu.selectedIndex == NSNotFound) {
                cyqLevel2Menu.selectedIndex = 0;  // 第一個
            } else {
                cyqLevel2Menu.selectedIndex = cyqLevel2Menu.selectedIndex;
            }
            level2MenuView.userInteractionEnabled = YES;
            secondLevelMenuQuoteView.hidden = YES;
            secondLevelMenuBasicView.hidden = YES;
            secondLevelMenuCYQView.hidden = NO;
        }
        else if (clickButton == level1NewsButton) {
            if (mainViewRowType == FSMainViewRowType2) {
                mainViewRowType = FSMainViewRowType1;
                [self.view setNeedsUpdateConstraints];
            }
            level2MenuView.userInteractionEnabled = NO;
            secondLevelMenuQuoteView.hidden = YES;
            secondLevelMenuBasicView.hidden = YES;
            secondLevelMenuCYQView.hidden = YES;
            
            // NewsController in
            RelatedNewsListViewController *viewController = [[RelatedNewsListViewController alloc] init];
            [self insertViewControllerInMainFrameView:viewController];
        }
    } else {
        if (quoteLevel2Menu == controller) {
            
            UIButton *clickButton = [quoteLevel2Menu.buttons objectAtIndex:selectedIndex];
            if (clickButton == chartButton) {
                FSEquityDrawViewController *viewController = [[FSEquityDrawViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == listButton) {
                RealtimeListController *viewController = [[RealtimeListController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == distButton) {
                FSNewPriceByVolumeViewController *viewController = [[FSNewPriceByVolumeViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == psButton) {
                FSPriceVolumeViewController *viewController = [[FSPriceVolumeViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
        }
        else if (basicLevel2Menu == controller) {
            
            UIButton *clickButton = [basicLevel2Menu.buttons objectAtIndex:selectedIndex];
            if (clickButton == profileButton) {
                UIViewController *viewController;
                if ([@"US" isEqualToString:identCode]) {
                    viewController = [[CompanyProfilePage1ViewController alloc] init];
                    [self insertViewControllerInMainFrameView:viewController];
                }
                else if ([@"TW" isEqualToString:identCode]) {
                    TWCompanyProfileViewController *viewController = [TWCompanyProfileViewController pageControlWithViewControllerClassName:@[@"CompanyProfilePage1ViewController", @"CompanyProfilePage2ViewController", @"CompanyProfilePage3ViewController", @"CompanyProfilePage4ViewController",@"CompanyProfilePage5ViewController"]];
                    viewController.currentPage = 0;
                    [self insertViewControllerInMainFrameView:viewController];
                
                }
                else if([@"SS" isEqualToString:identCode] || [@"SZ" isEqualToString:identCode]){
                    TWCompanyProfileViewController *viewController = [TWCompanyProfileViewController pageControlWithViewControllerClassName:@[@"TempCompanyProfileOnlyPage1ForCN"]];
                    viewController.currentPage = 0;
                    [self insertViewControllerInMainFrameView:viewController];
                }
            }
            else if (clickButton == revButton) {
                RevenueViewController *viewController = [RevenueViewController pageControlWithViewControllerClassName:@[@"RevenueController",                                                        @"RevenueChartViewController"]];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == epsButton) {
                FSHistoricalEPSViewController *viewController = [[FSHistoricalEPSViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == financeButton) {
                FinancialViewController *viewController = [[FinancialViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == xDXRButton){
                StockHolderMeetingViewController *viewController = [[StockHolderMeetingViewController alloc]init];
                [self insertViewControllerInMainFrameView:viewController];
            }
        }
        else if (cyqLevel2Menu == controller) {
            
            UIButton *clickButton = [cyqLevel2Menu.buttons objectAtIndex:selectedIndex];
            if (clickButton == todayStockButton) {
                TodayReserveViewController *viewController = [[TodayReserveViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == marginTradingButton) {
                MarginTradingViewController *viewController = [[MarginTradingViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == institudeButton) {
                InstitutionalBSViewController *viewController = [[InstitutionalBSViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == powerplusButton) {
                FSMainForceViewController *viewController = [[FSMainForceViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
#ifdef StockPowerTW
            //////////
            else if (clickButton == powerPButton) {
                FSMainForceViewController *viewController = (FSMainForceViewController *)[[FSMainPlusViewController alloc] init];

                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == powerPPButton) {
                FSMainForceViewController *viewController = (FSMainForceViewController *)[[PowerTwoPViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
            }
            else if (clickButton == powerPPPButton) {
                FSMainForceViewController *viewController = (FSMainForceViewController *)[[PowerPPPViewController alloc] init];
                [self insertViewControllerInMainFrameView:viewController];
                
            }
#endif
        }
    }

}

- (UILabel *)newLabel {
    UILabel *result = [[UILabel alloc] init];
    result.backgroundColor = [UIColor lightGrayColor];
    result.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:result];
    return result;
}

- (void)insertViewControllerInMainFrameView:(UIViewController *)newController {
    // mainframe移除所有view和controller
//    [[mainframeView subviews] makeObjectsPerformSelector:@selector(removeFirstAvailableUIViewController)];
    [[mainframeView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_mainViewController removeFromParentViewController];
    newController.view.frame = mainframeView.bounds;
    newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // mainframe新增view和controller
    _mainViewController = newController;
    [newController willMoveToParentViewController:self];
    [self addChildViewController:newController];
    [newController didMoveToParentViewController:self];
    [mainframeView addSubview:newController.view];
    
//    FSNavigationViewController *nav = (FSNavigationViewController *)self.navigationController;
//    if ([newController isKindOfClass:NSClassFromString(@"DrawAndScrollController")] ||[newController isKindOfClass:NSClassFromString(@"FSEquityDrawViewController")] ) {
//        self.view.frame = [UIApplication sharedApplication].keyWindow.bounds;
//        nav.gAdView.hidden = YES;
//    }else{
//        if([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
//            self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-32);
//            nav.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//            nav.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-32 ,self.view.bounds.size.width, 50);
//        }else{
//            self.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-50);
//            nav.gAdView.adSize = kGADAdSizeSmartBannerPortrait;
//            nav.gAdView.frame = CGRectMake(0, self.view.bounds.size.height-50 ,self.view.bounds.size.width, 50);
//        }
//        nav.gAdView.hidden = NO;
//    }
}

-(void)setScreen
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
@end
