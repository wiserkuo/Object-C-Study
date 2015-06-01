//
//  RevenueController.m
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/1/13.
//  Copyright 2009 NHCUE. All rights reserved.
//

//#import "TAtestController.h"
#import <QuartzCore/QuartzCore.h>
#import "RevenueController.h"
#import "RevenueCell.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface RevenueController()
{
    NSString *identCode;
}
@property(nonatomic,strong) NSArray *revenueHeaderNameArray; //營收
@property(nonatomic,strong) NSArray *headerSmybolArray; //營收symbol
@property (strong, nonatomic) SKCustomTableView *revenueTableView;
@property (strong, nonatomic) UILabel *unitLabel;
@property (strong, nonatomic) NSMutableArray *revenueArray;
@property (strong, nonatomic) FSDataModelProc *model;
@end


@implementation RevenueController

@synthesize revenueHeaderNameArray;

@synthesize headerSmybolArray;

@synthesize barBtn;
@synthesize isSelectACell;



- (void)viewDidLoad {
	
    [super viewDidLoad];
    
#ifdef PatternPowerUS
    identCode = @"US";
#endif
    
#ifdef PatternPowerTW
    identCode = @"TW";
#endif
	self.revenueArray = [[NSMutableArray alloc]init];
    [self addRevenueTableView];
    [self addUnitLabel];
    [self setupArrayData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sendRequest];
}

-(void)NewRevenueNotifyData:(id)target {
    self.revenueArray = target;
    [self.revenueTableView hideHUD];
    [self.revenueTableView reloadAllData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    
    [self.revenueArray removeAllObjects];
    [self.revenueTableView reloadAllData];
    self.model.nRevenue.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendRequest)];
}


- (void)sendRequest
{
    [self.revenueTableView showHUDWithTitle:NSLocalizedStringFromTable(@"Downloading",@"Draw",nil)];
    self.model = [FSDataModelProc sharedInstance];
    _model.nRevenue.delegate = self;
    [_model.nRevenue sendAndRead];
}


#pragma mark - UI Init

- (void)addRevenueTableView
{
    
    if ([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]) {
        self.revenueTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:55 mainColumnWidth:85 AndColumnHeight:44];
    } else {
        self.revenueTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:70 mainColumnWidth:85 AndColumnHeight:44];
    }
    
    _revenueTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _revenueTableView.delegate = self;
    [self.view addSubview:_revenueTableView];
}

- (void)addUnitLabel
{
    self.unitLabel = [[UILabel alloc] init];
    _unitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _unitLabel.text = NSLocalizedStringFromTable(@"單位：百萬", @"Equity", nil);
    _unitLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _unitLabel.textColor = [UIColor colorWithRed:0 green:0.528 blue:1 alpha:1.000];
    [self.view addSubview:_unitLabel];
}

#pragma mark - Array Init

- (void)setupArrayData
{
    //NSString *date = NSLocalizedStringFromTable(@"年/月", @"Equity", @"Date");
    //合併營收
    NSString *mergedRevenue = NSLocalizedStringFromTable(@"合併營收", @"Equity", @"");
    NSString *mergedRevenueOneYearAgo = NSLocalizedStringFromTable(@"去年同期", @"Equity", @"");
    NSString *mergedYoY = NSLocalizedStringFromTable(@"成長率", @"Equity", @"");
    
    //累計合併營收
    NSString *accumulatedMergedRevenue = NSLocalizedStringFromTable(@"累計合併營收", @"Equity", @"");
    NSString *accumulatedMergedRevenueOneYearAgo = NSLocalizedStringFromTable(@"去年同期累計", @"Equity", @"");
    NSString *accumulatedMergedYoY = NSLocalizedStringFromTable(@"累計成長率", @"Equity", @"");
    
    //月增率
    NSString *mom = NSLocalizedStringFromTable(@"月增率", @"Equity", @"monthRevenueRateOfChange");
    
    //當月營收
	NSString *revenue = NSLocalizedStringFromTable(@"當月營收", @"Equity", @"Revenue");
	NSString *revenueOneYearAgo = NSLocalizedStringFromTable(@"去年同期營收", @"Equity", @"lastYearRevenue");
	NSString *revenueYoY = NSLocalizedStringFromTable(@"成長率", @"Equity", @"YoY.");
    
    //累計營收
	NSString *accumulatedRevenue = NSLocalizedStringFromTable(@"累計營收", @"Equity", @"accumulatedRevenue");
	NSString *accumulatedRevenueOneYearAgo = NSLocalizedStringFromTable(@"去年同期累計", @"Equity", @"lastYearAccumulatedRevenue");
	NSString *accumulatedRevenueYoY = NSLocalizedStringFromTable(@"累計成長率", @"Equity", @"lastYearAccumulatedYoY");
	
	//NSString *accumulatedRevenueAchivedRate = NSLocalizedStringFromTable(@"年達成率％", @"CompanyProfile", @"accumulatedAchieveRate");
	
	
	
	// segment 0 : date revenue accumulatedRevenue , segment
    if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
        self.headerSmybolArray = [[NSArray alloc]initWithObjects:
                                  //@"date",
                                  @"mergedRevenue",
                                  @"mergedRevenueOneYearAgo",
                                  @"mergedYoY",
                                  
                                  @"accumulatedMergedRevenue",
                                  @"accumulatedMergedRevenueOneYearAgo",
                                  @"accumulatedMergedYoY",
                                  
                                  @"mom",
//                                  @"revenue",
//                                  @"revenueOneYearAgo",
//                                  @"revenueYoY",
//                                  @"accumulatedRevenue",
//                                  @"accumulatedRevenueOneYearAgo",
//                                  @"accumulatedRevenueYoY",
                                  nil];
        
        self.revenueHeaderNameArray = [[NSMutableArray alloc] initWithObjects:
                                       
                                      // date,
                                       mergedRevenue,
                                       mergedRevenueOneYearAgo,
                                       mergedYoY,
                                       
                                       accumulatedMergedRevenue,
                                       accumulatedMergedRevenueOneYearAgo,
                                       accumulatedMergedYoY,
                                       
                                       mom,
//                                       revenue,
//                                       revenueOneYearAgo,
//                                       revenueYoY,
//                                       accumulatedRevenue,
//                                       accumulatedRevenueOneYearAgo,
//                                       accumulatedRevenueYoY,
                                       
                                       nil];
        
        
        
    }else{
        self.headerSmybolArray = [[NSArray alloc]initWithObjects:
                                  @"revenue",
                                  @"revenueOneYearAgo",
                                  @"revenueYoY",
                                  @"accumulatedRevenue",
                                  @"accumulatedRevenueOneYearAgo",
                                  @"accumulatedRevenueYoY",
                                  nil];
        
        self.revenueHeaderNameArray = [[NSMutableArray alloc] initWithObjects:
                                       revenue,
                                       revenueOneYearAgo,
                                       revenueYoY,
                                       accumulatedRevenue,
                                       accumulatedRevenueOneYearAgo,
                                       accumulatedRevenueYoY,
                                       
                                       nil];
    }
	
}

//change segment index (for sorting)
- (void)changeSegmentIndex:(id)sender {
	[_revenueTableView reloadAllData];
}

- (int)getSegmentIndexByHeaderIndex:(int)headerIndex{
	
	int segmentIndex;
	
	if(headerIndex==0){
		
		segmentIndex = 0;
	}
	else{
		
		int value = fmod(headerIndex,3);
		
		switch (value) {
			case 0:
				segmentIndex = 3;
				break;
			case 1:
				segmentIndex = 1;
				break;
			case 2:
				segmentIndex = 2;
				break;
		}

		
	}
	
	return segmentIndex;
	
	
}

-(int)getCurrentPageBySelectedSegmentIndex:(int)selectedIndex{

	int r = fmod(selectedIndex,3);
	int v = floor((selectedIndex)/3);
	int pageNumber;
	if(r>0){
		
		pageNumber = v+1; //
	}
	else{
		
		pageNumber = v;
		
	}
	
	return pageNumber;

}



#pragma mark Table view methods

- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"年/月", @"Equity", @"Date")];
}

- (NSArray *)columnsInMainTableView {
    return revenueHeaderNameArray;
}

- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int recordCount = (int)[_revenueArray count];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    label.textAlignment = NSTextAlignmentLeft;
    if(recordCount<=0)
    {
        label.text = @"----";
        label.textColor = [UIColor orangeColor];
    }
    else {
        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
            //getRowData會檢查傳進去的參數是否大於0
            // change format : year/month => month/year （Memory 中的資料年放在前頭 也就是year/month格式 這樣比較好遵照 “年 月“ 來ＳＯＲＴ,而輸出因應要求則需轉換成 month/year）
            label.text = [self getDateStr:[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Date"]];
            label.textColor = [UIColor blueColor];
        }else{
            //getRowData會檢查傳進去的參數是否大於0
            // change format : year/month => month/year （Memory 中的資料年放在前頭 也就是year/month格式 這樣比較好遵照 “年 月“ 來ＳＯＲＴ,而輸出因應要求則需轉換成 month/year）
            NSString *monthString =@"";
            int month = [[[self getDateStr:[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Date"]] substringFromIndex:5]intValue];
            if (month>=1 && month<=3) {
                monthString = @"Q1";
            }else if (month>=4 && month<=6){
                monthString = @"Q2";
            }else if (month>=7 && month<=9){
                monthString = @"Q3";
            }else if (month>=10 && month<=12){
                monthString = @"Q4";
            }
            NSRange yearRange;
            yearRange.location	= 0;
            yearRange.length = 4;
            NSString *yearString = [[self getDateStr:[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Date"]] substringWithRange:yearRange];
            if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"us"]){
                label.text = [NSString stringWithFormat:@"%@/%04d",monthString,[yearString intValue]];
            }else {
                label.text = [NSString stringWithFormat:@"%04d/%@",[yearString intValue],monthString];
            }
            label.textColor = [UIColor blueColor];
        }
    }
    
}

- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int recordCount = (int)[_revenueArray count];
    
    if (recordCount <= 0) {
        label.text = @"----";
        label.textColor = [UIColor blackColor];
        return;
    }
    else {
        //column會預先產生25個(因應選股精靈)，所以超過自己要的index不要跑
        if (columnIndex < [headerSmybolArray count]) {
            [self updateRevenueLabel:label columnIndex:columnIndex indexPath:indexPath header:headerSmybolArray[columnIndex]];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // 最多八筆
    int count = (int)[_revenueArray count];
    
    if([identCode isEqualToString:@"TW"]){
        if(count > 12) {
            count = 12;
        }
    }else{
        if(count > 8){
            count = 8;
        }
    }
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark API for UI

-(void)updateRevenueLabel:(UILabel *) label columnIndex:(NSInteger)columnIndex indexPath:(NSIndexPath *) indexPath header:(NSString *) header
{
    int recordCount = (int)[_revenueArray count];
    if (recordCount <= 0) {
        label.text = @"----";
    }
    else {
        //營收
        
        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
            
            if (columnIndex == 0 && [header isEqualToString:@"mergedRevenue"]) {
                //合併營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", floor([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"MergedRevenue"]doubleValue])];
            }
            else if (columnIndex == 1 && [header isEqualToString:@"mergedRevenueOneYearAgo"]) {
                //去年合併營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"MergedRevenueYearAgo"]doubleValue] == 0.00){
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }else{
                    label.text = [NSString stringWithFormat:@"%.0f", floor([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"MergedRevenueYearAgo"]doubleValue])];
                }
            }
            else if (columnIndex == 2 && [header isEqualToString:@"mergedYoY"]) {
                //合併營收成長率
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [self getPrecent:[[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue]];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MergedRevenueYoY"]doubleValue]];
                }else{
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }
            }
            else if (columnIndex == 3 && [header isEqualToString:@"accumulatedMergedRevenue"]) {
                //累計合併營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", floor([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"AccumulatedMergedRevenue"]doubleValue])];
            }
            else if (columnIndex == 4 && [header isEqualToString:@"accumulatedMergedRevenueOneYearAgo"]) {
                //去年累計合併營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"AccumulatedMergedRevenueYearAgo"]doubleValue] == 0.00){
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }else{
                    label.text = [NSString stringWithFormat:@"%.0f", floor([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"AccumulatedMergedRevenueYearAgo"]doubleValue])];
                }
            }
            else if (columnIndex == 5 && [header isEqualToString:@"accumulatedMergedYoY"]) {
                //累計合併營收成長率
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue]];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedMergedRevenueYoY"]doubleValue]];
                }else{
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }
            }
            else if (columnIndex == 6 && [header isEqualToString:@"mom"]) {
                //月增率
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MoM"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MoM"]doubleValue]];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MoM"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"MoM"]doubleValue]];
                }else{
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }
            }
            else if (columnIndex == 7 && [header isEqualToString:@"revenue"]) {
                //當月營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Revenue"]doubleValue]];
            }
            else if (columnIndex == 8 && [header isEqualToString:@"revenueOneYearAgo"]){
                //去年同期營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"RevenueYearAgo"]doubleValue]];
            }
            else if (columnIndex == 9 && [header isEqualToString:@"revenueYoY"]){
                //成長率
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [self getPrecent:[[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue]];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue]];
                }else{
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }
            }
            else if (columnIndex == 10 && [header isEqualToString:@"accumulatedRevenue"]) {
                //當月營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"AccumulatedRevenue"]doubleValue]];
            }
            else if (columnIndex == 11 && [header isEqualToString:@"accumulatedRevenueOneYearAgo"]){
                //去年同期營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"AccumulatedRevenueYearAgo"]doubleValue]];
            }
            else if (columnIndex == 12 && [header isEqualToString:@"accumulatedRevenueYoY"]){
                //成長率
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [self getPrecent:[[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue]];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue]];
                }else{
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }
            }
        }else{
            if (columnIndex == 0 && [header isEqualToString:@"revenue"]) {
                //當月營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Revenue"]doubleValue]];
            }
            else if (columnIndex == 1 && [header isEqualToString:@"revenueOneYearAgo"]) {
                //去年當月營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"RevenueYearAgo"]doubleValue]];
                
            }
            else if (columnIndex == 2 && [header isEqualToString:@"revenueYoY"]) {
                //成長率
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue]];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"RevenueYoY"]doubleValue]];
                }else{
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }
                
            }
            else if (columnIndex == 3 && [header isEqualToString:@"accumulatedRevenue"]) {
                //累計營收
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"AccumulatedRevenue"]doubleValue]];
                
            }
            else if (columnIndex == 4 && [header isEqualToString:@"accumulatedRevenueOneYearAgo"]) {
                //去年同期累計
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                }else{
                    label.textColor = [UIColor blueColor];
                }
                label.text = [NSString stringWithFormat:@"%.0f", [(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"AccumulatedRevenueYearAgo"]doubleValue]];
            }
            else if (columnIndex == 5 && [header isEqualToString:@"accumulatedRevenueYoY"]){
                //累計成長率
                if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] > 0){
                    label.textColor = [StockConstant PriceUpColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue]];
                }else if([(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue] < 0){
                    label.textColor = [StockConstant PriceDownColor];
                    label.text = [self getPrecent:[(NSNumber *)[[_revenueArray objectAtIndex:indexPath.row]objectForKey:@"AccumulatedRevenueYoY"]doubleValue]];
                }else{
                    label.textColor = [UIColor blackColor];
                    label.text = @"----";
                }
            }
        }
    }
}


- (void) selectedCell
{
	isSelectACell = YES;
}


#pragma mark - Autolayout

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_revenueTableView, _unitLabel);
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[_revenueTableView][_unitLabel]-20-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_revenueTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_unitLabel]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(NSString *)getDateStr:(NSDate*)date
{
    NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
    [yearFormat setDateFormat:@"yyyy"];
    int year = [(NSNumber *)[yearFormat stringFromDate:date]intValue];
    year-=1911;
    
    NSDateFormatter *monthFormat = [[NSDateFormatter alloc] init];
    [monthFormat setDateFormat:@"MM"];
    NSString *month = [monthFormat stringFromDate:date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM"];
    
    if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
        return [NSString stringWithFormat:@"%d/%@",year,month];
    }else{
        return [formatter stringFromDate:date];
    }
}

-(NSString *)getPrecent:(double)value
{
    if(value > 0 ){
        if(value < 10){
            return [NSString stringWithFormat:@"+%.2f%%", floor(value * 100) / 100];
        }else if(value < 100){
            return [NSString stringWithFormat:@"+%.1f%%", floor(value * 10) / 10];
        }else{
            return [NSString stringWithFormat:@"+%.0f%%", floor(value)];
        }
    }else{
        if(value < -10){
            return [NSString stringWithFormat:@"-%.1f%%", floor(fabs(value * 10)) / 10];
        }else if(value < -100){
            return [NSString stringWithFormat:@"-%.0f%%", floor(fabs(value))];
        }else{
            return [NSString stringWithFormat:@"-%.2f%%", floor(fabs(value * 100)) / 100];
        }
    }
}
@end
