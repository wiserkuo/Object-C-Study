//
//  MarginTradingController2.m
//  Bullseye
//
//  Created by Connor on 13/9/4.
//
//

#import "MarginTradingViewController.h"
#import "UIView+NewComponent.h"
#import "CYQModel.h"
#import "FSHUD.h"

#import "MarginTradingIn.h"

#import "CodingUtil.h"
#import "StockConstant.h"

#import "SKDateUtils.h"

#import "DateRangeViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
@interface MarginTradingViewController () {
    NSMutableArray *layoutContraints;
}

@property (strong, nonatomic) FSUIButton *categoryBtn;
@property (strong, nonatomic) FSUIButton *changeCustomDateBtn;
@property (strong, nonatomic) SKCustomTableView *mainTableView;
@property (strong, nonatomic) UILabel *unitLabel;

@property (strong, nonatomic) NSArray *categoryArray;
@property (strong, nonatomic) NSArray *columnNames1;
@property (strong, nonatomic) NSArray *columnNames2;
@property (strong, nonatomic) NSArray *columnNames3;
@property (strong, nonatomic) NSArray *columnNames4;

@property (weak, nonatomic) FSDataModelProc *dataModel;

@end

@implementation MarginTradingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    layoutContraints = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];

    _categoryBtn = [self.view newButton:FSUIButtonTypeBlueGreenDetailButton];
    [self.view addSubview:_categoryBtn];
    
    _changeCustomDateBtn = [self.view newButton:FSUIButtonTypeNormalRed];
    [_changeCustomDateBtn setTitle:@"設定日期" forState:UIControlStateNormal];
    [self.view addSubview:_changeCustomDateBtn];
    
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
        _unitLabel.text = @"融資單位: 億 融券單位: 張";
    }else{
        _unitLabel.text = NSLocalizedStringFromTable(@"單位: 張", @"", nil);
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
    
    [_dataModel.marginTrading setTargetNotify:nil];
    
    [super viewWillDisappear:animated];
}

-(void)sendPacket{
    _dataModel = [FSDataModelProc sharedInstance];
    _portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    [_dataModel.marginTrading loadFromIdentSymbol:_portfolioItem.getIdentCodeSymbol];
    [_dataModel.marginTrading setTargetNotify:self];
    [_dataModel.marginTrading sendAndRead];
}

#pragma mark -------------------- AutoLayout --------------------

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    
    [layoutContraints removeAllObjects];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_categoryBtn, _changeCustomDateBtn, _mainTableView, _unitLabel);
    
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_categoryBtn(70)][_changeCustomDateBtn(105)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_categoryBtn][_mainTableView][_unitLabel(30)]|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_unitLabel]" options:0 metrics:nil views:viewControllers]];

    [self.view addConstraints:layoutContraints];
}

#pragma mark -------------------- 參數設定 --------------------

- (void)varInit {
    
    _categoryArray = [[NSArray alloc] initWithObjects:
                      @"每日",
                      @"累計",
                      nil];
    
    _columnNames1 = [[NSArray alloc] initWithObjects:
                              @"融資餘額",
                              @"融資增減",
                              @"使用率",
                              @"融券餘額",
                              @"融券增減",
                              @"使用率",
                              @"當沖量",
                              @"券資比",
                              nil];
    
    _columnNames2 = [[NSArray alloc] initWithObjects:
                              @"融資增減",
                              @"增減比例",
                              @"融券增減",
                              @"增減比例",
                              @"當沖量",
                              nil];
    
    _columnNames3 = [[NSArray alloc] initWithObjects:
                     @"融資餘額",
                     @"融資增減",
                     @"融券餘額",
                     @"融券增減",
                     nil];
    _columnNames4 = [[NSArray alloc] initWithObjects:
                     @"融資增減",
                     @"增減比例",
                     @"融券增減",
                     @"增減比例",
                     nil];
}

#pragma mark -------------------- 資料回傳 --------------------

- (void)notifyMarginTradingData {
    [_mainTableView reloadAllData];
    _dataModel.cyqModel.dateArray = [_dataModel.marginTrading getAllDateArray];
    [FSHUD hideHUDFor:self.view];
//    [[FSHUD sharedFSHUD] hideHUDFor:self.view animated:YES];
}


#pragma mark -------------------- 按鈕事件 --------------------

- (void)actionInit {
    [_categoryBtn addTarget:self action:@selector(categoryBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    __weak __typeof(self) weakSelf = self;
//    [_categoryBtn removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
//    [_categoryBtn addEventHandler:^(UIButton *sender) {
//        
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"選擇資料期間" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//        
//        __strong __typeof(self) strongSelf = weakSelf;
//        
//        int i = 0;
//        for (NSString *title in strongSelf.categoryArray) {
//            [actionSheet addButtonWithTitle:title handler:^{
//                
//                if (i == 0) {   // 每日
//                    strongSelf.changeCustomDateBtn.hidden = YES;
//                    strongSelf.dataModel.cyqModel.currentSearchType = CYQSearchType_dailyMode;
//                    [strongSelf.mainTableView setFixedColumnSize:77 mainColumnWidth:77 AndColumnHeight:44];
//                    
//                } else if (i == 1) {    // 累計
//                    strongSelf.changeCustomDateBtn.hidden = NO;
//                    strongSelf.dataModel.cyqModel.currentSearchType = CYQSearchType_accumulateMode;
//                    [strongSelf.mainTableView setFixedColumnSize:100 mainColumnWidth:77 AndColumnHeight:63];
//                }
//                
//                [strongSelf.mainTableView reloadAllData];
//                
//                [sender setTitle:title forState:UIControlStateNormal];
//            }];
//            i++;
//        }
//        
//        [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
//        
//    } forControlEvents:UIControlEventTouchUpInside];
    
    [_changeCustomDateBtn addTarget:self action:@selector(changeCustomDateBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [_changeCustomDateBtn removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
//    [_changeCustomDateBtn addEventHandler:^(UIButton *sender) {
//        __strong __typeof(self) strongSelf = weakSelf;
//        
//        DateRangeViewController *dateRangeViewController = [[DateRangeViewController alloc] init];
//        [strongSelf presentViewController:dateRangeViewController animated:YES completion:^{
//            // do not something.
//        }];
//    } forControlEvents:UIControlEventTouchUpInside];
}

-(void)categoryBtnClick{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"選擇資料期間" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for (i = 0; i < [_categoryArray count]; i++) {
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
        if (_portfolioItem->type_id == 6) {
            retArray = _columnNames4;
        }else{
            retArray = _columnNames2;
        }
    }
    
    return retArray;
}

#pragma mark -------------------- Table 資料欄位 --------------------

- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        
        label.textAlignment = NSTextAlignmentLeft;
        
        NSArray *allArray = [_dataModel.marginTrading getRowDataWithIndex:(int)indexPath.row];
        MarginTradingParam *mtParam = [allArray objectAtIndex:0];
        
        UInt16 year;
        UInt8 month,day;
        
        [CodingUtil getDate:mtParam->date year:&year month:&month day:&day];

        label.text = [NSString stringWithFormat:@"%02d/%02d", month, day];
        
    } else {    // CYQSearchType_accumulateMode
        
        UInt16 lastRecordDate = [_dataModel.marginTrading getLastRecordDate];
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
    
    if (columnIndex > 7) return;
    
    // default value
    label.textColor = [UIColor blackColor];
    label.text = @"----";
    
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        if (_portfolioItem->type_id == 6) {
            NSArray *allArray = [_dataModel.marginTrading getRowDataWithIndex:(int)indexPath.row];
            MarginTradingParam *mtParam = [allArray objectAtIndex:0];
            
            UInt16 year;
            UInt8 month,day;
            if (mtParam) {
                [CodingUtil getDate:mtParam->date year:&year month:&month day:&day];
                
                if (columnIndex == 0 || columnIndex == 1) {
                    
                    if (mtParam->amountOffset > 0) {
                        label.textColor = [StockConstant PriceUpColor];
                    } else if (mtParam->amountOffset < 0) {
                        label.textColor = [StockConstant PriceDownColor];
                    } else if (mtParam->amountOffset == 0) {
                        label.textColor = [UIColor blueColor];
                    }
                    
                    if (columnIndex == 0) {
                        label.text = [NSString stringWithFormat:@"%.2f", floor(mtParam->usedAmount * pow(10, 4) / pow(10, 8) * 100) / 100];
                    } else if (columnIndex == 1) {
                        if (mtParam->amountOffset > 0) {
                            label.text = [NSString stringWithFormat:@"+%.2f", floor(mtParam->amountOffset / pow(10, 4) * 100) / 100];
                        }else{
                            label.text = [NSString stringWithFormat:@"-%.2f", floor(abs(mtParam->amountOffset) / 100) / 100];
                        }
                    }
                }
                
                if (columnIndex == 2 || columnIndex == 3) {
                    
                    if (mtParam->sharedOffset > 0) {
                        label.textColor = [StockConstant PriceUpColor];
                    } else if (mtParam->sharedOffset < 0) {
                        label.textColor = [StockConstant PriceDownColor];
                    } else if (mtParam->sharedOffset == 0) {
                        label.textColor = [UIColor blueColor];
                    }
                    
                    if (columnIndex == 2) {
                        label.text = [CodingUtil getValueUnitString:mtParam->usedShare Unit:mtParam->usedShareUnit];
                    } else if (columnIndex == 3) {
                        if (mtParam->sharedOffset > 0) {
                            label.text = [@"+" stringByAppendingString:[CodingUtil getValueUnitString:mtParam->sharedOffset Unit:mtParam->sharedOffsetUnit]];
                        } else {
                            label.text = [CodingUtil getValueUnitString:mtParam->sharedOffset Unit:mtParam->sharedOffsetUnit];
                        }
                    }
                }
            }

        }else{
            NSArray *allArray = [_dataModel.marginTrading getRowDataWithIndex:(int)indexPath.row];
            MarginTradingParam *mtParam = [allArray objectAtIndex:0];
            
            UInt16 year;
            UInt8 month,day;
            
            if (mtParam) {
                [CodingUtil getDate:mtParam->date year:&year month:&month day:&day];
                
                if (columnIndex == 0 || columnIndex == 1 || columnIndex == 2) {
                    
                    if (mtParam->amountOffset > 0) {
                        label.textColor = [StockConstant PriceUpColor];
                    } else if (mtParam->amountOffset < 0) {
                        label.textColor = [StockConstant PriceDownColor];
                    } else if (mtParam->amountOffset == 0) {
                        label.textColor = [UIColor blueColor];
                    }
                    
                    if (columnIndex == 0) {
                        label.text = [CodingUtil getValueUnitString:mtParam->usedAmount Unit:mtParam->usedAmountUnit];
                    } else if (columnIndex == 1) {
                        if (mtParam->amountOffset > 0) {
                            label.text = [@"+" stringByAppendingString:[CodingUtil getValueUnitString:mtParam->amountOffset Unit:mtParam->amountOffsetUnit]];
                        } else {
                            label.text = [CodingUtil getValueUnitString:mtParam->amountOffset Unit:mtParam->amountOffsetUnit];
                        }

                    } else if (columnIndex == 2) {
                        if([[[NSNumber numberWithDouble:mtParam->amountRatio] stringValue] isEqualToString:@"0"] ){
                            label.text = @"0.00%";
                        }else if (![[[NSNumber numberWithDouble:mtParam->amountRatio] stringValue] isEqualToString:@"-0"]) {
                            label.text = [NSString stringWithFormat:@"%.2lf%%",mtParam->amountRatio*100];
                        }
                    }
                }
                
                if (columnIndex == 3 || columnIndex == 4 || columnIndex == 5) {
                    
                    if (mtParam->sharedOffset > 0) {
                        label.textColor = [StockConstant PriceUpColor];
                    } else if (mtParam->sharedOffset < 0) {
                        label.textColor = [StockConstant PriceDownColor];
                    } else if (mtParam->sharedOffset == 0) {
                        label.textColor = [UIColor blueColor];
                    }
                    
                    if (columnIndex == 3) {
                        label.text = [CodingUtil getValueUnitString:mtParam->usedShare Unit:mtParam->usedShareUnit];
                    } else if (columnIndex == 4) {
                        if (mtParam->sharedOffset > 0) {
                            label.text = [@"+" stringByAppendingString:[CodingUtil getValueUnitString:mtParam->sharedOffset Unit:mtParam->sharedOffsetUnit]];
                        } else {
                            label.text = [CodingUtil getValueUnitString:mtParam->sharedOffset Unit:mtParam->sharedOffsetUnit];
                        }
                        
                    } else if (columnIndex == 5) {
                        if([[[NSNumber numberWithDouble:mtParam->sharedRatio] stringValue] isEqualToString:@"0"]){
                            label.text = @"0.00%";
                        }else if (![[[NSNumber numberWithDouble:mtParam->sharedRatio] stringValue] isEqualToString:@"-0"]) {
                            label.text = [NSString stringWithFormat:@"%.2lf%%",mtParam->sharedRatio*100];
                        }
                    }
                }
                
                if (columnIndex == 6 || columnIndex == 7) {
                    label.textColor = [UIColor blueColor];
                    
                    if (columnIndex == 6) {
                        label.text = [CodingUtil getValueUnitString:mtParam->offset Unit:mtParam->offsetUnit];
                    } else if (columnIndex == 7) {
                        if(mtParam->usedAmount) {
                            double sum = (mtParam->usedShare*pow(1000,mtParam->usedShareUnit)) / (mtParam->usedAmount*pow(1000,mtParam->usedAmountUnit));
                            label.text = [NSString stringWithFormat:@"%.2f%%",floor(sum*100 * 100) / 100];
                        }
                    }
                }
            }
 
        }
    } else {
        
        NSDate *startDate, *endDate;
        
        UInt16 lastRecordDate = [_dataModel.marginTrading getLastRecordDate];
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
        
        NSDictionary *dict = [_dataModel.marginTrading getIIG1StatWithBetweenStartDate:[startDate uint16Value] AndEndDate:[endDate uint16Value]];
        
        if (columnIndex == 0) {
            float field1 = [(NSNumber *)[dict objectForKey:@"amountOffsetTotal"] floatValue];
            if (field1 > 0) {
                label.textColor = [UIColor redColor];
                if (_portfolioItem->type_id == 6) {
                    label.text = [NSString stringWithFormat:@"+%.2f", field1/10000];
                }else{
                    label.text = [NSString stringWithFormat:@"+%.f", field1];
                }
            } else if (field1 == 0) {
                label.textColor = [UIColor blueColor];
                if (_portfolioItem->type_id == 6) {
                    label.text = [NSString stringWithFormat:@"%.2f", field1/10000];
                }else{
                    label.text = [NSString stringWithFormat:@"%.f", field1];
                }
            } else if (field1 < 0) {
                label.textColor = [StockConstant PriceDownColor];
                if (_portfolioItem->type_id == 6) {
                    label.text = [NSString stringWithFormat:@"%.2f", field1/10000];
                }else{
                    label.text = [NSString stringWithFormat:@"%.f", field1];
                }
            }
            
        } else if (columnIndex == 1) {
            float field2 = [(NSNumber *)[dict objectForKey:@"amountOffsetRatio"] floatValue];
            if ([[dict objectForKey:@"amountOffsetRatio"] isEqualToNumber:[NSDecimalNumber notANumber]]) {
                label.textColor = [UIColor blackColor];
                label.text = @"----";
            }else{
                if (field2 > 0 || field2 == 0) {
                    field2 = floor(field2 * 10000) / 100;
                }else{
                    field2 = -floor(abs(field2 * 10000)) / 100;
                }
                
                if (field2 == INFINITY) {
                    label.textColor = [UIColor redColor];
                    label.text = @"0.00%";
                } else if (field2 > 0) {
                    label.textColor = [UIColor redColor];
                    label.text = [NSString stringWithFormat:@"+%.2f%%", field2];
                } else if (field2 == 0) {
                    label.textColor = [UIColor blueColor];
                    label.text = [NSString stringWithFormat:@"%.2f%%", field2];
                } else if (field2 < 0) {
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [NSString stringWithFormat:@"%.2f%%", field2];
                }
            }
        } else if (columnIndex == 2) {
            float field3 = [(NSNumber *)[dict objectForKey:@"sharedOffsetTotal"] floatValue];
            if (_portfolioItem->type_id == 6) {
                if (field3 >0) {
                    field3 = floor(field3 / 100) / 100;
                }else{
                    field3 = -floor(abs(field3 / 100)) / 100;
                }
            }
            
            if (field3 > 0) {
                label.textColor = [UIColor redColor];
                if (_portfolioItem->type_id == 6) {
                    label.text = [NSString stringWithFormat:@"+%.2f", field3];
                }else{
                    label.text = [NSString stringWithFormat:@"+%.f", field3];
                }
            } else if (field3 == 0) {
                field3 = abs(field3);
                label.textColor = [UIColor blueColor];
                if (_portfolioItem->type_id == 6) {
                    label.text = [NSString stringWithFormat:@"%.2f", field3];
                }else{
                    label.text = [NSString stringWithFormat:@"%.f", field3];
                }
            } else if (field3 < 0) {
                label.textColor = [StockConstant PriceDownColor];
                if (_portfolioItem->type_id == 6) {
                    label.text = [NSString stringWithFormat:@"%.2f", field3];
                }else{
                    label.text = [NSString stringWithFormat:@"%.f", field3];
                }
            }
            
        } else if (columnIndex == 3) {
            float field4 = floorf([(NSNumber *)[dict objectForKey:@"sharedOffsetRatio"] floatValue] * 100 * 100) / 100;
            
            
            if (field4 == INFINITY) {
                label.textColor = [UIColor redColor];
                label.text = @"0.00%";
            } else if (field4 >= 100) {
                label.textColor = [UIColor redColor];
                label.text = [NSString stringWithFormat:@"+100%%"];
            } else if (field4 > 0) {
                label.textColor = [UIColor redColor];
                label.text = [NSString stringWithFormat:@"+%.2f%%", field4];
            } else if (field4 == 0) {
                label.textColor = [UIColor blueColor];
                label.text = [NSString stringWithFormat:@"%.2f%%", field4];
            } else if (field4 < 0) {
                label.textColor = [StockConstant PriceDownColor];
                label.text = [NSString stringWithFormat:@"%.2f%%", field4];
            }
            
        } else if (columnIndex == 4) {
            int field5 = [(NSNumber *)[dict objectForKey:@"offsetTotal"] intValue];
            
            if (field5 > 0) {
                label.textColor = [UIColor redColor];
                label.text = [NSString stringWithFormat:@"+%d", field5];
            } else if (field5 == 0) {
                label.textColor = [UIColor blueColor];
                label.text = [NSString stringWithFormat:@"%d", field5];
            } else if (field5 < 0) {
                label.textColor = [StockConstant PriceDownColor];
                label.text = [NSString stringWithFormat:@"%d", field5];
            }
            
        }
    }
    
    
    
    
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dataModel.cyqModel.currentSearchType == CYQSearchType_dailyMode) {
        return [_dataModel.marginTrading getRowCount];
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
