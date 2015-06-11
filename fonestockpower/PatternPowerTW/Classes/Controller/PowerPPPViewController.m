//
//  PowerPPPViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "PowerPPPViewController.h"
#import "UITableView+iOS7Separator.h"
#import "PowerPPPOut.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSPowerSeriesObject.h"
#import "PowerPPPTableViewCell.h"
#import "FSMainPlusDateRangeViewController.h"

#define mainTableViewHeaderBackgroundColor [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0]

@interface PowerPPPViewController ()<UITableViewDataSource, UITableViewDelegate, FSPowerSeriesDelegate, UITextFieldDelegate>
{
    FSDataModelProc *dataModel;
    
    UITableView *leftTView;
    UITableView *rightTView;

    FSUIButton *selectDateBtn;
    UILabel *targetPriceLbl;
    UIButton *targetPriceBtn;

    PortfolioItem *item;
    
    BOOL isAlertBeClicked;
    UIAlertView *aViewFromClickLabel;
    UIAlertView *aViewFromQueryNoData;
    
    BOOL isWaitingForServer;
    
    UIScrollView *beingScrolled;
    bool whichOneIsBigger;//yes leftTView的個數比較多，反之RightTView
    
    //欲當作條件上傳給server 的項目
    UInt16 startDate;
    UInt16 endDate;
    CGFloat price;
    int days;
    int countsForOut;
    //取得搜尋條件之一：價格，所需要的全域變數
    EquitySnapshotDecompressed *mySnapshot;
    
    
    int quieryTooManyTimes;
}
@end

@implementation PowerPPPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initView];
    [self.view setNeedsUpdateConstraints];
    quieryTooManyTimes = 1;
//    NSLog(@"___________ %d",self.parentViewController.interfaceOrientation);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isWaitingForServer = YES;
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *compsStart = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dataModel.cyqModel.startDate];
//    int yearStart = [compsStart year];
//    int monthStart = [compsStart month];
//    int dayStart = [compsStart day];
//    NSDateComponents *compsEnd = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dataModel.cyqModel.endDate];
//    int yearEnd = [compsEnd year];
//    int monthEnd = [compsEnd month];
//    int dayEnd = [compsEnd day];
    
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"YYYYMMdd"];
    NSDateFormatter *dateFormate1 = [[NSDateFormatter alloc] init];
    [dateFormate1 setDateFormat:@"YYYY-MM-dd"];
    
    NSString *forBtnTitle;
    if(dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeRecently){
        
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
    quieryTooManyTimes = 1;
    isAlertBeClicked = NO;
    [self sendDataToServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    isWaitingForServer = YES;
    item = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    dataModel = [FSDataModelProc sharedInstance];
    dataModel.powerSeriesObject.delegate = self;
    
    self.view.backgroundColor = [UIColor grayColor];
    
    leftTView = [[UITableView alloc] init];
    leftTView.translatesAutoresizingMaskIntoConstraints = NO;
    leftTView.dataSource = self;
    leftTView.delegate = self;
    leftTView.bounces = NO;
    leftTView.showsHorizontalScrollIndicator = NO;
    leftTView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:leftTView];
    
    rightTView = [[UITableView alloc] init];
    rightTView.translatesAutoresizingMaskIntoConstraints = NO;
    rightTView.dataSource = self;
    rightTView.delegate = self;
    rightTView.bounces = NO;
    rightTView.showsHorizontalScrollIndicator = NO;
    rightTView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:rightTView];
    
    selectDateBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    days = 1;
    [self getYesterday];
    [selectDateBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    selectDateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    selectDateBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:selectDateBtn];

    mySnapshot = [dataModel.portfolioTickBank getSnapshotFromIdentCodeSymbol:[NSString stringWithFormat:@"%s %@",item->identCode,item->symbol]];
    
    targetPriceBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [targetPriceBtn setTitle:[NSString stringWithFormat:@"%.1f",mySnapshot.currentPrice] forState:UIControlStateNormal] ;
    targetPriceBtn.enabled = !isWaitingForServer;
    [targetPriceBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    targetPriceBtn.translatesAutoresizingMaskIntoConstraints = NO;
    targetPriceBtn.backgroundColor = [UIColor whiteColor];
    targetPriceBtn.layer.borderColor = [UIColor grayColor].CGColor;
    targetPriceBtn.layer.borderWidth = 0.5;
    [self.view addSubview:targetPriceBtn];
    
//    [self.view addSubview:targetPriceLbl];
    price = mySnapshot.currentPrice;
//    startDate = [CodingUtil makeDateFromDate:[NSDate date]];
//    endDate = [CodingUtil makeDateFromDate:[NSDate date]];
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

#pragma mark -
#pragma mark 上行電文
-(void)sendDataToServer
{
    targetPriceBtn.enabled = !isWaitingForServer;
    countsForOut = 20;
    UInt16 ui16 = (UInt16)[NSString stringWithFormat:@"%c%c",item->identCode[0],item->identCode[1]];
    PowerPPPOut *ppp = [[PowerPPPOut alloc] initWithPowerPPP:ui16 :item->symbol :price*100 :days :startDate :endDate :countsForOut];
    NSDate *now = [[NSDate alloc] init];
    [now uint16Value];
    [FSDataModelProc sendData:self WithPacket:ppp];
    
//    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString* cachePath = [cachePathArray lastObject];
//    NSLog(@"%@",cachePath );
}

-(void)btnClicked:(id)sender
{
    if([sender isMemberOfClass:[FSUIButton class]]){
        //call another view which has a calendar
        FSMainPlusDateRangeViewController *mpdr = [[FSMainPlusDateRangeViewController alloc] init];
        [self.navigationController pushViewController:mpdr animated:NO];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更改價格" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"確定", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//        [[alert textFieldAtIndex:0] setPlaceholder:@"1234"]; //設定類似註解的文字
        [[alert textFieldAtIndex:0] setText:[NSString stringWithFormat:@"%.1f",price]];
        [alert textFieldAtIndex:0].userInteractionEnabled = YES;
        [[alert textFieldAtIndex:0] canBecomeFirstResponder];
        [alert textFieldAtIndex:0].tag = 111;
        [alert show];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 111) {
        return NO;
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if(aViewFromQueryNoData.visible) return;
    if(![[alertView textFieldAtIndex:0].text intValue] && !aViewFromQueryNoData.visible){
        aViewFromClickLabel = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%.1f",price] message:nil delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
        [aViewFromClickLabel show];
        return ;
    }
    [targetPriceBtn setTitle:[alertView textFieldAtIndex:0].text forState:UIControlStateNormal] ;
    price = [(NSNumber *)[alertView textFieldAtIndex:0].text floatValue];
    quieryTooManyTimes = 1;
    isAlertBeClicked = YES;
    isWaitingForServer = YES;
    [self sendDataToServer];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(leftTView, rightTView, selectDateBtn, targetPriceBtn);//targetPriceLbl);
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectDateBtn][leftTView]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selectDateBtn][targetPriceBtn(90)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[targetPriceBtn(selectDateBtn)]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftTView]-1-[rightTView(leftTView)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rightTView]|" options:0 metrics:nil views:allObj]];
    
    [self replaceCustomizeConstraints:constraints];
}

#pragma -
#pragma mark About Scrolling two tableViews
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIScrollView *otherView = (scrollView == leftTView)? rightTView : leftTView;
    [otherView setContentOffset:[scrollView contentOffset] animated:NO];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    beingScrolled = nil;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(beingScrolled == nil) beingScrolled = scrollView;
}

#pragma mark -
#pragma mark TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.buyBrokerBranchNameAndValue.count >= self.sellBrokerBranchNameAndValue.count?self.buyBrokerBranchNameAndValue.count:self.sellBrokerBranchNameAndValue.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 37;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath %@ %d", tableView, (int)indexPath.row);
    //在Android 那邊，按下cell 會跳回技術頁，但是目前我們沒有動作
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableHeaderIdentifier = @"headerIdentifier";
    PowerPPPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableHeaderIdentifier];
    if(cell == nil){
        if(tableView == leftTView){
            cell = [[PowerPPPTableViewCell alloc] initWithLStyle:UITableViewCellStyleDefault reuseIdentifier:tableHeaderIdentifier];
        }else{
            cell = [[PowerPPPTableViewCell alloc] initWithRStyle:UITableViewCellStyleDefault reuseIdentifier:tableHeaderIdentifier];
        }
    }
    if(tableView == leftTView){
        //左邊tableView 的內容
        NSInteger indexCount = [self theReturnRowNum:tableView :indexPath.row];
        if(indexCount == -1) {[self doEmptyCell:cell]; return cell;}
        StoreBuyFormat *sbf = [self.buyBrokerBranchNameAndValue objectAtIndex:indexCount];
        cell.mainLbl.text = sbf->brokerBranchId;
        cell.subLbl.text = [NSString stringWithFormat:@"+%d",sbf->value];
    }else{
        //右邊tableView 的內容
        NSInteger indexCount = [self theReturnRowNum:tableView :indexPath.row];
        if(indexCount == -1) {[self doEmptyCell:cell]; return cell;}
        StoreSellFormat *ssf = [self.sellBrokerBranchNameAndValue objectAtIndex:indexCount];
        cell.mainLbl.text = ssf->brokerBranchId;
        cell.subLbl.text = [NSString stringWithFormat:@"%d",ssf->value];
    }
    targetPriceBtn.enabled = !isWaitingForServer;
    return cell;
}

//讓兩個tableView的cell 數量相同
-(NSInteger)theReturnRowNum:(UITableView *)tv :(NSInteger)sender
{
    NSInteger counts = 0;
    if((tv == leftTView && sender >= self.buyBrokerBranchNameAndValue.count - 1) || (tv == rightTView && sender >= self.sellBrokerBranchNameAndValue.count - 1)){
        if(whichOneIsBigger && tv == leftTView){
            if(sender <= self.buyBrokerBranchNameAndValue.count -1)
                counts = sender;
            else
                counts = -1;
        }else if(!whichOneIsBigger && tv == leftTView){
            counts = -1;//self.buyBrokerBranchNameAndValue.count - 1;
        }else if(whichOneIsBigger && tv == rightTView){
            counts = -1;//self.sellBrokerBranchNameAndValue.count - 1;
        }else if(!whichOneIsBigger && tv == rightTView){
            if(sender <= self.sellBrokerBranchNameAndValue.count -1)
                counts = sender;
            else
                counts = -1;
        }
    }else{
        counts = sender;
    }
    return counts;
}

//讓cell數量比較少的那個tableView填上的空白內容
-(void)doEmptyCell:(PowerPPPTableViewCell *)cell
{
    cell.mainLbl.text = @"";
    cell.subLbl.text = @"";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerCell = [[UIView alloc] init];
    UILabel *ll = [[UILabel alloc] initWithFrame:headerCell.frame];
    ll.textColor = [UIColor whiteColor];
    ll.textAlignment = NSTextAlignmentCenter;
    ll.font = [UIFont boldSystemFontOfSize:20.0];
    if(tableView == leftTView){
        ll.text = @"買超分點";
    }else{
        ll.text = @"賣超分點";
    }
    
    ll.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [headerCell addSubview:ll];
    headerCell.backgroundColor = mainTableViewHeaderBackgroundColor;
    return headerCell;
    
}

-(void)loadDidFinishWithData:(FSPowerSeriesObject *)data
{
    NSLog(@"price %.1f currentPrice %.1f referencePrice %.1f",price,mySnapshot.currentPrice,mySnapshot.referencePrice);
    //買超分點的資料
//    data.storeBuyBranchIdAndValue
    self.buyBrokerBranchNameAndValue = [NSArray arrayWithArray: data.storeBuyBranchIdAndValue];
    //賣超分點的資料
//    data.storeSellBranchIdAndValue
    self.sellBrokerBranchNameAndValue = [NSArray arrayWithArray:data.storeSellBranchIdAndValue];
    whichOneIsBigger = (self.buyBrokerBranchNameAndValue > self.sellBrokerBranchNameAndValue)? YES : NO;
    if(self.buyBrokerBranchNameAndValue.count == 0 || self.sellBrokerBranchNameAndValue.count == 0){
        if(price == mySnapshot.referencePrice == mySnapshot.currentPrice){
            [self queryNoData:1];
        }else if(quieryTooManyTimes > 2){
            [self queryNoData:2];
            isWaitingForServer = NO;
            targetPriceBtn.enabled = !isWaitingForServer;
        }else{
            quieryTooManyTimes++;
            if(!isAlertBeClicked){
                price = [[NSString stringWithFormat:@"%.2lf",mySnapshot.referencePrice] doubleValue];
            }
            [targetPriceBtn setTitle:[NSString stringWithFormat:@"%.1f",price] forState:UIControlStateNormal];
            [self sendDataToServer];
        }
    }else {
        isWaitingForServer = NO;
        if([[data.dateArray objectAtIndex:0] isEqualToString:[data.dateArray objectAtIndex:1]]){
            NSArray *ar = [[data.dateArray objectAtIndex:0] componentsSeparatedByString:@"/"];
            [selectDateBtn setTitle:[NSString stringWithFormat:@"%@-%@-%@",[ar objectAtIndex:0],[ar objectAtIndex:1],[ar objectAtIndex:2]] forState:UIControlStateNormal];
        }else if(![[data.dateArray objectAtIndex:0] isEqualToString:[data.dateArray objectAtIndex:1]]){
            NSArray *ar = [[data.dateArray objectAtIndex:0] componentsSeparatedByString:@"/"];
            NSArray *ar2 = [[data.dateArray objectAtIndex:1] componentsSeparatedByString:@"/"];
            [selectDateBtn setTitle:[NSString stringWithFormat:@"%@%@%@ - %@%@%@",[ar objectAtIndex:0],[ar objectAtIndex:1],[ar objectAtIndex:2],[ar2 objectAtIndex:0],[ar2 objectAtIndex:1],[ar2 objectAtIndex:2]] forState:UIControlStateNormal];
        }
    }
//    dataModel.cyqModel.startDate = [NSDate date];
//    dataModel.cyqModel.endDate = [NSDate date];
    
    [leftTView reloadData];
    [rightTView reloadData];
    
}

-(void)queryNoData:(NSInteger)num
{
//    if(aViewFromClickLabel.visible) return;
    NSArray *alertString;
    switch(num){
        case 1:
            alertString = [NSArray arrayWithObjects:@"網路異常", @"無法連接伺服器", nil];
            break;
        case 2:
            alertString = [NSArray arrayWithObjects:@"未搜尋到結果", @"請變更搜尋條件", nil];
            break;
        default:
            break;
    }
    aViewFromQueryNoData = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[alertString objectAtIndex:0]] message:[NSString stringWithFormat:@"%@",[alertString objectAtIndex:1]] delegate:nil cancelButtonTitle:@"確認" otherButtonTitles:nil, nil];
    [aViewFromQueryNoData show];
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
