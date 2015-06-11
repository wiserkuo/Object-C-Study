//
//  FSEmergingRankViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSEmergingRankViewController.h"
#import "SKCustomTableView.h"
#import "SortingCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "StockRankOut.h"
#import "FSMarketMoverOut.h"
#import "FSEmergingObject.h"
#import "InternationalInfoObject_v1.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface FSEmergingRankViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate, SortingTableViewDelegate, FSEmergingObjectCenterDelegate>{

    SKCustomTableView *skTableView;
    SortingCustomTableView *sortTableView;
    InternationalInfoObject_v1 *inter;
    FSDataModelProc *dataModel;
    SymbolFormat1 *symbol;
    
    
    UIActionSheet *actionSheetRankLeft;
    UIActionSheet *actionSheetRankRight;
    
    NSMutableArray *verticalConstraints;
    
    NSMutableArray *fundamentalsUpDown;
    NSMutableArray *technicalArrayUpDown;
    NSMutableArray *stockName;
    NSMutableArray *fromServerData;
    NSMutableArray *fromSpecialStateIn;
    NSMutableArray *stockMuArray;
    NSMutableArray *marketBitMaskMuArray;
    NSMutableArray *marketValueMuArray;
    NSMutableArray *forTableViewTitle;
    
    
    NSMutableDictionary *dataDic;
    
    NSArray *leftBtnArrayName;
    NSArray *immediateArrayName;
    NSArray *technicalArrayName;
    NSArray *fundamentalsArrayName;
    NSArray *immediateArray;
    NSArray *technicalArray1Up;
    NSArray *technicalArray1Down;
    NSArray *technicalArray2Up;
    NSArray *technicalArray2Down;
    NSArray *fundamentalsArray1;
    NSArray *fundamentalsArray2;
    NSArray *fundamentalsArray3;
    NSArray *fundamentalsArray4;
    NSArray *fundamentalsArray5;
    
    NSTimer *timer;
    
    UIButton *leftBtnGroup;
    UIButton *rightBtnGroup;
    
    BOOL firstTap;
    BOOL changeUpDown;
    
    int changeTableViewMainName;
    int lastTime;
    int rankDirection;
    int subType;
    int saveSortingType;
    int saveDirection;
    int leftBtnGroupIndex;
    int rightBtnGroupIndex;
}

@end

@implementation FSEmergingRankViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];

	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    [self readFromPlist];
    [self actionSheetSendSocketWithBtnIndex:leftBtnGroupIndex :rightBtnGroupIndex];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [dataModel.specialStateModel setTarget:nil];
    dataModel.emergingObj.delegate = nil;
    [dataModel.emergingObj setTarget:nil];
    [timer invalidate];
    [self saveToPlist];
}

-(void)initView{
    [self setUpImageBackButton];

    dataModel = [FSDataModelProc sharedInstance];
    dataModel.emergingObj.delegate = self;
    [dataModel.specialStateModel setTarget:self];
//    [dataModel.emergingObj setTarget:self];

    inter = [[InternationalInfoObject_v1 alloc]init];
    stockMuArray = [[NSMutableArray alloc]init];
    marketValueMuArray = [[NSMutableArray alloc]init];
    marketBitMaskMuArray = [[NSMutableArray alloc]init];
    _fsemObj = [[FSEmergingObject alloc]init];
    
    changeUpDown = YES;
    self.title = NSLocalizedStringFromTable(@"興櫃排行", @"Emerging", nil);
    verticalConstraints = [[NSMutableArray alloc]init];
    leftBtnArrayName = @[NSLocalizedStringFromTable(@"即時排行", @"Emerging", @"nil"),
                         NSLocalizedStringFromTable(@"技術面排行", @"Emerging", @"nil"),
                         NSLocalizedStringFromTable(@"基本面排行", @"Emerging", @"nil")];
    immediateArrayName = @[NSLocalizedStringFromTable(@"漲幅排行", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"跌幅排行", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"成交總量", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"成交總值", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"成交價", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"振幅排行", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"成交量增", @"Emerging", @"nil")];
    
    technicalArrayName = @[NSLocalizedStringFromTable(@"漲勢排行", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"新高新低排行", @"Emerging", @"nil")];

    fundamentalsArrayName = @[NSLocalizedStringFromTable(@"營收排行", @"Emerging", @"nil"),
                             NSLocalizedStringFromTable(@"獲利能力", @"Emerging", @"nil"),
                             NSLocalizedStringFromTable(@"償債能力", @"Emerging", @"nil"),
                             NSLocalizedStringFromTable(@"經營能力", @"Emerging", @"nil"),
                             NSLocalizedStringFromTable(@"財務結構", @"Emerging", @"nil")];

    immediateArray = @[NSLocalizedStringFromTable(@"買進", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"賣出", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"成交", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"最高", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"最低", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"漲跌", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"漲幅", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"振幅", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"單量", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"總量", @"Emerging", @"nil"),
                       NSLocalizedStringFromTable(@"週轉率", @"Emerging", @"nil")];
    
    technicalArray1Up = @[NSLocalizedStringFromTable(@"5日漲幅", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"20日漲幅", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"60日漲幅", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"120日漲幅", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"240日漲幅", @"Emerging", @"nil")];
    technicalArray1Down = @[NSLocalizedStringFromTable(@"5日跌幅", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"20日跌幅", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"60日跌幅", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"120日跌幅", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"240日跌幅", @"Emerging", @"nil")];

    technicalArray2Up = @[NSLocalizedStringFromTable(@"5日新高", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"20日新高", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"60日新高", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"120日新高", @"Emerging", @"nil"),
                        NSLocalizedStringFromTable(@"240日新高", @"Emerging", @"nil")];
    technicalArray2Down = @[NSLocalizedStringFromTable(@"5日新低", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"20日新低", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"60日新低", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"120日新低", @"Emerging", @"nil"),
                          NSLocalizedStringFromTable(@"240日新低", @"Emerging", @"nil")];

    fundamentalsArray1 = @[NSLocalizedStringFromTable(@"合併營收", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"月增率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"年增率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"累計合併營收", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"累計年增率", @"Emerging", @"nil")];

    fundamentalsArray2 = @[NSLocalizedStringFromTable(@"每股營收", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"營業毛利率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"營業利益率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"稅後淨利率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"每股稅後淨利", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"股東權益報酬率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"資產報酬率", @"Emerging", @"nil")];
    
    fundamentalsArray3 = @[NSLocalizedStringFromTable(@"流動比率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"速動比率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"負債比率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"現金流量比率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"財務槓桿指數", @"Emerging", @"nil")];
    
    fundamentalsArray4 = @[NSLocalizedStringFromTable(@"應收帳款收現天數", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"平均存貨天數", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"總資產週轉率", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"淨值周轉率", @"Emerging", @"nil")];

    fundamentalsArray5 = @[NSLocalizedStringFromTable(@"每股淨值", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"股價淨值比", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"負債淨值比", @"Emerging", @"nil"),
                           NSLocalizedStringFromTable(@"長期資金適合率", @"Emerging", @"nil")];

    
    leftBtnGroup = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    leftBtnGroup.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtnGroup setTitle:@"即時排行" forState:UIControlStateNormal];
    [leftBtnGroup addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [leftBtnGroup setTag:0];
    [self.view addSubview:leftBtnGroup];
    
    rightBtnGroup = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    rightBtnGroup.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtnGroup setTitle:@"漲幅排行" forState:UIControlStateNormal];
    [rightBtnGroup addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtnGroup setTag:1];
    [self.view addSubview:rightBtnGroup];

    skTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    skTableView.translatesAutoresizingMaskIntoConstraints = NO;
    skTableView.delegate = self;
    [self.view addSubview:skTableView];
    
    sortTableView = [[SortingCustomTableView alloc]initWithfixedColumnWidth:77 mainColumnWidth:110 AndColumnHeight:44];
    sortTableView.translatesAutoresizingMaskIntoConstraints = NO;
    sortTableView.delegate = self;
    sortTableView.focuseLabel = -1;
    sortTableView.hidden = YES;
    [self.view addSubview:sortTableView];
    
    forTableViewTitle = [[NSMutableArray alloc]initWithArray:immediateArray];

    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *mainViewArray = NSDictionaryOfVariableBindings(skTableView, sortTableView, leftBtnGroup, rightBtnGroup);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBtnGroup]-2-[rightBtnGroup(leftBtnGroup)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[leftBtnGroup]" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rightBtnGroup]" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[leftBtnGroup]-2-[skTableView]|" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[leftBtnGroup]-2-[sortTableView]|" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sortTableView]|" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[skTableView]|" options:0 metrics:nil views:mainViewArray]];

    [self replaceCustomizeConstraints:constraints];
}

//specialStateIn下行電文資料回來的地方
-(void)notifyDataArrive:(NSMutableArray *)array{
    //先停掉計時, 再每分鐘送一次更新電文e
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updataMarketMover:) userInfo:nil repeats:YES];
    fromSpecialStateIn = [[NSMutableArray alloc]initWithArray:array];
    [skTableView reloadDataNoOffset];
}

//stockRankIn下行電文資料回來的地方
-(void)loadDidFinishWithData:(FSEmergingObject *)rankData{
    
    fromServerData = [[NSMutableArray alloc]initWithArray:rankData.stockRankNameWithValue];

    [sortTableView reloadDataNoOffset];
}
//push TableView cell 回來的資料 再跳轉到mainView
-(void)notifyArrive:(NSMutableArray *)dataArray{
    if ([[dataArray objectAtIndex:1] count] > 0) {

        NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbol -> IdentCode[0], symbol -> IdentCode[1], symbol -> symbol];
        [dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[identCodeSymbol]];

        PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
        FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        
        instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
//push to mainView 技術頁
        FSMainViewController *mainView = [[FSMainViewController alloc]init];
        mainView.firstLevelMenuOption = 1;
        [self.navigationController pushViewController:mainView animated:NO];
    }else{
        [dataModel.securitySearchModel setTarget:self];
        [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModel.thread withObject:symbol->symbol waitUntilDone:NO];
    }
}

-(void)btnHandler:(UIButton *)sender{
    if (sender.tag == 0) {
        int x;
        actionSheetRankLeft = [[UIActionSheet alloc]initWithTitle:@"興櫃排行" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (x = 0; x < [leftBtnArrayName count]; x++){
            NSString *title = [leftBtnArrayName objectAtIndex:x];
            [actionSheetRankLeft addButtonWithTitle:title];
        }
        [actionSheetRankLeft addButtonWithTitle:@"取消"];
        [actionSheetRankLeft setCancelButtonIndex:x];
        [actionSheetRankLeft showInView:self.view];
    }else{
        int x;
        actionSheetRankRight = [[UIActionSheet alloc]initWithTitle:@"排序方式" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        if (leftBtnGroupIndex == 0) {
            for (x = 0; x < [immediateArrayName count]; x++){
                NSString *title = [immediateArrayName objectAtIndex:x];
                [actionSheetRankRight addButtonWithTitle:title];
            }
        }else if(leftBtnGroupIndex == 1){
            for (x = 0; x < [technicalArrayName count]; x++){
                NSString *title = [technicalArrayName objectAtIndex:x];
                [actionSheetRankRight addButtonWithTitle:title];
            }
        }else{
            for (x = 0; x < [fundamentalsArrayName count]; x++){
                NSString *title = [fundamentalsArrayName objectAtIndex:x];
                [actionSheetRankRight addButtonWithTitle:title];
            }
        }
        [actionSheetRankRight addButtonWithTitle:@"取消"];
        [actionSheetRankRight setCancelButtonIndex:x];
        [actionSheetRankRight showInView:self.view];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        return;
    }
    [fromSpecialStateIn removeAllObjects];
    [fromServerData removeAllObjects];
    [timer invalidate];


    if([actionSheet isEqual:actionSheetRankLeft]){
        switch (buttonIndex) {
            case 0:
                saveSortingType = 1;
                saveDirection = 0;
                [self showWhichTableViews:NO :YES];
                [self whichTableViewTitleShouldShow:immediateArray];
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];
                break;
            case 1:
                subType = 9;
                [self whichTableViewTitleShouldShow:technicalArray1Up];
                [self sendWhichSubTypeToServer:9 :1 :1];
                [self showWhichTableViews:YES :NO];
                lastTime = 1;
                break;
            case 2:
                subType = 16;
                [self whichfundamentalsArrayShow:0];
                [self sendWhichSubTypeToServer:16 :5 :1];
                [self showWhichTableViews:YES :NO];
                lastTime = 0;
                break;
            default:
                break;
        }
        rightBtnGroupIndex = 0;
        leftBtnGroupIndex = (int)buttonIndex;
        [self changeRightBtnTitle:(int)buttonIndex];
        [leftBtnGroup setTitle:[leftBtnArrayName objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }else if([actionSheet isEqual:actionSheetRankRight] && leftBtnGroupIndex == 0 ){
        switch (buttonIndex) {
            case 0://漲跌幅 0 desc; 1 asec
                saveSortingType = 1;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 1://漲跌幅
                saveSortingType = 1;
                saveDirection = 1;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 2://總量
                saveSortingType = 3;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 3://成交金額
                saveSortingType = 5;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 4://成交價
                saveSortingType = 4;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 5://振幅
                saveSortingType = 6;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 6://昨量比
                saveSortingType = 10;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            default:break;
        }
        rightBtnGroupIndex = (int)buttonIndex;
        [rightBtnGroup setTitle:[immediateArrayName objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }else if (leftBtnGroupIndex == 1){
        switch (buttonIndex) {
            case 0:
                subType = 9;
                [self whichTableViewTitleShouldShow:technicalArray1Up];
                [self sendWhichSubTypeToServer:9 :1 :1];
                break;
            case 1:
                subType = 10;
                [self whichTableViewTitleShouldShow:technicalArray2Up];
                [self sendSubType10ToServer:1 :0];
            default:
                break;
        }
        rightBtnGroupIndex = (int)buttonIndex;
        [rightBtnGroup setTitle:[technicalArrayName objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        lastTime = 1;
        
    }else if (leftBtnGroupIndex == 2){
        switch (buttonIndex) {
            case 0:
                [self sendWhichSubTypeToServer:16 :5 :1];
                subType = 16;
                break;
            case 1:
                [self sendWhichSubTypeToServer:17 :1 :1];
                subType = 17;
                break;
            case 2:
                [self sendWhichSubTypeToServer:19 :1 :1];
                subType = 19;
                break;
            case 3:
                [self sendWhichSubTypeToServer:20 :1 :1];
                subType = 20;
                break;
            case 4:
                [self sendWhichSubTypeToServer:21 :1 :1];
                subType = 21;
                break;
            default:
                break;
        }
        rightBtnGroupIndex = (int)buttonIndex;
        [rightBtnGroup setTitle:[fundamentalsArrayName objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        lastTime = 0;
            if (rightBtnGroupIndex <= 4) {
                [self whichfundamentalsArrayShow:buttonIndex];
        }
    }
    //重設開關
    changeUpDown = YES;
    firstTap = YES;

    sortTableView.focuseLabel = 1;
    [skTableView reloadAllData];
    [sortTableView reloadAllData];
}
//狀態回復
-(void)actionSheetSendSocketWithBtnIndex:(int)leftBtnIndex :(int)rightBtnIndex{

    if (leftBtnIndex == 0 ){
        switch (rightBtnIndex) {
            case 0://漲跌幅 0 desc; 1 asec
                saveSortingType = 1;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 1://漲跌幅
                saveSortingType = 1;
                saveDirection = 1;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 2://總量
                saveSortingType = 3;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 3://成交金額
                saveSortingType = 5;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 4://成交價
                saveSortingType = 4;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 5://振幅
                saveSortingType = 6;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            case 6://昨量比
                saveSortingType = 10;
                saveDirection = 0;
                [self sendMarketMoverToServer:saveSortingType :saveDirection :0];break;
            default:break;
        }
    }else if (leftBtnIndex == 1){
        switch (rightBtnIndex) {
            case 0:
                subType = 9;
                [self whichTableViewTitleShouldShow:technicalArray1Up];
                [self sendWhichSubTypeToServer:9 :1 :1];
                break;
            case 1:
                subType = 10;
                [self whichTableViewTitleShouldShow:technicalArray2Up];
                [self sendSubType10ToServer:1 :0];
            default:
                break;
        }
        lastTime = 1;
    }else {
        switch (rightBtnIndex) {
            case 0:
                [self sendWhichSubTypeToServer:16 :5 :1];
                subType = 16;
                break;
            case 1:
                [self sendWhichSubTypeToServer:17 :1 :1];
                subType = 17;
                break;
            case 2:
                [self sendWhichSubTypeToServer:19 :1 :1];
                subType = 19;
                break;
            case 3:
                [self sendWhichSubTypeToServer:20 :1 :1];
                subType = 20;
                break;
            case 4:
                [self sendWhichSubTypeToServer:21 :1 :1];
                subType = 21;
                break;
            default:
                break;
        }
        lastTime = 0;
        if (rightBtnIndex <= 4) {
            [self whichfundamentalsArrayShow:rightBtnIndex];
        }
    }
    sortTableView.focuseLabel = 1;
//    [skTableView reloadAllData];
//    [sortTableView reloadAllData];
}
-(void)changeRightBtnTitle:(int)buttonIndex{
    switch (buttonIndex) {
        case 0:[rightBtnGroup setTitle:[immediateArrayName objectAtIndex:0] forState:UIControlStateNormal];
            break;
        case 1:[rightBtnGroup setTitle:[technicalArrayName objectAtIndex:0] forState:UIControlStateNormal];
            break;
        case 2:[rightBtnGroup setTitle:[fundamentalsArrayName objectAtIndex:0] forState:UIControlStateNormal];
            break;
        default:break;
    }
}
-(void)whichTableViewTitleShouldShow:(NSArray *)array{
    forTableViewTitle = [NSMutableArray arrayWithArray:array];
}
-(void)whichfundamentalsArrayShow:(NSInteger )buttonIndex{
    switch (buttonIndex) {
        case 0:fundamentalsUpDown = [NSMutableArray arrayWithArray:fundamentalsArray1];
            break;
        case 1:fundamentalsUpDown = [NSMutableArray arrayWithArray:fundamentalsArray2];
            break;
        case 2:fundamentalsUpDown = [NSMutableArray arrayWithArray:fundamentalsArray3];
            break;
        case 3:fundamentalsUpDown = [NSMutableArray arrayWithArray:fundamentalsArray4];
            break;
        case 4:fundamentalsUpDown = [NSMutableArray arrayWithArray:fundamentalsArray5];
            break;
        default:break;
    }
    [fundamentalsUpDown replaceObjectAtIndex:0 withObject:[[fundamentalsUpDown objectAtIndex:0] stringByAppendingString:@"⬇︎"]];
    forTableViewTitle = [NSMutableArray arrayWithArray:fundamentalsUpDown];

}

-(void)showWhichTableViews:(BOOL)sk :(BOOL)sort{
    skTableView.hidden = sk;
    sortTableView.hidden = sort;
}

-(void)labelTap:(UILabel *)label{
    [fromServerData removeAllObjects];
    //supType = 9 ; Down 跌幅 0 遞增, Up 漲幅 1 遞減
    //subType = 10 ; Down 新低 1 新低, Up 新高 0 新高
    switch (subType) {
        case 9:
            if (lastTime == label.tag) {
                if (changeUpDown) {
                    rankDirection = 0;
                    forTableViewTitle = [NSMutableArray arrayWithArray:technicalArray1Down];
                }else{
                    rankDirection = 1;
                    forTableViewTitle = [NSMutableArray arrayWithArray:technicalArray1Up];
                }
            }else{
                rankDirection = 1;
                forTableViewTitle = [NSMutableArray arrayWithArray:technicalArray1Up];
            }
            [self sendWhichSubTypeToServer:9 :label.tag :rankDirection];
            break;
        case 10:
            if (lastTime == label.tag) {
                if (changeUpDown) {
                    rankDirection = 1;
                    forTableViewTitle = [NSMutableArray arrayWithArray:technicalArray2Down];
                }else{
                    rankDirection = 0;
                    forTableViewTitle = [NSMutableArray arrayWithArray:technicalArray2Up];
                }
            }else{
                rankDirection = 0;
                forTableViewTitle = [NSMutableArray arrayWithArray:technicalArray2Up];
            }
            [self sendSubType10ToServer:label.tag:rankDirection];
            break;
        case 16:
            [self addDirection:fundamentalsArray1 :(int)label.tag];
            switch (label.tag) {
                case 1:[self sendWhichSubTypeToServer:16 :5:rankDirection];break;
                case 2:[self sendWhichSubTypeToServer:16 :3:rankDirection];break;
                case 3:[self sendWhichSubTypeToServer:16 :4:rankDirection];break;
                case 4:[self sendWhichSubTypeToServer:16 :10:rankDirection];break;
                case 5:[self sendWhichSubTypeToServer:16 :9:rankDirection];break;
                default: break;
            }
            break;
        case 17:
            [self addDirection:fundamentalsArray2 :(int)label.tag];
            [self sendWhichSubTypeToServer:17 :label.tag:rankDirection];
            break;
        case 19:
            [self addDirection:fundamentalsArray3 :(int)label.tag];
            [self sendWhichSubTypeToServer:19 :label.tag:rankDirection];
            break;
        case 20:
            [self addDirection:fundamentalsArray4 :(int)label.tag];
            [self sendWhichSubTypeToServer:20 :label.tag :rankDirection];
            break;
        case 21:
            [self addDirection:fundamentalsArray5 :(int)label.tag];
            [self sendWhichSubTypeToServer:21 :label.tag :rankDirection];
            break;
        default:
            break;
    }
    //改變TableView Title 的上下
    if (changeUpDown) {
        changeUpDown = NO;
    }else{
        changeUpDown = YES;
    }
    sortTableView.focuseLabel = (int)label.tag;
    lastTime = (int)label.tag;
}

-(void)addDirection:(NSArray *)rankArray :(int)tap{
    //@"⬆︎"@"⬇︎"
    //0 遞增 ; 1 遞減
    NSString *upDown;
    int indexFindValue = tap - 1;
    
    //第 0 筆
    if (tap == 1) {
        //第一次點擊 由下變成上, 第二次由上變下
        if (firstTap) {
            if (tap != lastTime) {
                upDown = [[fundamentalsUpDown objectAtIndex:indexFindValue] stringByReplacingOccurrencesOfString:@"⬇︎" withString:@"⬆︎"];
                rankDirection = 0;
            }else{
                upDown = [[fundamentalsUpDown objectAtIndex:indexFindValue] stringByReplacingOccurrencesOfString:@"⬆︎" withString:@"⬇︎"];
                rankDirection = 1;
            }
            [fundamentalsUpDown replaceObjectAtIndex:indexFindValue withObject:upDown];
            firstTap = NO;
        }else{
        //第二次點擊 或 從別的按回第 0 筆 要顯示下, 然後第二次選擇由下變上, 再選一次由上變下
            if (tap != lastTime) {
                fundamentalsUpDown = [NSMutableArray arrayWithArray:rankArray];
                [fundamentalsUpDown replaceObjectAtIndex:indexFindValue withObject:[[fundamentalsUpDown objectAtIndex:indexFindValue] stringByAppendingString:@"⬇︎"]];
                changeUpDown = YES;
                rankDirection = 1;
            }else{
                if (changeUpDown) {
                    upDown = [[fundamentalsUpDown objectAtIndex:indexFindValue] stringByReplacingOccurrencesOfString:@"⬇︎" withString:@"⬆︎"];
                    rankDirection = 0;
                }else{
                    upDown = [[fundamentalsUpDown objectAtIndex:indexFindValue] stringByReplacingOccurrencesOfString:@"⬆︎" withString:@"⬇︎"];
                    rankDirection = 1;
                }
                [fundamentalsUpDown replaceObjectAtIndex:indexFindValue withObject:upDown];
            }
        }
    // 其他筆
    }else if(tap > 1){
        //第一次為下, 第二次由下變上, 再選一次由上變下
        if (tap != lastTime) {
            fundamentalsUpDown = [NSMutableArray arrayWithArray:rankArray];
            [fundamentalsUpDown replaceObjectAtIndex:indexFindValue withObject:[[fundamentalsUpDown objectAtIndex:indexFindValue] stringByAppendingString:@"⬇︎"]];
            changeUpDown = YES;
            rankDirection = 1;
        }else{
            if (changeUpDown) {
                upDown = [[fundamentalsUpDown objectAtIndex:indexFindValue] stringByReplacingOccurrencesOfString:@"⬇︎" withString:@"⬆︎"];
                rankDirection = 0;
            }else{
                upDown = [[fundamentalsUpDown objectAtIndex:indexFindValue] stringByReplacingOccurrencesOfString:@"⬆︎" withString:@"⬇︎"];
                rankDirection = 1;
            }
            [fundamentalsUpDown replaceObjectAtIndex:indexFindValue withObject:upDown];
        }
    }
    [self whichTableViewTitleShouldShow:fundamentalsUpDown];

}
-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([fromSpecialStateIn count] > 0) {
        //market mover
        symbol = [[SymbolFormat1 alloc]init];
        symbol = [[fromSpecialStateIn objectAtIndex:indexPath.row] objectAtIndex:0];
        label.text = symbol -> fullName;
    }else {
        _fsemObj = [fromServerData objectAtIndex:indexPath.row];
        label.text = _fsemObj.stockRankName;

    }
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([fromSpecialStateIn count] > 0 ) {
        marketBitMaskMuArray = [[fromSpecialStateIn objectAtIndex:indexPath.row] objectAtIndex:2];
        marketValueMuArray = [[fromSpecialStateIn objectAtIndex:indexPath.row] objectAtIndex:3];
        float buy = [self searchArrayWithBitMask:5];
        float sell = [self searchArrayWithBitMask:6];
        float current = [self searchArrayWithBitMask:2];
        float reference = [self searchArrayWithBitMask:3];
        float highest = [self searchArrayWithBitMask:17];
        float lowest = [self searchArrayWithBitMask:18];
        float change = current - reference;
        float gains = ((current - reference) / reference * 10000) / 100;
        float amplitude = ((highest - lowest) / reference * 10000) / 100;
        float unit = [self searchArrayWithBitMask:44];
        float total = [self searchArrayWithBitMask:4];
        float issuadShared = [self searchArrayWithBitMask:45];
        float turnover = (total / issuadShared) *100000;
        switch (columnIndex) {
            case 0://買進
                label.text = [NSString stringWithFormat:@"%.2f", buy];
                label.textColor = [_fsemObj compareTwoValue:buy :reference];
                break;
            case 1://賣出
                label.text = [NSString stringWithFormat:@"%.2f", sell];
                label.textColor = [_fsemObj compareTwoValue:sell :reference];
                break;
            case 2://成交
                label.text = [NSString stringWithFormat:@"%.2f", current];
                label.textColor = [_fsemObj compareTwoValue:current :reference];
                break;
            case 3://最高
                label.text = [NSString stringWithFormat:@"%.2f", highest];
                label.textColor = [_fsemObj compareTwoValue:highest :reference];
                break;
            case 4://最低
                label.text = [NSString stringWithFormat:@"%.2f", lowest];
                label.textColor = [_fsemObj compareTwoValue:lowest :reference];
                break;
            case 5://漲跌
                label.text = [_fsemObj stringWithMarketMover:change sign:YES];
                label.textColor = [inter compareToZero:change];
                break;
            case 6://漲幅
                if (reference == 0) {
                    label.text = [NSString stringWithFormat:@"----"];
                }else{
                    label.text = [_fsemObj stringWithMarketMoverPercent:gains sign:YES];
                }
                label.textColor = [inter compareToZero:gains];
                break;
            case 7://振幅
                label.textColor = [UIColor purpleColor];
                if (reference == 0) {
                    label.text = [NSString stringWithFormat:@"----"];
                    label.textColor = [UIColor blackColor];
                }else{
                    label.text = [_fsemObj stringWithOperatingMarginByValue:amplitude Sign:NO];
                }
                break;
            case 8://單量
                label.textColor = [UIColor purpleColor];
                if (unit == 0) {
                    label.text = [NSString stringWithFormat:@"----"];
                    label.textColor = [UIColor blackColor];
                }else{
                    label.text = [NSString stringWithFormat:@"%.0f", unit];
                }
                break;
            case 9://總量
                label.textColor = [UIColor purpleColor];
                if (total == 0) {
                    label.text = [NSString stringWithFormat:@"----"];
                    label.textColor = [UIColor blueColor];
                }else{
                    label.text = [NSString stringWithFormat:@"%.0f", total];
                }
                break;
            case 10://週轉率
                if (turnover == 0 || issuadShared == 0) {
                    label.text = [NSString stringWithFormat:@"----"];
                    label.textColor = [UIColor blackColor];
                }else{
                    label.text = [NSString stringWithFormat:@"%.2f%%", turnover];
                    label.textColor = [UIColor blueColor];
                }
                break;
            default:break;
        }
    }else{
        _fsemObj = [fromServerData objectAtIndex:indexPath.row];
        
        switch (columnIndex) {
            case 0:
                label.text = _fsemObj.column1;
                if (subType == 17 || subType == 20 || subType == 21) {
                    label.textColor = [UIColor blueColor];
                }else{
                    label.textColor = [inter compareToZero:[(NSNumber *)_fsemObj.column1 floatValue]];
                }
                break;
            case 1:
                label.text = _fsemObj.column2;
                if (subType == 20) {
                    label.textColor = [UIColor blueColor];
                }else{
                    label.textColor = [inter compareToZero:[(NSNumber *)_fsemObj.column2 floatValue]];
                }
                break;
            case 2:
                label.text = _fsemObj.column3;
                label.textColor = [inter compareToZero:[(NSNumber *)_fsemObj.column3 floatValue]];
                break;
            case 3:
                label.text = _fsemObj.column4;
                label.textColor = [inter compareToZero:[(NSNumber *)_fsemObj.column4 floatValue]];
                break;
            case 4:
                label.text = _fsemObj.column5;
                if (subType == 17 || subType == 19) {
                    label.textColor = [UIColor blueColor];
                }else{
                    label.textColor = [inter compareToZero:[(NSNumber *)_fsemObj.column5 floatValue]];
                }
                break;
            case 5:
                label.text = _fsemObj.column6;
                label.textColor = [inter compareToZero:[(NSNumber *)_fsemObj.column6 floatValue]];
                break;
            case 6:
                label.text = _fsemObj.column7;
                label.textColor = [inter compareToZero:[(NSNumber *)_fsemObj.column7 floatValue]];
                break;
            default:break;
        }
    }
}

-(NSArray *)columnsInFixedTableView{

    return @[NSLocalizedStringFromTable(@"名稱", @"Emerging", @"nil")];
}

-(NSArray *)columnsInMainTableView{
    return forTableViewTitle;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([fromSpecialStateIn count] > 0) {
        return [fromSpecialStateIn count];
    }else{
        return [fromServerData count];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if ([fromSpecialStateIn count] > 0) {
        symbol = [[fromSpecialStateIn objectAtIndex:indexPath.row] objectAtIndex:0];
    }else{
        symbol = [[fromServerData objectAtIndex:indexPath.row]securities];
    }
    
    [dataModel.securitySearchModel setTarget:self];
    [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModel.thread withObject:symbol -> symbol waitUntilDone:NO];
}

-(void)sendWhichSubTypeToServer:(UInt8)s :(UInt8)orderByFiledId :(UInt8)direction{
     //subType 9 = 漲勢排行, sectorCount 1 = 總共 1 筆, sectorId 599 = 興櫃 rootId, orderbyfieldid 1 = 5日漲勢, direction 0 = 遞增排序(1, 遞減), requestcount 10 = 要求 10 筆
    if (orderByFiledId > 0) {
        StockRankOut *rankOut = [[StockRankOut alloc]initWithSubType:s SectorCount:1 SectorId:599 orderByFiledId:orderByFiledId direction:direction requestCount:50];
        [FSDataModelProc sendData:self WithPacket:rankOut];
    }else{
        return;
    }
}
-(void)sendSubType10ToServer:(UInt8)parameter1 :(UInt8)direction{
    //subType 10 = 新高新低排行, sectorCount 1 = 總共 1 筆, sectorId 599 = 興櫃 rootId, direction 0 = 遞增排序(1, 遞減), parameter 1 = 創5日新高 / 創5日新低 (direction= 0 為創5日新高, direction=1 創5日新低), requestcount 10 = 要求 10 筆
    if (parameter1 > 0) {
        StockRankOut *rankOut = [[StockRankOut alloc]initWithSubType:10 SectorCount:1 SectorId:599 direction:direction parameter1:parameter1 requestCount:50];
        [FSDataModelProc sendData:self WithPacket:rankOut];
    }else{
        return;
    }
}
//每分鐘送一次更新電文
-(void)updataMarketMover:(NSTimer *)incomingTimer{
    FSMarketMoverOut *marketMoverPacket = [[FSMarketMoverOut alloc]initWithSortingType:saveSortingType direction:saveDirection update:1];
    [FSDataModelProc sendData:self WithPacket:marketMoverPacket];
}
-(void)sendMarketMoverToServer:(UInt8)sorTingType :(UInt8)direction :(UInt8)update{
    //sorTingType = 查 wiki type_9:_Market_Mover , 排序定義
    //direction = 0 desc; 1 asec
    
    FSMarketMoverOut *marketMoverPacket = [[FSMarketMoverOut alloc]initWithSortingType:sorTingType direction:direction update:update];
    [FSDataModelProc sendData:self WithPacket:marketMoverPacket];
}
-(float)searchArrayWithBitMask:(int)value{
    int x = 0;
    
    for (int i = 0; i < [marketBitMaskMuArray count]; i++){
        if (value == [(NSNumber *)[marketBitMaskMuArray objectAtIndex:i]intValue]) {
            x = i;
        }
    }
    float str = [(NSNumber *)[marketValueMuArray objectAtIndex:x]floatValue];
    return str;
    
}
-(void)saveToPlist{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"SaveEmergingRank.plist"]];
    dataDic = [[NSMutableDictionary alloc]init];
    [dataDic setObject:[NSNumber numberWithInt:leftBtnGroupIndex] forKey:@"leftBtnGroupIndex"];
    [dataDic setObject:[NSNumber numberWithInt:rightBtnGroupIndex] forKey:@"rightBtnGroupIndex"];
    
    [dataDic writeToFile:path atomically:YES];

}
-(void)readFromPlist{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"SaveEmergingRank.plist"]];
    dataDic = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (dataDic) {
        leftBtnGroupIndex = [(NSNumber *)[dataDic objectForKey:@"leftBtnGroupIndex"]intValue];
        rightBtnGroupIndex = [(NSNumber *)[dataDic objectForKey:@"rightBtnGroupIndex"]intValue];

        if (leftBtnGroupIndex == 0) {
            sortTableView.hidden = YES;
            skTableView.hidden = NO;
            [rightBtnGroup setTitle:[immediateArrayName objectAtIndex:rightBtnGroupIndex] forState:UIControlStateNormal];
        }else if(leftBtnGroupIndex == 1){
            [rightBtnGroup setTitle:[technicalArrayName objectAtIndex:rightBtnGroupIndex] forState:UIControlStateNormal];
            skTableView.hidden = YES;
            sortTableView.hidden = NO;
        }else{
            [rightBtnGroup setTitle:[fundamentalsArrayName objectAtIndex:rightBtnGroupIndex] forState:UIControlStateNormal];
            skTableView.hidden = YES;
            sortTableView.hidden = NO;
        }
        [leftBtnGroup setTitle:[leftBtnArrayName objectAtIndex:leftBtnGroupIndex] forState:UIControlStateNormal];
    }else{
        leftBtnGroupIndex = 0;
        rightBtnGroupIndex = 0;

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end