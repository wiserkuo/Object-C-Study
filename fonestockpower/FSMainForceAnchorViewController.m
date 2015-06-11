//
//  FSMainForceAnchorViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainForceAnchorViewController.h"
#import "SKCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSDataModelProc.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSMainForceViewController.h"


@interface FSMainForceAnchorViewController ()<SKCustomTableViewDelegate>{
    
    UILabel *titleLeftLabel;
    UILabel *titleRightLabel;
    SKCustomTableView *skMainTableView;
    NSMutableArray *tableViewTitle;
    FSDataModelProc *dataModel;
    NSMutableArray *fromBrokers;
    NSMutableArray *mainForceArray;
    FSMainForceAnchorData *mainForce;
    PortfolioItem *portfolioItem;
    NSString *brokerAnchorName;
    MBProgressHUD *hud;

}

@end

@implementation FSMainForceAnchorViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dataModel = [FSDataModelProc sharedInstance];
    [dataModel.brokers setTargetNotifyByAnchor:self];
    
    [hud show:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [dataModel.brokers setTargetNotifyByAnchor:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initVar];
    
    // Do any additional setup after loading the view.
}

-(void)initView{

    self.title = @"券商進出表";
    [self setUpImageBackButton];

    [self.navigationController setNavigationBarHidden:NO];
    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    titleLeftLabel = [[UILabel alloc]init];
    titleLeftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLeftLabel.font = [UIFont systemFontOfSize:22.0f];
    titleLeftLabel.text = [NSString stringWithFormat:@"券商:%@", [BrokersByModel sharedInstance].brokerName];
//    titleLeftLabel.text = [NSString stringWithFormat:@"券商:%@", [BrokersByModel sharedInstance].brokerAnchorName];

    [self.view addSubview:titleLeftLabel];

    titleRightLabel = [[UILabel alloc]init];
    titleRightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleRightLabel.font = [UIFont systemFontOfSize:22.0f];
    if ([BrokersByModel sharedInstance].brokerStockName) {
        titleRightLabel.text = [NSString stringWithFormat:@"股名:%@",[BrokersByModel sharedInstance].brokerStockName];
    }else{
        titleRightLabel.text = [NSString stringWithFormat:@"股名:%@",portfolioItem -> fullName];
    }
    [self.view addSubview:titleRightLabel];
    
    skMainTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:100 mainColumnWidth:77 AndColumnHeight:44];
    skMainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    skMainTableView.delegate = self;
    [self.view addSubview:skMainTableView];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.view setNeedsUpdateConstraints];
}
-(void)initVar{
    tableViewTitle = [[NSMutableArray alloc]initWithObjects:@"買賣超", @"買進", @"賣出", @"買均價", @"賣均價", nil];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(titleLeftLabel, titleRightLabel, skMainTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLeftLabel]-[titleRightLabel]-40-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[skMainTableView]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[titleLeftLabel]-5-[skMainTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
    
}
-(void)notifyData{
    fromBrokers = [NSMutableArray arrayWithArray:[dataModel.brokers mainAnchorArray]];
    mainForceArray = [[NSMutableArray alloc] init];

    for (int i = 0; i < [fromBrokers count]; i++) {
        mainForce = [[FSMainForceAnchorData alloc] init];

        mainForce.buy = [[[fromBrokers objectAtIndex:i] objectForKey:@"BuyShare"] doubleValue];
        mainForce.sell = [[[fromBrokers objectAtIndex:i] objectForKey:@"SellShare"] doubleValue];
        mainForce.buyAvg = [[[fromBrokers objectAtIndex:i] objectForKey:@"BuyAmnt"] doubleValue];
        mainForce.sellAvg = [[[fromBrokers objectAtIndex:i] objectForKey:@"SellAmnt"] doubleValue];
        mainForce.overBought = [[[fromBrokers objectAtIndex:i] objectForKey:@"BuySellShare"] doubleValue];
        [mainForceArray addObject:mainForce];
    }
    
    [skMainTableView reloadAllData];
    
    [hud hide:YES];
}
-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *startDateStrTmp = [CodingUtil getStringDatePlusZero:[[[fromBrokers objectAtIndex:indexPath.row] objectForKey:@"Date"]longValue]];
    
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blueColor];
    label.text = startDateStrTmp;
    
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    mainForce = [mainForceArray objectAtIndex:indexPath.row];
    if (mainForce.overBought > 0) {
        label.textColor = [StockConstant PriceUpColor];
    }else if (mainForce.overBought < 0){
        label.textColor = [StockConstant PriceDownColor];
    }else{
        label.textColor = [UIColor blueColor];
    }
    if (columnIndex == 0) {
        if (mainForce.overBought > 0) {
            label.text = [NSString stringWithFormat:@"+%.f", mainForce.overBought];
        }else if (mainForce.overBought <= 0){
            label.text = [NSString stringWithFormat:@"%.f", mainForce.overBought];
        }else{
            label.text = @"----";
        }
    }
    if (columnIndex == 1) {
        label.text = [NSString stringWithFormat:@"%.f", mainForce.buy];
    }
    if (columnIndex == 2) {
        label.text = [NSString stringWithFormat:@"%.f", mainForce.sell];
    }
    if (columnIndex == 3) {
        if (isnan(mainForce.buyAvg/mainForce.buy)) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", floor(mainForce.buyAvg / mainForce.buy * 100) / 100];
        }
    }
    if (columnIndex == 4) {
        if (isnan(mainForce.sellAvg / mainForce.sell)) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", floor(mainForce.sellAvg / mainForce.sell * 100) / 100];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fromBrokers count];
}

-(NSArray *)columnsInFixedTableView{
    return @[@"日期"];
}

-(NSArray *)columnsInMainTableView{
    return tableViewTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
@implementation FSMainForceAnchorData

@end
