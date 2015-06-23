//
//  InstitutionalBSViewController.m
//  Bullseye
//
//  Created by Connor on 13/9/5.
//
//

#import "InstitutionalBSViewController.h"
#import "CYQModel.h"
#import "FSHUD.h"

#import "InvesterBS.h"
#import "InvesterBSIn.h"
#import "InvesterHoldIn.h"
#import "CodingUtil.h"
#import "StockConstant.h"

#import "SKDateUtils.h"
#import "UIView+NewComponent.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "DateRangeViewController.h"

@interface InstitutionalBSViewController () {
    NSMutableArray *layoutConstrants;
}

@property (strong, nonatomic) FSUIButton *categoryBtn;
@property (strong, nonatomic) FSUIButton *changeCustomDateBtn;
@property (strong, nonatomic) SKCustomTableView *mainTableView;
@property (strong, nonatomic) UILabel *unitLabel;

@property (strong, nonatomic) NSArray *categoryArray;
@property (strong, nonatomic) NSArray *columnNames1;
@property (strong, nonatomic) NSArray *columnNames2;
@property (strong, nonatomic) NSArray *columnNames3;

@property (weak, nonatomic) FSDataModelProc *dataModel;
@property (weak, nonatomic) PortfolioItem *portfolioItem;

@end

@implementation InstitutionalBSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    layoutConstrants = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _categoryBtn = [self.view newButton:FSUIButtonTypeBlueGreenDetailButton];
    [_categoryBtn setTitle:@"累計" forState:UIControlStateNormal];
    
    _changeCustomDateBtn = [self.view newButton:FSUIButtonTypeNormalRed];
    [_changeCustomDateBtn setTitle:@"設定日期" forState:UIControlStateNormal];
    
    _mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:55 mainColumnWidth:77 AndColumnHeight:44];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    
    [self.view addSubview:_mainTableView];
    
    _unitLabel = [[UILabel alloc] init];
    _unitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_unitLabel];
    
    [self varInit];
    [self actionInit];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerLoginNotificationCallBack:self seletor:@selector(sendPacket)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendPacket)];
    
    _dataModel = [FSDataModelProc sharedInstance];
    _portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    if (_portfolioItem->type_id == 6) {
        _unitLabel.text = @"單位: 億";
    }else{
        _unitLabel.text = @"單位: 張";
    }
    
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        [_categoryBtn setTitle:@"每日" forState:UIControlStateNormal];
        _changeCustomDateBtn.hidden = YES;
        [_mainTableView setFixedColumnSize:55 mainColumnWidth:77 AndColumnHeight:44];
    } else {
        [_categoryBtn setTitle:@"累計" forState:UIControlStateNormal];
        [_mainTableView setFixedColumnSize:100 mainColumnWidth:77 AndColumnHeight:63];
    }
    
//    [FSHUD showHUDin:self.view title:NSLocalizedStringFromTable(@"Downloading",@"Draw",nil)];
    [self sendPacket];

}
- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    
    [_dataModel.investerBS setTargetNotify:nil];
    
    [super viewWillDisappear:animated];
}

-(void)sendPacket{
    _dataModel = [FSDataModelProc sharedInstance];
    _portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    [_dataModel.investerBS loadFromIdentSymbol:_portfolioItem.getIdentCodeSymbol];
    [_dataModel.investerBS setTargetNotify:self];
    [_dataModel.investerBS sendAndRead];
}

#pragma mark -------------------- AutoLayout --------------------

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    [self.view removeConstraints:layoutConstrants];
    [layoutConstrants removeAllObjects];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_categoryBtn, _changeCustomDateBtn, _mainTableView, _unitLabel);
    
    [layoutConstrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_categoryBtn(70)][_changeCustomDateBtn(105)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [layoutConstrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_categoryBtn][_mainTableView][_unitLabel(30)]|" options:0 metrics:nil views:viewControllers]];
    
    [layoutConstrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [layoutConstrants addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_unitLabel]|" options:0 metrics:nil views:viewControllers]];

    
    [self.view addConstraints:layoutConstrants];
}

#pragma mark -------------------- 參數設定 --------------------

- (void)varInit {
    
    _categoryArray = [[NSArray alloc] initWithObjects:
                      @"每日",
                      @"累計",
                      nil];
    
    _columnNames1 = [[NSArray alloc] initWithObjects:
                     @"外資買賣",
                     @"投信買賣",
                     @"自營商",
                     @"三大合計",
                     @"外資持有",
                     @"比率",
                     nil];
    
    _columnNames2 = [[NSArray alloc] initWithObjects:
                     @"外資買賣",
                     @"自營商",
                     @"投信買賣",
                     @"三大合計",
                     nil];
    
    _columnNames3 = [[NSArray alloc] initWithObjects:
                     @"外資買賣",
                     @"投信買賣",
                     @"自營商",
                     @"三大合計",
                    nil];
}

#pragma mark -------------------- 資料回傳 --------------------

- (void)notifyInvesterHoldData {
    [_mainTableView reloadAllData];
    _dataModel.cyqModel.dateArray = [_dataModel.investerBS getAllDateArray];
//    [[FSHUD sharedFSHUD] hideHUDFor:self.view animated:YES];
    [FSHUD hideHUDFor:self.view];
}

- (void)notifyInvesterBSData {
    [_mainTableView reloadAllData];
    _dataModel.cyqModel.dateArray = [_dataModel.investerBS getAllDateArray];
//    [[FSHUD sharedFSHUD] hideHUDFor:self.view animated:YES];
    [FSHUD hideHUDFor:self.view];
}

#pragma mark -------------------- 按鈕事件 --------------------

- (void)actionInit {
    [_categoryBtn addTarget:self action:@selector(categoryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_changeCustomDateBtn addTarget:self action:@selector(changeCustomDateBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)categoryBtnClick{
     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇類型", @"Equity", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for (i = 0;i < [_categoryArray count]; i++) {
        NSString * title = [_categoryArray objectAtIndex:i];
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [actionSheet setCancelButtonIndex:i];
    [self showActionSheet:actionSheet];
}

-(void)changeCustomDateBtnClick{
    DateRangeViewController *viewController = [[DateRangeViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:NO];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        _changeCustomDateBtn.hidden = YES;
        _dataModel.cyqModel.currentSearchType = CYQSearchType_dailyMode;
        [_mainTableView setFixedColumnSize:77 mainColumnWidth:77 AndColumnHeight:44];
        [_categoryBtn setTitle:[_categoryArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }else if (buttonIndex == 1){
        _changeCustomDateBtn.hidden = NO;
        _dataModel.cyqModel.currentSearchType = CYQSearchType_accumulateMode;
        [_mainTableView setFixedColumnSize:100 mainColumnWidth:77 AndColumnHeight:63];
        [_categoryBtn setTitle:[_categoryArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
    
    [_mainTableView reloadAllData];
}

#pragma mark -------------------- Table title 欄位 --------------------

- (NSArray *)columnsInFixedTableView {
    return @[@"日期"];
}

- (NSArray *)columnsInMainTableView {
    
    NSArray *retArray = nil;
    
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        if (_portfolioItem->type_id == 6) {
            retArray = _columnNames3;
        }else{
            retArray = _columnNames1;
        }
    } else {    // CYQSearchType_accumulateMode
        retArray = _columnNames2;
    }
    
    return retArray;
}

#pragma mark -------------------- Table 資料欄位 --------------------

- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        
        label.textAlignment = NSTextAlignmentLeft;
        
        NSArray *allArray = [_dataModel.investerBS getRowDataWithIndex:(int)indexPath.row];
        int date = [(NSNumber *)[allArray objectAtIndex:2] intValue];
        
        UInt16 year;
        UInt8 month,day;
        
        [CodingUtil getDate:date year:&year month:&month day:&day];
        label.text = [NSString stringWithFormat:@"%02d/%02d", month, day];
        
    } else {    // CYQSearchType_accumulateMode
        
        UInt16 lastRecordDate = [_dataModel.investerBS getLastRecordDate];
        SKDateUtils *dateUtils = [[SKDateUtils alloc] initWithDateUInt16:lastRecordDate];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.textColor = [UIColor blueColor];
        
        NSDate *startDate, *endDate;
        
        if (columnIndex == 0) {
            label.textAlignment = NSTextAlignmentLeft;
            if (indexPath.row == 0) {
                NSString *dateString = [dateUtils getBeginningOfWeek:&startDate getEndingOfWeek:&endDate format:@"MM/dd"];
                label.text = [NSString stringWithFormat:@"本週\n%@", dateString];
            } else if (indexPath.row == 1) {
                NSString *dateString = [dateUtils getpreviousOfBeginningOfWeek:&startDate getEndingOfWeek:&endDate format:@"MM/dd"];
                label.text = [NSString stringWithFormat:@"前一週\n%@", dateString];
            } else if (indexPath.row == 2) {
                NSString *dateString = [dateUtils getpreviousOfBeginningOf2Week:&startDate getEndingOf2Week:&endDate format:@"MM/dd"];
                label.text = [NSString stringWithFormat:@"前兩週\n%@", dateString];
            } else if (indexPath.row == 3) {
                NSString *dateString = [dateUtils getBeginningOfMonth:&startDate getEndingOfMonth:&endDate format:@"MM/dd"];
                label.text = [NSString stringWithFormat:@"本月\n%@", dateString];
            } else if (indexPath.row == 4) {
                NSString *dateString = [dateUtils getpreviousBeginningOfMonth:&startDate getpreviousEndingOfMonth:&endDate format:@"MM/dd"];
                label.text = [NSString stringWithFormat:@"前一月\n%@", dateString];
                
            } else if (indexPath.row == 5) {
                
                if (_dataModel.cyqModel.accumulateOptionType == CYQAcuumulateOptionTypeCalendar) {
                    
                    if (_dataModel.cyqModel.startDate == nil || _dataModel.cyqModel.endDate == nil) {
                        if ([_dataModel.cyqModel.dateArray count] > 0) {
                            int dateVal = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
                            _dataModel.cyqModel.startDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
                            _dataModel.cyqModel.endDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
                        }
                    }
                    
                    startDate = _dataModel.cyqModel.startDate;
                    endDate = _dataModel.cyqModel.endDate;
                } else if (_dataModel.cyqModel.accumulateOptionType == CYQAcuumulateOptionTypeRecently) {
                    
                    int numDate = [(NSNumber *)[_dataModel.cyqModel.dateArray objectAtIndex:[_dataModel.cyqModel.dateArray count]-_dataModel.cyqModel.recentlyDay] intValue];
                    startDate = [[NSNumber numberWithInt:numDate] uint16ToDate];
                    
                    int numEndDate = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
                    endDate = [[NSNumber numberWithInt:numEndDate] uint16ToDate];
                }
                
                NSString *dateString = [dateUtils getCustomDate:startDate getEndingOfDay:endDate format:@"MM/dd"];
                label.text = [NSString stringWithFormat:@"自訂\n%@", dateString];
                label.lineBreakMode = NSLineBreakByCharWrapping;
                label.numberOfLines = 0;
            }
        }
    }
    
    label.textColor = [UIColor blueColor];
}

- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (columnIndex > 6) return;
    
    // default value
    label.textColor = [UIColor blackColor];
    label.text = @"----";
    
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        if (_portfolioItem->type_id == 6) {
            NSArray *allArray = [_dataModel.investerBS getRowDataWithIndex:(int)indexPath.row];
            NSDictionary *BSDict = [allArray objectAtIndex:0];
            
            UInt16 year;
            UInt8 month,day;
            
            InvesterBSData *bsData = [BSDict objectForKey:[NSString stringWithFormat:@"Data%d", (int)columnIndex+1]];
            
            if (bsData) {
                [CodingUtil getDate:bsData->date year:&year month:&month day:&day];
                
                if (columnIndex == 0 || columnIndex == 1 || columnIndex == 2) {
                    
                    if (bsData->buySell > 0) {
                        label.textColor = [StockConstant PriceUpColor];
                    } else if(bsData->buySell < 0) {
                        label.textColor = [StockConstant PriceDownColor];
                    }
                    
                    if (bsData->buySell > 0) {
                        label.text = [NSString stringWithFormat:@"+%.2f", floor(bsData->buySell * pow(1000, bsData->buySellUnit)/pow(10, 8) * 100) / 100];
                    } else {
                        label.text = [NSString stringWithFormat:@"%.2f", floor(bsData->buySell * pow(1000, bsData->buySellUnit)/pow(10, 8) * 100) / 100];
                    }
                }
            }
            
            
            if (columnIndex == 3) {
                double sum = 0;
                UInt8 sumUnit = 0;
                for(int i=1 ; i<4 ; i++) {
                    InvesterBSData *bsData = [BSDict objectForKey:[NSString stringWithFormat:@"Data%d",i]];
                    if(bsData) {
                        UInt16 year;
                        UInt8 month,day;
                        [CodingUtil getDate:bsData->date year:&year month:&month day:&day];
                        sum += bsData->buySell * pow(1000,bsData->buySellUnit);
                    }
                }
                
                if(sum > 1000000 || sum < -1000000) {
                    sum /= 1000000;
                    sumUnit = 2;
                }
                
                if (sum > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                } else if (sum < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                }
                
                if (sum > 0) {
                    label.text = [NSString stringWithFormat:@"+%.2f", floor(sum * pow(1000, sumUnit) / pow(10, 8) * 100) / 100];
                } else {
                    label.text = [NSString stringWithFormat:@"%.2f", floor(sum * pow(1000, sumUnit) / pow(10, 8) * 100) / 100];
                }
                
            }

        }else{
            NSArray *allArray = [_dataModel.investerBS getRowDataWithIndex:(int)indexPath.row];
            NSDictionary *BSDict = [allArray objectAtIndex:0];
            
            UInt16 year;
            UInt8 month,day;
            
            InvesterBSData *bsData = [BSDict objectForKey:[NSString stringWithFormat:@"Data%d", (int)columnIndex+1]];
            
            if (bsData) {
                [CodingUtil getDate:bsData->date year:&year month:&month day:&day];
                
                if (columnIndex == 0 || columnIndex == 1 || columnIndex == 2) {
                    
                    if (bsData->buySell > 0) {
                        label.textColor = [StockConstant PriceUpColor];
                    } else if(bsData->buySell < 0) {
                        label.textColor = [StockConstant PriceDownColor];
                    }
                    
                    if (bsData->buySell > 0) {
                        label.text = [@"+" stringByAppendingFormat:@"%@", [CodingUtil getValueUnitString:bsData->buySell Unit:bsData->buySellUnit]];
                    } else {
                        label.text = [CodingUtil getValueUnitString:bsData->buySell Unit:bsData->buySellUnit];
                    }
                }
            }
            
            
            if (columnIndex == 3) {
                double sum = 0;
                UInt8 sumUnit = 0;
                for(int i=1 ; i<4 ; i++) {
                    InvesterBSData *bsData = [BSDict objectForKey:[NSString stringWithFormat:@"Data%d",i]];
                    if(bsData) {
                        UInt16 year;
                        UInt8 month,day;
                        [CodingUtil getDate:bsData->date year:&year month:&month day:&day];
                        sum += bsData->buySell * pow(1000,bsData->buySellUnit);
                    }
                }
                
                if(sum > 1000000 || sum < -1000000) {
                    sum /= 1000000;
                    sumUnit = 2;
                }
                
                if (sum > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                } else if (sum < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                }
                
                if (sum > 0) {
                    label.text = [@"+" stringByAppendingFormat:@"%@", [CodingUtil getValueUnitString:sum Unit:sumUnit]];
                } else if (sum == 0){
                    label.text = @"----";
                } else{
                    label.text = [CodingUtil getValueUnitString:sum Unit:sumUnit];
                }
                
            }
            
            if (columnIndex == 4 || columnIndex == 5) {
                NSArray *allArray = [_dataModel.investerBS getRowDataWithIndex:(int)indexPath.row];
                NSDictionary *holdDict = [allArray objectAtIndex:1];
                
                double sum = 0;
                for(int i=1 ; i<4 ; i++) {
                    InvesterBSData *bsData = [BSDict objectForKey:[NSString stringWithFormat:@"Data%d",i]];
                    if(bsData) {
                        UInt16 year;
                        UInt8 month,day;
                        [CodingUtil getDate:bsData->date year:&year month:&month day:&day];
                        sum += bsData->buySell * pow(1000,bsData->buySellUnit);
                    }
                }
                
                if (sum > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                } else if (sum < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                }
                
                if (columnIndex == 4) {
                    if ([holdDict count] > 0) {
                        InvesterHoldData *holdData = [holdDict objectForKey:@"holdData"];
                        label.text = [CodingUtil getValueUnitString:holdData->ownShares Unit:holdData->ownSharesUnit]; //外資持有
                    }
                    
                } else if (columnIndex == 5) {
                    if ([holdDict count] > 0) {
                        InvesterHoldData *holdData = [holdDict objectForKey:@"holdData"];
                        label.text = [NSString stringWithFormat:@"%.1f%%",floor(holdData->ownRatio * 100 * 10) / 10]; //比率
                    }
                }
            }

        }
        
    } else {
        
        NSDate *startDate, *endDate;
        
        UInt16 lastRecordDate = [_dataModel.investerBS getLastRecordDate];
        SKDateUtils *dateUtils = [[SKDateUtils alloc] initWithDateUInt16:lastRecordDate];
        
        if (indexPath.row == 0) {
            [dateUtils getBeginningOfWeek:&startDate getEndingOfWeek:&endDate format:nil];
        } else if (indexPath.row == 1) {
            [dateUtils getpreviousOfBeginningOfWeek:&startDate getEndingOfWeek:&endDate format:nil];
        } else if (indexPath.row == 2) {
            [dateUtils getpreviousOfBeginningOf2Week:&startDate getEndingOf2Week:&endDate format:nil];
        } else if (indexPath.row == 3) {
            [dateUtils getBeginningOfMonth:&startDate getEndingOfMonth:&endDate format:nil];
        } else if (indexPath.row == 4) {
            [dateUtils getpreviousBeginningOfMonth:&startDate getpreviousEndingOfMonth:&endDate format:nil];
        } else if (indexPath.row == 5) {
            
            if (_dataModel.cyqModel.accumulateOptionType == CYQAcuumulateOptionTypeCalendar) {
                
                if (_dataModel.cyqModel.startDate == nil || _dataModel.cyqModel.endDate == nil) {
                    if ([_dataModel.cyqModel.dateArray count] > 0) {
                        int dateVal = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
                        _dataModel.cyqModel.startDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
                        _dataModel.cyqModel.endDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
                    }
                }
                
                startDate = _dataModel.cyqModel.startDate;
                endDate = _dataModel.cyqModel.endDate;
            } else if (_dataModel.cyqModel.accumulateOptionType == CYQAcuumulateOptionTypeRecently) {
                
                int numDate = [(NSNumber *)[_dataModel.cyqModel.dateArray objectAtIndex:[_dataModel.cyqModel.dateArray count]-_dataModel.cyqModel.recentlyDay] intValue];
                startDate = [[NSNumber numberWithInt:numDate] uint16ToDate];
                
                int numEndDate = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
                endDate = [[NSNumber numberWithInt:numEndDate] uint16ToDate];
            }
        }
        
        //指數
        if (_portfolioItem->type_id == 6) {

            if (columnIndex == 0) {
                double field1 = [_dataModel.investerBS getIndexIIG1StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                if (field1 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%.2f", field1];
                } else if (field1 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field1];
                } else if (field1 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field1];
                }
            }else if (columnIndex == 1){
                double field2 = [_dataModel.investerBS getIndexIIG3StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                if (field2 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%.2f", field2];
                } else if (field2 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field2];
                } else if (field2 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field2];
                }
            }else if (columnIndex == 2){
                double field3 = [_dataModel.investerBS getIndexIIG2StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                
                if (field3 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%.2f", field3];
                } else if (field3 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field3];
                } else if (field3 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field3];
                }
            }else if (columnIndex == 3){
                double field1 = [_dataModel.investerBS getIndexIIG1StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                double field2 = [_dataModel.investerBS getIndexIIG2StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                double field3 = [_dataModel.investerBS getIndexIIG3StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                double field4 = field1 + field2 + field3;
                
                if (field4 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%.2f", floor(field4 * 100) / 100];
                } else if (field4 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field4];
                } else if (field4 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%.2f", field4];
                }
            }
        }else{
            if (columnIndex == 0) {
                NSInteger field1 = [_dataModel.investerBS getIIG1StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                
                if (field1 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%d", (int)field1];
                } else if (field1 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field1];
                } else if (field1 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field1];
                }
                
            } else if (columnIndex == 1) {
                NSInteger field2 = [_dataModel.investerBS getIIG3StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                
                if (field2 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%d", (int)field2];
                } else if (field2 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field2];
                } else if (field2 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field2];
                }
                
            } else if (columnIndex == 2) {
                NSInteger field3 = [_dataModel.investerBS getIIG2StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                
                if (field3 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%d", (int)field3];
                } else if (field3 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field3];
                } else if (field3 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field3];
                }
                
            } else if (columnIndex == 3) {
                NSInteger field1 = [_dataModel.investerBS getIIG1StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                NSInteger field2 = [_dataModel.investerBS getIIG2StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                NSInteger field3 = [_dataModel.investerBS getIIG3StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
                NSInteger field4 = field1 + field2 + field3;
                
                if (field4 > 0) {
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [NSString stringWithFormat:@"+%d", (int)field4];
                } else if (field4 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field4];
                } else if (field4 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%d", (int)field4];
                }
            }
        }
    }
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        return [_dataModel.investerBS getRowCount];
    } else {    // CYQSearchType_accumulateMode
        return 6;
    }
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        return 44;
    } else {    // CYQSearchType_accumulateMode
        return 63;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

@end
