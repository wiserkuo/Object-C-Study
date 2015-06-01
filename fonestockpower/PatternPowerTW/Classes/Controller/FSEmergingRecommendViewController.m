//
//  FSEmergingRecommendViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSEmergingRecommendViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SKCustomTableView.h"
#import "FSEmergingRecCollectViewController.h"
#import "FSEmergingObject.h"
#import "FMDB.h"
#import "InternationalInfoObject_v1.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"


@interface FSEmergingRecommendViewController ()<SKCustomTableViewDelegate>
{
    UILabel *brokerageLabel;
    UIButton *brokerageBtn;
    
    NSMutableArray *verticalConstraints;
    NSMutableArray *contentMutableArray;
    
    InternationalInfoObject_v1 *inter;
    RecObject *brokerObj;
    SKCustomTableView *brokerageTableView;
    FSDataModelProc *dataModel;

}
@end

@implementation FSEmergingRecommendViewController

-(UICollectionViewFlowLayout *)flowLayout{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    flowLayout.minimumLineSpacing = 20.0f;
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.itemSize = CGSizeMake(80.0f, 40.0f);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    
    return flowLayout;
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
    [self initView];
    [self firstTableViewContent];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![RecObject sharedInstance].changeBtnName) {
        [brokerageBtn setTitle:@"臺銀" forState:UIControlStateNormal];
    }else{
        [brokerageBtn setTitle:[NSString stringWithFormat:@"%@", [RecObject sharedInstance].changeBtnName] forState:UIControlStateNormal];
        contentMutableArray = [brokerObj parserRecBrokerObj:[RecObject sharedInstance].brokerIDWithT :@"NULL"];

    }
    [dataModel.portfolioData setTarget:self];
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:[RecObject sharedInstance].recBrokerSymbol];
    if ([[RecObject sharedInstance].recBrokerSymbol count] == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"沒有個股資訊" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil];
        [alert show];
    }
    [brokerageTableView reloadAllData];

}
-(void)initView{
    brokerObj = [[RecObject alloc]init];
    dataModel = [FSDataModelProc sharedInstance];
    inter = [[InternationalInfoObject_v1 alloc]init];
    if([RecObject sharedInstance].brokerIDWithT){
        contentMutableArray = [brokerObj parserRecBrokerObj:[RecObject sharedInstance].brokerIDWithT :@"NULL"];
    }else{
        contentMutableArray = [brokerObj parserRecBrokerObj:@"104T" :@"NULL"];
    }
    [self setUpImageBackButton];
    
    self.title = NSLocalizedStringFromTable(@"推薦券商", @"Emerging", nil);
    
    verticalConstraints = [[NSMutableArray alloc]init];
    
    brokerageLabel = [[UILabel alloc]init];
    brokerageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageLabel.text = @"證券商";
    brokerageLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    [self.view addSubview:brokerageLabel];
    
    brokerageBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    brokerageBtn.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageBtn.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [brokerageBtn addTarget:self action:@selector(choiceHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:brokerageBtn];
    
    brokerageTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:77 mainColumnWidth:70 AndColumnHeight:44];
    brokerageTableView.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageTableView.delegate = self;
    [self.view addSubview:brokerageTableView];
    
    [self.view setNeedsUpdateConstraints];
}
-(void)firstTableViewContent{
    NewSymbolObject *newObj = [contentMutableArray objectAtIndex:0];
    [dataModel.securityName setTarget:self];
    [dataModel.securityName selectCatID:[newObj.symbol intValue]];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *mainViewArray = NSDictionaryOfVariableBindings(brokerageLabel, brokerageBtn, brokerageTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[brokerageLabel(60)][brokerageBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[brokerageLabel]" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[brokerageTableView]|" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[brokerageBtn]-2-[brokerageTableView]|" options:0 metrics:nil views:mainViewArray]];
    
    [self replaceCustomizeConstraints:constraints];
}
-(void)notify{
}

-(void)reloadData{
    [brokerageTableView reloadAllData];
    for (NewSymbolObject *obj in [RecObject sharedInstance].recBrokerSymbol) {
        [dataModel.portfolioTickBank setTaget:self IdentCodeSymbol:[NSString stringWithFormat:@"%@ %@", obj.identCode, obj.symbol]];
    }
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = [[RecObject sharedInstance].recBrokerName objectAtIndex:indexPath.row];

}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewSymbolObject *name = [contentMutableArray objectAtIndex:indexPath.row];
    EquitySnapshotDecompressed *mySnapShot = [dataModel.portfolioTickBank getSnapshotFromIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@", name.identCode, name.symbol]];
    CGFloat change = 0.0;
    if (columnIndex == 0) {
        if (mySnapShot.currentPrice == 0) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }else{
            label.text = [inter convertDecimalPoint:mySnapShot.currentPrice];
            change = (mySnapShot.currentPrice - mySnapShot.referencePrice);
            label.textColor = [inter compareToZero:change];
        }
    }
    else if (columnIndex == 1) {
        if (mySnapShot.currentPrice == 0 || mySnapShot.referencePrice == 0) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];

        }else{
            change = (mySnapShot.currentPrice - mySnapShot.referencePrice);
            label.text = [inter formatCGFloatDataChange:change];
            label.textColor = [inter compareToZero:change];
        }
    }
    else if (columnIndex == 2) {
        if (mySnapShot.currentPrice == 0 || mySnapShot.referencePrice == 0) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];

        }else{
            change = ((mySnapShot.currentPrice - mySnapShot.referencePrice) / mySnapShot.currentPrice) *100;
            label.text = [inter formatCGFloatDataChangeUp:change];
            label.textColor = [inter compareToZero:change];
        }
    }
    else if (columnIndex == 3) {
        if (mySnapShot.accumulatedVolume == 0) {
            label.text = @"----";
        }
        label.text = [NSString stringWithFormat:@"%.f",mySnapShot.accumulatedVolume];

    }
    label.textAlignment = NSTextAlignmentRight;

}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"名稱", @"Emerging", @"nil")];
}

-(NSArray *)columnsInMainTableView{
    return @[NSLocalizedStringFromTable(@"最新", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"漲跌", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"漲幅", @"Emerging", @"nil"),
             NSLocalizedStringFromTable(@"總量", @"Emerging", @"nil")];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[RecObject sharedInstance].recBrokerName count];
    
}
-(void)choiceHandler:(UIButton *)sender{
    FSEmergingRecCollectViewController *sec = [[FSEmergingRecCollectViewController alloc]init];
    sec.Recommend = self;
    [self.navigationController pushViewController:sec animated:NO];
}

-(void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource{
    if ([dataSource isKindOfClass:[EquityTick class]]) {
        EquityTick *data = (EquityTick *)dataSource;
        NSString *identCodeSymbol = data.identCodeSymbol;
        int row = -1;
        
        for (int i = 0; i < [[RecObject sharedInstance].recBrokerSymbol count]; i++){
            NewSymbolObject *obj = [[RecObject sharedInstance].recBrokerSymbol objectAtIndex:i];
            if ([identCodeSymbol isEqualToString:[NSString stringWithFormat:@"%@ %@", obj.identCode, obj.symbol]]) {
                row = i;
                break;
            }
        }
        if (row >= 0) {
            if (row < [[brokerageTableView indexPathsForVisibleRows] count]) {
                NSIndexPath *indexPath = [[brokerageTableView indexPathsForVisibleRows]objectAtIndex:row];
                [brokerageTableView.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NewSymbolObject *obj = [[RecObject sharedInstance].recBrokerSymbol objectAtIndex:indexPath.row];
    FSMainViewController *mainView = [[FSMainViewController alloc]init];
    
    NSString *identCodeSymbol = [NSString stringWithFormat:@"%@ %@", obj.identCode, obj.symbol];
    
    PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
    FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    
    instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
    //push to mainView 技術
    mainView.firstLevelMenuOption = 1;
    [self.navigationController pushViewController:mainView animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
