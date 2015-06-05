//
//  FSFinanceViewController.m
//  pricevolume
//
//  Created by Connor on 2015/5/13.
//  Copyright (c) 2015年 Connor. All rights reserved.
//

#import "FSFinanceViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSFinanceModel.h"
#import "ChangeStockViewController.h"

#define BUTTON_HEIGHT 33

@interface FSFinanceViewController () {
    
    BOOL twoStockMode;
    
    FSFonestock *fonestock;
    FSFinanceModel *financeModel;
    FSInstantInfoWatchedPortfolio *watchedPortfolio;
    
    UIScrollView *scrollView;
    
    UIView *view1, *view2, *view3, *view4;
    UITableView *tableView1, *tableView2, *tableView3, *tableView4;
    UILabel *title1, *title2, *title3, *title4;
    UILabel *tableTitle1, *tableTitle2, *tableTitle3, *tableTitle4;
    
    FSUIButton *twoStockButton1, *twoStockButton2, *twoStockButton3, *twoStockButton4;
    UILabel *twoStockLabel1, *twoStockLabel2, *twoStockLabel3, *twoStockLabel4;
    
    FSUIButton *changeStockButton1_1, *changeStockButton1_2, *changeStockButton2_1, *changeStockButton2_2;
    FSUIButton *changeStockButton3_1, *changeStockButton3_2, *changeStockButton4_1, *changeStockButton4_2;
    
    FSUIButton *changeType1, *changeType2, *changeType3, *changeType4;
    FSUIButton *changeCategory1, *changeCategory2, *changeCategory3, *changeCategory4;
    
    FSUIButton *changeDate1_1, *changeDate1_2, *changeDate2_1, *changeDate2_2;
    FSUIButton *changeDate3_1, *changeDate3_2, *changeDate4_1, *changeDate4_2;
    
    NSMutableDictionary *viewDict;
    
    UIFont *titleFont;
    UIColor *titleColor;
    UIColor *twoStockTitleColor;
    
    
    NSInteger category;
    NSInteger type;
}

@end

@implementation FSFinanceViewController

- (instancetype)init {
    if (self = [super init]) {
        _a=0;
        fonestock = [FSFonestock sharedInstance];
        twoStockMode = fonestock.twoStockMode;
        
        financeModel = [[FSDataModelProc sharedInstance] financeModel];
        
        watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        
        viewDict = [[NSMutableDictionary alloc] init];
        titleFont = [UIFont boldSystemFontOfSize:20];
        titleColor = [UIColor colorWithRed:143/255.0f green:87/255.0f blue:45/255.0f alpha:1.0f];
        twoStockTitleColor = [UIColor colorWithRed:0/255.0f green:130/255.0f blue:255/255.0f alpha:1.0f];
    }
    return self;
}

- (void)dealloc {
    fonestock.twoStockMode = twoStockMode;
}

- (UIView *)newAutoLayoutView {
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UILabel *)newAutoLayoutLabel {
    UILabel *view = [[UILabel alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (UITableView *)newAutoLayoutTable {
    UITableView *view = [[UITableView alloc] init];
    view.allowsSelection = NO;
    view.bounces = NO;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (FSUIButton *)newAutoLayoutTwoChartButton {
    FSUIButton *twoStockButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [twoStockButton setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    twoStockButton.translatesAutoresizingMaskIntoConstraints = NO;
    return twoStockButton;
}

- (FSUIButton *)newAutoLayoutRedButton {
    FSUIButton *twoStockButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    twoStockButton.translatesAutoresizingMaskIntoConstraints = NO;
    return twoStockButton;
}

- (FSUIButton *)newAutoLayoutBlueGreenButton {
    FSUIButton *twoStockButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    twoStockButton.translatesAutoresizingMaskIntoConstraints = NO;
    return twoStockButton;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.backgroundColor = [UIColor grayColor];
    scrollView.pagingEnabled = YES;
    scrollView.clipsToBounds = NO;
    scrollView.bounces = NO;
    [viewDict setObject:scrollView forKey:@"scrollView"];
    [self.view addSubview:scrollView];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:viewDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:viewDict]];
    
    
    
    view1 = [self newAutoLayoutView];
    [viewDict setObject:view1 forKey:@"view1"];
    [scrollView addSubview:view1];
    
    title1 = [self newAutoLayoutLabel];
    title1.text = NSLocalizedStringFromTable(@"資產負債表", @"Finance", @"資產負債表");
    title1.font = titleFont;
    title1.textColor = titleColor;
    [viewDict setObject:title1 forKey:@"title1"];
    [view1 addSubview:title1];
    
    tableTitle1 = [self newAutoLayoutLabel];
    tableTitle1.backgroundColor = [UIColor colorWithRed:255/255.0f green:233/255.0f blue:169/255.0f alpha:1.0f];
    tableTitle1.text = NSLocalizedStringFromTable(@"財報日期", @"Finance", @"財報日期");
    [viewDict setObject:tableTitle1 forKey:@"tableTitle1"];
    [view1 addSubview:tableTitle1];
    
    changeType1 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeType1 forKey:@"changeType1"];
    [view1 addSubview:changeType1];
    
    changeCategory1 = [self newAutoLayoutBlueGreenButton];
    changeCategory1.hidden = YES;   // 沒有此按鈕
    [viewDict setObject:changeCategory1 forKey:@"changeCategory1"];
    [view1 addSubview:changeCategory1];

    changeDate1_1 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate1_1 forKey:@"changeDate1_1"];
    [view1 addSubview:changeDate1_1];
    
    changeDate1_2 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate1_2 forKey:@"changeDate1_2"];
    [view1 addSubview:changeDate1_2];
    
    // 兩檔比較的按鈕和Label
    twoStockButton1 = [self newAutoLayoutTwoChartButton];
    [twoStockButton1 addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:twoStockButton1 forKey:@"twoStockButton1"];
    [view1 addSubview:twoStockButton1];

    twoStockLabel1 = [self newAutoLayoutLabel];
    twoStockLabel1.text = NSLocalizedStringFromTable(@"兩檔比較", @"Finance", @"兩檔比較");
    twoStockLabel1.textColor = twoStockTitleColor;
    [viewDict setObject:twoStockLabel1 forKey:@"twoStockLabel1"];
    [view1 addSubview:twoStockLabel1];
    
    
    // 換股按鈕
    changeStockButton1_1 = [self newAutoLayoutRedButton];
    [changeStockButton1_1 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton1_1 forKey:@"changeStockButton1_1"];
    [view1 addSubview:changeStockButton1_1];
    changeStockButton1_2 = [self newAutoLayoutRedButton];
    [changeStockButton1_2 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton1_2 forKey:@"changeStockButton1_2"];
    [view1 addSubview:changeStockButton1_2];
    
    
    tableView1 = [self newAutoLayoutTable];
    tableView1.delegate = self;
    tableView1.dataSource = self;
    [viewDict setObject:tableView1 forKey:@"tableView1"];
    [view1 addSubview:tableView1];
    
    
    
    view2 = [self newAutoLayoutView];
    [viewDict setObject:view2 forKey:@"view2"];
    [scrollView addSubview:view2];
    
    tableTitle2 = [self newAutoLayoutLabel];
    tableTitle2.backgroundColor = [UIColor colorWithRed:255/255.0f green:233/255.0f blue:169/255.0f alpha:1.0f];
    tableTitle2.text = NSLocalizedStringFromTable(@"財報日期", @"Finance", @"財報日期");
    [viewDict setObject:tableTitle2 forKey:@"tableTitle2"];
    [view2 addSubview:tableTitle2];
    
    title2 = [self newAutoLayoutLabel];
    title2.text = NSLocalizedStringFromTable(@"損益表", @"Finance", @"損益表");
    title2.font = titleFont;
    title2.textColor = titleColor;
    [viewDict setObject:title2 forKey:@"title2"];
    [view2 addSubview:title2];
    
    
    
    changeDate2_1 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate2_1 forKey:@"changeDate2_1"];
    [view2 addSubview:changeDate2_1];
    
    changeDate2_2 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate2_2 forKey:@"changeDate2_2"];
    [view2 addSubview:changeDate2_2];
    
    
    changeType2 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeType2 forKey:@"changeType2"];
    [view2 addSubview:changeType2];
    
    changeCategory2 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeCategory2 forKey:@"changeCategory2"];
    [view2 addSubview:changeCategory2];
    
    twoStockButton2 = [self newAutoLayoutTwoChartButton];
    [twoStockButton2 addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:twoStockButton2 forKey:@"twoStockButton2"];
    [view2 addSubview:twoStockButton2];
    
    twoStockLabel2 = [self newAutoLayoutLabel];
    twoStockLabel2.text = NSLocalizedStringFromTable(@"兩檔比較", @"Finance", @"兩檔比較");
    twoStockLabel2.textColor = twoStockTitleColor;
    [viewDict setObject:twoStockLabel2 forKey:@"twoStockLabel2"];
    [view2 addSubview:twoStockLabel2];
    
    
    // 換股按鈕
    changeStockButton2_1 = [self newAutoLayoutRedButton];
    [changeStockButton2_1 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton2_1 forKey:@"changeStockButton2_1"];
    [view2 addSubview:changeStockButton2_1];
    changeStockButton2_2 = [self newAutoLayoutRedButton];
    [changeStockButton2_2 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton2_2 forKey:@"changeStockButton2_2"];
    [view2 addSubview:changeStockButton2_2];
    
    tableView2 = [self newAutoLayoutTable];
    tableView2.delegate = self;
    tableView2.dataSource = self;
    [viewDict setObject:tableView2 forKey:@"tableView2"];
    [view2 addSubview:tableView2];
    
    
    
    
    view3 = [self newAutoLayoutView];
    [viewDict setObject:view3 forKey:@"view3"];
    [scrollView addSubview:view3];
    
    tableTitle3 = [self newAutoLayoutLabel];
    tableTitle3.backgroundColor = [UIColor colorWithRed:255/255.0f green:233/255.0f blue:169/255.0f alpha:1.0f];
    tableTitle3.text = NSLocalizedStringFromTable(@"財報日期", @"Finance", @"財報日期");
    [viewDict setObject:tableTitle3 forKey:@"tableTitle3"];
    [view3 addSubview:tableTitle3];
    
    title3 = [self newAutoLayoutLabel];
    title3.text = NSLocalizedStringFromTable(@"現金流量", @"Finance", @"現金流量");
    title3.font = titleFont;
    title3.textColor = titleColor;
    [viewDict setObject:title3 forKey:@"title3"];
    [view3 addSubview:title3];
    
    changeType3 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeType3 forKey:@"changeType3"];
    [view3 addSubview:changeType3];
    
    changeCategory3 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeCategory3 forKey:@"changeCategory3"];
    [view3 addSubview:changeCategory3];
    
    changeDate3_1 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate3_1 forKey:@"changeDate3_1"];
    [view3 addSubview:changeDate3_1];
    
    changeDate3_2 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate3_2 forKey:@"changeDate3_2"];
    [view3 addSubview:changeDate3_2];

    

    twoStockButton3 = [self newAutoLayoutTwoChartButton];
    [twoStockButton3 addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:twoStockButton3 forKey:@"twoStockButton3"];
    [view3 addSubview:twoStockButton3];
    
    
    twoStockLabel3 = [self newAutoLayoutLabel];
    twoStockLabel3.textColor = twoStockTitleColor;
    twoStockLabel3.text = NSLocalizedStringFromTable(@"兩檔比較", @"Finance", @"兩檔比較");
    [viewDict setObject:twoStockLabel3 forKey:@"twoStockLabel3"];
    [view3 addSubview:twoStockLabel3];
    
    
    // 換股按鈕
    changeStockButton3_1 = [self newAutoLayoutRedButton];
    [changeStockButton3_1 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton3_1 forKey:@"changeStockButton3_1"];
    [view3 addSubview:changeStockButton3_1];
    changeStockButton3_2 = [self newAutoLayoutRedButton];
    [changeStockButton3_2 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton3_2 forKey:@"changeStockButton3_2"];
    [view3 addSubview:changeStockButton3_2];
    
    
    tableView3 = [self newAutoLayoutTable];
    tableView3.delegate = self;
    tableView3.dataSource = self;
    [viewDict setObject:tableView3 forKey:@"tableView3"];
    [view3 addSubview:tableView3];
    
    
    
    
    view4 = [self newAutoLayoutView];
    [viewDict setObject:view4 forKey:@"view4"];
    [scrollView addSubview:view4];
    
    tableTitle4 = [self newAutoLayoutLabel];
    tableTitle4.backgroundColor = [UIColor colorWithRed:255/255.0f green:233/255.0f blue:169/255.0f alpha:1.0f];
    tableTitle4.text = NSLocalizedStringFromTable(@"財報日期", @"Finance", @"財報日期");
    [viewDict setObject:tableTitle4 forKey:@"tableTitle4"];
    [view4 addSubview:tableTitle4];
    
    title4 = [self newAutoLayoutLabel];
    title4.text = NSLocalizedStringFromTable(@"五力分析", @"Finance", @"五力分析");
    title4.font = titleFont;
    title4.textColor = titleColor;
    [viewDict setObject:title4 forKey:@"title4"];
    [view4 addSubview:title4];
    
    changeDate4_1 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate4_1 forKey:@"changeDate4_1"];
    [view4 addSubview:changeDate4_1];
    
    changeDate4_2 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeDate4_2 forKey:@"changeDate4_2"];
    [view4 addSubview:changeDate4_2];

    
    changeType4 = [self newAutoLayoutBlueGreenButton];
    changeType4.hidden = YES;  // 沒有此按鈕
    [viewDict setObject:changeType4 forKey:@"changeType4"];
    [view4 addSubview:changeType4];
    
    changeCategory4 = [self newAutoLayoutBlueGreenButton];
    [viewDict setObject:changeCategory4 forKey:@"changeCategory4"];
    [view4 addSubview:changeCategory4];
    

    twoStockButton4 = [self newAutoLayoutTwoChartButton];
    [twoStockButton4 addTarget:self action:@selector(twoStockBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:twoStockButton4 forKey:@"twoStockButton4"];
    [view4 addSubview:twoStockButton4];
    
    twoStockLabel4 = [self newAutoLayoutLabel];
    twoStockLabel4.textColor = twoStockTitleColor;
    twoStockLabel4.text = NSLocalizedStringFromTable(@"兩檔比較", @"Finance", @"兩檔比較");
    [viewDict setObject:twoStockLabel4 forKey:@"twoStockLabel4"];
    [view4 addSubview:twoStockLabel4];
    
    
    // 換股按鈕
    changeStockButton4_1 = [self newAutoLayoutRedButton];
    [changeStockButton4_1 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton4_1 forKey:@"changeStockButton4_1"];
    [view4 addSubview:changeStockButton4_1];
    changeStockButton4_2 = [self newAutoLayoutRedButton];
    [changeStockButton4_2 addTarget:self action:@selector(changeStock:) forControlEvents:UIControlEventTouchUpInside];
    [viewDict setObject:changeStockButton4_2 forKey:@"changeStockButton4_2"];
    [view4 addSubview:changeStockButton4_2];
    
    
    tableView4 = [self newAutoLayoutTable];
    tableView4.delegate = self;
    tableView4.dataSource = self;
    [viewDict setObject:tableView4 forKey:@"tableView4"];
    [view4 addSubview:tableView4];
    
    
    
    
    NSDictionary *metrics = @{@"BUTTON_HEIGHT": @BUTTON_HEIGHT};
    
    
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:view1 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1][view2(view1)][view3(view1)][view4(view1)]|" options:0 metrics:nil views:viewDict]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1]|" options:0 metrics:nil views:viewDict]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view2]|" options:0 metrics:nil views:viewDict]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view3]|" options:0 metrics:nil views:viewDict]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view4]|" options:0 metrics:nil views:viewDict]];
    
    
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title1]" options:0 metrics:nil views:viewDict]];
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title1]" options:0 metrics:nil views:viewDict]];
    
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[changeCategory1(BUTTON_HEIGHT)]" options:0 metrics:metrics views:viewDict]];
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[title1]-[changeType1(70)]-[changeCategory1(70)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
    
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView1]|" options:0 metrics:nil views:viewDict]];
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[twoStockButton1(BUTTON_HEIGHT)][twoStockLabel1][changeStockButton1_1(100)][changeStockButton1_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:viewDict]];
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title1]-[twoStockButton1(BUTTON_HEIGHT)][changeDate1_1(BUTTON_HEIGHT)][tableView1]|" options:0 metrics:metrics views:viewDict]];
    
    [view1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableTitle1][changeDate1_1(100)][changeDate1_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
    
    
    
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title2]" options:0 metrics:nil views:viewDict]];
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title2]" options:0 metrics:nil views:viewDict]];
    
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[changeCategory2(BUTTON_HEIGHT)]" options:0 metrics:metrics views:viewDict]];
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[title2]-[changeType2(70)]-[changeCategory2(70)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
    
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView2]|" options:0 metrics:nil views:viewDict]];
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[twoStockButton2(BUTTON_HEIGHT)][twoStockLabel2][changeStockButton2_1(100)][changeStockButton2_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:viewDict]];
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[changeCategory2(BUTTON_HEIGHT)]-[twoStockButton2(BUTTON_HEIGHT)][changeDate2_1(BUTTON_HEIGHT)][tableView2]|" options:0 metrics:metrics views:viewDict]];
    
    
    [view2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableTitle2][changeDate2_1(100)][changeDate2_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
    
    [view3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title3]" options:0 metrics:nil views:viewDict]];
    
    [view3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[changeCategory3(BUTTON_HEIGHT)]" options:0 metrics:metrics views:viewDict]];
    [view3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[title3]-[changeType3(70)]-[changeCategory3(70)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
    [view3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView3]|" options:0 metrics:nil views:viewDict]];
    [view3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[twoStockButton3(BUTTON_HEIGHT)][twoStockLabel3][changeStockButton3_1(100)][changeStockButton3_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:viewDict]];
    [view3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[changeCategory3(BUTTON_HEIGHT)]-[twoStockButton3(BUTTON_HEIGHT)][changeDate3_1(BUTTON_HEIGHT)][tableView3]|" options:0 metrics:metrics views:viewDict]];
    
    [view3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableTitle3][changeDate3_1(100)][changeDate3_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
    
    [view4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title4]" options:0 metrics:metrics views:viewDict]];
    [view4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[changeCategory4(BUTTON_HEIGHT)]" options:0 metrics:metrics views:viewDict]];
    [view4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[title4]-[changeType4(70)]-[changeCategory4(70)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
    [view4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView4]|" options:0 metrics:metrics views:viewDict]];
    [view4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[twoStockButton4(BUTTON_HEIGHT)][twoStockLabel4][changeStockButton4_1(100)][changeStockButton4_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:metrics views:viewDict]];
    [view4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[changeCategory4(BUTTON_HEIGHT)]-[twoStockButton4(BUTTON_HEIGHT)][changeDate4_1(BUTTON_HEIGHT)][tableView4]|" options:0 metrics:metrics views:viewDict]];
    
    [view4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableTitle4][changeDate4_1(100)][changeDate4_2(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   // [self discardData];
    [financeModel setTargetNotify:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

        
    twoStockButton1.selected = twoStockMode;
    twoStockButton2.selected = twoStockMode;
    twoStockButton3.selected = twoStockMode;
    twoStockButton4.selected = twoStockMode;
    
    changeStockButton1_1.hidden = !twoStockMode;
    changeStockButton1_2.hidden = !twoStockMode;
    changeStockButton2_1.hidden = !twoStockMode;
    changeStockButton2_2.hidden = !twoStockMode;
    changeStockButton3_1.hidden = !twoStockMode;
    changeStockButton3_2.hidden = !twoStockMode;
    changeStockButton4_1.hidden = !twoStockMode;
    changeStockButton4_2.hidden = !twoStockMode;
    
    
    PortfolioItem *portfolioItem1 = watchedPortfolio.portfolioItem;
    PortfolioItem *portfolioItem2 = watchedPortfolio.comparedPortfolioItem;
    
    NSString *portfolioName1, *portfolioName2;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        portfolioName1 = portfolioItem1->symbol;
        portfolioName2 = portfolioItem2->symbol;
    } else {
        portfolioName1 = portfolioItem1->fullName;
        portfolioName2 = portfolioItem2->fullName;
        NSLog(@"PortfolioName1 = %@ portfolioName2=%@\n",portfolioName1,portfolioName2);
    }
    
    [changeStockButton1_1 setTitle:portfolioName1 forState:UIControlStateNormal];
    [changeStockButton1_2 setTitle:portfolioName2 forState:UIControlStateNormal];
    [changeStockButton2_1 setTitle:portfolioName1 forState:UIControlStateNormal];
    [changeStockButton2_2 setTitle:portfolioName2 forState:UIControlStateNormal];
    [changeStockButton3_1 setTitle:portfolioName1 forState:UIControlStateNormal];
    [changeStockButton3_2 setTitle:portfolioName2 forState:UIControlStateNormal];
    [changeStockButton4_1 setTitle:portfolioName1 forState:UIControlStateNormal];
    [changeStockButton4_2 setTitle:portfolioName2 forState:UIControlStateNormal];
    
    
    [changeType1 setTitle:[financeModel.typeList objectAtIndex:financeModel.type] forState:UIControlStateNormal];
    [changeType2 setTitle:[financeModel.typeList objectAtIndex:financeModel.type] forState:UIControlStateNormal];
    [changeType3 setTitle:[financeModel.typeList objectAtIndex:financeModel.type] forState:UIControlStateNormal];
    [changeType4 setTitle:[financeModel.typeList objectAtIndex:financeModel.type] forState:UIControlStateNormal];
    
    [changeCategory1 setTitle:[financeModel.categoryList objectAtIndex:financeModel.category] forState:UIControlStateNormal];
    [changeCategory2 setTitle:[financeModel.categoryList objectAtIndex:financeModel.category] forState:UIControlStateNormal];
    [changeCategory3 setTitle:[financeModel.categoryList objectAtIndex:financeModel.category] forState:UIControlStateNormal];
    [changeCategory4 setTitle:[financeModel.categoryList objectAtIndex:financeModel.category] forState:UIControlStateNormal];
    
    //[self addObserver:self forKeyPath:@"a" options:NSKeyValueObservingOptionNew context:nil];
    
    [self searchData];
}

- (void)searchData {

    [financeModel setTargetNotify:self];
    [financeModel searchAllSheetWithSecurityNumber:watchedPortfolio.portfolioItem->commodityNo dataType:'Q' searchStartDate:[[NSDate date] yearOffset:-3]];

    if (twoStockMode) {
        [financeModel searchAllSheetWithSecurityNumber:watchedPortfolio.comparedPortfolioItem->commodityNo dataType:'Q' searchStartDate:[[NSDate date] yearOffset:-3]];
    }
   
    
}
-(void)notifyData:(id)title{
    NSLog(@"===========%@\n",title);
    if([title isEqualToString:@"BalanceSheet1"]||[title isEqualToString:@"BalanceSheet2"]){
       // financeModel.model.stockDict;
        [tableView1 reloadData];
        
    }
    // dataModel.financeModel.model.stockDict
}
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//
//    printf("rejoqgjreg;legjor;eajo");
//}
- (void)twoStockBtnClick:(FSUIButton *)btn {
    //printf("dksaglsiagydulabhvfbfdabffjhidabh%d\n",_a);
    twoStockMode = !btn.selected;
    //_a++;
    [self buttonStateChange];
}

- (void)buttonStateChange {
    twoStockButton1.selected = twoStockMode;
    twoStockButton2.selected = twoStockMode;
    twoStockButton3.selected = twoStockMode;
    twoStockButton4.selected = twoStockMode;
    
    changeStockButton1_1.hidden = !twoStockMode;
    changeStockButton1_2.hidden = !twoStockMode;
    changeStockButton2_1.hidden = !twoStockMode;
    changeStockButton2_2.hidden = !twoStockMode;
    changeStockButton3_1.hidden = !twoStockMode;
    changeStockButton3_2.hidden = !twoStockMode;
    changeStockButton4_1.hidden = !twoStockMode;
    changeStockButton4_2.hidden = !twoStockMode;
}


- (void)changeStock:(FSUIButton *)btn {
    
    ChangeStockViewController *changeStockView;
    
    if (btn == changeStockButton1_1 || btn == changeStockButton2_1 || btn == changeStockButton3_1 || btn == changeStockButton4_1) {
        changeStockView = [[ChangeStockViewController alloc] initWithNumber:1];
        
    } else if (btn == changeStockButton1_2 || btn == changeStockButton2_2 || btn == changeStockButton3_2 || btn == changeStockButton4_2) {
        changeStockView = [[ChangeStockViewController alloc] initWithNumber:2];
    }
    
    [self.navigationController pushViewController:changeStockView animated:NO];
}

- (void)reloadAllTable {
    [tableView1 reloadData];
    [tableView2 reloadData];
    [tableView3 reloadData];
    [tableView4 reloadData];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == tableView1) {
        return [financeModel.pageList1 count];
    } else if (tableView == tableView2) {
        return [financeModel.pageList2 count];
    } else if (tableView == tableView3) {
        return [financeModel.pageList3 count];
    } else if (tableView == tableView4) {
        return [financeModel.pageList4 count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 33.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FSFinanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Finance"];
    
    if (!cell) {
        cell = [[FSFinanceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Finance"];
    }
    
    
    //stockDict = [[financeModel.model.stockDict objectForKey: [watchedPortfolio.portfolioItem getIdentCodeSymbol]] objectForKey:@"2015/03"] ;

    FSBValueFormat *value;
    
    //BalanceSheet
    if (tableView == tableView1) {
        
        
        cell.tableTitleLabel.text = [financeModel.pageList1 objectAtIndex:indexPath.row];
        value = [financeModel.model  getData:@"stock1" date:@"2015/03" ids:@"BalanceSheet" indexPath:indexPath];
       // [NSString stringWithFormat:@"%.0f",[[group1DataDic objectForKey:rowName] floatValue]/1000000];
        if(value ==nil)
            cell.stock1Label.text =@"-";
        else
            cell.stock1Label.text=[NSString stringWithFormat:@"%.0f",value.calcValue/100000];
        value = [financeModel.model  getData:@"stock2" date:@"2015/03" ids:@"BalanceSheet" indexPath:indexPath];
        if(value ==nil)
            cell.stock2Label.text =@"-";
        else
            cell.stock2Label.text=[NSString stringWithFormat:@"%.0f",value.calcValue/100000];
    }
    //IncomeStatement
    else if (tableView == tableView2) {
        cell.tableTitleLabel.text = [financeModel.pageList2 objectAtIndex:indexPath.row];
        cell.stock1Label.text = @"3";
        cell.stock2Label.text = @"4";
    }
    //CashFlow
    else if (tableView == tableView3) {
        cell.tableTitleLabel.text = [financeModel.pageList3 objectAtIndex:indexPath.row];
        cell.stock1Label.text = @"5";
        cell.stock2Label.text = @"6";
    }
    //FinancialRatio
    else if (tableView == tableView4) {
        cell.tableTitleLabel.text = [financeModel.pageList4 objectAtIndex:indexPath.row];
        cell.stock1Label.text = @"7";
        cell.stock2Label.text = @"8";
    }
    
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return NSLocalizedStringFromTable(@"單位", @"Finance", @"單位");
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLog(@"viewForHeaderInSection %@ %ld", tableView, (long)section);
    UIView *view = [[UIView alloc] init];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}



@end




@implementation FSFinanceTableView

@end



@interface FSFinanceTableViewCell()
{
    NSDictionary *viewDict;
}
@end

@implementation FSFinanceTableViewCell

- (UILabel *)newAutoLayoutLabel {
    UILabel *view = [[UILabel alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        viewDict = [[NSMutableDictionary alloc] init];
        
        _tableTitleLabel = [self newAutoLayoutLabel];
        _tableTitleLabel.backgroundColor = [UIColor colorWithRed:255/255.0f green:233/255.0f blue:169/255.0f alpha:1.0f];
        _stock1Label  = [self newAutoLayoutLabel];
        _stock2Label  = [self newAutoLayoutLabel];
        
        [viewDict setValue:_tableTitleLabel forKey:@"_tableTitleLabel"];
        [viewDict setValue:_stock1Label forKey:@"_stock1Label"];
        [viewDict setValue:_stock2Label forKey:@"_stock2Label"];
        
        [self.contentView addSubview:_tableTitleLabel];
        [self.contentView addSubview:_stock1Label];
        [self.contentView addSubview:_stock2Label];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableTitleLabel][_stock1Label(100)][_stock2Label(100)]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableTitleLabel]|" options:0 metrics:nil views:viewDict]];
    }
    return self;
}

@end

