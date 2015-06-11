//
//  EDOTargerController.m
//  FonestockPower
//
//  Created by Kenny on 2014/5/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODTargetController.h"
#import "FSUIButton.h"
#import "EODTargetTableViewCell.h"
#import "EODTargetModel.h"
#import "EODTargetOut.h"
#import "FigureSearchUS.h"
#import "FigureSearchMyProfileModel.h"
#import "FigureSearchResultViewController.h"
#import "FigureCustomCaseViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "EODTarget.h"
#import "FigureSearchCheckBoxTableViewCell.h"
#import "FSAppDelegate.h"
#import "RadioTableViewCell.h"
#import "FSHUD.h"
#import "SearchCriteriaModel.h"
#import "SearchCriteriaViewController.h"
#import "SGInfoAlert.h"
#import "ExplanationViewController.h"
#import "EODTargetIn.h"

#define SECTOR_DIAN_TOU      2     // 店頭市場
#define SECTOR_JI_JHONG     21     // 集中市場
#define SECTOR_SHANG_JIAO   101    //上交所
#define SECTOR_SHEN_JIAO    121    //深交所
#define SECTOR_NYSE         296     //NYSE
#define SECTOR_NASDAQ       297     //NASDAQ
#define SECTOR_AMEX         298     //AMEX



@interface EODTargetController ()<UIAlertViewDelegate, FigureSearchDelegate, EODTargetDelegate, UITableViewDataSource, UITableViewDelegate>
{
    BOOL firstFlag;
}
@property (strong, nonatomic) EODTargetModel *model;
@property (strong ,nonatomic)FigureSearchUS * figureSearchUS;
@property (strong ,nonatomic)EODTarget * eodTarget;
@property (nonatomic)enum FigureSearchUSFeeType searchType;
@property (strong, nonatomic) NSArray * moreOptionIconsEquation;
@property (strong, nonatomic) NSArray * zeroOptionIconsEquation;
@property (strong , nonatomic) UIAlertView * changeAlert;
@property (strong , nonatomic) UIAlertView * searchResultAlert;
@property (strong , nonatomic) FigureSearchMyProfileModel * customModel;
@property (nonatomic) int figureSearchID;
@property (strong, nonatomic) NSString * figureSearchName;
@property (strong , nonatomic)NSString * functionName;
@property (strong, nonatomic)NSString * resultEquationName;
@property (strong, nonatomic)NSString * resultTargetMarket;
@property (nonatomic)int resultDataAmount;
@property (nonatomic)int resultTotalAmount;
@property (strong, nonatomic)NSDate * resultDataDate;
@property (strong, nonatomic) NSArray * resultDataArray;
@property (strong, nonatomic) NSArray * resultMarkPriceArray;
@property (strong, nonatomic)UIAlertView * resultAlert;
@property (strong, nonatomic)UIAlertView * searchAlert;
@property (strong, nonatomic) NSString * opportunity;
@property (strong, nonatomic) NSMutableDictionary  * countDict;
@property (strong, nonatomic) NSMutableDictionary  * count2Dict;

@property (strong, nonatomic) SearchCriteriaModel *searchModel;
@end

@implementation EODTargetController
{
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    FSUIButton *considerationsButton;
    UITableView *mainTableView;
    NSString *gategoryStr;
    SearchCriteriaViewController *searchViewController;
    UIImage *redButton;
    UIImage *yellowButton;
    NSString *deatilFormula;
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

    firstFlag = YES;
    self.title = NSLocalizedStringFromTable(@"EOD Targets", @"FigureSearch", nil);
    // Do any additional setup after loading the view.
    [self initSearchView];
    [self setUpImageBackButton];
    [self initMoreOption];
    [self initZeroOption];
    [self initConsiderations];
    [self initTableView];
    [self initModel];
    [self initformulaArray];
    [self initDict];
    [self processLayout];
    gategoryStr = @"LongSystem"; 
}

-(void)explantation:(UIButton *)sender
{
    [self.navigationController pushViewController:[[ExplanationViewController alloc] init] animated:NO];
}

-(void)initSearchView
{
    searchViewController = [[SearchCriteriaViewController alloc] initWithName:@"EODTargetSearch"];
}

-(void)initDict
{
    self.countDict = [[NSMutableDictionary alloc] init];
    self.count2Dict = [[NSMutableDictionary alloc] init];
}


-(void)sendFormulaHandler
{
    if(firstFlag){
        [SGInfoAlert showInfo_EOD:NSLocalizedStringFromTable(@"搜尋結果為最近一次收盤資料.", @"FigureSearch", nil) bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
    }

    
    NSString *result = [searchViewController.formula stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"D0"];
    EODTargetOut *targetout = [[EODTargetOut alloc]initWithSerialNumber:5 PatternCount:24 Equation:result Reserved:0];
    [FSDataModelProc sendData:self WithPacket:targetout];
    self.eodTarget = [[FSDataModelProc sharedInstance] eodTarget];
    _eodTarget.delegate = self;
}


-(void)callBackResultDict:(EODTargetIn *)data
{
    self.countDict = data->longData;
    self.count2Dict = data->shortData;
    
    [mainTableView reloadData];
    
    [self.view hideHUD];
    
//    if ([self.countDict count] == 0 && [self.count2Dict count] == 0) {
//        [[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"無相符個股", @"SecuritySearch", nil) message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil] show];
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([searchViewController.formula isEqualToString:@""]){
        [considerationsButton setBackgroundImage:redButton forState:UIControlStateNormal];
    }else{
        [considerationsButton setBackgroundImage:yellowButton forState:UIControlStateNormal];
    }
    self.figureSearchUS = [[FSDataModelProc sharedInstance] figureSearchUS];
    _figureSearchUS.delegate = self;
    [self registerLoginNotificationCallBack:self seletor:@selector(sendFormulaHandler)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(sendFormulaHandler)];
    if(![deatilFormula isEqualToString:searchViewController.formula]){
        [self sendFormulaHandler];
        if (!firstFlag) {
            [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"EOD搜尋中", @"FigureSearch", nil)];
        }
        firstFlag = NO;
    }
    
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    deatilFormula = searchViewController.formula;
    _figureSearchUS.delegate = nil;
    _eodTarget.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMoreOption
{
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股", @"FigureSearch", nil);
    
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
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股", @"FigureSearch", nil);
    
    zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zeroOptionButton];
}

-(void)initConsiderations
{
    NSString *considerationsTitle = NSLocalizedStringFromTable(@"條件2", @"FigureSearch", nil);
    
    considerationsButton = [[FSUIButton alloc] init];
    redButton = [[UIImage imageNamed:@"redButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
    yellowButton = [[UIImage imageNamed:@"發亮橘色按鍵-88"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 13, 18, 13)];
    [considerationsButton setBackgroundImage:redButton forState:UIControlStateNormal];
    considerationsButton.adjustsImageWhenHighlighted = NO;
    considerationsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [considerationsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [considerationsButton setTitle:considerationsTitle forState:UIControlStateNormal];
    [considerationsButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:considerationsButton];
}

-(void)initTableView
{
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
}

-(void)initModel
{
    self.model = [[EODTargetModel alloc] init];
}

-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:moreOptionButton]) {
        zeroOptionButton.selected = NO;
        moreOptionButton.selected = YES;
        gategoryStr = @"LongSystem";
    }else if([btn isEqual:zeroOptionButton]){
        zeroOptionButton.selected = YES;
        moreOptionButton.selected = NO;
        gategoryStr = @"ShortSystem";
    }else{
        [self.navigationController pushViewController:searchViewController animated:NO];
    }
    [mainTableView reloadData];
}


-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(moreOptionButton, zeroOptionButton, mainTableView, considerationsButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-2-[zeroOptionButton(==moreOptionButton)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[considerationsButton]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[moreOptionButton(44)][considerationsButton(44)][mainTableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[zeroOptionButton(44)]" options:0 metrics:nil views:viewController]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EDOTargetCell";
    EODTargetTableViewCell *cell = (EODTargetTableViewCell *)[mainTableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell = [[EODTargetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    TPNObject *obj;
    if(moreOptionButton.selected){
        obj = [self.countDict objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }else if(zeroOptionButton.selected){
        obj = [self.count2Dict objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }
    
//    cell.imageTitle.text = NSLocalizedStringFromTable([[_model searchFigureSearchIdWithGategory:gategoryStr ItemOrder:[NSNumber numberWithInt:indexPath.row+1]] objectAtIndex:1], @"FigureSearch", nil);
    cell.imageTitle.text = NSLocalizedStringFromTable(obj->name,@"FigureSearch",nil);
    cell.imgView.image = [UIImage imageWithData:obj->imgData];
    cell.countNum.text = [NSString stringWithFormat:@"%d", obj->count];
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(moreOptionButton.selected){
        return [self.countDict count];
    }else{
        return [self.count2Dict count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.0f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPNObject *obj;
    if(moreOptionButton.selected){
        obj = [self.countDict objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }else if(zeroOptionButton.selected){
        obj = [self.count2Dict objectForKey:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }
    
    _figureSearchID = [(NSNumber *)[[_model searchFigureSearchIdWithGategory:gategoryStr ItemOrder:[NSNumber numberWithInt:obj->number]] objectAtIndex:0]intValue];
    ;
    _figureSearchName = [(NSArray *)[_model searchFigureSearchIdWithGategory:gategoryStr ItemOrder:[NSNumber numberWithInt:obj->number]] objectAtIndex:1];
    [self goSearch:obj->number-1];
}

-(void)initformulaArray{
    self.zeroOptionIconsEquation = [[NSArray alloc] initWithObjects:
                                    @"(#RANGE#0OPEN - #RANGE#0LAST) > #RANGE#1LAST * #LONGPARAM2# ",
                                    @"(#RANGE#0LAST / #RANGE#0LOW)< #TWOPARAM# and #RANGE#0OPEN >= #RANGE#0LAST and (#RANGE#0HIGH - #RANGE#0OPEN) > #RANGE#1LAST * #PARAM# and (#RANGE#1LAST / #RANGE#1LOW)< #TWOPARAM# and #RANGE#1OPEN >= #RANGE#1LAST and (#RANGE#1HIGH - #RANGE#1OPEN) > #RANGE#2LAST * #PARAM#",
                                    @"#RANGE#1NEW_HI#TIME# and (#RANGE#0OPEN - #RANGE#0LAST) > #RANGE#1LAST * #PARAM# and #RANGE#0LAST <= #RANGE#2OPEN and #RANGE#0HIGH <= #RANGE#1LOW and (if(#RANGE#1LAST>=#RANGE#1OPEN)then(#RANGE#1LAST - #RANGE#1OPEN)else(#RANGE#1OPEN - #RANGE#1LAST)end/#RANGE#1LAST)< #MULT# and #RANGE#1LOW >= #RANGE#2HIGH and (#RANGE#2LAST - #RANGE#2OPEN) > #RANGE#3LAST * #PARAM#",
                                    @"#BEARS3#",
                                    @"(#RANGE#0OPEN - #RANGE#0LAST ) > #RANGE#1LAST * #PARAM# and #RANGE#1LAST > #RANGE#1OPEN and (#RANGE#2OPEN - #RANGE#2LAST ) > #RANGE#3LAST * #PARAM# and #RANGE#0OPEN > #RANGE#1LAST and #RANGE#0LAST < #RANGE#1OPEN and #RANGE#1LAST < #RANGE#2OPEN and #RANGE#1OPEN > #RANGE#2LAST",
                                    @"#BEAR3CALVES#",
                                    @"#RANGE#1NEW_HI#TIME# and #RANGE#1LOW > #RANGE#0HIGH * 1.02 and #RANGE#1LOW > #RANGE#2HIGH * 1.02",
                                    @"MAX#SPEC1#(#RANGE#1PRC_MA#SPEC2#) / MIN#SPEC1#(#RANGE#1PRC_MA#SPEC2#) < #SPMULT# and #RANGE#0NEW_LO#SPEC1# and (#RANGE#0OPEN - #RANGE#0LAST)  > #RANGE#1LAST * #PARAM#",
                                    @"#RANGE#0NEW_HI#TIME# and if(#RANGE#0LAST >= #RANGE#0OPEN)then(#RANGE#0HIGH - #RANGE#0LAST)else(#RANGE#0HIGH - #RANGE#0OPEN)end  > #RANGE#1LAST * #LONGHORNPARAM#",
                                    @"(#RANGE#3OPEN - #RANGE#3LAST)  > #RANGE#4LAST * #PARAM# and MIN3(#RANGE#0LOW) >= #RANGE#3LOW and MAX3(#RANGE#0HIGH) <= ((#RANGE#3OPEN + #RANGE#3LAST) / 2 )",
                                    @"#RANGE#0NEW_LO#TIME# and #RANGE#0LAST > #RANGE#0OPEN and #RANGE#0HIGH <= #RANGE#1LOW and (#RANGE#0LAST - #RANGE#0OPEN)  < (#RANGE#1OPEN - #RANGE#1LAST)  and (#RANGE#0LAST - #RANGE#0OPEN)  < (#RANGE#2OPEN - #RANGE#2LAST)",
                                    @"#RANGE#2NEW_HI#TIME# and #RANGE#2LAST > #RANGE#2OPEN and #RANGE#1HIGH <= #RANGE#2HIGH and #RANGE#1LOW >= #RANGE#2LOW and #RANGE#1OPEN > #RANGE#1LAST and (#RANGE#0OPEN - #RANGE#0LAST)  > #RANGE#1LAST * #PARAM# and #RANGE#0LAST <= #RANGE#2LOW", nil];
    self.moreOptionIconsEquation= [[NSArray alloc] initWithObjects:
                                   @"(#RANGE#0LAST - #RANGE#0OPEN)> #RANGE#1LAST * #LONGPARAM2# ",
                                   @"(#RANGE#0HIGH / #RANGE#0LAST)< #TWOPARAM# and #RANGE#0LAST >= #RANGE#0OPEN and(#RANGE#0OPEN - #RANGE#0LOW) > #RANGE#1LAST * #PARAM# and (#RANGE#1HIGH /#RANGE#1LAST)< #TWOPARAM# and #RANGE#1LAST > #RANGE#1OPEN and (#RANGE#1OPEN - #RANGE#1LOW) >#RANGE#2LAST * #PARAM#",
                                   @"#MorningStar#",
                                   @"#RED3#",
                                   @"(#RANGE#0LAST - #RANGE#0OPEN) > #RANGE#1LAST * #PARAM# and #RANGE#1OPEN > #RANGE#1LAST and (#RANGE#2LAST - #RANGE#2OPEN ) > #RANGE#3LAST * #PARAM# and #RANGE#0LAST > #RANGE#1OPEN and #RANGE#0OPEN < #RANGE#1LAST and #RANGE#1OPEN < #RANGE#2LAST and #RANGE#1LAST > #RANGE#2OPEN",
                                   @"#BULL3CUBS#",
                                   @"#RANGE#1NEW_LO#TIME# and #RANGE#0LOW > #RANGE#1HIGH * 1.02 and #RANGE#2LOW > #RANGE#1HIGH * 1.02",
                                   @"MAX#SPEC1#(#RANGE#1PRC_MA#SPEC2#) / MIN#SPEC1#(#RANGE#1PRC_MA#SPEC2#) < #SPMULT2# and #RANGE#0NEW_HI#SPEC1# and (#RANGE#0LAST - #RANGE#0OPEN)  > #RANGE#1LAST * #PARAM#",
                                   @"#RANGE#0NEW_LO#TIME# and if(#RANGE#0LAST >= #RANGE#0OPEN)then(#RANGE#0OPEN - #RANGE#0LOW)else(#RANGE#0LAST - #RANGE#0LOW)end > #RANGE#1LAST * #LONGHORNPARAM#",
                                   @"#BullBrewing#",
                                   @"#CubStandUp#",
                                   @"#RANGE#2NEW_LO#TIME# and #RANGE#2OPEN > #RANGE#2LAST and #RANGE#1HIGH <= #RANGE#2HIGH and #RANGE#1LOW >= #RANGE#2LOW and #RANGE#1LAST > #RANGE#1OPEN and (#RANGE#0LAST - #RANGE#0OPEN)  > #RANGE#1LAST * #PARAM# and #RANGE#0LAST >= #RANGE#2HIGH", nil];
}

-(void)goSearch:(int)searchNum
{
    NSArray *sectorsID;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        sectorsID = [NSArray arrayWithObjects:@SECTOR_SHANG_JIAO, @SECTOR_SHEN_JIAO, nil];
    }
    else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        sectorsID = [NSArray arrayWithObjects:@SECTOR_DIAN_TOU, @SECTOR_JI_JHONG, nil];
    }
    else {
        sectorsID = [NSArray arrayWithObjects:@SECTOR_NYSE,@SECTOR_NASDAQ,@SECTOR_AMEX, nil];
    }
    
    UInt8 flag = 0;         // 無特殊需求就設0
    UInt8 sn = 65;          // 隨意定義, 回傳sn會一致
    UInt8 reqCount = 100;   // 預設100
    
    NSString *equation = nil;
    NSString *result = searchViewController.formula;
    _searchType =FigureSearchUSFeeTypePreviousSessionBuildIn;
    
    if(moreOptionButton.selected){
        equation = _moreOptionIconsEquation[searchNum];
    }else if(zeroOptionButton.selected){
        equation = _zeroOptionIconsEquation[searchNum];
    }
    
    result = [searchViewController.formula stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"D0"];

    if([[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"tw"]){
        equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"LAND3(#RANGE#0LAST > #RANGE#0OPEN) and LAND3(#RANGE#0HIGH > #RANGE#1HIGH) and LAND3(#RANGE#0LOW > #RANGE#1LOW)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"LAND3(#RANGE#0OPEN > #RANGE#0LAST) and LAND3(#RANGE#0HIGH < #RANGE#1HIGH) and LAND3(#RANGE#0LOW < #RANGE#1LOW)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LAST) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LAST >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MorningStar#" withString:@"#RANGE#1NEW_LO#TIME# and (#RANGE#0LAST - #RANGE#0OPEN) > #RANGE#1LAST * #PARAM# and #RANGE#0LAST >= #RANGE#2OPEN and #RANGE#0LOW >= #RANGE#1HIGH and (if(#RANGE#1LAST>=#RANGE#1OPEN)then(#RANGE#1LAST - #RANGE#1OPEN)else(#RANGE#1OPEN - #RANGE#1LAST)end/#RANGE#1LAST)< #MULT# and #RANGE#1HIGH <= #RANGE#2LOW and (#RANGE#2OPEN - #RANGE#2LAST) > #RANGE#3LAST * #PARAM#"];
    }else{
        equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"LAND3(#RANGE#0LAST > #RANGE#0OPEN) and LAND3(#RANGE#0HIGH > #RANGE#1HIGH) and LAND3(#RANGE#0LOW > #RANGE#1LOW) and LAND3(#RANGE#0LAST > #RANGE#1LAST)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"LAND3(#RANGE#0OPEN > #RANGE#0LAST) and LAND3(#RANGE#0HIGH < #RANGE#1HIGH) and LAND3(#RANGE#0LOW < #RANGE#1LOW) and LAND3(#RANGE#0LAST < #RANGE#1LAST)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LOW) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LOW >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MorningStar#" withString:@"D1NEW_LO15 and ( D0LAST - D0OPEN ) > D1LAST * 0.020 and D0LAST - D2LAST > ( D2OPEN - D2LAST ) * 0.5 and D0LOW >= D1HIGH * 0.995 and ( if ( D1LAST >= D1OPEN ) then ( D1LAST - D1OPEN ) else ( D1OPEN - D1LAST ) end ) < D1LAST * 0.010 and D1HIGH <= D2LOW * 1.005 and ( D2OPEN - D2LAST ) > D3LAST * 0.020"];
    }
    
    equation = [equation stringByReplacingOccurrencesOfString:@"#BULL3CUBS#" withString:@"LAND3(#RANGE#1OPEN >= #RANGE#1LAST )and #RANGE#0LAST > #RANGE#0OPEN and #RANGE#0LAST >= MAX3(#RANGE#1OPEN) and #RANGE#0OPEN <= MIN3(#RANGE#1LAST)"];

    equation = [equation stringByReplacingOccurrencesOfString:@"#BEAR3CALVES#" withString:@"LAND3(#RANGE#1LAST >= #RANGE#1OPEN ) and #RANGE#0OPEN > #RANGE#0LAST and #RANGE#0OPEN >= MAX3(#RANGE#1LAST) and #RANGE#0LAST <= MIN3(#RANGE#1OPEN)"];
    
    equation = [equation stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"D"];
    equation = [equation stringByReplacingOccurrencesOfString:@"#PARAM#" withString:NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM2#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Day_2", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM2#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Day_2", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#TWOPARAM#" withString:NSLocalizedStringFromTable(@"TWOPARAM_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#TIME#" withString:NSLocalizedStringFromTable(@"TIME_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#MULT#" withString:NSLocalizedStringFromTable(@"MULT_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT#" withString:NSLocalizedStringFromTable(@"SPMULT_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT2#" withString:NSLocalizedStringFromTable(@"SPMULT_Day_2", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC1#" withString:NSLocalizedStringFromTable(@"SPEC1_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC2#" withString:NSLocalizedStringFromTable(@"SPEC2_Day", @"FigureSearchFormula", nil)];
    
    equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDPARAM#" withString:NSLocalizedStringFromTable(@"TRENDPARAM_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#MONTRENDPARAM#" withString:NSLocalizedStringFromTable(@"MONTRENDPARAM_Day", @"FigureSearchFormula", nil)];
    equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDSPEC1#" withString:NSLocalizedStringFromTable(@"TRENDSPEC1_Day", @"FigureSearchFormula", nil)];
    
    
    if(result.length>0){
        equation = [NSString stringWithFormat:@"%@ and %@",equation, result];
    }
    
    [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"EOD搜尋中", @"FigureSearch", nil)];
    // 查詢
    
    [_figureSearchUS searchByType:_searchType
                        sectorIDs:sectorsID
                             flag:flag
                               sn:sn
                         reqCount:reqCount
                   equationString:equation];
//    NSLog(@"%@", equation);
}

- (void)callBackResultEquationName:(NSString *)equationName targetMarket:(NSString *)targetMarket dataAmount:(int)dataAmount totalAmount:(int)totalAmount dataDate:(UInt16)date dataArray:(NSArray *)dataArray markPriceArray:(NSArray *)markPriceArray{
    [self.view hideHUD];
    
    self.resultEquationName = equationName;
    self.resultTargetMarket = targetMarket;
    self.resultTotalAmount = totalAmount;
    self.resultDataDate = [[NSNumber numberWithInt:date]uint16ToDate];
    NSMutableArray * topDataArray = [[NSMutableArray alloc]init];
    NSMutableArray * topPriceArray = [[NSMutableArray alloc]init];
    if (totalAmount >100){
        self.resultDataAmount = 100;
        for (int i=0; i<100; i++) {
            [topDataArray addObject:[dataArray objectAtIndex:i]];
            [topPriceArray addObject:[markPriceArray objectAtIndex:i]];
        }
        self.resultDataArray =[[NSArray alloc]initWithArray:topDataArray];
        self.resultMarkPriceArray =[[NSArray alloc]initWithArray:topPriceArray];
    }else{
        self.resultDataAmount = dataAmount;
        self.resultDataArray =[[NSArray alloc]initWithArray:dataArray];
        self.resultMarkPriceArray =[[NSArray alloc]initWithArray:markPriceArray];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * searchdate  = [dateFormatter stringFromDate:self.resultDataDate];
    NSDate *currentDate = [dateFormatter dateFromString:searchdate];
    NSString * searchName;
    
    searchName = @"Day";
    self.opportunity = NSLocalizedStringFromTable(@"盤後", @"FigureSearch", nil);
    [_customModel editFigureSearchResultInfoWithFigureSearchId:[NSNumber numberWithInt:_figureSearchID] RangeType:searchName SearchDate:currentDate SearchRange:_resultTargetMarket Total:[NSNumber numberWithInt:_resultTotalAmount] SearchType:self.opportunity];
    
    if (_resultTotalAmount == 0){
        return;   // 沒有符合的stock, 故不進入搜尋結果
    }
    
    NSMutableArray * data = [_customModel searchLastResultWithFigureSearchId:[NSNumber numberWithInt:_figureSearchID] Range:searchName SearchType:self.opportunity];
    [_customModel editFigureSearchResultDataWithFigureSearchResultInfoId:[data objectAtIndex:0] DataArray:_resultDataArray MarkPriceArray:_resultMarkPriceArray];
    
    FigureSearchResultViewController * resultView = [[FigureSearchResultViewController alloc]initWithFigureSearchId:[NSNumber numberWithInt:_figureSearchID] FuctionName:_figureSearchName conditionName:_figureSearchName searchGroup:searchName datetime:currentDate Opportunity:self.opportunity targetMarket:_resultTargetMarket totalAmount:_resultTotalAmount displayAmount:_resultDataAmount dataArray:_resultDataArray markPriceArray:_resultMarkPriceArray];
    [self.navigationController pushViewController:resultView animated:NO];
    
//    NSString *alertBodyMsgPatten;
//    NSString *alertBodyMsg;
    
//    if (totalAmount > self.resultDataAmount) {
//        alertBodyMsgPatten = NSLocalizedStringFromTable(@"搜尋到%d筆資料!僅顯示%d筆.", @"FigureSearch", nil);
//        alertBodyMsg = [NSString stringWithFormat:alertBodyMsgPatten, totalAmount, self.resultDataAmount];
//    } else {
//        alertBodyMsgPatten = NSLocalizedStringFromTable(@"搜尋到%d筆資料!", @"FigureSearch", nil);
//        alertBodyMsg = [NSString stringWithFormat:alertBodyMsgPatten, totalAmount];
//    }
//    
//    self.resultAlert = [[UIAlertView alloc]initWithTitle:nil message:alertBodyMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil),nil];
//    
//    
//    [_resultAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if ([alertView isEqual:_resultAlert]){
//        if (buttonIndex == 0) { // 確認
//
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//            NSString * date  = [dateFormatter stringFromDate:self.resultDataDate];
//            NSDate *currentDate = [dateFormatter dateFromString:date];
//            NSString * searchName;
//
//            searchName = @"Day";
//            self.opportunity = NSLocalizedStringFromTable(@"盤後", @"FigureSearch", nil);
//            [_customModel editFigureSearchResultInfoWithFigureSearchId:[NSNumber numberWithInt:_figureSearchID] RangeType:searchName SearchDate:currentDate SearchRange:_resultTargetMarket Total:[NSNumber numberWithInt:_resultTotalAmount] SearchType:self.opportunity];
//            
//            if (_resultTotalAmount == 0){
//                return;   // 沒有符合的stock, 故不進入搜尋結果
//            }
//            
//            NSMutableArray * data = [_customModel searchLastResultWithFigureSearchId:[NSNumber numberWithInt:_figureSearchID] Range:searchName SearchType:self.opportunity];
//            [_customModel editFigureSearchResultDataWithFigureSearchResultInfoId:[data objectAtIndex:0] DataArray:_resultDataArray MarkPriceArray:_resultMarkPriceArray];
//            
//            FigureSearchResultViewController * resultView = [[FigureSearchResultViewController alloc]initWithFigureSearchId:[NSNumber numberWithInt:_figureSearchID] FuctionName:_figureSearchName conditionName:_figureSearchName searchGroup:searchName datetime:currentDate Opportunity:self.opportunity targetMarket:_resultTargetMarket totalAmount:_resultTotalAmount displayAmount:_resultDataAmount dataArray:_resultDataArray markPriceArray:_resultMarkPriceArray];
//            [self.navigationController pushViewController:resultView animated:NO];
//        }
//    }else if([alertView isEqual:_searchAlert]){
//        if (buttonIndex==1) {
//            
//        }
//    }
}
@end
