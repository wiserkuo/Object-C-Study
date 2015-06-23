//
//  FSNewPriceByVolumeViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/29.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSNewPriceByVolumeViewController.h"
#import "FSPriceByVolumeTableViewCell.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSEquityInfoPanel.h"
#import "FSDistributeOut.h"
#import "FSDistributeIn.h"
#import "DDPageControl.h"
#import "FSBAQuery.h"
#import "Commodity.h"
#import "PortfolioOut.h"

@interface FSNewPriceByVolumeViewController ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, DataArriveProtocol>{

    UITableView *priceByVolumeTableView;
    UIView *priceByVolumeTableViewHeaderView;
    NSMutableArray *distributeDataArray;
    
    FSEquityInfoPanel *infoPanel;
    FSSnapshot *symbolSnapshot;
//    PortfolioItem * portfolioItem;
    FSSnapshot * snapshot;
    FSInstantInfoWatchedPortfolio *watchPortfolio;
    DDPageControl *pageControl;
//    FSDataModelProc *dataModel;
    
    double totalVol;
}

@end

@implementation FSNewPriceByVolumeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.tradeDistribute setTarget:self];
    
    [[[FSDataModelProc sharedInstance]portfolioTickBank] setTaget:self IdentCodeSymbol:[watchPortfolio.portfolioItem getIdentCodeSymbol]];
    [[[FSDataModelProc sharedInstance]portfolioTickBank] updateTickDataByIdentCodeSymbol:[watchPortfolio.portfolioItem getIdentCodeSymbol]];
    
    snapshot = [[[FSDataModelProc sharedInstance] portfolioTickBank] getSnapshotBvalueFromIdentCodeSymbol:watchPortfolio.portfolioItem.getIdentCodeSymbol];
    [dataModel.category setTargetObj:self];
    [dataModel.category searchSectorIdByIdentCode:[NSString stringWithFormat:@"%c%c",watchPortfolio.portfolioItem->identCode[0],watchPortfolio.portfolioItem->identCode[1]] Symbol:watchPortfolio.portfolioItem->symbol];
    
    [self sendRequest9_11];
    [self registerLoginNotificationCallBack:self seletor:@selector(sendRequest9_11)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendRequest9_11)];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];

    if (watchPortfolio.portfolioItem != nil) {
        [[[FSDataModelProc sharedInstance]portfolioTickBank] removeKeyWithTaget:self IdentCodeSymbol:[watchPortfolio.portfolioItem getIdentCodeSymbol]];
    }
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.tradeDistribute setTarget:nil];
    [dataModel.category setTargetObj:nil];
    distributeDataArray = nil;
}
-(void)initView
{
    watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    [self addPriceByVolumeTableView];
    [self addInfoPanel];
    
    [self initPageControll];
    [self addHeaderView];

    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    
    NSDictionary *viewConstraints = NSDictionaryOfVariableBindings(priceByVolumeTableView, infoPanel);
    NSDictionary *metrics = @{@"panelHeight" : @(100)};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[priceByVolumeTableView][infoPanel(panelHeight)]|" options:0 metrics:metrics views:viewConstraints]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[priceByVolumeTableView]|" options:0 metrics:metrics views:viewConstraints]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoPanel]|" options:0 metrics:metrics views:viewConstraints]];
    
    [self replaceCustomizeConstraints:constraints];
}
- (void)addPriceByVolumeTableView
{
    priceByVolumeTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    priceByVolumeTableView.translatesAutoresizingMaskIntoConstraints = NO;
    priceByVolumeTableView.bounces = NO;
    priceByVolumeTableView.delegate = self;
    priceByVolumeTableView.dataSource = self;
    [self.view addSubview:priceByVolumeTableView];
}

-(void)sendRequest9_11
{
    UInt16 newDate = [CodingUtil dateConvertToNewDate:snapshot.trading_date.date16];
    NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c:%@",watchPortfolio.portfolioItem->identCode[0], watchPortfolio.portfolioItem->identCode[1], watchPortfolio.portfolioItem->symbol];
    
    FSDistributeOut *packetOut = [[FSDistributeOut alloc]initWithOneDayIdentCodeSymbol:identCodeSymbol number:0 date:newDate];
    [FSDataModelProc sendData:self WithPacket:packetOut];
    
    PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
    snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:portfolioItem.getIdentCodeSymbol];
    if (snapshot) {
        [infoPanel reloadBValueSnapshot:snapshot];
    }
}

- (void)addHeaderView
{
    CGRect headerViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, 33);
    priceByVolumeTableViewHeaderView = [[UIView alloc] initWithFrame:headerViewFrame];
    priceByVolumeTableViewHeaderView.backgroundColor = [UIColor colorWithRed:0.044 green:0.337 blue:0.442 alpha:1.000];
    CGFloat offset;
        offset = self.view.bounds.size.width / 3;
    for (NSUInteger labelCounter = 0; labelCounter < 3; labelCounter++) {
        UILabel *label = [[UILabel alloc] init];
//        label.font = [UIFont systemFontOfSize:20.0f];
        label.frame = CGRectMake(offset * labelCounter, 0, offset, 33);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];

        switch (labelCounter) {
            case 0:
                label.text = NSLocalizedStringFromTable(@"成價", @"Equity", @"");
                break;
            case 1:
                label.text = NSLocalizedStringFromTable(@"成量", @"Equity", @"");
                break;
            case 2:
                label.text = NSLocalizedStringFromTable(@"比例", @"Equity", @"");
                break;
            default:
                break;
        }
        [priceByVolumeTableViewHeaderView addSubview:label];
    }
}

-(void)initPageControll
{
    infoPanel.delegate = self;
    pageControl = [[DDPageControl alloc] init];
    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    pageControl.numberOfPages = 4;
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        
        pageControl.numberOfPages = 2;
        
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        
        if (portfolioItem->type_id == 6) {
            
            pageControl.numberOfPages = 2;
            
        } else if (portfolioItem->type_id == 3){
            
            pageControl.numberOfPages = 1;
            
        }
        
    } else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        
        if (portfolioItem->type_id == 6) {
            
            pageControl.numberOfPages = 2;
            
        } else if (portfolioItem->type_id == 3) {
            
            pageControl.numberOfPages = 2;
            
        }
    }
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    pageControl.currentPage =[dataModel.infoPanelCenter.currentInfoPage intValue];
    [pageControl setDefersCurrentPageDisplay: YES] ;
    [pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
    [pageControl setOnColor: [UIColor redColor]];
    [pageControl setOffColor: [UIColor redColor]];
    [pageControl setIndicatorDiameter: 7.0f] ;
    [pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:pageControl];
}

-(void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat pageWidth = infoPanel.bounds.size.width;
    float fractionalPage = infoPanel.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    FSBAQuery *baQuery = [[FSBAQuery alloc]init];
    if (pageControl.currentPage != nearestNumber) {
        pageControl.currentPage = nearestNumber;
        if (infoPanel.dragging) {
            PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
            [pageControl updateCurrentPageDisplay] ;
            if (nearestNumber == 2) {//瀏覽最佳五檔
                [baQuery sendWithIdentCodeSymbol:[portfolioItem getIdentCodeSymbol]];
                [portfolioItem setFocus];
            }else if(fractionalPage >= 1 && fractionalPage < 4){
                [portfolioItem killFocus];
            }
        }
    }
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    dataModel.infoPanelCenter.currentInfoPage = @(pageControl.currentPage);
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
    [pageControl updateCurrentPageDisplay] ;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return priceByVolumeTableViewHeaderView;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [distributeDataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FSPriceByVolumeTableViewCell";

    FSPriceByVolumeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FSPriceByVolumeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    double referencePrice = 0;
    
    if (snapshot) {
        referencePrice = snapshot.reference_price.calcValue;
    }

    cell.hasPlat = NO;
    FSDistributeObj *data = [distributeDataArray objectAtIndex:indexPath.row];

    cell.priceLabel.attributedText = [self priceLabelFormat:data ReferencePrice:referencePrice];
    cell.volumeLabel.text = [CodingUtil stringWithVolumeByValueNoDecimal:data.volume.calcValue];
    cell.percentageLabel.text = [NSString stringWithFormat:@"%.1f%%", (data.volume.calcValue / totalVol) * 100];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)addInfoPanel
{
    infoPanel = [[FSEquityInfoPanel alloc] initWithPortfolioItem:watchPortfolio.portfolioItem];
    infoPanel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:infoPanel];
}

-(void)dataArrive:(FSDistributeIn *)data
{
    if (data) {
        FSDistributeIn *td = (FSDistributeIn *)data;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"price.calcValue" ascending:NO selector:@selector(compare:)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArr = [[NSArray arrayWithArray:td -> tdArray] sortedArrayUsingDescriptors:sortDescriptors];
        
        distributeDataArray = [NSMutableArray arrayWithArray:sortedArr];
        for(int i = 0; i < [distributeDataArray count]; i++){
            FSDistributeObj *data = [distributeDataArray objectAtIndex:i];
            totalVol += data.volume.calcValue;
        }
        
        [priceByVolumeTableView reloadData];
    }
}

-(void)sectorIdCallBack:(NSMutableArray *)dataArray
{
    [infoPanel reloadMarketInfo:dataArray];
}

- (void)notifyDataArrive:(NSObject <TickDataSourceProtocol> *)dataSource
{
    snapshot = [[[FSDataModelProc sharedInstance] portfolioTickBank] getSnapshotBvalueFromIdentCodeSymbol:dataSource.getIdenCodeSymbol];
    if (snapshot) {
        [infoPanel reloadBValueSnapshot:snapshot];
        [priceByVolumeTableView reloadData];
    }
}
-(NSMutableAttributedString *)priceLabelFormat:(FSDistributeObj *)data ReferencePrice:(double)referencePrice
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    NSMutableAttributedString *mark = [[NSMutableAttributedString alloc]initWithString:[dataModel.tradeDistribute signByExamingPrice:data.price.calcValue equalToOpenPrice:snapshot.open_price.calcValue closePrice:snapshot.last_price.calcValue]];
    
    [mark addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, [mark length])];
    NSMutableAttributedString *price = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%.2f", data.price.calcValue]];
    
    NSRange priceRange = NSMakeRange(0, [price length]);
    
    if (data.price.calcValue > referencePrice) {
        [price addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceUpColor] range:priceRange];
        
    }else if(data.price.calcValue < referencePrice){
        [price addAttribute:NSForegroundColorAttributeName value:[StockConstant PriceDownColor] range:priceRange];
    }else{
        [price addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:priceRange];
    }
    [price appendAttributedString:mark];
    
    return price;
}

-(void)viewDidLayoutSubviews
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [pageControl setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height - 10)];
    infoPanel.contentOffset = CGPointMake(infoPanel.bounds.size.width * [dataModel.infoPanelCenter.currentInfoPage intValue], 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
