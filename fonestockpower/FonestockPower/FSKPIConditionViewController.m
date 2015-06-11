//
//  FSKPIConditionViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/12/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSKPIConditionViewController.h"
#import "FSKPIConditionTableViewCell.h"
#import "FSKPIConditionDetailTableViewCell.h"

@interface FSKPIConditionViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, FSKPIConditionCellDelegate, FSKPIConditionDetailCellDelegate>{
    UILabel *promptLabel;
    UILabel *exchangeLabel;
    UITableView *mainTableView;
    FSUIButton *exchangeBtn;
    FSUIButton *searchBtn;
    
    UIView *bottomView;
    
    NSMutableArray *kpiSimpleSearchDataArray;
    NSMutableArray *kpiDataArray;
    NSMutableArray *profitabilityDataArray;
    NSMutableArray *financialDataArray;
    NSMutableArray *managementDataArray;
    NSMutableArray *layoutContraints;
    
    KPIObject *kpi;
    
    int section0CellNumber;
    int section1CellNumber;
    int section2CellNumber;
    
}

@end

@implementation FSKPIConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    layoutContraints = [[NSMutableArray alloc] init];
    [self initData];
    
    section0CellNumber = 1;
    section1CellNumber = 1;
    section2CellNumber = 1;
    
    [self initView];
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView{
    promptLabel = [[UILabel alloc] init];
    promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    promptLabel.text = @"請選擇分數0~100";
    promptLabel.textColor = [UIColor blueColor];
    [self.view addSubview:promptLabel];
    
    mainTableView = [[UITableView alloc] init];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:mainTableView];
    
    bottomView = [[UIView alloc] init];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    
    exchangeLabel = [[UILabel alloc] init];
    exchangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    exchangeLabel.text = @"交易所";
    exchangeLabel.textColor = [UIColor brownColor];
    [bottomView addSubview:exchangeLabel];
    
    exchangeBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    exchangeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [exchangeBtn setTitle:@"集中市場" forState:UIControlStateNormal];
    [exchangeBtn addTarget:searchBtn action:@selector(exchangeBtnCick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:exchangeBtn];
    
    searchBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    searchBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [searchBtn setTitle:@"搜尋" forState:UIControlStateNormal];
    [bottomView addSubview:searchBtn];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    [layoutContraints removeAllObjects];

    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(promptLabel, mainTableView, bottomView, exchangeLabel, exchangeBtn, searchBtn);
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[promptLabel]|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|" options:0 metrics:nil views:viewControllers]];

    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[promptLabel][mainTableView][bottomView(50)]|" options:0 metrics:nil views:viewControllers]];
    
    
//    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[exchangeLabel(55)][exchangeBtn][searchBtn(50)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
//    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[exchangeLabel(50)]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewControllers]];

    [self.view addConstraints:layoutContraints];
}

-(void)initData{
    kpiSimpleSearchDataArray = [self searchKPISimpleSearchDataWithParentID:0];
    profitabilityDataArray = [self searchKPISimpleSearchDataWithParentID:22];
    financialDataArray = [self searchKPISimpleSearchDataWithParentID:23];
    managementDataArray = [self searchKPISimpleSearchDataWithParentID:24];
}

#pragma mark - Button Action
-(void)exchangeBtnCick:(FSUIButton *)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"交易所" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"集中市場", @"店頭市場", nil];
    [actionSheet showInView:self.view.window.rootViewController.view];
}

#pragma mark - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [exchangeBtn setTitle:@"集中市場" forState:UIControlStateNormal];
    }else if (buttonIndex == 1){
        [exchangeBtn setTitle:@"店頭市場" forState:UIControlStateNormal];
    }
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return section0CellNumber;
    }else if (section == 1){
        return section1CellNumber;
    }else{
        return section2CellNumber;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 44;
    }else{
        return 77;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSString *CellIdentifier = [NSString stringWithFormat:@"cellIdentifier%ld", (long)indexPath.row];
        FSKPIConditionTableViewCell * cell = (FSKPIConditionTableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[FSKPIConditionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        kpi = [kpiSimpleSearchDataArray objectAtIndex:indexPath.section];

        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailBtn.tag = indexPath.section;
        cell.lowScoreTextField.tag = indexPath.section;
        cell.highScoreTextField.tag = indexPath.section;
        
        if (indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2) {
            if (kpi.status) {
                cell.chooseImageView.image = [UIImage imageNamed:@"check_bg_true"];
            }else{
                cell.chooseImageView.image = [UIImage imageNamed:@"check_bg_false"];
            }
            cell.label.text = [NSString stringWithFormat:@"%d.%@", (int)indexPath.section + 1, kpi.kpiName];
            
            if (indexPath.section == 0 && section0CellNumber != 1) {
                cell.lowScoreTextField.hidden = YES;
                cell.highScoreTextField.hidden = YES;
                cell.tildeLabel.hidden = YES;
                cell.chooseImageView.image = [UIImage imageNamed:@"check_bg_false"];
            }else if (indexPath.section == 1 && section1CellNumber != 1){
                cell.lowScoreTextField.hidden = YES;
                cell.highScoreTextField.hidden = YES;
                cell.tildeLabel.hidden = YES;
                cell.chooseImageView.image = [UIImage imageNamed:@"check_bg_false"];
            }else if (indexPath.section == 2 && section2CellNumber != 1){
                cell.lowScoreTextField.hidden = YES;
                cell.highScoreTextField.hidden = YES;
                cell.tildeLabel.hidden = YES;
                cell.chooseImageView.image = [UIImage imageNamed:@"check_bg_false"];
            }else{
                cell.lowScoreTextField.text = [NSString stringWithFormat:@"%.f", kpi.lowScore];
                cell.highScoreTextField.text = [NSString stringWithFormat:@"%.f", kpi.highScore];
            }
        }
        
        return cell;
    }else{
        NSString *CellIdentifier2 = [NSString stringWithFormat:@"cellIdentifier2%ld", (long)indexPath.row];
        FSKPIConditionDetailTableViewCell * cell = (FSKPIConditionDetailTableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[FSKPIConditionDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.lowScoreTextField.tag = indexPath.section;
        cell.highScoreTextField.tag = indexPath.section;
        
        if (indexPath.section == 0) {
            kpi = [profitabilityDataArray objectAtIndex:indexPath.row - 1];
        }else if (indexPath.section == 1){
            kpi = [financialDataArray objectAtIndex:indexPath.row - 1];
        }else if (indexPath.section == 2){
            kpi = [managementDataArray objectAtIndex:indexPath.row - 1];
        }
        
        if (kpi.status) {
            cell.chooseImageView.image = [UIImage imageNamed:@"check_bg_true"];
        }else{
            cell.chooseImageView.image = [UIImage imageNamed:@"check_bg_false"];
        }
        cell.label.text = [NSString stringWithFormat:@"%@", kpi.kpiName];

        cell.lowScoreTextField.text = [NSString stringWithFormat:@"%.f", kpi.lowScore];
        cell.highScoreTextField.text = [NSString stringWithFormat:@"%.f", kpi.highScore];

        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        kpi = [kpiSimpleSearchDataArray objectAtIndex:indexPath.section];
    }else if (indexPath.section == 0 && indexPath.row != 0){
        kpi = [profitabilityDataArray objectAtIndex:indexPath.row - 1];
    }else if (indexPath.section == 1 && indexPath.row != 0){
        kpi = [financialDataArray objectAtIndex:indexPath.row - 1];
    }else if (indexPath.section == 2 && indexPath.row != 0){
        kpi = [managementDataArray objectAtIndex:indexPath.row - 1];
    }
    
    if (kpi.status) {
        kpi.status = NO;
    }else{
        kpi.status = YES;
    }
    [self updateKPIStatusWithKPIID:kpi.kpiID status:kpi.status];
    NSArray *array = [[NSArray alloc] initWithObjects:indexPath, nil];
    [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - Cell Delegate
-(void)returnDetailBtn:(FSUIButton *)detailBtn{
    if (detailBtn.tag == 0) {
        if (section0CellNumber == 1) {
            section0CellNumber = (int)[profitabilityDataArray count];
        }else{
            section0CellNumber = 1;
        }
    }else if (detailBtn.tag == 1){
        if (section1CellNumber == 1) {
            section1CellNumber = (int)[financialDataArray count];
        }else{
            section1CellNumber = 1;
        }
    }else if (detailBtn.tag == 2){
        if (section2CellNumber == 1) {
            section2CellNumber = (int)[managementDataArray count];
        }else{
            section2CellNumber = 1;
        }
    }
    [mainTableView reloadData];
}

-(void)returnLowScoreTextField:(UITextField *)lowScoreTextField{
    kpi = [kpiSimpleSearchDataArray objectAtIndex:lowScoreTextField.tag];
    [self updateKPILowScoreWithKPIID:kpi.kpiID lowScore:lowScoreTextField.text];
    [self initData];
}

-(void)returnHighScoreTextField:(UITextField *)highScoreTextField{
    kpi = [kpiSimpleSearchDataArray objectAtIndex:highScoreTextField.tag];
    [self updateKPIHighScoreWithKPIID:kpi.kpiID highScore:highScoreTextField.text];
    [self initData];
}

-(void)returnLowScoreTextField:(UITextField *)lowScoreTextField row:(NSInteger)row{
    if (lowScoreTextField.tag == 0) {
        kpi = [profitabilityDataArray objectAtIndex:row];
    }else if (lowScoreTextField.tag == 1){
        kpi = [financialDataArray objectAtIndex:row];
    }else if (lowScoreTextField.tag == 2){
        kpi = [managementDataArray objectAtIndex:row];
    }
    [self updateKPILowScoreWithKPIID:kpi.kpiID lowScore:lowScoreTextField.text];
    [self initData];
}

-(void)returnHighScoreTextField:(UITextField *)highScoreTextField row:(NSInteger)row{
    if (highScoreTextField.tag == 0) {
        kpi = [profitabilityDataArray objectAtIndex:row];
    }else if (highScoreTextField.tag == 1){
        kpi = [financialDataArray objectAtIndex:row];
    }else if (highScoreTextField.tag == 2){
        kpi = [managementDataArray objectAtIndex:row];
    }
    [self updateKPIHighScoreWithKPIID:kpi.kpiID highScore:highScoreTextField.text];
    [self initData];
}

-(void)returnTextFieldDidBeginEditing:(UITextField *)textField{

}

#pragma mark - DataBase
-(NSMutableArray *)searchKPISimpleSearchDataWithParentID:(int)parentID{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM KPI WHERE ParentID = ?", [NSNumber numberWithInt:parentID]];
        while ([message next]) {
            kpi = [[KPIObject alloc] init];
            kpi.kpiID = [message intForColumn:@"KPIID"];
            kpi.parentID = [message intForColumn:@"ParentID"];
            kpi.kpiName = [message stringForColumn:@"KPIName"];
            kpi.status = [message boolForColumn:@"Status"];
            kpi.lowScore = [message intForColumn:@"LowScore"];
            kpi.highScore = [message intForColumn:@"HighScore"];
            
            [dataArray addObject:kpi];
        }
    }];
    
    return dataArray;
}

-(void)updateKPIStatusWithKPIID:(int)kpiID status:(BOOL)Status{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE KPI SET Status = ? WHERE KPIID = ? ", [NSNumber numberWithBool:Status], [NSNumber numberWithInt:kpiID]];
    }];
}

-(void)updateKPILowScoreWithKPIID:(int)kpiID lowScore:(NSString *)lowScore{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [ db executeUpdate:@"UPDATE KPI SET LowScore = ? WHERE KPIID = ?", lowScore, [NSNumber numberWithInt:kpiID]];
    }];
}

-(void)updateKPIHighScoreWithKPIID:(int)kpiID highScore:(NSString *)highScore{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [ db executeUpdate:@"UPDATE KPI SET HighScore = ? WHERE KPIID = ?", highScore, [NSNumber numberWithInt:kpiID]];
    }];
}

@end

@implementation KPIObject

@end