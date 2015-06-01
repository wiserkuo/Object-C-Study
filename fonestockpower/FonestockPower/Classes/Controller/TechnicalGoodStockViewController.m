//
//  TechnicalGoodStockViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Restart by Michael.Hsieh on 14/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "TechnicalGoodStockViewController.h"
#import "SortingCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "StockRankOut.h"
#import "InternationalInfoObject_v1.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSEmergingObject.h"
#import "FSTechnicalTableViewCell.h"

@interface TechnicalGoodStockViewController (){
    
    FSUIButton * searchKeyBtn;
    FSUIButton * groupBtn;
    SortingCustomTableView *mainTableView;
    InternationalInfoObject_v1 *inter;
    
    NSMutableArray * searchKeyArray;
    NSMutableArray * groupArray;
    NSMutableArray * columnNames;
    
    NSMutableArray * searchUp;
    NSMutableArray * searchDown;
    
    NSMutableArray * searchNewHeight;
    NSMutableArray * searchNewLow;
    
    NSMutableArray * searchGold;
    NSMutableArray * searchDeath;
    
    NSMutableArray * searchGoldKD;
    NSMutableArray * searchDeathKD;
    
    NSMutableArray * searchBIAS;
    
    NSMutableArray * searchPSY;
    
    NSMutableArray * searchAR;

    NSMutableArray *fromStockRank;
    NSMutableArray *stillDownLoadArray;
    NSMutableArray *subTypeArray;
    
    UIActionSheet * searchActionSheet;
    UIActionSheet * groupActionSheet;

    NSTimer *timer;
    
    int lastTag;
    int subType;
    int sectorID;
    int fieldID;
    int direction;
    int sendcount;
    int searchKey;
    int nowSearch;//0=5日,1=20日,2=60日,120=5日,240=5日
    int nowState;//0=漲幅,1=跌幅
    
    BOOL sameTag;
    BOOL stillDownLoad;
}

@end

@implementation TechnicalGoodStockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.emergingObj setTarget:self];
    
    self.title = @"技術面密碼";
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.emergingObj setTarget:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self varInit];    
    [self defaulltSetting];
	// Do any additional setup after loading the view.
}

-(void)initView{
    
    [self setUpImageBackButton];
    
    searchKeyBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    searchKeyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [searchKeyBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [searchKeyBtn setTitle:NSLocalizedStringFromTable(@"漲勢排行", @"GoodStock", nil) forState:UIControlStateNormal];
    [self.view addSubview:searchKeyBtn];
    
    groupBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    groupBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [groupBtn addTarget:self action:@selector(groupBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [groupBtn setTitle:NSLocalizedStringFromTable(@"上市", @"GoodStock", nil) forState:UIControlStateNormal];
    [self.view addSubview:groupBtn];
    
    mainTableView = [[SortingCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    mainTableView.focuseLabel = -1;

    [self.view addSubview:mainTableView];
    
    [self.view setNeedsUpdateConstraints];
    
}

- (void)varInit {
    
    inter = [InternationalInfoObject_v1 new];
    
    searchUp = [[NSMutableArray alloc] initWithObjects:
                    NSLocalizedStringFromTable(@"5日\n漲幅", @"GoodStock", nil),
                    NSLocalizedStringFromTable(@"20日\n漲幅", @"GoodStock", nil),
                    NSLocalizedStringFromTable(@"60日\n漲幅", @"GoodStock", nil),
                    NSLocalizedStringFromTable(@"120日\n漲幅", @"GoodStock", nil),
                    NSLocalizedStringFromTable(@"240日\n漲幅", @"GoodStock", nil),nil];
    searchDown = [[NSMutableArray alloc] initWithObjects:
                       NSLocalizedStringFromTable(@"5日\n跌幅", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"20日\n跌幅", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"60日\n跌幅", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"120日\n跌幅", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"240日\n跌幅", @"GoodStock", nil),nil];
    
    searchNewHeight = [[NSMutableArray alloc] initWithObjects:
                            NSLocalizedStringFromTable(@"5日\n新高", @"GoodStock", nil),
                            NSLocalizedStringFromTable(@"20日\n新高", @"GoodStock", nil),
                            NSLocalizedStringFromTable(@"60日\n新高", @"GoodStock", nil),
                            NSLocalizedStringFromTable(@"120日\n新高", @"GoodStock", nil),
                            NSLocalizedStringFromTable(@"240日\n新高", @"GoodStock", nil),nil];
    
    searchNewLow = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedStringFromTable(@"5日\n新低", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"20日\n新低", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"60日\n新低", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"120日\n新低", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"240日\n新低", @"GoodStock", nil),nil];
    
    searchGold = [[NSMutableArray alloc] initWithObjects:
                       NSLocalizedStringFromTable(@"黃金交叉\n5日/20日", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"黃金交叉\n20日/60日", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"黃金交叉\n20日/120日", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"黃金交叉\n20日/240日", @"GoodStock", nil),nil];
    
    searchDeath = [[NSMutableArray alloc] initWithObjects:
                        NSLocalizedStringFromTable(@"死亡交叉\n5日/20日", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"死亡交叉\n20日/60日", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"死亡交叉\n20日/120日", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"死亡交叉\n20日/240日", @"GoodStock", nil),nil];
    
    searchGoldKD = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedStringFromTable(@"日KD黃金交叉\nK值/D值", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"日MACD黃金交叉\n9D/9M", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"日RSI黃金交叉\nRSI06/RSI12", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"威廉指標黃金交叉\n%R12/%R24", @"GoodStock", nil),nil];
    
    searchDeathKD = [[NSMutableArray alloc] initWithObjects:
                         NSLocalizedStringFromTable(@"日KD死亡交叉\nK值/D值", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"日MACD死亡交叉\n9D/9M", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"日RSI死亡交叉\nRSI06/RSI12", @"GoodStock", nil),
                         NSLocalizedStringFromTable(@"威廉指標死亡交叉\n%R12/%R24", @"GoodStock", nil),nil];
    
    searchBIAS = [[NSMutableArray alloc] initWithObjects:
                       NSLocalizedStringFromTable(@"5日", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"20日", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"60日", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"120日", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"240日", @"GoodStock", nil),nil];
    
    searchPSY = [[NSMutableArray alloc] initWithObjects:
                      NSLocalizedStringFromTable(@"12日", @"GoodStock", nil),
                      NSLocalizedStringFromTable(@"24日", @"GoodStock", nil),
                      NSLocalizedStringFromTable(@"12週", @"GoodStock", nil),
                      NSLocalizedStringFromTable(@"24週", @"GoodStock", nil),
                      NSLocalizedStringFromTable(@"12月", @"GoodStock", nil),
                      NSLocalizedStringFromTable(@"24月", @"GoodStock", nil),nil];
    
    searchAR = [[NSMutableArray alloc] initWithObjects:
                     NSLocalizedStringFromTable(@"26日\nAR", @"GoodStock", nil),
                     NSLocalizedStringFromTable(@"26日\nBR", @"GoodStock", nil),
                     NSLocalizedStringFromTable(@"26週\nAR", @"GoodStock", nil),
                     NSLocalizedStringFromTable(@"26週\nBR", @"GoodStock", nil),
                     NSLocalizedStringFromTable(@"26月\nAR", @"GoodStock", nil),
                     NSLocalizedStringFromTable(@"26月\nBR", @"GoodStock", nil),nil];
    
    groupArray = [[NSMutableArray alloc] initWithObjects:
                       NSLocalizedStringFromTable(@"上市", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"上櫃", @"GoodStock", nil),nil];
    
    
    searchKeyArray = [[NSMutableArray alloc] initWithObjects:
                           NSLocalizedStringFromTable(@"漲勢排行", @"GoodStock", nil),
                           NSLocalizedStringFromTable(@"新高新低排行", @"GoodStock", nil),
                           NSLocalizedStringFromTable(@"均線交叉", @"GoodStock", nil),
                           NSLocalizedStringFromTable(@"技術指標", @"GoodStock", nil),
                           NSLocalizedStringFromTable(@"乖離率", @"GoodStock", nil),
                           NSLocalizedStringFromTable(@"心理線", @"GoodStock", nil),
                           NSLocalizedStringFromTable(@"AR/BR", @"GoodStock", nil),nil];
    subTypeArray = [[NSMutableArray alloc]initWithObjects:@"9", @"10", @"11", @"13", @"12", @"14", @"15", nil];
}

-(void)defaulltSetting{
    searchKey = 0;
    nowSearch = 0;
    nowState = 0;
    
    fieldID = 1;
    subType = 9;
    lastTag = 1;
    sectorID = 21;
    [self whichTableViewArrayShow:0];
    [self sendPacketWithSubType:9 sectorID:sectorID orderByFiledId:1 direction:1];
}

-(void)searchBtnClick{
    searchActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"排序方式", @"GoodStock", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i;
    for (i=0;i<[searchKeyArray count];i++) {
        NSString * title = [searchKeyArray objectAtIndex:i];
        [searchActionSheet addButtonWithTitle:title];
    }
    [searchActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [searchActionSheet setCancelButtonIndex:i];
    [self showActionSheet:searchActionSheet];
}

- (void)groupBtnClick {
    groupActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類別", @"GoodStock", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i;
    for (i=0;i<[groupArray count];i++) {
        NSString * title = [groupArray objectAtIndex:i];
        [groupActionSheet addButtonWithTitle:title];
    }
    [groupActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [groupActionSheet setCancelButtonIndex:i];
    [self showActionSheet:groupActionSheet];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet isEqual:searchActionSheet] && buttonIndex<[searchKeyArray count]) {
        searchKey = (int)buttonIndex;
        sameTag = NO;
        lastTag = 1;

        if (buttonIndex == 2) {
            [mainTableView setFixedColumnSize:77 mainColumnWidth:160 AndColumnHeight:44];
        }else if(buttonIndex == 3){
            [mainTableView setFixedColumnSize:77 mainColumnWidth:160 AndColumnHeight:44];
        }else if(buttonIndex == 4){
            [mainTableView setFixedColumnSize:77 mainColumnWidth:85 AndColumnHeight:44];
        }else{
            [mainTableView setFixedColumnSize:77 mainColumnWidth:80 AndColumnHeight:44];
        }
        
        [self whichTableViewArrayShow:(int)buttonIndex];
        
        if (buttonIndex >= 4) {
            [self addDirctionDown];
        }
        
        subType = [(NSNumber *)[subTypeArray objectAtIndex:buttonIndex]intValue];
        if (subType != 10 && subType != 11 && subType != 13) {
            [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:1 direction:1];
        }else{
            [self sendPacketWithSubType:subType sectorID:sectorID parameter:1 direction:0];

        }
        [searchKeyBtn setTitle:[searchKeyArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        mainTableView.focuseLabel = 1;
        [mainTableView reloadAllData];

    }else if (buttonIndex < [groupArray count]){

        if (buttonIndex == 0) {
            sectorID = 21;
        }else{
            sectorID = 2;
        }
        if (subType != 10 && subType != 11 && subType != 13) {
            [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
        }else{
            [self sendPacketWithSubType:subType sectorID:sectorID parameter:fieldID direction:direction];
        }
        [groupBtn setTitle:[groupArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(searchKeyBtn, groupBtn, mainTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[searchKeyBtn]-2-[mainTableView]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchKeyBtn]-2-[groupBtn(==searchKeyBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewControllers]];

    [self replaceCustomizeConstraints:constraints];
    
}

-(void)whichTableViewArrayShow:(int)idx{
    [columnNames removeAllObjects];
    
    if (idx == 0) {
        columnNames = [searchUp mutableCopy];
    }else if(idx == 1){
        columnNames = [searchNewHeight mutableCopy];
    }else if(idx == 2){
        columnNames = [searchGold mutableCopy];
    }else if(idx == 3){
        columnNames = [searchGoldKD mutableCopy];
    }else if(idx == 4){
        columnNames = [searchBIAS mutableCopy];
    }else if(idx == 5){
        columnNames = [searchPSY mutableCopy];
    }else if(idx == 6){
        columnNames = [searchAR mutableCopy];
    }
    
}

-(void)addDirctionDown{
    
    [columnNames replaceObjectAtIndex:0 withObject:[[columnNames objectAtIndex:0]stringByAppendingString:@"⬇︎"]];
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    label.text = @"----";
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blueColor];
    

    FSEmergingObject *fsemObj = [fromStockRank objectAtIndex:indexPath.row];
    SymbolFormat1 *symbol1 = fsemObj.securities;

    label.text = symbol1 -> fullName;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont systemFontOfSize:16.0f];
    
    FSEmergingObject *fsemObj = [fromStockRank objectAtIndex:indexPath.row];
    
    if (subType == 9 || subType == 10) {
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj valueWithOneDeci:fsemObj.fieldId1.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId1.calcValue];
                break;
            case 1:
                label.text = [fsemObj valueWithOneDeci:fsemObj.fieldId2.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [fsemObj valueWithOneDeci:fsemObj.fieldId3.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj valueWithOneDeci:fsemObj.fieldId4.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [fsemObj valueWithOneDeci:fsemObj.fieldId5.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId5.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 11){
        switch (columnIndex) {
            case 0:
                label.attributedText = [fsemObj valueWithDirectionAndSpace:fsemObj.fieldId1.calcValue :fsemObj.fieldId2.calcValue :fsemObj.fieldId6.calcValue :fsemObj.fieldId7.calcValue];
                break;
            case 1:
                label.attributedText = [fsemObj valueWithDirectionAndSpace:fsemObj.fieldId2.calcValue :fsemObj.fieldId3.calcValue :fsemObj.fieldId7.calcValue :fsemObj.fieldId8.calcValue];
                break;
            case 2:
                label.attributedText = [fsemObj valueWithDirectionAndSpace:fsemObj.fieldId2.calcValue :fsemObj.fieldId4.calcValue :fsemObj.fieldId7.calcValue :fsemObj.fieldId9.calcValue];
                break;
            case 3:
                label.attributedText = [fsemObj valueWithDirectionAndSpace:fsemObj.fieldId2.calcValue :fsemObj.fieldId5.calcValue :fsemObj.fieldId7.calcValue :fsemObj.fieldId10.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 13){
        switch (columnIndex) {
            case 0:
                label.attributedText = [fsemObj valueWithDirectionAndSpacePlus:fsemObj.fieldId1.calcValue :fsemObj.fieldId2.calcValue :fsemObj.fieldId9.calcValue :fsemObj.fieldId10.calcValue];
                break;
            case 1:
                label.attributedText = [fsemObj valueWithDirectionAndSpacePlus:fsemObj.fieldId3.calcValue :fsemObj.fieldId4.calcValue :fsemObj.fieldId11.calcValue :fsemObj.fieldId12.calcValue];
                break;
            case 2:
                label.attributedText = [fsemObj valueWithDirectionAndSpacePlus:fsemObj.fieldId5.calcValue :fsemObj.fieldId6.calcValue :fsemObj.fieldId13.calcValue :fsemObj.fieldId14.calcValue];
                break;
            case 3:
                label.attributedText = [fsemObj valueWithDirectionAndSpacePlus:fsemObj.fieldId7.calcValue :fsemObj.fieldId8.calcValue :fsemObj.fieldId15.calcValue :fsemObj.fieldId16.calcValue];
                break;
            default:
                break;
        }
    }else if(subType == 12){
        label.textAlignment = NSTextAlignmentRight;
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj valueWithDirectionPercent:fsemObj.fieldId1.calcValue :fsemObj.fieldId6.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId1.calcValue :fsemObj.fieldId6.calcValue];
                break;
            case 1:
                label.text = [fsemObj valueWithDirectionPercent:fsemObj.fieldId2.calcValue :fsemObj.fieldId7.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId2.calcValue :fsemObj.fieldId7.calcValue];
                break;
            case 2:
                label.text = [fsemObj valueWithDirectionPercent:fsemObj.fieldId3.calcValue :fsemObj.fieldId8.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId3.calcValue :fsemObj.fieldId8.calcValue];
                break;
            case 3:
                label.text = [fsemObj valueWithDirectionPercent:fsemObj.fieldId4.calcValue :fsemObj.fieldId9.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId4.calcValue :fsemObj.fieldId9.calcValue];
                break;
            case 4:
                label.text = [fsemObj valueWithDirectionPercent:fsemObj.fieldId5.calcValue :fsemObj.fieldId10.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId5.calcValue :fsemObj.fieldId10.calcValue];
                break;
            default:
                break;
        }
    }else if(subType == 14){
        label.textAlignment = NSTextAlignmentCenter;
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj valueWithDirection:fsemObj.fieldId1.calcValue :fsemObj.fieldId7.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId1.calcValue :fsemObj.fieldId7.calcValue];
                break;
            case 1:
                label.text = [fsemObj valueWithDirection:fsemObj.fieldId2.calcValue :fsemObj.fieldId8.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId2.calcValue :fsemObj.fieldId8.calcValue];
                break;
            case 2:
                label.text = [fsemObj valueWithDirection:fsemObj.fieldId3.calcValue :fsemObj.fieldId9.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId3.calcValue :fsemObj.fieldId9.calcValue];
                break;
            case 3:
                label.text = [fsemObj valueWithDirection:fsemObj.fieldId4.calcValue :fsemObj.fieldId10.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId4.calcValue :fsemObj.fieldId10.calcValue];
                break;
            case 4:
                label.text = [fsemObj valueWithDirection:fsemObj.fieldId5.calcValue :fsemObj.fieldId11.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId5.calcValue :fsemObj.fieldId11.calcValue];
                break;
            case 5:
                label.text = [fsemObj valueWithDirection:fsemObj.fieldId6.calcValue :fsemObj.fieldId12.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId6.calcValue :fsemObj.fieldId12.calcValue];
                break;
            default:
                break;
        }
    }else if(subType == 15){
        label.textAlignment = NSTextAlignmentLeft;
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj valueWithDirectionForAR:fsemObj.fieldId1.calcValue :fsemObj.fieldId7.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId1.calcValue :fsemObj.fieldId7.calcValue];
                break;
            case 1:
                label.text = [fsemObj valueWithDirectionForAR:fsemObj.fieldId2.calcValue :fsemObj.fieldId8.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId2.calcValue :fsemObj.fieldId8.calcValue];
                break;
            case 2:
                label.text = [fsemObj valueWithDirectionForAR:fsemObj.fieldId3.calcValue :fsemObj.fieldId9.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId3.calcValue :fsemObj.fieldId9.calcValue];
                break;
            case 3:
                label.text = [fsemObj valueWithDirectionForAR:fsemObj.fieldId4.calcValue :fsemObj.fieldId10.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId4.calcValue :fsemObj.fieldId10.calcValue];
                break;
            case 4:
                label.text = [fsemObj valueWithDirectionForAR:fsemObj.fieldId5.calcValue :fsemObj.fieldId11.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId5.calcValue :fsemObj.fieldId11.calcValue];
                break;
            case 5:
                label.text = [fsemObj valueWithDirectionForAR:fsemObj.fieldId6.calcValue :fsemObj.fieldId12.calcValue];
                label.textColor = [fsemObj compareTwoValue:fsemObj.fieldId6.calcValue :fsemObj.fieldId12.calcValue];
                break;
            default:
                break;
        }
    }
}

- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"股名", @"GoodStock", nil)];
}

- (NSArray *)columnsInMainTableView {

    return columnNames;
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [fromStockRank count];
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FSEmergingObject *fsemObj = [fromStockRank objectAtIndex:indexPath.row];
    
    NewSymbolObject *newSymbol = [NewSymbolObject new];
    newSymbol.identCode = [NSString stringWithFormat:@"%c%c", fsemObj.securities->IdentCode[0], fsemObj.securities->IdentCode[1]];
    newSymbol.symbol = fsemObj.securities->symbol;
    newSymbol.fullName = fsemObj.securities->fullName;
    newSymbol.typeId = fsemObj.securities->typeID;
    
    NSMutableArray *newSymbolArray = [NSMutableArray new];
    [newSymbolArray addObject:newSymbol];
    
    NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", fsemObj.securities->IdentCode[0], fsemObj.securities->IdentCode[1], fsemObj.securities->symbol];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    
    [dataModel.portfolioData setTarget:self];
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:newSymbolArray];
    
    PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
    FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
    
}

-(void)reloadData{
    
    FSMainViewController *mainView = [[FSMainViewController alloc]init];
    [self.navigationController pushViewController:mainView animated:NO];
}
-(void)labelTap:(UILabel *)label{
    fieldID = (int)label.tag;
    
    if (subType == 9 || subType == 10 || subType == 11 || subType == 13) {
        if (label.tag != 0) {
            if (label.tag != lastTag) {
                sameTag = NO;
                [self whichTableViewArrayShow:searchKey];
                [self sendWhichPacketOut];
            }else{
                if(sameTag) {
                    sameTag = NO;
                    [self whichTableViewArrayShow:searchKey];
                    [self sendWhichPacketOut];
                }else{
                    sameTag = YES;
                    if (subType != 9) {
                        direction = 1;
                        [self sendPacketWithSubType:subType sectorID:sectorID parameter:fieldID direction:direction];
                        switch (subType) {
                            case 10:
                                columnNames = [searchNewLow mutableCopy];
                                break;
                            case 11:
                                columnNames = [searchDeath mutableCopy];
                                break;
                            case 13:
                                columnNames = [searchDeathKD mutableCopy];
                                break;
                            default:
                                break;
                        }
                    }else{
                        direction = 0;
                        columnNames = [searchDown mutableCopy];
                        [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
                    }
                }
            }
        }
    }else{
        if (label.tag != 0) {
            [self whichTableViewArrayShow:searchKey];
            if (label.tag != lastTag) {
                sameTag = NO;
                direction = 1;
                [columnNames replaceObjectAtIndex:label.tag - 1 withObject:[[columnNames objectAtIndex:label.tag - 1]stringByAppendingString:@"⬇︎"]];
            }else{
                if(sameTag) {
                    sameTag = NO;
                    direction = 1;
                    [columnNames replaceObjectAtIndex:label.tag - 1 withObject:[[columnNames objectAtIndex:label.tag - 1]stringByAppendingString:@"⬇︎"]];
                }else{
                    sameTag = YES;
                    direction = 0;
                    [columnNames replaceObjectAtIndex:label.tag - 1 withObject:[[columnNames objectAtIndex:label.tag - 1]stringByAppendingString:@"⬆︎"]];
                }
            }
        }
        [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
    }
    lastTag = fieldID;
    mainTableView.focuseLabel = lastTag;
}

    
//    if (nowSearch != label.tag) {
//        for (int i =0; i<[mainTableView.labelArray count]; i++) {
//            UILabel * allLabel = [mainTableView.labelArray objectAtIndex:i];
//            allLabel.backgroundColor = [UIColor clearColor];
//        }
//        label.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:162.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
//        nowSearch = label.tag;
//        if (searchKey == 4){
//            columnNames = [searchBIAS mutableCopy];
//            if (nowState == 0) {
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchBIAS objectAtIndex:label.tag],@"▲"]];
//            }else{
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchBIAS objectAtIndex:label.tag],@"▼"]];
//            }
//            
//        }else if (searchKey == 5){
//            columnNames = searchPSY;
//            if (nowState == 0) {
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchPSY objectAtIndex:label.tag],@"▲"]];
//            }else{
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchPSY objectAtIndex:label.tag],@"▼"]];
//            }
//        }else if (searchKey == 6){
//            columnNames = searchAR;
//            if (nowState == 0) {
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchAR objectAtIndex:label.tag],@"▲"]];
//            }else{
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchAR objectAtIndex:label.tag],@"▼"]];
//            }
//        }
//    }else{
//        if (searchKey == 0) {
//            if (nowState == 0) {
//                columnNames = searchDown;
//                nowState = 1;
//            }else{
//                columnNames = searchUp;
//                
//                nowState = 0;
//            }
//        }else if (searchKey == 1){
//            if (nowState == 0) {
//                columnNames = searchNewLow;
//                nowState = 1;
//            }else{
//                columnNames = searchNewHeight;
//                
//                nowState = 0;
//            }
//        }else if (searchKey == 2){
//            if (nowState == 0) {
//                columnNames = searchDeath;
//                nowState = 1;
//            }else{
//                columnNames = searchGold;
//                
//                nowState = 0;
//            }
//        }else if (searchKey == 3){
//            if (nowState == 0) {
//                columnNames = searchDeathKD;
//                nowState = 1;
//            }else{
//                columnNames = searchGoldKD;
//                
//                nowState = 0;
//            }
//        }else if (searchKey == 4){
//            columnNames = [searchBIAS mutableCopy];
//            if (nowState == 0) {
//                nowState = 1;
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchBIAS objectAtIndex:label.tag],@"▼"]];
//            }else{
//                nowState = 0;
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchBIAS objectAtIndex:label.tag],@"▲"]];
//            }
//            
//        }else if (searchKey == 5){
//            columnNames = searchPSY;
//            if (nowState == 0) {
//                nowState = 1;
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchPSY objectAtIndex:label.tag],@"▼"]];
//            }else{
//                nowState = 0;
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchPSY objectAtIndex:label.tag],@"▲"]];
//            }
//        }else if (searchKey == 6){
//            columnNames = searchAR;
//            if (nowState == 0) {
//                nowState = 1;
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchAR objectAtIndex:label.tag],@"▼"]];
//            }else{
//                nowState = 0;
//                [columnNames replaceObjectAtIndex:label.tag withObject:[NSString stringWithFormat:@"%@  %@",[searchAR objectAtIndex:label.tag],@"▲"]];
//            }
//        }
//        
//        
//    }

    
    
//    for (int i =0; i<[mainTableView.labelArray count]; i++) {
//        UILabel * allLabel = [mainTableView.labelArray objectAtIndex:i];
//        allLabel.text = [columnNames objectAtIndex:i];
//    }
//    UILabel * allLabel = [mainTableView.labelArray objectAtIndex:label.tag];
//    allLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:162.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    //do search
//}

-(void)notifyDataArrive:(NSMutableArray *)array{

    if ([array firstObject] == nil) {
        if (sendcount < 3) {
            sendcount ++;
            if (subType != 10 && subType != 11 && subType != 13) {
                [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
            }else{
                [self sendPacketWithSubType:subType sectorID:sectorID parameter:fieldID direction:direction];
            }
        }else{
            sendcount = 0;
            [mainTableView reloadDataNoOffset];

            UIAlertView *maxAlert = [[UIAlertView alloc]initWithTitle:@"無相符個股" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [maxAlert show];
        }
    }else{

        if ([[array firstObject] retCode] == 1) {
            stillDownLoadArray = [NSMutableArray arrayWithArray:array];
        }else{
            if ([stillDownLoadArray firstObject] == nil) {
                fromStockRank = [NSMutableArray arrayWithArray:array];
            }else{
                fromStockRank = [NSMutableArray arrayWithArray:stillDownLoadArray];
                [fromStockRank addObjectsFromArray:array];
                [stillDownLoadArray removeAllObjects];
            }
            
            mainTableView.focuseLabel = lastTag;
            [mainTableView reloadDataNoOffset];
        }
    }
}


-(void)sendPacketWithSubType:(int)sT sectorID:(int)sID orderByFiledId:(int)oBFID direction:(int)d{
    [fromStockRank removeAllObjects];
    [mainTableView reloadDataNoOffset];
    
    StockRankOut *packet = [[StockRankOut alloc]initWithSubType:sT SectorCount:1 SectorId:sID orderByFiledId:oBFID direction:d requestCount:80];
    [FSDataModelProc sendData:self WithPacket:packet];
    
}

-(void)sendPacketWithSubType:(int)sT sectorID:(int)sID parameter:(int)p direction:(int)d{
    [fromStockRank removeAllObjects];
    [mainTableView reloadDataNoOffset];

    StockRankOut *packet = [[StockRankOut alloc]initWithSubType:sT SectorCount:1 SectorId:sID direction:d parameter1:p requestCount:80];
    [FSDataModelProc sendData:self WithPacket:packet];
}

-(void)sendWhichPacketOut{
    if (subType != 10 && subType != 11 && subType != 13) {
        direction = 1;
        [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:1];
    }else{
        direction = 0;
        [self sendPacketWithSubType:subType sectorID:sectorID parameter:fieldID direction:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
