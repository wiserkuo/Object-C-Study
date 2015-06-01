//
//  FSEmergingQuotesViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSEmergingQuotesViewController.h"
#import "SKCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSEmergingObject.h"
#import "InternationalInfoObject_v1.h"
#import "FSDataModelProc.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface FSEmergingQuotesViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate>
{
    UILabel *brokerageLabel;
    UIButton *brokerageBtn;
    NSString *QuotesCatID;

    NSMutableArray *verticalConstraints;
    NSMutableArray *quoteMutableArray;
    NSMutableArray *tempMutableArray;
    NSMutableArray *contentMutableArray;
    NSMutableArray *getCatNameMutableArray;
    
    NewSymbolObject *obj;
    SKCustomTableView *brokerageTableView;
    RecObject *recOO;
    FSEmergingQuotes * QuotesObj;
    FSDataModelProc *dataModel;
    InternationalInfoObject_v1 *inter;
    FSEmergingObject *fsemObj;


}
@end

@implementation FSEmergingQuotesViewController
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
    [self firstTableViewContent];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![RecObject sharedInstance].brokerName) {
        [brokerageBtn setTitle:@"食品工業" forState:UIControlStateNormal];
    }else {
        [brokerageBtn setTitle:[NSString stringWithFormat:@"%@",[RecObject sharedInstance].brokerName] forState:UIControlStateNormal];
    }
}
-(void)initView{
 
    
    [self setUpImageBackButton];
    recOO = [[RecObject alloc]init];
    QuotesObj = [[FSEmergingQuotes alloc]init];
    getCatNameMutableArray = [QuotesObj getQuotesCatName];
    quoteMutableArray = [[NSMutableArray alloc]init];
    inter = [[InternationalInfoObject_v1 alloc]init];
    dataModel = [FSDataModelProc sharedInstance];
    fsemObj = [[FSEmergingObject alloc]init];
    self.title = NSLocalizedStringFromTable(@"興櫃行情", @"Emerging", nil);
    
    verticalConstraints = [[NSMutableArray alloc]init];
    
    brokerageLabel = [[UILabel alloc]init];
    brokerageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageLabel.text = @"類別";
    brokerageLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [self.view addSubview:brokerageLabel];
    
    brokerageBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    brokerageBtn.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageBtn.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [brokerageBtn addTarget:self action:@selector(choiceHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:brokerageBtn];
    
    brokerageTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:77 mainColumnWidth:70 AndColumnHeight:44];
    
    brokerageTableView.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageTableView.delegate = self;
    [self.view addSubview:brokerageTableView];
    
    [self.view setNeedsUpdateConstraints];
}
-(void)firstTableViewContent{
    
    //進入第一次的TableView內容---
    if (![RecObject sharedInstance].actionSheetTapIndex) {
        QuotesObj = [getCatNameMutableArray objectAtIndex:0];
    }else {
        QuotesObj = [getCatNameMutableArray objectAtIndex:[RecObject sharedInstance].actionSheetTapIndex];
    }
    [dataModel.securityName setTarget:self];
    [dataModel.securityName selectCatID:[QuotesObj.QuotesCatID intValue]];
    QuotesCatID = QuotesObj.QuotesCatID;
    contentMutableArray = [QuotesObj getQuotesCatNewObj:QuotesObj.QuotesCatID];
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:contentMutableArray];
    //-------------------------
}

-(void)updateViewConstraints{
    [super updateViewConstraints];

    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *mainViewArray = NSDictionaryOfVariableBindings(brokerageLabel, brokerageBtn, brokerageTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[brokerageLabel(50)]-[brokerageBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[brokerageLabel]" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[brokerageTableView]|" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[brokerageBtn]-2-[brokerageTableView]|" options:0 metrics:nil views:mainViewArray]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex < [getCatNameMutableArray count]) {
        [RecObject sharedInstance].actionSheetTapIndex = buttonIndex;
        QuotesObj = [getCatNameMutableArray objectAtIndex: buttonIndex ];
        [brokerageBtn setTitle:[NSString stringWithFormat:@"%@",QuotesObj.QuotesCatName] forState:UIControlStateNormal];
        [RecObject sharedInstance].brokerName = QuotesObj.QuotesCatName;
        [dataModel.portfolioData removeWatchListItemByIdentSymbolArray];
        [dataModel.portfolioTickBank removeIndexQuotesAllKeyWithTaget:self];
        [dataModel.securityName setTarget:self];
        [dataModel.securityName selectCatID:[QuotesObj.QuotesCatID intValue]];
        QuotesCatID = QuotesObj.QuotesCatID;
    }    
}
-(void)notify{
    contentMutableArray = [QuotesObj getQuotesCatNewObj:QuotesCatID];
    
    [dataModel.portfolioData setTarget:self];
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:contentMutableArray];
    if ([contentMutableArray count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"沒有個股資訊" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil];
        [alert show];
    }
    [brokerageTableView reloadAllData];
}
-(void)reloadData{
    [brokerageTableView reloadAllData];
    for (obj in contentMutableArray) {
        [dataModel.portfolioTickBank setTaget:self IdentCodeSymbol:[NSString stringWithFormat:@"%@ %@", obj.identCode, obj.symbol]];
    }
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    obj = [contentMutableArray objectAtIndex:indexPath.row];
    label.textColor = [UIColor blueColor];
    label.text = obj.fullName;
    label.textAlignment = NSTextAlignmentLeft;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    obj = [contentMutableArray objectAtIndex:indexPath.row];
    EquitySnapshotDecompressed *mySnapShot = [dataModel.portfolioTickBank getSnapshotFromIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@", obj.identCode, obj.symbol]];
    CGFloat change = 0.0;
    if (columnIndex == 0) {
        label.text = [fsemObj convertQuotesToString:mySnapShot.bid];
        label.textColor = [inter compareToZero:(mySnapShot.bid - mySnapShot.referencePrice)];
    }
    else if (columnIndex == 1) {
        label.text = [fsemObj convertQuotesToString:mySnapShot.ask];
        label.textColor = [inter compareToZero:(mySnapShot.ask - mySnapShot.referencePrice)];
    }
    else if (columnIndex == 2) {
        label.textColor = [inter compareToZero:(mySnapShot.currentPrice - mySnapShot.referencePrice)];
        if (mySnapShot.referencePrice == 0 || mySnapShot.currentPrice == 0) {
            label.textColor = [UIColor blackColor];
        }
        label.text = [fsemObj convertQuotesToString:mySnapShot.currentPrice];
        
    }
    else if (columnIndex == 3) {
        label.text = [fsemObj convertQuotesToString:mySnapShot.highestPrice];
        label.textColor = [inter compareToZero:(mySnapShot.highestPrice - mySnapShot.referencePrice)];
        if (mySnapShot.referencePrice == 0 || mySnapShot.currentPrice == 0) {
            label.textColor = [UIColor blackColor];
        }
    }
    else if (columnIndex == 4) {
        label.text = [fsemObj convertQuotesToString:mySnapShot.lowestPrice];
        label.textColor = [inter compareToZero:(mySnapShot.lowestPrice - mySnapShot.referencePrice)];
        if (mySnapShot.referencePrice == 0 || mySnapShot.currentPrice == 0) {
            label.textColor = [UIColor blackColor];
        }
    }
    else if (columnIndex == 5) {//漲跌
        change = (mySnapShot.currentPrice - mySnapShot.referencePrice);
        label.textColor = [inter compareToZeroRecUse:change];
        if (mySnapShot.currentPrice == 0) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [inter formatCGFloatDataChange:change];
        }
    }
    else if (columnIndex == 6) {//漲跌幅
        change = ((mySnapShot.currentPrice - mySnapShot.referencePrice) / mySnapShot.referencePrice * 10000) / 100;
        label.textColor = [inter compareToZeroRecUse:change];
        if (mySnapShot.currentPrice == 0 || mySnapShot.referencePrice == 0) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [inter formatCGFloatData:change];

        }

    }
    else if (columnIndex == 7) {
        label.text = [fsemObj convertZeroToString:mySnapShot.volume];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:131.0f/255.0f alpha:1.0f];
        if (mySnapShot.volume == 0) {
            label.textColor = [UIColor blackColor];
        }
    }
    else if (columnIndex == 8) {
        label.text = [fsemObj convertZeroToString:mySnapShot.accumulatedVolume];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:131.0f/255.0f alpha:1.0f];
        if (mySnapShot.accumulatedVolume == 0) {
            label.textColor = [UIColor blackColor];
        }
    }
    else if (columnIndex == 9) {//週轉率
        if (mySnapShot.issuedShares == 0 || mySnapShot.accumulatedVolume == 0) {
            label.text = [NSString stringWithFormat:@"----"];
            label.textColor = [UIColor blackColor];
        }else{
            double issuedShares = [[CodingUtil getValueString_2:mySnapShot.issuedShares Unit:mySnapShot.issuedSharesUnit]doubleValue];
            label.text = [NSString stringWithFormat:@"%.2f%%", (mySnapShot.accumulatedVolume / issuedShares) / 10];
            label.textColor = [UIColor blueColor];
        }
    }
;
    label.textAlignment = NSTextAlignmentRight;
}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"名稱", @"Emerging", @"nil")];
}

-(NSArray *)columnsInMainTableView{
    return @[NSLocalizedStringFromTable(@"買進", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"賣出", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"成交", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"最高", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"最低", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"漲跌", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"漲跌幅", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"單量", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"總量", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"週轉率", @"Emerging", @"nil")];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [contentMutableArray count];
}
-(void)choiceHandler:(UIButton *)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"類別" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for (i = 0; i < [getCatNameMutableArray count]; i++){
        QuotesObj = [getCatNameMutableArray objectAtIndex:i];
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", QuotesObj.QuotesCatName]];
    }
    [actionSheet setCancelButtonIndex:i];
    [actionSheet addButtonWithTitle:@"取消"];
    [actionSheet showInView:self.view.window];
}

-(void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource{
    if ([dataSource isKindOfClass:[EquityTick class]]) {
        EquityTick *data = (EquityTick *)dataSource;
        NSString *identCodeSymbol = data.identCodeSymbol;
        int row = -1;
        
        for (int i = 0; i < [contentMutableArray count]; i ++){
                obj = [contentMutableArray objectAtIndex:i];
            if ([identCodeSymbol isEqualToString:[NSString stringWithFormat:@"%@ %@", obj.identCode, obj.symbol]]) {
                row = i;
                break;
            }
        }
        if (row >= 0) {
            if (row<[[brokerageTableView indexPathsForVisibleRows]count]) {
                NSIndexPath *indexPath = [[brokerageTableView indexPathsForVisibleRows]objectAtIndex:row];
                [brokerageTableView.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    obj = [contentMutableArray objectAtIndex:indexPath.row];
    FSMainViewController *mainView = [[FSMainViewController alloc]init];
    
    NSString *identCodeSymbol = [NSString stringWithFormat:@"%@ %@", obj.identCode, obj.symbol];
    
    PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
    FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    
    instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
    //push to mainView 技術頁
    mainView.firstLevelMenuOption = 1;
    [self.navigationController pushViewController:mainView animated:NO];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
