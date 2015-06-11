//
//  FSMainBargainingChipViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainBargainingChipViewController.h"
#import "SKCustomTableView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSMainBargainingChipOut.h"
#import "FSEmergingObject.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"



@interface FSMainBargainingChipViewController ()<SKCustomTableViewDelegate, UIActionSheetDelegate, DataArriveProtocol>{

    NSMutableArray *tableViewTitle;
    NSMutableArray *actionSheetTitle;
    UIActionSheet *actionSheet;
    UIView *dateView;
    UILabel *duringData;
    UILabel *recentlyDateOf;
    
    FSUIButton *todayBtn;
    FSUIButton *fiveDaysBtn;
    FSUIButton *tenDaysBtn;
    FSUIButton *twentyDaysBtn;
    FSUIButton *confirmBtn;
    
    FSUIButton *dateBtn;
    FSUIButton *actionSheetBtn;
    SKCustomTableView *mainTableView;
    
    FSDataModelProc *dataModel;
    FSMainBargainingChip *bargainingChip;

    NSString *todayStr;
    
    NSMutableArray *fromMainBargainingIn;
    int dataType;
    int pickDays;
    NSString *startDateStr;
    BOOL firstLogin;
    
}

@end

@implementation FSMainBargainingChipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initVar];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];


}

-(void)initView{
    firstLogin = YES;
    pickDays = 1;
    dataType = 0;
    FSMainBargainingChipOut *chipPacket = [[FSMainBargainingChipOut alloc]initWithDays:1 SortType:0];
    [FSDataModelProc sendData:self WithPacket:chipPacket];
//    [self loadStartDate];
    
    
    dataModel = [FSDataModelProc sharedInstance];
    [dataModel.mainBargaining setTarget:self];
    
    bargainingChip = [[FSMainBargainingChip alloc]init];

    [self setUpImageBackButton];

    
    self.title = @"主力籌碼";
    
    dateBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    dateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [dateBtn setTag:1];
    [dateBtn setTitle:@" " forState:UIControlStateNormal];
    [dateBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dateBtn];
    
    actionSheetBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    actionSheetBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [actionSheetBtn setTag:2];
    [actionSheetBtn setTitle:@"集中度" forState:UIControlStateNormal];
    [actionSheetBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionSheetBtn];
    
    mainTableView = [[SKCustomTableView alloc]initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    [self.view addSubview:mainTableView];
    [self.view showHUDWithTitle:@"資料讀取中，請稍後"];

    
//  dateView
    
    dateView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    dateView.backgroundColor = [UIColor whiteColor];
    dateView.hidden = YES;
    [self.view addSubview:dateView];
    
    duringData = [[UILabel alloc]init];
    duringData.text = @"選擇資料期間";
    duringData.textAlignment = NSTextAlignmentCenter;
    duringData.backgroundColor = [UIColor clearColor];
    duringData.textColor = [UIColor brownColor];
    duringData.font = [UIFont systemFontOfSize:22.0f];
    duringData.translatesAutoresizingMaskIntoConstraints = NO;
    [dateView addSubview:duringData];
    
    recentlyDateOf = [[UILabel alloc]init];
    recentlyDateOf.text =@"由最近日期算起1天內";
    recentlyDateOf.textAlignment = NSTextAlignmentLeft;
    recentlyDateOf.backgroundColor = [UIColor clearColor];
    recentlyDateOf.textColor = [UIColor brownColor];
    recentlyDateOf.font = [UIFont systemFontOfSize:22.0f];
    recentlyDateOf.translatesAutoresizingMaskIntoConstraints = NO;
    [dateView addSubview:recentlyDateOf];
    
    todayBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    todayBtn.translatesAutoresizingMaskIntoConstraints = NO;
    todayBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [todayBtn setTag:3];
    [todayBtn setTitle:@"當日" forState:UIControlStateNormal];
    [todayBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [dateView addSubview:todayBtn];
    
    fiveDaysBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    fiveDaysBtn.translatesAutoresizingMaskIntoConstraints = NO;
    fiveDaysBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [fiveDaysBtn setTag:4];
    [fiveDaysBtn setTitle:@"5日" forState:UIControlStateNormal];
    [fiveDaysBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [dateView addSubview:fiveDaysBtn];
    
    tenDaysBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    tenDaysBtn.translatesAutoresizingMaskIntoConstraints = NO;
    tenDaysBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [tenDaysBtn setTag:5];
    [tenDaysBtn setTitle:@"10日" forState:UIControlStateNormal];
    [tenDaysBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [dateView addSubview:tenDaysBtn];
    
    twentyDaysBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    twentyDaysBtn.translatesAutoresizingMaskIntoConstraints = NO;
    twentyDaysBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [twentyDaysBtn setTag:6];
    [twentyDaysBtn setTitle:@"20日" forState:UIControlStateNormal];
    [twentyDaysBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [dateView addSubview:twentyDaysBtn];
    
    confirmBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [confirmBtn setTag:7];
    [confirmBtn setTitle:@"確定" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [dateView addSubview:confirmBtn];

    [self.view setNeedsUpdateConstraints];
}

-(void)initVar{
    tableViewTitle = [[NSMutableArray alloc]initWithObjects:@"成交均價", @"日均量", @"集中度", @"漲幅", nil];
    actionSheetTitle = [[NSMutableArray alloc]initWithObjects:@"集中度", @"多空比", @"高週轉", @"振盪", @"爆大量", @"公行買超", @"公行賣超", @"法人買超", @"法人賣超", nil];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];

    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *mainViewArray = NSDictionaryOfVariableBindings(dateBtn, actionSheetBtn, mainTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[dateBtn]-2-[actionSheetBtn(100)]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:mainViewArray]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[dateBtn]-2-[mainTableView]|" options:0 metrics:nil views:mainViewArray]];
    
    [self replaceCustomizeConstraints:constraints];
    
}

-(void)update_DateView{

    NSMutableArray *dateConstraints = [[NSMutableArray alloc]init];
    NSDictionary *dateViewArray = NSDictionaryOfVariableBindings(duringData, recentlyDateOf, todayBtn, fiveDaysBtn, tenDaysBtn, twentyDaysBtn, confirmBtn);
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[duringData]|" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[recentlyDateOf]|" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[todayBtn][fiveDaysBtn(todayBtn)][tenDaysBtn(fiveDaysBtn)][twentyDaysBtn(tenDaysBtn)]|" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[confirmBtn]-60-|" options:0 metrics:nil views:dateViewArray]];
    
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[duringData][recentlyDateOf][todayBtn]-5-[confirmBtn]" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[duringData][recentlyDateOf][fiveDaysBtn]" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[duringData][recentlyDateOf][tenDaysBtn]" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[duringData][recentlyDateOf][twentyDaysBtn]" options:0 metrics:nil views:dateViewArray]];
    
    [self replaceCustomizeConstraints:dateConstraints];
    
}

-(void)btnHandler:(UIButton *)sender{

    todayBtn.selected = NO;
    fiveDaysBtn.selected = NO;
    tenDaysBtn.selected = NO;
    twentyDaysBtn.selected = NO;
    confirmBtn.selected = NO;
    sender.selected = YES;
    
    if (sender.tag == 1) {
        dateView.hidden = NO;
        switch (pickDays) {
            case 1:
                todayBtn.selected = YES;
                break;
            case 5:
                fiveDaysBtn.selected = YES;
                break;
            case 10:
                tenDaysBtn.selected = YES;
                break;
            case 20:
                twentyDaysBtn.selected = YES;
                break;
            default:
                break;
        }
        [self.navigationController setNavigationBarHidden:YES];
        [self update_DateView];

    }else if(sender.tag == 2){
        actionSheet = [[UIActionSheet alloc]initWithTitle:@"主力籌碼" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        int i;
        for (i = 0; i <[actionSheetTitle count]; i++){
            NSString *title = [actionSheetTitle objectAtIndex:i];
            [actionSheet addButtonWithTitle:title];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        [actionSheet setCancelButtonIndex:i];
        [actionSheet showInView:self.view];
    }else if (sender.tag == 3){
        recentlyDateOf.text =@"由最近日期算起1天內";
        pickDays = 1;
    }else if (sender.tag == 4){
        recentlyDateOf.text =@"由最近日期算起5天內";
        pickDays = 5;
    }else if (sender.tag == 5){
        recentlyDateOf.text =@"由最近日期算起10天內";
        pickDays = 10;
    }else if (sender.tag == 6){
        recentlyDateOf.text =@"由最近日期算起20天內";
        pickDays = 20;

    }else{
        [self.view showHUDWithTitle:@"資料讀取中，請稍後"];
        dateView.hidden = YES;
        dateBtn.selected = NO;
        [self sendSocketWithDays:pickDays :dataType];
        
        [self.navigationController setNavigationBarHidden:NO];
    }
}
//- (NSString *)accumulativeDateLabelTextByPeriod:(NSUInteger) days
//{
//
//    NSDate *today = [NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSDateComponents *components = [[NSDateComponents alloc]init];
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    
//    switch(days) {
//        case 5:
//            [components setDay:-5];
//            break;
//        case 10:
//            [components setDay:-10];
//            break;
//        case 20:
//            [components setDay:-20];
//            break;
//    }
//    NSDate *pastDate = [gregorian dateByAddingComponents:components toDate:today options:0];
// 
//    NSUInteger units = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
//
//    NSDateComponents *com=[gregorian components:units fromDate:pastDate toDate:today options:0];
//    NSInteger day1=[com day];
//    int i=0;
//    int j=0;
//    
//    for(i=0; i<=day1; i++)
//    {
//        com = [[NSDateComponents alloc]init];
//        [com setDay:-i];
//        NSDate *newDate = [[NSCalendar currentCalendar]
//                           dateByAddingComponents:com
//                           toDate:today options:0];
//        [dateFormatter setDateFormat:@"EEE"];
//        NSString *satSun=[dateFormatter stringFromDate:newDate];
//        if ([satSun isEqualToString:@"Sat"] || [satSun isEqualToString:@"Sun"])
//        {
//            j++;
//            
//        }
//    }
//    if (days == 5) {
//        [com setDay:-5-j];
//    }else if (days == 10){
//        [com setDay:-10-j];
//    }else{
//        [com setDay:-20-j];
//    }
//    NSDate *pastDatec = [gregorian dateByAddingComponents:com toDate:today options:0];
//    
//    
//    
//    
//    [dateFormatter setDateFormat:@"YYYYMMdd"];
//    NSString *pastDateStringc = [dateFormatter stringFromDate:pastDatec];
//    
//    NSString *dateString = [NSString stringWithFormat:@"%@-%@", pastDateStringc, todayStr];
//    
//    return dateString;
//}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex < [actionSheetTitle count]) {
        [fromMainBargainingIn removeAllObjects];
        
        dataType = (int)buttonIndex;
        [actionSheetBtn setTitle:[actionSheetTitle objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        NSString *changeTableViewTitle = [actionSheetTitle objectAtIndex:buttonIndex];
        [tableViewTitle replaceObjectAtIndex:2 withObject:changeTableViewTitle];
        [self sendSocketWithDays:pickDays :buttonIndex];
        [self.view showHUDWithTitle:@""];
    }
}
-(void)notifyDataArrive:(NSMutableArray *)array{
    fromMainBargainingIn = [NSMutableArray arrayWithArray:array];

    [self loadRequestDate];
    [mainTableView reloadDataNoOffset];
    [self.view hideHUD];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fromMainBargainingIn count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    bargainingChip = [fromMainBargainingIn objectAtIndex:indexPath.row];

    label.text = bargainingChip.symbol -> fullName;
    
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor blueColor];
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    bargainingChip = [fromMainBargainingIn objectAtIndex:indexPath.row];
    FSEmergingObject *fsemObj = [[FSEmergingObject alloc]init];
    switch (columnIndex) {
        case 0:
            label.text = [NSString stringWithFormat:@"%.2f", floor(bargainingChip.avgPrice.calcValue * 100) / 100];
            if (bargainingChip.avgPrice.calcValue == 0) {
                label.text = [NSString stringWithFormat:@"----"];
            }
            label.textColor = [fsemObj compareToZero:bargainingChip.changePercentage.calcValue];

            break;
        case 1:
            label.text = [NSString stringWithFormat:@"%.f", bargainingChip.avgVolume.calcValue];
            label.textColor = [UIColor purpleColor];
            break;
        case 2:
            label.textColor = [UIColor blackColor];
//            集中度, 多空比 || 爆大量
            if (bargainingChip.dataType < 2 || bargainingChip.dataType == 4) {
                label.text = [NSString stringWithFormat:@"%.2f", floor(bargainingChip.data.calcValue * 100) / 100];
//                高週轉, 振盪
            }else if (bargainingChip.dataType == 2 || bargainingChip.dataType == 3){
                label.text = [NSString stringWithFormat:@"%.2f%%", floor(bargainingChip.data.calcValue * 100) / 100];

            }else{
                label.text = [CodingUtil stringWithMergedRevenueByValue:bargainingChip.data.calcValue Sign:YES];
                label.textColor = [fsemObj compareToZero:bargainingChip.data.calcValue];
            }
            break;
        case 3:
            if (bargainingChip.changePercentage.calcValue == 0) {
                label.text = [NSString stringWithFormat:@"0.00%%"];
            }else if(bargainingChip.changePercentage.calcValue > 0){
                label.text = [NSString stringWithFormat:@"+%.2f%%", bargainingChip.changePercentage.calcValue * 100];
            }else{
                label.text = [NSString stringWithFormat:@"%.2f%%", bargainingChip.changePercentage.calcValue * 100];
            }
            label.textColor = [fsemObj compareToZero:bargainingChip.changePercentage.calcValue];
            break;
        default:
            break;
    }    
}

-(NSArray *)columnsInFixedTableView{
    return @[(@"股名")];
}
-(NSArray *)columnsInMainTableView{
    return tableViewTitle;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    bargainingChip = [fromMainBargainingIn objectAtIndex:indexPath.row];
    
    [dataModel.securitySearchModel setTarget:self];
    [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModel.thread withObject:bargainingChip.symbol -> symbol waitUntilDone:NO];
}
-(void)notifyArrive:(NSMutableArray *)dataArray{
    if ([dataArray count] > 2) {
        FSMainViewController *mainView = [[FSMainViewController alloc]init];
        NSString *identCodeSymbol = [NSString stringWithFormat:@"%@ %@",[[dataArray objectAtIndex:2] objectAtIndex:0], [[dataArray objectAtIndex:1] objectAtIndex:0]];
        [dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[identCodeSymbol]];
        
        PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
        FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        
        instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
        
        mainView.firstLevelMenuOption = 3;
//        mainView.
        [self.navigationController pushViewController:mainView animated:NO];
    }else{
        [dataModel.securitySearchModel setTarget:self];
        [dataModel.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModel.thread withObject:bargainingChip.symbol -> fullName waitUntilDone:NO];
    }
}

-(void)sendSocketWithDays:(UInt8)Days :(UInt8)sortType {
    FSMainBargainingChipOut *chipPacket = [[FSMainBargainingChipOut alloc]initWithDays:Days SortType:sortType];
    [FSDataModelProc sendData:self WithPacket:chipPacket];
}

-(void)loadRequestDate{
    if (firstLogin) {
        bargainingChip = [fromMainBargainingIn objectAtIndex:0];
        NSString *startDateStrTmp = [CodingUtil getStringDatePlusZero:bargainingChip.startDate];
        startDateStr = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
        [dateBtn setTitle:[NSString stringWithFormat:@"%@", startDateStr] forState:UIControlStateNormal];
        firstLogin = NO;
    }else{
        bargainingChip = [fromMainBargainingIn objectAtIndex:0];
        NSString *startDateStrTmp = [CodingUtil getStringDatePlusZero:bargainingChip.startDate];
        NSString *endDateStrTmp = [CodingUtil getStringDatePlusZero:bargainingChip.endDate];
        startDateStr = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
        NSString *endDateStr = [endDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
        if (pickDays == 1) {
            [dateBtn setTitle:[NSString stringWithFormat:@"%@", startDateStr] forState:UIControlStateNormal];
        }else{
            [dateBtn setTitle:[NSString stringWithFormat:@"%@-%@",startDateStr, endDateStr] forState:UIControlStateNormal];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
