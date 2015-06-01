//
//  FSAddActionEditCondictionViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/5/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAddActionEditCondictionViewController.h"
#import "FSWatchlistPortfolioItem.h"
#import "FSAddActionEditCondictionCell.h"
#import "FSActionPlanDatabase.h"
#import "FSActionPlanModel.h"
#import "PortfolioOut.h"
#import "Commodity.h"
#import "FSAddActionPlanSettingViewController.h"

@interface FSAddActionEditCondictionViewController () <UIAlertViewDelegate>{
    NSMutableArray * watchListArray;
    NSMutableArray *layoutContraints;

}
@property (strong) UILabel * label;
@property (strong) NSMutableArray * columnNames;
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
@property (nonatomic, strong) FSUIButton * closeBtn;
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic) float offsetY;
@property (nonatomic, strong) FSAddActionEditCondictionCell *editCell;
@property (nonatomic, strong) FSDataModelProc *dataModel;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) FSActionPlanDatabase *actionPlanDB;
@property (nonatomic, weak) FSActionPlanModel *actionPlanModel;

@end

@implementation FSAddActionEditCondictionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _dataModel = [FSDataModelProc sharedInstance];
        _actionPlanDB = [FSActionPlanDatabase sharedInstances];
        _actionPlanModel = [[FSDataModelProc sharedInstance] actionPlanModel];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    watchListArray = [[NSMutableArray alloc]init];
    layoutContraints = [[NSMutableArray alloc] init];

    self.datalock = [[NSRecursiveLock alloc] init];
    [self initView];
    [self varInit];
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView{
    //neil
    //    self.alertParam = [[AlertParam alloc] init];
    _dataArray = [[NSMutableArray alloc]init];
    
    _mainTableView = [[UITableView alloc] init];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.bounces = NO;
    
    [self.view addSubview:_mainTableView];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)varInit {
    _columnNames = [[NSMutableArray alloc] initWithObjects:
                    NSLocalizedStringFromTable(@"Symbol", @"watchlists", nil),
                    NSLocalizedStringFromTable(@"Strategy", @"watchlists", nil),
                    nil];
}

#pragma mark - reload data
-(void)reloadDataArray{
    watchListArray = [_watchlistItem getWatchListArray];
    
    [self sortDataArray];
}

#pragma mark - sort data
-(void)sortDataArray{
    int howManyTypeIdThree = 0;
    for (int i = 0; i < [watchListArray count]; i++){
        PortfolioItem *item = watchListArray[i];
        if(item->type_id == 3){
            [watchListArray removeObject:item];
            [watchListArray insertObject:item atIndex:howManyTypeIdThree];
            howManyTypeIdThree++;
        }
    }
    [_mainTableView reloadData];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_mainTableView);
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:layoutContraints];
    
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark - table view delegate
// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [watchListArray count];
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        CellIdentifier = @"Portrait";
    }else{
        CellIdentifier = @"Landscape";
    }
    PortfolioItem *item = [watchListArray objectAtIndex:indexPath.row];
//    NSLog(@"row:%ld symbol:%@",(long)indexPath.row,item->symbol);
    FSAddActionEditCondictionCell *cell = (FSAddActionEditCondictionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FSAddActionEditCondictionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS && item->type_id != 3) {
        cell.label.text = item->symbol;
    }
    else {
        cell.label.text = item->fullName;
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.tag = indexPath.row;
    
    cell.indexPath = indexPath;
    int exist = [_actionPlanDB searchActionPlanDataWithSymbol:[item getIdentCodeSymbol] term:_termStr];
    cell.nonButton.hidden = YES;
    cell.addButton.hidden = YES;
    [cell.addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if (exist == 0) {
        if (item -> type_id == 1) {
            cell.nonButton.hidden = NO;
        }else{
            cell.nonButton.hidden = YES;
            cell.addButton.hidden = YES;
        }
    }else{
        if ([_termStr isEqualToString:@"Long"]) {
            [cell.addButton setTitle:NSLocalizedStringFromTable(@"Long", @"watchlists", nil) forState:UIControlStateNormal];
        }else{
            [cell.addButton setTitle:NSLocalizedStringFromTable(@"Short", @"watchlists", nil) forState:UIControlStateNormal];
        }
        cell.addButton.hidden = NO;
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    UIView *mainTableHeader = [[UIView alloc] init];
    mainTableHeader.backgroundColor = [UIColor colorWithRed: 0.0/255.0 green: 78.0/255.0 blue: 162.0/255.0 alpha: 1.0];
    for (int i = 0; i < [_columnNames count]; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.layer.borderWidth = 0.3f;
        label.layer.borderColor = [UIColor whiteColor].CGColor;
        label.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            label.frame = CGRectMake(0, 0, self.view.frame.size.width/3, 44);
        }else{
            label.frame = CGRectMake(self.view.frame.size.width/3, 0, (self.view.frame.size.width/3)*2, 44);
        }
        
        label.font = font;
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.text =[NSString stringWithFormat:@"%@",[_columnNames objectAtIndex:i]];
        [mainTableHeader addSubview:label];
    }
    
    return mainTableHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(void)cellButtonActionBegainWithCell:(FSAddActionEditCondictionCell *)cell{
    self.editCell = cell;
}

-(void)cellButtonAction:(FSAddActionEditCondictionCell *)cell{
    PortfolioItem *item = [watchListArray objectAtIndex:_editCell.indexPath.row];
    int count = 0;
    count = [_actionPlanDB searchNumberOfActionPlan];
    if (cell.addButton.hidden == YES) {
        if (count == 20) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"超過加入上限", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil) otherButtonTitles:nil];
            [alert show];
        }else{
            NSMutableArray * array = [[NSMutableArray alloc]init];
            Commodity *obj = [[Commodity alloc] initWithIdentCode:item -> identCode symbol:item->symbol];
            [array addObject: obj];
            PortfolioOut *packet = [[PortfolioOut alloc] init];
            [packet addPortfolio:array];
            [FSDataModelProc sendData:self WithPacket:packet];
            
            [cell.addButton setTitle:NSLocalizedStringFromTable(_termStr, @"watchlists", nil)forState:UIControlStateNormal];
            [_actionPlanDB insertActionPlanWithSybmol:[item getIdentCodeSymbol] Manual:[NSNumber numberWithFloat:0.0] Pattern1:[NSNumber numberWithInteger:0] SProfit:[NSNumber numberWithFloat:15] SLoss:[NSNumber numberWithFloat:8] Pattern2:[NSNumber numberWithInteger:0] Term:_termStr SProfit2:[NSNumber numberWithFloat:15] SLoss2:[NSNumber numberWithFloat:8] CostType:@"YES"];
            cell.addButton.hidden = NO;
            cell.nonButton.hidden = YES;
//            [_actionPlanModel addWatchIdentcodeSymbol:[item getIdentCodeSymbol]];
        }
    }
}

#pragma mark - AlertAiew Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    PortfolioItem *item = [watchListArray objectAtIndex:_editCell.indexPath.row];
//    [_actionPlanModel stopWatchIdentcodeSymbol:[item getIdentCodeSymbol]];
    if (buttonIndex == 1) {
        if (_alert.tag == 0) {
            [_actionPlanDB deleteActionbPlanDataWithSymbol:[item getIdentCodeSymbol]];
            [_actionPlanDB deletePositionsWithIdentCodeSymbol:[item getIdentCodeSymbol]];
//            [self.editCell.addButton setTitle:NSLocalizedStringFromTable(@"None", @"watchlists", nil) forState:UIControlStateNormal];
            self.editCell.addButton.hidden = YES;
            self.editCell.nonButton.hidden = NO;
        }else if (_alert.tag == 1){
            [_actionPlanDB deleteActionbPlanDataWithSymbol:[item getIdentCodeSymbol]];
            [_actionPlanDB deletePositionsWithIdentCodeSymbol:[item getIdentCodeSymbol]];
            [self.editCell.addButton setTitle:NSLocalizedStringFromTable(@"Long", @"watchlists", nil) forState:UIControlStateNormal];
            [_actionPlanDB insertActionPlanWithSybmol:[item getIdentCodeSymbol] Manual:[NSNumber numberWithFloat:0.0] Pattern1:[NSNumber numberWithInteger:0] SProfit:[NSNumber numberWithFloat:15] SLoss:[NSNumber numberWithFloat:8] Pattern2:[NSNumber numberWithInteger:0] Term:@"Long" SProfit2:[NSNumber numberWithFloat:15] SLoss2:[NSNumber numberWithFloat:8] CostType:@"YES"];

//            [_actionPlanModel addWatchIdentcodeSymbol:[item getIdentCodeSymbol]];
            self.editCell.addButton.hidden = NO;
            self.editCell.nonButton.hidden = YES;
        }
        else if (_alert.tag == 2){
            [_actionPlanDB deleteActionbPlanDataWithSymbol:[item getIdentCodeSymbol]];
            [_actionPlanDB deletePositionsWithIdentCodeSymbol:[item getIdentCodeSymbol]];
            [self.editCell.addButton setTitle:NSLocalizedStringFromTable(@"Short", @"watchlists", nil) forState:UIControlStateNormal];
            [_actionPlanDB insertActionPlanWithSybmol:[item getIdentCodeSymbol] Manual:[NSNumber numberWithFloat:0.0] Pattern1:[NSNumber numberWithInteger:0] SProfit:[NSNumber numberWithFloat:15] SLoss:[NSNumber numberWithFloat:8] Pattern2:[NSNumber numberWithInteger:0] Term:@"Short" SProfit2:[NSNumber numberWithFloat:15] SLoss2:[NSNumber numberWithFloat:8] CostType:@"YES"];

//            [_actionPlanModel addWatchIdentcodeSymbol:[item getIdentCodeSymbol]];
            self.editCell.addButton.hidden = NO;
            self.editCell.nonButton.hidden = YES;
        }else if (_alert.tag == 3){
            [_actionPlanDB deleteActionPlanDataWithSymbol:[item getIdentCodeSymbol] Term:@"Short"];
            [_actionPlanDB deletePositionsWithIdentCodeSymbol:[item getIdentCodeSymbol] Term:@"Short"];
            [self.editCell.addButton setTitle:NSLocalizedStringFromTable(@"Long", @"watchlists", nil) forState:UIControlStateNormal];
//            [_actionPlanModel addWatchIdentcodeSymbol:[item getIdentCodeSymbol]];
            self.editCell.addButton.hidden = NO;
            self.editCell.nonButton.hidden = YES;
        }else if (_alert.tag == 4){
            [_actionPlanDB deleteActionPlanDataWithSymbol:[item getIdentCodeSymbol] Term:@"Long"];
            [_actionPlanDB deletePositionsWithIdentCodeSymbol:[item getIdentCodeSymbol] Term:@"Long"];
            [self.editCell.addButton setTitle:NSLocalizedStringFromTable(@"Short", @"watchlists", nil) forState:UIControlStateNormal];
//            [_actionPlanModel addWatchIdentcodeSymbol:[item getIdentCodeSymbol]];
            self.editCell.addButton.hidden = NO;
            self.editCell.nonButton.hidden = YES;
        }
    }
}

#pragma mark - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([[FSFonestock sharedInstance] checkNeedShowAdvertise]){
        if([[UIApplication sharedApplication] statusBarOrientation]== UIInterfaceOrientationLandscapeLeft){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 64, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-50);
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [_mainTableView reloadData];
}

@end
