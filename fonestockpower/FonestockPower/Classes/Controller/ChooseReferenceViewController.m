//
//  ChooseReferenceViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/7/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ChooseReferenceViewController.h"
#import "UIViewController+CustomNavigationBar.h"
@interface ChooseReferenceViewController ()
{
    UITableView *mainTableView;
    NSMutableArray *titleArray;
    NSMutableArray *nameArray;
    MacroeconomicDrawViewController *macroeconomicDrawViewController;
    UIView *headerView;
}
@end

@implementation ChooseReferenceViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(id)initWithTitle:(NSMutableArray *)TitleArray Name:(NSMutableArray *)NameArray Controller:(MacroeconomicDrawViewController *)controller;
{
    self = [super init];
    if(self){
        nameArray = NameArray;
        titleArray = TitleArray;
        macroeconomicDrawViewController = controller;
        self.title = @"Choose Reference";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpImageBackButton];
	[self initTableView];
    [self processLayout];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initTableView
{
    headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor brownColor];
    
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:26/255.0 green:117/255.0 blue:174/255.0 alpha:1]];
    [self.view addSubview:mainTableView];
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(mainTableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    FSUITableViewCell *cell = (FSUITableViewCell *)[mainTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[nameArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[nameArray objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [titleArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [titleArray objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    macroeconomicDrawViewController.secondRow = (int)indexPath.row;
    macroeconomicDrawViewController.secondNameIndex = (int)indexPath.section;
    [macroeconomicDrawViewController setSecondFlag];
    [self.navigationController popViewControllerAnimated:NO];
}
@end
