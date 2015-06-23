//
//  TaiwanStockViewController.m
//  Bullseye
//
//  Created by Neil on 13/9/16.
//
//

#import "TaiwanChangeStockViewController.h"
#import "TaiwanSearchStockViewController.h"
#import "TaiwanStockListViewController.h"
#import "CXAlertView.h"

@interface TaiwanChangeStockViewController ()<UIActionSheetDelegate, UIScrollViewDelegate>{
    UIScrollView * popOverScrollView;
    NSMutableArray * editCategoryArray;
}

@end

@implementation TaiwanChangeStockViewController

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
    editCategoryArray = [[NSMutableArray alloc]init];
    _groupIdArray = [[NSMutableArray alloc]init];
    _categoryArray = [[NSMutableArray alloc]init];
    [self initView];
	// Do any additional setup after loading the view.
}

-(void)initView{
    self.objDictionary = [[NSMutableDictionary alloc]init];
    
    self.searchText = [[UITextField alloc]init];
    _searchText.placeholder = NSLocalizedStringFromTable(@"輸入代碼或名稱", @"SecuritySearch", nil);
    _searchText.translatesAutoresizingMaskIntoConstraints = NO;
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.font = [UIFont systemFontOfSize:22.0f];
    [_searchText addTarget:self action:@selector(search:) forControlEvents:UIControlEventEditingChanged];
    _searchText.delegate = self;
    [self.view addSubview:_searchText];
    [_objDictionary setObject:_searchText forKey:@"_searchText"];
    
    self.searchBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _searchBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchBtn setTitle:NSLocalizedStringFromTable(@"搜尋", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBtn];
    [_objDictionary setObject:_searchBtn forKey:@"_searchBtn"];
    
    self.searchStockView =[[TaiwanSearchStockViewController alloc]init];
    _searchStockView.view.translatesAutoresizingMaskIntoConstraints = NO;
    _searchStockView.delegate = self;
    _searchStockView.changeStock = YES;
    [self addChildViewController:_searchStockView];
    [self.view addSubview:_searchStockView.view];
    [_objDictionary setObject:_searchStockView.view forKey:@"_searchStockView"];

    
    self.stockListView =[[TaiwanStockListViewController alloc]init];
    _stockListView.view.translatesAutoresizingMaskIntoConstraints = NO;
    _stockListView.delegate = self;
    _stockListView.changeStock = YES;
    [self addChildViewController:_stockListView];
    [self.view addSubview:_stockListView.view];
    [_objDictionary setObject:_stockListView.view forKey:@"_stockListView"];
    
    [_searchStockView.view removeFromSuperview];

    _stringV = @"V:|-2-[_searchText(35)]-2-[_stockListView]|";
    _stringH = @"H:|[_stockListView]|";
    
    [self.view setNeedsUpdateConstraints];
}

-(void)selectGroup{
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
        self.searchGroup =[(NSNumber *)[self.groupIdArray objectAtIndex:buttonIndex]intValue];
        _stockListView.searchGroup = _searchGroup;
        _searchStockView.searchGroup = _searchGroup;
        [_searchStockView setSearchGroup];
        [_stockListView setSearchGroup];
        [_groupBtn setTitle:[self.categoryArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }

}

-(void)reNameBtnClick{
    [editCategoryArray removeAllObjects];
    popOverScrollView = [[UIScrollView alloc]init];
    popOverScrollView.delegate = self;
    popOverScrollView.backgroundColor = [UIColor whiteColor];
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(45, 10.0f, 200.0f, 28.0f)];
    titleLabel.text = NSLocalizedStringFromTable(@"請輸入新的自訂群組名稱", @"SecuritySearch", nil);
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    
    for (int i = 0; i<[_categoryArray count]; i++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(20, 10+(50*(i)), 30.0f, 28.0f)];
        label.text = [NSString stringWithFormat:@"%d.",i+1];
        label.backgroundColor = [UIColor clearColor];
        [popOverScrollView addSubview:label];
        
        UITextField * textField = [[UITextField alloc]initWithFrame:CGRectMake(50, 10+(50*(i)), 200.0f, 35.0f)];
        textField.text = [_categoryArray objectAtIndex:i];
        textField.delegate = self;
        textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [popOverScrollView addSubview:textField];
        [editCategoryArray addObject:textField];
        
    }
    
    [popOverScrollView setContentSize:CGSizeMake(280, 50*[_categoryArray count])];
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        [popOverScrollView setFrame:CGRectMake(0, 0, 280, 300)];
    }else{
        [popOverScrollView setFrame:CGRectMake(0, 0, 280, 380)];
    }
    
    CXAlertView *alertView = [[CXAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"請輸入新的自訂群組名稱", @"SecuritySearch", nil) contentView:popOverScrollView cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    alertView.contentScrollViewMaxHeight = 380;
    alertView.contentScrollViewMinHeight = 300;
    [alertView.contentView setFrame:CGRectMake(0, 0, 280, 380)];
    [alertView addButtonWithTitle:NSLocalizedStringFromTable(@"確認", @"SecuritySearch", nil) type:CXAlertViewButtonTypeDefault handler:^(CXAlertView *alertView, CXAlertButtonItem *button) {
        [alertView dismiss];
        [self btnClick];
    }];
    [alertView show];
}

-(void)btnClick{
    
    NSMutableArray * noText = [[NSMutableArray alloc]init];
    for (int i =0; i<[editCategoryArray count]; i++) {
        UITextField * text = [[UITextField alloc]init];
        text = [editCategoryArray objectAtIndex:i];
        if ([text.text isEqualToString:@""]) {
            [noText addObject:[NSNumber numberWithInt:i]];
        }
    }
    if ([noText count]>0) {
        UIAlertView * errorAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"錯誤", @"SecuritySearch", nil) message:NSLocalizedStringFromTable(@"名稱不可為空白", @"SecuritySearch", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [errorAlert show];
//        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(errorAlert) userInfo:nil repeats:NO];
    }else{
        NSMutableArray * changeNameArray = [[NSMutableArray alloc]init];
        for (int i =0; i<[editCategoryArray count]; i++) {
            UITextField * text = [[UITextField alloc]init];
            text = [editCategoryArray objectAtIndex:i];
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


-(void)search:(UITextField *)textField{
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    if (![textField.text isEqual:@""]) {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
        [dataModal.securitySearchModel performSelector:@selector(searchStockWithName:) onThread:dataModal.thread withObject:textField.text waitUntilDone:NO];
        _searchStockView.noStockLabel.hidden = YES;
    }else{
        [_searchStockView.data1Array removeAllObjects];
        [_searchStockView setData1Array:_searchStockView.data1Array];
        [_searchStockView reloadButton];
    }
    [self.view setNeedsUpdateConstraints];
    
}


-(void)notifyDataArrive:(NSMutableArray *)array{
    [_searchStockView setData1Array:[array objectAtIndex:0]];
    [_searchStockView setDataIdArray:[array objectAtIndex:1]];
    _searchStockView.dataICArray = [[NSMutableArray alloc]initWithArray:[array objectAtIndex:2]];
    [_searchStockView reloadButton];
    
    if ([(NSArray *)[array objectAtIndex:0]count]==0) {
        _searchStockView.noStockLabel.hidden = NO;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view hideHUD];
}

-(void)changeStockWithPortfolioItem:(PortfolioItem *)item{
    [_delegate changeStockWithPortfolioItem:item];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:nil];
    
    [super viewWillDisappear:animated];
}

- (void)updateViewConstraints {
    
    [self.view removeConstraints:self.view.constraints];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:_stringV options:0 metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_searchText]-5-[_searchBtn(70)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_searchBtn(44)]" options:0 metrics:nil views:_objDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:_stringH options:0 metrics:nil views:_objDictionary]];
//
//    
    [super updateViewConstraints];
}
-(void)searchBtnClick{
    [_searchText resignFirstResponder];
    if (![_searchText.text isEqual:@""]) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchStockFromServerWithName:) onThread:dataModal.thread withObject:_searchText.text waitUntilDone:NO];
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];

    }

}
-(void)groupNotifyDataArrive:(NSMutableArray *)array{
    _categoryArray = [array objectAtIndex:0];
    _groupIdArray = [array objectAtIndex:1];
    
    [_groupBtn setTitle:[_categoryArray objectAtIndex:0] forState:UIControlStateNormal];
    _searchGroup = [(NSNumber *)[_groupIdArray objectAtIndex:0]intValue];
    _stockListView.searchGroup = _searchGroup;
    _searchStockView.searchGroup = _searchGroup;
    [_searchStockView setSearchGroup];
    [_stockListView setSearchGroup];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{

    [_searchStockView willMoveToParentViewController:nil];

    [self transitionFromViewController:_stockListView toViewController:_searchStockView duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        _stringV = @"V:|-2-[_searchText(35)]-2-[_searchStockView]|";
        _stringH = @"H:|[_searchStockView]|";
        [self.view setNeedsUpdateConstraints];
    }];
}

-(void)backToList{
    [_stockListView willMoveToParentViewController:nil];
    
    [self transitionFromViewController:_searchStockView toViewController:_stockListView duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        _stringV = @"V:|-2-[_searchText(35)]-2-[_stockListView]|";
        _stringH = @"H:|[_stockListView]|";
        [self.view setNeedsUpdateConstraints];
    }];
    
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
    _searchText.text = @"";
    [_searchStockView.data1Array removeAllObjects];
    [_searchStockView setData1Array:_searchStockView.data1Array];
    [_searchStockView reloadButton];
    [_searchText resignFirstResponder];
    
    [_stockListView willMoveToParentViewController:self];
    
    [self transitionFromViewController:_searchStockView toViewController:_stockListView duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        _stringV = @"V:|-2-[_searchText(35)]-2-[_stockListView]|";
        _stringH = @"H:|[_stockListView]|";
        [self.view setNeedsUpdateConstraints];
    }];
    
}

-(void)goToWatchListWithSymbol:(NSString *)symbol{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(goToWatchListWithSymbol:)]) {
        [_delegate goToWatchListWithSymbol:symbol];
    }
    
}

-(void)notifyArrive:(NSMutableArray *)data{
    [self.view hideHUD];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
