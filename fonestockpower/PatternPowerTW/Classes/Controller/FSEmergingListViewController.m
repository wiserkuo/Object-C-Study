//
//  ViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/2.
//  Copyright (c) 2014年 Michael.Hsieh. All rights reserved.
//

#import "FSEmergingListViewController.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "FSEmergingObject.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SKCustomTableView.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface FSEmergingListViewController ()<SKCustomTableViewDelegate,DataArriveProtocol>
{
    SKCustomTableView *emergingTableView;
    FSEmergingObject *EmergingStockObject;
    FSEmergingObjectRegisterStock *registerObj;
    FSEmergingObjectApproveStock *approveObj;
    FSEmergingObjectRejectStock *rejectObj;
    FSDataModelProc *dataModel;
    UIButton *register_Button;
    UIButton *approve_Button;
    UIButton *reject_Button;
    
    NSMutableDictionary *timeData;

    NSMutableArray *verticalConstraints;
    NSMutableArray *registerStockArray;
    NSMutableArray *emergingStockArray;
    
    NSArray *paths;

    NSString *documentsDirectory;
    NSString *filePath;
    NSString *codeData;
    NSString *timestamp;
    NSString *timePath;
    NSString *stockFullName;
    
    NSFileManager *fileManager;
    
    NSData *res;
    
    int calCount;
    int codeDataInt;

}
@end

@implementation FSEmergingListViewController

-(void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpImageBackButton];
    [self initKissParser];
    [self initView];
    [self initTableView];
}

-(void)initKissParser{
    res = [[NSData alloc]init];
    EmergingStockObject = [[FSEmergingObject alloc]init];
    emergingStockArray = [[NSMutableArray alloc]init];
    dataModel = [FSDataModelProc sharedInstance];

    NSString *timeFilePath = [self findPath:@"time.plist"];
    timeData = [[NSMutableDictionary alloc]initWithContentsOfFile:timeFilePath];
    fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:timeFilePath]) {
        timePath = [timeData objectForKey:@"TIMEPATH"];
    }else{
        timePath = @"NULL";
    }
//    NSString *pathUrl = @"http://kqstock.fonestock.com:2172/query/emg_cal.cgi?time_stamp=2014-09-05T14:59:21";
    NSString *pathUrl = [NSString stringWithFormat:@"http://kqstock.fonestock.com:2172/query/emg_cal.cgi?time_stamp=%@", timePath];
    res = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:pathUrl]] returningResponse:nil error:nil];
    DDXMLDocument *xmlCode = [[DDXMLDocument alloc]initWithData:res options:0 error:nil];
    
//    parser code
    NSArray *code = [xmlCode nodesForXPath:@"//code" error:nil];
    DDXMLDocument *codeEle = [code objectAtIndex:0];
    codeData = [codeEle stringValue];
    
    if ([codeData isEqualToString:@"1"]) {
        [self loadToXMLFile];
    }else{
        [self saveToXMLFile];
    }
    [self parseXML:res];
    [self registerParseXML:res];
}
-(void)parseXML:(NSData *)data{
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc]initWithData:data options:0 error:nil];
    
//    parser time_stamp
    if ([codeData isEqualToString:@"0"]) {
        
        NSArray *time_stamp = [xmlDoc nodesForXPath:@"//time_stamp" error:nil];
        DDXMLDocument *timeEle = [time_stamp objectAtIndex:0];
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        NSString *timeFilePath = [documentsDirectory stringByAppendingPathComponent:@"/time.plist"];
        timeData = [[NSMutableDictionary alloc] init];
        [timeData setValue:[NSString stringWithFormat:@"%@", [timeEle stringValue]] forKey:@"TIMEPATH"];
        [timeData writeToFile:timeFilePath atomically: YES];
    }
}
-(void)registerParseXML:(NSData *)data{
    DDXMLDocument *registerDoc = [[DDXMLDocument alloc]initWithData:data options:0 error:nil];
    NSArray *registerStock = [registerDoc nodesForXPath:@"//register/stock" error:nil];

    for (DDXMLElement *cal in registerStock) {
        DDXMLElement *nameEle = [cal elementForName:@"name"];
        DDXMLElement *symbolEle = [cal elementForName:@"symbol"];
        DDXMLElement *capEle = [cal elementForName:@"cap"];
        DDXMLElement *secEle = [cal elementForName:@"sec"];
        DDXMLElement *reg_dateEle = [cal elementForName:@"reg_date"];
        DDXMLElement *brokerEle = [cal elementForName:@"broker"];
        DDXMLElement *priceEle = [cal elementForName:@"price"];

        registerObj = [[FSEmergingObjectRegisterStock alloc]init];
        registerObj.registerStockName = [nameEle stringValue];
        registerObj.registerStockSymbol = [symbolEle stringValue];
        registerObj.registerStockCap = [capEle stringValue];
        registerObj.registerStockSec = [secEle stringValue];
        registerObj.registerStockReg_date = [reg_dateEle stringValue];
        registerObj.registerStockBroker = [brokerEle stringValue];
        registerObj.registerStockPrice = [priceEle stringValue];
        
        [emergingStockArray addObject:registerObj];
    }
}
//parser app_approve/stock
-(void)approveParseXML:(NSData *)data{
    
    DDXMLDocument *approveDoc = [[DDXMLDocument alloc]initWithData:data options:0 error:nil];
    NSArray *app_approveStock = [approveDoc nodesForXPath:@"//app_approve/stock" error:nil];
    for (DDXMLElement *cal in app_approveStock) {
        DDXMLElement *nameEle = [cal elementForName:@"name"];
        DDXMLElement *symbolEle = [cal elementForName:@"symbol"];
        DDXMLElement *capEle = [cal elementForName:@"cap"];
        DDXMLElement *secEle = [cal elementForName:@"sec"];
        DDXMLElement *toEle = [cal elementForName:@"to"];
        DDXMLElement *commEle = [cal elementForName:@"comm"];
        DDXMLElement *boardEle = [cal elementForName:@"board"];
        DDXMLElement *burEle = [cal elementForName:@"bur"];
        DDXMLElement *list_dateEle = [cal elementForName:@"list_date"];
        DDXMLElement *brokerEle = [cal elementForName:@"broker"];
        DDXMLElement *priceEle = [cal elementForName:@"price"];

        approveObj = [[FSEmergingObjectApproveStock alloc]init];
        approveObj.approveStockName = [nameEle stringValue];
        approveObj.approveStockSymbol = [symbolEle stringValue];
        approveObj.approveStockCap = [capEle stringValue];
        approveObj.approveStockSec = [secEle stringValue];
        approveObj.approveStockTo = [toEle stringValue];
        approveObj.approveStockComm = [commEle stringValue];
        approveObj.approveStockBoard = [boardEle stringValue];
        approveObj.approveStockBur = [burEle stringValue];
        approveObj.approveStockList_date = [list_dateEle stringValue];
        approveObj.approveStockBroker = [brokerEle stringValue];
        approveObj.approveStockPrice = [priceEle stringValue];

        [emergingStockArray addObject:approveObj];
    }
}
-(void)rejectParseXML:(NSData *)data{

    DDXMLDocument *rejectDoc = [[DDXMLDocument alloc]initWithData:data options:0 error:nil];

    NSArray *app_rejectStock = [rejectDoc nodesForXPath:@"//app_reject/stock" error:nil];
    for (DDXMLElement *cal in app_rejectStock) {
        DDXMLElement *nameEle = [cal elementForName:@"name"];
        DDXMLElement *symbolEle = [cal elementForName:@"symbol"];
        DDXMLElement *capEle = [cal elementForName:@"cap"];
        DDXMLElement *secEle = [cal elementForName:@"sec"];
        DDXMLElement *toEle = [cal elementForName:@"to"];
        DDXMLElement *resEle = [cal elementForName:@"res"];
        DDXMLElement *brokerEle = [cal elementForName:@"broker"];
        DDXMLElement *rej_dateEle = [cal elementForName:@"rej_date"];

        rejectObj = [[FSEmergingObjectRejectStock alloc]init];
        rejectObj.rejectStockName = [nameEle stringValue];
        rejectObj.rejectStockSymbol = [symbolEle stringValue];
        rejectObj.rejectStockCap = [capEle stringValue];
        rejectObj.rejectStockSec = [secEle stringValue];
        rejectObj.rejectStockTo = [toEle stringValue];
        rejectObj.rejectStockRes = [resEle stringValue];
        rejectObj.rejectStockBroker = [brokerEle stringValue];
        rejectObj.rejectStockRej_date = [rej_dateEle stringValue];
        
        [emergingStockArray addObject:rejectObj];
    }
}
-(void)saveToXMLFile{
    filePath = [self findPath:@"emg_calender.xml"];
    fileManager = [NSFileManager defaultManager];
    
    [res writeToFile:filePath atomically:YES];
}
-(void)loadToXMLFile{
    filePath = [self findPath:@"emg_calender.xml"];
    fileManager = [NSFileManager defaultManager];
    res = [[NSData alloc]initWithContentsOfFile:filePath];

}
-(NSString *)loadToXMLTimePlist:(NSString *)loadTimePath{
    NSString *timeFilePath = [self findPath:@"time.plist"];
    
    timeData = [[NSMutableDictionary alloc]initWithContentsOfFile:timeFilePath];
    fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:timeFilePath]) {
        loadTimePath = [timeData objectForKey:@"TIMEPATH"];
    }else{
        loadTimePath = @"NULL";
    }
    return loadTimePath;
}
-(NSString *)findPath:(NSString *)fileName{
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *timeFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    return timeFilePath;
}
-(void)initView{
    verticalConstraints = [[NSMutableArray alloc]init];
    self.title = @"興櫃行事曆";
    
    register_Button = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    register_Button.translatesAutoresizingMaskIntoConstraints = NO;
    register_Button.selected = YES;
    [register_Button setTitle:@"登錄興櫃" forState:UIControlStateNormal];
    [register_Button addTarget:self action:@selector(approveHandler:) forControlEvents:UIControlEventTouchUpInside];
    [register_Button setTag:1];
    [self.view addSubview:register_Button];
    
    approve_Button = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    approve_Button.translatesAutoresizingMaskIntoConstraints = NO;
    [approve_Button setTitle:@"準上市櫃" forState:UIControlStateNormal];
    [approve_Button addTarget:self action:@selector(approveHandler:) forControlEvents:UIControlEventTouchUpInside];
    [approve_Button setTag:2];
    [self.view addSubview:approve_Button];
    
    reject_Button = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    reject_Button.translatesAutoresizingMaskIntoConstraints = NO;
    [reject_Button setTitle:@"申請退件" forState:UIControlStateNormal];
    [reject_Button addTarget:self action:@selector(approveHandler:) forControlEvents:UIControlEventTouchUpInside];
    [reject_Button setTag:3];
//    reject_Button.backgroundColor = [UIColor blueColor];
    [self.view addSubview:reject_Button];
    
    [self.view setNeedsUpdateConstraints];
}
-(void)initTableView{
    emergingTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:77 mainColumnWidth:140 AndColumnHeight:44];
    emergingTableView.translatesAutoresizingMaskIntoConstraints = NO;

    emergingTableView.delegate = self;

    [self.view addSubview:emergingTableView];
}
-(void)approveHandler:(UIButton *)sender{
    [emergingStockArray removeAllObjects];
    UIButton *header_Button = (UIButton *)sender;

    register_Button.selected = NO;
    approve_Button.selected = NO;
    reject_Button.selected = NO;
    sender.selected = YES;
    switch (header_Button.tag) {
        case 1:
            [self registerParseXML:res];break;
        case 2:
            [self approveParseXML:res];break;
        case 3:
            [self rejectParseXML:res];break;
        default:break;
    }
    [emergingTableView reloadAllData];

}
-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    
    NSDictionary *mainView = NSDictionaryOfVariableBindings(register_Button, approve_Button, reject_Button, emergingTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[register_Button][approve_Button(register_Button)][reject_Button(register_Button)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:mainView]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[emergingTableView]|" options:0 metrics:nil views:mainView]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[register_Button]-2-[emergingTableView]|" options:0 metrics:nil views:mainView]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[emergingStockArray objectAtIndex:indexPath.row] isKindOfClass:[FSEmergingObjectRegisterStock class]]) {
        registerObj = [emergingStockArray objectAtIndex:indexPath.row];
        label.text = registerObj.registerStockName;
    }
    else if ([[emergingStockArray objectAtIndex:indexPath.row] isKindOfClass:[FSEmergingObjectApproveStock class]]) {
        approveObj = [emergingStockArray objectAtIndex:indexPath.row];
        label.text = approveObj.approveStockName;
    }
    else {
        rejectObj = [emergingStockArray objectAtIndex:indexPath.row];
        label.text = rejectObj.rejectStockName;
    }
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor colorWithRed:245.0f/255.0f green:125.0f/255.0f blue:5.0f/255.0f alpha:1.0f];
    
}
-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.textAlignment = NSTextAlignmentCenter;
//    登入興櫃
    if ([[emergingStockArray objectAtIndex:indexPath.row] isKindOfClass:[FSEmergingObjectRegisterStock class]]) {
        registerObj = [emergingStockArray objectAtIndex:indexPath.row];
        switch (columnIndex) {
            case 0:
                label.text = registerObj.registerStockCap;break;
            case 1:
                label.text = registerObj.registerStockSec;break;
            case 2:
                label.text = registerObj.registerStockReg_date;break;
            case 3:
                label.text = registerObj.registerStockBroker;break;
            case 4:
                label.text = registerObj.registerStockPrice;break;
            default:break;
        }
    }
//    準上市櫃
    else if ([[emergingStockArray objectAtIndex:indexPath.row] isKindOfClass:[FSEmergingObjectApproveStock class]]) {
        approveObj = [emergingStockArray objectAtIndex:indexPath.row];
        switch (columnIndex) {
            case 0:
                label.text = approveObj.approveStockCap;break;
            case 1:
                label.text = approveObj.approveStockSec;break;
            case 2:
                label.text = approveObj.approveStockList_date;break;
            case 3:
                label.text = approveObj.approveStockTo;break;
            case 4:
                label.text = approveObj.approveStockComm;break;
            case 5:
                label.text = approveObj.approveStockBoard;break;
            case 6:
                label.text = approveObj.approveStockBur;break;
            case 7:
                label.text = approveObj.approveStockList_date;break;
            case 8:
                label.text = approveObj.approveStockBroker;break;
            case 9:
                label.text = approveObj.approveStockPrice;break;
            default:break;
        }
    }
//    申請退件
    else {
        rejectObj = [emergingStockArray objectAtIndex:indexPath.row];
        switch (columnIndex) {
            case 0:
                label.text = rejectObj.rejectStockCap;break;
            case 1:
                label.text = rejectObj.rejectStockSec;break;
            case 2:
                label.text = rejectObj.rejectStockTo;break;
            case 3:
                label.text = rejectObj.rejectStockRes;break;
            case 4:
                label.text = rejectObj.rejectStockBroker;break;
            case 5:
                label.text = rejectObj.rejectStockRej_date;break;
            default:break;
        }
    }
    label.textAlignment = NSTextAlignmentRight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"名稱", @"Emerging", @"nil")];
}

-(NSArray *)columnsInMainTableView{
    if (register_Button.selected == YES){
        return @[NSLocalizedStringFromTable(@"資本額", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"產業類別", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"登錄日期", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"推薦卷商", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"認購價", @"Emerging", @"nil"),];
    }else if (approve_Button.selected == YES){
        return @[NSLocalizedStringFromTable(@"資本額", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"產業類別", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"申請上市櫃", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"審議會通過", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"證期會通過", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"掛牌日期", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"主辦卷商", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"承銷價", @"Emerging", @"nil"),];
    }else{
        return @[NSLocalizedStringFromTable(@"資本額", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"產業類別", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"上市櫃退件", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"原因", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"主辦卷商", @"Emerging", @"nil"),
                 NSLocalizedStringFromTable(@"撤回日期", @"Emerging", @"nil"),];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [emergingStockArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *symbol;
    if ([[emergingStockArray objectAtIndex:indexPath.row] isKindOfClass:[FSEmergingObjectRegisterStock class]]) {
        registerObj = [emergingStockArray objectAtIndex:indexPath.row];
        symbol = registerObj.registerStockSymbol;
        stockFullName = registerObj.registerStockName;
    }
    else if ([[emergingStockArray objectAtIndex:indexPath.row] isKindOfClass:[FSEmergingObjectApproveStock class]]) {
        approveObj = [emergingStockArray objectAtIndex:indexPath.row];
        symbol = approveObj.approveStockSymbol;
        stockFullName = approveObj.approveStockName;
    }
    else {
        rejectObj = [emergingStockArray objectAtIndex:indexPath.row];
        symbol = rejectObj.rejectStockSymbol;
        stockFullName = rejectObj.rejectStockName;
    }

    [dataModel.securitySearchModel setTarget:self];
    [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModel.thread withObject:symbol waitUntilDone:NO];

}
-(void)notifyArrive:(NSMutableArray *)dataArray{
    if ([dataArray count] > 2) {
        FSMainViewController *mainView = [[FSMainViewController alloc]init];
        
        NSString *identCodeSymbol = [NSString stringWithFormat:@"%@ %@", [[dataArray objectAtIndex:2]objectAtIndex:0], [[dataArray objectAtIndex:1]objectAtIndex:0]];
        [dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[identCodeSymbol]];
        
        PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
        FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        
        instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
//        push to mainView 即時
        mainView.firstLevelMenuOption = 0;
        [self.navigationController pushViewController:mainView animated:NO];
    }else{
        [dataModel.securitySearchModel setTarget:self];
        [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModel.thread withObject:stockFullName waitUntilDone:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
