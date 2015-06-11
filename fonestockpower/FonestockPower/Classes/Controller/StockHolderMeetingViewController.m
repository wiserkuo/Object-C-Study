//
//  StockHolderMeetingViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "StockHolderMeetingViewController.h"
#import "DDPageControl.h"
#import "FSUIButton.h"
#import "StockHolderMeetingCell.h"
#import "HistoricalCell.h"
#import "StockHolderMeeting.h"
#import "FSRadioButtonSet.h"

typedef NS_ENUM(NSInteger, PlistData) {
    HisDic = 0,
    EpsDic,
};

@interface StockHolderMeetingViewController ()<UITableViewDelegate, UITableViewDataSource, StockHolderMeetingDelegate, FSRadioButtonSetDelegate>

{
    PlistData plistData;
    int type;
    int index;
    NSString *startDate;
    FSDataModelProc *model;
    UITableView *smTableView;
    UITableView *rightTableView;
    UIScrollView * topScrollView;
    UIScrollView * mainScrollView;
    DDPageControl *pageControl;
    UIView * topView;
    UIView * rightView;
    UIView * mainView;
    UIButton *holderMeetingButton;
    UIButton *rightsOutButton;
    UIButton *dividendsButton;
    UIButton *increaseButton;
    UIButton *taxButton;
    NSArray *dataArray;
    NSArray *holderMeetingArray;
    NSArray *rightsOutArray;
    NSArray *dividendsArray;
    NSArray *increaseArray;
    NSArray *taxArray;
    NSDictionary *dict;
    NSDictionary *epsDict;
    NSDictionary *hisDict;
    StockHolderMeeting *stockHolderMeeting;
    FSRadioButtonSet *radioButtonSetController;
}
@end

@implementation StockHolderMeetingViewController

-(void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    type = 1;
    [self initArrayData];
	[self initTopView];
    [self initBottomView];
    [self initRightView];
    [self initMainView];
    [self initPageControl];
    [self processLayout];
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    model.stockHolderMeeting.delegate = self;
    [model.stockHolderMeeting sendAndRead];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initModel];
    [self registerLoginNotificationCallBack:self seletor:@selector(initModel)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(initModel)];
//    [smTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    model.stockHolderMeeting.delegate = nil;
    dict = nil;
    hisDict = nil;
    epsDict = nil;
}

-(void)initPageControl
{
    pageControl = [[DDPageControl alloc] init];
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    [pageControl setDefersCurrentPageDisplay: YES] ;
	[pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[pageControl setOnColor: [UIColor redColor]];
	[pageControl setOffColor: [UIColor redColor]];
	[pageControl setIndicatorDiameter: 7.0f] ;
	[pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:pageControl];
}

- (void)EPSNotifyData:(id)target {
    epsDict = target;
    [smTableView reloadData];
    [rightTableView reloadData];
}

- (void)HisNotifyData:(id)target {
    hisDict = target;
    [smTableView reloadData];
    [rightTableView reloadData];
}

- (void)StockHolderMeetingNotifyData:(id)target {
    dict = target;
    [smTableView reloadData];
    [rightTableView reloadData];
}

-(void)initTopView
{
    topScrollView = [[UIScrollView alloc] init];
    topScrollView.contentSize = CGSizeMake(380.0f, 45.0f);
    topScrollView.bounces = NO;
    topScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    topView = [[UIView alloc] init];
    
    holderMeetingButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    [holderMeetingButton setTitle:@"股東會" forState:UIControlStateNormal];
    holderMeetingButton.selected = YES;
    [holderMeetingButton addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    holderMeetingButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    rightsOutButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    [rightsOutButton setTitle:@"除權" forState:UIControlStateNormal];
    [rightsOutButton addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    rightsOutButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    dividendsButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    [dividendsButton setTitle:@"除息" forState:UIControlStateNormal];
    [dividendsButton addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    dividendsButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    increaseButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    [increaseButton setTitle:@"現金增資" forState:UIControlStateNormal];
    [increaseButton addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    increaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    taxButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    [taxButton setTitle:@"可扣抵稅額" forState:UIControlStateNormal];
    [taxButton addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    taxButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    radioButtonSetController = [[FSRadioButtonSet alloc] init];
    radioButtonSetController.delegate = self;
    radioButtonSetController.buttons = @[holderMeetingButton,
                                          rightsOutButton,
                                          dividendsButton, increaseButton, taxButton];
  
    [topView addSubview:holderMeetingButton];
    [topView addSubview:rightsOutButton];
    [topView addSubview:dividendsButton];
    [topView addSubview:increaseButton];
    [topView addSubview:taxButton];
    
    [topScrollView addSubview:topView];
}

-(void)initBottomView
{
    smTableView = [[UITableView alloc] init];
    smTableView.delegate = self;
    smTableView.dataSource = self;
    smTableView.allowsSelection = NO;
    smTableView.bounces = NO;
    smTableView.translatesAutoresizingMaskIntoConstraints = NO;
}

-(void)initRightView
{
    rightTableView = [[UITableView alloc] init];
    rightTableView.delegate = self;
    rightTableView.dataSource = self;
    rightTableView.allowsSelection = NO;
    rightTableView.bounces = NO;
    rightTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    rightView = [[UIView alloc] init];
    [rightView addSubview:rightTableView];
}

-(void)initMainView
{
    mainView = [[UIView alloc] init];
    
    mainScrollView =[[UIScrollView alloc] init];
    mainScrollView.delegate = self;
    mainScrollView.pagingEnabled = YES;
    mainScrollView.bounces = NO;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [mainView addSubview:topScrollView];
    [mainView addSubview:smTableView];
    [mainScrollView addSubview:rightView];
    [mainScrollView addSubview:mainView];
    
    [self.view addSubview:mainScrollView];
}

-(void)initArrayData
{
    holderMeetingArray = [[NSArray alloc] initWithObjects:@"股東會日期", @"董監改選年", @"最後過戶日", @"停止過戶起始日", @"停券起始日", @"停券迄日", @"融券回補日", @"停資起始日", @"停資迄日", nil];
    rightsOutArray = [[NSArray alloc] initWithObjects:@"除權日期", @"最後過戶日", @"停止過戶起始日", @"停券起始日", @"停券迄日", @"融券回補日", @"停資起始日", @"停資迄日", @"股票發放日", nil];
    dividendsArray = [[NSArray alloc] initWithObjects:@"除息日期", @"最後過戶日", @"停止過戶起始日", @"停券起始日", @"停券迄日", @"融券回補日", @"停資起始日", @"停資迄日", @"股利發放日", nil];
    increaseArray = [[NSArray alloc] initWithObjects:@"現金增資日", @"最後過戶日", @"停止過戶起始日", @"停券起始日", @"停券迄日", @"融券回補日", @"停資起始日", @"停資迄日", @"金額(億)", @"認購價", @"認股率", @"增資後股本", @"現增發放日", nil];
    taxArray = [[NSArray alloc] initWithObjects:@"可扣抵稅額", nil];
    
    dataArray = [[NSArray alloc] initWithArray:holderMeetingArray];
    
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(topScrollView, holderMeetingButton, rightsOutButton, dividendsButton, increaseButton, taxButton, smTableView, rightTableView, mainScrollView, topView, mainView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainScrollView]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainScrollView]-15-|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topScrollView]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[smTableView]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[holderMeetingButton(70)][rightsOutButton(55)][dividendsButton(55)][increaseButton(90)][taxButton(110)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[holderMeetingButton(44)]" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rightTableView]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightTableView]|" options:0 metrics:nil views:viewController]];
}

- (void)viewDidLayoutSubviews {
    [mainScrollView setContentSize: CGSizeMake(mainScrollView.bounds.size.width * 2, mainScrollView.bounds.size.height)];
    
    [topView setFrame:CGRectMake(0, 0, topScrollView.contentSize.width, topScrollView.contentSize.height)];
    
    [mainView setFrame:CGRectMake(0, 0, mainScrollView.bounds.size.width, mainScrollView.bounds.size.height)];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topScrollView(44)][smTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(topScrollView, smTableView)]];
    
    [rightView setFrame:CGRectMake(mainScrollView.bounds.size.width * 1, 0, mainScrollView.bounds.size.width, mainScrollView.bounds.size.height)];
    
    [pageControl setCenter:CGPointMake(mainScrollView.center.x, self.view.bounds.size.height - 10)];
    [self.view layoutSubviews];
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == smTableView){
        return [dataArray count];
    }else{
        return 5;
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == smTableView){
        static NSString *kCellIdentifier = @"Cell";
        StockHolderMeetingCell *cell = (StockHolderMeetingCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        
        if (cell == nil) {
            cell = [[StockHolderMeetingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        }
        
        // Configure the cell...
        cell.leftLabel.text = [dataArray objectAtIndex:indexPath.row];
        
        if(type==1){
            if(dict == nil){
                cell.rightLabel.text = @"----";
//                cell.rightLabel.textColor = [UIColor blackColor];
            }else{
                if (indexPath.row ==0){
                    cell.rightLabel.text = [dict objectForKey:@"Type1MeetingDate"];
                }else if (indexPath.row ==1){
                    cell.rightLabel.text = [dict objectForKey:@"BoardReElection"];
                }else if (indexPath.row ==2){
                    cell.rightLabel.text = [dict objectForKey:@"Type1LastTranDate"];
                }else if (indexPath.row ==3){
                    cell.rightLabel.text = [dict objectForKey:@"Type1StopTranDate"];
                }else if (indexPath.row ==4){
                    cell.rightLabel.text = [dict objectForKey:@"Type1StopShrDateBegin"];
                }else if (indexPath.row ==5){
                    cell.rightLabel.text = [dict objectForKey:@"Type1StopShrDateEnd"];
                }else if (indexPath.row ==6){
                    cell.rightLabel.text = [dict objectForKey:@"Type1RetShrDate"];
                }else if (indexPath.row ==7){
                    cell.rightLabel.text = [dict objectForKey:@"Type1StopAmntDateBegin"];
                }else if (indexPath.row ==8){
                    cell.rightLabel.text = [dict objectForKey:@"Type1StopAmntDateEnd"];
                }
            }
        }else if(type==2){
            if(dict == nil){
                cell.rightLabel.text = @"----";
            }else{
                if (indexPath.row ==0){
                    cell.rightLabel.text = [dict objectForKey:@"Type2MeetingDate"];
                }else if (indexPath.row ==1){
                    cell.rightLabel.text = [dict objectForKey:@"Type2LastTranDate"];
                }else if (indexPath.row ==2){
                    cell.rightLabel.text = [dict objectForKey:@"Type2StopTranDate"];
                }else if (indexPath.row ==3){
                    cell.rightLabel.text = [dict objectForKey:@"Type2StopShrDateBegin"];
                }else if (indexPath.row ==4){
                    cell.rightLabel.text = [dict objectForKey:@"Type2StopShrDateEnd"];
                }else if (indexPath.row ==5){
                    cell.rightLabel.text = [dict objectForKey:@"Type2RetShrDate"];
                }else if (indexPath.row ==6){
                    cell.rightLabel.text = [dict objectForKey:@"Type2StopAmntDateBegin"];
                }else if (indexPath.row ==7){
                    cell.rightLabel.text = [dict objectForKey:@"Type2StopAmntDateEnd"];
                }else if (indexPath.row ==8){
                    cell.rightLabel.text = [dict objectForKey:@"StockDividendReleaseDate"];
                }
            }
        }else if(type==3){
            if(dict == nil){
                cell.rightLabel.text = @"----";
            }else{
                if (indexPath.row ==0){
                    cell.rightLabel.text = [dict objectForKey:@"Type3MeetingDate"];
                }else if (indexPath.row ==1){
                    cell.rightLabel.text = [dict objectForKey:@"Type3LastTranDate"];
                }else if (indexPath.row ==2){
                    cell.rightLabel.text = [dict objectForKey:@"Type3StopTranDate"];
                }else if (indexPath.row ==3){
                    cell.rightLabel.text = [dict objectForKey:@"Type3StopShrDateBegin"];
                }else if (indexPath.row ==4){
                    cell.rightLabel.text = [dict objectForKey:@"Type3StopShrDateEnd"];
                }else if (indexPath.row ==5){
                    cell.rightLabel.text = [dict objectForKey:@"Type3RetShrDate"];
                }else if (indexPath.row ==6){
                    cell.rightLabel.text = [dict objectForKey:@"Type3StopAmntDateBegin"];
                }else if (indexPath.row ==7){
                    cell.rightLabel.text = [dict objectForKey:@"Type3StopAmntDateEnd"];
                }else if (indexPath.row ==8){
                    cell.rightLabel.text = [dict objectForKey:@"CashDividendReleaseDate"];
                }
            }
        }else if(type==4){
            if(dict == nil){
                cell.rightLabel.text = @"----";
            }else{
                if (indexPath.row ==0){
                    cell.rightLabel.text = [dict objectForKey:@"Type4MeetingDate"];
                }else if (indexPath.row ==1){
                    cell.rightLabel.text = [dict objectForKey:@"Type4LastTranDate"];
                }else if (indexPath.row ==2){
                    cell.rightLabel.text = [dict objectForKey:@"Type4StopTranDate"];
                }else if (indexPath.row ==3){
                    cell.rightLabel.text = [dict objectForKey:@"Type4StopShrDateBegin"];
                }else if (indexPath.row ==4){
                    cell.rightLabel.text = [dict objectForKey:@"Type4StopShrDateEnd"];
                }else if (indexPath.row ==5){
                    cell.rightLabel.text = [dict objectForKey:@"Type4RetShrDate"];
                }else if (indexPath.row ==6){
                    cell.rightLabel.text = [dict objectForKey:@"Type4StopAmntDateBegin"];
                }else if (indexPath.row ==7){
                    cell.rightLabel.text = [dict objectForKey:@"Type4StopAmntDateEnd"];
                }else if (indexPath.row ==8){
                    cell.rightLabel.text = [dict objectForKey:@"CapIncAmnt"];
                }else if (indexPath.row ==9){
                    cell.rightLabel.text = [dict objectForKey:@"CapIncStkPrice"];
                }else if (indexPath.row ==10){
                    cell.rightLabel.text = [CodingUtil getValueToPrecent:[(NSNumber *)[dict objectForKey:@"CapIncStockRatio"]doubleValue]];
                }else if (indexPath.row ==11){
                    cell.rightLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"NewCapital"]];
                }else if (indexPath.row ==12){
                    cell.rightLabel.text = [dict objectForKey:@"CashAndStockReleaseDate"];
                }
            }
        }else if(type==5){
            if (indexPath.row ==0){
                if(dict == nil){
                    cell.rightLabel.text = @"----";
                }else{
                    cell.rightLabel.text = [NSString stringWithFormat:@"%@%%(%@年)", [dict objectForKey:@"TaxCredit"], [dict objectForKey:@"TaxDate"]];
                }
            }
        }
        return cell;
    }else{
        static NSString *rCellIdentifier = @"RCell";
        HistoricalCell *cell = (HistoricalCell *)[tableView dequeueReusableCellWithIdentifier:rCellIdentifier];
        
        if (cell == nil) {
            cell = [[HistoricalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rCellIdentifier];
        }
        
        cell.ernDivLabel.textAlignment = NSTextAlignmentRight;
        cell.capDivLabel.textAlignment = NSTextAlignmentRight;
        cell.cshDivLabel.textAlignment = NSTextAlignmentRight;
        cell.epsLabel.textAlignment = NSTextAlignmentRight;
        
        cell.ernDivLabel.text = @"----";
        cell.capDivLabel.text = @"----";
        cell.cshDivLabel.text = @"----";
        cell.epsLabel.text = @"----";
        
        cell.ernDivLabel.textColor = [UIColor blackColor];
        cell.capDivLabel.textColor = [UIColor blackColor];
        cell.cshDivLabel.textColor = [UIColor blackColor];
        cell.epsLabel.textColor = [UIColor blackColor];
//        2_11的電文殘缺不堪，所以歷年股利分配的顯示是用三支(2_11 + 2_12 + 10_21)電文湊起來。
        
        
        NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
        [yearFormat setDateFormat:@"yyyy"];
//        
//        int epsYear = [[yearFormat stringFromDate:[[NSNumber numberWithUnsignedInt:[[epsDict objectForKey:@"epsDate0"]unsignedIntValue]]uint16ToDate]]intValue];
        int stockHolderYear =[[yearFormat stringFromDate:[[NSNumber numberWithUnsignedInt:[[dict objectForKey:@"Type1DataDate"]unsignedIntValue]]uint16ToDate]]intValue] - 1;
        
        int hisYear = [[hisDict objectForKey:@"Year0"]intValue];

        if (stockHolderYear < hisYear) {
            cell.yearLabel.text = [hisDict objectForKey:[NSString stringWithFormat:@"Year%i", (int)indexPath.row]];
            cell.ernDivLabel.text =[hisDict objectForKey:[NSString stringWithFormat:@"EmDiv%i", (int)indexPath.row]];
            cell.capDivLabel.text =[hisDict objectForKey:[NSString stringWithFormat:@"emDiv%i", (int)indexPath.row]];
            cell.cshDivLabel.text = [hisDict objectForKey:[NSString stringWithFormat:@"cshDiv%i", (int)indexPath.row]];
            cell.epsLabel.text = [epsDict objectForKey:[NSString stringWithFormat:@"eps%i", (int)indexPath.row]];
            
            cell.ernDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[hisDict objectForKey:[NSString stringWithFormat:@"EmDiv%i", (int)indexPath.row]]];
            cell.capDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[hisDict objectForKey:[NSString stringWithFormat:@"emDiv%i", (int)indexPath.row]]];
            cell.cshDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[hisDict objectForKey:[NSString stringWithFormat:@"cshDiv%i", (int)indexPath.row]]];
            cell.epsLabel.textColor = [self judgmentIsGreaterThanZeroEps:[[epsDict objectForKey:[NSString stringWithFormat:@"eps%i", (int)indexPath.row]] doubleValue]];
        }else{
            if (indexPath.row == 0) {
                cell.yearLabel.text = [NSString stringWithFormat:@"%d", stockHolderYear];
                cell.ernDivLabel.text = [self determinedDecimal:[[dict objectForKey:@"ErnDiv"] doubleValue]];
                cell.capDivLabel.text = [self determinedDecimal:[[dict objectForKey:@"CapDiv"] doubleValue]];
                cell.cshDivLabel.text = [self determinedDecimal:[[dict objectForKey:@"CashDiv"]doubleValue]];
                
                cell.ernDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[dict objectForKey:@"ErnDiv"]];
                cell.capDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[dict objectForKey:@"CapDiv"]];
                cell.cshDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[dict objectForKey:@"CashDiv"]];
                if ([self findDicIndex:stockHolderYear PlistDataNum:EpsDic]) {
                    cell.epsLabel.text = [epsDict objectForKey:[NSString stringWithFormat:@"eps%i", index]];
                    cell.epsLabel.textColor = [self judgmentIsGreaterThanZeroEps:[[epsDict objectForKey:[NSString stringWithFormat:@"eps%i", index]] doubleValue]];
                }
            }else if (indexPath.row <= 4){
                if ([self findDicIndex: stockHolderYear - (int)indexPath.row PlistDataNum:HisDic]) {
                    cell.yearLabel.text = [hisDict objectForKey:[NSString stringWithFormat:@"Year%i", index]];
                    cell.ernDivLabel.text =[hisDict objectForKey:[NSString stringWithFormat:@"EmDiv%i", index]];
                    cell.capDivLabel.text =[hisDict objectForKey:[NSString stringWithFormat:@"emDiv%i", index]];
                    cell.cshDivLabel.text = [hisDict objectForKey:[NSString stringWithFormat:@"cshDiv%i", index]];
                    
                    cell.ernDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[hisDict objectForKey:[NSString stringWithFormat:@"EmDiv%i", index]]];
                    cell.capDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[hisDict objectForKey:[NSString stringWithFormat:@"emDiv%i", index]]];
                    cell.cshDivLabel.textColor = [self judgmentIsGreaterThanZeroHis:[hisDict objectForKey:[NSString stringWithFormat:@"cshDiv%i", index]]];

                    if ([self findDicIndex:stockHolderYear - (int)indexPath.row PlistDataNum:EpsDic]  ) {
                        cell.epsLabel.text = [epsDict objectForKey:[NSString stringWithFormat:@"eps%i", index]];
                        cell.epsLabel.textColor = [self judgmentIsGreaterThanZeroEps:[[epsDict objectForKey:[NSString stringWithFormat:@"eps%i", index]] doubleValue]];
                    }
                }else{
                    if ([self findDicIndex:stockHolderYear - (int)indexPath.row PlistDataNum:EpsDic]  ) {
                        cell.yearLabel.text = [NSString stringWithFormat:@"%d", stockHolderYear - (int)indexPath.row];
                        cell.epsLabel.text = [epsDict objectForKey:[NSString stringWithFormat:@"eps%i", index]];
                        cell.epsLabel.textColor = [self judgmentIsGreaterThanZeroEps:[[epsDict objectForKey:[NSString stringWithFormat:@"eps%i", index]] doubleValue]];
                    }
                }
            }
        }
        return cell;
    }
}

-(BOOL)findDicIndex:(int)year PlistDataNum:(NSInteger)plistDataNum{
    index = 0;
    if (plistDataNum == HisDic) {
        for (int i = 0; i <= 4; i++){
            if (year == [[hisDict objectForKey:[NSString stringWithFormat:@"Year%i", i]]intValue]) {
                index = i;
                return YES;
            }
        }
    }else if(plistDataNum == EpsDic) {
        NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
        [yearFormat setDateFormat:@"yyyy"];
        for (int i = 0; i <= 4; i++){
            if (year == [[yearFormat stringFromDate:[[NSNumber numberWithUnsignedInt:[[epsDict objectForKey:[NSString stringWithFormat:@"epsDate%i", i]]unsignedIntValue]]uint16ToDate]]intValue]) {
                
                index = i;
                return YES;
            }
        }
    }
    return NO;
}
-(UIColor *)judgmentIsGreaterThanZeroEps:(double)eps{
    if (eps > 0) {
        return [StockConstant PriceUpColor];
    }else if(eps < 0){
        return [StockConstant PriceDownColor];
    }else{
        return [UIColor blueColor];
    }
}

-(UIColor *)judgmentIsGreaterThanZeroHis:(NSString *)his{
    if ([his isEqualToString:@"----"]){
        return [UIColor blackColor];
    }else{
        return [UIColor blueColor];
    }
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:214.0f/255.0f green:137.0f/255.0f blue:0 alpha:1];
    
    UIFont * fontTitle = [UIFont boldSystemFontOfSize:20.0f];
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.font = fontTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"歷年股利分配";
    
    [titleLabel setTextColor:[UIColor whiteColor]];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel * yearLabel = [[UILabel alloc] init];
    yearLabel.text = @"年度";
    yearLabel.font = fontTitle;
    [yearLabel setTextColor:[UIColor whiteColor]];
    yearLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel * ernDivLabel = [[UILabel alloc] init];
    ernDivLabel.text = @"盈餘\n配股";
    ernDivLabel.font = fontTitle;
    ernDivLabel.numberOfLines = 0;
    [ernDivLabel setTextColor:[UIColor whiteColor]];
    ernDivLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel * capDivLabel = [[UILabel alloc] init];
    capDivLabel.text = @"公積\n配股";
    capDivLabel.font = fontTitle;
    capDivLabel.numberOfLines = 0;
    [capDivLabel setTextColor:[UIColor whiteColor]];
    capDivLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel * cshDivLabel = [[UILabel alloc] init];
    cshDivLabel.text = @"現金\n股利";
    cshDivLabel.font = fontTitle;
    cshDivLabel.numberOfLines = 0;
    [cshDivLabel setTextColor:[UIColor whiteColor]];
    cshDivLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel * epsLabel = [[UILabel alloc] init];
    epsLabel.text = @"EPS";
    epsLabel.font = fontTitle;
    [epsLabel setTextColor:[UIColor whiteColor]];
    epsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [headerView addSubview:titleLabel];
    [headerView addSubview:yearLabel];
    [headerView addSubview:ernDivLabel];
    [headerView addSubview:capDivLabel];
    [headerView addSubview:cshDivLabel];
    [headerView addSubview:epsLabel];
    
    NSDictionary *viewController = NSDictionaryOfVariableBindings(titleLabel, yearLabel, ernDivLabel, capDivLabel, cshDivLabel, epsLabel);
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:Nil views:viewController]];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[yearLabel][ernDivLabel(==yearLabel)][capDivLabel(==yearLabel)][cshDivLabel(==yearLabel)][epsLabel(==yearLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:Nil views:viewController]];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel][capDivLabel(50)]|" options:0 metrics:Nil views:viewController]];
    
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == rightTableView){
        return 100.0f;
    }else{
        return 0;
    }
}

-(void)changePage:(UIButton *)btn
{
    if([btn isEqual:holderMeetingButton]){
        dataArray = holderMeetingArray;
        type = 1;
        [smTableView reloadData];
        [rightTableView reloadData];
    }else if([btn isEqual:rightsOutButton]){
        dataArray = rightsOutArray;
        type = 2;
        [smTableView reloadData];
        [rightTableView reloadData];
    }else if([btn isEqual:dividendsButton]){
        dataArray = dividendsArray;
        type = 3;
        [smTableView reloadData];
        [rightTableView reloadData];
    }else if([btn isEqual:increaseButton]){
        dataArray = increaseArray;
        type = 4;
        [smTableView reloadData];
        [rightTableView reloadData];
    }else if([btn isEqual:taxButton]){
        dataArray = taxArray;
        type = 5;
        [smTableView reloadData];
        [rightTableView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGFloat pageWidth = mainScrollView.bounds.size.width;
    float fractionalPage = mainScrollView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    
    if (pageControl.currentPage != nearestNumber) {
        pageControl.currentPage = nearestNumber;
        if (mainScrollView.dragging) {
            
            [pageControl updateCurrentPageDisplay] ;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:rightTableView]){
        return 25.0f;
    }else{
        return 44.0f;
    }
}
-(NSString *)determinedDecimal:(double)cellNumber{
    NSString *cellText = nil;
    if (cellNumber > 100) {
        cellText = [NSString stringWithFormat:@"%.1f", cellNumber];
    }else if (cellNumber > 10){
        cellText = [NSString stringWithFormat:@"%.2f", cellNumber];
    }else{
        cellText = [NSString stringWithFormat:@"%.3f", cellNumber];
    }
    return cellText;
}

@end
