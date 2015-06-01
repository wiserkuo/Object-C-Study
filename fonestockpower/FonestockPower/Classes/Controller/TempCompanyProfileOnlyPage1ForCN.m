//
//  TempCompanyProfileOnlyPage1ForCN.m
//  FonestockPower
//
//  Created by CooperLin on 2015/4/24.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "TempCompanyProfileOnlyPage1ForCN.h"
#import "CompanyProfilePage1Cell.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "NewCompanyProfile.h"

@interface TempCompanyProfileOnlyPage1ForCN ()<UITableViewDataSource, UITableViewDelegate, NewCompanyProfileDelegate>
{
    NSString *identSymbol;
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

@implementation TempCompanyProfileOnlyPage1ForCN

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self processLayout];
    // Do any additional setup after loading the view.
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

-(void)initView
{
    _dataModel = [FSDataModelProc sharedInstance];
    
    _mainTableView = [[UITableView alloc] init];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.allowsSelection = YES;
    _mainTableView.bounces = NO;
    [self.view addSubview:_mainTableView];
}

#pragma mark -
#pragma mark notifyData處理

- (void)notifyData {
//    [self initDate];
    [self.mainTableView reloadData];
    
}

- (void)notifyData:(id)target {
    self.dict = target;
    [self.mainTableView reloadData];
}

-(void)processLayout
{
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_mainTableView);
    
    // mainTableView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainTableView]-15-|" options:0 metrics:nil views:viewControllers]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CompanyProfilePage1";
    CompanyProfilePage1Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[CompanyProfilePage1Cell alloc] init];
    }
    if (indexPath.row == 0) {
        cell.titleLabel.text = NSLocalizedStringFromTable(@"掛牌市場", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"Exchange"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 1){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"公司地址", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"Address"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 2){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"公司電話", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"Phone"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 3){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"董事長", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"COB"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 4){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"總經理", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"Manager"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 5){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"董事長秘書", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"Secretary"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 6){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"設立日期", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"FoundDateF"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 7){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"上市日", @"Equity", nil);
        cell.detailLabel.text = [self.dict objectForKey:@"ListDateF"];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }else if(indexPath.row == 8){
        cell.titleLabel.text = NSLocalizedStringFromTable(@"員工人數", @"Equity", nil);
        cell.detailLabel.text = [NSString stringWithFormat:@"%.0f",[(NSNumber *)[self.dict objectForKey:@"Employees"]floatValue]];
        if ([cell.detailLabel.text isEqualToString:@""] || cell.detailLabel.text ==nil){
            cell.detailLabel.text = @"----";
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
