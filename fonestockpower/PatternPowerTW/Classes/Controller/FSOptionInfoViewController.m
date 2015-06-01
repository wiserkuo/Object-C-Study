//
//  FSOptionInfoViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/10/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionInfoViewController.h"
#import "FSOptionInfoCell.h"

@interface FSOptionInfoViewController ()<UITableViewDataSource, UITableViewDelegate>{
    UILabel *titleLabel;
    UILabel *strikePriceLabel;
    UILabel *openPriceLabel;
    UILabel *highPriceLabel;
    UILabel *lowPriceLabel;
    UILabel *currentPriceLabel;
    UILabel *settlementPriceLabel;
    UILabel *volumePriceLabel;
    UILabel *openInterestLabel;
    UILabel *strikePriceTitleLabel;
    UILabel *openPriceTitleLabel;
    UILabel *highPriceTitleLabel;
    UILabel *lowPriceTitleLabel;
    UILabel *currentPriceTitleLabel;
    UILabel *settlementPriceTitleLabel;
    UILabel *volumePriceTitleLabel;
    UILabel *openInterestTitleLabel;
    UITableView *mainTableView;
    FSDataModelProc *dataModel;
    
    double strikePrice;
    double refPrice;
    NSString *callPutStr;
    BOOL callPut;
    BOOL loadFlag;
}

@end

@implementation FSOptionInfoViewController

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
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 280, 305);
    dataModel = [FSDataModelProc sharedInstance];
    [self initView];
    loadFlag = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init View
-(void)initView{
    titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    strikePriceTitleLabel = [[UILabel alloc] init];
    strikePriceTitleLabel.text = NSLocalizedStringFromTable(@"履約價:",@"",@"");
    strikePriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    strikePriceTitleLabel.textColor = [UIColor whiteColor];
    strikePriceTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:strikePriceTitleLabel];
    
    strikePriceLabel = [[UILabel alloc] init];
    strikePriceLabel.text = @"---";
    strikePriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    strikePriceLabel.textColor = [UIColor yellowColor];
    strikePriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:strikePriceLabel];
    
    openPriceTitleLabel = [[UILabel alloc] init];
	openPriceTitleLabel.text = NSLocalizedStringFromTable(@"參考價:",@"",@"");
    openPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    openPriceTitleLabel.textColor = [UIColor whiteColor];
    openPriceTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:openPriceTitleLabel];
    
    openPriceLabel = [[UILabel alloc] init];
	openPriceLabel.text = @"---";
    openPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    openPriceLabel.textColor = [UIColor blueColor];
    openPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:openPriceLabel];
    
    highPriceTitleLabel = [[UILabel alloc] init];
	highPriceTitleLabel.text = NSLocalizedStringFromTable(@"最高價:",@"",@"");
    highPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    highPriceTitleLabel.textColor = [UIColor whiteColor];
    highPriceTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:highPriceTitleLabel];
    
    highPriceLabel = [[UILabel alloc] init];
	highPriceLabel.text = @"---";
    highPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    highPriceLabel.textColor = [UIColor blueColor];
    highPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:highPriceLabel];

    lowPriceTitleLabel = [[UILabel alloc] init];
	lowPriceTitleLabel.text = NSLocalizedStringFromTable(@"最低價:",@"",@"");
    lowPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    lowPriceTitleLabel.textColor = [UIColor whiteColor];
    lowPriceTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:lowPriceTitleLabel];
    
    lowPriceLabel = [[UILabel alloc] init];
	lowPriceLabel.text = @"---";
    lowPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    lowPriceLabel.textColor = [UIColor blueColor];
    lowPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lowPriceLabel];

	currentPriceTitleLabel = [[UILabel alloc] init];
    currentPriceTitleLabel.text = NSLocalizedStringFromTable(@"現價:",@"",@"");
    currentPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    currentPriceTitleLabel.textColor = [UIColor whiteColor];
    currentPriceTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:currentPriceTitleLabel];
    
    currentPriceLabel = [[UILabel alloc] init];
    currentPriceLabel.text = @"---";
    currentPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    currentPriceLabel.textColor = [UIColor blueColor];
    currentPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:currentPriceLabel];

	settlementPriceTitleLabel = [[UILabel alloc] init];
    settlementPriceTitleLabel.text = NSLocalizedStringFromTable(@"結算價:",@"",@"");
    settlementPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    settlementPriceTitleLabel.textColor = [UIColor whiteColor];
    settlementPriceTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:settlementPriceTitleLabel];
    
    settlementPriceLabel = [[UILabel alloc] init];
    settlementPriceLabel.text = @"---";
    settlementPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    settlementPriceLabel.textColor = [UIColor blueColor];
    settlementPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:settlementPriceLabel];

	volumePriceTitleLabel = [[UILabel alloc] init];
    volumePriceTitleLabel.text = NSLocalizedStringFromTable(@"總量:",@"",@"");
    volumePriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    volumePriceTitleLabel.textColor = [UIColor whiteColor];
    volumePriceTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:volumePriceTitleLabel];
    
    volumePriceLabel = [[UILabel alloc] init];
    volumePriceLabel.text = @"---";
    volumePriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    volumePriceLabel.textColor = [UIColor blueColor];
    volumePriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:volumePriceLabel];

    openInterestTitleLabel = [[UILabel alloc] init];
    openInterestTitleLabel.text = NSLocalizedStringFromTable(@"昨倉:",@"",@"");
    openInterestTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    openInterestTitleLabel.textColor = [UIColor whiteColor];
    openInterestTitleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:openInterestTitleLabel];
    
    openInterestLabel = [[UILabel alloc] init];
    openInterestLabel.text = @"---";
    openInterestLabel.translatesAutoresizingMaskIntoConstraints = NO;
    openInterestLabel.textColor = [UIColor blueColor];
    openInterestLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:openInterestLabel];
    
    mainTableView = [[UITableView alloc] init];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.backgroundColor = [UIColor blackColor];
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mainTableView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(titleLabel, strikePriceTitleLabel, strikePriceLabel, openPriceTitleLabel, openPriceLabel, highPriceTitleLabel, highPriceLabel, lowPriceTitleLabel, lowPriceLabel, currentPriceTitleLabel, currentPriceLabel, settlementPriceTitleLabel, settlementPriceLabel, volumePriceTitleLabel, volumePriceLabel, openInterestTitleLabel, openInterestLabel, mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[strikePriceTitleLabel]-[strikePriceLabel(strikePriceTitleLabel)]-[openPriceTitleLabel(strikePriceTitleLabel)]-[openPriceLabel(strikePriceTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[highPriceTitleLabel]-[highPriceLabel(highPriceTitleLabel)]-[lowPriceTitleLabel(highPriceTitleLabel)]-[lowPriceLabel(highPriceTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[currentPriceTitleLabel]-[currentPriceLabel(currentPriceTitleLabel)]-[settlementPriceTitleLabel(currentPriceTitleLabel)]-[settlementPriceLabel(currentPriceTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[volumePriceTitleLabel]-[volumePriceLabel(volumePriceTitleLabel)]-[openInterestTitleLabel(volumePriceTitleLabel)]-[openInterestLabel(volumePriceTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel][strikePriceTitleLabel][highPriceTitleLabel][currentPriceTitleLabel][volumePriceTitleLabel][mainTableView]|" options:0 metrics:nil views:viewController]];
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *cellIdentifier = @"historicalEPSHeaderCell";
    
    FSOptionInfoCell *headerView = (FSOptionInfoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (headerView == nil) {
        headerView = [[FSOptionInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    headerView.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    
    headerView.header1.textColor = [UIColor whiteColor];
    headerView.header2.textColor = [UIColor whiteColor];
    
    headerView.header1.text = NSLocalizedStringFromTable(@"掛買", @"", nil);
    headerView.header2.text = NSLocalizedStringFromTable(@"掛賣", @"", nil);
    
    return headerView;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (loadFlag) {
        static NSString *CellIdentifier = @"Cell";
        FSOptionInfoCell *cell = (FSOptionInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if (cell == nil) {
            cell = [[FSOptionInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
        cell.contentView.backgroundColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.field1.textColor = cell.field2.textColor = cell.field3.textColor = cell.field4.textColor = [UIColor blueColor];
        cell.field1.text = cell.field2.text = cell.field3.text = cell.field4.text = @"---";
        
		return cell;
    
    }else{
        static NSString *CellIdentifier = @"cellIdentifier";
        FSOptionInfoCell *cell = (FSOptionInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[FSOptionInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.contentView.backgroundColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        OptionBAData *optionBA = [dataModel.option getAllocRowBAData:(int)indexPath.row];
        if(optionBA)
        {
            if(optionBA->bidPrice[0] > refPrice) cell.field2.textColor = [StockConstant PriceUpColor];
            else if(optionBA->bidPrice[0] < refPrice) cell.field2.textColor = [StockConstant PriceDownColor];
            if(optionBA->askPrice[0] > refPrice) cell.field3.textColor = [StockConstant PriceUpColor];
            else if(optionBA->askPrice[0] < refPrice) cell.field3.textColor = [StockConstant PriceDownColor];
            cell.field1.textColor = cell.field4.textColor = [UIColor blueColor];
            
            
            if(isnan(optionBA->bidPrice[0])||optionBA->bidPrice[0] == 0){
                cell.field2.text = @"---";
                cell.field2.textColor = [UIColor blueColor];
            }
            else{
                cell.field2.text = [[NSNumber numberWithFloat:optionBA->bidPrice[0]] stringValue];
            }
            if(isnan(optionBA->bidVolume[0])||optionBA->bidVolume[0] == 0){
                cell.field1.text = @"---";
                cell.field1.textColor = [UIColor blueColor];
            }
            else{
                cell.field1.text = [CodingUtil getValueUnitString:optionBA->bidVolume[0] Unit:optionBA->bidVolumeUnit[0]];
            }
            if(isnan(optionBA->askPrice[0])||optionBA->askPrice[0] == 0){
                cell.field3.text = @"---";
                cell.field3.textColor = [UIColor blueColor];
            }
            else{
                cell.field3.text = [[NSNumber numberWithFloat:optionBA->askPrice[0]] stringValue];
            }
            if(isnan(optionBA->askVolume[0])||optionBA->askVolume[0] == 0){
                cell.field4.text = @"---";
                cell.field4.textColor = [UIColor blueColor];
            }
            else{
                cell.field4.text = [CodingUtil getValueUnitString:optionBA->askVolume[0] Unit:optionBA->askVolumeUnit[0]];
            }
        }
        
        return cell;
    }
}

#pragma mark - set title
-(void)showLabelInfoWithStrikePrice:(double)SP callOrPut:(BOOL)cp{
    strikePriceLabel.text = [NSString stringWithFormat:@"%.f", SP];
    strikePrice = SP;
    callPut = cp;
    OptionParam *optionData;
    OptionCallPut *opCallPut = [dataModel.option getDataByStrikePrice:strikePrice];
    if (cp) {
        optionData = opCallPut->put;
        titleLabel.text = @"即時資訊(PUT)";
    }else{
        optionData = opCallPut->call;
        titleLabel.text = @"即時資訊(CALL)";
    }

    [dataModel.option setFocus:optionData->sn Target:self];
    [self NotifyTickData];
}

#pragma mark - notify data arrive
-(void)NotifyBAData{
    loadFlag = NO;
    [mainTableView reloadData];
}

- (void)NotifyTickData{
	OptionCallPut *opCallPut = [dataModel.option getDataByStrikePrice:strikePrice];
	OptionParam *optionData;

	if(callPut) optionData = opCallPut->put;
	else optionData = opCallPut->call;
    
    refPrice = optionData->referencePrice;

    //履約價
    if (isnan(strikePrice)) {
        strikePriceLabel.text = @"---";
    }else{
        strikePriceLabel.text = [NSString stringWithFormat:@"%.f", strikePrice];
    }
    //參考價
    if (isnan(optionData->referencePrice)) {
        openPriceLabel.text = @"---";
    }else{
        openPriceLabel.text = [[NSNumber numberWithFloat:optionData->referencePrice] stringValue];
    }
    //最高價
    if(optionData->highPrice > optionData->referencePrice){
        highPriceLabel.textColor = [StockConstant PriceUpColor];
    }else if(optionData->highPrice < optionData->referencePrice){
        highPriceLabel.textColor = [StockConstant PriceDownColor];
    }
    if (isnan(optionData->highPrice)) {
        highPriceLabel.text = @"---";
    }else{
        highPriceLabel.text = [[NSNumber numberWithFloat:optionData->highPrice] stringValue];
    }
    //最低價
    if(optionData->lowPrice > optionData->referencePrice) lowPriceLabel.textColor = [StockConstant PriceUpColor];
	else if(optionData->lowPrice < optionData->referencePrice) lowPriceLabel.textColor = [StockConstant PriceDownColor];
    if (isnan(optionData->lowPrice)) {
        lowPriceLabel.text = @"---";
    }else{
        lowPriceLabel.text = [[NSNumber numberWithFloat:optionData->lowPrice] stringValue];
    }
    //現價
    if(optionData->currentPrice > optionData->referencePrice) currentPriceLabel.textColor = [StockConstant PriceUpColor];
	else if(optionData->currentPrice < optionData->referencePrice) currentPriceLabel.textColor = [StockConstant PriceDownColor];
    if (isnan(optionData->currentPrice)) {
        currentPriceLabel.text = @"---";
    }else{
        currentPriceLabel.text = [[NSNumber numberWithFloat:optionData->currentPrice] stringValue];
    }
    //結算價
    if(optionData->settlement > optionData->referencePrice) settlementPriceLabel.textColor = [StockConstant PriceUpColor];
	else if(optionData->settlement < optionData->referencePrice) settlementPriceLabel.textColor = [StockConstant PriceDownColor];
    if (isnan(optionData->settlement)) {
        settlementPriceLabel.text = @"---";
    }else{
        settlementPriceLabel.text = [[NSNumber numberWithFloat:optionData->settlement] stringValue];
    }
    //總量
    if (isnan(optionData->volume)) {
        volumePriceLabel.text = @"---";
    }else{
        volumePriceLabel.text = [[NSNumber numberWithFloat:optionData->volume] stringValue];
    }
    //昨倉;未平倉
    double tmpVal = (double)[dataModel.option getPCIntest];
    if (isnan(tmpVal)) {
        openInterestTitleLabel.text = @"昨倉";
        openInterestLabel.text = [[NSNumber numberWithFloat:optionData->preInterest] stringValue];
    }else{
        openInterestTitleLabel.text = @"未平倉";
        openInterestLabel.text = [[NSNumber numberWithFloat:optionData->openInterest] stringValue];
    }
}

@end
