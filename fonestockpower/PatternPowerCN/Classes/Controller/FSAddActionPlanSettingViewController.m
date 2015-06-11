//
//  FSAddActionPlanSettingViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/5/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAddActionPlanSettingViewController.h"
#import "FSAddActionEditCondictionViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FigureSearchMyProfileModel.h"
#import "FSActionPlanViewController.h"
#import "CXAlertView.h"
#import "UIViewController+CustomNavigationBar.h"

@interface FSAddActionPlanSettingViewController ()<UIActionSheetDelegate, UITextFieldDelegate,SecuritySearchDelegate>{
    FSUIButton *groupButton;
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
@property (strong) FSAddActionEditCondictionViewController *actionEditCondition;
@property (strong, nonatomic) FigureSearchMyProfileModel *customModel;

@property (strong) UIScrollView * popOverScrollView;
@property (strong) NSMutableArray * editCategoryArray;

@end

@implementation FSAddActionPlanSettingViewController

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
    [self setUpImageBackButton];
    [self setupNavigationBar];
    [self setupView];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    
    [self.view setNeedsUpdateConstraints];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_actionEditCondition willMoveToParentViewController:nil];
    _searchType = 0;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
}

#pragma mark - Set up views
-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Add from Watchlist", @"ActionPlan", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];
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

    self.actionEditCondition =[[FSAddActionEditCondictionViewController alloc]init];
    _actionEditCondition.view.translatesAutoresizingMaskIntoConstraints = NO;
    _actionEditCondition.delegate = self;
    _actionEditCondition.termStr = _termStr;
    [self addChildViewController:_actionEditCondition];
    [self.view addSubview:_actionEditCondition.view];
    [_objDictionary setObject:_actionEditCondition.view forKey:@"_actionEditCondition"];

    _stringV = @"V:|-44-[_actionEditCondition]|";
    _stringH = @"H:|[_actionEditCondition]|";

    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSMutableArray *layoutContraints = [[NSMutableArray alloc]init];
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:_stringV options:0 metrics:nil views:_objDictionary]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[groupButton]|" options:0 metrics:nil views:_objDictionary]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[groupButton]" options:0 metrics:nil views:_objDictionary]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:_stringH options:0 metrics:nil views:_objDictionary]];

    [self replaceCustomizeConstraints:layoutContraints];
}

#pragma mark - Back Button Action
-(void)backBtnClick{
    if (_searchType == 0) {
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self addAllGroup];
        [_actionEditCondition willMoveToParentViewController:nil];
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: _searchNum];
        [self reloadTable];
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
    [self reloadTable];
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

#pragma mark - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex <[_categoryArray count]) {
        NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"WatchListGroupMemory.plist"]];
        self.mainDict = [[NSMutableDictionary alloc] init];
        self.searchNum =[(NSNumber *)[self.groupIdArray objectAtIndex:buttonIndex]intValue];
        [self.mainDict setObject:[NSNumber numberWithInt:self.searchNum] forKey:@"UserGroupNum"];
        [self.mainDict writeToFile:path atomically:YES];

        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID: self.searchNum];
        [self reloadTable];
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
-(void)reloadTable{
    [_actionEditCondition reloadDataArray];
    [self.actionEditCondition.mainTableView reloadData];
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
