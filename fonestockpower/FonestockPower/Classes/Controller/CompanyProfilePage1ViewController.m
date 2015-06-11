//
//  CompanyProfilePage1ViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/11/12.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "CompanyProfilePage1ViewController.h"
#import "CompanyProfilePage1Cell.h"
#import "CompanyProfilePage1WideStyleCell.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "NewCompanyProfile.h"
//#define CELL_CONTENT_MARGIN 0.0f

@interface CompanyProfilePage1ViewController () <UITableViewDelegate, UITableViewDataSource, NewCompanyProfileDelegate>
{
    NSString *identSymbol;
    UILabel *heightLabel;
}
@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) NSArray *companyTitleData;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) FSInstantInfoWatchedPortfolio *watchportfolio;
@property (strong, nonatomic) EquitySnapshotDecompressed *mySnapshot;
@property (strong, nonatomic) FSDataModelProc *dataModel;
@property (strong, nonatomic) NSArray *epsArray;
@property (strong, nonatomic) NSString * dateStr;
@property (strong, nonatomic) FSSnapshot * lpcbSnapshot;
@end

@implementation CompanyProfilePage1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataModel = [FSDataModelProc sharedInstance];
    [self initMainTableView];
    [self processLayout];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.watchportfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    identSymbol = [_watchportfolio.portfolioItem getIdentCodeSymbol];

    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]portfolioTickBank];
    self.mySnapshot = [tickBank getSnapshotFromIdentCodeSymbol:identSymbol];
    self.lpcbSnapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshotBvalueFromIdentCodeSymbol:identSymbol];
    
    [self sendCompany];
    [self registerLoginNotificationCallBack:self seletor:@selector(sendCompany)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendCompany)];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    
    self.dict = nil;
    NewCompanyProfile *companyProfile = [NewCompanyProfile sharedInstance];
    companyProfile.delegate = nil;
    [_dataModel.historicalEPS setTargetNotify:nil];
}
-(void)sendCompany
{
    [_dataModel.historicalEPS loadFromIdentSymbol:[FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem.getIdentCodeSymbol];
    [_dataModel.historicalEPS setTargetNotify:self];
    [_dataModel.historicalEPS sendAndRead];
    
    NewCompanyProfile *companyProfile = [NewCompanyProfile sharedInstance];
    companyProfile.delegate = self;
    [companyProfile sendAndRead];
}

- (void)initMainTableView {
    heightLabel = [[UILabel alloc] init];
    self.mainTableView = [[UITableView alloc] init];
    self.mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.allowsSelection = NO;
    self.mainTableView.bounces = NO;
    [self.view addSubview:self.mainTableView];
}

-(void)initDate
{
    NSString * month = [[_dataModel.historicalEPS getCompanyEPSDate]objectAtIndex:0];
    NSString * year = [[_dataModel.historicalEPS getCompanyEPSDate]objectAtIndex:1];
    int yearInt;
    int beforeYear;
    if([[identSymbol substringToIndex:2]isEqualToString:@"TW"]){
        yearInt =[year intValue]+1911;
        beforeYear = yearInt-1-1911;
        yearInt-=1911;
    }else{
        yearInt =[year intValue]+1911;
        beforeYear = yearInt-1;
    }
    
    int monthInt =[month intValue];
    
    NSString * quarter=[NSString stringWithFormat:@"Q%i",monthInt];
    if([quarter isEqualToString:@"Q1"]){
        if([[identSymbol substringToIndex:2]isEqualToString:@"TW"]){
            _dateStr = [NSString stringWithFormat:@"(%i/Q2~%i/Q1)", beforeYear, yearInt];
        }else{
            _dateStr = [NSString stringWithFormat:@"(Q2/%i~Q1/%i)", beforeYear, yearInt];
        }
    }else if ([quarter isEqualToString:@"Q2"]){
        if([[identSymbol substringToIndex:2]isEqualToString:@"TW"]){
            _dateStr = [NSString stringWithFormat:@"(%i/Q3~%i/Q2)", beforeYear, yearInt];
        }else{
            _dateStr = [NSString stringWithFormat:@"(Q3/%i~Q2/%i)", beforeYear, yearInt];
        }
    }else if ([quarter isEqualToString:@"Q3"]){
        if([[identSymbol substringToIndex:2]isEqualToString:@"TW"]){
            _dateStr = [NSString stringWithFormat:@"(%i/Q4~%i/Q3)", beforeYear, yearInt];
        }else{
            _dateStr = [NSString stringWithFormat:@"(Q4/%i~Q3/%i)", beforeYear, yearInt];
        }
    }else if ([quarter isEqualToString:@"Q4"]){
        if([[identSymbol substringToIndex:2]isEqualToString:@"TW"]){
            _dateStr = [NSString stringWithFormat:@"(%i/Q1~%i/Q4)", yearInt, yearInt];
        }else{
            _dateStr = [NSString stringWithFormat:@"(Q1/%i~Q4/%i)", yearInt, yearInt];
        }
            
    }else{
        _dateStr = @"(---)";
    }
}

#pragma mark -
#pragma mark Layout處理

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_mainTableView);
    
    // mainTableView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainTableView]-15-|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark -
#pragma mark notifyData處理

- (void)notifyData {
    
    //DataModalProc *dataModal = [DataModalProc getDataModal];
    //self.dict = [dataModal.companyProfile getDictData];
    [self initDate];
    [self.mainTableView reloadData];
    
}

- (void)notifyData:(id)target {
    self.dict = target;
    [self.mainTableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDelegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([[identSymbol substringToIndex:2] isEqualToString:@"TW"]){
        return 1;
    }else{
        return 2;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([[identSymbol substringToIndex:2] isEqualToString:@"TW"]){
        return 15;
    }else{
        if (section == 0) {
            return 8;
        } else if (section == 1) {
            return 1;
        } else {
            return 0;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([[identSymbol substringToIndex:2] isEqualToString:@"TW"]){
        return 0;
    }else{
        if (section == 1) {
            return 44.0f;
        } else {
            return 0;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UILabel *title = [[UILabel alloc] init];
        title.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
        title.textColor = [UIColor blackColor];
        title.font = [UIFont boldSystemFontOfSize:18.0f];
        title.text = NSLocalizedStringFromTable(@"公司簡介", @"Equity", nil);
        return title;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"CompanyProfilePage1Cell";
    CompanyProfilePage1Cell *cell = (CompanyProfilePage1Cell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil) {
        cell = [[CompanyProfilePage1Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    if([[identSymbol substringToIndex:2] isEqualToString:@"TW"]){
        // 集團名稱
        if (indexPath.row == 0) {
            cell.titleLabel.text = NSLocalizedStringFromTable(@"集團名稱", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor redColor];
            cell.detailLabel.text = [self.dict objectForKey:@"IndustryAssociationName"];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 1){
            //董事長
            cell.titleLabel.text = NSLocalizedStringFromTable(@"董事長", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"COB"];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 2){
            //總經理
            cell.titleLabel.text = NSLocalizedStringFromTable(@"總經理", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"Manager"];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 3){
            //成立日期
            cell.titleLabel.text = NSLocalizedStringFromTable(@"成立日期", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"FoundDate"];
            if (cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 4){
            //掛牌日期
            cell.titleLabel.text = NSLocalizedStringFromTable(@"掛牌日期", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"ListDate"];
            if (cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 5){
            //公司電話
            cell.titleLabel.text = NSLocalizedStringFromTable(@"公司電話", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"Phone"];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 6){
            //公司傳真
            cell.titleLabel.text = NSLocalizedStringFromTable(@"公司傳真", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"Fax"];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 7){
            //公司地址
            cell.titleLabel.text = NSLocalizedStringFromTable(@"公司地址", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor redColor];
            cell.detailLabel.text = [self.dict objectForKey:@"Address"];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 8){
            //公司網站
            cell.titleLabel.text = NSLocalizedStringFromTable(@"公司網站", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"Website"];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 9){
            //員工人數
            cell.titleLabel.text = NSLocalizedStringFromTable(@"員工人數", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [NSString stringWithFormat:@"%d",[(NSNumber *)[self.dict objectForKey:@"Employees"]intValue]];
            if ([cell.detailLabel.text isEqualToString:@"0"] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 10){
            //當期股本
            cell.titleLabel.text = NSLocalizedStringFromTable(@"當期股本", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor redColor];
            
            NSUInteger capital = [(NSNumber *)[self.dict objectForKey:@"Capital"] doubleValue];
            
            cell.detailLabel.text = [CodingUtil twStringWithVolumeByValue:capital];
            if ([cell.detailLabel.text isEqualToString:@"0.00億"] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 11){
            //總市值
            cell.titleLabel.text = NSLocalizedStringFromTable(@"總市值", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            
            NSUInteger capital = [(NSNumber *)[self.dict objectForKey:@"Capital"] doubleValue];
            double marketValue = capital * [(NSNumber *)[self.lpcbSnapshot.last_price format] doubleValue] / 10;
            
            cell.detailLabel.text = [CodingUtil twStringWithVolumeByValue:marketValue];
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil || marketValue ==0){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 12){
            //累計EPS
            cell.titleLabel.text = NSLocalizedStringFromTable(@"累計EPS", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            if([self.dict objectForKey:@"eps"] == nil){
                cell.detailLabel.text = @"----";
            }else{
                cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@",[self.dict objectForKey:@"eps"], _dateStr];
            }
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
            if (!self.dict){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 13){
            //本益比
            cell.titleLabel.text = NSLocalizedStringFromTable(@"本益比", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [NSString stringWithFormat:@"%.2f", [[self.lpcbSnapshot.last_price format]doubleValue]/ [(NSNumber *)[self.dict objectForKey:@"eps"] doubleValue]];
            if ([(NSNumber *)[self.dict objectForKey:@"eps"] doubleValue] == 0){
                cell.detailLabel.text = @"----";
            }
        }else if(indexPath.row == 14){
            //公司簡介
            cell.titleLabel.text = NSLocalizedStringFromTable(@"公司簡介", @"Equity", nil);
            cell.detailLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = [self.dict objectForKey:@"Business Summary"];
            heightLabel.text = cell.detailLabel.text;
            if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                cell.detailLabel.text = @"----";
            }
        }
    }else{
        if (indexPath.section == 0) {
            // Web site
            if (indexPath.row == 0) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"公司網站", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor blackColor];
                cell.detailLabel.text = [self.dict objectForKey:@"Website"];
                if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                    cell.detailLabel.text = @"----";
                }
            }
            
            // Employee
            else if (indexPath.row == 1) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"員工人數", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor blackColor];
                cell.detailLabel.text = [[self.dict objectForKey:@"Employees"] stringValue];
                if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                    cell.detailLabel.text = @"----";
                }
            }
            // Shares Outstanding
            else if (indexPath.row == 2) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"發行股數", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor redColor];
                double sharesOutstanding = [(NSNumber *)[self.dict objectForKey:@"SharesOutstandingDouble"] doubleValue];
                cell.detailLabel.text = [CodingUtil getMarketValue:sharesOutstanding];
                if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil || sharesOutstanding==0){
                    cell.detailLabel.text = @"----";
                }
            }
            // The Number of Shares Outstanding
            else if (indexPath.row == 3) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"流通在外股數", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor blackColor];
                if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                    cell.detailLabel.text = @"----";
                }
            }
            // Market Cap
            else if (indexPath.row == 4) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"總市值", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor blackColor];
                
                double sharesOutstanding = [(NSNumber *)[self.dict objectForKey:@"SharesOutstandingDouble"] doubleValue];
#ifdef LPCB
                double currentPrice = [[self.lpcbSnapshot.last_price format]doubleValue];
#else
                double currentPrice = self.mySnapshot.currentPrice;
#endif

                double marketValue = sharesOutstanding * currentPrice;
                
                cell.detailLabel.text = [CodingUtil getMarketValue:marketValue];
                if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil || marketValue ==0){
                    cell.detailLabel.text = @"----";
                }
            }
            // EPS ttm
            else if (indexPath.row == 5) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"累計EPS", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor blackColor];
                if([[self.dict objectForKey:@"eps"] isEqual:NULL]){
                    cell.detailLabel.text = @"----";
                }else{
                    cell.detailLabel.text = [NSString stringWithFormat:@"%@ %@",[self.dict objectForKey:@"eps"], _dateStr];
                }
                if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                    cell.detailLabel.text = @"----";
                }
                if (!self.dict){
                    cell.detailLabel.text = @"----";
                }
            }
            // EPS fwd
            else if (indexPath.row == 6) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"預估EPS", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor blackColor];
                if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
                    cell.detailLabel.text = @"----";
                }
            }
            // P/E
            else if (indexPath.row == 7) {
                cell.titleLabel.text = NSLocalizedStringFromTable(@"本益比", @"Equity", nil);
                cell.detailLabel.textColor = [UIColor blackColor];
#ifdef LPCB
                cell.detailLabel.text = [NSString stringWithFormat:@"%.2f", [[self.lpcbSnapshot.last_price format]doubleValue]/ [(NSNumber *)[self.dict objectForKey:@"eps"] doubleValue]];
#else
                cell.detailLabel.text = [NSString stringWithFormat:@"%.2f", self.mySnapshot.currentPrice / [(NSNumber *)[self.dict objectForKey:@"eps"] doubleValue]];
#endif
                if ([(NSNumber *)[self.dict objectForKey:@"eps"] doubleValue] == 0){
                    cell.detailLabel.text = @"----";
                }
            }
        } else if (indexPath.section == 1) {
            // 公司簡介
            if (indexPath.row == 0) {
                
                static NSString *kCellIdentifier = @"CompanyProfilePage1WideStyleCell";
                CompanyProfilePage1WideStyleCell *cell = (CompanyProfilePage1WideStyleCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
                
                if (cell == nil) {
                    cell = [[CompanyProfilePage1WideStyleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
                }
                
                cell.detailLabel.text = [self.dict objectForKey:@"Business Summary"];
                
                return cell;
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *contentText = @"";
    if([[identSymbol substringToIndex:2] isEqualToString:@"TW"]){
        if (indexPath.row == 14) {
            contentText = [self.dict objectForKey:@"Business Summary"];
            UIFont * font = [UIFont boldSystemFontOfSize:16.0f];
            CGSize constraint = CGSizeMake(tableView.frame.size.width - 40, 20000.0f);
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            
            NSDictionary *attributes = @{ NSFontAttributeName: font,
                                          NSParagraphStyleAttributeName: paragraphStyle };
            CGSize size = [contentText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
            
            CGFloat height = MAX(size.height+40 , 44.0f);
            return height;
        }else{
            return 44.0f;
        }
    }else{
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                
                contentText = [self.dict objectForKey:@"Business Summary"];
                UIFont * font = [UIFont systemFontOfSize:16.0f];
                CGSize constraint = CGSizeMake(tableView.frame.size.width - 90, 10000.0f);
                NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                paragraphStyle.maximumLineHeight = 13.0f;
                NSDictionary *attributes = @{ NSFontAttributeName: font,
                                              NSParagraphStyleAttributeName: paragraphStyle };
                CGSize size = [contentText boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                
                CGFloat height = MAX(size.height + 90 , 44.0f);
                return height;
            }
        }
        return 36.0f;
    }
}

@end
