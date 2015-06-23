//
//  AmericaStockSettingViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/14.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "AmericaStockSettingViewController.h"
#import "AmericaEditChooseViewController.h"
#import "AmericaEditConditionViewController.h"
#import "KxMenu.h"
#import "FSTeachPopView.h"
//#import "FSPopoverController.h"
#import "FigureSearchMyProfileModel.h"
#import "CXAlertView.h"


@interface AmericaStockSettingViewController ()
@property (strong , nonatomic) UIButton * backBtn;
@property (strong) FSUIButton * selectType;
@property (strong) FSUIButton * changeName;
@property (strong)UITextField * searchText;
@property (strong)FSUIButton * searchBtn;
@property (strong)NSMutableDictionary * objDictionary;

@property (strong) AmericaEditChooseViewController * editChoose;
@property (strong) AmericaEditConditionViewController * editCondition;

//@property (strong) FSPopoverController * changeNamePopover;
@property (strong) UIScrollView * popOverScrollView;

@property (strong) NSString * stringV;
@property (strong) NSString * stringH;

@property (strong) NSMutableArray * dataNameArray;
@property (strong) NSMutableArray * dataIdArray;

@property (strong) NSMutableArray * groupDataIdArray;//自選群組內的股票id

@property (strong) NSMutableArray * categoryArray;
@property (strong) NSMutableArray * editCategoryArray;
@property (strong) NSMutableArray * groupIdArray;

@property (nonatomic)int searchNum;
@property (nonatomic)int searchType;//0=table,1 = btnCollectionView
@property (nonatomic)int clickNum;//0=groupBtn,1=searchBtn

@property (nonatomic)int chooseCount;

@property (strong, nonatomic) FSTeachPopView * explainView;

@property (strong, nonatomic) FigureSearchMyProfileModel * customModel;

@property (nonatomic, strong) NSMutableDictionary *mainDict;
@end

@implementation AmericaStockSettingViewController

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
    [self.navigationController setNavigationBarHidden:YES];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    [self initView];
    
    
}

-(void)initView{
    
    self.dataNameArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    self.groupDataIdArray = [[NSMutableArray alloc]init];
    self.editCategoryArray = [[NSMutableArray alloc]init];
    self.objDictionary = [[NSMutableDictionary alloc]init];
    
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(_mainDict){
        self.searchNum = [(NSNumber *)[_mainDict objectForKey:@"UserGroupNum"]intValue];
    }else{
        _searchNum = 0;
    }
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_objDictionary setObject:_backBtn forKey:@"_backBtn"];
    [self.view addSubview:_backBtn];

    self.selectType = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _selectType.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_selectType];
    [_objDictionary setObject:_selectType forKey:@"_selectType"];
    
    self.changeName = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _changeName.translatesAutoresizingMaskIntoConstraints = NO;
    [_changeName setTitle:NSLocalizedStringFromTable(@"變更群組名稱", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_changeName addTarget:self action:@selector(changeNameClick) forControlEvents:UIControlEventTouchUpInside];
    _changeName.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.view addSubview:_changeName];
    [_objDictionary setObject:_changeName forKey:@"_changeName"];
    
    self.searchText = [[UITextField alloc]init];
    _searchText.placeholder = NSLocalizedStringFromTable(@"輸入代碼或名稱", @"SecuritySearch", nil);
    _searchText.translatesAutoresizingMaskIntoConstraints = NO;
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.font = [UIFont systemFontOfSize:20.0f];
    [_searchText addTarget:self action:@selector(search:) forControlEvents:UIControlEventEditingChanged];
    _searchText.delegate = self;
    [self.view addSubview:_searchText];
    _searchText.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchText.clearButtonMode = UITextFieldViewModeAlways;
    [_objDictionary setObject:_searchText forKey:@"_searchText"];
    
    self.searchBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _searchBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchBtn setTitle:NSLocalizedStringFromTable(@"搜尋", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBtn];
    [_objDictionary setObject:_searchBtn forKey:@"_searchBtn"];
    
    self.editChoose =[[AmericaEditChooseViewController alloc]init];
    _editChoose.view.translatesAutoresizingMaskIntoConstraints = NO;
    _editChoose.delegate = self;
    [self addChildViewController:_editChoose];
    [self.view addSubview:_editChoose.view];
    [_objDictionary setObject:_editChoose.view forKey:@"_editChoose"];
    
    self.editCondition =[[AmericaEditConditionViewController alloc]init];
    _editCondition.view.translatesAutoresizingMaskIntoConstraints = NO;
    _editCondition.delegate = self;
    [self addChildViewController:_editCondition];
    [self.view addSubview:_editCondition.view];
    [_objDictionary setObject:_editCondition.view forKey:@"_editCondition"];
    
    if ([FSUtility isGraterThanSupportVersion:7]) {
        _stringV = @"V:|-25-[_backBtn]-5-[_searchText]-2-[_editCondition]|";
    }else{
        _stringV = @"V:|-5-[_backBtn]-5-[_searchText]-2-[_editCondition]|";
    }
    
    _stringH = @"H:|[_editCondition]|";
    
    [self.view setNeedsUpdateConstraints];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString * show = [_customModel searchInstructionByControllerName:[[self class] description]];
    if ([show isEqualToString:@"YES"]) {
        [self teachPop];
    }
}

- (void)updateViewConstraints {
    
    [self.view removeConstraints:self.view.constraints];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:_stringV options:0 metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_searchText]-5-[_searchBtn(65)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backBtn(44)][_selectType][_changeName(80)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_backBtn(44)]" options:0 metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_selectType(44)]" options:0 metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_changeName(44)]" options:0 metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:_stringH options:0 metrics:nil views:_objDictionary]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_bottomLabel]-5-|" options:0 metrics:nil views:_objDictionary]];

    [super updateViewConstraints];
}

-(void)backBtnClick{
    if (_searchType == 0) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self addAllGroup];
        [_editCondition willMoveToParentViewController:nil];
        
        [self transitionFromViewController:_editChoose toViewController:_editCondition duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
            if ([FSUtility isGraterThanSupportVersion:7]) {
                _stringV = @"V:|-25-[_backBtn]-5-[_searchText(38)]-2-[_editCondition]|";
            }else{
                _stringV = @"V:|-5-[_backBtn]-5-[_searchText(38)]-2-[_editCondition]|";
            }
            
            _stringH = @"H:|[_editCondition]|";
            _searchType = 0;
            [self.view setNeedsUpdateConstraints];
        }];
        _searchText.text = @"";
        [_editChoose.dataArray removeAllObjects];
        [_editChoose reloadBtn];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [_searchText resignFirstResponder];
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: _searchNum];
        [_editCondition.mainTableView reloadData];
        [dataModal.securitySearchModel setChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchNum] waitUntilDone:NO];
    }
}


-(void)changeNameClick{
    [_editCategoryArray removeAllObjects];
    self.popOverScrollView = [[UIScrollView alloc]init];
    _popOverScrollView.delegate = self;
    _popOverScrollView.backgroundColor = [UIColor whiteColor];
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 10.0f, 200.0f, 28.0f)];
    titleLabel.text = NSLocalizedStringFromTable(@"請輸入新的自訂群組名稱", @"SecuritySearch", nil);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    
    for (int i = 1; i<[_categoryArray count]; i++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(20, 10+(50*(i-1)), 30.0f, 28.0f)];
        label.text = [NSString stringWithFormat:@"%d.",i];
        label.backgroundColor = [UIColor clearColor];
        [_popOverScrollView addSubview:label];
        
        UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(50, 10+(50*(i-1)), 200.0f, 35.0f)];
        textField.text = [_categoryArray objectAtIndex:i];
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [_popOverScrollView addSubview:textField];
        [_editCategoryArray addObject:textField];
        
    }
    
    [_popOverScrollView setContentSize:CGSizeMake(280, 46*[_categoryArray count])];
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 300)];
    }else{
        [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 380)];
    }
    
    CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:nil contentView:_popOverScrollView cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    alertView.contentScrollViewMaxHeight = 380;
    alertView.contentScrollViewMinHeight = 300;
    [alertView.contentView setFrame:CGRectMake(0, 0, 280, 380)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"確認", @"SecuritySearch", nil) type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        [self btnClick];
        [alertView dismiss];
    }];
    [alertView show];
}


-(void)btnClick{

    NSMutableArray * noText = [[NSMutableArray alloc]init];
    for (int i =0; i<[_editCategoryArray count]; i++) {
        UITextField * text = [[UITextField alloc]init];
        text = [_editCategoryArray objectAtIndex:i];
        if ([text.text isEqualToString:@""]) {
            [noText addObject:[NSNumber numberWithInt:i]];
        }
        
    }
    if ([noText count]>0) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"錯誤", @"SecuritySearch", nil) message:NSLocalizedStringFromTable(@"名稱不可為空白", @"SecuritySearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"SecuritySearch", nil) otherButtonTitles:nil];
        [alert show];
    }else{
        NSMutableArray * changeNameArray = [[NSMutableArray alloc]init];
        for (int i =0; i<[_editCategoryArray count]; i++) {
            UITextField * text = [[UITextField alloc]init];
            text = [_editCategoryArray objectAtIndex:i];
            if (![text.text isEqualToString:[_categoryArray objectAtIndex:i+1]]) {
                NSMutableArray * data = [[NSMutableArray alloc]init];//新名,舊名,id
                [data addObject:text.text];
                [data addObject:[_categoryArray objectAtIndex:i+1]];
                [data addObject:[_groupIdArray objectAtIndex:i+1]];
                [changeNameArray addObject:data];
            }
        }
        if ([changeNameArray count]>0) {
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            [dataModal.securitySearchModel setEditChooseTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(updateUserGroupName:) onThread:dataModal.thread withObject:changeNameArray waitUntilDone:NO];
        }
    
    }
    
}

-(void)updateGroupName{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
    self.mainDict = [[NSMutableDictionary alloc] init];
    [self.mainDict setObject:[NSNumber numberWithInt:1] forKey:@"UserGroupNum"];
    [self.mainDict writeToFile:path atomically:YES];
    if ([textField isEqual:_searchText]) {
        [self removeAllGroup];
        [_editChoose.dataArray removeAllObjects];
        [_editChoose willMoveToParentViewController:nil];
        
        [self transitionFromViewController:_editCondition toViewController:_editChoose duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
            if ([FSUtility isGraterThanSupportVersion:7]) {
                _stringV = @"V:|-25-[_backBtn]-5-[_searchText(38)]-2-[_editChoose]|";
            }else{
                _stringV = @"V:|-5-[_backBtn]-5-[_searchText(38)]-2-[_editChoose]|";
            }
            
            _stringH = @"H:|[_editChoose]|";
            
            [self.view setNeedsUpdateConstraints];
        }];
        _searchType = 1;
        _clickNum = 0;
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        if(_searchNum!=0){
            [dataModal.portfolioData selectGroupID: _searchNum];
            [_selectType setTitle:[_categoryArray objectAtIndex:_searchNum-1] forState:UIControlStateNormal];
        }else{
            _searchNum = 1;
            [dataModal.portfolioData selectGroupID: _searchNum];
            [_selectType setTitle:[_categoryArray objectAtIndex:0] forState:UIControlStateNormal];
        }
        [dataModal.securitySearchModel setChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchNum] waitUntilDone:NO];
    }else{
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 300)];
            if (textField.frame.origin.y > 150) {
                [_popOverScrollView setContentOffset:CGPointMake(0,textField.frame.origin.y-30 )  animated:NO];
            }
        }else{
            [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 380)];
            if (textField.frame.origin.y > 150) {
                [_popOverScrollView setContentOffset:CGPointMake(0,textField.frame.origin.y-100 )  animated:NO];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _searchText.text = @"";
    
    [_searchText resignFirstResponder];
    
    [_editCondition willMoveToParentViewController:nil];
    
    [self transitionFromViewController:_editChoose toViewController:_editCondition duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        if ([FSUtility isGraterThanSupportVersion:7]) {
            _stringV = @"V:|-25-[_backBtn]-5-[_searchText(38)]-2-[_editCondition]|";

        }else{
            _stringV = @"V:|-5-[_backBtn]-5-[_searchText(38)]-2-[_editCondition]|";

        }
        _stringH = @"H:|[_editCondition]|";
        _searchType = 0;
        [self.view setNeedsUpdateConstraints];
    }];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)addAllGroup{
    [_categoryArray insertObject:NSLocalizedStringFromTable(@"全部", @"SecuritySearch", nil) atIndex:0];
    [_groupIdArray insertObject:[NSNumber numberWithInt:0] atIndex:0];
    [_selectType addTarget:self action:@selector(selectTypeClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)removeAllGroup{
    [_categoryArray removeObject:NSLocalizedStringFromTable(@"全部", @"SecuritySearch", nil)];
    [_groupIdArray removeObject:[NSNumber numberWithInt:0]];
    [_selectType addTarget:self action:@selector(selectTypeClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)groupNotifyDataArrive:(NSMutableArray *)array{ //查詢自選群組名之結果
    _categoryArray = [array objectAtIndex:0];
    _groupIdArray = [array objectAtIndex:1];
    [self addAllGroup];
    [_selectType setTitle:[_categoryArray objectAtIndex:0] forState:UIControlStateNormal];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];
    if (_searchNum !=0) {
        [_selectType setTitle:[_categoryArray objectAtIndex:_searchNum] forState:UIControlStateNormal];
        _searchNum = [(NSNumber *)[_groupIdArray objectAtIndex:_searchNum]intValue];
    }
    [dataModal.portfolioData selectGroupID: _searchNum];
    [_editCondition.mainTableView reloadData];
    //[dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchNum] waitUntilDone:NO];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex <[_categoryArray count]) {
        NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
        self.mainDict = [[NSMutableDictionary alloc] init];
        
        self.searchNum =[(NSNumber *)[self.groupIdArray objectAtIndex:buttonIndex]intValue];
        [self.mainDict setObject:[NSNumber numberWithInt:self.searchNum] forKey:@"UserGroupNum"];
        [self.mainDict writeToFile:path atomically:YES];
        if (self.searchType ==1) {
            self.clickNum = 0;
        }
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: self.searchNum];
        [self.editCondition.mainTableView reloadData];
        
        [_selectType setTitle:[self.categoryArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
    
}


- (void)selectTypeClick {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"群組", @"SecuritySearch", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for (i=0;i<[_categoryArray count];i++) {
        NSString * title = [_categoryArray objectAtIndex:i];
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [actionSheet setCancelButtonIndex:i];
    [self showActionSheet:actionSheet];
    
    
}

-(void)setTarget:(id)obj
{
    
}


-(void)search:(UITextField *)textField{
    NSString *newString = [textField.text uppercaseString];
    textField.text = newString;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    if (![textField.text isEqual:@""]) {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockWithName:) onThread:dataModal.thread withObject:textField.text waitUntilDone:NO];
        _editChoose.noStockLabel.hidden = YES;
    }else{
        [_editChoose.dataArray removeAllObjects];
        [_editChoose reloadBtn];
        _editChoose.noStockLabel.hidden = YES;
    }
    [self.view setNeedsUpdateConstraints];
    
}

-(void)searchBtnClick{
    [_searchText resignFirstResponder];
    _clickNum =1;
    if (![_searchText.text isEqual:@""]) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModal.thread withObject:_searchText.text waitUntilDone:NO];
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
        
    }
    
}

-(void)notifyDataArrive:(NSMutableArray *)array{ //設定TABLE顯示內容
    _dataNameArray = [array objectAtIndex:0];
    _dataIdArray = [array objectAtIndex:1];
    if (_searchType ==0) {
        _editCondition.dataArray =_dataIdArray;
        [_editCondition.mainTableView reloadData];
    }else{
        if (_clickNum !=0) {
            [_editChoose.dataArray removeAllObjects];
            for (int i=0; i<[_dataIdArray count]; i++) {
                [_editChoose.dataArray addObject:[NSString stringWithFormat:@" %@    %@",[_dataIdArray objectAtIndex:i],[_dataNameArray objectAtIndex:i]]];
            }
            [_editChoose reloadBtn];
            
            if ([[array objectAtIndex:0]count]==0) {
                _editChoose.noStockLabel.hidden = NO;
            }
            [self.view hideHUD];
        }else{
            _groupDataIdArray = _dataIdArray;
            [self search:_searchText];
        }
    }
}

-(void)notifyArrive:(NSMutableArray *)array{
    _dataNameArray=[array objectAtIndex:0];
    _dataIdArray = [array objectAtIndex:1];
    _editChoose.dataIdArray = _dataIdArray;
    _editChoose.dataIdentCodeArray = [array objectAtIndex:2];

    _editChoose.searchGroupId = _searchNum;
    [_editChoose.dataArray removeAllObjects];
    for (int i=0; i<[_dataIdArray count]; i++) {
        [_editChoose.dataArray addObject:[NSString stringWithFormat:@" %@    %@",[_dataIdArray objectAtIndex:i],[_dataNameArray objectAtIndex:i]]];
    }
    _editChoose.chooseArray = [self changeBtnColor];
    [_editChoose reloadBtn];
    
    if ([[array objectAtIndex:0]count]==0) {
        _editChoose.noStockLabel.hidden = NO;
    }else{
        _editChoose.noStockLabel.hidden = YES;
    }
    [self.view hideHUD];
    
}

-(NSMutableArray *)changeBtnColor{
    NSMutableArray * array = [[NSMutableArray alloc]init];
    for (int i=0; i<[_dataIdArray count]; i++) {
        for (int j=0; j<[_groupDataIdArray count]; j++) {
            if ([[_dataIdArray objectAtIndex:i] isEqual:[_groupDataIdArray objectAtIndex:j]]) {
                [array addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    return array;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (![textField isEqual:_searchText]) {
        int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
        if (screenHeight==460) {
            [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 300)];
        }else{
            [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 380)];
        }
    }
    return YES;
}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];
    
    [_explainView showMenuWithRect:CGRectMake(50, 80, 0, 0) String:NSLocalizedStringFromTable(@"輸入搜尋條件", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView showMenuWithRect:CGRectMake(150, 210, 0, 0) String:NSLocalizedStringFromTable(@"設定警示條件", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView showMenuWithRect:CGRectMake(20, 330, 0, 0) String:NSLocalizedStringFromTable(@"刪除", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(20, 280, 30, 56)];
    [_explainView showMenuWithRect:CGRectMake(300, 370, 0, 0) String:NSLocalizedStringFromTable(@"長按移動", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handLongTap"Rect:CGRectMake(285, 330, 30, 39)];
    
}

//存資料庫
-(void)closeTeachPop:(UIView *)view{
    [view removeFromSuperview];
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    if (teachPopView.checkBtn.selected) {
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"NO"];
    }else{
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"YES"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
