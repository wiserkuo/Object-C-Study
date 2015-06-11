//
//  FSBrokerInAndOutListViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerInAndOutListViewController.h"
#import "SKCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FSMainForceDateSelectViewController.h"
#import "FSBrokerChoiceCollectionViewController.h"
#import "FSBrokerInAndOutListModel.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSBranchInAndOutListViewController.h"
#import "FSBrokerOptionalListViewController.h"

@interface FSBrokerInAndOutListViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate>{
    
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
    NSMutableArray *fromNewBrokerArray;
    NSMutableArray *brokerInfoArray;
    FSBrokerByBrokerData *brokerData;
    PortfolioItem *item;
    NSString *identCodeSymbol;
    SymbolFormat1 *symbol1;
}

@end

@implementation FSBrokerInAndOutListViewController

-(UICollectionViewFlowLayout *)flowLayout{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    flowLayout.minimumLineSpacing = 20.0f;
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.itemSize = CGSizeMake(80.0f, 40.0f);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    
    return flowLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initVar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [BrokersByModel sharedInstance].brokerTrackingViewController = FSBrokerInAndOutView;

    [self loadDayType];
    [self.navigationController setNavigationBarHidden:NO];
    [titleBtn setTitle:@"券商進出表" forState:UIControlStateNormal];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [dataModel.brokers setTargetNotifyByNewBroker:nil];
    [dataModel.portfolioData setTarget:nil];

}

-(void)initView{

    [self setUpImageBackButton];
    dataModel = [FSDataModelProc sharedInstance];
    
//    reset BrokersByModel
    if (![BrokersByModel sharedInstance].brokerID) {
        [BrokersByModel sharedInstance].brokerID = 1020;
        [BrokersByModel sharedInstance].brokerName = @"合庫";
    }

    titleBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];

    [titleBtn setFrame:CGRectMake(0, 0, 150, 44)];
    [titleBtn addTarget:self action:@selector(changeTable) forControlEvents:UIControlEventTouchUpInside];
    btnContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 44)];
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
    [brokerBtn setTitle:[BrokersByModel sharedInstance].brokerName forState:UIControlStateNormal];
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
    
    overBoughtArray = [NSMutableArray arrayWithObjects:@"買超", @"買進", @"賣出", @"買均價", @"賣均價", nil];
    overSoldArray = [NSMutableArray arrayWithObjects:@"賣超", @"買進", @"賣出", @"買均價", @"賣均價", nil];
    rankBtnTitle = [NSMutableArray arrayWithObjects:@"買超", @"賣超", nil];
    titleBtnTitle = [NSMutableArray arrayWithObjects:@"券商分公司進出表", @"券商進出表", @"自選主力進出表", nil];
    
    changeTableViewTitle = [NSMutableArray arrayWithArray:overBoughtArray];
}

-(void)loadDayType{
    
    if (_dayType == 0) {
        [dateBtn setTitle:@"當日" forState:UIControlStateNormal];
        pickDay = 1;
    }else if (_dayType == 1){
        [dateBtn setTitle:@"5日累計" forState:UIControlStateNormal];
        pickDay = 2;
    }else if (_dayType == 2){
        [dateBtn setTitle:@"10日累計" forState:UIControlStateNormal];
        pickDay = 3;
    }else if (_dayType == 3){
        [dateBtn setTitle:@"20日累計" forState:UIControlStateNormal];
        pickDay = 4;
    }
    
    [brokerBtn setTitle:[BrokersByModel sharedInstance].brokerName forState:UIControlStateNormal];
    [dataModel.brokers setTargetNotifyByNewBroker:self];
    [dataModel.brokers sendByNewBrokerID:[BrokersByModel sharedInstance].brokerID WithDay:pickDay BrokersCount:1 SortType:sortType];
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
            FSBranchInAndOutListViewController *branchView = [FSBranchInAndOutListViewController new];
            [self.navigationController pushViewController:branchView animated:NO];
        }else if (buttonIndex == 1){
            return;
        }else{
            FSBrokerOptionalListViewController *OptionalView = [FSBrokerOptionalListViewController new];
            [self.navigationController pushViewController:OptionalView animated:NO];
        }
    }else if(mainActionSheet.tag == 1 && buttonIndex < [rankBtnTitle count]){
        [rankBtn setTitle:[rankBtnTitle objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        if (buttonIndex == 0) {
            changeTableViewTitle = [NSMutableArray arrayWithArray:overBoughtArray];
            sortType = 0;
        }else{
            changeTableViewTitle = [NSMutableArray arrayWithArray:overSoldArray];
            sortType = 1;
        }
        [self loadDayType];
    }else{
        return;
    }
}

-(void)pushToDatePick{
    
    FSMainForceDateSelectViewController *dateView = [FSMainForceDateSelectViewController new];
    dateView.dayType = _dayType;
    dateView.dataBroker = self;
    [self.navigationController pushViewController:dateView animated:NO];
}

-(void)notifyData{
    fromNewBrokerArray = [NSMutableArray arrayWithArray:[dataModel.brokers mainNewBrokerArray]];

    brokerInfoArray = [NSMutableArray new];

    for (int i = 0; i < [fromNewBrokerArray count]; i++) {
        brokerData = [[FSBrokerByBrokerData alloc] init];
        
        brokerData.buy = [(NSNumber *)[[fromNewBrokerArray objectAtIndex:i] objectForKey:@"BuyShare"] doubleValue];
        brokerData.sell = [(NSNumber *)[[fromNewBrokerArray objectAtIndex:i] objectForKey:@"SellShare"] doubleValue];
        brokerData.buyAvg = [(NSNumber *)[[fromNewBrokerArray objectAtIndex:i] objectForKey:@"BuyAmnt"] doubleValue];
        brokerData.sellAvg = [(NSNumber *)[[fromNewBrokerArray objectAtIndex:i] objectForKey:@"SellAmnt"] doubleValue];
        brokerData.overBought = [(NSNumber *)[[fromNewBrokerArray objectAtIndex:i] objectForKey:@"BuySellShare"] doubleValue];
        [brokerInfoArray addObject:brokerData];
    }
    
    [skMainTableView reloadDataNoOffset];
}

-(NSArray *)columnsInFixedTableView{
    
    return @[@"股名"];
}

-(NSArray *)columnsInMainTableView{
    
    return changeTableViewTitle;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [fromNewBrokerArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    
    symbol1 = [[fromNewBrokerArray objectAtIndex:indexPath.row] objectForKey:@"SymbolFormat1"];
    label.text = symbol1 -> fullName;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    brokerData = [brokerInfoArray objectAtIndex:indexPath.row];
    if (brokerData.overBought > 0) {
        label.textColor = [StockConstant PriceUpColor];
    }else if (brokerData.overBought < 0){
        label.textColor = [StockConstant PriceDownColor];
    }else{
        label.textColor = [UIColor blueColor];
    }
    if (columnIndex == 0) {
        if (brokerData.overBought > 0) {
            label.text = [NSString stringWithFormat:@"+%.f", brokerData.overBought];
        }else if (brokerData.overBought <= 0){
            label.text = [NSString stringWithFormat:@"%.f", brokerData.overBought];
        }else{
            label.text = @"----";
        }
    }
    if (columnIndex == 1) {
        label.text = [NSString stringWithFormat:@"%.f", brokerData.buy];
    }
    if (columnIndex == 2) {
        label.text = [NSString stringWithFormat:@"%.f", brokerData.sell];
    }
    if (columnIndex == 3) {
        if (isnan(brokerData.buyAvg/brokerData.buy)) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", floor(brokerData.buyAvg / brokerData.buy * 100) / 100];
        }
    }
    if (columnIndex == 4) {
        if (isnan(brokerData.sellAvg / brokerData.sell)) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", floor(brokerData.sellAvg / brokerData.sell * 100) / 100];
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    symbol1 = [[fromNewBrokerArray objectAtIndex:indexPath.row] objectForKey:@"SymbolFormat1"];
    
    NSMutableArray *newSymbolArray = [NSMutableArray new];
    NewSymbolObject *newSymbolObj = [NewSymbolObject new];
    newSymbolObj.identCode = [NSString stringWithFormat:@"%c%c", symbol1->IdentCode[0], symbol1->IdentCode[1]];
    newSymbolObj.symbol = symbol1->symbol;
    newSymbolObj.fullName = symbol1->fullName;
    newSymbolObj.typeId = symbol1->typeID;
    [newSymbolArray addObject:newSymbolObj];
    [BrokersByModel sharedInstance].brokerStockName = newSymbolObj.fullName;
//    [BrokersByModel sharedInstance].brokerAnchorName = newSymbolObj.fullName;
    identCodeSymbol = [NSString stringWithFormat:@"%@ %@", newSymbolObj.identCode, newSymbolObj.symbol];
    
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?",symbol1 -> symbol];
        while ([message next]) {
            [BrokersByModel sharedInstance].brokerName = [message stringForColumn:@"Name"];
            
        }
        [message close];
    }];
//    [dataModel.portfolioData removeWatchListItemByIdentSymbolArray];
    [dataModel.portfolioData setTarget:self];
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:newSymbolArray];
    
}
-(void)reloadData{
    
    item = [[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:identCodeSymbol];
    [dataModel.brokers sendByAnchor:item ->commodityNo BrokerID:[BrokersByModel sharedInstance].brokerID BrokersCount:30];
    FSMainForceAnchorViewController *anchorView = [FSMainForceAnchorViewController new];
    [self.navigationController pushViewController:anchorView animated:NO];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}



@end
