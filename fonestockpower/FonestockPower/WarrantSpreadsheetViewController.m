//
//  WarrantSpreadsheetViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantSpreadsheetViewController.h"
#import "SKCustomTableView.h"

@interface WarrantSpreadsheetViewController ()<SKCustomTableViewDelegate>
{
    UILabel *subjectSymbolLabel;
    UILabel *subjectPriceLabel;
    UILabel *targetPriceLabel;
    UILabel *dateLabel;
    UILabel *brokersLabel;
    UILabel *hvFluctuationLabel;
    UILabel *targetFluctuationLabel;
    
    FSUIButton *subjectSymbolBtn;
    UILabel *subjectPriceContent;
    FSUIButton *targetPriceBtn;
    FSUIButton *dateBtn;
    FSUIButton *brokersBtn;
    UILabel *hvFluctuationContent;
    FSUIButton *targetFluctuationBtn;
    
    SKCustomTableView *mainTableView;
    NSString *targetIdentCodeSymbol;
    NSString *targetName;
    FSDataModelProc *model;
    EquitySnapshotDecompressed *snapShot;
}
@end

@implementation WarrantSpreadsheetViewController

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
    [self initModel];
	[self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    targetIdentCodeSymbol = @"TW 2206";
    targetName = @"三陽";
    model = [FSDataModelProc sharedInstance];
    [model.portfolioData setTarget:self];
    
    NewSymbolObject * symbolObj = [[NewSymbolObject alloc] init];
    symbolObj.identCode = [targetIdentCodeSymbol substringToIndex:2];
    symbolObj.symbol = [targetIdentCodeSymbol substringFromIndex:3];
    symbolObj.fullName = targetName;
    [model.portfolioData addWatchListItemNewSymbolObjArray:@[symbolObj]];
}

-(void)sendHandler
{
    snapShot = [model.portfolioTickBank getSnapshotFromIdentCodeSymbol:targetIdentCodeSymbol];
    [model.warrant setTarget:self];
    [model.warrant.warrantArray removeAllObjects];
    [model.warrant sendIdentSymbol:targetIdentCodeSymbol function:5 fullName:targetName targetPrice:snapShot.ceilingPrice];
}

-(void)initView
{
    subjectSymbolLabel = [[UILabel alloc] init];
    subjectSymbolLabel.text = NSLocalizedStringFromTable(@"權證標的", @"Warrant", nil);
    subjectSymbolLabel.textColor = [UIColor blueColor];
    subjectSymbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectSymbolLabel];
    
    subjectPriceLabel = [[UILabel alloc] init];
    subjectPriceLabel.text = NSLocalizedStringFromTable(@"標的現價", @"Warrant", nil);
    subjectPriceLabel.textColor = [UIColor blueColor];
    subjectPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectPriceLabel];
    
    targetPriceLabel = [[UILabel alloc] init];
    targetPriceLabel.text = NSLocalizedStringFromTable(@"目標價格", @"Warrant", nil);
    targetPriceLabel.textColor = [UIColor blueColor];
    targetPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetPriceLabel];
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.text = NSLocalizedStringFromTable(@"評價日期", @"Warrant" , nil);
    dateLabel.textColor = [UIColor blueColor];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dateLabel];
    
    brokersLabel = [[UILabel alloc] init];
    brokersLabel.text = NSLocalizedStringFromTable(@"券商", @"Warrnat", nil);
    brokersLabel.textColor = [UIColor blueColor];
    brokersLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokersLabel];
    
    hvFluctuationLabel = [[UILabel alloc] init];
    hvFluctuationLabel.text = NSLocalizedStringFromTable(@"歷史波動", @"Warrant", nil);
    hvFluctuationLabel.textColor = [UIColor blueColor];
    hvFluctuationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hvFluctuationLabel];
    
    targetFluctuationLabel = [[UILabel alloc] init];
    targetFluctuationLabel.text = NSLocalizedStringFromTable(@"目標波動%", @"Warrant", nil);
    targetFluctuationLabel.textColor = [UIColor blueColor];
    targetFluctuationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetFluctuationLabel];
    
    subjectSymbolBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    subjectSymbolBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectSymbolBtn];
    
    subjectPriceContent = [[UILabel alloc] init];
    subjectPriceContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectPriceContent];
    
    targetPriceBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    targetPriceBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetPriceBtn];
    
    dateBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    dateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dateBtn];
    
    brokersBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    brokersBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokersBtn];
    
    hvFluctuationContent = [[UILabel alloc] init];
    hvFluctuationContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hvFluctuationContent];
    
    targetFluctuationBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    targetFluctuationBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetFluctuationBtn];
    
    mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:33];
    mainTableView.delegate = self;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
    
   // [self updateViewConstraints];
}

- (NSArray *)columnsInFixedTableView {
    return @[@"權證"];
}

- (NSArray *)columnsInMainTableView {
    return @[@"成交",
             @"預估價",
             @"報酬",
             @"類型",
             @"履約\n方式",
             @"上下\n限型",
             @"履約價",
             @"價內外",
             @"剩餘天數",
             @"隱含波動",
             @"實質\n槓桿",
             @"距損\n平點"];
}

- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (columnIndex == 0) {
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = @"aaa";
    }
}

- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    label.text = @"bBB";
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)updateViewConstraints
{
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(subjectSymbolLabel, subjectSymbolBtn, subjectPriceLabel, subjectPriceContent, targetPriceLabel, targetPriceBtn, dateLabel, dateBtn, brokersLabel, brokersBtn, hvFluctuationLabel, hvFluctuationContent, targetFluctuationLabel, targetFluctuationBtn, mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subjectSymbolLabel][subjectSymbolBtn(==subjectSymbolLabel)][brokersLabel(==subjectSymbolLabel)][brokersBtn(==subjectSymbolLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subjectPriceLabel][subjectPriceContent(==subjectPriceLabel)][hvFluctuationLabel(==subjectPriceLabel)][hvFluctuationContent(==subjectPriceLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[targetPriceLabel][targetPriceBtn(==targetPriceLabel)][targetFluctuationLabel(==targetPriceLabel)][targetFluctuationBtn(==targetPriceLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dateLabel(==targetPriceLabel)][dateBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subjectSymbolLabel(37)][subjectPriceLabel(==subjectSymbolLabel)][targetPriceLabel(==subjectSymbolLabel)][dateLabel(==subjectSymbolLabel)][mainTableView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subjectSymbolBtn(==subjectSymbolLabel)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subjectPriceContent(==subjectSymbolLabel)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[targetPriceBtn(==subjectSymbolLabel)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[dateBtn(==subjectSymbolLabel)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[brokersBtn(==subjectSymbolLabel)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hvFluctuationContent(==subjectSymbolLabel)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[targetFluctuationBtn(==subjectSymbolLabel)]" options:0 metrics:nil views:viewDictionary]];
    
    [super updateViewConstraints];
}
@end
