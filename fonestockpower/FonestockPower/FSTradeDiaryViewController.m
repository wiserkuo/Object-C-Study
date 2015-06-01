//
//  FSTradeDiaryViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTradeDiaryViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "DrawAndScrollController.h"
#import "FSTradeHistoryViewController.h"
#import "DrawAndScrollController.h"
#import "FSActionPlanDatabase.h"
#import "FSPositionManagementViewController.h"
#import "ExplanationViewController.h"

@interface FSTradeDiaryViewController ()<UIActionSheetDelegate>{
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    FSUIButton *moreOptionBtnNav;
    FSUIButton *zeroOptionBtnNav;
    
    UIView *infoView;
    UILabel *realizedTitleLabel;
    UILabel *realizedLabel;
    UILabel *winRationTitleLabel;
    UILabel *winRationLabel;
    UILabel *titleLabel;
    
    NSUInteger diaryCount;
    NSMutableArray *diaryArray;
    NSMutableArray *layoutContraints;
    NSMutableArray *layoutContraints1;
    
    FSInstantInfoWatchedPortfolio *watchedPortfolio;
    FSPositionModel *positionModel;
    FSDiary *diary;
    BOOL status;//YES:Long NO:Short
}

@end

@implementation FSTradeDiaryViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    positionModel = [[FSDataModelProc sharedInstance] positionModel];
    watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
   
    layoutContraints = [[NSMutableArray alloc] init];
    layoutContraints1 = [[NSMutableArray alloc] init];

    [self initView];
    [self.view setNeedsUpdateConstraints];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self initData];
    [self setNavigation];
    [self setNavigationBtn];
    [self buttonStatusControll];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    titleLabel.text = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - set navigation
-(void)setNavigation{
    [self setUpImageBackButton];
    UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [pointButton addTarget:self action:@selector(explantation:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"Trade", nil);
    moreOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionBtnNav.frame = CGRectMake(0, 0, 132, 33);
//    moreOptionBtnNav.selected = YES;
    [moreOptionBtnNav setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"Trade", nil);
    zeroOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionBtnNav.frame = CGRectMake(0, 0, 132, 33);
//    zeroOptionBtnNav.selected = NO;
    [zeroOptionBtnNav setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barAddButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pointButton];
    UIBarButtonItem *moreBtnItem = [[UIBarButtonItem alloc] initWithCustomView:moreOptionBtnNav];
    UIBarButtonItem *zeroBtnItem = [[UIBarButtonItem alloc] initWithCustomView:zeroOptionBtnNav];
    NSArray *itemArray = [[NSArray alloc] initWithObjects:barAddButtonItem, zeroBtnItem, moreBtnItem, nil];
    [self.navigationItem setRightBarButtonItems:itemArray];
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"Diary", @"Launcher", nil)];
    
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
    titleLabel.text = NSLocalizedStringFromTable(@"Diary", @"Launcher", nil);
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

#pragma mark - 說明頁
-(void)explantation:(UIButton *)sender
{
    [self.navigationController pushViewController:[[ExplanationViewController alloc] init] animated:NO];
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
    
    _tableView = [[FSTradeDiaryTableView alloc] initWithfixedColumnWidth:80 mainColumnWidth:100 AndColumnHeight:50];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    infoView = [[UIView alloc] init];
    infoView.translatesAutoresizingMaskIntoConstraints = NO;
    infoView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
    [self.view addSubview:infoView];
    
    realizedTitleLabel = [[UILabel alloc] init];
    realizedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    realizedTitleLabel.text = NSLocalizedStringFromTable(@"已實現損益", @"Trade", nil);
    [infoView addSubview:realizedTitleLabel];
    
    realizedLabel = [[UILabel alloc] init];
    realizedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    realizedLabel.text = @"---";
    realizedLabel.adjustsFontSizeToFitWidth = YES;
    realizedLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:realizedLabel];
    
    winRationTitleLabel = [[UILabel alloc] init];
    winRationTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    winRationTitleLabel.text = NSLocalizedStringFromTable(@"勝率", @"Trade", nil);
    [infoView addSubview:winRationTitleLabel];
    
    winRationLabel = [[UILabel alloc] init];
    winRationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    winRationLabel.text = @"---";
    winRationLabel.adjustsFontSizeToFitWidth = YES;
    winRationLabel.textAlignment = NSTextAlignmentRight;
    [infoView addSubview:winRationLabel];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    [self.view removeConstraints:layoutContraints1];
    [layoutContraints removeAllObjects];
    [layoutContraints1 removeAllObjects];
    
    NSDictionary *viewController = NSDictionaryOfVariableBindings(moreOptionButton, zeroOptionButton, _tableView, infoView, realizedTitleLabel, realizedLabel, winRationTitleLabel, winRationLabel);
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-2-[zeroOptionButton(==moreOptionButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[moreOptionButton(44)]-2-[_tableView][infoView(50)]|" options:0 metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[realizedTitleLabel(140)][realizedLabel(realizedTitleLabel)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[winRationTitleLabel(140)][winRationLabel(winRationTitleLabel)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[realizedTitleLabel(25)][winRationTitleLabel(25)]" options:0 metrics:nil views:viewController]];
        [self.view addConstraints:layoutContraints];
        [infoView addConstraints:layoutContraints1];
    }else{
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView][infoView(50)]|" options:0 metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[realizedTitleLabel(140)][realizedLabel(realizedTitleLabel)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[winRationTitleLabel(140)][winRationLabel(winRationTitleLabel)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [layoutContraints1 addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[realizedTitleLabel(25)][winRationTitleLabel(25)]" options:0 metrics:nil views:viewController]];
        [self.view addConstraints:layoutContraints];
        [infoView addConstraints:layoutContraints1];
    }
}

#pragma mark - initData
-(void)initData{
    diaryArray = [[NSMutableArray alloc] init];
    if (moreOptionButton.selected == YES) {
        [positionModel loadDiaryData:@"Sell"];
        status = YES;
    }else{
        [positionModel loadDiaryData:@"Cover"];
        status = NO;
    }
    diaryArray = positionModel.diaryArray;
    [_tableView reloadData];
    
    //已實現損益
    float realized = 0;
    float gainPercent = 0;
    for (diary in diaryArray) {
        realized += diary.gainDollar;
        gainPercent += diary.gainPercent;
    }
    
    if (realized > 0) {
        realizedLabel.textColor = [StockConstant PriceUpColor];
    }else if (realized < 0){
        realizedLabel.textColor = [StockConstant PriceDownColor];
    }else{
        realizedLabel.textColor = [UIColor blackColor];
    }
    
    if ([diaryArray count] > 0) {
        realizedLabel.text = [NSString stringWithFormat:@"$%@(%@%%)", [self setPrice:realized * positionModel.suggestCount Decimal:0], [CodingUtil CoverFloatWithComma:gainPercent*100 DecimalPoint:2]];
    }else{
        realizedLabel.text = [NSString stringWithFormat:@"$0(----)"];
    }

    //勝率
    float winRate = 0;
    for (diary in diaryArray) {
        if (diary.gainPercent > 0) {
            winRate++;
        }
    }
    if ([diaryArray count] > 0) {
        winRationLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@%%(交易%d檔)", @"Trade", nil), [CodingUtil CoverFloatWithComma:(winRate/(int)[diaryArray count]) * 100 DecimalPoint:2], (int)[diaryArray count]];
    }else{
        winRationLabel.text = @"----(----)";
    }
}

#pragma mark - Button click action
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
}

-(void)hBtnAction:(FSUIButton *)sender{
    diary = [diaryArray objectAtIndex:sender.tag];

    FSTradeHistoryViewController *tradeHistoryView = [[FSTradeHistoryViewController alloc] init];
    if (moreOptionButton.selected == YES) {
        tradeHistoryView.termStr = @"Long";
    }else{
        tradeHistoryView.termStr = @"Short";
    }
    tradeHistoryView.symbolStr = diary.identCodeSymbol;
    [self.navigationController pushViewController:tradeHistoryView animated:NO];
}

-(void)nBtnAction:(FSUIButton *)sender{
    diary = [diaryArray objectAtIndex:sender.tag];

    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePortRelateKLine showAlertViewToShopping:YES]) {
        
        NSString *idSymbol =diary.identCodeSymbol;
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (moreOptionButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:diary.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:diary.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:positionModel.dateFormatter];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"Buy"] || [[dict objectForKey:@"Deal"] isEqualToString:@"Cover"]) {
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
    diary = [diaryArray objectAtIndex:sender.tag];

    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePortRelateKLine showAlertViewToShopping:YES]) {
        
        NSString *idSymbol =diary.identCodeSymbol;
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        dataModal.indicator.bottomView1Indicator = 14;
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (moreOptionButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:diary.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:diary.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:positionModel.dateFormatter];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"Buy"] || [[dict objectForKey:@"Deal"] isEqualToString:@"Cover"]) {
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
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Long" DealBuy:@"Buy" DealSell:@"Sell"];
        }else{
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Short" DealBuy:@"Short" DealSell:@"Cover"];
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
        
        for (int i = beginDateInt; i < today; i++) {
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

-(void)deleteDiaryData:(UIButton *)sender{
    UIButton *button = (UIButton *)sender;
    diaryCount = button.tag;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"確定刪除此筆記錄?", @"ActionPlan", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) otherButtonTitles:nil];
    [alert addButtonWithTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil)];
    [alert show];
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
    return [diaryArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"名稱", @"ActionPlan", nil)];
}

-(NSArray *)columnsFirstInMainTableView{
    return @[NSLocalizedStringFromTable(@"張數", @"ActionPlan", nil)];
}

-(NSArray *)columnsSecondInMainTableView{
    if (moreOptionButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"賣出均價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"回補均價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }
}

-(NSArray *)columnsThirdInMainTableView{
    return @[NSLocalizedStringFromTable(@"獲利", @"ActionPlan", nil)];
}

-(NSArray *)columnsFourthInMainTableView{
    if (moreOptionButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"買進均價", @"Position", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"放空均價", @"Position", nil), NSLocalizedStringFromTable(@"金額History", @"ActionPlan", nil)];
    }
}

-(void)updateFixedTableCellSymbolLabel:(UILabel *)symbolLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeDiaryFixedTableViewCell *)cell{
    diary = [diaryArray objectAtIndex:indexPath.row];
    NSString *string = diary.identCodeSymbol;
    NSString *identCode = [string substringToIndex:2];
    NSString *symbol = [string substringFromIndex:3];
    NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        symbolLabel.text = symbol;
    }else {
        symbolLabel.text = fullName;
    }
}

-(void)updateMainTableCellqtyLabel:(UILabel *)qtyLabel avgSellLabel:(UILabel *)avgSellLabel sellAmountLabel:(UILabel *)sellAmountLabel gainLabel:(UILabel *)gainLabel gainPercentLabel:(UILabel *)gainPercentLabel avgCost:(UILabel *)avgCost costAmountLabel:(UILabel *)costAmountLabel hBtn:(FSUIButton *)hBtn nBtn:(FSUIButton *)nBtn gBtn:(FSUIButton *)gBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSTradeDiaryMainTableViewCell *)cell{
    diary = [diaryArray objectAtIndex:indexPath.row];
    //張數
    qtyLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:diary.qty DecimalPoint:0]];
    
    //賣出均價
    avgSellLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:diary.avgPrice DecimalPoint:2]];
    
    //賣出金額
    sellAmountLabel.text = [self setPrice:diary.qty * diary.avgPrice * positionModel.suggestCount Decimal:0];
    
    //獲利
    if (diary.gainDollar > 0) {
        gainLabel.textColor = [StockConstant PriceUpColor];
        gainPercentLabel.textColor = [StockConstant PriceUpColor];
    }else if (diary.gainDollar < 0){
        gainLabel.textColor = [StockConstant PriceDownColor];
        gainPercentLabel.textColor = [StockConstant PriceDownColor];
    }else{
        gainLabel.textColor = [UIColor blueColor];
        gainPercentLabel.textColor = [UIColor blueColor];
    }
    
    gainLabel.text = [self setPrice:diary.gainDollar * positionModel.suggestCount Decimal:0];
    
    //獲利(%)
    gainPercentLabel.text = [NSString stringWithFormat:@"(%@%%)", [CodingUtil CoverFloatWithComma:diary.gainPercent*100 DecimalPoint:2]];
    
    //平均成本
    avgCost.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:diary.avgCost DecimalPoint:2]];
    
    //金額
    costAmountLabel.text = [self setPrice:diary.totalCost * positionModel.suggestCount Decimal:0];
    
    hBtn.tag = indexPath.row;
    [hBtn addTarget:self action:@selector(hBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    nBtn.tag = indexPath.row;
    [nBtn addTarget:self action:@selector(nBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    gBtn.tag = indexPath.row;
    [gBtn addTarget:self action:@selector(gBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //刪除
//    removeBtn.tag = indexPath.row;
//    [removeBtn addTarget:self action:@selector(deleteDiaryData:) forControlEvents:UIControlEventTouchUpInside];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    diary = [diaryArray objectAtIndex:indexPath.row];
    NSString *idSymbol = diary.identCodeSymbol;
    
    FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
    watchedPortfolio.portfolioItem = portfolioItem;
    mainViewController.firstLevelMenuOption =1;
    [self.navigationController pushViewController:mainViewController animated:NO];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.view setNeedsUpdateConstraints];
    [self setNavigationBtn];
}

-(NSString *)setPrice:(float)Price Decimal:(int)decimal{
    NSString *tempStr = @"";
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        tempStr = [CodingUtil CoverFloatWithCommaForCN:Price];
    }else{
        tempStr = [CodingUtil CoverFloatWithComma:Price DecimalPoint:decimal];
    }
    
    return tempStr;
}
@end
