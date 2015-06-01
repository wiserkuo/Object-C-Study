//
//  TrendEODActionViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TrendEODActionViewController.h"
#import "FigureSearchCollectionViewCell.h"
#import "FigureSearchViewLayout.h"
#import "EODActionTableCell.h"
#import "TrendEODActionModel.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "UIViewController+CustomNavigationBar.h"

@interface TrendEODActionViewController ()
{
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    UITableView *mainTableView;
    NSString *gategoryStr;
    UICollectionView *collectionView;
    FigureSearchViewLayout *layout;
    FSDataModelProc *model;
    FSInstantInfoWatchedPortfolio *watchPortfolio;
    NSMutableArray *imgArray;
    NSMutableDictionary *imageLongDictionary;
    NSMutableDictionary *imageShortDictionary;
    NSMutableDictionary *imageLongNameDictionary;
    NSMutableDictionary *imageShortNameDictionary;
    int longCount;
    int shortCount;
    NSMutableDictionary * symbolDict;
    NSMutableArray *longName;
    NSMutableArray *shortName;
    NSMutableArray *longSymbolKey;
    NSMutableArray *shortSymbolKey;
    int symbolLongKeyCount;
    int symbolShortKeyCount;
}
@end

@implementation TrendEODActionViewController

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
	self.title = NSLocalizedStringFromTable(@"EOD Check", @"FigureSearch", nil);
    [self setUpImageBackButton];
    [self initMoreOption];
    [self initZeroOption];
    [self initSymbol];
    [self initTableView];
    [self processLayout];
    watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    gategoryStr = @"LongSystem";
    imgArray = [[NSMutableArray alloc] init];
    imageLongDictionary = [[NSMutableDictionary alloc] init];
    imageShortDictionary = [[NSMutableDictionary alloc] init];
    imageLongNameDictionary = [[NSMutableDictionary alloc] init];
    imageShortNameDictionary = [[NSMutableDictionary alloc] init];
    longCount = 0;
    shortCount = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODCheckALL showAlertViewToShopping:YES]) {
        UIView * noSupperView = [[UIView alloc]initWithFrame:self.view.bounds];
        noSupperView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        [self.view addSubview:noSupperView];
    }
    
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    [model.trendEODModel setTargetNotify:self];
    
    if(symbolLongKeyCount < [longSymbolKey count]){
        [model.trendEODModel getFigureImage:[longSymbolKey objectAtIndex:symbolLongKeyCount] Type:@"Long"];
    }else{
        if(symbolShortKeyCount < [shortSymbolKey count]){
            [model.trendEODModel getFigureImage:[shortSymbolKey objectAtIndex:symbolShortKeyCount] Type:@"Short"];
        }
    }
}

-(void)initSymbol
{
    symbolLongKeyCount = 0;
    symbolShortKeyCount = 0;
    longName = [[NSMutableArray alloc] init];
    shortName = [[NSMutableArray alloc] init];
    longSymbolKey = [[NSMutableArray alloc] init];
    shortSymbolKey = [[NSMutableArray alloc] init];
    NSString *symbolPath = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"AlertData.plist"]];
    symbolDict = [[NSMutableDictionary alloc]init];
    symbolDict = [NSMutableDictionary dictionaryWithContentsOfFile:symbolPath];
    symbolDict = [symbolDict objectForKey:@"priceAlert"];
    
    for( NSString *aKey in [symbolDict allKeys] ){
        NSMutableArray * dataArray = [symbolDict objectForKey:aKey];
        for(int i=0 ; i<=[dataArray count]; i++){
            if([(NSNumber *)[[dataArray objectAtIndex:i]objectForKey:@"termId"]intValue]==503){
                [longSymbolKey addObject:aKey];
                [longName addObject:[aKey substringFromIndex:3]];
                break;
            }else if([(NSNumber *)[[dataArray objectAtIndex:i]objectForKey:@"termId"]intValue]==504){
                [shortSymbolKey addObject:aKey];
                [shortName addObject:[aKey substringFromIndex:3]];
                break;
            }
        }
    }
    [self initModel];
}


-(void)notifyLongData:(id)target
{
    ArrayData *arrayData = target;
    if(arrayData->dataArray !=nil){
        [imageLongDictionary setObject:arrayData->dataArray forKey:[NSString stringWithFormat:@"%d",longCount]];
        [imageLongNameDictionary setObject:arrayData->nameArray forKey:[NSString stringWithFormat:@"%d",longCount]];
    }
    longCount ++;
    [mainTableView reloadData];
    symbolLongKeyCount ++;
    if(symbolLongKeyCount < [longSymbolKey count]){
        [model.trendEODModel getFigureImage:[longSymbolKey objectAtIndex:symbolLongKeyCount] Type:@"Long"];
    }else{
        if(symbolShortKeyCount < [shortSymbolKey count]){
            [model.trendEODModel getFigureImage:[shortSymbolKey objectAtIndex:symbolShortKeyCount] Type:@"Short"];
        }
    }
    
}

-(void)notifyShortData:(id)target
{
    ArrayData *arrayData = target;
    if(arrayData->dataArray !=nil){
        [imageShortDictionary setObject:arrayData->dataArray forKey:[NSString stringWithFormat:@"%d",shortCount]];
        [imageShortNameDictionary setObject:arrayData->nameArray forKey:[NSString stringWithFormat:@"%d",shortCount]];
    }
    shortCount ++;
    [mainTableView reloadData];
    symbolShortKeyCount ++;
    if(symbolShortKeyCount < [shortSymbolKey count]){
        [model.edoActionModel getFigureImage:[shortSymbolKey objectAtIndex:symbolShortKeyCount] Type:@"Short"];
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

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(moreOptionButton, zeroOptionButton, mainTableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-2-[zeroOptionButton(==moreOptionButton)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[moreOptionButton(44)][mainTableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[zeroOptionButton(44)]" options:0 metrics:nil views:viewController]];
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
    
    cell = [[EODActionTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    //cell.stockName.text = [model.edoActionModel getStockName:indexPath];
    if(moreOptionButton.selected){
        [cell setCount:(int)[[imageLongDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]count]];
        [cell setImgArray:[imageLongDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]];
        [cell setNameArray:[imageLongNameDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]];
        cell.stockName.text = [longName objectAtIndex:indexPath.row];
    }else if(zeroOptionButton.selected){
        [cell setCount:(int)[[imageShortDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]count]];
        [cell setImgArray:[imageShortDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]];
        [cell setNameArray:[imageShortNameDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.row]]];
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

@end
