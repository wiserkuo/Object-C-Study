//
//  ChipGoodStockViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Restart by Michael.Hsieh on 14/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "ChipGoodStockViewController.h"
#import "SortingCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "StockRankOut.h"
#import "InternationalInfoObject_v1.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface ChipGoodStockViewController ()<SortingTableViewDelegate, UIActionSheetDelegate>{

    InternationalInfoObject_v1 *inter;
    FSUIButton *leftBtn;
    FSUIButton *middleBtn;
    
    SortingCustomTableView *skMainTableView;
    
    NSMutableArray *tableViewArray;
    
    NSMutableArray *leftBtnNameArray;
    NSMutableArray *middleBtnNameArray;

    NSMutableArray *subTypeArray23Up;
    NSMutableArray *subTypeArray23Down;
    NSMutableArray *subTypeArray1;
    NSMutableArray *subTypeArray22Up;
    NSMutableArray *subTypeArray22Down;
    NSMutableArray *subTypeArray3;
    NSMutableArray *subTypeArray2;
    NSMutableArray *subTypeArray4;
    
    NSMutableArray *fromStockRank;
    NSMutableArray *stillDownLoadArray;
    
    NSMutableArray *fieldIDArray23;
    UIActionSheet *leftActionSheet;
    UIActionSheet *middleActionSheet;
    
    NSTimer *timer;
    BOOL sameTag;
    BOOL stillDownLoad;
    
    int lastTag;
    int btnIdx;
    int subType;
    int sectorID;
    int fieldID;
    int direction;
    int sendcount;
    int recentYear;
}

@end

@implementation ChipGoodStockViewController

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
    
    self.title = @"籌碼面密碼";
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
    [self initVar];

	// Do any additional setup after loading the view.
}
-(void)initView{
    [self setUpImageBackButton];
    
    leftBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [leftBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    [leftBtn setTitle:@"外資券商追蹤" forState:UIControlStateNormal];
    leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    middleBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [middleBtn setTitle:@"上市" forState:UIControlStateNormal];
    [middleBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    middleBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [middleBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:middleBtn];
    
    skMainTableView = [[SortingCustomTableView alloc]initWithfixedColumnWidth:77 mainColumnWidth:85 AndColumnHeight:42];
    skMainTableView.delegate = self;
    skMainTableView.focuseLabel = -1;
    skMainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:skMainTableView];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)initVar{
    
    tableViewArray = [NSMutableArray new];
    stillDownLoadArray = [NSMutableArray new];
    leftBtnNameArray = [NSMutableArray arrayWithObjects:@"外資券商追蹤", @"法人買賣", @"法人追蹤", @"法人認同度", @"當日資券動態", @"信用交易統計", nil];
    middleBtnNameArray = [NSMutableArray arrayWithObjects:@"上市", @"上櫃", nil];

    subTypeArray23Up = [NSMutableArray arrayWithObjects:@"瑞士信貸\n買超率", @"瑞銀\n買超率", @"台灣摩根\n買超率", @"美林\n買超率", @"德意志\n買超率", @"花旗\n買超率", @"美商高盛\n買超率", @"摩根大通\n買超率", @"港麥格理\n買超率", @"港商里昂\n買超率", @"法銀巴黎\n買超率", @"上海匯豐\n買超率", @"港商野村\n買超率", @"港商法興\n買超率", @"大和國泰\n買超率", @"巴克萊\n買超率",  nil];
    subTypeArray23Down = [NSMutableArray arrayWithObjects:@"瑞士信貸\n賣超率", @"瑞銀\n賣超率", @"台灣摩根\n賣超率", @"美林\n賣超率", @"德意志\n賣超率", @"花旗\n賣超率", @"美商高盛\n賣超率", @"摩根大通\n賣超率", @"港麥格理\n賣超率", @"港商里昂\n賣超率", @"法銀巴黎\n賣超率", @"上海匯豐\n賣超率", @"港商野村\n賣超率", @"港商法興\n賣超率", @"大和國泰\n賣超率", @"巴克萊\n賣超率",  nil];

    subTypeArray1 = [NSMutableArray arrayWithObjects:@"當日外\n資買賣", @"當日自\n營買賣", @"當日投\n信買賣", @"當日三\n大買賣", @"當週外\n資買賣", @"當週自\n營買賣", @"當週投\n信買賣", @"當週三\n大買賣", @"當月外\n資買賣", @"當月自\n營買賣", @"當月投\n信買賣", @"當月三\n大買賣", nil];
    subTypeArray22Up = [NSMutableArray arrayWithObjects:@"外資\n連買", @"投信\n連買", @"自營商\n連買", @"融資\n連買", @"融券\n連買", nil];
    subTypeArray22Down = [NSMutableArray arrayWithObjects:@"外資\n連賣", @"投信\n連賣", @"自營商\n連賣", @"融資\n連賣", @"融券\n連買", nil];
    subTypeArray3 = [NSMutableArray arrayWithObjects:@"外資持\n股比率", @"投信持\n股比率", @"董監持\n股比率", @"董監質\n押比率", nil];
    subTypeArray2 = [NSMutableArray arrayWithObjects:@"融資\n增減", @"融券\n增減", @"當日\n沖銷", @"當沖\n比率", nil];
    subTypeArray4 = [NSMutableArray arrayWithObjects:@"融資\n餘額", @"融券\n餘額", @"券資\n比率", nil];
    
    fieldIDArray23 = [NSMutableArray arrayWithObjects:@"6", @"10", @"3", @"4", @"7", @"11", @"5", @"15", @"1", @"2", @"16", @"14", @"8", @"9", @"12", @"13", nil];
    
    [self defaulltSetting];
}

-(void)defaulltSetting{
    lastTag = 1;
    fieldID = 1;
    subType = 23;
    recentYear = 1;
    sectorID = 21;
    
    inter = [InternationalInfoObject_v1 new];
    [self whichTableViewArrayShow:0];
    [self sendPacketWithSubType:23 sectorID:sectorID orderByFiledId:6 direction:1];
    
}
-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *viewConstraints = NSDictionaryOfVariableBindings(leftBtn, middleBtn, skMainTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBtn]-2-[middleBtn(leftBtn)]|" options:0 metrics:nil views:viewConstraints]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[leftBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[middleBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
    
    [self replaceCustomizeConstraints:constraints];
}
-(NSArray *)columnsInMainTableView{
    
    return tableViewArray;
}

-(NSArray *)columnsInFixedTableView{
    
    return @[@"股名"];
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
    
    label.text = @"----";
    label.adjustsFontSizeToFitWidth = YES;
    
    FSEmergingObject *fsemObj = [fromStockRank objectAtIndex:indexPath.row];
    if (subType == 23) {
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId6.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId6.calcValue];
                break;
            case 1:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId10.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId10.calcValue];
                break;
            case 2:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId3.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId4.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId7.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId7.calcValue];
                break;
            case 5:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId11.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId11.calcValue];
                break;
            case 6:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId5.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId5.calcValue];
                break;
            case 7:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId15.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId15.calcValue];
                break;
            case 8:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId1.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId1.calcValue];
                break;
            case 9:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId2.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 10:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId16.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId16.calcValue];
                break;
            case 11:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId14.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId14.calcValue];
                break;
            case 12:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId8.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId8.calcValue];
                break;
            case 13:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId9.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId9.calcValue];
                break;
            case 14:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId12.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId12.calcValue];
                break;
            case 15:
                label.text = [fsemObj convertForeighnValueToString:fsemObj.fieldId13.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId13.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 1){
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId1.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId1.calcValue];
                break;
            case 1:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId2.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId3.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId4.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId5.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId5.calcValue];
                break;
            case 5:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId6.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId6.calcValue];
                break;
            case 6:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId7.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId7.calcValue];
                break;
            case 7:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId8.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId8.calcValue];
                break;
            case 8:
                label.text = [CodingUtil stringWithMergedRevenueByValue:fsemObj.fieldId9.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId9.calcValue];
                break;
            case 9:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId10.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId10.calcValue];
                break;
            case 10:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId11.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId11.calcValue];
                break;
            case 11:
                label.text = [CodingUtil stringWithMergedRevenueByValue:fsemObj.fieldId12.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId12.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 22){
        label.textColor = [UIColor blueColor];
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj valueWithDay:fsemObj.fieldId1.calcValue];
                break;
            case 1:
                label.text = [fsemObj valueWithDay:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [fsemObj valueWithDay:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj valueWithDay:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [fsemObj valueWithDay:fsemObj.fieldId5.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 3){
        label.textColor = [UIColor blueColor];
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj stringWithChipPercent:fsemObj.fieldId1.calcValue sign:NO];
                break;
            case 1:
                label.text = [fsemObj stringWithChipPercent:fsemObj.fieldId3.calcValue sign:NO];
                break;
            case 2:
                label.text = [fsemObj stringWithChipPercent:fsemObj.fieldId4.calcValue sign:NO];
                break;
            case 3:
                label.text = [fsemObj stringWithChipPercent:fsemObj.fieldId5.calcValue sign:NO];
                break;
            default:
                break;
        }
    }else if (subType == 2){
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId1.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId1.calcValue];
                break;
            case 1:
                label.text = [fsemObj convertZeroPlusOrNotForChip:fsemObj.fieldId2.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [NSString stringWithFormat:@"%.0f", fsemObj.fieldId3.calcValue];
                label.textColor = [UIColor blueColor];
                break;
            case 3:
                if (fsemObj.fieldId4.calcValue == 0) {
                    label.text = @"0%%";
                }else{
                    label.text = [fsemObj stringWithMarketMoverPercent:fsemObj.fieldId4.calcValue * 100 sign:NO];
                }
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 4){
        label.textColor = [UIColor blueColor];
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj stringWithMarketMoverPercent:fsemObj.fieldId1.calcValue * 100 sign:NO];
                break;
            case 1:
                label.text = [fsemObj stringWithMarketMoverPercent:fsemObj.fieldId2.calcValue * 100 sign:NO];
                break;
            case 2:
                label.text = [fsemObj stringWithMarketMoverPercent:fsemObj.fieldId3.calcValue * 100 sign:NO];
                break;
            default:
                break;
        }
        if ([label.text isEqualToString:@"0.00%"]) {
            label.text = @"0%";
        }
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [fromStockRank count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(void)btnHandler:(FSUIButton *)sender{
    
    if ([sender isEqual:leftBtn]) {
        leftActionSheet = [[UIActionSheet alloc]initWithTitle:@"排序方式" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        int i;
        for(i = 0; i < [leftBtnNameArray count]; i++){
            NSString *leftBtnTitle = [leftBtnNameArray objectAtIndex:i];
            [leftActionSheet addButtonWithTitle:leftBtnTitle];
        }
        [leftActionSheet addButtonWithTitle:@"取消"];
        [leftActionSheet setCancelButtonIndex:i];
        [leftActionSheet showInView:self.view];
        
    }else if ([sender isEqual:middleBtn]){
        middleActionSheet = [[UIActionSheet alloc]initWithTitle:@"類別" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        int i;
        for(i = 0; i < [middleBtnNameArray count]; i++){
            NSString *middleBtnTitle = [middleBtnNameArray objectAtIndex:i];
            [middleActionSheet addButtonWithTitle:middleBtnTitle];
        }
        [middleActionSheet addButtonWithTitle:@"取消"];
        [middleActionSheet setCancelButtonIndex:i];
        [middleActionSheet showInView:self.view];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    stillDownLoad = NO;
    
    if ([actionSheet isEqual:leftActionSheet] && buttonIndex < [leftBtnNameArray count]) {
        [leftBtn setTitle:[leftActionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        [self whichTableViewArrayShow:(int)buttonIndex];
        
        if (subType != 22 && subType != 23) {
            [self addDirctionDown];
        }
        sameTag = NO;
        lastTag = 1;
        btnIdx = (int)buttonIndex;
        if (subType == 23) {
            [self sendPacketWithSubType:23 sectorID:sectorID orderByFiledId:6 direction:1];
        }else{
            [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:1 direction:1];
        }
        skMainTableView.focuseLabel = 1;

    }else if ([actionSheet isEqual:middleActionSheet] && buttonIndex < [middleBtnNameArray count]){
        [middleBtn setTitle:[middleActionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        switch (buttonIndex) {
            case 0:
                sectorID = 21;
                break;
            case 1:
                sectorID = 2;
            default:
                break;
        }
        [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
    }
}

-(void)whichTableViewArrayShow:(int)idx{

    [tableViewArray removeAllObjects];
    
    switch (idx) {
        case 0:
            tableViewArray = [NSMutableArray arrayWithArray:subTypeArray23Up];
            subType = 23;
            break;
        case 1:
            tableViewArray = [NSMutableArray arrayWithArray:subTypeArray1];
            subType = 1;
            break;
        case 2:
            tableViewArray = [NSMutableArray arrayWithArray:subTypeArray22Up];
            subType = 22;
            break;
        case 3:
            tableViewArray = [NSMutableArray arrayWithArray:subTypeArray3];
            subType = 3;
            break;
        case 4:
            tableViewArray = [NSMutableArray arrayWithArray:subTypeArray2];
            subType = 2;
            break;
        case 5:
            tableViewArray = [NSMutableArray arrayWithArray:subTypeArray4];
            subType = 4;
            break;
        default:
            break;
    }
}

-(void)addDirctionDown{
    
    [tableViewArray replaceObjectAtIndex:0 withObject:[[tableViewArray objectAtIndex:0]stringByAppendingString:@"⬇︎"]];
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

    stillDownLoad = NO;
    
    fieldID = (int)label.tag;
    
    if (subType == 23) {
        fieldID = [(NSNumber *)[fieldIDArray23 objectAtIndex:label.tag -1]intValue];
    }else if (subType == 3){
        if (label.tag == 2) {
            fieldID = 3;
        }else if (label.tag == 3){
            fieldID = 4;
        }else if (label.tag == 4){
            fieldID = 5;
        }
    }
    if (subType == 22 || subType == 23) {
        if (label.tag != 0) {
            if (label.tag != lastTag) {
                sameTag = NO;
                direction = 1;
                [self whichTableViewArrayShow:btnIdx];
                [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:1];
            }else{
                if(sameTag) {
                    sameTag = NO;
                    direction = 1;
                    [self whichTableViewArrayShow:btnIdx];
                    [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:1];
                }else{
                    sameTag = YES;
                    direction = 0;
                    if (subType == 22) {
                        tableViewArray = [NSMutableArray arrayWithArray:subTypeArray22Down];
                        [self sendPacketWithSubType:22 sectorID:sectorID orderByFiledId:fieldID direction:0];
                    }else{
                        tableViewArray = [NSMutableArray arrayWithArray:subTypeArray23Down];
                        [self sendPacketWithSubType:23 sectorID:sectorID orderByFiledId:fieldID direction:0];
                    }
                }
            }
        }
    }else{
        if (label.tag != 0) {
            [self whichTableViewArrayShow:btnIdx];
            if (label.tag != lastTag) {
                sameTag = NO;
                direction = 1;
                [tableViewArray replaceObjectAtIndex:label.tag - 1 withObject:[[tableViewArray objectAtIndex:label.tag - 1]stringByAppendingString:@"⬇︎"]];
            }else{
                if(sameTag) {
                    sameTag = NO;
                    direction = 1;
                    [tableViewArray replaceObjectAtIndex:label.tag - 1 withObject:[[tableViewArray objectAtIndex:label.tag - 1]stringByAppendingString:@"⬇︎"]];
                }else{
                    sameTag = YES;
                    direction = 0;
                    [tableViewArray replaceObjectAtIndex:label.tag - 1 withObject:[[tableViewArray objectAtIndex:label.tag - 1]stringByAppendingString:@"⬆︎"]];
                }
            }
        }
        [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];

    }
    lastTag = (int)label.tag;
    skMainTableView.focuseLabel = lastTag;
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    

    //如果下來資料是空的就重送 直到重送次數超過三次
    if ([array firstObject] == nil) {
        if (sendcount <= 3) {
            sendcount ++;
            [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
        }
    }else{
        sendcount = 0;
        
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
            
            skMainTableView.focuseLabel = lastTag;
            [skMainTableView reloadDataNoOffset];
        }
    }
}


-(void)sendPacketWithSubType:(int)sT sectorID:(int)sID orderByFiledId:(int)oBFID direction:(int)d{
    [fromStockRank removeAllObjects];
    [skMainTableView reloadDataNoOffset];
    
    StockRankOut *packet = [[StockRankOut alloc]initWithSubType:sT SectorCount:1 SectorId:sID orderByFiledId:oBFID direction:d requestCount:80];
    [FSDataModelProc sendData:self WithPacket:packet];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
