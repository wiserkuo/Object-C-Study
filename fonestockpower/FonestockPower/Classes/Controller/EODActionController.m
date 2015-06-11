//
//  EDOActionController.m
//  FonestockPower
//
//  Created by Kenny on 2014/5/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODActionController.h"
#import "FigureSearchCollectionViewCell.h"
#import "FigureSearchViewLayout.h"
#import "EODActionTableCell.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "UIViewController+CustomNavigationBar.h"
#import "ExplanationViewController.h"
#import "SGInfoAlert.h"
@interface EODActionController ()<EODActionTableCellDelegate>
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
@end

static NSString *itemIdentifier = @"FigureSearchItemIdentifier";
@implementation EODActionController
{
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    UITableView *mainTableView;
    NSString *gategoryStr;
//    UICollectionView *collectionView;
    FigureSearchViewLayout *layout;
    FSDataModelProc *model;
    FSInstantInfoWatchedPortfolio *watchPortfolio;
    NSMutableArray *imgArray;
    NSMutableDictionary *imageLongDictionary;
    NSMutableDictionary *imageShortDictionary;
    int longCount;
    int shortCount;
    NSMutableDictionary * symbolDict;
    NSMutableArray *longName;
    NSMutableArray *shortName;
    NSMutableArray *longSymbolKey;
    NSMutableArray *shortSymbolKey;
    int symbolCount;
    NSMutableArray *dataArray;
}
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
    UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [pointButton addTarget:self action:@selector(explantation:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barAddButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pointButton];
    NSArray *itemArray = [[NSArray alloc] initWithObjects:barAddButtonItem,nil];
    [self.navigationItem setRightBarButtonItems:itemArray];
    
    self.title = NSLocalizedStringFromTable(@"EOD Check", @"FigureSearch", nil);
    [self setUpImageBackButton];
    [self initMoreOption];
    [self initZeroOption];
    [self initSymbol];
    [self initTableView];

    watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    gategoryStr = @"LongSystem";
    imgArray = [[NSMutableArray alloc] init];
    imageLongDictionary = [[NSMutableDictionary alloc] init];
    imageShortDictionary = [[NSMutableDictionary alloc] init];
    longCount = 0;
    shortCount = 0;
    
    [self.view setNeedsUpdateConstraints];
}

-(void)explantation:(UIButton *)sender
{
    [self.navigationController pushViewController:[[ExplanationViewController alloc] init] animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [SGInfoAlert showInfo_EOD:NSLocalizedStringFromTable(@"搜尋結果為最近一次收盤資料.", @"FigureSearch", nil) bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [model.edoActionModel setTargetNotify:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    [model.edoActionModel setTargetNotify:self];

    symbolCount = 0;
    ActionObject *object = [[ActionObject alloc] init];
    if(symbolCount < [dataArray count]){
        object = [dataArray objectAtIndex:symbolCount];
        [model.edoActionModel getFigureImage:object.symbol Type:object.term];
    }
}

-(NSMutableArray *)sortWatchListArray{
    self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
    NSMutableArray *tempWatchListArray = [[NSMutableArray alloc]initWithArray:[_watchlistItem getWatchListArray]];
    
    for (int i = 0; i < [tempWatchListArray count]; i++){
        PortfolioItem *itme = [tempWatchListArray objectAtIndex:i];
        if (itme -> type_id != 1) {
            [tempWatchListArray removeObjectAtIndex:i];
        }
    }
    
    return tempWatchListArray;
}
-(void)insertArray:(NSMutableArray *)actionList isLongArray:(BOOL)IsLongArray{
    NSMutableArray *nameArray = [[NSMutableArray alloc]init];
    NSMutableArray *symbolArray = [[NSMutableArray alloc]init];
    
    for (FSActionPlan *actionItem in actionList) {
        ActionObject *object = [[ActionObject alloc] init];
        NSString *string = actionItem.identCodeSymbol;
        NSString *identCode = [string substringToIndex:2];
        NSString *symbol = [string substringFromIndex:3];
        object.symbol = string;
        object.term = actionItem.longShortType;
        [dataArray addObject:object];
        NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
        [symbolArray addObject:string];
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            [nameArray addObject:symbol];
        }else{
            [nameArray addObject:fullName];
        }
    }
    
    if (IsLongArray) {
        longName = [[NSMutableArray alloc]initWithArray:nameArray];
        longSymbolKey = [[NSMutableArray alloc]initWithArray:symbolArray];
    }else{
        shortName = [[NSMutableArray alloc]initWithArray:nameArray];
        shortSymbolKey = [[NSMutableArray alloc]initWithArray:symbolArray];
    }
}
-(void)initSymbol
{
    FSActionPlanModel *actionPlanModel = [[FSDataModelProc sharedInstance] actionPlanModel];
    NSMutableArray *longArray = actionPlanModel.actionPlanLongArray;
    NSMutableArray *shortArray = actionPlanModel.actionPlanShortArray;
    dataArray = [[NSMutableArray alloc] init];

    [self insertArray:longArray isLongArray:YES];
    [self insertArray:shortArray isLongArray:NO];
    [self initModel];
}


-(void)notifyLongData:(ArrayData *)target
{
    ArrayData *arrayData = target;
    if(arrayData->dataArray !=nil){
        [imageLongDictionary setObject:arrayData->dataArray forKey:[NSString stringWithFormat:@"%d",longCount]];
        [imageLongDictionary setObject:arrayData->nameArray forKey:[NSString stringWithFormat:@"name%d",longCount]];
    }
    longCount ++;
    [mainTableView reloadData];
    
    symbolCount ++;

    ActionObject *object = [[ActionObject alloc] init];
    if(symbolCount < [dataArray count]){
        object = [dataArray objectAtIndex:symbolCount];
        [model.edoActionModel getFigureImage:object.symbol Type:object.term];
    }

}

-(void)notifyShortData:(ArrayData *)target
{
    ArrayData *arrayData = target;
    if(arrayData->dataArray !=nil){
        [imageShortDictionary setObject:arrayData->dataArray forKey:[NSString stringWithFormat:@"%d",shortCount]];
        [imageShortDictionary setObject:arrayData->nameArray forKey:[NSString stringWithFormat:@"name%d",shortCount]];
    }
    shortCount ++;
    [mainTableView reloadData];
    
    symbolCount ++;
    
    ActionObject *object = [[ActionObject alloc] init];
    if(symbolCount < [dataArray count]){
        object = [dataArray objectAtIndex:symbolCount];
        [model.edoActionModel getFigureImage:object.symbol Type:object.term];
    }
}

-(void)initMoreOption
{
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"FigureSearch", nil);
    
    moreOptionButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    moreOptionButton.selected = YES;
    [moreOptionButton setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreOptionButton];
}

-(void)initZeroOption
{
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"FigureSearch", nil);
    
    zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zeroOptionButton];
}

-(void)initTableView
{
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
}
-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:moreOptionButton]) {
        zeroOptionButton.selected = NO;
        moreOptionButton.selected = YES;
        gategoryStr = @"LongSystem";
    }else{
        zeroOptionButton.selected = YES;
        moreOptionButton.selected = NO;
        gategoryStr = @"ShortSystem";
    }
    [mainTableView reloadData];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSMutableArray *constraintsArray = [[NSMutableArray alloc]init];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(moreOptionButton, zeroOptionButton, mainTableView);
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-2-[zeroOptionButton(==moreOptionButton)]|" options:0 metrics:nil views:viewController]];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[moreOptionButton(44)][mainTableView]|" options:0 metrics:nil views:viewController]];
    [constraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[zeroOptionButton(44)]" options:0 metrics:nil views:viewController]];
    
    [self replaceCustomizeConstraints:constraintsArray];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(moreOptionButton.selected){
        return [longName count];
    }else{
        return [shortName count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EDOTargetCell";
    EODActionTableCell *cell = (EODActionTableCell *)[mainTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[EODActionTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier controller:self];
    cell.delegate = self;

    cell.tag = indexPath.row;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if(moreOptionButton.selected){
        [cell setCount:(int)[[imageLongDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]count]];
        [cell setImgArray:[imageLongDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]];
        [cell setNameArray:[imageLongDictionary objectForKey:[NSString stringWithFormat:@"name%d", (int)indexPath.row]]];
        cell.stockName.text = [longName objectAtIndex:indexPath.row];
    }else if(zeroOptionButton.selected){
        [cell setCount:(int)[[imageShortDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]count]];
        [cell setImgArray:[imageShortDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]];
        [cell setNameArray:[imageShortDictionary objectForKey:[NSString stringWithFormat:@"name%d", (int)indexPath.row]]];
        cell.stockName.text = [shortName objectAtIndex:indexPath.row];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    PortfolioItem *portfolioItem;
    if(moreOptionButton.selected){
        [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[[longSymbolKey objectAtIndex:indexPath.row]]];
        portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[longSymbolKey objectAtIndex:indexPath.row]];
    }else if(zeroOptionButton.selected){
        [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[[shortSymbolKey objectAtIndex:indexPath.row]]];
        portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[shortSymbolKey objectAtIndex:indexPath.row]];
    }
    watchPortfolio.portfolioItem = portfolioItem;
    
    mainViewController.firstLevelMenuOption =1;
    mainViewController.techOption = AnalysisPeriodDay;
    [self.navigationController pushViewController:mainViewController animated:NO];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

-(void)btnBeClick:(NSInteger)row
{
    FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    PortfolioItem *portfolioItem;
    if(moreOptionButton.selected){
        [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[[longSymbolKey objectAtIndex:row]]];
        portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[longSymbolKey objectAtIndex:row]];
    }else if(zeroOptionButton.selected){
        [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[[shortSymbolKey objectAtIndex:row]]];
        portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[shortSymbolKey objectAtIndex:row]];
    }
    watchPortfolio.portfolioItem = portfolioItem;
    
    mainViewController.firstLevelMenuOption =1;
    mainViewController.techOption = AnalysisPeriodDay;
    [self.navigationController pushViewController:mainViewController animated:NO];
}


@end
@implementation ActionObject
@end
