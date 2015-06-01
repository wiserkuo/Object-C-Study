//
//  FSBrokerChoiceCollectionViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerChoiceCollectionViewController.h"
#import "FSBrokerChoiceCollectionViewCell.h"
#import "FSBrokerInAndOutListModel.h"
#import "UIView+NewComponent.h"



@interface FSBrokerChoiceCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>{

    UICollectionView *mainCollectionView;
    NSMutableArray *brokerInfoArray;
    FSDataModelProc *dataModel;
    FSDatabaseAgent *dbAgent;
    FSBrokerChoice *brokerInfo;
    
    
//    use for branchInAndOutListViewController
    UILabel *titleLeftLabel;
    FSUIButton *backBtn;
    BOOL changeCollectView;
    
}

@end

@implementation FSBrokerChoiceCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self searchBrokerNameAndIDInDB];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    判斷是那個分頁進來
    if ([BrokersByModel sharedInstance].brokerTrackingViewController == FSBrokerInAndOutView) {
        backBtn.hidden = YES;
        titleLeftLabel.text = @"券商";
    }else if ([BrokersByModel sharedInstance].brokerTrackingViewController == FSBranchInAndOutView){
        backBtn.hidden = NO;
        titleLeftLabel.text = @"總公司";
    }
//    判斷是在哪個collectView , NO = 總公司 , YES = 分公司
    changeCollectView = NO;
}

-(void)initView{
    self.title = @"選擇券商";
    self.navigationItem.hidesBackButton = YES;
    
//    重置 brokerID to 合庫
//    [BrokersByModel sharedInstance].brokerID = 1020;
    
    backBtn =  [self.view newButton:FSUIButtonTypeNormalRed];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backHandler) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:backBtn];
    
    titleLeftLabel = [UILabel new];
    titleLeftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLeftLabel.font = [UIFont systemFontOfSize:22.0f];
    titleLeftLabel.textColor = [UIColor brownColor];
    titleLeftLabel.text = @"總公司";

    [self.view addSubview:titleLeftLabel];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = CGSizeMake(80, 30);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 40, 20);
    
    mainCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 40, 320, 568) collectionViewLayout:flowLayout];
    mainCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mainCollectionView.delegate = self;
    mainCollectionView.dataSource = self;
    mainCollectionView.backgroundColor = [UIColor clearColor];
    mainCollectionView.bounces = NO;
    [mainCollectionView registerClass:[FSBrokerChoiceCollectionViewCell class] forCellWithReuseIdentifier:@"FSBrokerChoiceCollectionViewCell"];
    [self.view addSubview:mainCollectionView];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *contraints = [NSMutableArray new];
    NSDictionary *viewContraints = NSDictionaryOfVariableBindings(titleLeftLabel, backBtn);
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLeftLabel]-[backBtn(60)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[backBtn(40)]" options:0 metrics:nil views:viewContraints]];
    
    [self replaceCustomizeConstraints:contraints];
}

-(void)backHandler{
    if (!changeCollectView) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        changeCollectView = NO;

        [self searchBrokerNameAndIDInDB];
        [mainCollectionView reloadData];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [brokerInfoArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"FSBrokerChoiceCollectionViewCell";
    FSBrokerChoiceCollectionViewCell *cell = (FSBrokerChoiceCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    brokerInfo = [brokerInfoArray objectAtIndex:indexPath.row];
    if (!changeCollectView) {
        cell.label.text = brokerInfo.brokerName;
    }else{
        cell.label.text = brokerInfo.branchName;
    }

    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    brokerInfo = [brokerInfoArray objectAtIndex:indexPath.row];
    [BrokersByModel sharedInstance].brokerID = brokerInfo.brokerID;
    [brokerInfoArray removeAllObjects];

    if ([BrokersByModel sharedInstance].brokerTrackingViewController == FSBrokerInAndOutView) {
        
        [self searchBrokerNameInDB];
        [BrokersByModel sharedInstance].brokerName = brokerInfo.brokerName;
        [self.navigationController popViewControllerAnimated:NO];
    }else if ([BrokersByModel sharedInstance].brokerTrackingViewController == FSBranchInAndOutView){
        
        if (!changeCollectView) {
            [BrokersByModel sharedInstance].brokerNameForBranchView = brokerInfo.brokerName;
            titleLeftLabel.text = [NSString stringWithFormat:@"%@分公司",[BrokersByModel sharedInstance].brokerNameForBranchView];
            [self searchBranchNameAndIDInDB];
            [mainCollectionView reloadData];
            changeCollectView = YES;
        }else{
            [BrokersByModel sharedInstance].brokerAnchorName = brokerInfo.branchName;
            if (![[BrokersByModel sharedInstance].brokerBranchID isEqualToString: brokerInfo.brokerBranchID]){
                [BrokersByModel sharedInstance].brokerBranchID = brokerInfo.brokerBranchID;
            }
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

-(void)searchBrokerNameAndIDInDB{
    
    brokerInfoArray = [NSMutableArray new];
    dataModel = [FSDataModelProc sharedInstance];
    dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Name, BrokerID FROM brokerName"];
        while ([message next]) {
            brokerInfo = [FSBrokerChoice new];
            brokerInfo.brokerName = [message stringForColumn:@"Name"];
            brokerInfo.brokerID = [message intForColumn:@"BrokerID"];
            
            [brokerInfoArray addObject:brokerInfo];
        }
        [message close];
    }];
}

-(void)searchBrokerNameInDB{

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Name FROM brokerName WHERE BrokerID = ?",[NSNumber numberWithInt:[BrokersByModel sharedInstance].brokerID]];
        while ([message next]) {
            NSString *brokerName = [message stringForColumn:@"Name"];
            [BrokersByModel sharedInstance].brokerName = brokerName;
        }
        [message close];
    }];
}

-(void)searchBranchNameAndIDInDB{
    
    brokerInfoArray = [NSMutableArray new];
    dataModel = [FSDataModelProc sharedInstance];
    dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Name, BrokerBranchID FROM brokerBranch WHERE BrokerID = ?",[NSNumber numberWithInt:[BrokersByModel sharedInstance].brokerID]];
        while ([message next]) {
            brokerInfo = [FSBrokerChoice new];
            brokerInfo.branchName = [message stringForColumn:@"Name"];
            brokerInfo.brokerBranchID = [message stringForColumn:@"BrokerBranchID"];
            
            [brokerInfoArray addObject:brokerInfo];
        }
        [message close];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
