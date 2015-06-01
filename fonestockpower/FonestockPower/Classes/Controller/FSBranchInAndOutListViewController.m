//
//  FSBranchInAndOutListViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBranchInAndOutListViewController.h"
#import "SKCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FSMainPlusDateRangeViewController.h"
#import "FSMainPlusViewController.h"
#import "FSBrokerInAndOutListModel.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSBrokerChoiceCollectionViewController.h"
#import "FSMainPlusOut.h"
#import "FSBrokerInAndOutListViewController.h"
#import "FSEmergingObject.h"
#import "FSBrokerOptionalListViewController.h"
#import "FSMainViewController.h"

@interface FSBranchInAndOutListViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate, DataArriveProtocol>{

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

    NSMutableArray *changeTableViewTitle;
    UIActionSheet *mainActionSheet;
    FSDataModelProc *dataModel;
    int sortType;
    int pickDay;
    int sDate;
    int eDate;
    NSMutableArray *fromNewBrokerArray;
    NSMutableArray *brokerInfoArray;
    FSBrokerByBrokerData *brokerData;
    PortfolioItem *item;
    SymbolFormat1 *symbol1;
    FSEmergingObject *fsemobj;
    NSString *identCodeSymbol;
    NSMutableArray *totalSaleArray;
    NSMutableArray *differenceArray;
    NSMutableArray *fromBrokerBranch;
    
    NSTimer *timer;
    
//    for FSMainPlusViewController
    NSString *addBuyAndSellShareSend;
    NSString *minusBuyAndSellShareSend;
    NSString *buyPriceSend;
    NSString *sellPriceSend;
    NSMutableDictionary *mainDict;
    NSString *fullName;
}
@end

@implementation FSBranchInAndOutListViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [dataModel.mainBargaining setTarget:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dataModel = [FSDataModelProc sharedInstance];
    [dataModel.mainBargaining setTarget:self];
    [self.navigationController setNavigationBarHidden:NO];
    [titleBtn setTitle:@"券商分公司進出表" forState:UIControlStateNormal];
    [self defaluSetting];
    [self sendBranchStockToServerWithOptionType];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initVar];

}
-(void)initView{
    
    [self setUpImageBackButton];
    dataModel = [FSDataModelProc sharedInstance];
    fsemobj = [FSEmergingObject new];
    
//    reset BrokersByModel
    if (![BrokersByModel sharedInstance].brokerBranchID) {
        [BrokersByModel sharedInstance].brokerBranchID = @"1020";
//        [BrokersByModel sharedInstance].brokerName = @"合庫";
        [BrokersByModel sharedInstance].brokerNameForBranchView = @"合庫";

    };
    
    sortType = 0;
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
    [brokerBtn addTarget:self action:@selector(pushToBrokerList) forControlEvents:UIControlEventTouchUpInside];
    
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

-(void)defaluSetting{

    [BrokersByModel sharedInstance].brokerTrackingViewController = FSBranchInAndOutView;
    

    if ([BrokersByModel sharedInstance].brokerAnchorName) {
        [brokerBtn setTitle:[self compareBrokerNameAndBranchName] forState:UIControlStateNormal];
    }else{
        [brokerBtn setTitle:[BrokersByModel sharedInstance].brokerNameForBranchView forState:UIControlStateNormal];
    }
}

-(NSString *)compareBrokerNameAndBranchName{
    
    NSString *labelName;
    if ([[[BrokersByModel sharedInstance].brokerNameForBranchView substringToIndex:2] isEqualToString:[[BrokersByModel sharedInstance].brokerAnchorName substringToIndex:2]]) {
        labelName = [BrokersByModel sharedInstance].brokerNameForBranchView;
    }else{
        labelName = [[BrokersByModel sharedInstance].brokerNameForBranchView stringByAppendingString:[BrokersByModel sharedInstance].brokerAnchorName];
    }
    return labelName;
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

-(void)pushToBrokerList{
    
    FSBrokerChoiceCollectionViewController *collectionView = [FSBrokerChoiceCollectionViewController new];
    [self.navigationController pushViewController:collectionView animated:NO];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (mainActionSheet.tag == 0 && buttonIndex < [titleBtnTitle count]) {
        [titleBtn setTitle:[titleBtnTitle objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        if(buttonIndex == 0){
             return;
        }else if (buttonIndex == 1){
           
            FSBrokerInAndOutListViewController *brokerView = [FSBrokerInAndOutListViewController new];
            [self.navigationController pushViewController:brokerView animated:NO];
        }else{
            FSBrokerOptionalListViewController *optionalView = [FSBrokerOptionalListViewController new];
            [self.navigationController pushViewController:optionalView animated:NO];
        }
    }else if(mainActionSheet.tag == 1 && buttonIndex < [rankBtnTitle count]){
        [rankBtn setTitle:[rankBtnTitle objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        [self showTableViewTitleAndSetSortType:(int)buttonIndex];
        [self sendBranchStockToServerWithOptionType];

    }else{
        return;
    }
}

-(void)pushToDatePick{
    
    FSMainPlusDateRangeViewController *dateView = [FSMainPlusDateRangeViewController new];
    [self.navigationController pushViewController:dateView animated:NO];
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    
    fromBrokerBranch = [NSMutableArray arrayWithArray:array];
    [self loadServerDate];
    
    [skMainTableView reloadDataNoOffset];
}

-(NSArray *)columnsInFixedTableView{
    
    return @[@"股名"];
}

-(NSArray *)columnsInMainTableView{
    
    return changeTableViewTitle;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [fromBrokerBranch count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    
    FSBrokerBranchByBroker *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
    symbol1 = branchInfo.brokerBranchData.symbolFormat1;
    label.text = symbol1 -> fullName;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FSBrokerBranchByBroker *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
    double buyShare = branchInfo.brokerBranchData.buyAmount.calcValue;
    double buyPrice = branchInfo.brokerBranchData.buyPrice.calcValue;
    double sellShare = branchInfo.brokerBranchData.sellAmount.calcValue;
    double sellPrice = branchInfo.brokerBranchData.sellPrice.calcValue;
    double minusBuyAndSellShare = buyShare - sellShare;
    double addBuyAndSellShare = buyShare + sellShare;
    double dealVolume = branchInfo.brokerBranchData.dealAmount.calcValue / 100;
    
    label.textColor = [fsemobj compareTwoValue:buyShare :sellShare];
    switch (columnIndex) {
        case 0:
            if (sortType == 0 || sortType == 1) {
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    FSBrokerBranchByBroker *branchInfo = [fromBrokerBranch objectAtIndex:indexPath.row];
    fullName = branchInfo.brokerBranchData.symbolFormat1->fullName;
    
    minusBuyAndSellShareSend = [fsemobj stringWithMarketMoverPercent:(branchInfo.brokerBranchData.buyAmount.calcValue - branchInfo.brokerBranchData.sellAmount.calcValue ) / (branchInfo.brokerBranchData.dealAmount.calcValue / 100) sign:NO];
    
    addBuyAndSellShareSend = [fsemobj stringWithMarketMoverPercent:fabs(branchInfo.brokerBranchData.buyAmount.calcValue + branchInfo.brokerBranchData.sellAmount.calcValue ) / (branchInfo.brokerBranchData.dealAmount.calcValue / 100) sign:NO];
    
    buyPriceSend = [fsemobj convertQuotesToString:branchInfo.brokerBranchData.buyPrice.calcValue];
    sellPriceSend = [fsemobj convertQuotesToString:branchInfo.brokerBranchData.sellPrice.calcValue];
    
    mainDict = [NSMutableDictionary new];
    [mainDict setObject:minusBuyAndSellShareSend forKey:@"minusBuyAndSellShareSend"];
    [mainDict setObject:addBuyAndSellShareSend forKey:@"addBuyAndSellShareSend"];
    [mainDict setObject:buyPriceSend forKey:@"buyPriceSend"];
    [mainDict setObject:sellPriceSend forKey:@"sellPriceSend"];
    [mainDict setObject:branchInfo.brokerBranchData.symbolFormat1 -> symbol forKey:@"symbol"];
    [mainDict setObject:branchInfo.brokerBranchId forKey:@"brokerBranchID"];
    
    [self saveToFile];
    
    identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", branchInfo.brokerBranchData.symbolFormat1->IdentCode[0], branchInfo.brokerBranchData.symbolFormat1->IdentCode[1], branchInfo.brokerBranchData.symbolFormat1->symbol];
    [dataModel.securitySearchModel setTarget:self];
    [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModel.thread withObject:branchInfo.brokerBranchData.symbolFormat1->symbol waitUntilDone:NO];
    
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
        [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModel.thread withObject:fullName waitUntilDone:NO];
    }
}
- (void)saveToFile {
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:@"BranchInAndOutList.plist"];
    
    BOOL success = [mainDict writeToFile:path atomically:YES];
    if(!success) NSLog(@"BranchInAndOutList wirte error!!");

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

-(void)sendBranchStockToServerWithOptionType{
    [self findModelStartAndEndDay];
    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeCalendar) {
        
        BrokerBranchByBrokerOut *branchByBrokerPcket = [[BrokerBranchByBrokerOut alloc]initWithBrokerBranchId:[BrokersByModel sharedInstance].brokerBranchID days:0 startDate:sDate endDate:eDate sortType:sortType];
        [FSDataModelProc sendData:self WithPacket:branchByBrokerPcket];
        
    }else{
        if (dataModel.cyqModel.pickDays == 0) {
            dataModel.cyqModel.pickDays = 1;
        }
        BrokerBranchByBrokerOut *branchByBrokerPcket = [[BrokerBranchByBrokerOut alloc]initWithBrokerBranchId:[BrokersByModel sharedInstance].brokerBranchID days:dataModel.cyqModel.pickDays sortType:sortType];
        [FSDataModelProc sendData:self WithPacket:branchByBrokerPcket];
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
-(void)loadServerDate{
    
    FSBrokerBranchByBroker *branchInfo = [fromBrokerBranch firstObject];
    
    int dateValSt = branchInfo.startDate;
    int dateValEn = branchInfo.endDate;
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
-(void)changeDateBtnTitle:(NSTimer *)incomingTimer{
    
    FSBrokerBranchByBroker *branchInfo = [fromBrokerBranch firstObject];
    NSString *startDateStrTmp = [CodingUtil getStringDatePlusZero:branchInfo.startDate];
    NSString *endDateStrTmp = [CodingUtil getStringDatePlusZero:branchInfo.endDate];
    NSString *startDateStr = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *startDateStrForBtnTitle = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *endDateStr = [endDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([startDateStr isEqualToString:endDateStr]) {
        [dateBtn setTitle:[NSString stringWithFormat:@"%@", startDateStrForBtnTitle] forState:UIControlStateNormal];
    }else{
        [dateBtn setTitle:[NSString stringWithFormat:@"%@ - %@",startDateStr, endDateStr] forState:UIControlStateNormal];
        
    }
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}



@end
