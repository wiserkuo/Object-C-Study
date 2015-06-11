//
//  ValueSummaryViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ValueSummaryViewController.h"
#import "WarrantBasicTableViewCell.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface ValueSummaryViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *mainTableView;
    NSMutableArray *layoutContrains;
    NSMutableArray *leftTextArray;
    FSDataModelProc *model;
    PortfolioItem *portfolioItem;
    NSMutableDictionary *mainDict;
}
@end

@implementation ValueSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initModel];
    [self initArray];
    [self initTableView];
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    [model.warrant setTarget:self];
    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
    if(portfolioItem!=nil){
        [model.warrant sendWarrantBasicData:portfolioItem->commodityNo blockMask:2];
    }
}

-(void)initArray
{
    leftTextArray = [[NSMutableArray alloc]initWithObjects:NSLocalizedStringFromTable(@"價內外", @"Warrant", nil),
                                                          NSLocalizedStringFromTable(@"時間價值", @"Warrant", nil),
                                                          NSLocalizedStringFromTable(@"內含價值", @"Warrant", nil),
                                                          NSLocalizedStringFromTable(@"損平點", @"Warrant", nil),NSLocalizedStringFromTable(@"距損平點", @"Warrant", nil),NSLocalizedStringFromTable(@"實質槓桿", @"Warrant", nil),NSLocalizedStringFromTable(@"BIV", @"Warrant", nil),NSLocalizedStringFromTable(@"SIV", @"Warrant", nil),NSLocalizedStringFromTable(@"IV", @"Warrant", nil),NSLocalizedStringFromTable(@"HV", @"Warrant", nil),NSLocalizedStringFromTable(@"流通在外比例", @"Warrant", nil),
                                                                @"",
                                                          NSLocalizedStringFromTable(@"Delta", @"Warrant", nil),
                                                          NSLocalizedStringFromTable(@"Gamma", @"Warrant", nil),
                                                          NSLocalizedStringFromTable(@"Vega", @"Warrant", nil),
                                                          NSLocalizedStringFromTable(@"Theta", @"Warrant", nil), nil];
}

-(void)initTableView
{
    layoutContrains = [[NSMutableArray alloc] init];
    
    mainTableView = [[UITableView alloc] init];
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view removeConstraints:layoutContrains];
    [layoutContrains removeAllObjects];
    
    [layoutContrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainTableView)]];
    [layoutContrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(mainTableView)]];
    
    [self.view addConstraints:layoutContrains];
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WarrantBasicCell";
    WarrantBasicTableViewCell *cell = (WarrantBasicTableViewCell *)[mainTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[WarrantBasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.leftText.text = [leftTextArray objectAtIndex:indexPath.row];
    if(indexPath.row == 0){
        
    }else if(indexPath.row == 1){
        
    }else if(indexPath.row == 2){
        
    }else if(indexPath.row == 3){
        
    }else if(indexPath.row == 4){
        
    }else if(indexPath.row == 5){
        cell.rightText.textColor = [UIColor blueColor];
    }else if(indexPath.row == 6){
        cell.rightText.text = [mainDict objectForKey:@"BIV"];
        cell.rightText.textColor = [UIColor blueColor];
    }else if(indexPath.row == 7){
        cell.rightText.text = [mainDict objectForKey:@"SIV"];
        cell.rightText.textColor = [UIColor blueColor];
    }else if(indexPath.row == 8){
        cell.rightText.textColor = [UIColor blueColor];
        cell.rightText.text = [mainDict objectForKey:@"IV"];
    }else if(indexPath.row == 9){
        cell.rightText.textColor = [UIColor blueColor];
        cell.rightText.text = [mainDict objectForKey:@"HV"];
    }else if(indexPath.row == 10){
        cell.rightText.textColor = [UIColor blueColor];
    }else if(indexPath.row == 11){
        cell.rightText.text = NSLocalizedStringFromTable(@"敏感度分析", @"Warrant", nil);
        cell.rightText.textAlignment = NSTextAlignmentCenter;
        cell.rightText.font = [UIFont boldSystemFontOfSize:20.0f];
        cell.rightText.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:230.0/255.0 blue:144.0/255.0 alpha:1];
    }else if(indexPath.row == 12){
        cell.rightText.text = [mainDict objectForKey:@"Delta"];
        cell.rightText.textAlignment = NSTextAlignmentCenter;
    }else if(indexPath.row == 13){
        cell.rightText.text = [mainDict objectForKey:@"Gamma"];
        cell.rightText.textAlignment = NSTextAlignmentCenter;
    }else if(indexPath.row == 14){
        cell.rightText.text = [mainDict objectForKey:@"Vega"];
        cell.rightText.textAlignment = NSTextAlignmentCenter;
    }else if(indexPath.row == 15){
        cell.rightText.text = [mainDict objectForKey:@"Theta"];
        cell.rightText.textAlignment = NSTextAlignmentCenter;
    }
    
    return cell;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [leftTextArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(void)notifySummaryData:(NSMutableDictionary *)data
{
    mainDict = data;
    [mainTableView reloadData];
}


@end
