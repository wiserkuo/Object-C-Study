//
//  FSInvestedViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/4/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSInvestedViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FSInvestedHeaderTableViewCell.h"
#import "FSInvestedCell.h"
#import "FSAddFundsViewController.h"
#import "FSActionPlanDatabase.h"


@interface FSInvestedViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    UITableView *mainTableView;
    UIScrollView *scrollView;
    UIButton *button;
    UIAlertView *alert;
    NSMutableArray *investedFunds;
    NSMutableArray *investedArray;
    NSMutableArray *investedArrayForShowMessage;
}

@property (weak, nonatomic) FSInvestedModel *invested;

@end

@implementation FSInvestedViewController

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
	// Do any additional setup after loading the view.
    [self.view setNeedsUpdateConstraints];
    [self setupNavigationBar];
    [self setupTableView];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    investedFunds = [[NSMutableArray alloc] init];
    investedFunds = [[FSActionPlanDatabase sharedInstances] searchInvestedByTerm:_termStr];
    
    [self showInvestedLabel];
    
    [mainTableView reloadData];
    _invested = [[FSDataModelProc sharedInstance] investedModel];
    investedArray = _invested.dataArray;
//    [self goToBottom];
}

-(void)showInvestedLabel{
    if (investedArrayForShowMessage && [investedArrayForShowMessage count] < [investedFunds count]) {
        [FSHUD showMsg:[NSString stringWithFormat:@"%@ $%@ %@",
                        [[investedFunds firstObject] objectForKey:@"Remit"],
                        [CodingUtil CoverFloatWithComma:fabs([(NSNumber *)[[investedFunds firstObject] objectForKey:@"Amount"] doubleValue]) DecimalPoint:0],
                        NSLocalizedStringFromTable(@"成功", @"Position", nil)]];
        investedArrayForShowMessage = investedFunds;
        
    }else{
        investedArrayForShowMessage = [[NSMutableArray alloc]initWithArray:investedFunds];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goToBottom
{
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    [mainTableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(NSIndexPath *)lastIndexPath
{
    NSInteger lastSectionIndex = MAX(0, [mainTableView numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [mainTableView numberOfRowsInSection:lastSectionIndex] - 1);
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}

-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"投入資金", @"ActionPlan", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [addButton setImage:[UIImage imageNamed:@"+藍色小球"] forState:UIControlStateNormal];
    UIBarButtonItem *barAddButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = barAddButtonItem;
    [addButton addTarget:self action:@selector(addFundsTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self setUpImageBackButton];
}

-(void)addFundsTapped:(id)sender{
    FSAddFundsViewController *term = [[FSAddFundsViewController alloc] init];
    [self.navigationController pushViewController:term animated:NO];
    if ([_termStr isEqualToString:@"Long"]) {
        term.termStr = @"Long";
    }else{
        term.termStr = @"Short";
    }
}

-(void)setupTableView{
    mainTableView = [[UITableView alloc] init];
    mainTableView.separatorColor = [UIColor clearColor];
    mainTableView.allowsSelection = NO;
    mainTableView.bounces = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.directionalLockEnabled = NO;
    scrollView.contentSize = CGSizeMake(mainTableView.frame.size.width, scrollView.frame.size.height);
    [scrollView addSubview:mainTableView];
    [self.view addSubview:scrollView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(mainTableView, scrollView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView(>=570)]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView(==scrollView)]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark - Table view header setting
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *cellIdentifier = @"InvestedCell";
    
    FSInvestedHeaderTableViewCell *contentView = (FSInvestedHeaderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (contentView == nil) {
        contentView = [[FSInvestedHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    contentView.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    contentView.dateLabel.textColor = [UIColor whiteColor];
    contentView.dateLabel.text = NSLocalizedStringFromTable(@"日期",@"ActionPlan",nil);
    
    contentView.remitLabel.textColor = [UIColor whiteColor];
    contentView.remitLabel.text = NSLocalizedStringFromTable(@"匯入/匯出",@"ActionPlan",nil);
    
    contentView.amountLabel.textColor = [UIColor whiteColor];
    contentView.amountLabel.text = NSLocalizedStringFromTable(@"金額$",@"ActionPlan",nil);
    
    contentView.totalAmountLabel.textColor = [UIColor whiteColor];
    contentView.totalAmountLabel.text = NSLocalizedStringFromTable(@"累計金額",@"ActionPlan",nil);
        
    return contentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [investedFunds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"InvestedHeaderCell";
    
    FSInvestedCell *contentView = (FSInvestedCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (contentView == nil) {
        contentView = [[FSInvestedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }else{
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    NSDate * date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",
                                               [[investedFunds objectAtIndex:indexPath.row] objectForKey:@"Date"]]];
    NSString * dateStr = [dateFormatter stringFromDate:date];

    contentView.dateLabel.text = dateStr;
    NSString *remitStr = [NSString stringWithFormat:@"%@",
                                  [[investedFunds objectAtIndex:indexPath.row] objectForKey:@"Remit"]];
    contentView.remitLabel.text = NSLocalizedStringFromTable(remitStr, @"ActionPlan", nil);
    
    double amount = fabs([(NSNumber *)[[investedFunds objectAtIndex:indexPath.row] objectForKey:@"Amount"] doubleValue]);
    contentView.amountLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:amount DecimalPoint:0]];
    
    contentView.totalAmountLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:[[[investedFunds objectAtIndex:indexPath.row] objectForKey:@"Total_Amount"] floatValue] DecimalPoint:0]];
    
    [contentView.removeBtn setImage:[UIImage imageNamed:@"RedDeleteButton"] forState:UIControlStateNormal];
    contentView.removeBtn.tag = indexPath.row;
    [contentView.removeBtn addTarget:self action:@selector(deleteData:) forControlEvents:UIControlEventTouchUpInside];
    return contentView;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (![[investedFunds objectAtIndex:indexPath.row] isEqual:[investedFunds lastObject]] && [(NSNumber *)[[investedFunds objectAtIndex:indexPath.row] objectForKey:@"Amount"] floatValue] > [(NSNumber *)[[investedFunds objectAtIndex:indexPath.row + 1] objectForKey:@"Total_Amount"] floatValue]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Warning", @"ActionPlan", nil) message:NSLocalizedStringFromTable(@"The funds should be more than 0.", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ActionPlan", nil) otherButtonTitles:nil];
            [alertView show];
        }else{
            [[FSActionPlanDatabase sharedInstances] deleteInvestedDataWithrowid:[[investedFunds objectAtIndex:indexPath.row] objectForKey:@"rowid"]];
            [investedFunds removeObjectAtIndex:indexPath.row];
            [mainTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationTop];
            investedFunds = [[FSActionPlanDatabase sharedInstances] searchInvestedByTerm:_termStr];
            [mainTableView reloadData];
        }
    }
}

-(void)deleteData:(UIButton *)sender{
    button =(UIButton *)sender;
    alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"確定刪除此筆記錄?", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil), nil];
    [alert show];
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[FSActionPlanDatabase sharedInstances] deleteInvestedDataWithrowid:[[investedFunds objectAtIndex:button.tag] objectForKey:@"rowid"]];
        [investedFunds removeObjectAtIndex:button.tag];
        investedFunds = [[FSActionPlanDatabase sharedInstances] searchInvestedByTerm:_termStr];
        [mainTableView reloadData];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end

