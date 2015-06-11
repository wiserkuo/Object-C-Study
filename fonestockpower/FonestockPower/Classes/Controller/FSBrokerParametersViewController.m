//
//  FSBrokerParametersViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerParametersViewController.h"
#import "FSRadioButtonSet.h"
#import "FSBrokerCustomViewController.h"
#import "FSBrokerInAndOutListModel.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSMainPlusDateRangeViewController.h"
#import "FSMainPlusOut.h"
#import "FSInstantInfoWatchedPortfolio.h"


@interface FSBrokerParametersViewController ()<FSRadioButtonSetDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>{
    
    FSRadioButtonSet *radioBtnControl;
    FSDataModelProc *dataModel;

//    自選券商
    int idx;
    UILabel *titleLabelUp;
    UILabel *titleLabelDown;
    
    UIButton *optionBtn1;
    UIButton *optionBtn2;
    UIButton *countBtn;
    
    UITableView *mainTableView;
    NSMutableArray *tableViewTitle;
    NSMutableArray *selectPoints;
    NSMutableArray *branchNameArray;
    NSMutableArray *brokerAndBranchName;
    NSDictionary *loadDictionary;
    NSString *detailStr;
    
//    買賣主力
    UIView *buyAndSellView;
    UIView *dataDurationView;
    UILabel *secondViewFirstLabel;
    UILabel *secondViewSecondLabelLeft;
    UILabel *secondViewSecondLabelRight;
    FSUIButton *dateBtn;
    NSTimer *timer;
    NSTimer *timer2;

    int sDate;
    int eDate;
    int todayForKLine;
    int endDayForKLine;
    UITableView *secondLTableView;
    UITableView *secondRTableView;

    NSString *symbol;
    UIView *testView;
    UIButton *optionBtnSelected;
    NSMutableArray *brokerNameArray;
    int count;
    BOOL alreadySend;
    NSMutableArray *forTableViewLeft;
    NSMutableArray *forTableViewRight;
    
}

@end

@implementation FSBrokerParametersViewController

-(UICollectionViewFlowLayout *)flowLayout{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    flowLayout.minimumLineSpacing = 20.0f;
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.itemSize = CGSizeMake(80.0f, 40.0f);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 20.0f, 10.0f, 20.0f);
    
    return flowLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initVar];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self loadDB];
    [dataModel.mainBargaining setTarget:self];
    
    if (optionBtnSelected == optionBtn2) {
        [self sendBranchStockToServerWithOptionType:0];
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(showDataTimeOut:) userInfo:nil repeats:NO];
        [self.view showHUDWithTitle:@""];
        alreadySend = NO;
    }
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
    [dataModel.mainBargaining setTarget:nil];
}

-(void)initView{
    self.title = @"主力買賣券商設定";
    [self setUpImageBackButton];
    
//    default
    brokerNameArray = [NSMutableArray new];
    count = 5;
    alreadySend = NO;


    titleLabelUp = [[UILabel alloc]init];
    titleLabelUp.text = @"自選券商";
    titleLabelUp.textColor = [UIColor brownColor];
    titleLabelUp.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabelUp.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:titleLabelUp];
    
    titleLabelDown = [[UILabel alloc]init];
    titleLabelDown.text = @"買賣主力 分點買賣超前";
    titleLabelDown.textColor = [UIColor brownColor];
    titleLabelDown.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabelDown.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:titleLabelDown];
    
    optionBtn1 = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeRadio];
    optionBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:optionBtn1];
    
    optionBtn2 = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeRadio];
    optionBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:optionBtn2];
    
    radioBtnControl = [FSRadioButtonSet new];
    radioBtnControl.delegate = self;
    radioBtnControl.buttons = @[optionBtn1, optionBtn2];
    
    radioBtnControl.selectedIndex = 0;
    
    countBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    countBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [countBtn setTitle:@"5名" forState:UIControlStateNormal];
    [countBtn addTarget:self action:@selector(countBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:countBtn];

    mainTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.layer.borderWidth = 1.0;
    mainTableView.layer.borderColor = [UIColor grayColor].CGColor;

    [self.view addSubview:mainTableView];
    
    dataDurationView = [[UIView alloc]init];
    dataDurationView.hidden = YES;
    dataDurationView.backgroundColor = [UIColor whiteColor];
    dataDurationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dataDurationView];
    
    buyAndSellView = [[UIView alloc]init];
    buyAndSellView.hidden = YES;
    buyAndSellView.backgroundColor = [UIColor grayColor];
    buyAndSellView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:buyAndSellView];

    secondViewFirstLabel = [UILabel new];
    secondViewFirstLabel.text = @"資料期間";
    secondViewFirstLabel.font = [UIFont systemFontOfSize:20.0f];
    secondViewFirstLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [dataDurationView addSubview:secondViewFirstLabel];

    dateBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    dateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [dateBtn setTitle:@"" forState:UIControlStateNormal];
    [dateBtn addTarget:self action:@selector(pushToDateRangeView:) forControlEvents:UIControlEventTouchUpInside];
    [dataDurationView addSubview:dateBtn];

//    secondLTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, buyAndSellView.frame.size.width/2 -1, buyAndSellView.frame.size.height) style:UITableViewStylePlain];
//    secondLTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    secondLTableView = [UITableView new];
    secondLTableView.delegate = self;
    secondLTableView.dataSource = self;
    secondLTableView.bounces = NO;
    secondLTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [secondLTableView setShowsVerticalScrollIndicator:NO];
    [buyAndSellView addSubview:secondLTableView];

//    secondRTableView = [[UITableView alloc]initWithFrame:CGRectMake(buyAndSellView.frame.size.width/2 +1, 0, buyAndSellView.frame.size.width/2 -1, buyAndSellView.frame.size.height) style:UITableViewStylePlain];
//    secondRTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    secondRTableView = [UITableView new];
    secondRTableView.delegate = self;
    secondRTableView.dataSource = self;
    secondRTableView.bounces = NO;
    secondRTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [buyAndSellView addSubview:secondRTableView];
    
    [self.view setNeedsUpdateConstraints];

}

-(void)initVar{

    selectPoints = [NSMutableArray arrayWithObjects:@"1名", @"5名", @"10名", nil];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];

    optionBtnSelected = [radioBtnControl.buttons objectAtIndex:radioBtnControl.selectedIndex];
    NSMutableArray *contraintsArray = [NSMutableArray new];
    NSDictionary *viewContraints = NSDictionaryOfVariableBindings(titleLabelUp, titleLabelDown, optionBtn1, optionBtn2, countBtn, mainTableView, secondViewFirstLabel, dateBtn, dataDurationView, buyAndSellView, secondLTableView, secondRTableView);
    
        
    [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[optionBtn1(30)][titleLabelUp]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
    [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[optionBtn2(30)][titleLabelDown][countBtn(50)]-30-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
    [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[countBtn(35)]" options:0 metrics:nil views:viewContraints]];
    
    if (optionBtnSelected == optionBtn1) {
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewContraints]];
        
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[optionBtn1(30)]-10-[optionBtn2(30)]-10-[mainTableView]|" options:0 metrics:nil views:viewContraints]];
        
    }else{
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dataDurationView]|" options:0 metrics:nil views:viewContraints]];
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[secondViewFirstLabel(100)][dateBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[buyAndSellView]|" options:0 metrics:nil views:viewContraints]];
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[optionBtn1(30)]-10-[optionBtn2(30)]-1-[dataDurationView(35)][buyAndSellView]|" options:0 metrics:nil views:viewContraints]];
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[secondLTableView]-1-[secondRTableView(secondLTableView)]|" options:0 metrics:0 views:viewContraints]];
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dateBtn(35)][secondLTableView]|" options:0 metrics:nil views:viewContraints]];
        [contraintsArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dateBtn(35)][secondRTableView]|" options:0 metrics:nil views:viewContraints]];
    }

    [self replaceCustomizeConstraints:contraintsArray];
    
}

-(void)pushToDateRangeView:(id)sender{
    FSMainPlusDateRangeViewController *dateRange = [FSMainPlusDateRangeViewController new];
    [self.navigationController pushViewController:dateRange animated:NO];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:mainTableView]) {
        return [tableViewTitle count];

    }else{
        return count;
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerCell = [[UIView alloc] init];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:headerCell.frame];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont boldSystemFontOfSize:20.0];
    if([tableView isEqual: secondLTableView]){
        textLabel.text = @"累計買超券商分點";
        textLabel.adjustsFontSizeToFitWidth = YES;
    }else{
        textLabel.text = @"累計賣超券商分點";
        textLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    textLabel.autoresizingMask =  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [headerCell addSubview:textLabel];
    headerCell.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    return headerCell;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:mainTableView]) {

        static NSString *CellIdentifier = @"mainTableViewCell";
        FSBrokerParametersCell *cell = (FSBrokerParametersCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[FSBrokerParametersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.titleLabel.text = [tableViewTitle objectAtIndex:indexPath.row];

        NSMutableString *str1 = [NSMutableString new];
        NSMutableString *str2 = [NSMutableString new];
        NSMutableString *str3 = [NSMutableString new];
        NSMutableString *str4 = [NSMutableString new];
        NSMutableString *str5 = [NSMutableString new];
        for (FSBrokerChoice *brokerChoice in branchNameArray) {
    //        NSMutableArray *arr = [NSMutableArray new];
            
            switch (brokerChoice.groupIndex) {
                case 1:
                    [str1 appendFormat:@"%@, ", brokerChoice.brokerName];
                    break;
                case 2:
                    [str2 appendFormat:@"%@, ", brokerChoice.brokerName];
                    break;
                case 3:
                    [str3 appendFormat:@"%@, ", brokerChoice.brokerName];
                    break;
                case 4:
                    [str4 appendFormat:@"%@, ", brokerChoice.brokerName];
                    break;
                case 5:
                    [str5 appendFormat:@"%@, ", brokerChoice.brokerName];
                    break;
                default:
                    break;
            }
        }
        brokerAndBranchName = [NSMutableArray new];
        [brokerAndBranchName addObject:str1];
        [brokerAndBranchName addObject:str2];
        [brokerAndBranchName addObject:str3];
        [brokerAndBranchName addObject:str4];
        [brokerAndBranchName addObject:str5];

        cell.detailLabel.text = [brokerAndBranchName objectAtIndex:indexPath.row];
//        [cell setNeedsUpdateConstraints];
//        [cell updateConstraintsIfNeeded];
////
//        cell.detailTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(tableView.bounds);
        return cell;
    }else{
        
        FSEmergingObject *fsemObj = [FSEmergingObject new];

        static NSString *CellIdentifiersecL = @"secondTableViewCellL";
        static NSString *CellIdentifiersecR = @"secondTableViewCellR";
        
        if ([tableView isEqual:secondLTableView]) {
//            FSBrokerParametersMainCell *cellL = (FSBrokerParametersMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifiersecL];
//            if (cellL == nil) {
                FSBrokerParametersMainCell *cellL = [[FSBrokerParametersMainCell alloc] initWithLStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifiersecL];
//            }

            if ([forTableViewLeft firstObject] == nil) {
                cellL.mainLbl.text = @"";
                cellL.subLbl.text = @"";
            }else{
                FSBrokerBranchByStock *leftInfo = [forTableViewLeft objectAtIndex:indexPath.row];
                NSString *leftbrokerName = [self loadDBWithBranchName:leftInfo.brokerBranchData.brokerBranchID];
                double leftMinusBuyAndSellShare = leftInfo.brokerBranchData.buyShare.calcValue - leftInfo.brokerBranchData.sellShare.calcValue;
                
                cellL.mainLbl.text = leftbrokerName;
                cellL.subLbl.text = [fsemObj convertZeroPlusOrNot:leftMinusBuyAndSellShare / 1000];
            }
//            [cellL.contentView setNeedsUpdateConstraints];
//            [cellL.contentView updateConstraintsIfNeeded];
            return cellL;

        }else{
//            FSBrokerParametersMainCell *cellR = (FSBrokerParametersMainCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifiersecR];
//            if (cellR == nil) {
            FSBrokerParametersMainCell *cellR = [[FSBrokerParametersMainCell alloc] initWithRStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifiersecR];
//            }
            if ([forTableViewRight firstObject] == nil) {
                cellR.mainLbl.text = @"";
                cellR.subLbl.text = @"";
            }else{
                FSBrokerBranchByStock *rightInfo = [forTableViewRight objectAtIndex:indexPath.row];
                NSString *rightbrokerName = [self loadDBWithBranchName:rightInfo.brokerBranchData.brokerBranchID];
                double rightMinusBuyAndSellShare = rightInfo.brokerBranchData.buyShare.calcValue - rightInfo.brokerBranchData.sellShare.calcValue;
                
                cellR.mainLbl.text = rightbrokerName;
                cellR.subLbl.text = [fsemObj convertZeroPlusOrNot:rightMinusBuyAndSellShare / 1000];
            }
//            [cellR.contentView setNeedsUpdateConstraints];
//            [cellR.contentView updateConstraintsIfNeeded];
            return cellR;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:mainTableView]) {
        

        
        NSString *text = [brokerAndBranchName objectAtIndex:indexPath.row];
        
        UIFont *cellFont = [UIFont systemFontOfSize:20.0f];
        CGSize constraint = CGSizeMake(tableView.frame.size.width - 40, 20000.0f);
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle]mutableCopy];
        
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName: cellFont, NSParagraphStyleAttributeName: paragraphStyle};
        CGSize size = [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
        CGFloat height = MAX(size.height , 44.0f);
        return height;
    }else{
        return 44.0f;
    }
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:mainTableView]) {
        return 0;
    }else{
        return 45;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:mainTableView]) {

        FSBrokerCustomViewController *customView = [[FSBrokerCustomViewController alloc]initWithIndexPath:(int)indexPath.row];
        [self.navigationController pushViewController:customView animated:NO];
        
    }else{
        if ([tableView isEqual:secondLTableView]) {
            NSLog(@"L%ld", (long)indexPath.row);
            FSBrokerBranchByStock *leftInfo = [forTableViewLeft objectAtIndex:indexPath.row];

            MainBranchKLineOut *kLinePacket = [[MainBranchKLineOut alloc]initWithSymbol:symbol brokerBranchIdD:leftInfo.brokerBranchData.brokerBranchID dataType:0 count:0 startDate:endDayForKLine endDate:todayForKLine];
            [FSDataModelProc sendData:self WithPacket:kLinePacket];
        }else{
            NSLog(@"R%ld", (long)indexPath.row);
            FSBrokerBranchByStock *rightInfo = [forTableViewRight objectAtIndex:indexPath.row];

            MainBranchKLineOut *kLinePacket = [[MainBranchKLineOut alloc]initWithSymbol:symbol brokerBranchIdD:rightInfo.brokerBranchData.brokerBranchID dataType:0 count:0 startDate:endDayForKLine endDate:todayForKLine];
            [FSDataModelProc sendData:self WithPacket:kLinePacket];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
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
-(void)countBtn{
    
    UIActionSheet *actionSheetPoints = [[UIActionSheet alloc]initWithTitle:@"選擇前幾名分點" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for(i = 0; i < [selectPoints count]; i++){
        NSString *title = [selectPoints objectAtIndex:i];
        [actionSheetPoints addButtonWithTitle:title];
    }
    [actionSheetPoints addButtonWithTitle:@"取消"];
    [actionSheetPoints setCancelButtonIndex:i];
    [actionSheetPoints showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex < [selectPoints count]) {
        [countBtn setTitle:[actionSheet buttonTitleAtIndex:buttonIndex] forState:UIControlStateNormal];
        switch (buttonIndex) {
            case 0:
                count = 1;
                break;
            case 1:
                count = 5;
                break;
            case 2:
                count = 10;
                break;
            default:
                break;
        }
        alreadySend = NO;
        [self.view showHUDWithTitle:@""];
        [self sendBranchStockToServerWithOptionType:0];
    }
}

-(void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex{
    
    if (selectedIndex == 0) {
        mainTableView.hidden = NO;
        buyAndSellView.hidden = YES;
        dataDurationView.hidden = YES;

    }else{

        mainTableView.hidden = YES;
        buyAndSellView.hidden = NO;
        dataDurationView.hidden = NO;
        alreadySend = NO;
        [self sendBranchStockToServerWithOptionType:0];
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(showDataTimeOut:) userInfo:nil repeats:NO];
        [self.view showHUDWithTitle:@""];
        

    }
    [self.view setNeedsUpdateConstraints];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    UITableView *scrollIng;
    if (scrollView == secondLTableView) {
        scrollIng = secondRTableView;
    }else if (scrollView == secondRTableView){
        scrollIng = secondLTableView;
    }
    [scrollIng setContentOffset:scrollView.contentOffset];
}

- (void)loadDB{
    NSMutableArray *tableViewBranchID = [NSMutableArray new];
    NSMutableArray *tableViewGroup1 = [NSMutableArray new];
    NSMutableArray *tableViewGroup2 = [NSMutableArray new];
    NSMutableArray *tableViewGroup3 = [NSMutableArray new];
    NSMutableArray *tableViewGroup4 = [NSMutableArray new];
    NSMutableArray *tableViewGroup5 = [NSMutableArray new];
    tableViewTitle = [NSMutableArray new];
    
    dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message1 = [db executeQuery:@"SELECT Name FROM BrokerOptional"];
        while ([message1 next]) {
            NSString *title = [message1 stringForColumn:@"Name"];
            [tableViewTitle addObject:title];
        }
        [message1 close];
        
        FMResultSet *message = [db executeQuery:@"SELECT GroupIndex, BrokerBranchID FROM BrokerOptionalID"];
        while ([message next]) {
            int groupIndex = [message intForColumn:@"GroupIndex"];
            switch (groupIndex) {
                case 1:
                    [tableViewGroup1 addObject:[message stringForColumn:@"BrokerBranchID"]];
                    break;
                case 2:
                    [tableViewGroup2 addObject:[message stringForColumn:@"BrokerBranchID"]];
                    break;
                case 3:
                    [tableViewGroup3 addObject:[message stringForColumn:@"BrokerBranchID"]];
                    break;
                case 4:
                    [tableViewGroup4 addObject:[message stringForColumn:@"BrokerBranchID"]];
                    break;
                case 5:
                    [tableViewGroup5 addObject:[message stringForColumn:@"BrokerBranchID"]];
                    break;
                default:
                    break;
            }
        }
        
        [message close];

        [tableViewBranchID addObject:tableViewGroup1];
        [tableViewBranchID addObject:tableViewGroup2];
        [tableViewBranchID addObject:tableViewGroup3];
        [tableViewBranchID addObject:tableViewGroup4];
        [tableViewBranchID addObject:tableViewGroup5];
        
    }];

    [self searchNameWithBranchID:tableViewBranchID];
    [mainTableView reloadData];

}

-(void)searchNameWithBranchID:(NSMutableArray *)tableViewID{
    dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    branchNameArray = [NSMutableArray new];
    __block int gpIdx = 0;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        for(int i = 0; i < [tableViewID count]; i++){
            gpIdx = i + 1;
            NSMutableArray * arr = [NSMutableArray arrayWithArray:[tableViewID objectAtIndex:i]];
            
            for (NSString *branchId in arr){
                
                FMResultSet *message = [db executeQuery:@"SELECT brokerBranch.Name, brokerName.Name FROM brokerBranch JOIN brokerName ON brokerName.BrokerID = brokerBranch.BrokerID WHERE brokerBranch.BrokerBranchID = ?", branchId];
                while ([message next]) {
                    FSBrokerChoice *brokerData = [FSBrokerChoice new];
                    brokerData.brokerName = [self compareBrokerNameAndBranchName:[message objectForColumnIndex:1] :[message objectForColumnIndex:0]];
                    brokerData.groupIndex = gpIdx;

                    [branchNameArray addObject:brokerData];
                }
                [message close];
            }
        }
    }];
}

-(NSString *)loadDBWithBranchName:(NSString *)brokerBranchID{
    
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    NSMutableArray *brokerIDArray = [[NSMutableArray alloc]init];
    __block NSString *branchName;
    __block NSString *brokerName;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *searchNameAndBrokerIDWithBrokerBranchID = [db executeQuery:@"SELECT * FROM brokerBranch where BrokerBranchID = ?",brokerBranchID];
        while ([searchNameAndBrokerIDWithBrokerBranchID next]) {
            
            NSString *brokerID = [searchNameAndBrokerIDWithBrokerBranchID stringForColumn:@"BrokerID"];
            branchName = [searchNameAndBrokerIDWithBrokerBranchID stringForColumn:@"Name"];
            [brokerIDArray addObject:brokerID];
        }
        [searchNameAndBrokerIDWithBrokerBranchID close];
    }];
    
    [dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        for (int i = 0; i < [brokerIDArray count]; i++){
            FMResultSet *searchNameWithBrokerID = [db executeQuery:@"SELECT Name FROM brokerName where BrokerID = ?",[brokerIDArray objectAtIndex:i]];
            while ([searchNameWithBrokerID next]) {
                if (![[NSString stringWithFormat:@"%@", [brokerIDArray objectAtIndex:i]]isEqualToString:brokerBranchID]) {
                }
                brokerName = [searchNameWithBrokerID stringForColumn:@"Name"];
            }
            [searchNameWithBrokerID close];
        }
    }];
    return [self compareBrokerNameAndBranchName:brokerName :branchName];
    
}

-(NSString *)compareBrokerNameAndBranchName:(NSString *)brokerName :(NSString *)branchName{
    NSString *labelName;
    if ([[brokerName substringToIndex:2] isEqualToString:[branchName substringToIndex:2]]) {
        labelName = brokerName;
    }else{
        labelName = [brokerName stringByAppendingString:branchName];
    }
    return labelName;
}


-(void)loadServerDate{
    
    FSBrokerBranchByStock *brokerBranchInfo = [forTableViewLeft firstObject];
    
    int dateValSt = brokerBranchInfo.startDate;
    int dateValEn = brokerBranchInfo.endDate;
    dataModel.cyqModel.startDate = [[NSNumber numberWithInt:dateValSt]uint16ToDate];
    dataModel.cyqModel.endDate = [[NSNumber numberWithInt:dateValEn]uint16ToDate];
    
    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeRecently) {
        switch (dataModel.cyqModel.pickDays) {
            case 1:
                [dateBtn setTitle:@"1日累計" forState:UIControlStateNormal];
                break;
            case 5:
                [dateBtn setTitle:@"5日累計" forState:UIControlStateNormal];
                break;
            case 10:
                [dateBtn setTitle:@"10日累計" forState:UIControlStateNormal];
                break;
            case 20:
                [dateBtn setTitle:@"20日累計" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeDateBtnTitle:) userInfo:nil repeats:NO];
    }else{
        [self changeDateBtnTitle:0];
    }
}
-(void)changeDateBtnTitle:(NSTimer *)incomingTimer{
    
    FSBrokerBranchByStock *brokerBranchInfo = [forTableViewLeft firstObject];
    NSString *startDateStrTmp = [CodingUtil getStringDatePlusZero:brokerBranchInfo.startDate];
    NSString *endDateStrTmp = [CodingUtil getStringDatePlusZero:brokerBranchInfo.endDate];
    NSString *startDateStr = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *startDateStrForBtnTitle = [startDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    NSString *endDateStr = [endDateStrTmp stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([startDateStr isEqualToString:endDateStr]) {
        [dateBtn setTitle:[NSString stringWithFormat:@"%@", startDateStrForBtnTitle] forState:UIControlStateNormal];
    }else{
        [dateBtn setTitle:[NSString stringWithFormat:@"%@ - %@",startDateStr, endDateStr] forState:UIControlStateNormal];
        
    }
}

-(void)notifyDataArrive:(NSMutableArray *)array{

    if ([array firstObject] == nil) {
        NSLog(@"FSBrokerParametersViewController No Data arrive");
    }else{
        if (!alreadySend) {
            [timer invalidate];
            forTableViewLeft = [NSMutableArray arrayWithArray:array];
            [secondLTableView reloadData];
            
            [self loadServerDate];
            [self sendBranchStockToServerWithOptionType:1];
            alreadySend = YES;
        }else{
            [self.view hideHUD];
            forTableViewRight = [NSMutableArray arrayWithArray:array];

            [secondRTableView reloadData];
        }
    }
}
-(void)showDataTimeOut:(NSTimer *)incomingTimer{
    [self.view hideHUD];
    [forTableViewLeft removeAllObjects];
    [forTableViewRight removeAllObjects];
    [secondLTableView reloadData];
    [secondRTableView reloadData];
    UIAlertView *timeOutAlert = [[UIAlertView alloc]initWithTitle:@"下載逾時" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [timeOutAlert show];

}
-(void)sendBranchStockToServerWithOptionType:(int)sortType{
    [self findModelStartAndEndDay];

    PortfolioItem *portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    PortfolioItem * comparedPortfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
    
    if (portfolioItem == nil) {
        [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem = [[[FSDataModelProc sharedInstance] portfolioData] findItemByIdentCodeSymbol:@"TW ^tse01"];
        
        comparedPortfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
        
        symbol = comparedPortfolioItem -> symbol;
    }else{
        symbol = portfolioItem -> symbol;
    }

    if (dataModel.cyqModel.mainPlusAccumulateOptionType == MainPlusAcuumulateOptionTypeCalendar) {
        
        BrokerBranchByStockOut *brokerCalenderPacket = [[BrokerBranchByStockOut alloc]initWithSymbol:symbol days:0 startDate:sDate endDate:eDate sortType:sortType count:count];
        [FSDataModelProc sendData:self WithPacket:brokerCalenderPacket];
        
    }else{
        if (dataModel.cyqModel.pickDays == 0) {
            dataModel.cyqModel.pickDays = 1;
        }
        BrokerBranchByStockOut *stockOutPacket = [[BrokerBranchByStockOut alloc]initWithSymbol:symbol days:dataModel.cyqModel.pickDays sortType:sortType count:count];
        [FSDataModelProc sendData:self WithPacket:stockOutPacket];
    }
}


-(void)findModelStartAndEndDay{
    NSDate *today = [[NSDate alloc]init];

    if (dataModel.cyqModel.startDate == 0 || dataModel.cyqModel.endDate == 0) {
        
        dataModel.cyqModel.startDate = today;
        dataModel.cyqModel.endDate = today;
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *compsStart = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dataModel.cyqModel.startDate];
    int yearStart = (int)[compsStart year];
    int monthStart = (int)[compsStart month];
    int dayStart = (int)[compsStart day];
    NSDateComponents *compsEnd = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dataModel.cyqModel.endDate];
    int yearEnd = (int)[compsEnd year];
    int monthEnd = (int)[compsEnd month];
    int dayEnd = (int)[compsEnd day];
    
    NSDateComponents *compsToday = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int yearKLineStart = (int)[compsToday year];
    int monthKLineStart = (int)[compsToday month];
    int dayKLineStart = (int)[compsToday day];
    NSDateComponents *compsTwoAndAHalf = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int yearKLineEnd = (int)[compsTwoAndAHalf year];
    int monthKLineEnd = (int)[compsTwoAndAHalf month];
    int dayKLineEnd = (int)[compsTwoAndAHalf day];
    
    sDate = [CodingUtil makeDate:yearStart month:monthStart day:dayStart];
    eDate = [CodingUtil makeDate:yearEnd month:monthEnd day:dayEnd];
    
    todayForKLine = [CodingUtil makeDate:yearKLineStart month:monthKLineStart day:dayKLineStart];
    endDayForKLine = [CodingUtil makeDate:yearKLineEnd - 2 month:monthKLineEnd - 6 day:dayKLineEnd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
