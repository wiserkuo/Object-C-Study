//  美股AddSymbols
//  FSActionEditChooseViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/5/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionEditChooseViewController.h"
#import "BtnCollectionView.h"
#import "UIView+NewComponent.h"

@interface FSActionEditChooseViewController (){
    int userCount;
}
@property (strong) UILabel *titleLabel;
@property (strong) UILabel *bottomLabel;
@property (strong) UITextField *searchText;
@property (strong) FSUIButton *searchBtn;
@property (strong) BtnCollectionView *collectionView;
@property (strong) NSString *identSymbol;
@property (strong) NSMutableArray * dataNameArray;
@property (strong) NSMutableArray * groupDataIdArray;//自選群組內的股票id
@property (strong, nonatomic) NSMutableDictionary *mainDict;
@property (nonatomic)int clickNum;//0=groupBtn,1=searchBtn
@property (nonatomic) int totalCount;

@property (nonatomic)int chooseCount;

@end

@implementation FSActionEditChooseViewController

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
	// Do any additional setup after loading the view.
    [self initView];
    _clickNum = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView{
    self.dataArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    self.dataIdentCodeArray = [[NSMutableArray alloc]init];
    self.groupDataIdArray = [[NSMutableArray alloc]init];
    self.chooseArray = [[NSMutableArray alloc]init];
    _totalCount = 0;
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(_mainDict){
        self.searchNum = [(NSNumber *)[_mainDict objectForKey:@"UserGroupNum"]intValue];
    }else{
        _searchNum = 0;
    }
    
    self.searchText = [[UITextField alloc] init];
    _searchText.translatesAutoresizingMaskIntoConstraints = NO;
    _searchText.placeholder = NSLocalizedStringFromTable(@"輸入代碼或名稱", @"SecuritySearch", nil);
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.font = [UIFont systemFontOfSize:20.0f];
    [_searchText addTarget:self action:@selector(search:) forControlEvents:UIControlEventEditingChanged];
    _searchText.delegate = self;
    [self.view addSubview:_searchText];
    _searchText.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchText.clearButtonMode = UITextFieldViewModeAlways;
    [self.view addSubview:_searchText];
    
    self.searchBtn = [self.view newButton:FSUIButtonTypeNormalRed];
    _searchBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchBtn setTitle:NSLocalizedStringFromTable(@"搜尋", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = [NSString stringWithFormat:@"%d Stock selected",userCount];//NSLocalizedStringFromTable(@"由下列標的物選取股票", @"SecuritySearch", nil);
    _titleLabel.textColor = [UIColor blueColor];
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_titleLabel];

    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    aFlowLayout.itemSize = CGSizeMake(308, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    _collectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:aFlowLayout rowCount:1];
    _collectionView.btnFlag=1;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionView.myDelegate = self;
    _collectionView.searchGroup =1;
    
    _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
    _collectionView.aligment = UIControlContentHorizontalAlignmentLeft;
    
    [self.view addSubview:_collectionView];

    self.bottomLabel = [[UILabel alloc]init];
    _bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomLabel.text = NSLocalizedStringFromTable(@"橘色為已加入自選股", @"SecuritySearch", nil);
    _bottomLabel.textColor = [UIColor blueColor];
    _bottomLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.view addSubview:_bottomLabel];
    
    self.noStockLabel = [[UILabel alloc]init];
    _noStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noStockLabel.text = NSLocalizedStringFromTable(@"無相符個股", @"SecuritySearch", nil);
    _noStockLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_noStockLabel];
    _noStockLabel.hidden = YES;
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_searchText , _searchBtn, _titleLabel,_collectionView,_bottomLabel);
    NSMutableArray *constraints = [[NSMutableArray alloc] initWithCapacity:10];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_searchText(44)]-2-[_titleLabel]-2-[_collectionView]-2-[_bottomLabel(25)]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_searchBtn(44)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_searchText]-2-[_searchBtn(65)]-5-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_collectionView]-3-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    [self replaceCustomizeConstraints:constraints];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
    self.mainDict = [[NSMutableDictionary alloc] init];
    [self.mainDict setObject:[NSNumber numberWithInt:1] forKey:@"UserGroupNum"];
    [self.mainDict writeToFile:path atomically:YES];

    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchNum] waitUntilDone:NO];
}

-(void)reSearch{
    _searchGroupId = _searchNum;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchNum] waitUntilDone:NO];
}

#pragma mark - TextField Auto Stocks Search
-(void)search:(UITextField *)textField{
    NSString *newString = [textField.text uppercaseString];
    textField.text = newString;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    if (![textField.text isEqual:@""]) {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockWithName:) onThread:dataModal.thread withObject:textField.text waitUntilDone:NO];
        userCount = [dataModal.securitySearchModel searchUserStockWithName:textField.text Group:_searchGroupId];
        if (userCount>1) {
            _titleLabel.text = [NSString stringWithFormat:@"%d Stocks selected",userCount];
        }else{
            _titleLabel.text = [NSString stringWithFormat:@"%d Stock selected",userCount];
        }
        
        _noStockLabel.hidden = YES;
    }else{
        userCount = 0;
         _titleLabel.text = [NSString stringWithFormat:@"%d Stock selected",userCount];
        [_dataArray removeAllObjects];
        [self reloadBtn];
        _noStockLabel.hidden = YES;
    }
    [self.view setNeedsUpdateConstraints];
    
}

-(void)notifyDataArrive:(NSMutableArray *)array{ //設定TABLE顯示內容
    _dataNameArray = [array objectAtIndex:0];
    _dataIdArray = [array objectAtIndex:1];
    if (_clickNum !=0) {
        [_dataArray removeAllObjects];
        for (int i=0; i<[_dataIdArray count]; i++) {
            [_dataArray addObject:[NSString stringWithFormat:@" %@    %@",[_dataIdArray objectAtIndex:i],[_dataNameArray objectAtIndex:i]]];
        }
        [self reloadBtn];
        
    if ([[array objectAtIndex:0]count]==0) {
        _noStockLabel.hidden = NO;
    }
        [self.view hideHUD];
    }else{
        _groupDataIdArray = _dataIdArray;
        [self search:_searchText];
    }
}

-(void)notifyArrive:(NSMutableArray *)array{
    _dataNameArray=[array objectAtIndex:0];
    _dataIdArray = [array objectAtIndex:1];
    _dataIdentCodeArray = [array objectAtIndex:2];
    
    _searchGroupId = _searchNum;
    [_dataArray removeAllObjects];
    for (int i=0; i<[_dataIdArray count]; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@" %@    %@",[_dataIdArray objectAtIndex:i],[_dataNameArray objectAtIndex:i]]];
    }
    _chooseArray = [self changeBtnColor];
    [self reloadBtn];
    
    if ([[array objectAtIndex:0]count]==0) {
        _noStockLabel.hidden = NO;
    }else{
        _noStockLabel.hidden = YES;
    }
    [self.view hideHUD];
    
}

-(NSMutableArray *)changeBtnColor{
    NSMutableArray * array = [[NSMutableArray alloc]init];
    for (int i=0; i<[_dataIdArray count]; i++) {
        for (int j=0; j<[_groupDataIdArray count]; j++) {
            if ([[_dataIdArray objectAtIndex:i] isEqualToString:[_groupDataIdArray objectAtIndex:j]]) {
                [array addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    return array;
}

-(void)reloadBtn{
    _collectionView.btnArray=_dataArray;
    _collectionView.chooseArray = _chooseArray;
    _collectionView.holdBtn = 99999;
    [_collectionView reloadData];
}

#pragma mark - Search Button Action
-(void)searchBtnClick{
    [_searchText resignFirstResponder];
    if (![_searchText.text isEqual:@""]) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModal.thread withObject:_searchText.text waitUntilDone:NO];
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self registerTickDataNotificationCallBack:self seletor:@selector(TickDataNotification)];
    [self registerLoginNotificationCallBack:self seletor:@selector(TickDataNotification)];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setEditChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(countUserStock) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self unRegisterTickDataNotificationCallBack:nil];
    [self unregisterLoginNotificationCallBack:nil];
}

-(void)totalCount:(NSNumber *)count{
    _totalCount = [count intValue];
    _bottomLabel.text =[NSString stringWithFormat:@"(%@)",NSLocalizedStringFromTable(@"橘色為已加入自選股", @"SecuritySearch", nil)];
}

-(void)editTotalCount:(NSNumber *)count{
    _totalCount += [count intValue];
    _bottomLabel.text =[NSString stringWithFormat:@"(%@)",NSLocalizedStringFromTable(@"橘色為已加入自選股", @"SecuritySearch", nil)];
}


-(void)titleButtonClick:(FSUIButton *)button{
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSMutableArray * array = [[NSMutableArray alloc]init];
    [array addObject:[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]]];
    [array addObject:[NSNumber numberWithInt:_searchGroupId]];
    if (button.selected == YES) {
        button.selected = NO;
        button.titleLabel.textColor = [UIColor blackColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //delete 自選股
        [self.chooseArray removeObject:[NSNumber numberWithInteger:button.tag]];
        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]]];
        [dataModal.portfolioData RemoveItem:secu->identCode andSymbol:secu->symbol];
        [self editTotalCount:[NSNumber numberWithInt:-1]];
        [_groupDataIdArray removeObject:[_dataIdArray objectAtIndex:button.tag]];
        _totalCount-=1;
        userCount-=1;
    }else{
        if (_totalCount/2<[[FSFonestock sharedInstance]portfolioQuota]) {
            button.selected = YES;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //判斷是否已存在 如已加入則修改
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            [dataModal.securitySearchModel setEditChooseTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(editUserStock:) onThread:dataModal.thread withObject:array waitUntilDone:NO];
            [self.chooseArray addObject:[NSNumber numberWithInteger:button.tag]];
            
            SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]]];
            _identSymbol = [NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]];
            [dataModal.portfolioData AddItem:secu];
            [_groupDataIdArray addObject:[_dataIdArray objectAtIndex:button.tag]];
            _totalCount+=1;
            userCount+=1;
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"警告", @"SecuritySearch", nil) message:NSLocalizedStringFromTable(@"自選股已達上限", @"SecuritySearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"SecuritySearch", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
    if (userCount>1) {
        _titleLabel.text = [NSString stringWithFormat:@"%d Stocks selected",userCount];
    }else{
        _titleLabel.text = [NSString stringWithFormat:@"%d Stock selected",userCount];
    }

}

-(void)TickDataNotification{
    PortfolioTick *tickBank_P = [[FSDataModelProc sharedInstance]portfolioTickBank];
    
    if (_identSymbol != nil) {
        [tickBank_P goGetTickByIdentSymbolForStock:_identSymbol];
        
    }
    
}

@end
