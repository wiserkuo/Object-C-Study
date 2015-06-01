//
//  CompanyProfilePage3ViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage3ViewController.h"

@interface CompanyProfilePage3ViewController ()<UITableViewDataSource, UITableViewDelegate, MajorProductsDelegate, MajorHoldersDelegate>
{
    NSMutableDictionary *productDict;
    NSMutableDictionary *holderDict;
    UITableView *mainTableView;
    PortfolioItem *portfolioItem;
    FSDataModelProc *model;
}
@end

@implementation CompanyProfilePage3ViewController

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
	[self initMainTableView];
    [self processLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendHandler];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendHandler
{
    model = [FSDataModelProc sharedInstance];
    model.majorHolders.delegate = self;
    [model.majorHolders sendAndRead];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    model.majorProducts.delegate = nil;
    model.majorHolders.delegate = nil;
    productDict = nil;
    [mainTableView reloadData];
}

- (void)notifyProductData:(id)target {
    productDict = target;
    [mainTableView reloadData];
}

- (void)notifyHoldersData:(id)target{
    holderDict = target;
    model.majorHolders.delegate = nil;
    model.majorProducts.delegate = self;
    [model.majorProducts sendAndRead];
    [mainTableView reloadData];
}

-(void)initMainTableView
{
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.allowsSelection = NO;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
}


-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(mainTableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:Nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]-15-|" options:0 metrics:Nil views:viewController]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section ==0){
        if(!holderDict){
            return 0;
        }else{
            return [(NSNumber *)[holderDict objectForKey:@"MajorHoldersCount"] intValue];
        }
    }
    else{
        if(!productDict){
            return 0;
        }else{
            return [(NSNumber *)[productDict objectForKey:@"MajorProductsCount"] intValue];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    UIFont * font = [UIFont boldSystemFontOfSize:16.0f];
    cell.detailTextLabel.font = font;
    cell.textLabel.font = font;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    [cell.detailTextLabel setTextColor:[UIColor redColor]];
    [cell.textLabel setTextColor:[UIColor blueColor]];
    if(indexPath.section ==0){
        if(!holderDict){
            cell.textLabel.text = @"---";
            cell.detailTextLabel.text= @"----";
        }else{
            cell.textLabel.text = [[holderDict objectForKey:@"HolderName"] objectAtIndex:indexPath.row];
            cell.detailTextLabel.text= [CodingUtil getValueToPrecent:[(NSNumber *)[[holderDict objectForKey:@"ShareRate"] objectAtIndex:indexPath.row]doubleValue]];
        }
    }
    if(indexPath.section ==1){
        if(!productDict){
            cell.textLabel.text = @"---";
            cell.detailTextLabel.text= @"----";
        }else{
            cell.textLabel.text = [[productDict objectForKey:@"ProductName"] objectAtIndex:indexPath.row];
            cell.detailTextLabel.text= [CodingUtil getValueToPrecent:[(NSNumber *)[[productDict objectForKey:@"RevRate"] objectAtIndex:indexPath.row]doubleValue]];
        }
    }

    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
    
    UIFont * font = [UIFont boldSystemFontOfSize:18.0f];
    
    UILabel * leftLabel = [[UILabel alloc] init];
    leftLabel.font = font;
    [leftLabel setTextColor:[UIColor whiteColor]];
    leftLabel.translatesAutoresizingMaskIntoConstraints=NO;
    
    UILabel * rightLabel = [[UILabel alloc] init];
    rightLabel.font= font;
    [rightLabel setTextColor:[UIColor whiteColor]];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.translatesAutoresizingMaskIntoConstraints=NO;
    
    if(section==0){
        leftLabel.text = @"大股東";
        rightLabel.text = @"持股比例";
    }else if(section==1){
        leftLabel.text = @"主要產品";
        rightLabel.text = @"營收比例";
    }else{
        return nil;
    }
    
    [headerView addSubview:leftLabel];
    [headerView addSubview:rightLabel];
    
    NSDictionary *viewControll = NSDictionaryOfVariableBindings(leftLabel, rightLabel);
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftLabel][rightLabel]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControll]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLabel]|" options:0 metrics:nil views:viewControll]];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}



@end
