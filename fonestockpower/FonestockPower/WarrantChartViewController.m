//
//  WarrantChartViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantChartViewController.h"
#import "WarrantChartView.h"
#import "FSEquityDrawViewTickPlotDataSource.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSEquityDrawCrossHairInfoPanel.h"
@interface WarrantChartViewController ()<DataArriveProtocol>
{
    FSInstantInfoWatchedPortfolio * watchPortfolio;
    WarrantChartView *topView;
    WarrantChartView *bottomView;
    FSDataModelProc *model;
    NSMutableArray *timeArray;
    NSMutableArray *priceArray;
    NSMutableArray *lastPriceArray;
    NSMutableArray *lastVolumeArray;
    NSMutableArray *lastBidArray;
    NSMutableArray *lastAskArray;
    NSMutableArray *volumeArray;
    NSMutableArray *drawVolumeArray;
    NSMutableArray *changeArray;
    NSMutableArray *sumVolumeArray;
    NSMutableArray *tickTimeArray;
    
    NSMutableArray *comparedTimeArray;
    NSMutableArray *comparedPriceArray;
    NSMutableArray *comparedLastPriceArray;
    NSMutableArray *comparedLastVolumeArray;
    NSMutableArray *comparedLastBidArray;
    NSMutableArray *comparedLastAskArray;
    NSMutableArray *comparedVolumeArray;
    NSMutableArray *comparedDrawVolumeArray;
    NSMutableArray *comparedChangeArray;
    NSMutableArray *comparedSumVolumeArray;
    NSMutableArray *comparedTickTimeArray;
    
    NSMutableDictionary *dict;
    UILabel *vertical;
    UILabel *comparedVertical;
    FSEquityDrawCrossHairInfoPanel *infoView;
    FSEquityDrawCrossHairInfoPanel *bottomInfoView;
    EquitySnapshotDecompressed *mySnapshot;
    EquitySnapshotDecompressed *comparedSnapshot;
    UILabel *priceLabel1;
    UILabel *priceLabel2;
    UILabel *priceLabel3;
    UILabel *priceLabel4;
    UILabel *priceLabel5;
    
    UILabel *comparedPriceLabel1;
    UILabel *comparedPriceLabel2;
    UILabel *comparedPriceLabel3;
    UILabel *comparedPriceLabel4;
    UILabel *comparedPriceLabel5;
    
    UILabel *volumeLabel1;
    UILabel *volumeLabel2;
    UILabel *volumeLabel3;
    
    UILabel *comparedVolumeLabel1;
    UILabel *comparedVolumeLabel2;
    UILabel *comparedVolumeLabel3;
    
    MarketInfoItem *marketInfo;
    MarketInfoItem *comparedMarketInfo;
}
@end

@implementation WarrantChartViewController

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
	[self initChartView];
    [self initVertical];
    [self initLeftLabel];
    [self tickHandler];
    [self.view setNeedsUpdateConstraints];
}


-(void)initInfoView
{
    infoView = [[FSEquityDrawCrossHairInfoPanel alloc] initWithFrameByWarrant:CGRectMake(self.view.frame.size.width-180, topView.frame.size.height-90, 70 , 90)];
    infoView.backgroundColor = [UIColor whiteColor];
    [topView addSubview:infoView];
    infoView.hidden = YES;
    
    UIFont *font = [UIFont boldSystemFontOfSize:17.0f];
    infoView.timeContentLabel.font = [UIFont boldSystemFontOfSize:10.0f];
    infoView.volContentLabel.font = font;
    infoView.bidContentLabel.font = font;
    infoView.askContentLabel.font = font;
    infoView.lastPriceContentLabel.font = font;
    infoView.changeContentLabel.font = font;


    bottomInfoView = [[FSEquityDrawCrossHairInfoPanel alloc] initWithFrameByWarrant:CGRectMake(self.view.frame.size.width-180, bottomInfoView.frame.size.height-90, 70 , 90)];
    bottomInfoView.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:bottomInfoView];
    bottomInfoView.hidden = YES;
    
    bottomInfoView.timeContentLabel.font = [UIFont boldSystemFontOfSize:10.0f];
    bottomInfoView.volContentLabel.font = font;
    bottomInfoView.bidContentLabel.font = font;
    bottomInfoView.askContentLabel.font = font;
    bottomInfoView.lastPriceContentLabel.font = font;
    bottomInfoView.changeContentLabel.font = font;
}

-(void)viewDidLayoutSubviews
{
    [self initInfoView];
}

-(void)initVertical
{
    if (!vertical) {
        vertical = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 1, topView.frame.size.height)];
        vertical.layer.borderColor = [UIColor blueColor].CGColor;
        vertical.layer.borderWidth = 0.5;
        [topView addSubview:vertical];
        vertical.hidden = YES;
    }
    if (!comparedVertical) {
        comparedVertical = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 1, bottomView.frame.size.height)];
        comparedVertical.layer.borderColor = [UIColor blueColor].CGColor;
        comparedVertical.layer.borderWidth = 0.5;
        [bottomView addSubview:comparedVertical];
        comparedVertical.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tickHandler
{
    model = [FSDataModelProc sharedInstance];
    watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if(watchPortfolio.portfolioItem){
    [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:[NSString stringWithFormat:@"%c%c %@",watchPortfolio.portfolioItem->identCode[0], watchPortfolio.portfolioItem->identCode[1], watchPortfolio.portfolioItem->symbol] GetTick:YES];
    }
    if(watchPortfolio.comparedPortfolioItem){
    [[[FSDataModelProc sharedInstance]portfolioTickBank] watchTarget:self ForEquity:[NSString stringWithFormat:@"%c%c %@",watchPortfolio.comparedPortfolioItem->identCode[0], watchPortfolio.comparedPortfolioItem->identCode[1], watchPortfolio.comparedPortfolioItem->symbol] GetTick:YES];
    }
}


- (void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource
{
    NSLog(@"%f",dataSource.progress);
    if([[dataSource getIdenCodeSymbol] isEqualToString:[NSString stringWithFormat:@"%c%c %@",watchPortfolio.portfolioItem->identCode[0], watchPortfolio.portfolioItem->identCode[1], watchPortfolio.portfolioItem->symbol]]){
        if(dataSource.progress > 0.99){
            dict = [[NSMutableDictionary alloc] init];
            timeArray = [[NSMutableArray alloc] init];
            priceArray = [[NSMutableArray alloc] init];
            lastPriceArray = [[NSMutableArray alloc] init];
            volumeArray = [[NSMutableArray alloc] init];
            lastVolumeArray = [[NSMutableArray alloc] init];
            sumVolumeArray = [[NSMutableArray alloc] init];
            lastBidArray = [[NSMutableArray alloc] init];
            lastAskArray = [[NSMutableArray alloc] init];
            changeArray = [[NSMutableArray alloc] init];
            drawVolumeArray = [[NSMutableArray alloc] init];
            tickTimeArray = [[NSMutableArray alloc] init];
            for(int i =0; i<271; i++){
                [lastAskArray addObject:[NSNumber numberWithDouble:0]];
                [lastBidArray addObject:[NSNumber numberWithDouble:0]];
                [lastPriceArray addObject:[NSNumber numberWithDouble:0]];
                [lastVolumeArray addObject:[NSNumber numberWithDouble:0]];
                [changeArray addObject:[NSNumber numberWithDouble:0]];
                [tickTimeArray addObject:[NSNumber numberWithInt:0]];
                [drawVolumeArray addObject:[NSNumber numberWithInt:0]];
            }
            marketInfo = [model.marketInfo getMarketInfo:watchPortfolio.portfolioItem->market_id];
            
            double drawVolume=0.00;
            PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]portfolioTickBank];
            mySnapshot = [tickBank getSnapshotFromIdentCodeSymbol:[NSString stringWithFormat:@"%c%c %@",watchPortfolio.portfolioItem->identCode[0], watchPortfolio.portfolioItem->identCode[1], watchPortfolio.portfolioItem->symbol]];
            
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for( int i = 1; i<=[dataSource tickCount]; i++){
                EquityTickDecompressed *tick = (EquityTickDecompressed*)[dataSource copyTickAtSequenceNo:i];
                if(tick.time>270){
                    break;
                }
                ChartObject *obj = [[ChartObject alloc ]init];
                obj->date = tick.time;
                obj->price = tick.price;
                obj->change = tick.price-mySnapshot.referencePrice;
                obj->bid = tick.bid;
                obj->ask = tick.ask;
                obj->volume = tick.volume;
                [lastAskArray setObject:[NSNumber numberWithDouble:tick.ask] atIndexedSubscript:tick.time];
                [lastBidArray setObject:[NSNumber numberWithDouble:tick.bid] atIndexedSubscript:tick.time];
                [lastPriceArray setObject:[NSNumber numberWithDouble:tick.price] atIndexedSubscript:tick.time];
                [changeArray setObject:[NSNumber numberWithDouble:tick.price-mySnapshot.referencePrice] atIndexedSubscript:tick.time];
                [tickTimeArray setObject:[NSNumber numberWithInt:tick.time] atIndexedSubscript:tick.time];
                
                
                double lastVolume = tick.volume - drawVolume;
                [lastVolumeArray setObject:[NSNumber numberWithDouble:lastVolume] atIndexedSubscript:tick.time];
                
                
                if([drawVolumeArray count]==0){
                    [drawVolumeArray setObject:[NSNumber numberWithInt:tick.volume] atIndexedSubscript:tick.time];
                }else{
                    double volume = tick.volume - drawVolume;
                    [drawVolumeArray setObject:[NSNumber numberWithInt:volume] atIndexedSubscript:tick.time];
                }
                
                
                
                drawVolume = tick.volume;
                [priceArray addObject:[NSNumber numberWithDouble:tick.price]];
                [volumeArray addObject:[NSNumber numberWithDouble:tick.volume]];
                [timeArray addObject:[NSNumber numberWithInt:tick.time]];
                [dataArray addObject:obj];
            }
            [dict setObject:priceArray forKey:@"Price"];
            [dict setObject:volumeArray forKey:@"Volume"];
            
            [topView setDataAndDraw:priceArray timeData:timeArray volumeData:drawVolumeArray ReferencePrice:mySnapshot.referencePrice CeilingPrice:mySnapshot.ceilingPrice FloorPrice:mySnapshot.floorPrice startTime:marketInfo->startTime_1];
            [self LabelLayout];
            [self setRightLabel];
            [self setLeftLabel];
        }
        
    }else if([[dataSource getIdenCodeSymbol] isEqualToString:[NSString stringWithFormat:@"%c%c %@",watchPortfolio.comparedPortfolioItem->identCode[0], watchPortfolio.comparedPortfolioItem->identCode[1], watchPortfolio.comparedPortfolioItem->symbol]]){
        if(dataSource.progress > 0.99){
            dict = [[NSMutableDictionary alloc] init];
            comparedTimeArray = [[NSMutableArray alloc] init];
            comparedPriceArray = [[NSMutableArray alloc] init];
            comparedLastPriceArray = [[NSMutableArray alloc] init];
            comparedVolumeArray = [[NSMutableArray alloc] init];
            comparedLastVolumeArray = [[NSMutableArray alloc] init];
            comparedSumVolumeArray = [[NSMutableArray alloc] init];
            comparedLastBidArray = [[NSMutableArray alloc] init];
            comparedLastAskArray = [[NSMutableArray alloc] init];
            comparedChangeArray = [[NSMutableArray alloc] init];
            comparedDrawVolumeArray = [[NSMutableArray alloc] init];
            comparedTickTimeArray = [[NSMutableArray alloc] init];
            comparedMarketInfo = [model.marketInfo getMarketInfo:watchPortfolio.comparedPortfolioItem->market_id];
            
            for(int i =0; i<271; i++){
                [comparedLastAskArray addObject:[NSNumber numberWithDouble:0]];
                [comparedLastBidArray addObject:[NSNumber numberWithDouble:0]];
                [comparedLastPriceArray addObject:[NSNumber numberWithDouble:0]];
                [comparedLastVolumeArray addObject:[NSNumber numberWithDouble:0]];
                [comparedChangeArray addObject:[NSNumber numberWithDouble:0]];
                [comparedTickTimeArray addObject:[NSNumber numberWithInt:0]];
                [comparedDrawVolumeArray addObject:[NSNumber numberWithInt:0]];
            }
            
            double drawVolume=0.00;
            PortfolioTick *tickBank = [[FSDataModelProc sharedInstance]portfolioTickBank];
            comparedSnapshot = [tickBank getSnapshotFromIdentCodeSymbol:[NSString stringWithFormat:@"%c%c %@",watchPortfolio.comparedPortfolioItem->identCode[0], watchPortfolio.comparedPortfolioItem->identCode[1], watchPortfolio.comparedPortfolioItem->symbol]];
            NSMutableArray *dataArray = [[NSMutableArray alloc] init];
            for( int i = 1; i<=[dataSource tickCount]; i++){
                EquityTickDecompressed *tick = (EquityTickDecompressed*)[dataSource copyTickAtSequenceNo:i];
                ChartObject *obj = [[ChartObject alloc ]init];
                obj->date = tick.time;
                obj->price = tick.price;
                obj->change = tick.price-mySnapshot.referencePrice;
                obj->bid = tick.bid;
                obj->ask = tick.ask;
                obj->volume = tick.volume;
                [comparedLastAskArray setObject:[NSNumber numberWithDouble:tick.ask] atIndexedSubscript:tick.time];
                [comparedLastBidArray setObject:[NSNumber numberWithDouble:tick.bid] atIndexedSubscript:tick.time];
                [comparedLastPriceArray setObject:[NSNumber numberWithDouble:tick.price] atIndexedSubscript:tick.time];
                [comparedChangeArray setObject:[NSNumber numberWithDouble:tick.price-mySnapshot.referencePrice] atIndexedSubscript:tick.time];
                [comparedTickTimeArray setObject:[NSNumber numberWithInt:tick.time] atIndexedSubscript:tick.time];
                
                double lastVolume = tick.volume - drawVolume;
                [comparedLastVolumeArray setObject:[NSNumber numberWithDouble:lastVolume] atIndexedSubscript:tick.time];
                
                if([drawVolumeArray count]==0){
                    [comparedDrawVolumeArray setObject:[NSNumber numberWithInt:tick.volume] atIndexedSubscript:tick.time];
                }else{
                    double volume = tick.volume - drawVolume;
                    [comparedDrawVolumeArray setObject:[NSNumber numberWithInt:volume] atIndexedSubscript:tick.time];
                }
                drawVolume = tick.volume;
                [comparedPriceArray addObject:[NSNumber numberWithDouble:tick.price]];
                [comparedVolumeArray addObject:[NSNumber numberWithDouble:tick.volume]];
                [comparedTimeArray addObject:[NSNumber numberWithInt:tick.time]];
                [dataArray addObject:obj];
            }
            [dict setObject:comparedPriceArray forKey:@"ComparedPrice"];
            [dict setObject:comparedVolumeArray forKey:@"ComparedVolume"];
            
            double high = comparedSnapshot.highestPrice - comparedSnapshot.referencePrice;
            double low =  comparedSnapshot.referencePrice - comparedSnapshot.lowestPrice;
            double range = MAX(high,low);
            high = comparedSnapshot.referencePrice + range;
            low = comparedSnapshot.referencePrice - range;
            
            [bottomView setDataAndDraw:comparedPriceArray timeData:comparedTimeArray volumeData:comparedDrawVolumeArray ReferencePrice:comparedSnapshot.referencePrice CeilingPrice:high FloorPrice:low startTime:comparedMarketInfo->startTime_1];
            [self setComparedLabelLayout];
            [self setComparedRightLabel];
            [self setComparedLeftLabel];
        }
        
    }
}

-(void)initChartView
{
    topView = [[WarrantChartView alloc] initWithController:self];
    topView.layer.borderWidth = 1.0f;
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topView];

    bottomView = [[WarrantChartView alloc] initWithController:self];
    bottomView.layer.borderWidth = 1.0f;
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomView];
}
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(topView, bottomView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView][bottomView(==topView)]|" options:0 metrics:nil views:viewController]];
}

-(void)initLeftLabel
{
    priceLabel1 = [[UILabel alloc] init];
    priceLabel1.backgroundColor = [UIColor redColor];
    priceLabel1.adjustsFontSizeToFitWidth = YES;
    priceLabel1.textColor = [UIColor whiteColor];
    priceLabel1.textAlignment = NSTextAlignmentRight;
    [topView.leftTopView addSubview:priceLabel1];
    
    priceLabel2 = [[UILabel alloc] init];
    priceLabel2.textColor = [UIColor blueColor];
    priceLabel2.adjustsFontSizeToFitWidth = YES;
    priceLabel2.textAlignment = NSTextAlignmentRight;
    [topView.leftTopView addSubview:priceLabel2];
    
    priceLabel3 = [[UILabel alloc] init];
    priceLabel3.textColor = [UIColor brownColor];
    priceLabel3.adjustsFontSizeToFitWidth = YES;
    priceLabel3.textAlignment = NSTextAlignmentRight;
    [topView.leftTopView addSubview:priceLabel3];
    
    priceLabel4 = [[UILabel alloc] init];
    priceLabel4.textColor = [UIColor blueColor];
    priceLabel4.adjustsFontSizeToFitWidth = YES;
    priceLabel4.textAlignment = NSTextAlignmentRight;
    [topView.leftTopView addSubview:priceLabel4];
    
    priceLabel5 = [[UILabel alloc] init];
    priceLabel5.backgroundColor = [UIColor colorWithRed:29.0/255 green:112.0/255.0 blue:0 alpha:1];
    priceLabel5.textColor = [UIColor whiteColor];
    priceLabel5.adjustsFontSizeToFitWidth = YES;
    priceLabel5.textAlignment = NSTextAlignmentRight;
    [topView.leftTopView addSubview:priceLabel5];
    
    UIFont *font = [UIFont boldSystemFontOfSize:12.0f];
    volumeLabel1 = [[UILabel alloc] init];
    volumeLabel1.font = font;
    volumeLabel1.textColor = [UIColor colorWithRed:43.0/255.0 green:39.0/255.0 blue:173.0/255.0 alpha:1];
    volumeLabel1.textAlignment = NSTextAlignmentRight;
    [topView.leftBottomView addSubview:volumeLabel1];
    
    volumeLabel2 = [[UILabel alloc] init];
    volumeLabel2.font = font;
    volumeLabel2.textColor = [UIColor colorWithRed:43.0/255.0 green:39.0/255.0 blue:173.0/255.0 alpha:1];
    volumeLabel2.textAlignment = NSTextAlignmentRight;
    [topView.leftBottomView addSubview:volumeLabel2];
    
    volumeLabel3 = [[UILabel alloc] init];
    volumeLabel3.font = font;
    volumeLabel3.textColor = [UIColor colorWithRed:43.0/255.0 green:39.0/255.0 blue:173.0/255.0 alpha:1];
    volumeLabel3.textAlignment = NSTextAlignmentRight;
    [topView.leftBottomView addSubview:volumeLabel3];
    
    
    
    
    comparedPriceLabel1 = [[UILabel alloc] init];
    comparedPriceLabel1.backgroundColor = [UIColor redColor];
    comparedPriceLabel1.textColor = [UIColor whiteColor];
    comparedPriceLabel1.adjustsFontSizeToFitWidth = YES;
    comparedPriceLabel1.textAlignment = NSTextAlignmentRight;
    [bottomView.leftTopView addSubview:comparedPriceLabel1];
    
    comparedPriceLabel2 = [[UILabel alloc] init];
    comparedPriceLabel2.textColor = [UIColor blueColor];
    comparedPriceLabel2.adjustsFontSizeToFitWidth = YES;
    comparedPriceLabel2.textAlignment = NSTextAlignmentRight;
    [bottomView.leftTopView addSubview:comparedPriceLabel2];
    
    comparedPriceLabel3 = [[UILabel alloc] init];
    comparedPriceLabel3.textColor = [UIColor brownColor];
    comparedPriceLabel3.adjustsFontSizeToFitWidth = YES;
    comparedPriceLabel3.textAlignment = NSTextAlignmentRight;
    [bottomView.leftTopView addSubview:comparedPriceLabel3];
    
    comparedPriceLabel4 = [[UILabel alloc] init];
    comparedPriceLabel4.textColor = [UIColor blueColor];
    comparedPriceLabel4.adjustsFontSizeToFitWidth = YES;
    comparedPriceLabel4.textAlignment = NSTextAlignmentRight;
    [bottomView.leftTopView addSubview:comparedPriceLabel4];
    
    comparedPriceLabel5 = [[UILabel alloc] init];
    comparedPriceLabel5.backgroundColor = [UIColor colorWithRed:29.0/255 green:112.0/255.0 blue:0 alpha:1];
    comparedPriceLabel5.textColor = [UIColor whiteColor];
    comparedPriceLabel5.adjustsFontSizeToFitWidth = YES;
    comparedPriceLabel5.textAlignment = NSTextAlignmentRight;
    [bottomView.leftTopView addSubview:comparedPriceLabel5];
    
    comparedVolumeLabel1 = [[UILabel alloc] init];
    comparedVolumeLabel1.font = font;
    comparedVolumeLabel1.textColor = [UIColor colorWithRed:43.0/255.0 green:39.0/255.0 blue:173.0/255.0 alpha:1];
    comparedVolumeLabel1.textAlignment = NSTextAlignmentRight;
    [bottomView.leftBottomView addSubview:comparedVolumeLabel1];
    
    comparedVolumeLabel2 = [[UILabel alloc] init];
    comparedVolumeLabel2.font = font;
    comparedVolumeLabel2.textColor = [UIColor colorWithRed:43.0/255.0 green:39.0/255.0 blue:173.0/255.0 alpha:1];
    comparedVolumeLabel2.textAlignment = NSTextAlignmentRight;
    [bottomView.leftBottomView addSubview:comparedVolumeLabel2];
    
    comparedVolumeLabel3 = [[UILabel alloc] init];
    comparedVolumeLabel3.font = font;
    comparedVolumeLabel3.textColor = [UIColor colorWithRed:43.0/255.0 green:39.0/255.0 blue:173.0/255.0 alpha:1];
    comparedVolumeLabel3.textAlignment = NSTextAlignmentRight;
    [bottomView.leftBottomView addSubview:comparedVolumeLabel3];
}

-(void)setLeftLabel
{
    topView.symbolName.text = watchPortfolio.portfolioItem->fullName;
    
    double maxPrice = mySnapshot.ceilingPrice;
    double minPrice = mySnapshot.floorPrice;
    double maxDetailPrice = (maxPrice-mySnapshot.referencePrice)/2+mySnapshot.referencePrice;
    double minDetailPrice = (mySnapshot.referencePrice-minPrice)/2+minPrice;
    priceLabel1.text = [NSString stringWithFormat:@"%.2f",maxPrice];
    priceLabel2.text = [NSString stringWithFormat:@"%.2f",maxDetailPrice];
    priceLabel3.text = [NSString stringWithFormat:@"%.2f",mySnapshot.referencePrice];
    priceLabel4.text = [NSString stringWithFormat:@"%.2f",minDetailPrice];
    priceLabel5.text = [NSString stringWithFormat:@"%.2f",minPrice];
    
    
    double maxVolume = -MAXFLOAT;
    
    for(int i =0; i<[drawVolumeArray count] ; i++){
        maxVolume = MAX(maxVolume, [(NSNumber *)[drawVolumeArray objectAtIndex:i]doubleValue]);
    }
    double rangVolume = maxVolume / 4;
    
    volumeLabel1.text = [NSString stringWithFormat:@"%.0f",maxVolume-rangVolume*1];
    volumeLabel2.text = [NSString stringWithFormat:@"%.0f",maxVolume-rangVolume*2];
    volumeLabel3.text = [NSString stringWithFormat:@"%.0f",maxVolume-rangVolume*3];
    
}

-(void)setRightLabel
{
    UIColor *valueColor;
    if(mySnapshot.currentPrice - mySnapshot.referencePrice  > 0){
        valueColor = [UIColor redColor];
        topView.upDownValue.text = [NSString stringWithFormat:@"+%.2f",mySnapshot.currentPrice - mySnapshot.referencePrice];
        topView.upRatioValue.text = [NSString stringWithFormat:@"+%.2f%%",(mySnapshot.currentPrice - mySnapshot.referencePrice)/mySnapshot.currentPrice*100];
    }else{
        valueColor = [UIColor colorWithRed:35.0/255.0 green:132.0/255.0 blue:8.0/255.0 alpha:1];
        topView.upDownValue.text = [NSString stringWithFormat:@"%-.2f",mySnapshot.currentPrice - mySnapshot.referencePrice];
        topView.upRatioValue.text = [NSString stringWithFormat:@"%-.2f%%",(mySnapshot.currentPrice - mySnapshot.referencePrice)/mySnapshot.currentPrice*100];
    }
    topView.upDownValue.textColor = valueColor;
    topView.upRatioValue.textColor = valueColor;
    
    topView.buyValue.text = [NSString stringWithFormat:@"%.2f",mySnapshot.bid];
    topView.sellValue.text = [NSString stringWithFormat:@"%.2f",mySnapshot.ask];
    topView.tradeValue.text = [NSString stringWithFormat:@"%.2f",mySnapshot.currentPrice];
    topView.highValue.text = [NSString stringWithFormat:@"%.2f",mySnapshot.highestPrice];
    topView.lowValue.text = [NSString stringWithFormat:@"%.2f",mySnapshot.lowestPrice];
    
    topView.buyValue.textColor = valueColor;
    topView.sellValue.textColor = valueColor;
    topView.tradeValue.textColor = valueColor;
    topView.highValue.textColor = valueColor;
    topView.lowValue.textColor = valueColor;

    topView.volumeValue.text = [NSString stringWithFormat:@"%.0f",mySnapshot.volume];
}

-(void)setComparedLeftLabel
{
    bottomView.symbolName.text = watchPortfolio.comparedPortfolioItem->fullName;
    
    double high = comparedSnapshot.highestPrice - comparedSnapshot.referencePrice;
    double low =  comparedSnapshot.referencePrice - comparedSnapshot.lowestPrice;
    double range = MAX(high,low);
    high = comparedSnapshot.referencePrice + range;
    low = comparedSnapshot.referencePrice - range;
    double maxDetailPrice = (high - comparedSnapshot.referencePrice)/2 + comparedSnapshot.referencePrice;
    double minDetailPrice = (comparedSnapshot.referencePrice - low)/2 + low;
    comparedPriceLabel1.text = [NSString stringWithFormat:@"%.2f",high];
    comparedPriceLabel2.text = [NSString stringWithFormat:@"%.2f",maxDetailPrice];
    comparedPriceLabel3.text = [NSString stringWithFormat:@"%.2f",comparedSnapshot.referencePrice];
    comparedPriceLabel4.text = [NSString stringWithFormat:@"%.2f",minDetailPrice];
    comparedPriceLabel5.text = [NSString stringWithFormat:@"%.2f",low];
    
    
    double maxVolume = -MAXFLOAT;
    
    for(int i =0; i<[comparedDrawVolumeArray count] ; i++){
        maxVolume = MAX(maxVolume, [(NSNumber *)[comparedDrawVolumeArray objectAtIndex:i]doubleValue]);
    }
    double rangVolume = maxVolume / 4;
    
    comparedVolumeLabel1.text = [NSString stringWithFormat:@"%.0f",maxVolume-rangVolume*1];
    comparedVolumeLabel2.text = [NSString stringWithFormat:@"%.0f",maxVolume-rangVolume*2];
    comparedVolumeLabel3.text = [NSString stringWithFormat:@"%.0f",maxVolume-rangVolume*3];
    
    
}

-(void)setComparedRightLabel
{
    UIColor *valueColor;
    if(comparedSnapshot.currentPrice - comparedSnapshot.referencePrice  > 0){
        valueColor = [UIColor redColor];
        bottomView.upDownValue.text = [NSString stringWithFormat:@"+%.2f",comparedSnapshot.currentPrice - comparedSnapshot.referencePrice];
        bottomView.upRatioValue.text = [NSString stringWithFormat:@"+%.2f%%",(comparedSnapshot.currentPrice - comparedSnapshot.referencePrice)/comparedSnapshot.referencePrice*100];
    }else{
        valueColor = [UIColor colorWithRed:35.0/255.0 green:132.0/255.0 blue:8.0/255.0 alpha:1];
        bottomView.upDownValue.text = [NSString stringWithFormat:@"%-.2f",comparedSnapshot.currentPrice - comparedSnapshot.referencePrice];
        bottomView.upRatioValue.text = [NSString stringWithFormat:@"%-.2f%%",(comparedSnapshot.currentPrice - comparedSnapshot.referencePrice)/comparedSnapshot.referencePrice*100];
    }
    bottomView.upDownValue.textColor = valueColor;
    bottomView.upRatioValue.textColor = valueColor;
    
    
    bottomView.buyValue.text = [NSString stringWithFormat:@"%.2f",comparedSnapshot.bid];
    bottomView.sellValue.text = [NSString stringWithFormat:@"%.2f",comparedSnapshot.ask];
    bottomView.tradeValue.text = [NSString stringWithFormat:@"%.2f",comparedSnapshot.currentPrice];
    bottomView.highValue.text = [NSString stringWithFormat:@"%.2f",comparedSnapshot.highestPrice];
    bottomView.lowValue.text = [NSString stringWithFormat:@"%.2f",comparedSnapshot.lowestPrice];
    
    bottomView.buyValue.textColor = valueColor;
    bottomView.sellValue.textColor = valueColor;
    bottomView.tradeValue.textColor = valueColor;
    bottomView.highValue.textColor = valueColor;
    bottomView.lowValue.textColor = valueColor;
    
    bottomView.volumeValue.text = [NSString stringWithFormat:@"%.0f",comparedSnapshot.volume];
}

-(void)LabelLayout
{
    float upperLabelCenter = topView.leftTopView.frame.size.height / 4.0f;
    [topView.symbolName setFrame:CGRectMake(0,0,topView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    topView.symbolName.font = [UIFont boldSystemFontOfSize:15.0f];
    topView.symbolName.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:194.0/255.0 blue:128.0/255.0 alpha:1];
    [priceLabel1 setFrame:CGRectMake(0, 0, topView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [priceLabel2 setFrame:CGRectMake(0, upperLabelCenter*1-upperLabelCenter/4, topView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [priceLabel3 setFrame:CGRectMake(0, upperLabelCenter*2-upperLabelCenter/4, topView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [priceLabel4 setFrame:CGRectMake(0, upperLabelCenter*3-upperLabelCenter/4, topView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [priceLabel5 setFrame:CGRectMake(0, topView.leftTopView.frame.size.height-upperLabelCenter/2, topView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    
    float bottomLabelCenter = topView.leftBottomView.frame.size.height / 4.0f;
    [volumeLabel1 setFrame:CGRectMake(0, bottomLabelCenter*1-bottomLabelCenter/4, topView.leftBottomView.frame.size.width, bottomLabelCenter/2+3)];
    [volumeLabel2 setFrame:CGRectMake(0, bottomLabelCenter*2-bottomLabelCenter/4, topView.leftBottomView.frame.size.width, bottomLabelCenter/2+3)];
    [volumeLabel3 setFrame:CGRectMake(0, bottomLabelCenter*3-bottomLabelCenter/4, topView.leftBottomView.frame.size.width, bottomLabelCenter/2+3)];
}

-(void)setComparedLabelLayout
{
    float upperLabelCenter = bottomView.leftTopView.frame.size.height / 4.0f;
    [bottomView.symbolName setFrame:CGRectMake(0,0,bottomView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    bottomView.symbolName.font = [UIFont boldSystemFontOfSize:15.0f];
    bottomView.symbolName.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:194.0/255.0 blue:128.0/255.0 alpha:1];
    [comparedPriceLabel1 setFrame:CGRectMake(0, 0, bottomView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [comparedPriceLabel2 setFrame:CGRectMake(0, upperLabelCenter*1-upperLabelCenter/4, bottomView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [comparedPriceLabel3 setFrame:CGRectMake(0, upperLabelCenter*2-upperLabelCenter/4, bottomView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [comparedPriceLabel4 setFrame:CGRectMake(0, upperLabelCenter*3-upperLabelCenter/4, bottomView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    [comparedPriceLabel5 setFrame:CGRectMake(0, bottomView.leftTopView.frame.size.height-upperLabelCenter/2, bottomView.leftTopView.frame.size.width, upperLabelCenter/2+3)];
    
    float bottomLabelCenter = bottomView.leftBottomView.frame.size.height / 4.0f;
    [comparedVolumeLabel1 setFrame:CGRectMake(0, bottomLabelCenter*1-bottomLabelCenter/4, bottomView.leftBottomView.frame.size.width, bottomLabelCenter/2+3)];
    [comparedVolumeLabel2 setFrame:CGRectMake(0, bottomLabelCenter*2-bottomLabelCenter/4, bottomView.leftBottomView.frame.size.width, bottomLabelCenter/2+3)];
    [comparedVolumeLabel3 setFrame:CGRectMake(0, bottomLabelCenter*3-bottomLabelCenter/4, bottomView.leftBottomView.frame.size.width, bottomLabelCenter/2+3)];
}

- (void)doTouchesWithPoint:(CGPoint)point number:(int)num
{
    if(num >= 0 && num <[lastPriceArray count]){
        if([(NSNumber *)[lastVolumeArray objectAtIndex:num]doubleValue]==0.00){
            vertical.hidden = YES;
            infoView.hidden = YES;
        }else{
            vertical.hidden = NO;
            infoView.hidden = NO;
            int hour = (marketInfo->startTime_1 + [(NSNumber *)[tickTimeArray objectAtIndex:num]intValue])/60;
            int min = (marketInfo->startTime_1 + [(NSNumber *)[tickTimeArray objectAtIndex:num]intValue])%60;
            NSString *minText;
            if(min<10){
                minText = [NSString stringWithFormat:@"0%d",min];
            }else{
                minText = [NSString stringWithFormat:@"%d",min];
            }
            [vertical setFrame:CGRectMake(point.x, vertical.frame.origin.y, 1, topView.frame.size.height-20)];
            infoView.timeContentLabel.text = [NSString stringWithFormat:@"%d:%@", hour, minText];
            infoView.volContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[drawVolumeArray objectAtIndex:num]doubleValue]];
            infoView.bidContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[lastBidArray objectAtIndex:num]doubleValue]];
            infoView.askContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[lastAskArray objectAtIndex:num]doubleValue]];
            infoView.lastPriceContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[lastPriceArray objectAtIndex:num]doubleValue]];
            if([(NSNumber *)[changeArray objectAtIndex:num]doubleValue]>=0){
                [infoView.changeContentLabel setTextColor:[UIColor redColor]];
                infoView.changeContentLabel.text = [NSString stringWithFormat:@"%+.2f", [(NSNumber *)[changeArray objectAtIndex:num]doubleValue]];
            }else{
                [infoView.changeContentLabel setTextColor:[UIColor colorWithRed:35.0/255.0 green:132.0/255.0 blue:8.0/255.0 alpha:1]];
                infoView.changeContentLabel.text = [NSString stringWithFormat:@"%-.2f", [(NSNumber *)[changeArray objectAtIndex:num]doubleValue]];
            }
            
            
            if(point.x-50 > (topView.frame.size.width - 160)/2){
                [infoView setFrame:CGRectMake(50, topView.frame.size.height-90, 70 , 90)];
            }else{
                [infoView setFrame:CGRectMake(self.view.frame.size.width-180, topView.frame.size.height-90, 70 , 90)];
            }
        }
    }
    if(num >=0 && num <[comparedLastPriceArray count]){
        if([(NSNumber *)[comparedLastVolumeArray objectAtIndex:num]doubleValue]==0.00){
            comparedVertical.hidden = YES;
            bottomInfoView.hidden = YES;
        }else{
            comparedVertical.hidden = NO;
            bottomInfoView.hidden = NO;
        
            int hour = (comparedMarketInfo->startTime_1 + [(NSNumber *)[comparedTickTimeArray objectAtIndex:num]intValue])/60;
            int min = (comparedMarketInfo->startTime_1 + [(NSNumber *)[comparedTickTimeArray objectAtIndex:num]intValue])%60;
            NSString *minText;
            if(min<10){
                minText = [NSString stringWithFormat:@"0%d",min];
            }else{
                minText = [NSString stringWithFormat:@"%d",min];
            }
            
            [comparedVertical setFrame:CGRectMake(point.x, comparedVertical.frame.origin.y, 1, bottomView.frame.size.height-20)];
            
            bottomInfoView.timeContentLabel.text = [NSString stringWithFormat:@"%d:%@", hour, minText];
            bottomInfoView.volContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[comparedDrawVolumeArray objectAtIndex:num]doubleValue]];
            bottomInfoView.bidContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[comparedLastBidArray objectAtIndex:num]doubleValue]];
            bottomInfoView.askContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[comparedLastAskArray objectAtIndex:num]doubleValue]];
            bottomInfoView.lastPriceContentLabel.text = [NSString stringWithFormat:@"%.2f", [(NSNumber *)[comparedLastPriceArray objectAtIndex:num]doubleValue]];
            if([(NSNumber *)[comparedChangeArray objectAtIndex:num]doubleValue]>=0){
                [bottomInfoView.changeContentLabel setTextColor:[UIColor redColor]];
                bottomInfoView.changeContentLabel.text = [NSString stringWithFormat:@"%+.2f", [(NSNumber *)[comparedChangeArray objectAtIndex:num]doubleValue]];
            }else{
                [bottomInfoView.changeContentLabel setTextColor:[UIColor colorWithRed:35.0/255.0 green:132.0/255.0 blue:8.0/255.0 alpha:1]];
                bottomInfoView.changeContentLabel.text = [NSString stringWithFormat:@"%-.2f", [(NSNumber *)[comparedChangeArray objectAtIndex:num]doubleValue]];
            }
            
            
            if(point.x-50 > (bottomView.frame.size.width - 160)/2){
                [bottomInfoView setFrame:CGRectMake(50, bottomView.frame.size.height-90, 70 , 90)];
            }else{
                [bottomInfoView setFrame:CGRectMake(self.view.frame.size.width-180, bottomView.frame.size.height-90, 70 , 90)];
            }
        }
    }
}
@end

@implementation ChartObject
@end
