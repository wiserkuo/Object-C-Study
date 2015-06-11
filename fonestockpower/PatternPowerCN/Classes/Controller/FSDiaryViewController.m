//
//  FSDiaryViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/7/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSDiaryViewController.h"
#import "FSActionPlanDatabase.h"
#import "FSPositionInformationViewController.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSPositionViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "DrawAndScrollController.h"

@interface FSDiaryViewController (){
    UILabel *totalGainTitleLabel;
    UILabel *totalGainLabel;
    UILabel *tradingsTitleLabel;
    UILabel *tradingsLabel;
    UILabel *bestGainTitleLabel;
    UILabel *bestGainLabel;
    UILabel *winRateTitleLabel;
    UILabel *winRateLabel;
    FSInstantInfoWatchedPortfolio *watchedPortfolio;
}
@property (strong, nonatomic) FSUIButton *longButton;
@property (strong, nonatomic) FSUIButton *shortButton;
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UIScrollView *infoScrollView;
@property (strong, nonatomic) NSMutableArray *diaryArray;

@property (strong, nonatomic) FSActionPlanDatabase *actionPlanDB;
@property (strong, nonatomic) FSPositionModel *positionModel;
@property (strong, nonatomic) FSDiary *diary;
@property (nonatomic) BOOL status;//YES:Long NO:Short

@end

@implementation FSDiaryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _positionModel = [[FSDataModelProc sharedInstance] positionModel];
        _actionPlanDB = [FSActionPlanDatabase sharedInstances];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _actionPlanDB = [FSActionPlanDatabase sharedInstances];
    watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    [self setUpImageBackButton];
    [self setupNavigationBar];
    [self initOptionButton];
    [self initTableView];
    [self initInfoView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self initWithData];
    [self showInfoViewData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set up Data
-(void)initWithData{
    _diaryArray = [[NSMutableArray alloc] init];
    if (_longButton.selected == YES) {
        [_positionModel loadDiaryData:@"Sell"];
        _status = YES;
    }else{
        [_positionModel loadDiaryData:@"Cover"];
        _status = NO;
    }
    _diaryArray = _positionModel.diaryArray;
    [_tableView reloadAllData];
}

#pragma mark - Set up Navigation
-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Diary", @"Launcher", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];

    self.navigationItem.hidesBackButton = YES;
}

-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Set up Views
-(void)initOptionButton{
    _longButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _longButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_longButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _longButton.selected = YES;
    [_longButton setTitle:NSLocalizedStringFromTable(@"多方選股形勢", @"Trade", nil) forState:UIControlStateNormal];
    [_longButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_longButton];
    
    _shortButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _shortButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_shortButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shortButton setTitle:NSLocalizedStringFromTable(@"空方選股形勢", @"Trade", nil) forState:UIControlStateNormal];
    [_shortButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shortButton];
}

-(void)initTableView{
    self.tableView = [[FSDiaryTableView alloc] initWithfixedColumnWidth:90 mainColumnWidth:90 AndColumnHeight:30];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

-(void)initInfoView{
    _infoView = [[UIView alloc] init];
    _infoView.translatesAutoresizingMaskIntoConstraints = NO;
    _infoView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
    
    _infoScrollView = [[UIScrollView alloc] init];
    _infoScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _infoScrollView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
    _infoScrollView.bounces = NO;
    _infoScrollView.contentSize = CGSizeMake(_infoView.frame.size.width, _infoView.frame.size.height);
    [self.view addSubview:_infoView];
//    [self.view addSubview:_infoScrollView];
    
    totalGainTitleLabel = [[UILabel alloc] init];
    totalGainTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    totalGainTitleLabel.adjustsFontSizeToFitWidth = YES;
    totalGainTitleLabel.text = NSLocalizedStringFromTable(@"Total Gain", @"ActionPlan", nil);
    [_infoView addSubview:totalGainTitleLabel];
    
    totalGainLabel = [[UILabel alloc] init];
    totalGainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    totalGainLabel.adjustsFontSizeToFitWidth = YES;
    totalGainLabel.text = @"----";
    totalGainLabel.textColor = [StockConstant PriceUpColor];
    totalGainLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:totalGainLabel];
    
    tradingsTitleLabel = [[UILabel alloc] init];
    tradingsTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tradingsTitleLabel.adjustsFontSizeToFitWidth = YES;
    tradingsTitleLabel.text = NSLocalizedStringFromTable(@"Trades", @"ActionPlan", nil);
    [_infoView addSubview:tradingsTitleLabel];
    
    tradingsLabel = [[UILabel alloc] init];
    tradingsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    tradingsLabel.adjustsFontSizeToFitWidth = YES;
    tradingsLabel.text = @"----";
    tradingsLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:tradingsLabel];
    
    winRateTitleLabel = [[UILabel alloc] init];
    winRateTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    winRateTitleLabel.adjustsFontSizeToFitWidth = YES;
    winRateTitleLabel.text = NSLocalizedStringFromTable(@"Win Rate", @"ActionPlan", nil);
    [_infoView addSubview:winRateTitleLabel];
    
    winRateLabel = [[UILabel alloc] init];
    winRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    winRateLabel.adjustsFontSizeToFitWidth = YES;
    winRateLabel.textColor = [StockConstant PriceUpColor];
    winRateLabel.text = @"----";
    winRateLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:winRateLabel];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_longButton, _shortButton, _tableView,_infoView, _infoScrollView, totalGainTitleLabel, totalGainLabel, tradingsTitleLabel, tradingsLabel, winRateTitleLabel, winRateLabel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_longButton][_shortButton(_longButton)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_longButton(44)][_tableView]-47-|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_shortButton(44)]" options:0 metrics:nil views:viewController]];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoScrollView]|" options:0 metrics:nil views:viewController]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoScrollView(47)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoView(47)]|" options:0 metrics:nil views:viewController]];
    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[totalGainTitleLabel]-1-[totalGainLabel(totalGainTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[tradingsTitleLabel(winRateTitleLabel)]-1-[tradingsLabel(winRateTitleLabel)]-[winRateTitleLabel]-1-[winRateLabel(winRateTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [_infoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[totalGainTitleLabel]-1-[tradingsTitleLabel]|" options:0 metrics:nil views:viewController]];
}

-(void)showInfoViewData{
    float totalGainNum = 0;
    float bestGain = 0;
    float winRate = 0;
    float totalGainBuyCost = 0;
    for (FSDiary *diary in _diaryArray) {
        totalGainNum += diary.gainDollar;
        totalGainBuyCost += diary.proceeds - diary.gainDollar;
        if (diary.gainPercent > bestGain) {
            bestGain = diary.gainPercent;
        }
        if (diary.gainPercent > 0) {
            winRate ++;
        }
    }
    if (totalGainBuyCost > 0) {
        totalGainLabel.text = [NSString stringWithFormat:@"$%@(%.2f%%)", [CodingUtil CoverFloatWithComma:totalGainNum DecimalPoint:0], totalGainNum/totalGainBuyCost * 100];
    }else{
        totalGainLabel.text = [NSString stringWithFormat:@"$%@(0.00%%)", [CodingUtil CoverFloatWithComma:totalGainNum DecimalPoint:0]];
    }
    
    NSUInteger tradeNum = [_diaryArray count];
    if (tradeNum >1) {
        tradingsLabel.text = [NSString stringWithFormat:@"%d %@", (int)[_diaryArray count], NSLocalizedStringFromTable(@"次數s", @"ActionPlan", nil)];
    }else{
        tradingsLabel.text = [NSString stringWithFormat:@"%d %@", (int)[_diaryArray count], NSLocalizedStringFromTable(@"次數", @"ActionPlan", nil)];
    }
    if ([_diaryArray count] > 0) {
        winRateLabel.text = [NSString stringWithFormat:@"%.f%%", (winRate/[_diaryArray count]) * 100];
    }else{
        winRateLabel.text = @"0.00%";
    }
}

#pragma mark - Button click action
-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:_longButton]) {
        _shortButton.selected = NO;
        _longButton.selected = YES;
        [_positionModel loadDiaryData:@"Sell"];
        _diaryArray = _positionModel.diaryArray;
        _status = YES;
    }else{
        _shortButton.selected = YES;
        _longButton.selected = NO;
        [_positionModel loadDiaryData:@"Cover"];
        _diaryArray = _positionModel.diaryArray;
        _status = NO;
    }
    [self showInfoViewData];
    [_tableView reloadAllData];
}

#pragma mark - Set Up Table View Cell
-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (columnIndex == 0) {
        label.frame = CGRectMake(2, 2, label.frame.size.width/3, 38);
        label.backgroundColor = [UIColor redColor];
        label.layer.borderColor = [UIColor blackColor].CGColor;
        label.layer.borderWidth = 2.0;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.text = @"H";
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *iTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iTap:)];
        label.tag = indexPath.row;
        [label addGestureRecognizer:iTap];
    }
    if (columnIndex == 1) {
        label.frame = CGRectMake(30, 2, label.frame.size.width/3, 38);
        label.backgroundColor = [UIColor redColor];
        label.layer.borderColor = [UIColor blackColor].CGColor;
        label.layer.borderWidth = 2.0;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.text = @"N";
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *kTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kTap:)];
        label.tag = indexPath.row;
        [label addGestureRecognizer:kTap];
    }
    if (columnIndex == 2) {
        label.frame = CGRectMake(58, 2, label.frame.size.width/3, 38);
        label.backgroundColor = [UIColor redColor];
        label.layer.borderColor = [UIColor blackColor].CGColor;
        label.layer.borderWidth = 2.0;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:20];
        label.text = @"G";
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *gTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gTap:)];
        label.tag = indexPath.row;
        [label addGestureRecognizer:gTap];
    }
    if (columnIndex == 3) {
        _diary = [_diaryArray objectAtIndex:indexPath.row];
        NSString *string = _diary.identCodeSymbol;
        NSString *identCode = [string substringToIndex:2];
        NSString *symbol = [string substringFromIndex:3];
        NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
        label.frame = CGRectMake(label.frame.origin.x / 3, 8, label.frame.size.width, 28);
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            label.text = symbol;
        }else {
            label.text = fullName;
        }
    }
}

-(void)iTap:(UITapGestureRecognizer *)sender{
    UILabel *label = (UILabel *)sender.view;
    _diary = [_diaryArray objectAtIndex:label.tag];
    FSPositionInformationViewController *info = [[FSPositionInformationViewController alloc] init];
    if (_longButton.selected == YES) {
        info.termStr = @"Long";
        info.symbolStr = _diary.identCodeSymbol;
    }else{
        info.termStr = @"Short";
        info.symbolStr = _diary.identCodeSymbol;
    }
    [self.navigationController pushViewController:info animated:NO];
}

-(void)kTap:(UITapGestureRecognizer *)sender{
    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePortRelateKLine showAlertViewToShopping:YES]) {
        
        FSDiary * diary =[_diaryArray objectAtIndex:sender.view.tag];
        
        NSString *idSymbol =diary.identCodeSymbol;
        
//        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (_longButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:diary.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:diary.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"Buy"] || [[dict objectForKey:@"Deal"] isEqualToString:@"Cover"]) {
                data->arrowType = 1;
            }else{
                data->arrowType = 2;
            }
            data->type = [dict objectForKey:@"Deal"];
            data->date = [dict objectForKey:@"Date"];
            data->note = [dict objectForKey:@"Note"];
            data->reason = [dict objectForKey:@"Reason"];
            
            NSDate * date  = [dateFormatter dateFromString:data->date];
            
            NSMutableDictionary * sameDateDic = [dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
            if (sameDateDic) {
                [sameDateDic setObject:data forKey:[dict objectForKey:@"Deal"]];
            }else{
                sameDateDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:data,[dict objectForKey:@"Deal"], nil];
            }
            
            [dataDictionary setObject:sameDateDic forKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
        }
//        mainViewController.arrowUpDownType = 4;
//        mainViewController.firstLevelMenuOption =1;
//        mainViewController.techOption = AnalysisPeriodDay;
//        mainViewController.arrowType =AnalysisPeriodDay;
//        mainViewController.dateDictionary=dataDictionary;
//        [self.navigationController pushViewController:mainViewController animated:NO];
        
        DrawAndScrollController *viewController = [[DrawAndScrollController alloc] init];
        viewController.analysisPeriod = AnalysisPeriodDay;
        viewController.dateDictionary = dataDictionary;
        viewController.arrowType = AnalysisPeriodDay;
        viewController.arrowUpDownType = 4;
        [self.navigationController pushViewController:viewController animated:NO];
    }
}

-(void)gTap:(UITapGestureRecognizer *)sender{
    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePortRelateKLine showAlertViewToShopping:YES]) {
        
        FSDiary * diary =[_diaryArray objectAtIndex:sender.view.tag];
        
        NSString *idSymbol =diary.identCodeSymbol;
        
//        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (_longButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:diary.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:diary.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"Buy"] || [[dict objectForKey:@"Deal"] isEqualToString:@"Cover"]) {
                data->arrowType = 1;
            }else{
                data->arrowType = 2;
            }
            data->type = [dict objectForKey:@"Deal"];
            data->date = [dict objectForKey:@"Date"];
            data->note = [dict objectForKey:@"Note"];
            data->reason = [dict objectForKey:@"Reason"];
            
            NSDate * date  = [dateFormatter dateFromString:data->date];
            
            NSMutableDictionary * sameDateDic = [dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
            if (sameDateDic) {
                [sameDateDic setObject:data forKey:[dict objectForKey:@"Deal"]];
            }else{
                sameDateDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:data,[dict objectForKey:@"Deal"], nil];
            }
            
            [dataDictionary setObject:sameDateDic forKey:[NSNumber numberWithUnsignedInt:[date uint16Value]]];
            
        }
        
        
        NSMutableDictionary * gainDataDictionary = [[NSMutableDictionary alloc]init];
        
        NSMutableArray *gainDataArray = [[NSMutableArray alloc] init];
        if (_longButton.selected == YES) {
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Long" DealBuy:@"Buy" DealSell:@"Sell"];
        }else{
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Short" DealBuy:@"Short" DealSell:@"Cover"];
        }

        for (int i = 0; i < [gainDataArray count]; i++) {
            float totalBuy = 0;
            float totalSell = 0;
            float count = 0;
            
            totalBuy = [(NSNumber *)[[gainDataArray objectAtIndex:i] objectForKey:@"TotalBuy"] floatValue];
            totalSell = fabsf([(NSNumber *)[[gainDataArray objectAtIndex:i] objectForKey:@"TotalSell"] floatValue]);
            count = fabsf([(NSNumber *)[[gainDataArray objectAtIndex:i] objectForKey:@"Count"] floatValue]);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            NSDate * date  = [dateFormatter dateFromString:[[gainDataArray objectAtIndex:i] objectForKey:@"Date"]];
            UInt16 dateInt = [CodingUtil makeDateFromDate:date];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithFloat:totalBuy] forKey:@"totalBuy"];
            [dict setObject:[NSNumber numberWithFloat:totalSell] forKey:@"totalSell"];
            [dict setObject:[NSNumber numberWithFloat:count] forKey:@"count"];
            [gainDataDictionary setObject:dict forKey:[NSNumber numberWithUnsignedInt:dateInt]];
        }
        
        NSDate *beginDate = [dateFormatter dateFromString:[[gainDataArray objectAtIndex:0] objectForKey:@"Date"]];
        UInt16 beginDateInt = [CodingUtil makeDateFromDate:beginDate];
        UInt16 today = [CodingUtil makeDateFromDate:[NSDate date]];
        UInt16 date = beginDateInt;
        NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
        
        for (int i = beginDateInt; i < today; i++) {
            NSMutableDictionary * dic = [gainDataDictionary objectForKey:[NSNumber numberWithInt:i]];
            if (dic != nil) {
                date = i;
                
            }else{
                dic = [gainDataDictionary objectForKey:[NSNumber numberWithInt:date]];
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[dic objectForKey:@"totalBuy"] forKey:@"totalBuy"];
            [dict setObject:[dic objectForKey:@"totalSell"] forKey:@"totalSell"];
            [dict setObject:[dic objectForKey:@"count"] forKey:@"count"];
            [dataDict setObject:dict forKey:[NSNumber numberWithUnsignedInt:i]];
        }
        
//        mainViewController.arrowUpDownType = 5;
//        mainViewController.firstLevelMenuOption =1;
//        mainViewController.techOption = AnalysisPeriodDay;
//        mainViewController.arrowType =AnalysisPeriodDay;
//        dataModal.indicator.bottomView1Indicator = 14;
//        mainViewController.dateDictionary = dataDictionary;
//        mainViewController.gainDateDictionary = dataDict;
//        [self.navigationController pushViewController:mainViewController animated:NO];
        
        
        DrawAndScrollController *viewController = [[DrawAndScrollController alloc] init];
        viewController.analysisPeriod = AnalysisPeriodDay;
        viewController.dateDictionary = dataDictionary;
        viewController.gainDateDictionary = dataDict;
        viewController.arrowType = AnalysisPeriodDay;
        viewController.arrowUpDownType = 5;
        viewController.status = _status;
        dataModal.indicator.bottomView1Indicator = 14;
        [self.navigationController pushViewController:viewController animated:NO];
    }
}


-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.textAlignment = NSTextAlignmentRight;
    _diary = [_diaryArray objectAtIndex:indexPath.row];
    if (columnIndex == 0) {
        label.text = [NSString stringWithFormat:@"%.f", _diary.qty];
    }
    if (columnIndex == 1) {
        label.text = [CodingUtil CoverFloatWithComma:_diary.avgPrice DecimalPoint:2];
    }
    if (columnIndex == 2) {
        label.text = [CodingUtil CoverFloatWithComma:_diary.proceeds DecimalPoint:0];
    }
    if (columnIndex == 3) {
        label.textColor = [StockConstant PriceUpColor];
        label.text = [NSString stringWithFormat:@"%@(%.2f%%)", [CodingUtil CoverFloatWithComma:_diary.gainDollar DecimalPoint:0], _diary.gainPercent * 100];
//        label.text = [CodingUtil CoverFloatWithComma:_diary.gainDollar DecimalPoint:0];
    }
//    if (columnIndex == 4) {
//        label.textColor = [StockConstant PriceUpColor];
//        label.text = [NSString stringWithFormat:@"%.2f%%", _diary.gainPercent * 100];
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_diaryArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Table View Columns Name
-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"Function", @"ActionPlan", nil), NSLocalizedStringFromTable(@"名稱", @"ActionPlan", nil)];
}

-(NSArray *)columnsInMainTableView{
    return @[NSLocalizedStringFromTable(@"QTY", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Average$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Proceeds$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Gain$", @"ActionPlan", nil)];
}

@end
