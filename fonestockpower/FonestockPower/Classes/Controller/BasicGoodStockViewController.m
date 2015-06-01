//
//  BasicGoodStockViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Restart by Michael.Hsieh on 14/12/26
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "BasicGoodStockViewController.h"
#import "SortingCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "StockRankOut.h"
#import "FSEmergingObject.h"
#import "InternationalInfoObject_v1.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"


@interface BasicGoodStockViewController ()<SortingTableViewDelegate, UIActionSheetDelegate>{

    InternationalInfoObject_v1 *inter;
    FSUIButton *leftBtn;
    FSUIButton *middleBtn;
    FSUIButton *rightBtn;
    
    SortingCustomTableView *skMainTableView;
    
    NSMutableArray *tableViewArray;
    
    NSMutableArray *leftBtnNameArray;
    NSMutableArray *middleBtnNameArray;
    NSMutableArray *rightBtnNameArray;
    
    NSMutableArray *revenueArray;
    NSMutableArray *profitabilityRatiosArray1;
    NSMutableArray *growArray2;
    NSMutableArray *financialStrengthArray3;
    NSMutableArray *managemnetEffectivenessArray4;
    NSMutableArray *financialStructureArray5;
    NSMutableArray *exArray6;
    NSMutableArray *averageArray7;
    
    NSMutableArray *fromStockRank;
    NSMutableArray *stillDownLoadArray;
    UIActionSheet *leftActionSheet;
    UIActionSheet *middleActionSheet;
    UIActionSheet *rightActionSheet;
    
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

@implementation BasicGoodStockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self initVar];

	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.emergingObj setTarget:self];
    
    self.title = @"基本面密碼";
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.emergingObj setTarget:nil];

}
-(void)initView{
    [self setUpImageBackButton];
    
    leftBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [leftBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    [leftBtn setTitle:@"營收排行" forState:UIControlStateNormal];
    leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    middleBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [middleBtn setTitle:@"上市" forState:UIControlStateNormal];
    [middleBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    middleBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [middleBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:middleBtn];
    
    rightBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [rightBtn setTitle:@"近一年" forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0]];
    rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.hidden = YES;
    [self.view addSubview:rightBtn];
    
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
    leftBtnNameArray = [NSMutableArray arrayWithObjects:@"營收排行", @"獲利能力", @"成長能力", @"償債能力", @"經營能力", @"財務結構", @"除權除息", @"平均股利", nil];
    middleBtnNameArray = [NSMutableArray arrayWithObjects:@"上市", @"上櫃", nil];
    rightBtnNameArray = [NSMutableArray arrayWithObjects:@"近一年", @"近二年", @"近三年", @"近四年", @"近五年", nil];

    revenueArray = [NSMutableArray arrayWithObjects:@"創高/\n創低", @"合併\n營收", @"月增率", @"年增率", @"累計合\n併營收", @"累計\n年增率", nil];
    profitabilityRatiosArray1 = [NSMutableArray arrayWithObjects:@"每股\n營收", @"營業\n毛利率", @"營業\n利益率", @"稅後\n淨利率", @"每股稅\n後淨利", @"股東權益\n報酬率", @"資產\n報酬率", nil];
    growArray2 = [NSMutableArray arrayWithObjects:@"營收\n成長率", @"營業利益\n成長率", @"稅前淨利\n成長率", @"稅後淨利\n成長率", @"淨值\n成長率", @"本益比", nil];
    financialStrengthArray3 = [NSMutableArray arrayWithObjects:@"流動\n比率", @"速動\n比率", @"負債\n比率", @"現金流\n量比率", @"財務槓\n桿指數", nil];
    managemnetEffectivenessArray4 = [NSMutableArray arrayWithObjects:@"應收帳款\n收現之數", @"平均存\n貨之數", @"總資產\n週轉率", @"淨值\n週轉率", nil];
    financialStructureArray5 = [NSMutableArray arrayWithObjects:@"每股\n淨值", @"股價\n淨值比", @"負債\n淨值比", @"長期資金\n適合率", nil];
    
//    "董監改選" 改成 "董監改選年"
    exArray6 = [NSMutableArray arrayWithObjects:@"除權\n日期", @"盈餘\n配股", @"公積\n配股", @"股票\n股利", @"除息\n日期", @"現金\n股利", @"現金\n增資", @"股東\n會議", @"可扣\n抵稅額", @"股票\n發放日", @"現金\n發放日", @"現增\n發放日", @"董監\n改選年", @"股息\n殖利率", nil];
    averageArray7 = [NSMutableArray arrayWithObjects:@"平均\n營配", @"平均\n資配", @"平均\n配股", @"平均\n配息", @"平均\nEPS", nil];
    

    [self defaulltSetting];
}
-(void)defaulltSetting{
    lastTag = 1;
    fieldID = 1;
    subType = 16;
    recentYear = 1;
    sectorID = 21;
    
    [self whichTableViewArrayShow:0];
    [self addDirctionDown];
    [self sendPacketWithSubType:16 sectorID:21 orderByFiledId:1 direction:1];

}
-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *viewConstraints = NSDictionaryOfVariableBindings(leftBtn, middleBtn, rightBtn, skMainTableView);
    
    if ([leftBtn.titleLabel.text isEqualToString:@"平均股利"]) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBtn]-2-[middleBtn(80)]-2-[rightBtn(middleBtn)]|" options:0 metrics:nil views:viewConstraints]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[leftBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[middleBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[rightBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftBtn]-2-[middleBtn(leftBtn)]|" options:0 metrics:nil views:viewConstraints]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[leftBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[middleBtn]-2-[skMainTableView]|" options:0 metrics:nil views:viewConstraints]];
    }
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

    FSEmergingObject *fsemObj = [fromStockRank objectAtIndex:indexPath.row];
    
    inter = [InternationalInfoObject_v1 new];
    
    label.text = @"----";
    label.adjustsFontSizeToFitWidth = YES;
    
    if (subType == 16) {
        switch (columnIndex) {
            case 0:
                label.text = [NSString stringWithFormat:@"%.0f", fsemObj.fieldId1.calcValue];
                label.textColor = [UIColor blueColor];
                break;
            case 1:
                label.text = [CodingUtil stringWithMergedRevenueByValue:fsemObj.fieldId5.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId5.calcValue];
                break;
            case 2:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId3.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId4.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [CodingUtil stringWithMergedRevenueByValue:fsemObj.fieldId10.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId10.calcValue];
                break;
            case 5:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId11.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId11.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 17){
        switch (columnIndex) {
            case 0:
                label.text = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId1.calcValue];
                label.textColor = [UIColor blueColor];
                break;
            case 1:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId2.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId3.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId5.calcValue];
                label.textColor = [UIColor blueColor];
                break;
            case 5:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId6.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId6.calcValue];
                break;
            case 6:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId7.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId7.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 18){
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId1.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId1.calcValue];
                break;
            case 1:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId2.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId3.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId5.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId5.calcValue];
                break;
            case 5:
                if (fsemObj.fieldId6.calcValue == 0) {
                    label.text = @"----";
                    label.textColor = [UIColor blueColor];
                }else{
                    label.text = [NSString stringWithFormat:@"+%.2f", fsemObj.fieldId6.calcValue];
                    label.textColor = [UIColor redColor];
                }
                break;
            default:
                break;
        }
    }else if (subType == 19) {
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId1.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId1.calcValue];
                break;
            case 1:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId2.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [inter formatCGFloatDataRank:fsemObj.fieldId3.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                if (fsemObj.fieldId5.calcValue == 0) {
                    label.text = @"----";
                }else{
                    label.text = [NSString stringWithFormat:@"%.3f", fsemObj.fieldId5.calcValue];
                }
                label.textColor = [UIColor blueColor];
                break;
            default:
                break;
        }
    }else if (subType == 20) {
        switch (columnIndex) {
            case 0:
                label.text = [NSString stringWithFormat:@"%.2f天", fsemObj.fieldId1.calcValue];
                label.textColor = [UIColor blueColor];
                break;
            case 1:
                label.text = [NSString stringWithFormat:@"%.2f天", fsemObj.fieldId2.calcValue];
                label.textColor = [UIColor blueColor];
                break;
            case 2:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId3.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 21) {
        switch (columnIndex) {
            case 0:
                label.text = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId1.calcValue];
                label.textColor = [UIColor blueColor];
                break;
            case 1:
                label.text = [fsemObj convertPriceValueToString:fsemObj.fieldId2.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [fsemObj convertPriceValueToString:fsemObj.fieldId3.calcValue];
                label.textColor = [inter compareToZero:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj stringWithOperatingMarginByValue:fsemObj.fieldId4.calcValue Sign:YES];
                label.textColor = [inter compareToZero:fsemObj.fieldId4.calcValue];
                break;
            default:
                break;
        }
    }else if (subType == 5) {
        switch (columnIndex) {
            case 0:
                if (fsemObj.stockDividendDate == 0) {
                    label.text = @"----";
                }else{
                    label.text = [fsemObj getStringDatePlusZeroForEX:fsemObj.stockDividendDate];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.stockDividendDate];
                break;
            case 1:
                if (fsemObj.fieldId2.calcValue == 0) {
                    label.text = @"----";
                }else{
                    label.text = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId2.calcValue];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                if (fsemObj.fieldId3.calcValue == 0) {
                    label.text = @"----";
                }else{
                    label.text = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId3.calcValue];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                if (fsemObj.fieldId4.calcValue == 0) {
                    label.text = @"----";
                }else{
                    label.text = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId4.calcValue];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId4.calcValue];
                
                break;
            case 4:
                if (fsemObj.cashDividendDate == 0) {
                    label.text = @"----";
                }else{
                    label.text = [fsemObj getStringDatePlusZeroForEX:fsemObj.cashDividendDate];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.cashDividendDate];
                
                break;
            case 5:
                if (fsemObj.fieldId6.calcValue == 0) {
                    label.text = @"----";
                }else{
                    label.text = [NSString stringWithFormat:@"%.2f", fsemObj.fieldId6.calcValue];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId6.calcValue];

                break;
//現金增資
            case 6:
                if (fsemObj.fieldId7.calcValue == 0) {
                    label.text = @"0";
                }else{
                    label.text = [CodingUtil stringWithMergedRevenueByValue:fsemObj.fieldId7.calcValue Sign:NO];
                }
                label.textColor = [UIColor blueColor];
                break;
                
            case 7:
                if (fsemObj.shareHolderMeetingDate == 0) {
                    label.text = @"----";
                }else{
                    label.text = [fsemObj getStringDatePlusZeroForEX:fsemObj.shareHolderMeetingDate];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.shareHolderMeetingDate];
                break;
//可扣抵稅額
            case 8:
                if (fsemObj.fieldId9.calcValue == 0) {
                    label.text = @"0.00%";
                }else if (fsemObj.fieldId9.calcValue < 10){
                    label.text = [NSString stringWithFormat:@"%.2f%%", fsemObj.fieldId9.calcValue];
                }else if (fsemObj.fieldId9.calcValue < 100){
                    label.text = [NSString stringWithFormat:@"%.1f%%", fsemObj.fieldId9.calcValue];
                }else{
                    label.text = [NSString stringWithFormat:@"%.0f%%", fsemObj.fieldId9.calcValue];
                }
                label.textColor = [UIColor blueColor];
                break;
            case 9:
                if (fsemObj.stockDividendDate2 == 0) {
                    label.text = @"----";
                }else{
                    label.text = [fsemObj getStringDatePlusZeroForEX:fsemObj.stockDividendDate2];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.stockDividendDate2];
                break;
            case 10:
                if (fsemObj.cashDividend == 0) {
                    label.text = @"----";
                }else{
                    label.text = [fsemObj getStringDatePlusZeroForEX:fsemObj.cashDividend];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.cashDividend];
                break;
            case 11:
                if (fsemObj.cashCapitalIncrease == 0) {
                    label.text = @"----";
                }else{
                    label.text = [fsemObj getStringDatePlusZeroForEX:fsemObj.cashCapitalIncrease];
                }
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.cashCapitalIncrease];
                break;
            case 12:
                if ([fsemObj.directorsDate isEqualToString:@"0"]) {
                    label.text = @"----";
                    label.textColor = [UIColor blackColor];
                }else{
                    label.text = fsemObj.directorsDate;
                    label.textColor = [UIColor blueColor];
                }
                break;
            case 13:
                if (fsemObj.fieldId14.calcValue == 0) {
                    label.text = @"0.0%";
                }else if (fsemObj.fieldId14.calcValue < 10){
                    label.text = [NSString stringWithFormat:@"%.2f%%", fsemObj.fieldId14.calcValue];
                }else if (fsemObj.fieldId14.calcValue < 100){
                    label.text = [NSString stringWithFormat:@"%.1f%%", fsemObj.fieldId14.calcValue];
                }else{
                    label.text = [NSString stringWithFormat:@"%.0f%%", fsemObj.fieldId14.calcValue];
                }
                label.textColor = [UIColor blueColor];
                break;
            default:
                break;
        }
    }else if (subType == 6) {
        switch (columnIndex) {
            case 0:
                label.text = [fsemObj convertZeroToStringForAverage:fsemObj.fieldId1.calcValue];
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId1.calcValue];
                break;
            case 1:
                label.text = [fsemObj convertZeroToStringForAverage:fsemObj.fieldId2.calcValue];
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId2.calcValue];
                break;
            case 2:
                label.text = [fsemObj convertZeroToStringForAverage:fsemObj.fieldId3.calcValue];
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId3.calcValue];
                break;
            case 3:
                label.text = [fsemObj convertZeroToStringForAverage:fsemObj.fieldId4.calcValue];
                label.textColor = [fsemObj compareToZeroForEX:fsemObj.fieldId4.calcValue];
                break;
            case 4:
                label.text = [fsemObj convertAverageValueToString:fsemObj.fieldId5.calcValue];
                label.textColor = [fsemObj compareToZero:fsemObj.fieldId5.calcValue];
                break;
            default:
                break;
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
        
    }else if ([sender isEqual:rightBtn]){
        rightActionSheet = [[UIActionSheet alloc]initWithTitle:@"平均年份" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        int i;
        for(i = 0; i < [rightBtnNameArray count]; i++){
            NSString *rightBtnTitle = [rightBtnNameArray objectAtIndex:i];
            [rightActionSheet addButtonWithTitle:rightBtnTitle];
        }
        [rightActionSheet addButtonWithTitle:@"取消"];
        [rightActionSheet setCancelButtonIndex:i];
        [rightActionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    stillDownLoad = NO;
    
    if ([actionSheet isEqual:leftActionSheet] && buttonIndex < [leftBtnNameArray count]) {
        [leftBtn setTitle:[leftActionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        [self whichTableViewArrayShow:(int)buttonIndex];
        [self addDirctionDown];
        sameTag = NO;
        lastTag = 1;
        btnIdx = (int)buttonIndex;
        if (subType == 6) {
            [self sendPacketWithSubType:6 SectorId:sectorID orderByFiledId:1 direction:1 parameter1:recentYear];
        }else{
            [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:1 direction:1];
        }
        [skMainTableView reloadAllData];
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
        if (subType == 6) {
            [self sendPacketWithSubType:6 SectorId:sectorID orderByFiledId:fieldID direction:direction parameter1:recentYear];
        }else{
            [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
        }
    }else if ([actionSheet isEqual:rightActionSheet] && buttonIndex < [rightBtnNameArray count]){
        [rightBtn setTitle:[rightActionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        recentYear = (int)buttonIndex + 1;
        [self sendPacketWithSubType:6 SectorId:sectorID orderByFiledId:fieldID direction:direction parameter1:recentYear];
    }
}

-(void)whichTableViewArrayShow:(int)idx{
    rightBtn.hidden = YES;
    [tableViewArray removeAllObjects];
    
    switch (idx) {
        case 0:
            tableViewArray = [NSMutableArray arrayWithArray:revenueArray];
            subType = 16;
            break;
        case 1:
            tableViewArray = [NSMutableArray arrayWithArray:profitabilityRatiosArray1];
            subType = 17;
            break;
        case 2:
            tableViewArray = [NSMutableArray arrayWithArray:growArray2];
            subType = 18;
            break;
        case 3:
            tableViewArray = [NSMutableArray arrayWithArray:financialStrengthArray3];
            subType = 19;
            break;
        case 4:
            tableViewArray = [NSMutableArray arrayWithArray:managemnetEffectivenessArray4];
            subType = 20;
            break;
        case 5:
            tableViewArray = [NSMutableArray arrayWithArray:financialStructureArray5];
            subType = 21;
            break;
        case 6:
            tableViewArray = [NSMutableArray arrayWithArray:exArray6];
            subType = 5;
            break;
        case 7:
            tableViewArray = [NSMutableArray arrayWithArray:averageArray7];
            subType = 6;
            rightBtn.hidden = NO;
            break;
        default:
            break;
    }

}
-(void)addDirctionDown{

    [tableViewArray replaceObjectAtIndex:0 withObject:[[tableViewArray objectAtIndex:0]stringByAppendingString:@"⬇︎"]];
    [self.view setNeedsUpdateConstraints];
}
-(void)labelTap:(UILabel *)label{
    stillDownLoad = NO;
    
    fieldID = (int)label.tag;
    
    if (subType == 16){
        if (label.tag == 2) {
            fieldID = 5;
        }else if (label.tag == 5){
            fieldID = 10;
        }else if (label.tag == 6){
            fieldID = 11;
        }
    }else if (subType == 5){
        if (label.tag == 10) {
            fieldID = 11;
        }else if (label.tag == 11){
            fieldID = 12;
        }else if (label.tag == 12){
            fieldID = 13;
        }else if (label.tag == 13){
            fieldID = 10;
        }
    }
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
        if (subType == 6) {
            [self sendPacketWithSubType:subType SectorId:sectorID orderByFiledId:fieldID direction:direction parameter1:recentYear];
        }else{
            [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
        }
        lastTag = (int)label.tag;
        skMainTableView.focuseLabel = lastTag;
    }
}
-(void)notifyDataArrive:(NSMutableArray *)array{

    
    
//如果下來資料是空的就重送 直到重送次數超過三次
    if ([array firstObject] == nil) {
        if (sendcount <= 3) {
            sendcount ++;
            if (subType == 6) {
                [self sendPacketWithSubType:subType SectorId:sectorID orderByFiledId:fieldID direction:direction parameter1:recentYear];
            }else{
                [self sendPacketWithSubType:subType sectorID:sectorID orderByFiledId:fieldID direction:direction];
            }
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


-(void)sendPacketWithSubType:(int)sT sectorID:(int)sID orderByFiledId:(int)oBFID direction:(int)d{
    [fromStockRank removeAllObjects];
    [skMainTableView reloadDataNoOffset];
    
    StockRankOut *packet = [[StockRankOut alloc]initWithSubType:sT SectorCount:1 SectorId:sID orderByFiledId:oBFID direction:d requestCount:80];
    [FSDataModelProc sendData:self WithPacket:packet];

}
-(void)sendPacketWithSubType:(UInt8)st SectorId:(UInt16)si orderByFiledId:(UInt8)obfi direction:(UInt8)d parameter1:(UInt8)p {
    [fromStockRank removeAllObjects];
    [skMainTableView reloadDataNoOffset];
    
    StockRankOut *packet = [[StockRankOut alloc]initWithSubType:st SectorId:si orderByFiledId:obfi direction:d parameter1:p requestCount:80];
    [FSDataModelProc sendData:self WithPacket:packet];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
