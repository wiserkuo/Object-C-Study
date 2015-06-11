//
//  CompanyProfilePage5ViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage5ViewController.h"

@interface CompanyProfilePage5ViewController ()<BoardMemberTransferDelegate>
{
    UITableView *mainTableView;
    NSDictionary *dict;
    FSDataModelProc *model;
}
@end

@implementation CompanyProfilePage5ViewController

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

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    model.boardMemberTransfer.delegate = self;
    [model.boardMemberTransfer sendAndRead];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initModel];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    model.boardMemberTransfer.delegate = nil;
    dict = nil;
    [mainTableView reloadData];
}

-(void)notifyBoardMemberTransferData:(id)target
{
    dict = target;
    [mainTableView reloadData];
}

- (void)initMainTableView {
    mainTableView = [[UITableView alloc] init];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.allowsSelection = NO;
    mainTableView.bounces = NO;
    [self.view addSubview:mainTableView];
}

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]-15-|" options:0 metrics:nil views:viewControllers]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!dict){
        return 0;
    }else{
        return [(NSNumber *)[dict objectForKey:@"BoardMemberTransferCount"]intValue];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellIdentifier = @"5Cell";
    CompanyProfilePage5Cell *cell = (CompanyProfilePage5Cell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil) {
        cell = [[CompanyProfilePage5Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    cell.applyShareLabel.text = @"申讓張數:";
    cell.orgShareLabel.text = @"申讓前持張:";
    cell.applyPriceLabel.text = @"申讓價格:";
    cell.actualShareLabel.text = @"申讓後持張:";
    if(!dict){
        cell.directorLabel.text=@"----";
        cell.sheetLabel.text=@"----";
        cell.beforeSheetLabel.text=@"----";
        cell.sheetPriceLabel.text=@"----";
        cell.afterSheetLabel.text=@"----";
        cell.tradeLabel.text=[NSString stringWithFormat:@"交易方式:----"];
        cell.letDateLabel.text=[NSString stringWithFormat:@"申讓日期:----"];
    }else{
        cell.directorLabel.text=[NSString stringWithFormat:@"%@ %@",[[dict objectForKey:@"HolderName"] objectAtIndex:indexPath.row],[[dict objectForKey:@"HolderTitle"] objectAtIndex:indexPath.row]];
        cell.sheetLabel.text=[[[dict objectForKey:@"ApplyShare"] objectAtIndex:indexPath.row]stringValue];
        cell.beforeSheetLabel.text=[[[dict objectForKey:@"OrgShare"] objectAtIndex:indexPath.row]stringValue];
        cell.sheetPriceLabel.text=[NSString stringWithFormat:@"%.2f",[(NSNumber *)[[dict objectForKey:@"ApplyPrice"] objectAtIndex:indexPath.row]doubleValue]];
        cell.afterSheetLabel.text=[[[dict objectForKey:@"ActualTransfer"] objectAtIndex:indexPath.row]stringValue];
        cell.tradeLabel.text=[NSString stringWithFormat:@"交易方式:%@",[[dict objectForKey:@"Method"] objectAtIndex:indexPath.row]];
        cell.letDateLabel.text=[NSString stringWithFormat:@"申讓日期:%@",[[dict objectForKey:@"TransferDate"] objectAtIndex:indexPath.row]];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}

@end
