//
//  FSEPSViewController.m
//  FonestockPower
//
//  Created by Connor on 14/3/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSHistoricalEPSViewController.h"
#import "FSHistoricalEPSCell.h"
#import "FSHistoricalEPSChartView.h"
#import "UIView+NewComponent.h"
#import "FSRadioButtonSet.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface FSHistoricalEPSViewController () <UITableViewDataSource, UITableViewDelegate, FSRadioButtonSetDelegate> {
    UITableView *mainTableView;
    FSUIButton *sortByYearBtn;
    FSUIButton *sortBySeasonBtn;
    FSRadioButtonSet *sortButtonSet;
    UIView *epsChartView;
    FSDataModelProc * dataModel;
    NSArray *epsArray;
    PortfolioItem *item;
}

@end

static enum EPSchartMode epsChartMode;

@implementation FSHistoricalEPSViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupMainTableView];
    [self setupActionButton];
    [self setupChartView];
    [self initDataModel];
    
    // 利用radiobutton來控制所有流程:
    // epsChartMode (EPSChartMode_Year=0) (EPSChartMode_Season=1)
    sortButtonSet = [[FSRadioButtonSet alloc] initWithButtonArray:@[sortByYearBtn, sortBySeasonBtn] andDelegate:self];
    [sortButtonSet setSelectedIndex:epsChartMode];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
    [self registerLoginNotificationCallBack:self seletor:@selector(loadData)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(loadData)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
}

- (void)initDataModel {
    dataModel = [FSDataModelProc sharedInstance];
}

- (void)loadData {
    
    item = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    [dataModel.historicalEPS loadFromIdentSymbol:item.getIdentCodeSymbol];
	[dataModel.historicalEPS setTargetNotify:self];
    epsArray = nil;
    [(FSHistoricalEPSChartView*)epsChartView notifyDrawChart:nil mode:epsChartMode];
    [mainTableView reloadData];
	[dataModel.historicalEPS sendAndRead];
    
//    [self changeChartType];
}

- (void)changeChartType {
    if (epsChartMode == EPSChartMode_Year) {
        sortByYearBtn.selected = YES;
        sortBySeasonBtn.selected = NO;
    } else if (epsChartMode == EPSChartMode_Season) {
        sortByYearBtn.selected = NO;
        sortBySeasonBtn.selected = YES;
    }
    [self notifyData];
}

- (void)notifyData {
    
    epsArray = [dataModel.historicalEPS getAllocEPSArray];
    [mainTableView reloadData];
    [(FSHistoricalEPSChartView*)epsChartView notifyDrawChart:epsArray mode:epsChartMode];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}

- (void)setupMainTableView {
    mainTableView = [[UITableView alloc] init];
    mainTableView.separatorColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
    mainTableView.allowsSelection = NO;
    mainTableView.bounces = NO;
    mainTableView.directionalLockEnabled = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:mainTableView];
}

- (void)setupActionButton {
    sortByYearBtn = [self.view newButton:FSUIButtonTypeNormalRed];
    [sortByYearBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [sortByYearBtn setTitle:NSLocalizedStringFromTable(@"依年度", @"Equity", nil) forState:UIControlStateNormal];
    
    sortBySeasonBtn = [self.view newButton:FSUIButtonTypeNormalRed];
    [sortBySeasonBtn setTitle:NSLocalizedStringFromTable(@"依季度", @"Equity", nil) forState:UIControlStateNormal];
    [sortBySeasonBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
}

- (void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex {
    UIButton *clickButton = [controller.buttons objectAtIndex:selectedIndex];
    
    if (clickButton == sortByYearBtn) {
        epsChartMode = EPSChartMode_Year;
    }
    else if (clickButton == sortBySeasonBtn) {
        epsChartMode = EPSChartMode_Season;
    }
    [self changeChartType];
}

- (void)setupChartView {
    epsChartView = [[FSHistoricalEPSChartView alloc] init];
    epsChartView.backgroundColor = [UIColor whiteColor];
    [epsChartView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:epsChartView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(mainTableView, sortByYearBtn, sortBySeasonBtn, sortByYearBtn, epsChartView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[epsChartView]|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sortByYearBtn][epsChartView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sortByYearBtn][sortBySeasonBtn]" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:viewControllers]];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mainTableView][sortByYearBtn]" options:0 metrics:nil views:viewControllers]];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sortByYearBtn(40)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sortBySeasonBtn(40)]" options:0 metrics:nil views:viewControllers]];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView(167)]" options:0 metrics:nil views:viewControllers]];
    
    
    [self replaceCustomizeConstraints:constraints];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"historicalEPSCell";
    FSHistoricalEPSCell *cell = (FSHistoricalEPSCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FSHistoricalEPSCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // default
    cell.field1.textColor = [UIColor blueColor];
    cell.field2.textColor = [UIColor blackColor];
    cell.field3.textColor = [UIColor blueColor];
    cell.field4.textColor = [UIColor blackColor];
    cell.field5.textColor = [UIColor blueColor];
    cell.field6.textColor = [UIColor blackColor];
    
    cell.field1.text = @"----";
    cell.field2.text = @"----";
    cell.field3.text = @"----";
    cell.field4.text = @"----";
    cell.field5.text = @"----";
    cell.field6.text = @"----";
    
    NSDictionary *epsDict = nil;
    
    if([indexPath row] >[epsArray count]-1){
        return cell;
    }
    
    if ([dataModel.historicalEPS getAllocEPSArray] == nil) {
    
    
    }
    if(epsArray != nil){
        epsDict = [epsArray objectAtIndex:[indexPath row]];
        
        if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
            cell.field1.adjustsFontSizeToFitWidth = YES;
            cell.field1.text = [NSString stringWithFormat:@"%02d Q%d",
                                [(NSNumber *)[epsDict objectForKey:@"yearValue"] intValue],
                                [(NSNumber *)[epsDict objectForKey:@"seasonValue"] intValue]];
        }else{
            cell.field1.text = [NSString stringWithFormat:@"Q%d/%02d",
                                [(NSNumber *)[epsDict objectForKey:@"seasonValue"] intValue],
                                ([(NSNumber *)[epsDict objectForKey:@"yearValue"] intValue] + 1911) % 100];
        }
        
        cell.field2.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue]];
        if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] > 0) {
            cell.field2.textColor = [StockConstant PriceUpColor];
        } else if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] < 0) {
            cell.field2.textColor = [StockConstant PriceDownColor];
        } else if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] == 0) {
            cell.field2.textColor = [UIColor blueColor];
        }
        
        if([indexPath row]+4 >[epsArray count]-1){
            return cell;
        }
        epsDict = [epsArray objectAtIndex:[indexPath row] + 4];
        
        
        if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
            cell.field3.adjustsFontSizeToFitWidth = YES;
            cell.field3.text = [NSString stringWithFormat:@"%02d Q%d",
                                [(NSNumber *)[epsDict objectForKey:@"yearValue"] intValue],
                                [(NSNumber *)[epsDict objectForKey:@"seasonValue"] intValue]];
        }else{
            cell.field3.text = [NSString stringWithFormat:@"Q%d/%02d",
                            [(NSNumber *)[epsDict objectForKey:@"seasonValue"] intValue],
                            ([(NSNumber *)[epsDict objectForKey:@"yearValue"] intValue] + 1911) % 100];
        }
        cell.field4.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue]];
        if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] > 0) {
            cell.field4.textColor = [StockConstant PriceUpColor];
        } else if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] < 0) {
            cell.field4.textColor = [StockConstant PriceDownColor];
        } else if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] == 0) {
            cell.field4.textColor = [UIColor blueColor];
        }
        
        if([indexPath row]+8 >[epsArray count]-1){
            return cell;
        }
        epsDict = [epsArray objectAtIndex:[indexPath row] + 8];
        
        if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
            cell.field5.adjustsFontSizeToFitWidth = YES;
            cell.field5.text = [NSString stringWithFormat:@"%02d Q%d",
                                [(NSNumber *)[epsDict objectForKey:@"yearValue"] intValue],
                                [(NSNumber *)[epsDict objectForKey:@"seasonValue"] intValue]];
        }else{
            cell.field5.text = [NSString stringWithFormat:@"Q%d/%02d",
                                [(NSNumber *)[epsDict objectForKey:@"seasonValue"] intValue],
                                ([(NSNumber *)[epsDict objectForKey:@"yearValue"] intValue] + 1911) % 100];
        }
        
        
        cell.field6.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue]];
        if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] > 0) {
            cell.field6.textColor = [StockConstant PriceUpColor];
        } else if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] < 0) {
            cell.field6.textColor = [StockConstant PriceDownColor];
        } else if ([(NSNumber *)[epsDict objectForKey:@"epsValue"] floatValue] == 0) {
            cell.field6.textColor = [UIColor blueColor];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *cellIdentifier = @"historicalEPSHeaderCell";

    FSHistoricalEPSCell *headerView = (FSHistoricalEPSCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (headerView == nil) {
        headerView = [[FSHistoricalEPSCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    headerView.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1.0f];

    headerView.field1.textColor = [UIColor whiteColor];
    headerView.field2.textColor = [UIColor whiteColor];
    headerView.field3.textColor = [UIColor whiteColor];
    headerView.field4.textColor = [UIColor whiteColor];
    headerView.field5.textColor = [UIColor whiteColor];
    headerView.field6.textColor = [UIColor whiteColor];
    
    
    if ([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
        headerView.field1.text = NSLocalizedStringFromTable(@"年/季", @"Equity", nil);
        headerView.field2.text = NSLocalizedStringFromTable(@"EPS", @"Equity", nil);
        headerView.field3.text = NSLocalizedStringFromTable(@"年/季", @"Equity", nil);
        headerView.field4.text = NSLocalizedStringFromTable(@"EPS", @"Equity", nil);
        headerView.field5.text = NSLocalizedStringFromTable(@"年/季", @"Equity", nil);
        headerView.field6.text = NSLocalizedStringFromTable(@"EPS", @"Equity", nil);
    } else {
        headerView.field1.text = NSLocalizedStringFromTable(@"季/年", @"Equity", nil);
        headerView.field2.text = NSLocalizedStringFromTable(@"EPS", @"Equity", nil);
        headerView.field3.text = NSLocalizedStringFromTable(@"季/年", @"Equity", nil);
        headerView.field4.text = NSLocalizedStringFromTable(@"EPS", @"Equity", nil);
        headerView.field5.text = NSLocalizedStringFromTable(@"季/年", @"Equity", nil);
        headerView.field6.text = NSLocalizedStringFromTable(@"EPS", @"Equity", nil);
    }
    
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 33;
}

@end
