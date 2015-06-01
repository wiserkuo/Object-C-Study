//
//  TQuoteViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TQuoteViewController.h"
#import "FSOptionTableView.h"

@interface TQuoteViewController ()<FSOptionTableViewDelegate>
{
    UILabel *targetLabel;
    FSUIButton *targetButton;
    UILabel *brokerageLabel;
    FSUIButton *brokerageButton;
    UILabel *priceTitleLabel;
    UILabel *priceLabel;
    UILabel *changeTitleLabel;
    UILabel *changeLabel;
    UILabel *waveTitleLabel;
    UILabel *waveLabel;
    UILabel *ratioTitleLabel;
    UILabel *ratioLabel;
    UIView *headerView;
    UILabel *leftLabel;
    UILabel *rightLabel;
    FSOptionTableView *mainTableView;
}
@end

@implementation TQuoteViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    targetLabel = [[UILabel alloc] init];
    targetLabel.translatesAutoresizingMaskIntoConstraints = NO;
    targetLabel.text = @"權證標的";
    targetLabel.textColor = [UIColor blueColor];
    [self.view addSubview:targetLabel];
    
    targetButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    targetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetButton];
    
    brokerageLabel = [[UILabel alloc] init];
    brokerageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageLabel.text = @"券商";
    brokerageLabel.textAlignment = NSTextAlignmentCenter;
    brokerageLabel.textColor = [UIColor blueColor];
    [self.view addSubview:brokerageLabel];
    
    brokerageButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    brokerageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokerageButton];
    
    priceTitleLabel = [[UILabel alloc] init];
    priceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    priceTitleLabel.text = @"標的現價";
    priceTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:priceTitleLabel];
    
    priceLabel = [[UILabel alloc] init];
    priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:priceLabel];
    
    changeTitleLabel = [[UILabel alloc] init];
    changeTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    changeTitleLabel.text = @"漲跌";
    changeTitleLabel.textAlignment = NSTextAlignmentCenter;
    changeTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:changeTitleLabel];
    
    changeLabel = [[UILabel alloc] init];
    changeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:changeLabel];
    
    waveTitleLabel = [[UILabel alloc] init];
    waveTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    waveTitleLabel.text = @"歷史波動";
    waveTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:waveTitleLabel];
    
    waveLabel = [[UILabel alloc] init];
    waveLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:waveLabel];
    
    ratioTitleLabel = [[UILabel alloc] init];
    ratioTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    ratioTitleLabel.text = @"漲幅";
    ratioTitleLabel.textAlignment = NSTextAlignmentCenter;
    ratioTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:ratioTitleLabel];
    
    ratioLabel = [[UILabel alloc] init];
    ratioLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ratioLabel];
    
    headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    headerView.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    [self.view addSubview:headerView];
    
    leftLabel = [[UILabel alloc] init];
    leftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    leftLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.text = @"認購";
    leftLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:leftLabel];
    
    rightLabel = [[UILabel alloc] init];
    rightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    rightLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.text = @"認售";
    rightLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:rightLabel];
    
    mainTableView = [[FSOptionTableView alloc] initWithleftColumnWidth:66 fixedColumnWidth:66 rightColumnWidth:66 AndColumnHeight:30];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    [self.view addSubview:mainTableView];
    

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)updateLeftTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)updateRightTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"履約價", @"", nil)];
}

-(NSArray *)columnsInLeftTableView{
    return @[NSLocalizedStringFromTable(@"買價", @"", nil), NSLocalizedStringFromTable(@"賣價", @"", nil), NSLocalizedStringFromTable(@"成交", @"", nil), NSLocalizedStringFromTable(@"總量", @"", nil), NSLocalizedStringFromTable(@"漲跌", @"", nil), NSLocalizedStringFromTable(@"IV", @"", nil), NSLocalizedStringFromTable(@"天數", @"", nil), NSLocalizedStringFromTable(@"距損平點", @"", nil)];
}

-(NSArray *)columnsInRightTableView{
    return @[NSLocalizedStringFromTable(@"買價", @"", nil), NSLocalizedStringFromTable(@"賣價", @"", nil), NSLocalizedStringFromTable(@"成交", @"", nil), NSLocalizedStringFromTable(@"總量", @"", nil), NSLocalizedStringFromTable(@"漲跌", @"", nil), NSLocalizedStringFromTable(@"IV", @"", nil), NSLocalizedStringFromTable(@"天數", @"", nil), NSLocalizedStringFromTable(@"距損平點", @"", nil)];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(targetLabel, targetButton, brokerageLabel, brokerageButton, priceTitleLabel, priceLabel, changeTitleLabel, changeLabel, waveTitleLabel, waveLabel, ratioTitleLabel, ratioLabel, headerView, leftLabel, rightLabel, mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[targetLabel][targetButton(==targetLabel)][brokerageLabel(==targetLabel)][brokerageButton(==targetLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:Nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[priceTitleLabel][priceLabel(==priceTitleLabel)][changeTitleLabel(==priceTitleLabel)][changeLabel(==priceTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:Nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[waveTitleLabel][waveLabel(==waveTitleLabel)][ratioTitleLabel(==waveTitleLabel)][ratioLabel(==waveTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:Nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerView]|" options:0 metrics:Nil views:viewDictionary]];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftLabel]-50-[rightLabel(==leftLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:Nil views:viewDictionary]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLabel]|" options:0 metrics:Nil views:viewDictionary]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:Nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[targetLabel(33)][priceTitleLabel(==targetLabel)][waveTitleLabel(==targetLabel)][headerView(33)][mainTableView]|" options:0 metrics:Nil views:viewDictionary]];
    
}
@end
