//
//  FSBrokerCustomViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerCustomViewController.h"
#import "FSBrokerChoiceCollectionViewCell.h"
#import "FSBrokerInAndOutListModel.h"


@interface FSBrokerCustomViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

{
    
    UILabel *titleLabel;
    FSUIButton *changeNameBtn;
    UILabel *trackPointsLabel;
    UILabel *headOfficeLabel;
    UILabel *branchOfficeLabel;
    
    UILabel *bottomLabel;
    FSUIButton *resetBtn;
    FSUIButton *backBtn;
    
    UICollectionView *trackCollection;
    UICollectionView *headOfficeCollection;
    UICollectionView *branchOfficeCollection;
    UITextField *userName;
    UIAlertView *changeNameAlert;
    NSString *userInput;
    NSMutableArray *brokerInfoArray;
    NSMutableArray *branchInfoArray;
    NSMutableArray *optionalArray;
    FSDataModelProc *dataModel;
    FSDatabaseAgent *dbAgent;
    int selected;
    NSString *brokerNameForBtn;
    int brokerIDForBtn;
    NSString *optionalName;
    NSMutableArray *optionalBranchID;
    NSString *trackName;
    int idx;

}

@end

@implementation FSBrokerCustomViewController

-(id)initWithIndexPath:(int)tableViewIndex{
    self = [super init];
    if (self) {
        idx = tableViewIndex + 1;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self loadDB];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];

}

-(void)initView{

    self.title = @"自選券商";
    self.navigationItem.hidesBackButton = YES;
//    brokerCell1.btn.selected = YES;
    brokerIDForBtn = 1020;
    brokerNameForBtn = @"合庫";
    [self searchBranchNameAndIDInDB:1020];
//    [headOfficeCollection reloadData];
//    [branchOfficeCollection reloadData];
    
    titleLabel = [UILabel new];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont systemFontOfSize:21.0f];
    [self.view addSubview:titleLabel];
    
    changeNameBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    changeNameBtn.translatesAutoresizingMaskIntoConstraints = NO;
    changeNameBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    [changeNameBtn setTitle:@"更改名稱" forState:UIControlStateNormal];
    [changeNameBtn addTarget:self action:@selector(changeHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeNameBtn];
    
    trackPointsLabel = [UILabel new];
    trackPointsLabel.text = @"追\n蹤\n分\n點";
    trackPointsLabel.numberOfLines = 0;
    trackPointsLabel.textAlignment = NSTextAlignmentLeft;
    trackPointsLabel.font = [UIFont systemFontOfSize:19.0f];
    trackPointsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:trackPointsLabel];
    
    headOfficeLabel = [UILabel new];
    headOfficeLabel.text = @"總\n公\n司";
    headOfficeLabel.numberOfLines = 0;
    headOfficeLabel.font = [UIFont systemFontOfSize:19.0f];
    headOfficeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headOfficeLabel];
    
    branchOfficeLabel = [UILabel new];
    branchOfficeLabel.text = @"分\n公\n司";
    branchOfficeLabel.numberOfLines = 0;
    branchOfficeLabel.font = [UIFont systemFontOfSize:19.0f];
    branchOfficeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:branchOfficeLabel];
    
    bottomLabel = [UILabel new];
    bottomLabel.text = @"0/10 (橘色為已加入)";
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLabel.textColor = [UIColor colorWithRed:43.0/255.0 green:67.0/255.0 blue:154.0/255.0 alpha:1.0];
    bottomLabel.font = [UIFont systemFontOfSize:19.0f];
    [self.view addSubview:bottomLabel];
    
    resetBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    resetBtn.translatesAutoresizingMaskIntoConstraints = NO;
    resetBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    [resetBtn setTitle:@"清空重選" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    backBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UICollectionViewFlowLayout *flowLayoutTrack = [UICollectionViewFlowLayout new];
    flowLayoutTrack.itemSize = CGSizeMake(130, 32);
    flowLayoutTrack.sectionInset = UIEdgeInsetsMake(0, 0, 30, 20);

    UICollectionViewFlowLayout *flowLayoutOffice = [UICollectionViewFlowLayout new];
    flowLayoutOffice.itemSize = CGSizeMake(80, 32);
    flowLayoutOffice.sectionInset = UIEdgeInsetsMake(0, 0, 25, 25);
    
    UICollectionViewFlowLayout *flowLayoutbranch = [UICollectionViewFlowLayout new];
    flowLayoutbranch.itemSize = CGSizeMake(80, 32);
    flowLayoutbranch.sectionInset = UIEdgeInsetsMake(0, 0, 25, 25);
    
    trackCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(20, 45, 295, 190) collectionViewLayout:flowLayoutTrack];
    trackCollection.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    trackCollection.delegate = self;
    trackCollection.dataSource = self;
    trackCollection.backgroundColor = [UIColor clearColor];
    trackCollection.bounces = NO;
    trackCollection.layer.borderWidth = 1.0f;
    trackCollection.layer.borderColor = [UIColor blackColor].CGColor;
    [trackCollection registerClass:[FStrackCollectionViewCell class] forCellWithReuseIdentifier:@"trackCollectionCell"];
    [self.view addSubview:trackCollection];
    
    headOfficeCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(20, 185, 295, 190) collectionViewLayout:flowLayoutOffice];
    headOfficeCollection.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    headOfficeCollection.delegate = self;
    headOfficeCollection.dataSource = self;
    headOfficeCollection.backgroundColor = [UIColor clearColor];
    headOfficeCollection.bounces = NO;
    headOfficeCollection.layer.borderWidth = 1.0f;
    headOfficeCollection.layer.borderColor = [UIColor blackColor].CGColor;
    [headOfficeCollection registerClass:[FSheadOfficeCollectionViewCell class] forCellWithReuseIdentifier:@"headOfficeCollectionCell"];
    [self.view addSubview:headOfficeCollection];

    branchOfficeCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(20, 325, 295, 190) collectionViewLayout:flowLayoutbranch];
    branchOfficeCollection.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    branchOfficeCollection.delegate = self;
    branchOfficeCollection.dataSource = self;
    branchOfficeCollection.backgroundColor = [UIColor clearColor];
    branchOfficeCollection.bounces = NO;
    branchOfficeCollection.layer.borderWidth = 1.0f;
    branchOfficeCollection.layer.borderColor = [UIColor blackColor].CGColor;
    [branchOfficeCollection registerClass:[FSbranchOfficeCollectionViewCell class] forCellWithReuseIdentifier:@"headOfficeCollectionCell"];
    [self.view addSubview:branchOfficeCollection];

    [self searchBrokerNameAndIDInDB];
    
    NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:0 inSection:0];
    [headOfficeCollection selectItemAtIndexPath:indexPathToInsert animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self.view setNeedsUpdateConstraints];
}


-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *contraints = [NSMutableArray new];
    NSDictionary *viewContraints = NSDictionaryOfVariableBindings(titleLabel, changeNameBtn, trackPointsLabel, headOfficeLabel, branchOfficeLabel, bottomLabel, resetBtn, backBtn);
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]-[changeNameBtn(100)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[trackPointsLabel(50)]" options:0 metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headOfficeLabel(50)]" options:0 metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[branchOfficeLabel(50)]" options:0 metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLabel]-[resetBtn(85)][backBtn(45)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[changeNameBtn(40)]-2-[trackPointsLabel(100)]-35-[headOfficeLabel(100)]-35-[branchOfficeLabel(100)]-35-[bottomLabel]|" options:0 metrics:nil views:viewContraints]];
    
    [self replaceCustomizeConstraints:contraints];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if ([collectionView isEqual:trackCollection]) {
        return [optionalArray count];
    }else if ([collectionView isEqual:headOfficeCollection]){
        return [brokerInfoArray count];
    }else if ([collectionView isEqual:branchOfficeCollection]){
        return [branchInfoArray count];
    }
    return 0;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellTrackIdentifier = @"trackCollectionCell";
    static NSString *CellHeadIdentifier = @"headOfficeCollectionCell";

    bottomLabel.text = [NSString stringWithFormat:@"%d/10 (橘色為已加入)", selected];

    FSheadOfficeCollectionViewCell *cellOffice;

    if ([collectionView isEqual: trackCollection]) {

        FStrackCollectionViewCell *cellTrack = (FStrackCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellTrackIdentifier forIndexPath:indexPath];
        if (optionalArray != nil) {
            [cellTrack.btn setTitle:[optionalArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        }

        return cellTrack;
        
    }else if ([collectionView isEqual: headOfficeCollection]){

        cellOffice = (FSheadOfficeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellHeadIdentifier forIndexPath:indexPath];
        FSBrokerChoice *brokerInfo = [brokerInfoArray objectAtIndex:indexPath.row];
        [cellOffice.btn setTitle:brokerInfo.brokerName forState:UIControlStateNormal];

        if (brokerIDForBtn == brokerInfo.brokerID) {
            cellOffice.btn.selected = YES;
            [cellOffice.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }

        return cellOffice;
        
    }else{

        cellOffice = (FSbranchOfficeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellHeadIdentifier forIndexPath:indexPath];
        FSBrokerChoice *branchInfo = [branchInfoArray objectAtIndex:indexPath.row];

        [cellOffice.btn setTitle:branchInfo.branchName forState:UIControlStateNormal];
        
        for(int i = 0; i < [optionalBranchID count]; i++){
            NSString *tempID = [optionalBranchID objectAtIndex:i];
            if ([tempID isEqualToString:branchInfo.brokerBranchID]) {
                cellOffice.btn.selected = YES;
                [cellOffice.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
        
        return cellOffice;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if ([collectionView isEqual:trackCollection]) {
        
        selected--;
        trackName = [optionalArray objectAtIndex:indexPath.row];
        NSUInteger index = [optionalArray indexOfObject:trackName];
        if (index != NSNotFound) {
            [optionalArray removeObjectAtIndex:index];
            [optionalBranchID removeObjectAtIndex:index];
        }
        
        [trackCollection reloadData];
        [branchOfficeCollection reloadData];

    }else if ([collectionView isEqual:headOfficeCollection]){

        FSheadOfficeCollectionViewCell * brokerCell = (FSheadOfficeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        brokerCell.btn.selected = YES;
        [brokerCell.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        FSBrokerChoice *brokerInfo = [brokerInfoArray objectAtIndex:indexPath.row];
        brokerNameForBtn = brokerInfo.brokerName;
        brokerIDForBtn = brokerInfo.brokerID;

        [self searchBranchNameAndIDInDB:brokerInfo.brokerID];
        [branchOfficeCollection reloadData];
    }else{
        FSbranchOfficeCollectionViewCell * branchCell = (FSbranchOfficeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        FSBrokerChoice *branchInfo = [branchInfoArray objectAtIndex:indexPath.row];

        if (!branchCell.btn.selected) {
            if (selected >= 10) {
                UIAlertView *maxAlert = [[UIAlertView alloc]initWithTitle:@"最多只能追蹤10個券商分點" message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                [maxAlert show];
                return;
            }else{
                selected++;
                [branchCell.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [optionalBranchID addObject:branchInfo.brokerBranchID];
                [optionalArray addObject:[self compareBrokerNameAndBranchName:brokerNameForBtn :branchInfo.branchName :brokerIDForBtn :[branchInfo.brokerBranchID intValue]]];
                branchCell.btn.selected = !branchCell.btn.selected;
            }
        }else{
            selected--;
            [branchCell.btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            NSUInteger index = [optionalArray indexOfObject:[self compareBrokerNameAndBranchName:brokerNameForBtn :branchInfo.branchName :brokerIDForBtn :[branchInfo.brokerBranchID intValue]]];
            NSUInteger indexId = [optionalBranchID indexOfObject:branchInfo.brokerBranchID ];
            if (index != NSNotFound) {
                [optionalArray removeObjectAtIndex:index];
                [optionalBranchID removeObjectAtIndex:indexId];
            }
            branchCell.btn.selected = !branchCell.btn.selected;
        }
        [trackCollection reloadData];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{

    if ([collectionView isEqual: headOfficeCollection]) {
        FSheadOfficeCollectionViewCell * brokerCell = (FSheadOfficeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [brokerCell.btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        brokerCell.btn.selected = NO;
    }
}

-(void)changeHandler:(UITextField *)textField{
    changeNameAlert = [[UIAlertView alloc]initWithTitle:@"更改群組名稱" message:@"請輸入新的名稱:" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil];
    changeNameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;

    userName = [changeNameAlert textFieldAtIndex:0];
    userName.keyboardType = UIKeyboardTypeNamePhonePad;
    [userName setDelegate:self];
    [userName becomeFirstResponder];
    userName.text = userInput;

    [changeNameAlert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView != changeNameAlert) {
        return;
    }else{
        if (userName.text.length != 0) {
            userInput = userName.text;
            titleLabel.text = [NSString stringWithFormat:@"名稱: %@", userInput];

        }else{

            UIAlertView *alertSpace = [[UIAlertView alloc]initWithTitle:@"名稱不可空白" message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alertSpace show];
        }
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(userName.text.length >= 10 && range.length == 0){
        return NO;
    }
    return YES;
}

-(void)resetHandler{

    selected = 0;
    bottomLabel.text = @"0/10 (橘色為已加入)";
    [self removeInfoAtGroupIndex];
    [optionalArray removeAllObjects];
    [optionalBranchID removeAllObjects];
    [branchOfficeCollection reloadData];
    [trackCollection reloadData];
}

-(void)backHandler{

    [self saveTitleLabelAndBranchIDToDB];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)searchBrokerNameAndIDInDB{
    
    brokerInfoArray = [NSMutableArray new];
    dataModel = [FSDataModelProc sharedInstance];
    dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Name, BrokerID FROM brokerName"];
        while ([message next]) {
            FSBrokerChoice *brokerInfo = [FSBrokerChoice new];
            brokerInfo.brokerName = [message stringForColumn:@"Name"];
            brokerInfo.brokerID = [message intForColumn:@"BrokerID"];
            
            [brokerInfoArray addObject:brokerInfo];
        }
        [message close];
    }];
}

-(void)searchBranchNameAndIDInDB:(int)brokerID{
    
    branchInfoArray = [NSMutableArray new];
    dataModel = [FSDataModelProc sharedInstance];
    dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT Name, BrokerBranchID FROM brokerBranch WHERE BrokerID = ?",[NSNumber numberWithInt:brokerID]];
        while ([message next]) {
            FSBrokerChoice *brokerInfo = [FSBrokerChoice new];
            brokerInfo.branchName = [message stringForColumn:@"Name"];
            brokerInfo.brokerBranchID = [message stringForColumn:@"BrokerBranchID"];
            
            [branchInfoArray addObject:brokerInfo];
        }
        [message close];
    }];
}

-(NSString *)compareBrokerNameAndBranchName:(NSString *)brokerName :(NSString *)branchName :(int)brokerID :(int)branchID{
    
    NSString *labelName;
    if ([[brokerName substringToIndex:2] isEqualToString:[branchName substringToIndex:2]]) {
        labelName = brokerName;
    }else if(brokerID == branchID){
        labelName = brokerName;
    }else{
        labelName = [brokerName stringByAppendingString:branchName];
    }
    return labelName;
}

-(void)loadDB{
    
    optionalBranchID = [NSMutableArray new];
    optionalArray = [NSMutableArray new];
    dataModel = [FSDataModelProc sharedInstance];
    dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
//        searchTitleLabel
        FMResultSet *message = [db executeQuery:@"SELECT Name FROM BrokerOptional WHERE GroupIndex = ?",[NSNumber numberWithInt:idx]];
        while ([message next]) {
            userInput = [message stringForColumn:@"Name"];

        }
        [message close];
        
//        searchBranchID
        FMResultSet *message1 = [db executeQuery:@"SELECT BrokerBranchID FROM BrokerOptionalID WHERE GroupIndex = ?",[NSNumber numberWithInt:idx]];
        while ([message1 next]) {
            NSString *branchID = [message1 stringForColumn:@"BrokerBranchID"];
            [optionalBranchID addObject:branchID];
        }
        [message1 close];
        
//        searchBranchName
        for (NSString *branchId in optionalBranchID) {
            FMResultSet *message = [db executeQuery:@"SELECT * FROM brokerBranch JOIN brokerName ON brokerName.BrokerID = brokerBranch.BrokerID WHERE brokerBranch.BrokerBranchID = ?", branchId];
            while ([message next]) {
                NSString *branchName = [self compareBrokerNameAndBranchName:[message stringForColumnIndex:5] :[message stringForColumnIndex:2] :[message intForColumn:@"BrokerID"] :[message intForColumn:@"BrokerBranchID"]];
                [optionalArray addObject:branchName];
            }
            [message close];
        }
    }];
    
    titleLabel.text = [NSString stringWithFormat:@"名稱: %@", userInput];
    selected = (int)[optionalBranchID count];
}

-(void)saveTitleLabelAndBranchIDToDB{
    dataModel = [FSDataModelProc sharedInstance];
    dbAgent = dataModel.mainDB;

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        [db executeUpdate:@"UPDATE BrokerOptional SET Name = ? WHERE GroupIndex = ? ", userInput, [NSNumber numberWithInt:idx]];
        if ([optionalArray firstObject] != nil) {
            
//            remove BranchID
            [db executeUpdate:@"DELETE FROM BrokerOptionalID WHERE GroupIndex = ?", [NSNumber numberWithInt:idx]];
            
//            save BranchID
            for (NSString *branchID in optionalBranchID) {
                [db executeUpdate:@"INSERT INTO BrokerOptionalID(GroupIndex, BrokerBranchID) VALUES(?, ?)", [NSNumber numberWithInt:idx], branchID];
            }
        }
    }];
}

-(void)removeInfoAtGroupIndex{
    dataModel = [FSDataModelProc sharedInstance];
    dbAgent = dataModel.mainDB;
    
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"DELETE FROM BrokerOptionalID WHERE GroupIndex = ?", [NSNumber numberWithInt:idx]];
        }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
