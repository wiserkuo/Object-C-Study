//
//  CompanyProfilePage4ViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage4ViewController.h"

@interface CompanyProfilePage4ViewController ()< BoardMemberHoldingDelegate>
{
    UITableView *mainTableView;
    NSDictionary *dict;
    FSDataModelProc *model;
}
@end

@implementation CompanyProfilePage4ViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initMainTableView {
    mainTableView = [[UITableView alloc] init];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.allowsSelection=NO;
    mainTableView.bounces = NO;
    [self.view addSubview:mainTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initModel];
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    model.boardMemberHolding.delegate = self;
    [model.boardMemberHolding sendAndRead];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    model.boardMemberHolding.delegate = nil;
    dict = nil;
    [mainTableView reloadData];
}

-(void)notifyBoardMemberHoldingData:(id)target
{
    dict = target;
    [mainTableView reloadData];
}

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(mainTableView);
    
    // scrollView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]-15-|" options:0 metrics:nil views:viewControllers]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!dict){
        return 0;
    }else{
        return [(NSNumber *)[dict objectForKey:@"BoardMemberHolderingCount"]intValue];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"4Cell";
    CompanyProfilePage4Cell *cell = (CompanyProfilePage4Cell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil) {
        cell = [[CompanyProfilePage4Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    if(!dict){
        cell.shareholderLabel.text=@"----";
        cell.shareholderDetailLabel.text=@"----";
        cell.holdLabel.text= @"----";
        cell.holdRateLabel.text= @"----";
    }else{
        cell.shareholderLabel.text=[[dict objectForKey:@"HolderName"] objectAtIndex:indexPath.row];
        cell.shareholderDetailLabel.text=[[dict objectForKey:@"HolderTitle"] objectAtIndex:indexPath.row];
        cell.holdLabel.text= [[[dict objectForKey:@"Share"] objectAtIndex:indexPath.row]stringValue];
        cell.holdRateLabel.text=[CodingUtil getValueToPrecent:[(NSNumber *)[[dict objectForKey:@"Ratio"] objectAtIndex:indexPath.row]doubleValue]];
    }
    cell.holdingLabel.text=@"持有:";
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
    
    UIFont * font = [UIFont boldSystemFontOfSize:18.0f];
    UILabel * updataDateLabel = [[UILabel alloc] init];
    updataDateLabel.font = font;
    [updataDateLabel setTextColor:[UIColor whiteColor]];
    updataDateLabel.textAlignment = NSTextAlignmentCenter;
    updataDateLabel.translatesAutoresizingMaskIntoConstraints=NO;
    updataDateLabel.text = [NSString stringWithFormat:@"資料更新日期:%@",[dict objectForKey:@"ModifiedDate"]];
    
    [headerView addSubview:updataDateLabel];
    
    NSDictionary *viewControll = NSDictionaryOfVariableBindings(updataDateLabel);
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[updataDateLabel]|" options:0 metrics:nil views:viewControll]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[updataDateLabel]-3-|" options:0 metrics:nil views:viewControll]];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

@end
