//
//  FSBrokerOptionalListViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerOptionalListViewController.h"
#import "SKCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FSMainPlusDateRangeViewController.h"
#import "CXAlertView.h"
#import "FSBrokerParametersViewController.h"
#import "FSBrokerInAndOutListViewController.h"
#import "FSBranchInAndOutListViewController.h"
#import "FSMainPlusOut.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"


@interface FSBrokerOptionalListViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, DataArriveProtocol>{

    UILabel *titleLeftLabel;
    UILabel *titleRightLabel;
    UILabel *titleSecondLabel;
    
    FSUIButton *brokerBtn;
    FSUIButton *rankBtn;
    FSUIButton *dateBtn;
    FSUIButton *titleBtn;
    
    SKCustomTableView *skMainTableView;
    UIView *btnContainer;
    
    NSMutableArray *overBoughtArray;
    NSMutableArray *overSoldArray;
    NSMutableArray *rankBtnTitle;
    NSMutableArray *titleBtnTitle;
    NSMutableArray *optionListTitle;
    
    NSMutableArray *changeTableViewTitle;
    UIActionSheet *mainActionSheet;
    FSDataModelProc *dataModel;
    int sortType;
    int pickDay;
    int sDate;
    int eDate;
    
    NSMutableArray *totalSaleArray;
    NSMutableArray *differenceArray;
    FSEmergingObject *fsemobj;
    UITableView *custTableView;
    CXAlertView *cxAlertView;
    int checkedCell;
    NSMutableArray *fromBrokerOptional;
    NSTimer *timer;
    NSMutableArray *branchIDArray;
    SymbolFormat1 *symbol1;
    NSString *identCodeSymbol;
}

@end

@implementation FSBrokerOptionalListViewController



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [dataModel.mainBargaining setTarget:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [titleBtn setTitle:@"自選主力進出表" forState:UIControlStateNormal];
    dataModel = [FSDataModelProc sharedInstance];
    [dataModel.mainBargaining setTarget:self];
    [self sendAndSearchDB];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initVar];
    [self initDatabase];
    
}
-(void)initView{
    [self setUpImageBackButton];

    fsemobj = [FSEmergingObject new];

    sortType = 0;
    checkedCell = 0;
    titleBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];

    [titleBtn setFrame:CGRectMake(0, 0, 170, 44)];
    [titleBtn addTarget:self action:@selector(changeTable) forControlEvents:UIControlEventTouchUpInside];
    btnContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 170, 44)];
    [btnContainer addSubview:titleBtn];
    self.navigationItem.titleView = btnContainer;

    titleLeftLabel = [UILabel new];
    titleLeftLabel.font = [UIFont systemFontOfSize:20.0f];
    titleLeftLabel.text = @"券商";
    titleLeftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLeftLabel];

    titleRightLabel = [UILabel new];
    titleRightLabel.font = [UIFont systemFontOfSize:20.0f];
    titleRightLabel.text = @"排行";
    titleRightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleRightLabel];

    titleSecondLabel = [UILabel new];
    titleSecondLabel.font = [UIFont systemFontOfSize:20.0f];
    titleSecondLabel.text = @"日期";
    titleSecondLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleSecondLabel];

    brokerBtn =  [self.view newButton:FSUIButtonTypeNormalRed];
    brokerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    brokerBtn.translatesAutoresizingMaskIntoConstraints = NO;

    [brokerBtn addTarget:self action:@selector(optionalList) forControlEvents:UIControlEventTouchUpInside];

    rankBtn =  [self.view newButton:FSUIButtonTypeBlueGreenDetailButton];
    rankBtn.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    rankBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [rankBtn setTitle:@"買超" forState:UIControlStateNormal];
    [rankBtn addTarget:self action:@selector(rankList) forControlEvents:UIControlEventTouchUpInside];

    dateBtn =  [self.view newButton:FSUIButtonTypeNormalRed];
    dateBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    dateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [dateBtn setTitle:@"" forState:UIControlStateNormal];
    [dateBtn addTarget:self action:@selector(pushToDatePick) forControlEvents:UIControlEventTouchUpInside];

    skMainTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:80 mainColumnWidth:77 AndColumnHeight:44];
    skMainTableView.delegate = self;
    skMainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:skMainTableView];

    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *contraints = [NSMutableArray new];
    NSDictionary *viewContraints = NSDictionaryOfVariableBindings(titleLeftLabel, titleRightLabel, titleSecondLabel, brokerBtn, rankBtn, dateBtn, skMainTableView);
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLeftLabel(40)]-2-[brokerBtn(150)]-2-[titleRightLabel(40)]-2-[rankBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleSecondLabel(40)]-2-[dateBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[skMainTableView]|" options:0 metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[brokerBtn]-2-[dateBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewContraints]];
    
    [self replaceCustomizeConstraints:contraints];
}

-(void)initVar{
    
    overBoughtArray = [NSMutableArray arrayWithObjects:@"買超", @"買進", @"賣出", @"買超率", @"買均價", @"賣均價", nil];
    overSoldArray = [NSMutableArray arrayWithObjects:@"賣超", @"買進", @"賣出", @"賣超率", @"買均價", @"賣均價", nil];
    totalSaleArray = [NSMutableArray arrayWithObjects:@"買賣合", @"買進", @"賣出", @"合計率", @"買均價", @"賣均價" , nil];
    differenceArray = [NSMutableArray arrayWithObjects:@"買賣差", @"買進", @"賣出", @"差額率", @"買均價", @"賣均價" , nil];
    titleBtnTitle = [NSMutableArray arrayWithObjects:@"券商分公司進出表", @"券商進出表", @"自選主力進出表", nil];
    rankBtnTitle = [NSMutableArray arrayWithObjects:@"買超", @"賣超", @"買賣合計", @"買賣差額", nil];
   
    changeTableViewTitle = [NSMutableArray arrayWithArray:overBoughtArray];
}
-(void)notifyDataArrive:(NSMutableArray *)array{
    
    fromBrokerOptional = [NSMutableArray arrayWithArray:array];
    [self loadServerDate];
    
    [skMainTableView reloadDataNoOffset];
}
-(void)pushToDatePick{
    
    FSMainPlusDateRangeViewController *dateView = [FSMainPlusDateRangeViewController new];
    [self.navigationController pushViewController:dateView animated:NO];
}

-(void)changeTable{
    
    mainActionSheet = [[UIActionSheet alloc]initWithTitle:@"選擇種類" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for(i = 0; i < [titleBtnTitle count]; i++){
        NSString *actionSheetTitle = [titleBtnTitle objectAtIndex:i];
        [mainActionSheet addButtonWithTitle:actionSheetTitle];
    }
    [mainActionSheet addButtonWithTitle:@"取消"];
    [mainActionSheet cancelButtonIndex];
    [mainActionSheet setTag:0];
    [mainActionSheet showInView:self.view];
}

-(void)rankList{
    
    mainActionSheet = [[UIActionSheet alloc]initWithTitle:@"選擇排行" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for(i = 0; i < [rankBtnTitle count]; i++){
        NSString *actionSheetTitle = [rankBtnTitle objectAtIndex:i];
        [mainActionSheet addButtonWithTitle:actionSheetTitle];
    }
    [mainActionSheet addButtonWithTitle:@"取消"];
    [mainActionSheet cancelButtonIndex];
    [mainActionSheet setTag:1];
    [mainActionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (mainActionSheet.tag == 0) {
        if (buttonIndex < [titleBtnTitle count]) {
            [titleBtn setTitle:[titleBtnTitle objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                FSBranchInAndOutListViewController *branchView = [FSBranchInAndOutListViewController new];
                [self.navigationController pushViewController:branchView animated:NO];
            }else if (buttonIndex == 1){
                FSBrokerInAndOutListViewController *brokerView = [FSBrokerInAndOutListViewController new];
                [self.navigationController pushViewController:brokerView animated:NO];
            }else{
                return;
            }
        }
    }else{
        if (buttonIndex < [rankBtnTitle count]) {
            [rankBtn setTitle:[rankBtnTitle objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            [self showTableViewTitleAndSetSortType:(int)buttonIndex];
            [self sendAndSearchDB];
        }
    }
}

-(void)optionalList{

    UIView *customView = [UIView new];

    cxAlertView = [[CXAlertView alloc]initWithTitle:@"自選主力" contentView:customView cancelButtonTitle:nil];
    cxAlertView.contentScrollViewMaxHeight = 350;
    cxAlertView.contentScrollViewMinHeight = 300;
    
    __block FSBrokerOptionalListViewController *weakSelf = self;
    [cxAlertView.contentView setFrame:CGRectMake(0, 0, 280, 350)];
    [cxAlertView addButtonWithTitle:@"主力設定" type:CXAlertViewButtonTypeCancel handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        [weakSelf pushToParametersView];

        [alertView dismiss];
    }];
    [cxAlertView addButtonWithTitle:@"取消" type:CXAlertViewButtonTypeCancel handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        [alertView dismiss];
    }];
    custTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, customView.frame.size.width, customView.frame.size.height) style:UITableViewStyleGrouped];
    custTableView.delegate = self;
    custTableView.dataSource = self;
    custTableView.bounces = NO;

    [customView addSubview: custTableView];
    
    [cxAlertView show];

}

-(NSArray *)columnsInFixedTableView{
    
    return @[@"股名"];
}

-(NSArray *)columnsInMainTableView{
    
    return changeTableViewTitle;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if ([tableView isEqual:custTableView]) {
        return [optionListTitle count];
    }else{
        return [fromBrokerOptional count];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:custTableView]) {
        return 55.0f;
    }else{
        return 44.0f;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"custTableViewCell";
    UITableViewCell *cell=[custTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.tag = indexPath.row;
    cell.textLabel.font=[UIFont systemFontOfSize:15];
    cell.textLabel.text = [optionListTitle objectAtIndex:indexPath.row];

    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (checkedCell == indexPath.row && tableView == custTableView) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == custTableView) {
        checkedCell = (int)indexPath.row;
        [brokerBtn setTitle:[optionListTitle objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        [fromBrokerOptional removeAllObjects];
        [skMainTableView reloadAllData];
        [self sendAndSearchDB];
        [cxAlertView dismiss];

    }else{
        FSBrokerOptional *optionalInfo = [fromBrokerOptional objectAtIndex:indexPath.row];
        symbol1 = optionalInfo.brokerBranchData.symbolFormat1;
        
        identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbol1->IdentCode[0], symbol1->IdentCode[1], symbol1->symbol];
        
        [dataModel.securitySearchModel setTarget:self];
        [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModel.thread withObject:symbol1 -> symbol waitUntilDone:NO];
    }
}

-(void)notifyArrive:(NSMutableArray *)dataArray{
    if ([dataArray count] > 2) {
        
        [dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[identCodeSymbol]];
        PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
        FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
        
        FSMainViewController *mainView = [FSMainViewController new];
        mainView.firstLevelMenuOption = ChipMenuItem;
        mainView.secondChipMenuOption = PowerPMenuItem;

        [self.navigationController pushViewController:mainView animated:NO];

    }else{
        [dataModel.securitySearchModel setTarget:self];
        [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModel.thread withObject:symbol1->fullName waitUntilDone:NO];
    }
}
-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"----";
    
    FSBrokerOptional *optionalInfo = [fromBrokerOptional objectAtIndex:indexPath.row];
    symbol1 = optionalInfo.brokerBranchData.symbolFormat1;
    label.text = symbol1 -> fullName;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    label.text = @"----";
    
    FSBrokerOptional *optionalInfo = [fromBrokerOptional objectAtIndex:indexPath.row];
    double buyShare = optionalInfo.brokerBranchData.buyAmount.calcValue;
    double buyPrice = optionalInfo.brokerBranchData.buyPrice.calcValue;
    double sellShare = optionalInfo.brokerBranchData.sellAmount.calcValue;
    double sellPrice = optionalInfo.brokerBranchData.sellPrice.calcValue;
    double minusBuyAndSellShare = buyShare - sellShare;
    double addBuyAndSellShare = buyShare + sellShare;
    double dealVolume = optionalInfo.brokerBranchData.dealAmount.calcValue / 100;
    
    label.textColor = [fsemobj compareTwoValue:buyShare :sellShare];
    switch (columnIndex) {
        case 0:
            if (sortType == 0 || sortType == 1) {
                label.text = [fsemobj convertZeroPlusOrNot:minusBuyAndSellShare / 1000];
            }else if(sortType == 4){
                label.text = [NSString stringWithFormat:@"%.0f", addBuyAndSellShare / 1000];
            }else{
                label.text = [NSString stringWithFormat:@"%.0f", fabs(minusBuyAndSellShare) /1000 ];
            }
            break;
        case 1:
            label.text = [NSString stringWithFormat:@"%.0f",floor(buyShare / 1000)];
            break;
        case 2:
            label.text = [NSString stringWithFormat:@"%.0f",floor(sellShare / 1000)];
            break;
        case 3://比率
            if (sortType == 4) {
                label.text = [fsemobj stringWithMarketMoverPercent:addBuyAndSellShare / dealVolume sign:NO];
            }else{
                label.text = [fsemobj stringWithMarketMoverPercent:fabs(minusBuyAndSellShare) / dealVolume sign:NO];
            }
            if (dealVolume == 0) {
                label.text = @"----";
                label.textColor = [UIColor blackColor];
            }
            break;
        case 4:
            if (buyPrice == 0) {
                label.textColor = [UIColor blackColor];
            }
            label.text = [fsemobj convertQuotesToString:buyPrice];
            break;
        case 5:
            if (sellPrice == 0) {
                label.textColor = [UIColor blackColor];
            }
            label.text = [fsemobj convertQuotesToString:sellPrice];
            break;
        default:
            break;
    }
}

-(void)findModelStartAndEndDay{
    if (dataModel.cyqModel.startDate == 0 || dataModel.cyqModel.endDate == 0) {
        NSDate *today = [[NSDate alloc]init];
        
        dataModel.cyqModel.startDate = today;
        dataModel.cyqModel.endDate = today;
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *compsStart = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dataModel.cyqModel.startDate];
    int yearStart = (int)[compsStart year];
    int monthStart = (int)[compsStart month];
    int dayStart = (int)[compsStart day];
    NSDateComponents *compsEnd = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dataModel.cyqModel.endDate];
    int yearEnd = (int)[compsEnd year];
    int monthEnd = (int)[compsEnd month];
    int dayEnd = (int)[compsEnd day];
    
    sDate = [CodingUtil makeDate:yearStart month:monthStart day:dayStart];
    eDate = [CodingUtil makeDate:yearEnd month:monthEnd day:dayEnd];
}

-(void)changeDateBtnTitle:(NSTimer *)incomingTimer{
    
    FSBrokerOptional *brokerOptional = [fromBrokerOptional firstObject];
    NSString *startDateStrTmp = [CodingUtil getStringDatePlusZero:brokerOptional.startDate];
    NSString *endDateStrTmp = [CodingUtil getStringDatePlusZero:brokerOptional.endDate];
    NSString *startDateStr = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *startDateStrForBtnTitle = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *endDateStr = [endDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([startDateStr isEqualToString:endDateStr]) {
        [dateBtn setTitle:[NSString stringWithFormat:@"%@", startDateStrForBtnTitle] forState:UIControlStateNormal];
    }else{
        [dateBtn setTitle:[NSString stringWithFormat:@"%@ - %@",startDateStr, endDateStr] forState:UIControlStateNormal];
        
    }
}

-(void)initDatabase{
    NSMutableArray *tableViewTitleDB = [NSMutableArray arrayWithObjects:@"主力1", @"主力2", @"主力3", @"主力4", @"主力5", nil];
    
    dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    __block BOOL hasData = NO;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BrokerOptional (GroupIndex INTEGER PRIMARY KEY NOT NULL, Name TEXT)"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS BrokerOptionalID (SID INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL UNIQUE, GroupIndex INTEGER, BrokerBranchID TEXT)"];
        
        FMResultSet *message = [db executeQuery:@"SELECT * FROM BrokerOptional WHERE GroupIndex = 1"];
        while ([message next]) {
            hasData = YES;
            NSString *title = [message stringForColumn:@"Name"];
            [brokerBtn setTitle:title forState:UIControlStateNormal];
        }
        if (!hasData) {
            for(int i = 0; i < [tableViewTitleDB count]; i++){
                [db executeUpdate:@"INSERT INTO BrokerOptional (GroupIndex, Name) VALUES(?,?)", [NSNumber numberWithInt:i + 1], [tableViewTitleDB objectAtIndex:i]];
                [brokerBtn setTitle:[tableViewTitleDB objectAtIndex:0] forState:UIControlStateNormal];
            }
        }
        [message close];
    }];

}
-(void)searchTableViewTitle{
    dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    optionListTitle = [NSMutableArray new];
    branchIDArray = [NSMutableArray new];
    int groupIndex = checkedCell + 1;
    __block BOOL hasData = NO;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
//        searchTitleLabel
        FMResultSet *message = [db executeQuery:@"SELECT Name FROM BrokerOptional"];
        while ([message next]) {
            NSString *title = [message stringForColumn:@"Name"];
            [optionListTitle addObject:title];
        }
        [message close];
        
        FMResultSet *message1 = [db executeQuery:@"SELECT BrokerBranchID FROM BrokerOptionalID WHERE GroupIndex = ?", [NSNumber numberWithInt:groupIndex]];
        while ([message1 next]) {
            hasData = YES;
            NSString *title = [message1 stringForColumn:@"BrokerBranchID"];
            [branchIDArray addObject:title];
        }
        [message1 close];
        
    }];
    
    if (!hasData) {
        [self performSelectorOnMainThread:@selector(sendErrorMessage) withObject:nil waitUntilDone:NO];
        
    }
}
-(void)sendErrorMessage{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"未設定主力分點" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"主力設定", @"取消", nil];
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self pushToParametersView];
    }else{
        return;
    }
}
-(void)loadServerDate{
    
    FSBrokerOptional *optionalInfo = [fromBrokerOptional firstObject];
    
    int dateValSt = optionalInfo.startDate;
    int dateValEn = optionalInfo.endDate;
    dataModel.cyqModel.startDate = [[NSNumber numberWithInt:dateValSt]uint16ToDate];
    dataModel.cyqModel.endDate = [[NSNumber numberWithInt:dateValEn]uint16ToDate];
    
    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeRecently) {
        switch (dataModel.cyqModel.pickDays) {
            case 1:
                [dateBtn setTitle:@"1日累計" forState:UIControlStateNormal];
                break;
            case 5:
                [dateBtn setTitle:@"5日累計" forState:UIControlStateNormal];
                break;
            case 10:
                [dateBtn setTitle:@"10日累計" forState:UIControlStateNormal];
                break;
            case 20:
                [dateBtn setTitle:@"20日累計" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeDateBtnTitle:) userInfo:nil repeats:NO];
    }else{
        [self changeDateBtnTitle:0];
    }
}

-(void)showTableViewTitleAndSetSortType:(int)index{
    switch (index) {
        case 0:
            changeTableViewTitle = [NSMutableArray arrayWithArray:overBoughtArray];
            sortType = 0;
            break;
        case 1:
            changeTableViewTitle = [NSMutableArray arrayWithArray:overSoldArray];
            sortType = 1;
            break;
        case 2:
            changeTableViewTitle = [NSMutableArray arrayWithArray:totalSaleArray];
            sortType = 4;
            break;
        case 3:
            changeTableViewTitle = [NSMutableArray arrayWithArray:differenceArray];
            sortType = 5;
            break;
        default:
            break;
    }
}

-(void)sendOptionalPacket{
    [self findModelStartAndEndDay];
    if ([branchIDArray firstObject] != nil) {
        if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeCalendar) {
            
            OptionalMainOut *optionPacket = [[OptionalMainOut alloc]initWithBrokerBranchId:branchIDArray days:0 startDate:sDate endDate:eDate count:30 sortType:sortType];
            [FSDataModelProc sendData:self WithPacket:optionPacket];

        }else{
            if (dataModel.cyqModel.pickDays == 0) {
                dataModel.cyqModel.pickDays = 1;
            }

            OptionalMainOut *optionPacket = [[OptionalMainOut alloc]initWithidBrokerBranchId:branchIDArray days:dataModel.cyqModel.pickDays count:30 sortType:sortType];

            [FSDataModelProc sendData:self WithPacket:optionPacket];
        }
    }
}
-(void)pushToParametersView{
    FSBrokerParametersViewController *nextView = [FSBrokerParametersViewController new];
    [self.navigationController pushViewController:nextView animated:NO];
}
-(void)sendAndSearchDB{
    
    [self searchTableViewTitle];
    [self sendOptionalPacket];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
