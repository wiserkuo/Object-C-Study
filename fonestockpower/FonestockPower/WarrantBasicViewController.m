//
//  WarrantBasicViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantBasicViewController.h"
#import "WarrantBasicTableViewCell.h"
#import "FSInstantInfoWatchedPortfolio.h"
@interface WarrantBasicViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *mainTableView;
    NSMutableArray *leftTextArray;
    UIColor *yellowColor;
    NSDateFormatter *formatter;
    UInt16 todayDate;
    FSDataModelProc *model;
    PortfolioItem *portfolioItem;
    NSMutableDictionary *mainDict;
}

@end

@implementation WarrantBasicViewController

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
    todayDate = [[[NSDate alloc] init]uint16Value];
    yellowColor = [UIColor colorWithRed:190.0/255.0 green:138.0/255.0 blue:0 alpha:1];
    [self initModel];
	[self initTableView];
    [self.view setNeedsUpdateConstraints];
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    [model.warrant setTarget:self];
    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
    if(portfolioItem!=nil){
        [model.warrant sendWarrantBasicData:portfolioItem->commodityNo blockMask:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTableView
{
    leftTextArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"發行券商", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"類型", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"履約方式", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"標的", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"履約價", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"界限價", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"行使比例", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"最後交易日", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"到期日", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"剩餘天數", @"Warrant", nil),
                                                           NSLocalizedStringFromTable(@"發行量", @"Warrant", nil), nil];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    
    
    mainTableView = [[UITableView alloc]init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    if(mainDict){
        if(indexPath.row == 0){
            cell.rightText.text = [model.warrant getBrokerName:[mainDict objectForKey:@"BrokersID"]];
            cell.rightText.textColor = yellowColor;
        }else if(indexPath.row == 1){
            cell.rightText.text = [mainDict objectForKey:@"Type"];
            cell.rightText.textColor = yellowColor;
        }else if(indexPath.row == 2){
            cell.rightText.text = [mainDict objectForKey:@"Method"];
            cell.rightText.textColor = yellowColor;
        }else if(indexPath.row == 3){
            cell.rightText.text = [model.warrant getFullName:[[mainDict objectForKey:@"IdentCodeSymbol"]substringFromIndex:3]];
            cell.rightText.textColor = yellowColor;
        }else if(indexPath.row == 4){
            
            cell.rightText.text = [mainDict objectForKey:@"ExercisePrice"];
            cell.rightText.textColor = [UIColor brownColor];
        }else if(indexPath.row == 5){
            cell.rightText.text = [mainDict objectForKey:@"LimitPrice"];//界限價
        }else if(indexPath.row == 6){
            cell.rightText.text = [mainDict objectForKey:@"Proportion"];
            cell.rightText.textColor = [UIColor blueColor];
        }else if(indexPath.row == 7){
            //最後交易日
            cell.rightText.text = [mainDict objectForKey:@"FinalTradeDate"];
            cell.rightText.textColor = [UIColor blueColor];
        }else if(indexPath.row == 8){
            //到期日
            cell.rightText.text = [mainDict objectForKey:@"EndDate"];
            cell.rightText.textColor = [UIColor blueColor];
        }else if(indexPath.row == 9){
            //剩餘天數
            cell.rightText.textColor = [UIColor blueColor];
            cell.rightText.text = [NSString stringWithFormat:@"%@(天)", [mainDict objectForKey:@"Day"]];
        }else if(indexPath.row == 10){
            //發行量
            cell.rightText.textColor = [UIColor blueColor];
            cell.rightText.text = [NSString stringWithFormat:@"%@(張)", [mainDict objectForKey:@"Volume"]];
        }
    }else{
        cell.rightText.text = @"----";
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [leftTextArray count];
}
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(mainTableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(void)notifyBasicData:(NSMutableDictionary *)data
{
    mainDict = data;
    [mainTableView reloadData];
}


@end
