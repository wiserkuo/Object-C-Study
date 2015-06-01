//
//  TodayReserveViewController.m
//  Bullseye
//
//  Created by Connor on 13/9/5.
//
//

#import "TodayReserveViewController.h"
#import "FSHUD.h"

#import "TodayReserveCell.h"
#import "FSTodayReserve2Cell.h"

#import "InvesterBSIn.h"
#import "MarginTradingIn.h"
#import "StockConstant.h"

#import "NewHistoricalPriceOut.h"
#import "EquityTick.h"

#import "CodingUtil.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface TodayReserveViewController () {
    NSMutableArray *layoutConstraints;
}
@property (strong, nonatomic) FSDataModelProc *dataModal;
@property (strong, nonatomic) UITableView *mainTableView;
@end

#define tableBackgroundColor [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1.0f]

@implementation TodayReserveViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    layoutConstraints = [[NSMutableArray alloc] init];
    
	_mainTableView = [[UITableView alloc] init];
    _mainTableView.separatorColor = tableBackgroundColor;
    
    _mainTableView.allowsSelection = NO;
    _mainTableView.bounces = NO;
    _mainTableView.directionalLockEnabled = NO;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_mainTableView];
    
    [self.view setNeedsUpdateConstraints];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self registerLoginNotificationCallBack:self seletor:@selector(sendPacket)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendPacket)];
    
    [self sendPacket];
    
//    [[FSHUD sharedFSHUD] showHUDin:self.view status:NSLocalizedStringFromTable(@"Downloading",@"Draw",nil) animated:YES];
}

-(void)sendPacket{
    _portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    _dataModal = [FSDataModelProc sharedInstance];
    [_dataModal.investerBS loadFromIdentSymbol:_portfolioItem.getIdentCodeSymbol];
    [_dataModal.investerBS setTargetNotify:self];
    [_dataModal.investerBS sendAndRead];
    
    [_dataModal.marginTrading loadFromIdentSymbol:_portfolioItem.getIdentCodeSymbol];
    [_dataModal.marginTrading setTargetNotify:self];
    [_dataModal.marginTrading sendAndRead];
    
    [_dataModal.todayReserve setTargetNotify:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_dataModal.investerBS setTargetNotify:nil];
    [_dataModal.marginTrading setTargetNotify:nil];
    [_dataModal.todayReserve setTargetNotify:nil];

    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    [super viewWillDisappear:animated];
}

-(void)updateViewConstraints {
    [super updateViewConstraints];

    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_mainTableView);
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:layoutConstraints];
    
}

- (void)notifyInvesterHoldData {
    [_mainTableView reloadData];
}

- (void)notifyInvesterBSData {
    [_mainTableView reloadData];
    [FSHUD hideHUDFor:self.view];
//    [[FSHUD sharedFSHUD] hideHUDFor:self.view animated:YES];
    [self notifyData];
}

- (void)notifyMarginTradingData {
    [_mainTableView reloadData];
}

- (void)notifyVolume {
    [_mainTableView reloadData];
}

- (void)notifyData {
    int lastRecordDate = [_dataModal.investerBS getLastIIGRecordDate];
    
    NSLog(@"%@", [[NSNumber numberWithInt:lastRecordDate] uint16ToDate]);
    NewHistoricalPriceOut *packet = [[NewHistoricalPriceOut alloc] initWithSecurityNumber:_portfolioItem->commodityNo dataType:'D' commodityType:_portfolioItem->type_id startDate:lastRecordDate endDate:lastRecordDate];
    [FSDataModelProc sendData:self WithPacket:packet];
    
	[_mainTableView reloadData];
    [FSHUD hideHUDFor:self.view];
//    [[FSHUD sharedFSHUD] hideHUDFor:self.view animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_portfolioItem->type_id == 6) {
        return 4;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_portfolioItem->type_id == 6) {
        switch (section) {
            case 0:
                return 0;
            case 1:
                return 5;
            case 2:
                return 1;
            case 3:
                return 1;
        }
        return 4;
    }else{
        switch (section) {
            case 0:
                return 4;
            case 1:
                return 4;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_portfolioItem->type_id == 6) {
        static NSString *CellIdentifier = @"FSTodayReserve2Cell";
        FSTodayReserve2Cell *cell = (FSTodayReserve2Cell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[FSTodayReserve2Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.field1.backgroundColor = tableBackgroundColor;
        cell.field1.textColor = [UIColor whiteColor];
        if (indexPath.section == 1) {
            InvesterBSData *BSData1;
            InvesterBSData *BSData2;
            InvesterBSData *BSData3;
            BOOL releaseFlag = NO;
            NSArray *tmpArray = [_dataModal.investerBS getDataForTodayUse];
            if (tmpArray) {
                BSData1 = [tmpArray objectAtIndex:0];
                BSData2 = [tmpArray objectAtIndex:1];
                BSData3 = [tmpArray objectAtIndex:2];
                releaseFlag = YES;
            }
            else return cell;
            if (indexPath.row == 0) {
                NSString *localString = NSLocalizedStringFromTable(@"外        資",@"CompanyProfile",@"外        資");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                if (BSData1->buySell < 0 ) {
                    cell.field2.textColor = [StockConstant PriceDownColor];
                } else if (BSData1->buySell > 0 ) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [UIColor blueColor];
                }
                cell.field2.text = [NSString stringWithFormat:@"%.2f", BSData1->buyShares * pow(1000, BSData1->sellSharesUnit) / pow(10, 8)];
                
                if (BSData1->buySell < 0 ) {
                    cell.field3.textColor = [StockConstant PriceDownColor];
                } else if (BSData1->buySell > 0 ) {
                    cell.field3.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field3.textColor = [UIColor blueColor];
                }
                cell.field3.text = [NSString stringWithFormat:@"%.2f", BSData1->sellShares * pow(1000, BSData1->sellSharesUnit) / pow(10, 8)];
                
                if (BSData1->buySell < 0 ) {
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if (BSData1->buySell > 0 ) {
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field4.textColor = [UIColor blueColor];
                }
                
                NSString *buysell = [NSString stringWithFormat:@"%.2f", BSData1->buySell * pow(1000, BSData1->buySellUnit) / pow(10, 8)];
                
                if (BSData1->buySell > 0) {
                    cell.field4.text = [NSString stringWithFormat:@"+%@", buysell];
                } else {
                    cell.field4.text = buysell;
                }
            }else if (indexPath.row == 1){
                NSString *localString = NSLocalizedStringFromTable(@"投        信",@"CompanyProfile",@"投        信");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                
                if(BSData2->buySell < 0 ) {
                    cell.field2.textColor = [StockConstant PriceDownColor];
                } else if(BSData2->buySell > 0 ) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [UIColor blueColor];
                }
                cell.field2.text = [NSString stringWithFormat:@"%.2f", BSData2->buyShares * pow(1000, BSData2->buySharesUnit) / pow(10, 8)];
                
                if(BSData2->buySell < 0 ) {
                    cell.field3.textColor = [StockConstant PriceDownColor];
                } else if(BSData2->buySell > 0 ) {
                    cell.field3.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field3.textColor = [UIColor blueColor];
                }
                cell.field3.text = [NSString stringWithFormat:@"%.2f", BSData2->sellShares * pow(1000, BSData2->sellSharesUnit) / pow(10, 8)];
                
                if(BSData2->buySell < 0 ) {
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if(BSData2->buySell > 0 ) {
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field4.textColor = [UIColor blueColor];
                }
                
                NSString *buysell = [NSString stringWithFormat:@"%.2f", BSData2->buySell * pow(1000, BSData2->buySellUnit) / pow(10, 8)];
                if (BSData2->buySell > 0) {
                    cell.field4.text = [NSString stringWithFormat:@"+%@", buysell];
                } else {
                    cell.field4.text = buysell;
                }
            }else if (indexPath.row == 2){
                NSString *localString = NSLocalizedStringFromTable(@"自  營  商",@"CompanyProfile",@"自 營 商");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                
                if (BSData3->buySell < 0 ) {
                    cell.field2.textColor = [StockConstant PriceDownColor];
                } else if(BSData3->buySell > 0 ) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [UIColor blueColor];
                }
                cell.field2.text = [NSString stringWithFormat:@"%.2f", BSData3->buyShares *pow(1000, BSData3->buySharesUnit) / pow(10, 8)];
                
                if (BSData3->buySell < 0 ) {
                    cell.field3.textColor = [StockConstant PriceDownColor];
                } else if(BSData3->buySell > 0 ) {
                    cell.field3.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field3.textColor = [UIColor blueColor];
                }
                cell.field3.text = [NSString stringWithFormat:@"%.2f", BSData3->sellShares * pow(1000, BSData3->sellSharesUnit) / pow(10, 8)];
                
                if (BSData3->buySell < 0 ) {
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if(BSData3->buySell > 0 ) {
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field4.textColor = [UIColor blueColor];
                }
                
                NSString *buysell = [NSString stringWithFormat:@"%.2f", BSData3->buySell * pow(1000, BSData3->buySellUnit) / pow(10, 8)];
                
                if (BSData3->buySell > 0) {
                    cell.field4.text = [NSString stringWithFormat:@"+%@", buysell];
                } else {
                    cell.field4.text = buysell;
                }
            }else if (indexPath.row == 3){
                NSString *localString = NSLocalizedStringFromTable(@"合        計",@"CompanyProfile",@"合        計");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                
                cell.field2.textColor = [StockConstant PriceDownColor];
                cell.field3.textColor = [StockConstant PriceDownColor];
                cell.field4.textColor = [StockConstant PriceDownColor];

                float sumBuyShares = (BSData1->buyShares * pow(1000, BSData1->buySharesUnit) / pow(10, 8)) + (BSData2->buyShares * pow(1000, BSData2->buySharesUnit) / pow(10, 8)) + (BSData3->buyShares * pow(1000, BSData3->buySharesUnit) / pow(10, 8));
                cell.field2.text = [NSString stringWithFormat:@"%.2f", sumBuyShares];
                float sumSellShares = (BSData1->sellShares * pow(1000, BSData1->sellSharesUnit) / pow(10, 8)) + (BSData2->sellShares * pow(1000, BSData2->sellSharesUnit) / pow(10, 8)) + (BSData3->sellShares * pow(1000, BSData3->sellSharesUnit) / pow(10, 8));
                cell.field3.text = [NSString stringWithFormat:@"%.2f", sumSellShares];
                float sumBuySell = (BSData1->buySell * pow(1000, BSData1->buySellUnit) / pow(10, 8)) + (BSData2->buySell * pow(1000, BSData2->buySellUnit) / pow(10, 8)) + (BSData3->buySell * pow(1000, BSData3->buySellUnit) / pow(10, 8));
                cell.field4.text = [NSString stringWithFormat:@"%.2f", sumBuySell];
            }else if (indexPath.row == 4){
                cell.field5.backgroundColor = tableBackgroundColor;
                cell.field5.textColor = [UIColor whiteColor];
                cell.field5.text = @"三大法人佔成交比重";
                
                cell.field6.textColor = [UIColor blueColor];
                cell.field6.text = [_dataModal.todayReserve getInvestorProportion];
            }
        }else if (indexPath.section == 2){
            MarginTradingParam *MTParam;
            NSArray *tmpArray = [_dataModal.marginTrading getRowDataWithIndex:0];
            if(tmpArray)
            {
                MTParam = [tmpArray objectAtIndex:0];
            }
            else return cell;
            if (indexPath.row == 0) {
                NSString *localString = NSLocalizedStringFromTable(@"融        資",@"CompanyProfile",@"融        資");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                
                
                if (MTParam->amountOffset < 0 ) {
                    cell.field7.textColor = [StockConstant PriceDownColor];
                    cell.field8.textColor = [StockConstant PriceDownColor];
                } else if (MTParam->amountOffset > 0 ) {
                    cell.field7.textColor = [StockConstant PriceUpColor];
                    cell.field8.textColor = [StockConstant PriceUpColor];
                }
                
                cell.field7.text = [NSString stringWithFormat:@"%.2f", MTParam->usedAmount * pow(1000, MTParam->usedAmountUnit) / pow(10, 4)];
                if (MTParam->amountOffset > 0) {
                    cell.field8.text = [NSString stringWithFormat:@"+%.2f", MTParam->amountOffset *pow(1000, MTParam->amountOffsetUnit) / pow(10, 4)];
                }else{
                    cell.field8.text = [NSString stringWithFormat:@"%.2f", MTParam->amountOffset *pow(1000, MTParam->amountOffsetUnit) / pow(10, 4)];
                }
            }
        }else if (indexPath.section == 3){
            MarginTradingParam *MTParam;
            NSArray *tmpArray = [_dataModal.marginTrading getRowDataWithIndex:0];
            if(tmpArray)
            {
                MTParam = [tmpArray objectAtIndex:0];
            }
            else return cell;
            if (indexPath.row == 0) {
                NSString *localString = NSLocalizedStringFromTable(@"融        券",@"CompanyProfile",@"融        券");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                
                if (MTParam->sharedOffset < 0 ) {
                    cell.field7.textColor = [StockConstant PriceDownColor];
                    cell.field8.textColor = [StockConstant PriceDownColor];
                } else if (MTParam->sharedOffset > 0 ) {
                    cell.field7.textColor = [StockConstant PriceUpColor];
                    cell.field8.textColor = [StockConstant PriceUpColor];
                }
                
                cell.field7.text = [CodingUtil getValueUnitString:MTParam->usedShare Unit:MTParam->usedShareUnit];
                if (MTParam->sharedOffset > 0) {
                    cell.field8.text = [NSString stringWithFormat:@"+%@", [CodingUtil getValueUnitString:MTParam->sharedOffset Unit:MTParam->sharedOffsetUnit]];
                }else{
                    cell.field8.text = [NSString stringWithFormat:@"%@", [CodingUtil getValueUnitString:MTParam->sharedOffset Unit:MTParam->sharedOffsetUnit]];
                }
            }
        }

        return cell;

    }else{
        static NSString *CellIdentifier = @"TodayReserveCell";
        TodayReserveCell *cell = (TodayReserveCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[TodayReserveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.field1.backgroundColor = tableBackgroundColor;
        cell.field1.textColor = [UIColor whiteColor];
        
        if (indexPath.section == 0) {
            
            InvesterBSData *BSData1;
            InvesterBSData *BSData2;
            InvesterBSData *BSData3;
            BOOL releaseFlag = NO;
            NSArray *tmpArray = [_dataModal.investerBS getDataForTodayUse];
            if (tmpArray) {
                BSData1 = [tmpArray objectAtIndex:0];
                BSData2 = [tmpArray objectAtIndex:1];
                BSData3 = [tmpArray objectAtIndex:2];
                releaseFlag = YES;
            }
            else return cell;
            
            if (indexPath.row == 0) {
                NSString *localString = NSLocalizedStringFromTable(@"外資法人",@"CompanyProfile",@"外資法人");
                cell.field1.text =[NSString stringWithFormat:@"%@\n%@",localString,[CodingUtil getStringDate2:BSData1->date]];
                
                if (BSData1->buyShares != 0) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [UIColor blueColor];
                }
                cell.field2.text = [CodingUtil getValueUnitString:BSData1->buyShares Unit:BSData1->buySharesUnit];
                
                if (BSData1->sellShares != 0) {
                    cell.field3.textColor = [StockConstant PriceDownColor];
                } else {
                    cell.field3.textColor = [UIColor blueColor];
                }
                cell.field3.text = [CodingUtil getValueUnitString:BSData1->sellShares Unit:BSData1->sellSharesUnit];
                
                
                if (BSData1->buySell < 0 ) {
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if (BSData1->buySell > 0 ) {
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field4.textColor = [UIColor blueColor];
                }
                
                NSString *buysell = [CodingUtil getValueUnitString:BSData1->buySell Unit:BSData1->buySellUnit];
                
                if (BSData1->buySell > 0) {
                    cell.field4.text = [NSString stringWithFormat:@"+%@", buysell];
                } else {
                    cell.field4.text = buysell;
                }
                
            } else if (indexPath.row == 1) {
                NSString *localString = NSLocalizedStringFromTable(@"自  營  商",@"CompanyProfile",@"自 營 商");
                cell.field1.text =[NSString stringWithFormat:@"%@\n%@",localString,[CodingUtil getStringDate2:BSData3->date]];
                cell.field1.textColor = [UIColor whiteColor];
                
                if (BSData3->buyShares != 0) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [UIColor blueColor];
                }
                cell.field2.text = [CodingUtil getValueUnitString:BSData3->buyShares Unit:BSData3->buySharesUnit];
                
                if (BSData3->sellShares != 0) {
                    cell.field3.textColor = [StockConstant PriceDownColor];
                } else {
                    cell.field3.textColor = [UIColor blueColor];
                }
                cell.field3.text = [CodingUtil getValueUnitString:BSData3->sellShares Unit:BSData3->sellSharesUnit];
                
                if (BSData3->buySell < 0 ) {
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if(BSData3->buySell > 0 ) {
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field4.textColor = [UIColor blueColor];
                }
                
                NSString *buysell = [CodingUtil getValueUnitString:BSData3->buySell Unit:BSData3->buySellUnit];
                
                if (BSData3->buySell > 0) {
                    cell.field4.text = [NSString stringWithFormat:@"+%@", buysell];
                } else {
                    cell.field4.text = buysell;
                }
            } else if (indexPath.row == 2) {
                NSString *localString = NSLocalizedStringFromTable(@"投        信",@"CompanyProfile",@"投        信");
                cell.field1.text =[NSString stringWithFormat:@"%@\n%@",localString,[CodingUtil getStringDate2:BSData2->date]];
                cell.field1.textColor = [UIColor whiteColor];
                
                if (BSData2->buyShares != 0) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [UIColor blueColor];
                }
                cell.field2.text = [CodingUtil getValueUnitString:BSData2->buyShares Unit:BSData2->buySharesUnit];
                
                
                if (BSData2->sellShares != 0) {
                    cell.field3.textColor = [StockConstant PriceDownColor];
                } else {
                    cell.field3.textColor = [UIColor blueColor];
                }
                cell.field3.text = [CodingUtil getValueUnitString:BSData2->sellShares Unit:BSData2->sellSharesUnit];
                
                if(BSData2->buySell < 0 ) {
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if(BSData2->buySell > 0 ) {
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field4.textColor = [UIColor blueColor];
                }
                
                NSString *buysell = [CodingUtil getValueUnitString:BSData2->buySell Unit:BSData2->buySellUnit];
                if (BSData2->buySell > 0) {
                    cell.field4.text = [NSString stringWithFormat:@"+%@", buysell];
                } else {
                    cell.field4.text = buysell;
                }
            } else if (indexPath.row == 3) {
                cell.field5.backgroundColor = tableBackgroundColor;
                cell.field5.textColor = [UIColor whiteColor];
                cell.field5.text = @"三大法人佔成交比重";
                
                cell.field6.textColor = [UIColor blueColor];
                cell.field6.text = [_dataModal.todayReserve getInvestorProportion];
            }
        } else if (indexPath.section == 1) {
            MarginTradingParam *MTParam;
            NSArray *tmpArray = [_dataModal.marginTrading getRowDataWithIndex:0];
            if(tmpArray)
            {
                MTParam = [tmpArray objectAtIndex:0];
            }
            else return cell;
            if(indexPath.row == 0)
            {
                NSString *localString = NSLocalizedStringFromTable(@"融        資",@"CompanyProfile",@"融        資");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                
                
                if (MTParam->amountOffset < 0 ) {
                    cell.field2.textColor = [StockConstant PriceDownColor];
                    cell.field3.textColor = [StockConstant PriceDownColor];
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if (MTParam->amountOffset > 0 ) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                    cell.field3.textColor = [StockConstant PriceUpColor];
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [StockConstant PriceEqualColor];
                    cell.field3.textColor = [StockConstant PriceEqualColor];
                    cell.field4.textColor = [StockConstant PriceEqualColor];
                }
                
                cell.field2.text = [CodingUtil getValueUnitString:MTParam->usedAmount Unit:MTParam->usedAmountUnit];
                if (MTParam->amountOffset > 0) {
                    cell.field3.text = [NSString stringWithFormat:@"+%@", [CodingUtil getValueUnitString:MTParam->amountOffset Unit:MTParam->amountOffsetUnit]];
                }else{
                    cell.field3.text = [NSString stringWithFormat:@"%@", [CodingUtil getValueUnitString:MTParam->amountOffset Unit:MTParam->amountOffsetUnit]];
                }
                
//                if(![[[NSNumber numberWithDouble:MTParam->amountRatio] stringValue] isEqualToString:@"0"] &&
//                   ![[[NSNumber numberWithDouble:MTParam->amountRatio] stringValue] isEqualToString:@"-0"])
                    cell.field4.text = [NSString stringWithFormat:@"%.02lf%%",MTParam->amountRatio*100];
            }
            else if(indexPath.row == 1)
            {
                NSString *localString = NSLocalizedStringFromTable(@"融        券",@"CompanyProfile",@"融        券");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                
                if (MTParam->sharedOffset < 0 ) {
                    cell.field2.textColor = [StockConstant PriceDownColor];
                    cell.field3.textColor = [StockConstant PriceDownColor];
                    cell.field4.textColor = [StockConstant PriceDownColor];
                } else if (MTParam->sharedOffset > 0 ) {
                    cell.field2.textColor = [StockConstant PriceUpColor];
                    cell.field3.textColor = [StockConstant PriceUpColor];
                    cell.field4.textColor = [StockConstant PriceUpColor];
                } else {
                    cell.field2.textColor = [StockConstant PriceEqualColor];
                    cell.field3.textColor = [StockConstant PriceEqualColor];
                    cell.field4.textColor = [StockConstant PriceEqualColor];
                }
                
                cell.field2.text = [CodingUtil getValueUnitString:MTParam->usedShare Unit:MTParam->usedShareUnit];
                if (MTParam->sharedOffset > 0) {
                    cell.field3.text = [NSString stringWithFormat:@"+%@", [CodingUtil getValueUnitString:MTParam->sharedOffset Unit:MTParam->sharedOffsetUnit]];
                }else{
                    cell.field3.text = [NSString stringWithFormat:@"%@", [CodingUtil getValueUnitString:MTParam->sharedOffset Unit:MTParam->sharedOffsetUnit]];
                }
//                if(![[[NSNumber numberWithDouble:MTParam->sharedRatio] stringValue] isEqualToString:@"0"] &&
//                   ![[[NSNumber numberWithDouble:MTParam->sharedRatio] stringValue] isEqualToString:@"-0"])
                    cell.field4.text = [NSString stringWithFormat:@"%.02lf%%",MTParam->sharedRatio*100];
            }
            else if(indexPath.row == 2)
            {
                NSString *localString = NSLocalizedStringFromTable(@"券  資  比",@"CompanyProfile",@"券  資  比");
                cell.field1.text =[NSString stringWithFormat:@"%@",localString];
                cell.field1.textColor = [UIColor whiteColor];
                cell.field2.textColor = [UIColor blueColor];
                if(MTParam->usedAmount)
                    cell.field2.text = [NSString stringWithFormat:@"%.2lf%%",((MTParam->usedShare*pow(1000,MTParam->usedShareUnit)) / (MTParam->usedAmount*pow(1000,MTParam->usedAmountUnit)))*100];
                cell.field3.text = nil;
                cell.field4.text = nil;
            }
            else if(indexPath.row == 3)
            {
                NSString *localString = NSLocalizedStringFromTable(@"當日沖銷",@"CompanyProfile",@"當日沖銷");
                cell.field1.text =[NSString stringWithFormat:@"%@\n%@",localString,[CodingUtil getStringDate2:MTParam->date]];
                cell.field1.textColor = [UIColor whiteColor];
                cell.field2.textColor = [UIColor blueColor];
                cell.field2.text = [CodingUtil getValueUnitString:MTParam->offset Unit:MTParam->offsetUnit];
                cell.field3.text = nil;
                cell.field4.text = nil;
            }
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_portfolioItem->type_id == 6) {
        NSString *localeString1 = NSLocalizedStringFromTable(@"買 進",@"CompanyProfile",@"買 進");
        NSString *localeString2 = NSLocalizedStringFromTable(@"賣 出",@"CompanyProfile",@"賣 出");
        NSString *localeString3 = NSLocalizedStringFromTable(@"買 賣 超",@"CompanyProfile",@"買 賣 超");
        NSString *localeString4 = NSLocalizedStringFromTable(@"融資餘額",@"CompanyProfile",@"融資餘額");
        NSString *localeString5 = NSLocalizedStringFromTable(@"增減(億)",@"CompanyProfile",@"增減(億)");
        NSString *localeString6 = NSLocalizedStringFromTable(@"市場整體庫存",@"CompanyProfile",@"市場整體庫存");
        NSString *localeString7 = NSLocalizedStringFromTable(@"融券餘額",@"CompanyProfile",@"融券餘額");
        NSString *localeString8 = NSLocalizedStringFromTable(@"增減(張)",@"CompanyProfile",@"增減(張)");


        static NSString *CellIdentifier = @"TodayReserveHeaderCell2";
        FSTodayReserve2Cell *headerView = [[FSTodayReserve2Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        headerView.field2.textColor = [UIColor whiteColor];
        headerView.field3.textColor = [UIColor whiteColor];
        headerView.field4.textColor = [UIColor whiteColor];
        headerView.field5.textColor = [UIColor whiteColor];
        headerView.field6.textColor = [UIColor whiteColor];
        headerView.field7.textColor = [UIColor whiteColor];
        headerView.field8.textColor = [UIColor whiteColor];

        headerView.backgroundColor = tableBackgroundColor;
        
        if (section == 0) {
            headerView.field5.text = localeString6;
            NSArray *allArray = [_dataModal.investerBS getRowDataWithIndex:(int)section];
            int date = [(NSNumber *)[allArray objectAtIndex:2] intValue];
            UInt16 year;
            UInt8 month,day;
            
            [CodingUtil getDate:date year:&year month:&month day:&day];

            headerView.field6.text = [NSString stringWithFormat:@"%02d/%@", year-1911, [CodingUtil getStringDate2:date]];
        }else if (section == 1){
            headerView.field2.text = localeString1;
            headerView.field3.text = localeString2;
            headerView.field4.text = localeString3;
        }else if (section == 2){
            headerView.field7.text = localeString4;
            headerView.field8.text = localeString5;
        }else if (section == 3){
            headerView.field7.text = localeString7;
            headerView.field8.text = localeString8;
        }
        
        return headerView;

    }else{
        NSString *localeString1 = NSLocalizedStringFromTable(@"買 張",@"CompanyProfile",@"買 張");
        NSString *localeString2 = NSLocalizedStringFromTable(@"賣 張",@"CompanyProfile",@"賣 張");
        NSString *localeString3 = NSLocalizedStringFromTable(@"買 賣 超",@"CompanyProfile",@"買 賣 超");
        NSString *localeString4 = NSLocalizedStringFromTable(@"餘 額",@"CompanyProfile",@"餘 額");
        NSString *localeString5 = NSLocalizedStringFromTable(@"增 減 張",@"CompanyProfile",@"增 減 張");
        NSString *localeString6 = NSLocalizedStringFromTable(@"比 率",@"CompanyProfile",@"比 率");
        
        static NSString *CellIdentifier = @"TodayReserveHeaderCell";
        
        TodayReserveCell *headerView = [[TodayReserveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        headerView.field2.textColor = [UIColor whiteColor];
        headerView.field3.textColor = [UIColor whiteColor];
        headerView.field4.textColor = [UIColor whiteColor];
        
        headerView.backgroundColor = tableBackgroundColor;
        
        if(section == 0) {
            headerView.field2.text = localeString1;
            headerView.field3.text = localeString2;
            headerView.field4.text = localeString3;
        }
        else if (section == 1) {
            headerView.field2.text = localeString4;
            headerView.field3.text = localeString5;
            headerView.field4.text = localeString6;
        }
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            return 33;
        } else {
            return 55;
        }
    } else {
        return 44;
    }
}
@end
