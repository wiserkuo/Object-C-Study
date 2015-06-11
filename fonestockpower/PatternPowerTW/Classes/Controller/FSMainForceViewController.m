//
//  FSMainForceViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/8/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainForceViewController.h"
#import "UIView+NewComponent.h"
#import "SKCustomTableView.h"
#import "FSMainForceDateSelectViewController.h"
#import "BrokersByOut.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FMDB.h"
#import "NSNumber+Extensions.h"
#import "FSMainForceAnchorViewController.h"

@interface FSMainForceViewController () <UIActionSheetDelegate, SKCustomTableViewDelegate>{
    FSUIButton *mainForceButton;
    FSUIButton *dateButton;
    FSUIButton *netBuySellButton;
    
    UIActionSheet *actionSheet;
    
    NSDate *date;
    
    NSMutableArray *dataArray;
    NSMutableArray *mainForceArray;
    FSMainForceData *mainForce;
    PortfolioItem *item;
    FSDataModelProc *dataModel;
    int overboughtSold;
    int dateNum;
}
@property (strong, nonatomic) SKCustomTableView *mainForceTableView;

@end

@implementation FSMainForceViewController
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    [self addMainForceTableView];
    [self constructUIComponents];
//    [self processLayout];
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self registerLoginNotificationCallBack:self seletor:@selector(loadData)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(loadData)];
    [self loadData];
}

-(void)loadData{
    if (_dayType == 0) {
        [dateButton setTitle:@"當日" forState:UIControlStateNormal];
    }else if (_dayType == 1){
        [dateButton setTitle:@"5日累計" forState:UIControlStateNormal];
    }else if (_dayType == 2){
        [dateButton setTitle:@"10日累計" forState:UIControlStateNormal];
    }else if (_dayType == 3){
        [dateButton setTitle:@"20日累計" forState:UIControlStateNormal];
    }
    
    dataModel = [FSDataModelProc sharedInstance];
    item = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    [dataModel.brokers setTargetNotifyByStock:self];
    [dataModel.brokers sendByStockID:item->commodityNo WithDay:_dayType + 1 BrokersCount:1 SortType:overboughtSold];
}

- (void)viewWillDisappear:(BOOL)animated {
    dataModel = [FSDataModelProc sharedInstance];
    [dataModel.brokers setTargetNotifyByStock:nil];
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    [super viewWillDisappear:animated];
}

-(void)notifyData{
    dataModel = [FSDataModelProc sharedInstance];
    if ([dataModel.brokers recordDate] != 0) {
        date = [[NSNumber numberWithInt:[dataModel.brokers recordDate]] uint16ToDate];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr  = [dateFormatter stringFromDate:date];
        if (_dayType == 0) {
            [dateButton setTitle:dateStr forState:UIControlStateNormal];
        }
    }

    [self loadMainForceData];
}

-(void)loadMainForceData{
    dataArray = [[NSMutableArray alloc] init];
    mainForceArray = [[NSMutableArray alloc] init];
    
    dataModel = [FSDataModelProc sharedInstance];
    dataArray = [dataModel.brokers mainStockArray];
    
    for (int i = 0; i < [dataArray count]; i++) {
        mainForce = [[FSMainForceData alloc] init];
        dataModel = [FSDataModelProc sharedInstance];
        FSDatabaseAgent *dbAgent = dataModel.mainDB;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
            
            FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?",[[dataArray objectAtIndex:i] objectForKey:@"BrokerID"]];
            while ([message next]) {
                mainForce.name = [message stringForColumn:@"Name"];
            }
        }];
        mainForce.buy = [(NSNumber *)[[dataArray objectAtIndex:i] objectForKey:@"BuyShare"] doubleValue];
        mainForce.sell = [(NSNumber *)[[dataArray objectAtIndex:i] objectForKey:@"SellShare"] doubleValue];
        mainForce.buyAvg = [(NSNumber *)[[dataArray objectAtIndex:i] objectForKey:@"BuyAmnt"] doubleValue];
        mainForce.sellAvg = [(NSNumber *)[[dataArray objectAtIndex:i] objectForKey:@"SellAmnt"] doubleValue];
        mainForce.overBought = [(NSNumber *)[[dataArray objectAtIndex:i] objectForKey:@"BuySellShare"] doubleValue];
        [mainForceArray addObject:mainForce];
    }
    
    [_mainForceTableView reloadAllData];
}

-(void)backBtnClick{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addMainForceTableView{
    _mainForceTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:85 AndColumnHeight:44];
    _mainForceTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainForceTableView.delegate = self;
    _mainForceTableView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_mainForceTableView];
}

- (void)constructUIComponents {
    dateButton = [self.view newButton:FSUIButtonTypeNormalRed];
    if (dateNum == 0) {
        [dateButton setTitle:NSLocalizedStringFromTable(@"當日", @"", @"") forState:UIControlStateNormal];
    }else if (dateNum == 1){
        [dateButton setTitle:NSLocalizedStringFromTable(@"5日", @"", @"") forState:UIControlStateNormal];
    }else if (dateNum == 2){
        [dateButton setTitle:NSLocalizedStringFromTable(@"10日", @"", @"") forState:UIControlStateNormal];
    }else if (dateNum == 3){
        [dateButton setTitle:NSLocalizedStringFromTable(@"20日", @"", @"") forState:UIControlStateNormal];
    }
    dateButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [dateButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    netBuySellButton = [self.view newButton:FSUIButtonTypeBlueGreenDetailButton];
    [netBuySellButton setTitle:NSLocalizedStringFromTable(@"買超", @"", @"") forState:UIControlStateNormal];
    netBuySellButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [netBuySellButton addTarget:self action:@selector(clickMenu:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(dateButton, netBuySellButton, _mainForceTableView);
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dateButton(210)][netBuySellButton]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainForceTableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dateButton][_mainForceTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}

- (void)clickMenu:(UIButton *)button {
    if ([button isEqual:dateButton]){
        FSMainForceDateSelectViewController *viewController = [[FSMainForceDateSelectViewController alloc] init];
        viewController.dayType = _dayType;
        viewController.data = self;

        [self.navigationController pushViewController:viewController animated:NO];
        viewController.dateNum = dateNum;
    }else if ([button isEqual:netBuySellButton]){
        actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇類型", @"", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"買超", @"", @""), NSLocalizedStringFromTable(@"賣超", @"", @""), nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [netBuySellButton setTitle:NSLocalizedStringFromTable(@"買超", @"", @"") forState:UIControlStateNormal];
        overboughtSold = 0;
        [self loadData];
    }else if (buttonIndex == 1){
        [netBuySellButton setTitle:NSLocalizedStringFromTable(@"賣超", @"", @"") forState:UIControlStateNormal];
        overboughtSold = 1;
        [self loadData];
    }
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    mainForce = [mainForceArray objectAtIndex:indexPath.row];
    label.text = mainForce.name;
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    mainForce = [mainForceArray objectAtIndex:indexPath.row];
    if (mainForce.overBought > 0) {
        label.textColor = [StockConstant PriceUpColor];
    }else if (mainForce.overBought < 0){
        label.textColor = [StockConstant PriceDownColor];
    }else{
        label.textColor = [UIColor blueColor];
    }
    if (columnIndex == 0) {
        if (mainForce.overBought > 0) {
            label.text = [NSString stringWithFormat:@"+%.f", mainForce.overBought];
        }else if (mainForce.overBought <= 0){
            label.text = [NSString stringWithFormat:@"%.f", mainForce.overBought];
        }else{
            label.text = @"----";
        }
    }
    if (columnIndex == 1) {
        label.text = [NSString stringWithFormat:@"%.f", mainForce.buy];
    }
    if (columnIndex == 2) {
        label.text = [NSString stringWithFormat:@"%.f", mainForce.sell];
    }
    if (columnIndex == 3) {
        if (isnan(mainForce.buyAvg/mainForce.buy)) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", floor(mainForce.buyAvg / mainForce.buy * 100) / 100];
        }
    }
    if (columnIndex == 4) {
        if (isnan(mainForce.sellAvg / mainForce.sell)) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", floor(mainForce.sellAvg / mainForce.sell * 100) / 100];
        }
    }
}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"券商", @"", @"")];
}

-(NSArray *)columnsInMainTableView{
    if (overboughtSold == 0) {
        return @[NSLocalizedStringFromTable(@"買超", @"", @""), NSLocalizedStringFromTable(@"買進", @"", @""), NSLocalizedStringFromTable(@"賣出", @"", @""), NSLocalizedStringFromTable(@"買均價", @"", @""), NSLocalizedStringFromTable(@"賣均價", @"", @""),];
    }else{
        return @[NSLocalizedStringFromTable(@"賣超", @"", @""), NSLocalizedStringFromTable(@"買進", @"", @""), NSLocalizedStringFromTable(@"賣出", @"", @""), NSLocalizedStringFromTable(@"買均價", @"", @""), NSLocalizedStringFromTable(@"賣均價", @"", @""),];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mainForceArray count];
}

//Michael
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [BrokersByModel sharedInstance].brokerStockName = item->fullName;
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?",[[dataArray objectAtIndex:indexPath.row] objectForKey:@"BrokerID"]];
        while ([message next]) {
            [BrokersByModel sharedInstance].brokerName = [message stringForColumn:@"Name"];
            
        }
        [message close];
    }];
    FSMainForceAnchorViewController *anchorView = [[FSMainForceAnchorViewController alloc]init];
    [dataModel.brokers sendByAnchor:item -> commodityNo BrokerID:[(NSNumber *)[[dataArray objectAtIndex:indexPath.row] objectForKey:@"BrokerID"] doubleValue] BrokersCount:30];
    [self.navigationController pushViewController:anchorView animated:NO];
}

@end

@implementation FSMainForceData

@end
