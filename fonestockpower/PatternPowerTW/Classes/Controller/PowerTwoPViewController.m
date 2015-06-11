//
//  PowerTwoPViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/11/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "PowerTwoPViewController.h"
#import "DDPageControl.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "PowerPPPOut.h"
#import "PowerTwoPIn.h"
#import "FSMainPlusDateRangeViewController.h"
#import "FSppSeriesDrawView.h"
#import "FSPowerSeriesObject.h"

@interface PowerTwoPViewController ()<UIScrollViewDelegate, UIActionSheetDelegate, FSPowerSeriesDelegate>
{
    PortfolioItem *item;
    
    FSDataModelProc *dataModel;

    NSArray *forigenBroker;
    NSArray *majorSeries;
    
    NSArray *storeMajorBtnContent;
    int totalBrokerBranch;
    
    int acculumateForBuy;
    int acculumateForSell;
    
    UILabel *showWords;
    FSUIButton *selectDateBtn;
    UIView *viewForText;
    FSppSeriesDrawView *drawThePic;
    UIScrollView *sclView;
    
    //for viewForText;
    UILabel *ll1;
    UILabel *ll2;
    UILabel *ll3;
    UILabel *ll4;
    UILabel *ll5;
    
    UILabel *buyNumber;
    UILabel *sellNumber;
    
    UIView *view1;
    UILabel *concentrationLbl;
    FSppSeriesDrawView *conImg;
    UILabel *marketSentimentLbl;
    FSppSeriesDrawView *marImg;
    UILabel *theForceLbl;
    FSppSeriesDrawView *forImg;
    
    UIView *view2;
    UILabel *firstWeightLbl;
    FSppSeriesDrawView *firImg;
    UILabel *topFiveLbl;
    FSppSeriesDrawView *topfImg;
    UILabel *herfindahlLbl;
    FSppSeriesDrawView *herImg;
    
    UIView *view3;
    UILabel *fBrokerLbl;
    FSppSeriesDrawView *fbImg;
    UILabel *goverLbl;
    FSppSeriesDrawView *govImg;
    FSUIButton *majorBtn;
    FSppSeriesDrawView *majImg;
    
    UIFont *fff;
    
    //欲當作條件上傳給server 的項目
    UInt16 startDate;
    UInt16 endDate;
    int days;
    
    //counting GINI
    NSMutableArray *buyData;
    NSMutableArray *sellData;
    NSMutableArray *zeroData;
    
    //store data which need to show
    NSMutableDictionary *aboutSell;
    NSMutableDictionary *aboutBuy;
}

@property (unsafe_unretained, nonatomic) NSInteger numberOfPages;
@property (nonatomic, strong) DDPageControl *pageControl;
@property (nonatomic, strong) NSMutableDictionary *mainDict;

@end

@implementation PowerTwoPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initPageControl];
    [self.view setNeedsUpdateConstraints];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    //畫面出現時要做的動作，主要是針對按下日期的按鈕後，跳回viewcontroller 時要做的
    [super viewWillAppear:animated];
    
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"YYYYMMdd"];
    NSDateFormatter *dateFormate1 = [[NSDateFormatter alloc] init];
    [dateFormate1 setDateFormat:@"YYYY-MM-dd"];
    
    NSString *forBtnTitle;
    if(dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeRecently && dataModel.cyqModel.pickDays){
        
        days = dataModel.cyqModel.pickDays;
        switch(dataModel.cyqModel.pickDays){
            case 1: forBtnTitle = @"1日累計"; break;
            case 5: forBtnTitle = @"5日累計"; break;
            case 10: forBtnTitle = @"10日累計"; break;
            case 20: forBtnTitle = @"20日累計"; break;
            default: forBtnTitle = @"當日"; break;
        }
        [selectDateBtn setTitle:forBtnTitle forState:UIControlStateNormal];
    }else if(dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeCalendar){
        NSString *sd = [dateFormate stringFromDate:dataModel.cyqModel.startDate];
        NSString *ed = [dateFormate stringFromDate:dataModel.cyqModel.endDate];
        if([sd isEqualToString:ed]){
            forBtnTitle = [dateFormate1 stringFromDate:dataModel.cyqModel.startDate];
        }else if(![sd isEqualToString:ed]){
            forBtnTitle = [NSString stringWithFormat:@"%@ - %@",sd,ed];
        }
        days = 0;
        [selectDateBtn setTitle:forBtnTitle forState:UIControlStateNormal];
    }
    
    startDate = [CodingUtil makeDateFromDate:dataModel.cyqModel.startDate];
    //[CodingUtil makeDate:yearStart month:monthStart day:dayStart];
    endDate = [CodingUtil makeDateFromDate:dataModel.cyqModel.endDate];
    //[CodingUtil makeDate:yearEnd month:monthEnd day:dayEnd];
    [self sendDataToServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    fff = [UIFont systemFontOfSize:20];
    UIFont *ff = [UIFont systemFontOfSize:8];
    
    dataModel = [FSDataModelProc sharedInstance];
    dataModel.powerSeriesObject.delegate = self;
    
    FSPowerSeriesObject *fspso = [[FSPowerSeriesObject alloc] init];
    majorSeries = [fspso queryBrokerOptionalIDTable:@"1"];
    storeMajorBtnContent = [NSArray arrayWithArray:[fspso getBrokerOptional]];
    totalBrokerBranch = [fspso getBrokerBranchCount];
    
    item = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    acculumateForBuy = 0;
    acculumateForSell = 0;
    
    days = 1;
    [self getYesterday];
    
    forigenBroker = [NSArray arrayWithObjects:@"港麥格理",@"港商里昂",@"台灣摩根",@"美林",@"美商高盛",@"瑞士信貸",@"德意志",@"港商野村",@"港商法興",@"瑞銀",@"花旗",@"大和國泰",@"巴克萊",@"上海匯豐",@"摩根大通",@"法銀巴黎", nil];
    
    showWords = [[UILabel alloc] init];
    showWords.text = NSLocalizedStringFromTable(@"期間", @"ppSeries", nil);
    showWords.translatesAutoresizingMaskIntoConstraints = NO;
    showWords.font = fff;
    showWords.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:showWords];
    
    selectDateBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"YYYY-MM-dd"];
    [selectDateBtn setTitle:[dateFormate stringFromDate:[NSDate date]] forState:UIControlStateNormal];
    [selectDateBtn addTarget:self action:@selector(beClicked:) forControlEvents:UIControlEventTouchUpInside];
    selectDateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:selectDateBtn];
    
    drawThePic = [[FSppSeriesDrawView alloc] init];
    drawThePic.layer.borderColor = [UIColor lightGrayColor].CGColor;
    drawThePic.layer.borderWidth = 0.5;
    drawThePic.translatesAutoresizingMaskIntoConstraints = NO;
    drawThePic.backgroundColor = [UIColor clearColor];
    [self.view addSubview:drawThePic];
    
    viewForText = [[UIView alloc] init];
    viewForText.translatesAutoresizingMaskIntoConstraints = NO;
//    viewForText.backgroundColor = [UIColor yellowColor];
    ll1 = [[UILabel alloc] init];
    ll1.font = ff;
    ll1.textAlignment = NSTextAlignmentRight;
    [viewForText addSubview:ll1];
    ll2 = [[UILabel alloc] init];
    ll2.font = ff;
    ll2.textAlignment = NSTextAlignmentRight;
    [viewForText addSubview:ll2];
    ll3 = [[UILabel alloc] init];
    ll3.font = ff;
    ll3.textAlignment = NSTextAlignmentRight;
    [viewForText addSubview:ll3];
    ll4 = [[UILabel alloc] init];
    ll4.font = ff;
    ll4.textAlignment = NSTextAlignmentRight;
    [viewForText addSubview:ll4];
    ll5 = [[UILabel alloc] init];
    ll5.font = ff;
    ll5.textAlignment = NSTextAlignmentRight;
    [viewForText addSubview:ll5];
    [self.view addSubview:viewForText];
    buyNumber = [[UILabel alloc] init];
    buyNumber.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:buyNumber];
    sellNumber = [[UILabel alloc] init];
    sellNumber.font = [UIFont systemFontOfSize:10];
    sellNumber.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:sellNumber];
    
    sclView = [[UIScrollView alloc] init];
    sclView.translatesAutoresizingMaskIntoConstraints = NO;
    sclView.userInteractionEnabled = YES;
    sclView.directionalLockEnabled = YES;
    sclView.bounces = NO;
    sclView.delegate = self;
    sclView.pagingEnabled = YES;
    [self.view addSubview:sclView];
    
    view1 = [[UIView alloc] init];
    view1.translatesAutoresizingMaskIntoConstraints = NO;
    concentrationLbl = [[UILabel alloc] init];
    concentrationLbl.text = NSLocalizedStringFromTable(@"集中度", @"ppSeries", nil);
    concentrationLbl.textAlignment = NSTextAlignmentCenter;
    concentrationLbl.translatesAutoresizingMaskIntoConstraints = NO;
    concentrationLbl.font = fff;
    [view1 addSubview:concentrationLbl];
    conImg = [[FSppSeriesDrawView alloc] init];
    conImg.layer.borderWidth = 0.5;
    conImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    conImg.translatesAutoresizingMaskIntoConstraints = NO;
    conImg.backgroundColor = [UIColor clearColor];
    [view1 addSubview:conImg];
    marketSentimentLbl = [[UILabel alloc] init];
    marketSentimentLbl.text = NSLocalizedStringFromTable(@"市場氣氛", @"ppSeries", nil);
    marketSentimentLbl.textAlignment = NSTextAlignmentCenter;
    marketSentimentLbl.translatesAutoresizingMaskIntoConstraints = NO;
    marketSentimentLbl.font = fff;
    [view1 addSubview:marketSentimentLbl];
    marImg = [[FSppSeriesDrawView alloc] init];
    marImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    marImg.layer.borderWidth = 0.5;
    marImg.translatesAutoresizingMaskIntoConstraints = NO;
    marImg.backgroundColor = [UIColor clearColor];
    [view1 addSubview:marImg];
    theForceLbl = [[UILabel alloc] init];
    theForceLbl.text = NSLocalizedStringFromTable(@"控盤力道", @"ppSeries", nil);
    theForceLbl.textAlignment = NSTextAlignmentCenter;
    theForceLbl.translatesAutoresizingMaskIntoConstraints = NO;
    theForceLbl.font = fff;
    [view1 addSubview:theForceLbl];
    forImg = [[FSppSeriesDrawView alloc] init];
    forImg.layer.borderWidth = 0.5;
    forImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    forImg.translatesAutoresizingMaskIntoConstraints = NO;
    forImg.backgroundColor = [UIColor clearColor];
    [view1 addSubview:forImg];
    //nine labels
    NSArray *aaa = [NSArray arrayWithObjects:@"1",@"0",@"1",@"0",@"1",@"∞",@"0",@"1",@"∞", nil];
    [self doTheNineLabels:aaa :ff :view1];
    
    view2 = [[UIView alloc] init];
    view2.translatesAutoresizingMaskIntoConstraints = NO;
    firstWeightLbl = [[UILabel alloc] init];
    firstWeightLbl.text = NSLocalizedStringFromTable(@"第一大比重", @"ppSeries", nil);
    firstWeightLbl.textAlignment = NSTextAlignmentCenter;
    firstWeightLbl.translatesAutoresizingMaskIntoConstraints = NO;
    firstWeightLbl.font = fff;
    [view2 addSubview:firstWeightLbl];
    firImg = [[FSppSeriesDrawView alloc] init];
    firImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    firImg.layer.borderWidth = 0.5;
    firImg.translatesAutoresizingMaskIntoConstraints = NO;
    firImg.backgroundColor = [UIColor clearColor];
    [view2 addSubview:firImg];
    topFiveLbl = [[UILabel alloc] init];
    topFiveLbl.text = NSLocalizedStringFromTable(@"前五大比重", @"ppSeries", nil);
    topFiveLbl.textAlignment = NSTextAlignmentCenter;
    topFiveLbl.translatesAutoresizingMaskIntoConstraints = NO;
    topFiveLbl.font = fff;
    [view2 addSubview:topFiveLbl];
    topfImg = [[FSppSeriesDrawView alloc] init];
    topfImg.layer.borderWidth = 0.5;
    topfImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    topfImg.translatesAutoresizingMaskIntoConstraints = NO;
    topfImg.backgroundColor = [UIColor clearColor];
    [view2 addSubview:topfImg];
    herfindahlLbl = [[UILabel alloc] init];
    herfindahlLbl.text = NSLocalizedStringFromTable(@"賀芬達指標", @"ppSeries", nil);
    herfindahlLbl.textAlignment = NSTextAlignmentCenter;
    herfindahlLbl.translatesAutoresizingMaskIntoConstraints = NO;
    herfindahlLbl.font = fff;
    [view2 addSubview:herfindahlLbl];
    herImg = [[FSppSeriesDrawView alloc] init];
    herImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    herImg.layer.borderWidth = 0.5;
    herImg.translatesAutoresizingMaskIntoConstraints = NO;
    herImg.backgroundColor = [UIColor clearColor];
    [view2 addSubview:herImg];
    //nine labels
    NSArray *aaa1 = [NSArray arrayWithObjects:@"100%",@"0",@"100%",@"100%",@"0",@"100%",@"100%",@"0",@"100%", nil];
    [self doTheNineLabels:aaa1 :ff :view2];
    
    view3 = [[UIView alloc] init];
    view3.translatesAutoresizingMaskIntoConstraints = NO;
    fBrokerLbl = [[UILabel alloc] init];
    fBrokerLbl.text = NSLocalizedStringFromTable(@"外資券商", @"ppSeries", nil);
    fBrokerLbl.textAlignment = NSTextAlignmentCenter;
    fBrokerLbl.translatesAutoresizingMaskIntoConstraints = NO;
    fBrokerLbl.font = fff;
    [view3 addSubview:fBrokerLbl];
    fbImg = [[FSppSeriesDrawView alloc] init];
    fbImg.layer.borderWidth = 0.5;
    fbImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    fbImg.translatesAutoresizingMaskIntoConstraints = NO;
    fbImg.backgroundColor = [UIColor clearColor];
    [view3 addSubview:fbImg];
    goverLbl = [[UILabel alloc] init];
    goverLbl.text = NSLocalizedStringFromTable(@"公股總行", @"ppSeries", nil);
    goverLbl.textAlignment = NSTextAlignmentCenter;
    goverLbl.translatesAutoresizingMaskIntoConstraints = NO;
    goverLbl.font = fff;
    [view3 addSubview:goverLbl];
    govImg = [[FSppSeriesDrawView alloc] init];
    govImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    govImg.layer.borderWidth = 0.5;
    govImg.translatesAutoresizingMaskIntoConstraints = NO;
    govImg.backgroundColor = [UIColor clearColor];
    [view3 addSubview:govImg];
    majorBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeShortDetailYellow];
    [majorBtn setTitle:[NSString stringWithFormat:@"%@",[storeMajorBtnContent objectAtIndex:0]] forState:UIControlStateNormal];
    [majorBtn addTarget:self action:@selector(beClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [majorBtn setFrame:CGRectMake(0, 0, 100, 100)];
    [majorBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    majorBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [view3 addSubview:majorBtn];
    majImg = [[FSppSeriesDrawView alloc] init];
    majImg.layer.borderWidth = 0.5;
    majImg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    majImg.translatesAutoresizingMaskIntoConstraints = NO;
    majImg.backgroundColor = [UIColor clearColor];
    [view3 addSubview:majImg];
    //nine labels
    NSArray *aaa2 = [NSArray arrayWithObjects:@"100%",@"0",@"100%",@"100%",@"0",@"100%",@"100%",@"0",@"100%", nil];
    [self doTheNineLabels:aaa2 :ff :view3];
    
    [sclView addSubview:view1];
    [sclView addSubview:view2];
    [sclView addSubview:view3];
    
    
}

//下方三個view 內各有九個在相同位置的label，在此作設定
-(void)doTheNineLabels:(NSArray *)showSeries :(UIFont *)ff :(UIView *)vv
{
    for(int i = 0; i < 3; i++){
        UILabel *l1 = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 50, 10)];
        l1.text = [showSeries objectAtIndex:0];
        l1.font = ff;
        [vv addSubview:l1];
        UILabel *l2 = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 110) / 2 + 108, 0, 10, 10)];
        l2.text = [showSeries objectAtIndex:1];
        l2.font = ff;
        [vv addSubview:l2];
        UILabel *l3 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50, 0, 50, 10)];
        l3.text = [showSeries objectAtIndex:2];
        l3.font = ff;
        l3.textAlignment = NSTextAlignmentRight;
        [vv addSubview:l3];
        UILabel *l4 = [[UILabel alloc] initWithFrame:CGRectMake(110, 50, 50, 10)];
        l4.text = [showSeries objectAtIndex:3];
        l4.font = ff;
        [vv addSubview:l4];
        UILabel *l5 = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 110) / 2 + 108, 50, 10, 10)];
        l5.text = [showSeries objectAtIndex:4];
        l5.font = ff;
        [vv addSubview:l5];
        UILabel *l6 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50, 50, 50, 10)];
        l6.text = [showSeries objectAtIndex:5];
        l6.font = ff;
        l6.textAlignment = NSTextAlignmentRight;
        [vv addSubview:l6];
        UILabel *l7 = [[UILabel alloc] initWithFrame:CGRectMake(110, 100, 50, 10)];
        l7.text = [showSeries objectAtIndex:6];
        l7.font = ff;
        [vv addSubview:l7];
        UILabel *l8 = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 110) / 2 + 108, 100, 10, 10)];
        l8.text = [showSeries objectAtIndex:7];
        l8.font = ff;
        [vv addSubview:l8];
        UILabel *l9 = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50, 100, 50, 10)];
        l9.text = [showSeries objectAtIndex:8];
        l9.font = ff;
        l9.textAlignment = NSTextAlignmentRight;
        [vv addSubview:l9];
    }
}

//主力++ 內只有兩個按鈕，一個是上面的日期，一個是第三個view 的主力按鈕
-(void)beClicked:(FSUIButton *)sender
{
    if(sender == majorBtn){
        UIActionSheet *action1 = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"自設主力", @"ppSeries", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"ppSeries", nil) destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"%@",[storeMajorBtnContent objectAtIndex:0]], [NSString stringWithFormat:@"%@",[storeMajorBtnContent objectAtIndex:1]], [NSString stringWithFormat:@"%@",[storeMajorBtnContent objectAtIndex:2]], [NSString stringWithFormat:@"%@",[storeMajorBtnContent objectAtIndex:3]], [NSString stringWithFormat:@"%@",[storeMajorBtnContent objectAtIndex:4]], nil];
        [action1 showInView:self.view];
    }else{
        FSMainPlusDateRangeViewController *mpdr = [[FSMainPlusDateRangeViewController alloc] init];
        [self.navigationController pushViewController:mpdr animated:NO];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *groupIndex = [NSString stringWithFormat:@"%d", (int)buttonIndex + 1];
    FSPowerSeriesObject *fspso = [[FSPowerSeriesObject alloc] init];
    majorSeries = [fspso queryBrokerOptionalIDTable:groupIndex];
    [self dealTheMajorSeries];
    [self drawTheView:@[majImg] :@[@"major"]];
}

-(NSDate *)getYesterday
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    NSDate *today = [cal dateFromComponents:comps];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    dataModel.cyqModel.startDate = yesterday;
    dataModel.cyqModel.endDate = yesterday;
    startDate = [CodingUtil makeDateFromDate:yesterday];
    endDate = [CodingUtil makeDateFromDate:yesterday];
    return yesterday;
}

#pragma -
#pragma mark About Layout
-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(showWords, selectDateBtn, drawThePic, sclView, view1, concentrationLbl, conImg, marketSentimentLbl, marImg, theForceLbl, forImg, view2, firstWeightLbl, firImg, topFiveLbl, topfImg, herfindahlLbl, herImg, view3, fBrokerLbl, fbImg, goverLbl, govImg, majorBtn, majImg, viewForText);
    NSNumber *aa = [[NSNumber alloc] initWithFloat:viewForText.frame.size.height/4];
    NSNumber *viewWidth = [[NSNumber alloc] initWithFloat:self.view.frame.size.width];
    NSNumber *eachHeight = [[NSNumber alloc] initWithFloat:40.0];
    NSNumber *viewHeight = [[NSNumber alloc] initWithFloat:150.0];
    NSDictionary *metrics = @{@"aa":aa, @"viewWidth":viewWidth, @"hhh":eachHeight, @"vhh":viewHeight};
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    //self.view autolayout
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[showWords(35)]-5-[viewForText]-15-[sclView(150)]-19-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[showWords(55)][selectDateBtn]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewForText(25)][drawThePic]-1-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[selectDateBtn(35)]-5-[drawThePic]-15-[sclView(150)]-19-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sclView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    //sclView autolayout
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view1]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view1(viewWidth)][view2(viewWidth)][view3(viewWidth)]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view2]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view3(vhh)]" options:0 metrics:metrics views:allObj]];
    //view1 autolayout
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[concentrationLbl(40)]-10-[marketSentimentLbl(concentrationLbl)]-10-[theForceLbl(concentrationLbl)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[concentrationLbl(100)]-5-[conImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[marketSentimentLbl(100)]-5-[marImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[theForceLbl(100)]-5-[forImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[conImg(hhh)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[marImg(hhh)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[forImg(hhh)]" options:0 metrics:metrics views:allObj]];
    //view2 autolayout
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[firstWeightLbl(40)]-10-[topFiveLbl(firstWeightLbl)]-10-[herfindahlLbl(firstWeightLbl)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[firstWeightLbl(100)]-5-[firImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[topFiveLbl(100)]-5-[topfImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[herfindahlLbl(100)]-5-[herImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firImg(hhh)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topfImg(hhh)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[herImg(hhh)]" options:0 metrics:metrics views:allObj]];
    //view3 autolayout
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[fBrokerLbl(40)]-10-[goverLbl(fBrokerLbl)]-10-[majorBtn(fBrokerLbl)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[fBrokerLbl(100)]-5-[fbImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[goverLbl(100)]-5-[govImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[majorBtn(100)]-5-[majImg]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[fbImg(hhh)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[govImg(hhh)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[majImg(hhh)]" options:0 metrics:metrics views:allObj]];
    
    [self replaceCustomizeConstraints:constraints];
     
}

-(void)viewDidLayoutSubviews
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = 150.0;
    [sclView setContentSize:CGSizeMake(width * 3, height)];
    
    [self.pageControl setFrame:CGRectMake(sclView.center.x, self.view.bounds.size.height - 10, self.pageControl.frame.size.width, 30)];
    [self.pageControl setCenter:CGPointMake(sclView.center.x, self.view.bounds.size.height - 10)];
    
    ll1.text = @"100%";
    ll2.text = @"50%";
    ll3.text = @"0%";
    ll4.text = @"50%";
    ll5.text = @"100%";
    double range = viewForText.frame.size.height / 4;
    [ll1 setFrame:CGRectMake(0, 0, viewForText.frame.size.width, 20)];
    [ll2 setFrame:CGRectMake(0, range * 1 - 10, viewForText.frame.size.width, 20)];
    [ll3 setFrame:CGRectMake(0, range * 2 - 10, viewForText.frame.size.width, 20)];
    [ll4 setFrame:CGRectMake(0, range * 3 - 10, viewForText.frame.size.width, 20)];
    [ll5 setFrame:CGRectMake(0, range * 4 - 15, viewForText.frame.size.width, 20)];
    buyNumber.text = NSLocalizedStringFromTable(@"買超家數", @"ppSeries", nil);
    [buyNumber setFrame:CGRectMake(viewForText.frame.size.width, self.view.frame.size.height - 183, 50, 10)];
    sellNumber.text = NSLocalizedStringFromTable(@"賣超家數", @"ppSeries", nil);
    [sellNumber setFrame:CGRectMake(self.view.frame.size.width - 50, self.view.frame.size.height - 183, 50, 10)];
    //像這些label 位置必須在autolayout 放完後才指定的位置可以放在viewDidLayoutSubviews
    
}

-(void)initPageControl
{
    self.numberOfPages = 3;
    self.pageControl = [[DDPageControl alloc] init];
    self.pageControl.numberOfPages = self.numberOfPages;
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
    [self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
    [self.pageControl setOnColor: [UIColor redColor]];
    [self.pageControl setOffColor: [UIColor redColor]];
    [self.pageControl setIndicatorDiameter: 7.0f] ;
    [self.pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    CGFloat pageWidth = sclView.bounds.size.width;
    float fractionalPage = sclView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    
    if (self.pageControl.currentPage != nearestNumber) {
        self.pageControl.currentPage = nearestNumber;
        [self.pageControl updateCurrentPageDisplay] ;
    }
}

-(void)sendDataToServer
{
//    startDate = (UInt16)28005;
//    endDate = (UInt16)28011;
    UInt16 ui16 = (UInt16)[NSString stringWithFormat:@"%c%c",item->identCode[0],item->identCode[1]];
    PowerPPPOut *ppp = [[PowerPPPOut alloc] initWithPowerPP:ui16 :item->symbol :days :startDate :endDate];
    NSDate *now = [[NSDate alloc] init];
    [now uint16Value];
    [FSDataModelProc sendData:self WithPacket:ppp];
}

#pragma -
#pragma mark 資料下來後，主要的動作都在這
-(void)loadDidFinishWithData:(FSPowerSeriesObject *)data
{
    NSMutableArray *brokerBranchData = data.storeBrokerBranchData;
    
    if(brokerBranchData.count == 0){
    }else{
        [self setSelectDateBtnTitle:data.dateArray];
        sellData = [[NSMutableArray alloc] init];
        buyData = [[NSMutableArray alloc] init];
        zeroData = [[NSMutableArray alloc] init];
        for(StoreBrokerBranch *bbd in brokerBranchData){
//            NSLog(@"ID->%@ public->%d offset->%.0f",bbd.brokerBranchId,bbd.stockHeadquarter,bbd.sellOffset.calcValue);
            if(bbd.sellOffset.calcValue > 0){
                [buyData addObject:bbd];
            }else if(bbd.sellOffset.calcValue < 0){
                [sellData addObject:bbd];
            }else if(bbd.sellOffset.calcValue == 0){
                [zeroData addObject:bbd];
            }
        }
//        NSMutableArray *aa = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
        [self countingSellGiniCoefficient:sellData :&acculumateForSell];
        [self countingGiniCoefficient:buyData :&acculumateForBuy];
        [self dealTheMajorSeries];
//        NSLog(@"buyData->%d sellData->%d zeroData->%d",buyData.count,sellData.count,zeroData.count);
        NSArray *imgArray = [NSArray arrayWithObjects:conImg, firImg, topfImg, herImg, govImg, fbImg, majImg, marImg, forImg, nil];
        NSArray *keyArray = [NSArray arrayWithObjects:@"concentrate", @"topOne", @"topFive", @"herfindahlIndex", @"countingHeadquarter", @"forigen", @"major", @"marketSentiment", @"theForce", nil];
        [self drawTheView:imgArray :keyArray];
        drawThePic.storeBuyArray = buyData;
        drawThePic.storeSellArray = sellData;
        drawThePic.totalOffsetForBuy = acculumateForBuy;
        drawThePic.totalOffsetForSell = acculumateForSell;
        [drawThePic setNeedsDisplay];
    }
}

#pragma -
#pragma mark 技術數值的method 都在下面
-(void)drawTheView:(NSArray *)imgAr :(NSArray *)keyAr
{
    for(int i = 0; i < imgAr.count; i++){
        //目前市場氣氛及控盤力道的部份算法並不是jimmy 教的算法
        //有問題的話再跟jimmy 討論吧
        if([[keyAr objectAtIndex:i] isEqualToString:@"marketSentiment"]){
            ((FSppSeriesDrawView *)[imgAr objectAtIndex:i]).marketSentiment = (buyData.count * 1.0) / (sellData.count * 1.0);
        }else if([[keyAr objectAtIndex:i] isEqualToString:@"theForce"]){
            ((FSppSeriesDrawView *)[imgAr objectAtIndex:i]).theForce = [(NSNumber *)[aboutBuy objectForKey:@"concentrate"]doubleValue]/[(NSNumber *)[aboutSell objectForKey:@"concentrate"]doubleValue];
        }else{
            ((FSppSeriesDrawView *)[imgAr objectAtIndex:i]).theBuyData = [(NSNumber *)[aboutBuy objectForKey:[keyAr objectAtIndex:i]]doubleValue];
            ((FSppSeriesDrawView *)[imgAr objectAtIndex:i]).theSellData = [(NSNumber *)[aboutSell objectForKey:[keyAr objectAtIndex:i]]doubleValue];
        }
        [((FSppSeriesDrawView *)[imgAr objectAtIndex:i]) setNeedsDisplay];
    }
    //控盤力道：買超集中度 ÷ 賣超集中度
    //市場氣氛：買超家數 ÷ 賣超家數
}

-(void)dealTheMajorSeries
{
    //計算按下主力按鈕後會對自設主力進行計算的method
    CGFloat ss = 0.0;
    CGFloat bb = 0.0;
    for(NSString *str in majorSeries){
        for(StoreBrokerBranch *sbb in sellData){
            if([str isEqualToString:sbb.brokerBranchId]){
                ss += sbb.sellOffset.calcValue * -1;
            }
        }
        for(StoreBrokerBranch *sbb in buyData){
            if([str isEqualToString:sbb.brokerBranchId]){
                bb += sbb.sellOffset.calcValue;
            }
        }
    }
    [aboutSell setValue:[NSString stringWithFormat:@"%.4f",ss/acculumateForSell] forKey:@"major"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%.4f",bb/acculumateForBuy] forKey:@"major"];
}

-(void)countingSellGiniCoefficient:(NSMutableArray *)data :(int *)aia
{
    int totalCount = (int)data.count;
    aboutSell = [[NSMutableDictionary alloc] init];
    int i = 0;
    int acculumate = 0;
    long long outTheLoop = 0;
    CGFloat forForigen = 0.0;
    CGFloat herfindahlIndex = 0.0;
    CGFloat countingHeadquarter = 0.0;
    NSMutableArray *topFiveArray = [[NSMutableArray alloc] init];
    for(StoreBrokerBranch *sbb in data){
        double aa = (sbb.sellOffset.calcValue * -1);
        i++;
        outTheLoop = outTheLoop + (aa * (-1 * totalCount + 2 * i - 1));
        acculumate = acculumate + aa;
        if(i > totalCount - 5){
            [topFiveArray addObject:[NSString stringWithFormat:@"%.0f",aa]];
        }
        if(sbb.stockHeadquarter == 1){
            countingHeadquarter += aa;
        }
        for(NSString *str in forigenBroker){
            if([str isEqualToString:sbb.brokerBranchId]){
                forForigen += aa;
            }
        }
    }
    for(StoreBrokerBranch *sbb in data){
        double aa = (sbb.sellOffset.calcValue * -1);
        herfindahlIndex = herfindahlIndex + ((aa / acculumate) * (aa / acculumate));
    }
    *aia = acculumate;
    outTheLoop = outTheLoop * 2 / (totalCount * (totalCount - 1));
    [aboutSell setValue:[NSString stringWithFormat:@"%.2f",(outTheLoop / ( 2.0 * acculumate / totalCount))] forKey:@"concentrate"];
    [aboutSell setValue:[NSString stringWithFormat:@"%.4f",herfindahlIndex] forKey:@"herfindahlIndex"];
    [aboutSell setValue:[NSString stringWithFormat:@"%d",totalCount] forKey:@"marketSentiment"];
    [aboutSell setValue:[NSString stringWithFormat:@"%.2f",(outTheLoop / ( 2.0 * acculumate / totalCount))] forKey:@"theForce"];
    [aboutSell setValue:[NSString stringWithFormat:@"%.2f",[[topFiveArray lastObject] floatValue]/acculumate] forKey:@"topOne"];
    [aboutSell setValue:[NSString stringWithFormat:@"%.2f",([[topFiveArray objectAtIndex:0] floatValue] + [[topFiveArray objectAtIndex:1] floatValue] + [[topFiveArray objectAtIndex:2] floatValue] + [[topFiveArray objectAtIndex:3] floatValue] + [[topFiveArray objectAtIndex:4] floatValue])/acculumate] forKey:@"topFive"];
    [aboutSell setValue:[NSString stringWithFormat:@"%.4f",countingHeadquarter/acculumate] forKey:@"countingHeadquarter"];
    [aboutSell setValue:[NSString stringWithFormat:@"%.4f",forForigen/acculumate] forKey:@"forigen"];
}

-(void)countingGiniCoefficient:(NSMutableArray *)data :(int *)aia
{
    //因數值太大，且不打算將其拆開，所以直接使用long long 這個型態
    aboutBuy = [[NSMutableDictionary alloc] init];
    int totalCount = (int)data.count;
    int i = totalCount + 1;
    int acculumate = 0;
    CGFloat forForigen = 0.0;
    CGFloat countingHeadquarter = 0.0;
    NSMutableArray *neededData = [[NSMutableArray alloc] init];
    for(StoreBrokerBranch *sbb in data){
        [neededData addObject:[NSString stringWithFormat:@"%.0f",sbb.sellOffset.calcValue]];
         acculumate = acculumate + sbb.sellOffset.calcValue;
    }
//    if(acculumate < 0){
//        NSArray *tmpArray = [NSArray arrayWithArray:neededData];
//        [neededData removeAllObjects];
//        for(NSString *aa in [tmpArray reverseObjectEnumerator]){
//            [neededData addObject:[NSString stringWithFormat:@"%d",([aa intValue] * -1)]];
//        }
//        acculumate = acculumate * -1;
//    }
    long long outTheLoop = 0;
    
    NSMutableArray *topFiveArray = [[NSMutableArray alloc] init];
//    int forTopFive = 0;
    CGFloat herfindahlIndex = 0.0;
    for(StoreBrokerBranch *sbb in data){
        i--;
        outTheLoop = outTheLoop + (sbb.sellOffset.calcValue * ((totalCount * -1) + 2 * i - 1));
       
        if(topFiveArray.count < 5){
            [topFiveArray addObject:[NSString stringWithFormat:@"%.2f",sbb.sellOffset.calcValue]];
        }
        herfindahlIndex = herfindahlIndex + ((sbb.sellOffset.calcValue / acculumate) * (sbb.sellOffset.calcValue / acculumate));
        if(sbb.stockHeadquarter == 1){
            countingHeadquarter += sbb.sellOffset.calcValue;
        }
        for(NSString *str in forigenBroker){
            if([str isEqualToString:sbb.brokerBranchId]){
                forForigen += sbb.sellOffset.calcValue;
            }
        }
    }
    *aia = acculumate;
    [aboutBuy setValue:[NSString stringWithFormat:@"%.2f",(outTheLoop * 2.0 /(totalCount * (totalCount - 1))) / (2.0 * acculumate / totalCount)] forKey:@"concentrate"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%.4f",herfindahlIndex] forKey:@"herfindahlIndex"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%d",totalCount] forKey:@"marketSentiment"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%.2f",(outTheLoop * 2.0 /(totalCount * (totalCount - 1))) / (2.0 * acculumate / totalCount)] forKey:@"theForce"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%.2f",[[topFiveArray firstObject] floatValue]/acculumate] forKey:@"topOne"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%.2f",([[topFiveArray objectAtIndex:0] floatValue] + [[topFiveArray objectAtIndex:1] floatValue] + [[topFiveArray objectAtIndex:2] floatValue] + [[topFiveArray objectAtIndex:3] floatValue] + [[topFiveArray objectAtIndex:4] floatValue])/acculumate] forKey:@"topFive"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%.4f",(countingHeadquarter/acculumate)] forKey:@"countingHeadquarter"];
    [aboutBuy setValue:[NSString stringWithFormat:@"%.4f",(forForigen/acculumate)] forKey:@"forigen"];
    //一開始會算不出來的原因是排序上的問題
    //i 跟Yi 要對應起來，也就是說：i 如果要從1 開始，則Yi 就是從小到大排序！
    //以下的註解為不同的計算方式計算吉尼係數及驗算的部份
//    
//    ///////
     
//    
//    long long storeYi = 0;
//    long long acculumate1 = 0;
//    for(StoreBrokerBranch *sbb in data){
//        storeYi = sbb.sellOffset.calcValue + storeYi;
//    }
//    acculumate1 = storeYi;
//    long long firstSiegma = storeYi * (totalCount + 1);
//    
//    long long storeYi2 = 0;
//    int j = totalCount + 1;
//    for(StoreBrokerBranch *sbb in data){
//        j--;
////        int a = (data.count - j + 1);
////        int b = [[NSString stringWithFormat:@"%.0f",sbb.sellOffset.calcValue] intValue];
////        storeYi2 = a * b + storeYi2;
//        storeYi2 = storeYi2 + ((totalCount - j + 1) * sbb.sellOffset.calcValue);
////        NSLog(@"sbb = %.0f", sbb.sellOffset.calcValue);
////        NSLog(@"storeYi = %.0f", storeYi2);
//    }
//    long long secondSiegma = 2 * storeYi2;
////    NSLog(@"the answer %.2f fir%ld sec%ld",(((2.0 / (totalCount * (totalCount - 1))) * (firstSiegma - secondSiegma)) / (2.0 * acculumate1 / totalCount)),firstSiegma,secondSiegma);
//    NSLog(@"the answer %.2f fir%ld sec%ld",(((2.0 / (totalCount * (totalCount - 1))) * ((storeYi * (totalCount + 1)) - secondSiegma)) / (2.0 * acculumate1 / totalCount)),firstSiegma,secondSiegma);
//
//    int storeYi = 0;
//    int acculumate1 = 0;
//    for(NSString *str in data){
//        storeYi = [str intValue] + storeYi;
//    }
//    acculumate1 = storeYi;
//    int firstOmega = storeYi * (data.count + 1);
//
//    int storeYi2 = 0;
//    int j = 0;
//    for(NSString *str in data){
//        j++;
//        storeYi2 = storeYi2 + ((data.count - j + 1) * [str intValue]);
//    }
//    int secondOmega = 2 * storeYi2;
//    NSLog(@"the answer %.2f",(((2.0 / (data.count * (data.count - 1))) * (firstOmega - secondOmega)) / (2.0 * acculumate1 / data.count)));
}

-(void)setSelectDateBtnTitle:(NSMutableArray *)dateArray
{
    if([[dateArray objectAtIndex:0] isEqualToString:[dateArray objectAtIndex:1]]){
        NSArray *ar = [[dateArray objectAtIndex:0] componentsSeparatedByString:@"/"];
        [selectDateBtn setTitle:[NSString stringWithFormat:@"%@-%@-%@",[ar objectAtIndex:0],[ar objectAtIndex:1],[ar objectAtIndex:2]] forState:UIControlStateNormal];
    }else if(![[dateArray objectAtIndex:0] isEqualToString:[dateArray objectAtIndex:1]]){
        NSArray *ar = [[dateArray objectAtIndex:0] componentsSeparatedByString:@"/"];
        NSArray *ar2 = [[dateArray objectAtIndex:1] componentsSeparatedByString:@"/"];
        [selectDateBtn setTitle:[NSString stringWithFormat:@"%@%@%@ - %@%@%@",[ar objectAtIndex:0],[ar objectAtIndex:1],[ar objectAtIndex:2],[ar2 objectAtIndex:0],[ar2 objectAtIndex:1],[ar2 objectAtIndex:2]] forState:UIControlStateNormal];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
