//
//  FSActionEditCondictionViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/5/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionEditCondictionViewController.h"
#import "FSWatchlistPortfolioItem.h"
#import "FSActionEditCondictionCell.h"
#import "FSActionPlanDatabase.h"
#import "FSActionPlanModel.h"

@interface FSActionEditCondictionViewController () <UIAlertViewDelegate>
@property (strong) UILabel * label;
@property (strong) NSMutableArray * columnNames;
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
@property (nonatomic, strong) FSUIButton * closeBtn;
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic) float offsetY;
@property (nonatomic, strong) FSActionEditCondictionCell *editCell;
@property (nonatomic, strong) FSDataModelProc *dataModel;
@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) FSActionPlanDatabase *actionPlanDB;
@property (nonatomic, weak) FSActionPlanModel *actionPlanModel;

@end

@implementation FSActionEditCondictionViewController

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

- (void)viewDidLoad
{
	// Do any additional setup after loading the view.
    self.datalock = [[NSRecursiveLock alloc] init];
    [self initView];
    [self varInit];
    [super viewDidLoad];
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
    
    [_mainTableView setEditing:YES animated:NO];
    _mainTableView.allowsSelectionDuringEditing = YES;
    
    [self.view addSubview:_mainTableView];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    PortfolioItem *item = [_watchlistItem portfolioItem:indexPath];
    if (item->type_id == 6  || item->type_id == 3) {
        return NO;
    }else{
        return YES;
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSLocalizedStringFromTable(@"刪除", @"SecuritySearch", nil);
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if(fromIndexPath.row != toIndexPath.row)
	{
         PortfolioItem *item = [_watchlistItem portfolioItem:toIndexPath];
        if (item->type_id != 6 && item->type_id != 3) {
            [[_dataModel portfolioData] moveWatchList:(int)fromIndexPath.row ToRowIndex:(int)toIndexPath.row];
            [[_dataModel portfolioData]  reSetNewWatchListToDB];
        }
		
	}
    [_mainTableView reloadData];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		PortfolioItem *item = [[_dataModel portfolioData] getItemAt:(int)indexPath.row];
        double longQTY = [[FSActionPlanDatabase sharedInstances] searchPositionQTYWithTerm:@"Long" symbol:[item getIdentCodeSymbol]];
        double ShortQTY = [[FSActionPlanDatabase sharedInstances] searchPositionQTYWithTerm:@"Short" symbol:[item getIdentCodeSymbol]];
        BOOL exist = [[FSActionPlanDatabase sharedInstances] searchExistSymbolWithSymbol:[item getIdentCodeSymbol]];

        if (longQTY > 0 || ShortQTY > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"持有部位應以交易的方式移除(賣出或回補)" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil) otherButtonTitles:nil];
            [alert show];
        }else if (exist){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請先由交易計劃清單移除此檔股票" delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil) otherButtonTitles:nil];
            [alert show];
        }else{
            int beforeRemovePortfolioCount = [[_dataModel portfolioData] getCount];
            [[_dataModel portfolioData] RemoveItem:item->identCode andSymbol:item->symbol];
            int afterRemovePortfolioCount = [[_dataModel portfolioData] getCount];
            
            if(beforeRemovePortfolioCount-1 != afterRemovePortfolioCount) // 刪除兩個以上identcode symbol相同的商品 (特例情況)
            {
                [_mainTableView reloadData];
            }
            
            else // 正常情況
            {
                [_mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                [_mainTableView reloadData];
            }
            [[_dataModel alert] deleteDataByIdentCodeSymbol:[item getIdentCodeSymbol]];
            
            [[_dataModel alert] performSelector:@selector(saveAlertDataToFile) onThread:[_dataModel thread] withObject:nil waitUntilDone:NO];
            
            [_actionPlanModel stopWatchIdentcodeSymbol:[item getIdentCodeSymbol]];
        }
	}
}

- (void)updateViewConstraints {
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings( _mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [super updateViewConstraints];
}


- (void)varInit {
    _columnNames = [[NSMutableArray alloc] initWithObjects:
                    NSLocalizedStringFromTable(@"Symbol", @"watchlists", nil),
                    nil];
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_watchlistItem count];
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        CellIdentifier = @"Portrait";
    }else{
        CellIdentifier = @"Landscape";
    }
    PortfolioItem *item = [_watchlistItem portfolioItem:indexPath];
    FSActionEditCondictionCell *cell = (FSActionEditCondictionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FSActionEditCondictionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS && item->type_id != 3) {
        cell.label.text = item->symbol;
    }
    else {
        cell.label.text =  item->fullName;
    }
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.tag = indexPath.row;
    

    cell.indexPath = indexPath;
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    UIView *mainTableHeader = [[UIView alloc] init];
    mainTableHeader.backgroundColor = [UIColor colorWithRed: 0.0/255.0 green: 78.0/255.0 blue: 162.0/255.0 alpha: 1.0];
    for (int i = 0; i < [_columnNames count]; i++) {
        UILabel *label = [[UILabel alloc] init];
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            if (i == 0) {
                label.Frame = CGRectMake(110, 0, 110, 44);
            }
        }else{
            if (i == 0) {
                label.Frame = CGRectMake(0, 0, 165, 44);
            }
        }
        
        if (i == 1) {
            label.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
        }else{
            label.backgroundColor = [UIColor clearColor];
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
    return 0;//44;
}

-(void)cellButtonActionBegainWithCell:(FSActionEditCondictionCell *)cell{
    self.editCell = cell;
}

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

@end
