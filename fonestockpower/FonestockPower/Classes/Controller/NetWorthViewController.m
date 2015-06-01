//
//  testViewController.m
//  FonestockPower
//
//  Created by Neil on 14/6/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "NetWorthViewController.h"
#import "FSUIButton.h"
#import "NetWorthUpperView.h"
#import "NetWorthBottonView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+HUD.h"


@implementation  NetWorthData


@end

@interface UIDevice()
-(void)setOrientation:(UIInterfaceOrientation)orientation;

@end

@interface NetWorthViewController (){
    UIView *verticalLine;
    UIView *horizontalLine;
    FSUIButton * threeMonthBtn;
    FSUIButton * sixMonthBtn;
    FSUIButton * ytdBtn;
    FSUIButton * oneYearBtn;
    FSUIButton * threeYearBtn;
    NetWorthUpperView * upperView;
    NetWorthBottonView * bottonView;
    UIView * upperRightView;
    UIView * bottonRightView;
    UIView * dataView;
    UILabel * bottonRightLabel1;
    UILabel * bottonRightLabel2;
    UILabel * bottonRightLabel3;
    
    UILabel * upperRightLabel1;
    UILabel * upperRightLabel2;
    UILabel * upperRightLabel3;
    UILabel * upperRightLabel4;
    UILabel * upperRightLabel5;
    UILabel * upperRightLabel6;
    
    UILabel * upperRightTitleLabel;
    UILabel * bottonRightTitleLabel;
    
    NSMutableArray * netWorthDataArray;
    double maxTotal;
    double minTotal;
    double maxDaily;
    
    UInt16 beginDayInt;
    BOOL firstTime;
}
@end

@implementation NetWorthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpImageBackButton];
    [self initView];
    [self setDefaultSetting];;
    
    [self.view setNeedsUpdateConstraints];

    [[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
}

-(void)setDefaultSetting{
    self.navigationItem.title = NSLocalizedStringFromTable(@"Net Worth", @"ActionPlan", nil);
    firstTime = YES;;
    netWorthDataArray = [[NSMutableArray alloc]init];
    threeMonthBtn.selected = YES;
    [upperView setRange:threeMonth];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[[FSDataModelProc sharedInstance] investedModel]setTargetNotify:nil];
    [upperView removeLabel];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[[FSDataModelProc sharedInstance] investedModel]setTargetNotify:self];
    [self.view showHUDWithTitle:@""];
}
-(void)initView{
    threeMonthBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    threeMonthBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [threeMonthBtn setTitle:NSLocalizedStringFromTable(@"3M", @"ActionPlan", nil) forState:UIControlStateNormal];
    threeMonthBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [threeMonthBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:threeMonthBtn];
    
    sixMonthBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    sixMonthBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [sixMonthBtn setTitle:NSLocalizedStringFromTable(@"6M", @"ActionPlan", nil) forState:UIControlStateNormal];
    sixMonthBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [sixMonthBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sixMonthBtn];
    
    ytdBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    ytdBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [ytdBtn setTitle:NSLocalizedStringFromTable(@"YTD", @"ActionPlan", nil) forState:UIControlStateNormal];
    ytdBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    ytdBtn.titleLabel.numberOfLines = 0;
    [ytdBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ytdBtn];
    
    oneYearBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    oneYearBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [oneYearBtn setTitle:NSLocalizedStringFromTable(@"1Y", @"ActionPlan", nil) forState:UIControlStateNormal];
    oneYearBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [oneYearBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:oneYearBtn];
    
    threeYearBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    threeYearBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [threeYearBtn setTitle:NSLocalizedStringFromTable(@"3Y", @"ActionPlan", nil) forState:UIControlStateNormal];
    threeMonthBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [threeYearBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:threeYearBtn];
    
    dataView = [[UIView alloc]init];
    dataView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dataView];
    
    upperView = [[NetWorthUpperView alloc]init];
    upperView.translatesAutoresizingMaskIntoConstraints = NO;
    upperView.backgroundColor = [UIColor whiteColor];
    upperView.layer.borderColor = [UIColor blackColor].CGColor;
    upperView.layer.borderWidth = 0.5;
    upperView.netWorthViewController = self;
    [dataView addSubview:upperView];
    
    bottonView = [[NetWorthBottonView alloc]init];
    bottonView.translatesAutoresizingMaskIntoConstraints = NO;
    bottonView.backgroundColor = [UIColor whiteColor];
    bottonView.layer.borderColor = [UIColor blackColor].CGColor;
    bottonView.layer.borderWidth = 0.5;
    [dataView addSubview:bottonView];
    
    upperRightView = [[UIView alloc]init];
    upperRightView.translatesAutoresizingMaskIntoConstraints = NO;
    upperRightView.backgroundColor = [UIColor whiteColor];
    [dataView addSubview:upperRightView];
    
    upperRightTitleLabel = [[UILabel alloc]init];
    upperRightTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    upperRightTitleLabel.text = NSLocalizedStringFromTable(@"Accumulate$", @"ActionPlan", nil);
    upperRightTitleLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    upperRightTitleLabel.textColor = [UIColor whiteColor];
    upperRightTitleLabel.adjustsFontSizeToFitWidth = YES;
    upperRightTitleLabel.textAlignment = NSTextAlignmentCenter;
    [upperRightView addSubview:upperRightTitleLabel];
    
    upperRightLabel1 = [[UILabel alloc]init];
    upperRightLabel1.backgroundColor = [UIColor clearColor];
    upperRightLabel1.textColor = [UIColor blueColor];
    upperRightLabel1.font = [UIFont systemFontOfSize:12.0f];
    upperRightLabel1.textAlignment = NSTextAlignmentLeft;
    [upperRightView addSubview:upperRightLabel1];
    
    upperRightLabel2 = [[UILabel alloc]init];
    upperRightLabel2.backgroundColor = [UIColor clearColor];
    upperRightLabel2.textColor = [UIColor blueColor];
    upperRightLabel2.font = [UIFont systemFontOfSize:12.0f];
    upperRightLabel2.textAlignment = NSTextAlignmentLeft;
    [upperRightView addSubview:upperRightLabel2];
    
    upperRightLabel3 = [[UILabel alloc]init];
    upperRightLabel3.backgroundColor = [UIColor clearColor];
    upperRightLabel3.textColor = [UIColor blueColor];
    upperRightLabel3.font = [UIFont systemFontOfSize:12.0f];
    upperRightLabel3.textAlignment = NSTextAlignmentLeft;
    [upperRightView addSubview:upperRightLabel3];
    
    upperRightLabel4 = [[UILabel alloc]init];
    upperRightLabel4.backgroundColor = [UIColor clearColor];
    upperRightLabel4.textColor = [UIColor blueColor];
    upperRightLabel4.font = [UIFont systemFontOfSize:12.0f];
    upperRightLabel4.textAlignment = NSTextAlignmentLeft;
    [upperRightView addSubview:upperRightLabel4];
    
    upperRightLabel5 = [[UILabel alloc]init];
    upperRightLabel5.backgroundColor = [UIColor clearColor];
    upperRightLabel5.textColor = [UIColor blueColor];
    upperRightLabel5.font = [UIFont systemFontOfSize:12.0f];
    upperRightLabel5.textAlignment = NSTextAlignmentLeft;
    [upperRightView addSubview:upperRightLabel5];
    
    upperRightLabel6 = [[UILabel alloc]init];
    upperRightLabel6.backgroundColor = [UIColor clearColor];
    upperRightLabel6.textColor = [UIColor blueColor];
    upperRightLabel6.font = [UIFont systemFontOfSize:12.0f];
    upperRightLabel6.textAlignment = NSTextAlignmentLeft;
    [upperRightView addSubview:upperRightLabel6];
    
    bottonRightView = [[UIView alloc]init];
    bottonRightView.translatesAutoresizingMaskIntoConstraints = NO;
    bottonRightView.backgroundColor = [UIColor whiteColor];
    [dataView addSubview:bottonRightView];
    
    bottonRightTitleLabel = [[UILabel alloc]init];
    bottonRightTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    bottonRightTitleLabel.text = NSLocalizedStringFromTable(@"Daily$", @"ActionPlan", nil);
    bottonRightTitleLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    bottonRightTitleLabel.textColor = [UIColor whiteColor];
    bottonRightTitleLabel.adjustsFontSizeToFitWidth = YES;
    bottonRightTitleLabel.textAlignment = NSTextAlignmentCenter;
    [bottonRightView addSubview:bottonRightTitleLabel];
    
    bottonRightLabel1 = [[UILabel alloc]init];
    bottonRightLabel1.backgroundColor = [UIColor clearColor];
    bottonRightLabel1.textColor = [UIColor blueColor];
    bottonRightLabel1.font = [UIFont systemFontOfSize:12.0f];
    bottonRightLabel1.textAlignment = NSTextAlignmentLeft;
    [bottonRightView addSubview:bottonRightLabel1];
    
    bottonRightLabel2 = [[UILabel alloc]init];
    bottonRightLabel2.backgroundColor = [UIColor clearColor];
    bottonRightLabel2.textColor = [UIColor blueColor];
    bottonRightLabel2.font = [UIFont systemFontOfSize:12.0f];
    bottonRightLabel2.textAlignment = NSTextAlignmentLeft;
    bottonRightLabel2.text = @"0";
    [bottonRightView addSubview:bottonRightLabel2];
    
    bottonRightLabel3 = [[UILabel alloc]init];
    bottonRightLabel3.backgroundColor = [UIColor clearColor];
    bottonRightLabel3.textColor = [UIColor blueColor];
    bottonRightLabel3.font = [UIFont systemFontOfSize:12.0f];
    bottonRightLabel3.textAlignment = NSTextAlignmentLeft;
    [bottonRightView addSubview:bottonRightLabel3];
    
    verticalLine = [[UIView alloc] init];
    verticalLine.backgroundColor = [UIColor blackColor];
    [dataView addSubview:verticalLine];
    
    horizontalLine = [[UIView alloc] init];
    horizontalLine.backgroundColor = [UIColor blackColor];
    [dataView addSubview:horizontalLine];
 
}


-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(threeMonthBtn,sixMonthBtn,ytdBtn,oneYearBtn,threeYearBtn,upperView,bottonView,upperRightView,bottonRightView,upperRightTitleLabel,bottonRightTitleLabel, dataView);
    
    NSDictionary *metrics;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight == 460) {
            metrics = @{@"height2": @(260)};
        }else{
            metrics = @{@"height2": @(320)};
        }
        
        [ytdBtn setTitle:NSLocalizedStringFromTable(@"YTD換行", @"ActionPlan", nil) forState:UIControlStateNormal];
        ytdBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
        ytdBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    }else{
        metrics = @{@"height2": @(150)};
        [ytdBtn setTitle:NSLocalizedStringFromTable(@"YTD", @"ActionPlan", nil) forState:UIControlStateNormal];
        ytdBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[threeMonthBtn(40)]-2-[dataView]|" options:0 metrics:metrics views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dataView]|" options:0 metrics:metrics views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[threeMonthBtn(40)]-2-[upperView(height2)][bottonView]|" options:NSLayoutFormatAlignAllLeft metrics:metrics views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[threeMonthBtn]-2-[sixMonthBtn(threeMonthBtn)]-2-[ytdBtn(threeMonthBtn)]-2-[oneYearBtn(threeMonthBtn)]-2-[threeYearBtn(threeMonthBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[threeMonthBtn(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sixMonthBtn(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[ytdBtn(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[oneYearBtn(40)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[threeYearBtn(40)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upperView][upperRightView(68)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottonView][bottonRightView(68)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[upperRightView(==upperView)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottonRightView(==bottonView)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[upperRightTitleLabel(15)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[upperRightTitleLabel]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bottonRightTitleLabel(15)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottonRightTitleLabel]|" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(void)btnClick:(FSUIButton*)btn{

    threeMonthBtn.selected = NO;
    sixMonthBtn.selected = NO;
    ytdBtn.selected = NO;
    oneYearBtn.selected = NO;
    threeYearBtn.selected = NO;
    btn.selected = YES;
    verticalLine.hidden = YES;
    horizontalLine.hidden = YES;
    firstTime = YES;
    
    if ([btn isEqual:threeMonthBtn]) {
        [upperView setRange:threeMonth];
    }else if ([btn isEqual:sixMonthBtn]){
        [upperView setRange:sixMonth];
    }else if ([btn isEqual:ytdBtn]){
        [upperView setRange:YTD];
    }else if ([btn isEqual:oneYearBtn]){
        [upperView setRange:oneYear];
    }else if ([btn isEqual:threeYearBtn]){
        [upperView setRange:threeYear];
    }
    
    [self.view showHUDWithTitle:@""];;
}

-(void)prepareData{
    
    [[[FSDataModelProc sharedInstance] investedModel] startWithTerm:_termStr Deal:_dealStr beginDate:beginDayInt];
}

-(void)dataCallBack:(FSInvestedModel *)investedModel{
    
    maxTotal = [[[FSDataModelProc sharedInstance] investedModel]maxTotal];
    minTotal = [[[FSDataModelProc sharedInstance] investedModel]minTotal];
    maxDaily = [[[FSDataModelProc sharedInstance] investedModel]maxDaily];
    
    netWorthDataArray = investedModel.dataArray;
    upperView.histDataArray = investedModel.historicDataArray;
    bottonView.histDataArray = investedModel.historicDataArray;
    
    if (investedModel.historicDataArray && threeMonthBtn.selected) {
        [upperView setRange:threeMonth];
    }
    
    double total = maxTotal-minTotal;
    
    NSString * totalStr = [NSString stringWithFormat:@"%.0f",total];
    
    int blockNum = pow(10, totalStr.length -1 )/ 20;
    if (blockNum < 50) {
        blockNum = 50;
    }
    
    int min;
    min = minTotal / blockNum;
    minTotal = min * blockNum;
    int maxInt = maxTotal;
    double num = ceil(maxInt / blockNum) ;
    maxTotal = blockNum * (num + 1);
    
    if (maxTotal == minTotal) {
        maxTotal = minTotal + 50;
    }
    
    if (maxDaily>1000000) {
        if (fmod(maxDaily, 20000.0f) != 0.0f) {
            float num = ceilf(maxDaily / 20000.f) ;
            maxDaily = 20000 * num;
        }
    }else if (maxDaily>1000){
        if (fmod(maxDaily, 2000.0f) != 0.0f) {
            float num = ceilf(maxDaily / 2000.f) ;
            maxDaily = 2000 * num;
        }
    }else {
        if (fmod(maxDaily, maxDaily * 2) != 0.0f) {
            maxDaily = maxDaily * 2;
        }
    }
    
    upperView.maxTotal = maxTotal;
    upperView.minTotal = minTotal;
    bottonView.maxDaily = maxDaily;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[netWorthDataArray sortedArrayUsingDescriptors:sortDescriptors]];
    
    upperView.netWorthDataArray = sortedArray;
    bottonView.netWorthDataArray = sortedArray;
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc]init];
    
    for (int i =0; i<[sortedArray count]; i++) {
        NetWorthData * data = [sortedArray objectAtIndex:i];
        
        [dataDictionary setObject:data forKey:data->date];
    }
    upperView.netWorthDataDictionary = dataDictionary;
    bottonView.netWorthDataDictionary = dataDictionary;
    
    [self updateRightLabel];
    
    [upperView setNeedsDisplay];
    [bottonView setNeedsDisplay];
    
    [self.view hideHUD];
}

-(void)updateRightLabel{
    
    float upperLabelCenter = upperRightView.frame.size.height/6.5f;
    [upperRightLabel1 setFrame:CGRectMake(3, upperLabelCenter*1-upperLabelCenter/4, upperRightView.frame.size.width-5,upperLabelCenter/2 )];
    [upperRightLabel2 setFrame:CGRectMake(3, upperLabelCenter*2-upperLabelCenter/4, upperRightView.frame.size.width-5,upperLabelCenter/2 )];
    [upperRightLabel3 setFrame:CGRectMake(3, upperLabelCenter*3-upperLabelCenter/4, upperRightView.frame.size.width,upperLabelCenter/2 )];
    [upperRightLabel4 setFrame:CGRectMake(3, upperLabelCenter*4-upperLabelCenter/4, upperRightView.frame.size.width-5,upperLabelCenter/2 )];
    [upperRightLabel5 setFrame:CGRectMake(3, upperLabelCenter*5-upperLabelCenter/4, upperRightView.frame.size.width-5,upperLabelCenter/2 )];
    [upperRightLabel6 setFrame:CGRectMake(3, upperLabelCenter*6-upperLabelCenter/4, upperRightView.frame.size.width-5,upperLabelCenter/2 )];
    
    float bottonLabelCenter = bottonRightView.frame.size.height/5;
    [bottonRightLabel1 setFrame:CGRectMake(3, bottonLabelCenter*2-bottonLabelCenter/2, bottonRightView.frame.size.width-5,bottonLabelCenter )];
    [bottonRightLabel2 setFrame:CGRectMake(3, bottonLabelCenter*3-bottonLabelCenter/2, bottonRightView.frame.size.width-5,bottonLabelCenter )];
    [bottonRightLabel3 setFrame:CGRectMake(3, bottonLabelCenter*4-bottonLabelCenter/2, bottonRightView.frame.size.width-5,bottonLabelCenter )];
    
    float totalUnit = (maxTotal-minTotal)/5;
    upperRightLabel1.text = [CodingUtil stringNoDecimalByValue:maxTotal Sign:NO];
    upperRightLabel2.text = [CodingUtil stringNoDecimalByValue:maxTotal-totalUnit Sign:NO];
    upperRightLabel3.text = [CodingUtil stringNoDecimalByValue:maxTotal-totalUnit*2 Sign:NO];
    upperRightLabel4.text = [CodingUtil stringNoDecimalByValue:maxTotal-totalUnit*3 Sign:NO];
    upperRightLabel5.text = [CodingUtil stringNoDecimalByValue:maxTotal-totalUnit*4 Sign:NO];
    upperRightLabel6.text = [CodingUtil stringNoDecimalByValue:maxTotal-totalUnit*5 Sign:NO];
    
    bottonRightLabel1.text = [CodingUtil stringNoDecimalByValue:maxDaily/2.0f Sign:YES];
    bottonRightLabel3.text = [CodingUtil stringNoDecimalByValue:maxDaily/-2.0f Sign:YES];
    if([bottonRightLabel1.text isEqualToString:@"----"]){
        bottonRightLabel1.text = @"";
        bottonRightLabel3.text = @"";
    }
}

- (void)doTouchesWithPoint:(CGPoint)point Date:(NSString *)date Value:(float)value
{
    verticalLine.hidden = NO;
    horizontalLine.hidden = NO;
    [verticalLine setFrame:CGRectMake(point.x, dataView.frame.origin.x + upperView.frame.size.height/ 6.5, 0.5, dataView.frame.size.height)];
    [bottonView changeDate:date Value:value];
}
- (void)doTouchesAndMoveWithPoint:(CGPoint)point Date:(NSString *)date Value:(float)value
{
    [bottonView changeDate:date Value:value];
}

-(void)setBeginDay:(NSDate *)beginDay{
    beginDayInt = [beginDay uint16Value];
    bottonView.beginDay = beginDay;
    if (firstTime) {
        [self prepareData];
        firstTime = NO;
    }
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
