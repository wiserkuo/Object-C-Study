//
//  FSActionPlanSettingViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/5/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionPlanSettingViewController.h"
#import "FSActionEditCondictionViewController.h"
#import "FSActionEditChooseViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FigureSearchMyProfileModel.h"
#import "FSActionPlanViewController.h"
#import "CXAlertView.h"
#import "TaiwanStockViewController.h"


#import "TaiwanStockListViewController.h"
@interface FSActionPlanSettingViewController ()<UIActionSheetDelegate, UITextFieldDelegate,SecuritySearchDelegate>{
    FSUIButton *groupButton;
    FSUIButton *addSymbolButton;
    FSUIButton *backButton;
    UITableView *mainTableView;
    UIAlertView * errorAlert;
    BOOL alertFlag;
}
@property (strong)NSMutableDictionary * objDictionary;
@property (strong, nonatomic) NSMutableDictionary *mainDict;
@property (strong) NSMutableArray * groupIdArray;
@property (strong) NSMutableArray * categoryArray;
@property (strong) NSString * stringV;
@property (strong) NSString * stringH;
@property (strong) NSString * stringBtnH;
@property (nonatomic)int searchNum;
@property (nonatomic)int searchType;//0=table,1 = btnCollectionView
@property (strong) FSActionEditCondictionViewController *actionEditCondition;
@property (strong) FSActionEditChooseViewController *actionEditChoose;
@property (strong, nonatomic) FigureSearchMyProfileModel *customModel;

@property (strong) UIScrollView * popOverScrollView;
@property (strong) NSMutableArray * editCategoryArray;
@property (strong) FSUIButton * changeName;
@end

@implementation FSActionPlanSettingViewController

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
	// Do any additional setup after loading the view.
    [self setupNavigationBar];
    [self setupView];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [_actionEditCondition willMoveToParentViewController:nil];
    _searchType = 0;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
    
}

#pragma mark - Set up views
-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Setting", @"ActionPlan", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self setUpImageBackButton];

    self.navigationItem.hidesBackButton = YES;
}

-(void)setupView{
    self.objDictionary = [[NSMutableDictionary alloc]init];
    self.editCategoryArray = [[NSMutableArray alloc]init];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
    _mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(_mainDict){
        _searchNum = [(NSNumber *)[_mainDict objectForKey:@"UserGroupNum"]intValue];
    }else{
        _searchNum = 0;
    }
    groupButton = [self.view newButton:FSUIButtonTypeBlueGreenDetailButton];
    [groupButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_objDictionary setObject:groupButton forKey:@"groupButton"];
    
    addSymbolButton = [self.view newButton:FSUIButtonTypeNormalBlue];
    [addSymbolButton setTitle:NSLocalizedStringFromTable(@"Add Symbols", @"watchlists", nil) forState:UIControlStateNormal];
    [addSymbolButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [addSymbolButton addTarget:self action:@selector(addSymbols) forControlEvents:UIControlEventTouchUpInside];
    [_objDictionary setObject:addSymbolButton forKey:@"addSymbolButton"];

    self.actionEditCondition =[[FSActionEditCondictionViewController alloc]init];
    _actionEditCondition.view.translatesAutoresizingMaskIntoConstraints = NO;
    _actionEditCondition.delegate = self;
    [self addChildViewController:_actionEditCondition];
    [self.view addSubview:_actionEditCondition.view];
    [_objDictionary setObject:_actionEditCondition.view forKey:@"_actionEditCondition"];

    self.changeName = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _changeName.translatesAutoresizingMaskIntoConstraints = NO;
    [_changeName setTitle:NSLocalizedStringFromTable(@"變更群組名稱", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_changeName addTarget:self action:@selector(changeNameClick) forControlEvents:UIControlEventTouchUpInside];
    _changeName.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.view addSubview:_changeName];
    [_objDictionary setObject:_changeName forKey:@"_changeName"];
    
    backButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlackLeftArrow];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [_objDictionary setObject:backButton forKey:@"_groupTitleLabel"];
    
    _stringV = @"V:|-40-[_actionEditCondition]|";
    _stringH = @"H:|[_actionEditCondition]|";
    addSymbolButton.hidden = NO;
    _changeName.hidden = YES;
    backButton.hidden = YES;
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSMutableArray *constraints  =[[NSMutableArray alloc] initWithCapacity:10];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:_stringV options:0 metrics:nil views:_objDictionary]];

    if (addSymbolButton.hidden) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_groupTitleLabel(44)]-5-[groupButton]-5-[_changeName(100)]-5-|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:_objDictionary]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[groupButton][addSymbolButton(groupButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_objDictionary]];
    }

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:_stringH options:0 metrics:nil views:_objDictionary]];
    
    [self replaceCustomizeConstraints:constraints];
}

#pragma mark - Back Button Action
-(void)backBtnClick{
    if (_searchType == 0) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self addAllGroup];
        [_actionEditCondition willMoveToParentViewController:nil];
        [self.navigationController setNavigationBarHidden:NO];
        [self transitionFromViewController:_actionEditChoose toViewController:_actionEditCondition duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
            _searchType = 0;
            
            _stringV = @"V:|-40-[_actionEditCondition]|";
            _stringH = @"H:|[_actionEditCondition]|";
            addSymbolButton.hidden = NO;
            _changeName.hidden = YES;
            backButton.hidden = YES;
            [self.view setNeedsUpdateConstraints];
        }];
        [_actionEditChoose.dataArray removeAllObjects];
        [_actionEditChoose reloadBtn];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: _searchNum];
        [_actionEditCondition.mainTableView reloadData];
        [dataModal.securitySearchModel setChooseTarget:self];
    }
}

#pragma mark - GroupButton
-(void)addAllGroup{
    //Setting view can select all stocks
    [_categoryArray insertObject:NSLocalizedStringFromTable(@"全部", @"SecuritySearch", nil) atIndex:0];
    [_groupIdArray insertObject:[NSNumber numberWithInt:0] atIndex:0];
    [groupButton addTarget:self action:@selector(groupButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)removeAllGroup{
    [_categoryArray removeObject:NSLocalizedStringFromTable(@"全部", @"SecuritySearch", nil)];
    [_groupIdArray removeObject:[NSNumber numberWithInt:0]];
    [groupButton addTarget:self action:@selector(groupButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)groupNotifyDataArrive:(NSMutableArray *)array{ //查詢自選群組名之結果
    _categoryArray = [array objectAtIndex:0];
    _groupIdArray = [array objectAtIndex:1];
    if(alertFlag){
        [self removeAllGroup];
        
    }else{
        [self addAllGroup];
    }
    [groupButton setTitle:[_categoryArray objectAtIndex:0] forState:UIControlStateNormal];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];

    if(alertFlag){
        [groupButton setTitle:[_categoryArray objectAtIndex:_searchNum-1] forState:UIControlStateNormal];
    }else{
        [groupButton setTitle:[_categoryArray objectAtIndex:_searchNum] forState:UIControlStateNormal];
        _searchNum = [(NSNumber *)[_groupIdArray objectAtIndex:_searchNum]intValue];
    }
    [dataModal.portfolioData selectGroupID: _searchNum];
    [_actionEditCondition.mainTableView reloadData];
    alertFlag = NO;
    
}

- (void)groupButtonClick {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"群組", @"SecuritySearch", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for (i = 0; i < [_categoryArray count]; i++) {
        NSString * title = [_categoryArray objectAtIndex:i];
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [actionSheet setCancelButtonIndex:i];
    [self showActionSheet:actionSheet];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex <[_categoryArray count]) {
        NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
        self.mainDict = [[NSMutableDictionary alloc] init];
        self.searchNum =[(NSNumber *)[self.groupIdArray objectAtIndex:buttonIndex]intValue];
        [self.mainDict setObject:[NSNumber numberWithInt:self.searchNum] forKey:@"UserGroupNum"];
        [self.mainDict writeToFile:path atomically:YES];

        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: self.searchNum];
        [self.actionEditCondition.mainTableView reloadData];
        self.actionEditChoose.searchNum = _searchNum;
        [self.actionEditChoose reSearch];
        [groupButton setTitle:[self.categoryArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
    if([[FSFonestock sharedInstance] checkNeedShowAdvertise]){
        if([[UIApplication sharedApplication] statusBarOrientation]== UIInterfaceOrientationLandscapeLeft){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 64, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-50);
        }
    }
}

#pragma mark - Add Symbols Button Action
-(void)addSymbols{
    [self removeAllGroup];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW || [FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        
        TaiwanStockViewController * twStockView = [[TaiwanStockViewController alloc]init];
        
        //        twStockView.view.translatesAutoresizingMaskIntoConstraints = NO;
        twStockView.searchGroup = _searchNum;
        twStockView.delegate = self;
        
        [self.navigationController pushViewController:twStockView animated:NO];
        //        [self addChildViewController:twStockView];
        //        [self.view addSubview:twStockView.view];
        //        [_objDictionary setObject:twStockView.view forKey:@"_actionEditChoose"];
        
        //        [self transitionFromViewController:_actionEditCondition toViewController:twStockView duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        //            _stringV = @"V:|-45-[_actionEditChoose]|";
        //            _stringH = @"H:|[_actionEditChoose]|";
        //            addSymbolButton.hidden = YES;
        //            _changeName.hidden = NO;
        //            [self.view setNeedsUpdateConstraints];
        //        }];
    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        
        self.actionEditChoose =[[FSActionEditChooseViewController alloc]init];
        _actionEditChoose.view.translatesAutoresizingMaskIntoConstraints = NO;
        _actionEditChoose.delegate = self;
        _actionEditChoose.searchGroupId = _searchNum;
        _actionEditChoose.searchNum = _searchNum;
        [self addChildViewController:_actionEditChoose];
        [self.view addSubview:_actionEditChoose.view];
        [_objDictionary setObject:_actionEditChoose.view forKey:@"_actionEditChoose"];
        
        _searchType = 1;
        
        [self transitionFromViewController:_actionEditCondition toViewController:_actionEditChoose duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
            _stringV = @"V:|-22-[_groupTitleLabel(44)]-3-[_actionEditChoose]|";
            _stringH = @"H:|[_actionEditChoose]|";
            addSymbolButton.hidden = YES;
            _changeName.hidden = NO;
            backButton.hidden = NO;
            [self.view setNeedsUpdateConstraints];
        }];
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        if(_searchNum!=0){
            [dataModal.portfolioData selectGroupID: _searchNum];
            [groupButton setTitle:[_categoryArray objectAtIndex:_searchNum-1] forState:UIControlStateNormal];
        }else{
            _searchNum = 1;
            [dataModal.portfolioData selectGroupID: _searchNum];
            [groupButton setTitle:[_categoryArray objectAtIndex:0] forState:UIControlStateNormal];
        }
    }
}


-(void)reloadTable{
    [self.actionEditCondition.mainTableView reloadData];
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
    
    for (int i = 0; i<[_categoryArray count]; i++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(20, 10+(50*(i)), 30.0f, 28.0f)];
        label.text = [NSString stringWithFormat:@"%d.",i+1];
        label.backgroundColor = [UIColor clearColor];
        [_popOverScrollView addSubview:label];
        
        UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(50, 10+(50*(i)), 200.0f, 35.0f)];
        textField.text = [_categoryArray objectAtIndex:i];
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [_popOverScrollView addSubview:textField];
        [_editCategoryArray addObject:textField];
        
    }
    
    [_popOverScrollView setContentSize:CGSizeMake(280, 50*[_categoryArray count])];
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 50*[_categoryArray count])];
    }else{
        [_popOverScrollView setFrame:CGRectMake(0, 0, 280, 50*[_categoryArray count])];
    }
    
    CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"請輸入新的自訂群組名稱", @"SecuritySearch", nil) contentView:_popOverScrollView cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    alertView.contentScrollViewMaxHeight = 50*[_categoryArray count];
    alertView.contentScrollViewMinHeight = 50*[_categoryArray count];
    [alertView.contentView setFrame:CGRectMake(0, 0, 280, 50*[_categoryArray count])];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"確認", @"SecuritySearch", nil) type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        [alertView dismiss];
        [self btnClick];
        alertFlag = YES;
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
        errorAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"錯誤", @"SecuritySearch", nil) message:NSLocalizedStringFromTable(@"名稱不可為空白", @"SecuritySearch", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [errorAlert show];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(errorAlert) userInfo:nil repeats:NO];
    }else{
        NSMutableArray * changeNameArray = [[NSMutableArray alloc]init];
        for (int i =0; i<[_editCategoryArray count]; i++) {
            UITextField * text = [[UITextField alloc]init];
            text = [_editCategoryArray objectAtIndex:i];
            if (![text.text isEqualToString:[_categoryArray objectAtIndex:i]]) {
                NSMutableArray * data = [[NSMutableArray alloc]init];//新名,舊名,id
                [data addObject:text.text];
                [data addObject:[_categoryArray objectAtIndex:i]];
                [data addObject:[_groupIdArray objectAtIndex:i]];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return  YES;
}

-(void)errorAlert
{
    [errorAlert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
