//
//  FSMainPlusViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainPlusViewController.h"
#import "SKCustomTableView.h"
#import "DateRangeViewController.h"
#import "FSMainPlusOut.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSEmergingObject.h"
#import "FSMainPlusDateRangeViewController.h"
#import "FSMainViewController.h"
#import "FSBranchInAndOutListViewController.h"

@interface FSMainPlusViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate>{
    FSUIButton *pickDateBtn;
    FSUIButton *buyAndSellBtn;
    FSEmergingObject *fsemobj;
    SKCustomTableView *skMainTableView;
    FSDataModelProc *dataModel;
    FSBrokerBranchByStock *branchInfoByStock;
    PortfolioItem *portfolioItem;
    
    NSMutableArray *pickRankArray;
    NSMutableArray *overBoughtArray;
    NSMutableArray *overSoldArray;
    NSMutableArray *totalSaleArray;
    NSMutableArray *differenceArray;
    NSMutableArray *changeTableViewTitle;
    NSMutableArray *fromBrokerBranch;
    
    NSString *branchName;
    NSString *brokerName;
    NSString *ratioAddForAnchor;
    NSString *ratioMinusForAnchor;
    NSString *buyPriceForAnchor;
    NSString *sellPriceForAnchor;
    
    NSTimer *timer;
    
    int brokerID;
    int sortType;
    int sDate;
    int eDate;
    int todayForKLine;
    int endDayForKLine;
    int ratioCount;
    int buyPriceTotalCount;
    int sellPriceTotalCount;
    
    double buyShareTotal;
    double sellShareTotal;
    double ratioMinus;
    double ratioAdd;
    double buyPriceTotal;
    double sellPriceTotal;
    double buyShare;
    double buyPrice;
    double sellShare;
    double sellPrice;
    double minusBuyAndSellShare;
    double addBuyAndSellShare;
    double dealVolume;
    
//    lastPage:
    UILabel *titleLabelLeft;
    UILabel *titleLabelRight;

    NSMutableArray *overBoughtArrayDetail;
    NSMutableArray *overSoldArrayDetail;
    NSMutableArray *totalSaleArrayDetail;
    NSMutableArray *differenceArrayDetail;    
}

@end

@implementation FSMainPlusViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BrokersByModel sharedInstance].brokerTrackingViewController = FSBrokerInAndOutView;
    [dataModel.mainBargaining setTarget:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([BrokersByModel sharedInstance].brokerTrackingViewController == FSBrokerInAndOutView) {
        [self sendBranchStockToServerWithOptionType];

    }else if ([BrokersByModel sharedInstance].brokerTrackingViewController == FSBranchInAndOutView){
        [self loadToFile];
    }
    [dataModel.mainBargaining setTarget:self];

    [self.view showHUDWithTitle:@""];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void)viewDidLayoutSubviews{

    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
    [self initArray];
}
-(void)initView{
    [self.navigationController setNavigationBarHidden:YES];
    
    fsemobj = [[FSEmergingObject alloc]init];

    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    pickDateBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    pickDateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    pickDateBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    
    [pickDateBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickDateBtn];
    
    buyAndSellBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    buyAndSellBtn.translatesAutoresizingMaskIntoConstraints = NO;
    buyAndSellBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [buyAndSellBtn setTitle:@"買超" forState:UIControlStateNormal];
    [buyAndSellBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buyAndSellBtn];
    
//    BrokerBranchByAnchor Page 2
    titleLabelLeft = [[UILabel alloc]init];
    titleLabelLeft.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabelLeft.textColor = [UIColor brownColor];
    titleLabelLeft.font = [UIFont systemFontOfSize:20.0];
    titleLabelLeft.text = @"";
    titleLabelLeft.hidden = YES;
    [self.view addSubview:titleLabelLeft];
    
    titleLabelRight = [[UILabel alloc]init];
    titleLabelRight.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabelRight.font = [UIFont systemFontOfSize:22.0];
    titleLabelRight.text = @"";
    titleLabelRight.hidden = YES;
    [self.view addSubview:titleLabelRight];
    
    skMainTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:100 mainColumnWidth:77 AndColumnHeight:44];
    skMainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    skMainTableView.delegate = self;
    [self.view addSubview:skMainTableView];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)initArray{
    
//    BrokerBranchByStock Page 1
    pickRankArray = [NSMutableArray arrayWithObjects:@"買超", @"賣超", @"買賣合計", @"買賣差額", nil];
    overBoughtArray = [NSMutableArray arrayWithObjects:@"買超", @"買進", @"賣出", @"買超率", @"買均價", @"賣均價", nil];
    overSoldArray = [NSMutableArray arrayWithObjects:@"賣超", @"買進", @"賣出", @"賣超率", @"買均價", @"賣均價", nil];
    totalSaleArray = [NSMutableArray arrayWithObjects:@"買賣合", @"買進", @"賣出", @"合計率", @"買均價", @"賣均價" , nil];
    differenceArray = [NSMutableArray arrayWithObjects:@"買賣差", @"買進", @"賣出", @"差額率", @"買均價", @"賣均價" , nil];
    changeTableViewTitle = [NSMutableArray arrayWithArray:overBoughtArray];
    
//    BrokerBranchByAnchor Page 2
    overBoughtArrayDetail = [NSMutableArray arrayWithObjects:@"買超", @"買進", @"賣出", @"買超率", nil];
    overSoldArrayDetail = [NSMutableArray arrayWithObjects:@"買超", @"買進", @"賣出", @"賣超率", nil];
    totalSaleArrayDetail = [NSMutableArray arrayWithObjects:@"買超", @"買進", @"賣出", @"合計率", nil];
    differenceArrayDetail = [NSMutableArray arrayWithObjects:@"買超", @"買進", @"賣出", @"差額率", nil];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(pickDateBtn, buyAndSellBtn, titleLabelLeft, titleLabelRight, skMainTableView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickDateBtn(210)]-2-[buyAndSellBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[skMainTableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabelLeft]-[titleLabelRight]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabelLeft]-[skMainTableView]-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pickDateBtn]-2-[skMainTableView]-|" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}
-(void)notifyDataArrive:(NSMutableArray *)array{
    fromBrokerBranch = [NSMutableArray arrayWithArray:array];
    
//    BrokerBranchByStock Page 1
    if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByStock class]]) {
        
        [self loadServerDate];
        
//    BrokerBranchByAnchor Page 2
    }else if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByAnchor class]]){
        
//        總和運算
        [self totaling];

//    BrokerBranchDetailByAnchor Page 3
    }else if([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchDetailByAnchor class]]){
        FSBrokerBranchDetailByAnchor *detailByAnchor = [fromBrokerBranch firstObject];
        titleLabelLeft.text = [NSString stringWithFormat:@"%@", [CodingUtil getStringDatePlusZero:detailByAnchor.dataDate]];
    }
    
    [skMainTableView reloadAllData];
    [self.view hideHUD];

}
-(void)loadServerDate{
    branchInfoByStock = [fromBrokerBranch firstObject];
    
    int dateValSt = branchInfoByStock.startDate;
    int dateValEn = branchInfoByStock.endDate;
    dataModel.cyqModel.startDate = [[NSNumber numberWithInt:dateValSt]uint16ToDate];
    dataModel.cyqModel.endDate = [[NSNumber numberWithInt:dateValEn]uint16ToDate];
    
    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeRecently) {
        switch (dataModel.cyqModel.pickDays) {
            case 1:
                [pickDateBtn setTitle:@"1日累計" forState:UIControlStateNormal];
                break;
            case 5:
                [pickDateBtn setTitle:@"5日累計" forState:UIControlStateNormal];
                break;
            case 10:
                [pickDateBtn setTitle:@"10日累計" forState:UIControlStateNormal];
                break;
            case 20:
                [pickDateBtn setTitle:@"20日累計" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changePickDateTitle:) userInfo:nil repeats:NO];
    }else{
        [self changePickDateTitle:0];
    }
    
}
-(void)btnHandler:(UIButton *)sender{
    if ([sender isEqual:buyAndSellBtn]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"選擇排行" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        int i;
        for (i = 0; i <[pickRankArray count]; i++){
            NSString *actionSheetTitle = [pickRankArray objectAtIndex:i];
            [actionSheet addButtonWithTitle:actionSheetTitle];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        [actionSheet setCancelButtonIndex:i];
        [actionSheet showInView:self.view];
    }else{
        FSMainPlusDateRangeViewController *dateView = [[FSMainPlusDateRangeViewController alloc]init];
        [self.navigationController pushViewController:dateView animated:NO];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex < [pickRankArray count]) {
        [buyAndSellBtn setTitle:[pickRankArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];

        [self showTableViewTitleAndSetSortType:(int)buttonIndex];
        [self sendBranchStockToServerWithOptionType];
        [self.view showHUDWithTitle:@""];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    BrokerBranchByAnchor Page 2 加上總和欄位
    if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByAnchor class]]) {
        if (sDate != eDate) {
            return [fromBrokerBranch count] + 1;
        }
    }
    return [fromBrokerBranch count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSArray *)columnsInFixedTableView{
    NSArray *tableViewFixed = nil;
    
//    BrokerBranchByStock Page 1
    if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByStock class]]) {
        tableViewFixed = @[@"券商分公司"];
        
//    BrokerBranchByAnchor Page 2
    }else if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByAnchor class]]) {
        tableViewFixed = @[@"日期"];
    }else{
        
//    BrokerBranchDetailByAnchor Page 3
        tableViewFixed = @[@"成交單價"];
    }
    return tableViewFixed;
}

-(NSArray *)columnsInMainTableView{
    return changeTableViewTitle;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    default
    label.font = [UIFont systemFontOfSize:18.0];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blueColor];
    label.adjustsFontSizeToFitWidth = YES;
//    BrokerBranchByStock Page 1
    if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByStock class]]) {
        branchInfoByStock = [fromBrokerBranch objectAtIndex:indexPath.row];
        [self loadDBWithBranchName:branchInfoByStock.brokerBranchData.brokerBranchID];

        label.text = [self compareBrokerNameAndBranchName];
        label.font = [UIFont systemFontOfSize:15.0];
    }
    
//    BrokerBranchByAnchor Page 2
    else if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByAnchor class]]) {
        if ([fromBrokerBranch count] == indexPath.row) {
            label.text = @"總和";
        }else{
            FSBrokerBranchByAnchor *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
            label.text = [CodingUtil getStringDatePlusZero:branchInfo.brokerBranchData.dataDate];
        }
        
//    BrokerBranchDetailByAnchor Page 3
    }else{
        FSBrokerBranchDetailByAnchor *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
        label.text = [NSString stringWithFormat:@"%.2f", branchInfo.brokerBranchData.dealShare.calcValue];
    }
}
-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    BrokerBranchByStock Page 1
    if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByStock class]]) {
        branchInfoByStock = [fromBrokerBranch objectAtIndex:indexPath.row];
        buyShare = branchInfoByStock.brokerBranchData.buyShare.calcValue;
        buyPrice = branchInfoByStock.brokerBranchData.buyPrice.calcValue;
        sellShare = branchInfoByStock.brokerBranchData.sellShare.calcValue;
        sellPrice = branchInfoByStock.brokerBranchData.sellPrice.calcValue;
        minusBuyAndSellShare = buyShare - sellShare;
        addBuyAndSellShare = buyShare + sellShare;
        dealVolume = branchInfoByStock.dealVolume.calcValue / 100;
        
//    BrokerBranchByAnchor Page 2
    }else if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByAnchor class]]) {
        if (indexPath.row != [fromBrokerBranch count]) {
            FSBrokerBranchByAnchor *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
            buyShare = branchInfo.brokerBranchData.buyShare.calcValue;
            buyPrice = branchInfo.brokerBranchData.buyPrice.calcValue;
            sellShare = branchInfo.brokerBranchData.sellShare.calcValue;
            sellPrice = branchInfo.brokerBranchData.sellPrice.calcValue;
            minusBuyAndSellShare = buyShare - sellShare;
            addBuyAndSellShare = buyShare + sellShare;
            dealVolume = branchInfo.brokerBranchData.dealShare.calcValue/ 100;
        }else {
//            for總合欄位
            switch (columnIndex) {
                case 0:
                    if (sortType < 2) {
                        label.text = [fsemobj convertZeroPlusOrNot:(buyShareTotal - sellShareTotal) / 1000];
                    }else if(sortType == 4){
                        label.text = [NSString stringWithFormat:@"%.0f", (buyShareTotal + sellShareTotal) /1000 ];
                    }else{
                        label.text = [NSString stringWithFormat:@"%.0f", fabs(buyShareTotal - sellShareTotal) /1000 ];
                    }
                    break;
                case 1:
                    label.text = [NSString stringWithFormat:@"%.0f", buyShareTotal /1000];
                    break;
                case 2:
                    label.text = [NSString stringWithFormat:@"%.0f", sellShareTotal /1000];
                    break;
                case 3:
                    if (sortType == 4) {
                        label.text = ratioAddForAnchor;
                    }else{
                        label.text = ratioMinusForAnchor;
                    }
                    break;
                case 4:
                    label.text = buyPriceForAnchor;
                    break;
                case 5:
                    label.text = sellPriceForAnchor;
                    break;
                default:
                    break;
            }
            label.textColor = [fsemobj compareTwoValue:buyShareTotal :sellShareTotal];
            return;
        }
    }else{
//    BrokerBranchDetailByAnchor Page 3
        FSBrokerBranchDetailByAnchor *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
        buyShare = branchInfo.brokerBranchData.buyShare.calcValue;
        sellShare = branchInfo.brokerBranchData.sellShare.calcValue;
        minusBuyAndSellShare = buyShare - sellShare;
        addBuyAndSellShare = buyShare + sellShare;
        dealVolume = branchInfo.dealVolume.calcValue / 100;
    }
    label.textColor = [fsemobj compareTwoValue:buyShare :sellShare];
    switch (columnIndex) {
        case 0:
            if (sortType < 2) {
                label.text = [fsemobj convertZeroPlusOrNot:minusBuyAndSellShare / 1000];
            }else if(sortType == 4){
                label.text = [NSString stringWithFormat:@"%.0f", addBuyAndSellShare /1000 ];
            }else{
                label.text = [NSString stringWithFormat:@"%.0f", fabs(minusBuyAndSellShare) /1000 ];
            }
            break;
        case 1:
            label.text = [NSString stringWithFormat:@"%.0f",buyShare / 1000];
            break;
        case 2:
            label.text = [NSString stringWithFormat:@"%.0f",sellShare / 1000];
            break;
        case 3://比率
            if (sortType == 4) {
                label.text = [fsemobj stringWithMarketMoverPercent:(addBuyAndSellShare) / dealVolume sign:NO];
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
-(void)loadDBWithBranchName:(NSString *)brokerBranchID{
    
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *brokerIDArray = [[NSMutableArray alloc]init];
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {

        FMResultSet *searchNameAndBrokerIDWithBrokerBranchID = [db executeQuery:@"SELECT * FROM brokerBranch where BrokerBranchID = ?",brokerBranchID];
        while ([searchNameAndBrokerIDWithBrokerBranchID next]) {
            
            brokerID = [searchNameAndBrokerIDWithBrokerBranchID intForColumn:@"BrokerID"];
            branchName = [searchNameAndBrokerIDWithBrokerBranchID stringForColumn:@"Name"];
            [brokerIDArray addObject:[NSString stringWithFormat:@"%d", brokerID]];
        }
        [searchNameAndBrokerIDWithBrokerBranchID close];
    }];
    
    [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        for (int i = 0; i < [brokerIDArray count]; i++){
            FMResultSet *searchNameWithBrokerID = [db executeQuery:@"SELECT Name FROM brokerName where BrokerID = ?",[brokerIDArray objectAtIndex:i]];
            while ([searchNameWithBrokerID next]) {
                if (![[NSString stringWithFormat:@"%@", [brokerIDArray objectAtIndex:i]]isEqualToString:brokerBranchID]) {
                }
                brokerName = [searchNameWithBrokerID stringForColumn:@"Name"];
            }
            [searchNameWithBrokerID close];
        }
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    BrokerBranchByStock Page 1
    if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByStock class]]) {
        branchInfoByStock = [fromBrokerBranch objectAtIndex:indexPath.row];

//        判斷是否為左邊的TableView
        if (tableView == skMainTableView.fixedTableView) {
            [self findTodayAndTwoAndAHalf];
            MainBranchKLineOut *kLinePacket = [[MainBranchKLineOut alloc]initWithSymbol:portfolioItem -> symbol brokerBranchIdD:branchInfoByStock.brokerBranchData.brokerBranchID dataType:0 count:0 startDate:endDayForKLine endDate:todayForKLine];
            [FSDataModelProc sendData:self WithPacket:kLinePacket];
            
//            FSMainViewController *mainView = [[FSMainViewController alloc]init];
//            mainView.firstLevelMenuOption = 1;
//            [self.navigationController pushViewController:mainView animated:NO];
            return;
        }else{
            [self saveStockInfo];
            [self showTitleLabelleft];
            [self loadDBWithBranchName:branchInfoByStock.brokerBranchData.brokerBranchID];
            titleLabelRight.text = [self compareBrokerNameAndBranchName];
            [self sendBranchAnchorToServerWithOptionType:branchInfoByStock.symbol :branchInfoByStock.brokerBranchData.brokerBranchID];
            pickDateBtn.hidden = YES;
            buyAndSellBtn.hidden = YES;
            titleLabelLeft.hidden = NO;
            titleLabelRight.hidden = NO;
        }
        
//    BrokerBranchByAnchor Page 2
    }else if ([[fromBrokerBranch firstObject] isKindOfClass:[FSBrokerBranchByAnchor class]]) {
        if ([fromBrokerBranch count] == indexPath.row) {
            return;
        };
        
        FSBrokerBranchByAnchor *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
        BrokerBranchDetailByAnchorOut *stockOutPacket = [[BrokerBranchDetailByAnchorOut alloc]initWithSymbol:branchInfo.symbol brokerBranchID:branchInfo.brokerBranchId dataDate:branchInfo.brokerBranchData.dataDate];
        [FSDataModelProc sendData:self WithPacket:stockOutPacket];
        switch (sortType) {
            case 0:
                changeTableViewTitle = [NSMutableArray arrayWithArray:overBoughtArrayDetail];
                break;
            case 1:
                changeTableViewTitle = [NSMutableArray arrayWithArray:overSoldArrayDetail];
                break;
            case 4:
                changeTableViewTitle = [NSMutableArray arrayWithArray:totalSaleArrayDetail];
                break;
            case 5:
                changeTableViewTitle = [NSMutableArray arrayWithArray:differenceArrayDetail];
                break;
            default:
                break;
        }
    }else{
        return;
    }
    [fromBrokerBranch removeAllObjects];
    [skMainTableView reloadAllData];
}
-(void)totaling{
    
    for(int i = 0; i < [fromBrokerBranch count]; i++){
        FSBrokerBranchByAnchor *branchInfoByAnchor = [fromBrokerBranch objectAtIndex:i];
        double buyShareForTotal = branchInfoByAnchor.brokerBranchData.buyShare.calcValue;
        double buyPriceForTotal = branchInfoByAnchor.brokerBranchData.buyPrice.calcValue;
        double sellShareForTotal = branchInfoByAnchor.brokerBranchData.sellShare.calcValue;
        double sellPriceForTotal = branchInfoByAnchor.brokerBranchData.sellPrice.calcValue;
        double minusBuyAndSellShareForTotal = buyShare - sellShare;
        double addBuyAndSellShareForTotal = buyShare + sellShare;
        double dealVolumeForTotal = branchInfoByAnchor.brokerBranchData.dealShare.calcValue/ 100;
        buyShareTotal += buyShareForTotal;
        sellShareTotal += sellShareForTotal;
        ratioMinus += (minusBuyAndSellShareForTotal) / dealVolumeForTotal;
        ratioAdd += (addBuyAndSellShareForTotal) / dealVolumeForTotal;
        if (buyPrice == 0) {
            buyPriceTotalCount++;
        }else{
            buyPriceTotal += buyPriceForTotal;
        }
        if (sellPrice == 0) {
            sellPriceTotalCount++;
        }else{
            sellPriceTotal += sellPriceForTotal;
        }
        if (dealVolume == 0) {
            ratioCount++;
        }
    }
    
}

-(void)saveStockInfo{
    
    ratioMinusForAnchor = [fsemobj stringWithMarketMoverPercent:fabs(branchInfoByStock.brokerBranchData.buyShare.calcValue - branchInfoByStock.brokerBranchData.sellShare.calcValue ) / (branchInfoByStock.dealVolume.calcValue / 100) sign:NO];
    ratioAddForAnchor = [fsemobj stringWithMarketMoverPercent:fabs(branchInfoByStock.brokerBranchData.buyShare.calcValue + branchInfoByStock.brokerBranchData.sellShare.calcValue ) / (branchInfoByStock.dealVolume.calcValue / 100) sign:NO];
    buyPriceForAnchor = [fsemobj convertQuotesToString:branchInfoByStock.brokerBranchData.buyPrice.calcValue];
    sellPriceForAnchor = [fsemobj convertQuotesToString:branchInfoByStock.brokerBranchData.sellPrice.calcValue];
}

-(void)sendBranchStockToServerWithOptionType{
    [self findModelStartAndEndDay];

    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeCalendar) {

        BrokerBranchByStockOut *brokerCalenderPacket = [[BrokerBranchByStockOut alloc]initWithSymbol:portfolioItem -> symbol days:0 startDate:sDate endDate:eDate sortType:sortType count:30];
        [FSDataModelProc sendData:self WithPacket:brokerCalenderPacket];
        
    }else{
        if (dataModel.cyqModel.pickDays == 0) {
            dataModel.cyqModel.pickDays = 1;
        }
        BrokerBranchByStockOut *stockOutPacket = [[BrokerBranchByStockOut alloc]initWithSymbol:portfolioItem -> symbol days:dataModel.cyqModel.pickDays sortType:sortType count:30];
        [FSDataModelProc sendData:self WithPacket:stockOutPacket];
    }
}
-(void)sendBranchAnchorToServerWithOptionType:(NSString *)anchorSymbol :(NSString *)anchorBranchID{
    [self findModelStartAndEndDay];
    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeCalendar) {
        
        BrokerBranchByAnchorOut *stockOutPacket = [[BrokerBranchByAnchorOut alloc]initWithSymbol:anchorSymbol brokerBranchID:anchorBranchID count:0 startDate:sDate endDate:eDate];
        [FSDataModelProc sendData:self WithPacket:stockOutPacket];
        
    }else{
        if (dataModel.cyqModel.pickDays == 0) {
            dataModel.cyqModel.pickDays = 1;
        }
        BrokerBranchByAnchorOut *stockOutPacket = [[BrokerBranchByAnchorOut alloc]initWithSymbol:anchorSymbol brokerBranchID:anchorBranchID count:dataModel.cyqModel.pickDays];
       [FSDataModelProc sendData:self WithPacket:stockOutPacket];
    }
}

-(void)showTitleLabelleft{
    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeRecently) {
        switch (dataModel.cyqModel.pickDays) {
            case 1:
                titleLabelLeft.text = @"1日累計";
                break;
            case 5:
                titleLabelLeft.text = @"5日累計";
                break;
            case 10:
                titleLabelLeft.text = @"10日累計";
                break;
            case 20:
                titleLabelLeft.text = @"20日累計";
                break;
            default:
                break;
        }
    }else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        
        NSString *startDateCYQ =[formatter stringFromDate:dataModel.cyqModel.startDate];
        NSString *endDateCYQ =[formatter stringFromDate:dataModel.cyqModel.endDate];

        titleLabelLeft.text = [NSString stringWithFormat:@"%@ - %@",startDateCYQ, endDateCYQ];
    }
}

-(void)findModelStartAndEndDay{
    dataModel = [FSDataModelProc sharedInstance];
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
-(void)findTodayAndTwoAndAHalf{
    NSDate *today = [[NSDate alloc]init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *compsToday = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int yearStart = (int)[compsToday year];
    int monthStart = (int)[compsToday month];
    int dayStart = (int)[compsToday day];
    NSDateComponents *compsTwoAndAHalf = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int yearEnd = (int)[compsTwoAndAHalf year];
    int monthEnd = (int)[compsTwoAndAHalf month];
    int dayEnd = (int)[compsTwoAndAHalf day];
    
    todayForKLine = [CodingUtil makeDate:yearStart month:monthStart day:dayStart];
    endDayForKLine = [CodingUtil makeDate:yearEnd - 2 month:monthEnd - 6 day:dayEnd];
}
-(void)changePickDateTitle:(NSTimer *)incomingTimer{

    branchInfoByStock = [fromBrokerBranch firstObject];
    NSString *startDateStrTmp = [CodingUtil getStringDatePlusZero:branchInfoByStock.startDate];
    NSString *endDateStrTmp = [CodingUtil getStringDatePlusZero:branchInfoByStock.endDate];
    NSString *startDateStr = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *startDateStrForBtnTitle = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *endDateStr = [endDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([startDateStr isEqualToString:endDateStr]) {
        [pickDateBtn setTitle:[NSString stringWithFormat:@"%@", startDateStrForBtnTitle] forState:UIControlStateNormal];
    }else{
        [pickDateBtn setTitle:[NSString stringWithFormat:@"%@ - %@",startDateStr, endDateStr] forState:UIControlStateNormal];

    }
}

-(NSString *)compareBrokerNameAndBranchName{
    NSString *labelName;
    if ([[brokerName substringToIndex:2] isEqualToString:[branchName substringToIndex:2]]) {
        labelName = brokerName;
    }else if([[NSString stringWithFormat:@"%d", brokerID] isEqualToString:branchInfoByStock.brokerBranchData.brokerBranchID]){
        labelName = brokerName;
    }else{
        labelName = [brokerName stringByAppendingString:branchName];
    }
    return labelName;
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

-(void)loadToFile{

    NSString *documents = [CodingUtil fonestockDocumentsPath];
    NSString *path = [documents stringByAppendingPathComponent:@"BranchInAndOutList.plist"];
    NSDictionary *loadDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    [self sendBranchAnchorToServerWithOptionType:[loadDic objectForKey:@"symbol"]:[loadDic objectForKey:@"brokerBranchID"]];
    ratioAddForAnchor = [loadDic objectForKey:@"addBuyAndSellShareSend"];
    ratioMinusForAnchor = [loadDic objectForKey:@"minusBuyAndSellShareSend"];
    buyPriceForAnchor = [loadDic objectForKey:@"buyPriceSend"];
    sellPriceForAnchor = [loadDic objectForKey:@"sellPriceSend"];
    [self loadDBWithBranchName:[loadDic objectForKey:@"brokerBranchID"]];
    
    [self showTitleLabelleft];
    titleLabelRight.text = [self compareBrokerNameAndBranchName];
    pickDateBtn.hidden = YES;
    buyAndSellBtn.hidden = YES;
    titleLabelLeft.hidden = NO;
    titleLabelRight.hidden = NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
