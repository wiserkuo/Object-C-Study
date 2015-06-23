//
//  FSPositionViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/7/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPositionViewController.h"
#import "UIView+NewComponent.h"
#import "MarqueeLabel.h"
#import "FSInvestedViewController.h"
#import "NetWorthViewController.h"
#import "FSActionPlanDatabase.h"
#import "FSPositionInformationViewController.h"
#import "FSPositionModel.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "UIViewController+CustomNavigationBar.h"
#import "DrawAndScrollController.h"

@implementation arrowData

@end

@interface FSPositionViewController (){
    UILabel *fundTitleLabel;
    UILabel *fundLabel;
    UILabel *netWorthTitleLabel;
    UILabel *netWorthLabel;
    UILabel *realizedTitleLabel;
    UILabel *realizedLabel;
    UILabel *unrealizedTitleLabel;
    UILabel *unrealizedLabel;
    UILabel *riskExposureTitleLabel;
    UILabel *riskExposureLabel;
    UILabel *positionTitleLabel;
    UILabel *positionLabel;
    UILabel *costTitleLabel;
    UILabel *costLabel;
    UILabel *cashTitleLabel;
    UILabel *cashLabel;
    MarqueeLabel * fundButtonLabel;
    FSInstantInfoWatchedPortfolio *watchedPortfolio;
}
@property (strong, nonatomic) FSUIButton *longButton;
@property (strong, nonatomic) FSUIButton *shortButton;
@property (strong, nonatomic) FSUIButton *fundButton;
@property (strong, nonatomic) FSUIButton *netWorthButton;
@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UIScrollView *infoScrollView;

@property (strong, nonatomic) NSString *current;
@property (strong, nonatomic) NSMutableArray *investedFunds;
@property (strong, nonatomic) NSMutableArray *positionArray;

@property (strong, nonatomic) FSActionPlanDatabase *actionPlanDB;
@property (strong, nonatomic) FSPositionModel *positionModel;
@property (strong, nonatomic) FSPositions *positions;
@property (nonatomic,strong) NSObject<HistoricTickDataSourceProtocol> *historicData;
@property (nonatomic) BOOL status;//YES:Long NO:Short
@end

@implementation FSPositionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _positionModel = [[FSDataModelProc sharedInstance] positionModel];
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
    _investedFunds = [[NSMutableArray alloc] init];
    if (_longButton.selected == YES) {
        _investedFunds = [_actionPlanDB searchInvestedByTerm:@"Long"];
        [_positionModel loadPositionData:@"Long"];
        _positionArray = _positionModel.positionArray;
        _status = YES;
    }else{
        _investedFunds = [_actionPlanDB searchInvestedByTerm:@"Short"];
        [_positionModel loadPositionData:@"Short"];
        _positionArray = _positionModel.positionArray;
        _status = NO;
    }
    [_tableView reloadAllData];
}

#pragma mark - Set up Navigation
-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Positions", @"Launcher", nil)];
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
    self.tableView = [[FSActionTableView alloc] initWithfixedColumnWidth:90 mainColumnWidth:90 AndColumnHeight:44];
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
    _infoScrollView.backgroundColor = [UIColor clearColor];
    _infoScrollView.bounces = NO;
    _infoScrollView.contentSize = CGSizeMake(_infoView.frame.size.width, _infoView.frame.size.height);
    [_infoScrollView addSubview:_infoView];
    [self.view addSubview:_infoScrollView];
    
    _fundButton =[_infoView newButton:FSUIButtonTypeNormalRed];
    [_fundButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_fundButton addTarget:self action:@selector(InventedFundsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    fundButtonLabel = [[MarqueeLabel alloc]init];
    fundButtonLabel.translatesAutoresizingMaskIntoConstraints = NO;
    fundButtonLabel.text = NSLocalizedStringFromTable(@"投入資金", @"ActionPlan", nil);
    [fundButtonLabel setLabelize:NO];
    fundButtonLabel.marqueeType = 4;
    fundButtonLabel.continuousMarqueeExtraBuffer = 30.0f;
    fundButtonLabel.backgroundColor = [UIColor clearColor];
    fundButtonLabel.textColor = [UIColor whiteColor];
    fundButtonLabel.font = [UIFont systemFontOfSize:16.0f];
    [_infoView addSubview:fundButtonLabel];
    
    _netWorthButton = [_infoView newButton:FSUIButtonTypeNormalRed];
    _netWorthButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [_netWorthButton setTitle:NSLocalizedStringFromTable(@"資產淨值", @"ActionPlan", nil) forState:UIControlStateNormal];
    [_netWorthButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_netWorthButton addTarget:self action:@selector(NetAssetsTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //投入資金
    fundTitleLabel = [[UILabel alloc]init];
    fundTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    fundTitleLabel.backgroundColor = [UIColor clearColor];
    fundTitleLabel.text = @"";
    [_infoView addSubview:fundTitleLabel];
    
    fundLabel = [[UILabel alloc] init];
    fundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    fundLabel.backgroundColor = [UIColor clearColor];
    fundLabel.adjustsFontSizeToFitWidth = YES;
    fundLabel.textColor = [StockConstant PriceUpColor];
    fundLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:fundLabel];
    
    //資產淨值
    netWorthTitleLabel = [[UILabel alloc]init];
    netWorthTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    netWorthTitleLabel.backgroundColor = [UIColor clearColor];
    netWorthTitleLabel.text = @"";
    [_infoView addSubview:netWorthTitleLabel];
    
    netWorthLabel = [[UILabel alloc]init];
    netWorthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    netWorthLabel.adjustsFontSizeToFitWidth = YES;
    netWorthLabel.backgroundColor = [UIColor clearColor];
    netWorthLabel.textColor = [StockConstant PriceUpColor];
    netWorthLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:netWorthLabel];
    
    //已實現損益
    realizedTitleLabel = [[UILabel alloc]init];
    realizedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    realizedTitleLabel.backgroundColor = [UIColor clearColor];
    realizedTitleLabel.adjustsFontSizeToFitWidth = YES;
    realizedTitleLabel.text = NSLocalizedStringFromTable(@"Realized Gains", @"ActionPlan", nil);
    [_infoView addSubview:realizedTitleLabel];
    
    realizedLabel = [[UILabel alloc]init];
    realizedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    realizedLabel.adjustsFontSizeToFitWidth = YES;
    realizedLabel.backgroundColor = [UIColor clearColor];
    realizedLabel.textColor = [StockConstant PriceUpColor];
    realizedLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:realizedLabel];
    
    //未實現損益
    unrealizedTitleLabel = [[UILabel alloc]init];
    unrealizedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    unrealizedTitleLabel.backgroundColor = [UIColor clearColor];
    unrealizedTitleLabel.adjustsFontSizeToFitWidth = YES;
    unrealizedTitleLabel.text = NSLocalizedStringFromTable(@"Unrealized Gains", @"ActionPlan", nil);
    [_infoView addSubview:unrealizedTitleLabel];
    
    unrealizedLabel = [[UILabel alloc] init];
    unrealizedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    unrealizedLabel.backgroundColor = [UIColor clearColor];
    unrealizedLabel.adjustsFontSizeToFitWidth = YES;
    unrealizedLabel.textColor = [StockConstant PriceUpColor];
    unrealizedLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:unrealizedLabel];
    
    //曝顯金額
    riskExposureTitleLabel = [[UILabel alloc]init];
    riskExposureTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    riskExposureTitleLabel.backgroundColor = [UIColor clearColor];
    riskExposureTitleLabel.adjustsFontSizeToFitWidth = YES;
    riskExposureTitleLabel.text = NSLocalizedStringFromTable(@"Risk", @"ActionPlan", nil);
    [_infoView addSubview:riskExposureTitleLabel];
    
    riskExposureLabel = [[UILabel alloc]init];
    riskExposureLabel.translatesAutoresizingMaskIntoConstraints = NO;
    riskExposureLabel.backgroundColor = [UIColor clearColor];
    riskExposureLabel.adjustsFontSizeToFitWidth = YES;
    riskExposureLabel.textColor = [StockConstant PriceDownColor];
    riskExposureLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:riskExposureLabel];
    
    //成本
    positionTitleLabel = [[UILabel alloc]init];
    positionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    positionTitleLabel.backgroundColor = [UIColor clearColor];
    positionTitleLabel.adjustsFontSizeToFitWidth = YES;
    positionTitleLabel.text = NSLocalizedStringFromTable(@"Positions", @"ActionPlan", nil);
    [_infoView addSubview:positionTitleLabel];
    
    positionLabel = [[UILabel alloc]init];
    positionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    positionLabel.backgroundColor = [UIColor clearColor];
    positionLabel.adjustsFontSizeToFitWidth = YES;
    positionLabel.textColor = [StockConstant PriceUpColor];
    positionLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:positionLabel];
    
    //庫存成本
    costTitleLabel = [[UILabel alloc] init];
    costTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    costTitleLabel.backgroundColor = [UIColor clearColor];
    costTitleLabel.adjustsFontSizeToFitWidth = YES;
    costTitleLabel.text = NSLocalizedStringFromTable(@"Cost", @"ActionPlan", nil);
    [_infoView addSubview:costTitleLabel];
    
    costLabel = [[UILabel alloc] init];
    costLabel.translatesAutoresizingMaskIntoConstraints = NO;
    costLabel.backgroundColor = [UIColor clearColor];
    costLabel.adjustsFontSizeToFitWidth = YES;
    costLabel.textColor = [StockConstant PriceUpColor];
    costLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:costLabel];
    
    //現金餘額
    cashTitleLabel = [[UILabel alloc] init];
    cashTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cashTitleLabel.backgroundColor = [UIColor clearColor];
    cashTitleLabel.adjustsFontSizeToFitWidth = YES;
    cashTitleLabel.text = NSLocalizedStringFromTable(@"Cash", @"ActionPlan", nil);
    [_infoView addSubview:cashTitleLabel];
    
    cashLabel = [[UILabel alloc] init];
    cashLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cashLabel.backgroundColor = [UIColor clearColor];
    cashLabel.adjustsFontSizeToFitWidth = YES;
    cashLabel.textColor = [StockConstant PriceUpColor];
    cashLabel.textAlignment = NSTextAlignmentRight;
    [_infoView addSubview:cashLabel];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_longButton, _shortButton, _tableView, _infoView, _infoScrollView, _fundButton, _netWorthButton, fundTitleLabel, netWorthTitleLabel, realizedTitleLabel, unrealizedTitleLabel, riskExposureTitleLabel, positionTitleLabel, fundLabel,netWorthLabel, realizedLabel, unrealizedLabel, riskExposureLabel, positionLabel, costTitleLabel, costLabel, cashTitleLabel, cashLabel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_longButton][_shortButton(_longButton)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_longButton(44)][_tableView]-47-|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_shortButton(44)]" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoScrollView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoScrollView(47)]|" options:0 metrics:nil views:viewController]];
    [_infoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoView(783)]|" options:0 metrics:nil views:viewController]];
    [_infoScrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_infoView(47)]" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_fundButton(20)]-2-[_netWorthButton(20)]-3-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_fundButton(100)]-2-[fundTitleLabel]-[fundLabel(90)]-[positionTitleLabel(70)]-1-[positionLabel(90)]-[realizedTitleLabel(130)]-1-[realizedLabel(80)]-[riskExposureTitleLabel(65)]-1-[riskExposureLabel(115)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_netWorthButton(100)]-2-[netWorthTitleLabel]-[netWorthLabel(90)]-[cashTitleLabel(70)]-1-[cashLabel(90)]-[unrealizedTitleLabel(130)]-1-[unrealizedLabel(80)]-[costTitleLabel(65)]-1-[costLabel(115)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_fundButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_fundButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_fundButton attribute:NSLayoutAttributeLeft multiplier:1 constant:1.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:fundButtonLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_fundButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
}

-(void)showInfoViewData{
    float lastFund = [(NSNumber *)[[_investedFunds valueForKey:@"Total_Amount"] valueForKey:@"@lastObject"] floatValue];
    fundLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:lastFund DecimalPoint:0]];
    netWorthLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:_positionModel.netWorth DecimalPoint:0]];
    realizedLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:_positionModel.realized DecimalPoint:0]];
    unrealizedLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:_positionModel.unrealized DecimalPoint:0]];
    float totalRiskRatio = 0;
    totalRiskRatio = _positionModel.totalRiskDollar / _positionModel.netWorth;
    riskExposureLabel.text = [NSString stringWithFormat:@"$%@(%.2f%%)", [CodingUtil CoverFloatWithComma:_positionModel.totalRiskDollar DecimalPoint:0], totalRiskRatio * 100];

    positionLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:_positionModel.position DecimalPoint:0]];
    costLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:_positionModel.totalCost DecimalPoint:0]];
    cashLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:lastFund+_positionModel.realized-_positionModel.totalCost DecimalPoint:0]];
}

#pragma mark - Button click action
-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:_longButton]) {
        _shortButton.selected = NO;
        _longButton.selected = YES;
        _investedFunds = [_actionPlanDB searchInvestedByTerm:@"Long"];
        [_positionModel loadPositionData:@"Long"];
        _status = YES;
    }else{
        _shortButton.selected = YES;
        _longButton.selected = NO;
        _investedFunds = [_actionPlanDB searchInvestedByTerm:@"Short"];
        [_positionModel loadPositionData:@"Short"];
        _status = NO;
    }
    _positionArray = _positionModel.positionArray;
    [self showInfoViewData];
    [_tableView reloadAllData];
}

- (void)InventedFundsTapped:(id)sender {
    FSInvestedViewController *term = [[FSInvestedViewController alloc] init];
    [self.navigationController pushViewController:term animated:NO];
    if (_longButton.selected == YES) {
        term.termStr = @"Long";
    }else{
        term.termStr = @"Short";
    }
}

- (void)NetAssetsTapped:(id)sender {
    NetWorthViewController * netWorthView =[[NetWorthViewController alloc] init];
    [self.navigationController pushViewController:netWorthView animated:NO];
    if (_longButton.selected == YES) {
        netWorthView.termStr = @"Long";
    }else{
        netWorthView.termStr = @"Short";
    }
    netWorthView.dealStr = @"BUY";
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
        _positions = [_positionArray objectAtIndex:indexPath.row];
        NSString *string = _positions.identCodeSymbol;
        NSString *identCode = [string substringToIndex:2];
        NSString *symbol = [string substringFromIndex:3];
        NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
        NSString *appid = [FSFonestock sharedInstance].appId;
        NSString *group = [appid substringWithRange:NSMakeRange(0, 2)];
        label.frame = CGRectMake(label.frame.origin.x / 3, 8, label.frame.size.width, 28);
        label.textColor = [UIColor blueColor];
        if ([group isEqualToString:@"us"]) {
            label.text = symbol;
        }else {
            label.text = fullName;
        }
    }
}

-(void)iTap:(UITapGestureRecognizer *)sender{
    UILabel *label = (UILabel *)sender.view;
    _positions = [_positionArray objectAtIndex:label.tag];
    FSPositionInformationViewController *info = [[FSPositionInformationViewController alloc] init];
    if (_longButton.selected == YES) {
        info.termStr = @"Long";
        info.symbolStr = _positions.identCodeSymbol;
    }else{
        info.termStr = @"Short";
        info.symbolStr = _positions.identCodeSymbol;
    }
    [self.navigationController pushViewController:info animated:NO];
}


-(void)kTap:(UITapGestureRecognizer *)sender{
    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePortRelateKLine showAlertViewToShopping:YES]) {
        
        FSPositions * position =[_positionArray objectAtIndex:sender.view.tag];
        
        NSString *idSymbol =position.identCodeSymbol;
        
//        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;

        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (_longButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:position.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:position.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"BUY"]) {
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
        
        FSPositions * position =[_positionArray objectAtIndex:sender.view.tag];
        
        NSString *idSymbol =position.identCodeSymbol;
        
//        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        
        dataModal.indicator.bottomView1Indicator = 14;
        
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        NSMutableDictionary * dataDictionary = [[NSMutableDictionary alloc]init];
        
        if (_longButton.selected == YES) {
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:position.identCodeSymbol];
        }else{
            dataArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:position.identCodeSymbol];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        
        for (NSDictionary *dict in dataArray) {
            arrowData * data = [[arrowData alloc]init];
            if ([[dict objectForKey:@"Deal"] isEqualToString:@"BUY"] || [[dict objectForKey:@"Deal"] isEqualToString:@"COVER"]) {
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
        
        NSMutableArray *gainDataArray = [[NSMutableArray alloc] init];
        NSMutableDictionary * gainDataDictionary = [[NSMutableDictionary alloc]init];
        if (_longButton.selected == YES) {
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Long" DealBuy:@"BUY" DealSell:@"SELL"];
        }else{
            gainDataArray = [[FSActionPlanDatabase sharedInstances] searchGainDataWithSymbol:idSymbol Term:@"Short" DealBuy:@"SHORT" DealSell:@"COVER"];
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
//        mainViewController.dateDictionary = dataDictionary;
//        mainViewController.gainDateDictionary = dataDict;
//        mainViewController.status = _status;
//        [self.navigationController pushViewController:mainViewController animated:NO];
        
        DrawAndScrollController *viewController = [[DrawAndScrollController alloc] init];
        viewController.analysisPeriod = AnalysisPeriodDay;
        viewController.dateDictionary = dataDictionary;
        viewController.gainDateDictionary = dataDict;
        viewController.arrowType = AnalysisPeriodDay;
        viewController.arrowUpDownType = 5;
        viewController.status = _status;
        [self.navigationController pushViewController:viewController animated:NO];
        
    }
}


-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    _positions = [_positionArray objectAtIndex:indexPath.row];
    label.textAlignment = NSTextAlignmentRight;
    if (columnIndex == 0) {
        label.text = [NSString stringWithFormat:@"%.f", _positions.qty];
    }
    if (columnIndex == 1) {
        label.text = [NSString stringWithFormat:@"%.2f", _positions.avgCost];
    }
    if (columnIndex == 2) {
        label.text = [CodingUtil CoverFloatWithComma:_positions.total DecimalPoint:0];
    }
    if (columnIndex == 3) {
        label.textColor = [StockConstant PriceUpColor];
        label.text = [NSString stringWithFormat:@"%.2f", _positions.last];
    }
    if (columnIndex == 4) {
        label.textColor = [StockConstant PriceUpColor];
        label.text = [NSString stringWithFormat:@"%@(%.2f%%)", [CodingUtil CoverFloatWithComma:_positions.gainDollar DecimalPoint:0], _positions.gainPercent * 100];
    }
    if (columnIndex == 5) {
        label.textColor = [StockConstant PriceDownColor];
        label.text = [NSString stringWithFormat:@"%.2f", _positions.sl];
    }
    if (columnIndex == 6) {
        label.textColor = [StockConstant PriceDownColor];
        label.text = [NSString stringWithFormat:@"%@(%.2f%%)", [CodingUtil CoverFloatWithComma:_positions.riskDollar DecimalPoint:0], (_positions.riskDollar / _positionModel.netWorth) * 100];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_positionArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FSPositions * position =[_positionArray objectAtIndex:indexPath.row];
    
    NSString *idSymbol =position.identCodeSymbol;
    
    FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
    watchedPortfolio.portfolioItem = portfolioItem;
    mainViewController.firstLevelMenuOption =1;
    [self.navigationController pushViewController:mainViewController animated:NO];
}

#pragma mark - Table View Columns Name
-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"Function", @"ActionPlan", nil), NSLocalizedStringFromTable(@"名稱", @"ActionPlan", nil)];
}

-(NSArray *)columnsInMainTableView{
    return @[NSLocalizedStringFromTable(@"QTY", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Average$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Total$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Last$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Gain$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"S@L$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Risk$", @"ActionPlan", nil)];
}

@end
