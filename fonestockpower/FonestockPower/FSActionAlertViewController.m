
//
//  FSActionAlertViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/10/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#define indicatorNumberOfTables 12

#import "FSActionAlertViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSAddActionPlanSettingViewController.h"
#import "FSActionPlanDatabase.h"
#import "CXAlertView.h"
#import "FigureSearchMyProfileModel.h"
#import "FSFigureSearchTableViewCell.h"
#import "FSTradeViewController.h"
#import "CustomIOS7AlertView.h"
#import <Social/Social.h>
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "ExplanationViewController.h"
#import "FSCostTableViewCell.h"

@interface FSActionAlertViewController () <UIAlertViewDelegate, FSActionAlertMainCellDelegate, FSActionAlertSecondMainCellDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CustomIOS7AlertViewDelegate>{
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    FSUIButton *costClickBtn;
    FSUIButton *keyInPriceClickBtn;
    FSUIButton *moreOptionBtnNav;
    FSUIButton *zeroOptionBtnNav;
    
    //暫存cell物件
    UIButton *clickBtn;
    UITextField *cellTargetTextField;
    UITextField *cellTextField;
    UITextField *cellTextField2;
    UITextField *custTextField;
    
    CXAlertView * alert;
    UIAlertView *deleteAlert;
    UIAlertView *costAlert;
    UIAlertView *targetAlert;
    CustomIOS7AlertView *spAlertView;
    CustomIOS7AlertView *slAlertView;
    CustomIOS7AlertView *figureAlertView;
    CustomIOS7AlertView *costAlertView;
    
    UITableView *costTableView;
    UIImageView *radioImageView;
    UIView * view;
    UITableView * patternTabelView;
    NSUInteger time;
    NSTimer *timer;
    NSString *termStr;
    UILabel *navTitleLabel;
    
    int indexRowNum;
    int section0CellNumber;
    int section1CellNumber;
    int section2CellNumber;
    int section3CellNumber;
    int section4CellNumber;

    BOOL indicator0Show;
    BOOL indicator1Show;
    BOOL indicator2Show;
    BOOL indicator3Show;
    BOOL alertViewShow; //YES:Alert view show; NO:Alert view no show (protect delegate reset)
    BOOL isUS;
    
    NSMutableArray * figureSearchArray;
    NSMutableArray * selectArray;
    NSMutableArray *showIndex;
    NSMutableArray *layoutContraints;
    NSMutableDictionary *alertDict;
    
    BOOL firstIn;
}
@property (weak, nonatomic) NSMutableArray *actionArray;
@property (weak, nonatomic) FSActionPlanModel *actionPlanModel;
@property (weak, nonatomic) FSActionPlan *actionPlan;
@property (weak, nonatomic) FSActionPlanDatabase *actionPlanDB;

@end

@implementation FSActionAlertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad {
//    // Do any additional setup after loading the view.
    layoutContraints = [[NSMutableArray alloc] init];
    [self initView];
    [self.view setNeedsUpdateConstraints];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"getAlert" object:nil];
    [self registerLoginNotificationCallBack:self seletor:@selector(receiveNotification:)];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(receiveNotification:)];
    alertDict = [[NSMutableDictionary alloc] init];
    _actionPlanModel = [[FSDataModelProc sharedInstance] actionPlanModel];
    _actionPlanDB = [FSActionPlanDatabase sharedInstances];
    alertViewShow = NO;
    firstIn = YES;
    [self.navigationController setNavigationBarHidden:NO];
    [self initWithData];
    [self setNavigation];
    [self setNavigationBtn];
    [_tableView reloadData];
    _actionPlanModel.viewController = self;
    [self alertTimer];
    time = 0;

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _actionPlanModel.viewController = nil;
    [self unregisterLoginNotificationCallBack:self];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    [timer invalidate];
    navTitleLabel.text = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getAlert" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - set navigation
-(void)setNavigation{
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"Action Plan", @"Launcher", nil)];
    [self setUpImageBackButton];
    
    UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [pointButton addTarget:self action:@selector(explanation:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [addButton setImage:[UIImage imageNamed:@"+藍色小球"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(AddBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"ActionPlan", nil);
    moreOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionBtnNav.frame = CGRectMake(0, 0, 110, 33);
    [moreOptionBtnNav setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"ActionPlan", nil);
    zeroOptionBtnNav = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionBtnNav.frame = CGRectMake(0, 0, 110, 33);
    [zeroOptionBtnNav setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionBtnNav addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barPointButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pointButton];
    UIBarButtonItem *barAddButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    UIBarButtonItem *moreBtnItem = [[UIBarButtonItem alloc] initWithCustomView:moreOptionBtnNav];
    UIBarButtonItem *zeroBtnItem = [[UIBarButtonItem alloc] initWithCustomView:zeroOptionBtnNav];
    
    NSArray *itemArray = [[NSArray alloc] initWithObjects:barAddButtonItem, barPointButtonItem, zeroBtnItem, moreBtnItem, nil];
    [self.navigationItem setRightBarButtonItems:itemArray];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {

        navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width-8, 66)];
    }else{
        navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.height-8, 66)];
    }
    navTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:navTitleLabel];
}

-(void)setNavigationBtn{
    navTitleLabel.text = NSLocalizedStringFromTable(@"Action Plan", @"Launcher", nil);
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        navTitleLabel.hidden = NO;
        moreOptionBtnNav.hidden = YES;
        zeroOptionBtnNav.hidden = YES;
    }else{
        navTitleLabel.hidden = YES;
        moreOptionBtnNav.hidden = NO;
        moreOptionBtnNav.selected = moreOptionButton.selected;
        zeroOptionBtnNav.hidden = NO;
        zeroOptionBtnNav.selected = zeroOptionButton.selected;
    }
}

#pragma mark - 說明頁
-(void)explanation:(UIButton *)sender{
    [self.navigationController pushViewController:[[ExplanationViewController alloc] init] animated:NO];
}

#pragma mark - init View
-(void)initView{
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股形勢", @"ActionPlan", nil);
    moreOptionButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    moreOptionButton.selected = YES;
    [moreOptionButton setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreOptionButton];
    
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股形勢", @"ActionPlan", nil);
    zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    zeroOptionButton.selected = NO;
    [zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zeroOptionButton];
    
    self.tableView = [[FSActionAlertTableView alloc] initWithfixedColumnWidth:100 mainColumnWidth:100 AndColumnHeight:50];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    
    [self.view addSubview:_tableView];
}

-(void)updateViewConstraints{

    [super updateViewConstraints];
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(moreOptionButton, zeroOptionButton, _tableView);
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {

        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-2-[zeroOptionButton(==moreOptionButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[moreOptionButton(44)]-2-[_tableView]|" options:0 metrics:nil views:viewController]];
        [self replaceCustomizeConstraints:constraints];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:viewController]];
        [self replaceCustomizeConstraints:constraints];
    }
}

-(void)initWithData{
    figureSearchArray = [[FigureSearchMyProfileModel alloc] actionSearchFigureSearchId];
    
    selectArray = [[NSMutableArray alloc]init];
    showIndex = [[NSMutableArray alloc]init];
    
    //警示型態陣列
    for (int i = 0; i < 48; i++) {
        [selectArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    if (moreOptionButton.selected == YES) {
        [_actionPlanModel loadActionPlanLongData];
        _actionArray = _actionPlanModel.actionPlanLongArray;
        _controllerType = YES;
        termStr = @"Long";
    }else{
        [_actionPlanModel loadActionPlanShortData];
        _actionArray = _actionPlanModel.actionPlanShortArray;
        _controllerType = NO;
        termStr = @"Short";
    }
    _tableView.actionArray = _actionArray;
    if (firstIn) {
        firstIn = NO;
    }
    
    //警示
    for (_actionPlan in _actionArray) {
        [_actionPlanModel getSellProfitAlertWithFSActionPlan:_actionPlan];
        [_actionPlanModel getSellLossAlertWithFSActionPlan:_actionPlan];
        [_actionPlanModel getTargerAlertWithFSActionPlan:_actionPlan];
        [self getAlert];
    }
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        isUS = YES;
    }else{
        isUS = NO;
    }
}

#pragma mark - tickArrive
-(void)reloadRowWithIdentCodeSymbol:(NSString *)ids lastPrice:(float)lastPrice row:(int)row{
    //AlertView not esixt
    if (alertViewShow == NO) {
        for (FSActionPlan *action in _actionArray) {
            if ([action.identCodeSymbol isEqualToString:ids] && row < [_actionArray count]){
                [self initWithData];
                [_tableView reloadRowsAtIndexPaths:row];
            }
        }
    }
}

#pragma mark - Alert Timer
-(void)alertTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(showAlert:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)showAlert:(NSTimer *)timer{
    time ++;
    for (NSString *aKey in [alertDict allKeys]) {
        UILabel *label = [alertDict objectForKey:aKey];
        [label.layer removeAllAnimations];
        if (time % 2 == 0) {
            if (label.tag == 1) {
                label.layer.backgroundColor = [UIColor yellowColor].CGColor;
            }else if (label.tag == 2){
                if (isUS) {
                    if (zeroOptionBtnNav.selected || zeroOptionButton.selected) {
                        label.layer.backgroundColor = [StockConstant AlertSellLossColor].CGColor;
                    }else{
                        label.layer.backgroundColor = [StockConstant AlertSellProfitColor].CGColor;
                    }
                }else{
                    if (zeroOptionBtnNav.selected || zeroOptionButton.selected) {
                        label.layer.backgroundColor = [StockConstant AlertSellProfitColor].CGColor;
                    }else{
                        label.layer.backgroundColor = [StockConstant AlertSellLossColor].CGColor;
                    }
                }
            }else if (label.tag == 3){
                if (isUS) {
                    if (zeroOptionBtnNav.selected || zeroOptionButton.selected) {
                        label.layer.backgroundColor = [StockConstant AlertSellProfitColor].CGColor;
                    }else{
                        label.layer.backgroundColor = [StockConstant AlertSellLossColor].CGColor;
                    }
                }else{
                    if (zeroOptionBtnNav.selected || zeroOptionButton.selected) {
                        label.layer.backgroundColor = [StockConstant AlertSellLossColor].CGColor;
                    }else{
                        label.layer.backgroundColor = [StockConstant AlertSellProfitColor].CGColor;
                    }
                }
            }else if (label.tag == 4){
                if (isUS) {
                    label.layer.backgroundColor = [StockConstant AlertSellProfitColor].CGColor;
                }else{
                    label.layer.backgroundColor = [StockConstant AlertSellLossColor].CGColor;
                }
            }else if (label.tag == 5){
                if (isUS) {
                    label.layer.backgroundColor = [StockConstant AlertSellLossColor].CGColor;
                }else{
                    label.layer.backgroundColor = [StockConstant AlertSellProfitColor].CGColor;
                }
            }
        }else{
            label.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
    }
}

#pragma mark - Button Action
-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:moreOptionButton] || [btn isEqual:moreOptionBtnNav]) {
        zeroOptionButton.selected = NO;
        moreOptionButton.selected = YES;
        zeroOptionBtnNav.selected = NO;
        moreOptionBtnNav.selected = YES;
    }else if ([btn isEqual:zeroOptionButton] || [btn isEqual:zeroOptionBtnNav]){
        zeroOptionButton.selected = YES;
        moreOptionButton.selected = NO;
        zeroOptionBtnNav.selected = YES;
        moreOptionBtnNav.selected = NO;
    }
    [self initWithData];
    [_tableView reloadData];
}

-(void)AddBtnAction:(id)sender{
    FSAddActionPlanSettingViewController *viewController = [[FSAddActionPlanSettingViewController alloc] init];
    viewController.termStr = termStr;
    [self.navigationController pushViewController:viewController animated:NO];
}

-(void)tradeBtnAction:(FSUIButton *)sender{
    FSUIButton *button =(FSUIButton *)sender;
    _actionPlan = [_actionArray objectAtIndex:button.tag];
    
    FSTradeViewController *trade = [[FSTradeViewController alloc] init];
    trade.symbolStr = [NSString stringWithFormat:@"%@", _actionPlan.identCodeSymbol];
    trade.lastNum = _actionPlan.last;
    trade.costType = _actionPlan.costType;
    trade.ref_Price = _actionPlan.ref_Price;
    
    if (moreOptionButton.selected == YES) {
        trade.termStr = @"Long";
        if ([button.titleLabel.text isEqualToString:NSLocalizedStringFromTable(@"BUY", @"ActionPlan", nil)]) {
            trade.dealStr = @"BUY";
        }else{
            trade.dealStr = @"SELL";
        }
    }else{
        trade.termStr = @"Short";
        if ([button.titleLabel.text isEqualToString:NSLocalizedStringFromTable(@"SHORT", @"ActionPlan", nil)]) {
            trade.dealStr = @"SHORT";
        }else{
            trade.dealStr = @"COVER";
        }
    }
    
    trade.actionPlan = _actionPlan;
    [self.navigationController pushViewController:trade animated:NO];
}

-(void)deleteTap:(UIButton *)sender{
    UIButton *button =(UIButton *)sender;
    _actionPlan = [_actionArray objectAtIndex:button.tag];
    deleteAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"Action Plan", @"Launcher", nil) message:NSLocalizedStringFromTable(@"確定要刪除?", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
    [deleteAlert show];
}

-(void)costBtnAction:(FSUIButton *)sender{
    costClickBtn = (FSUIButton *)sender;
    _actionPlan = [_actionArray objectAtIndex:costClickBtn.tag];

    costAlertView = [[CustomIOS7AlertView alloc] init];
    UIView *costView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
    
    UILabel *costLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 300, 20)];
    costLabel.text = NSLocalizedStringFromTable(@"成本價", @"ActionPlan", nil);
    costLabel.textAlignment = NSTextAlignmentLeft;
    [costView addSubview:costLabel];
    
    UILabel *costDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 300, 60)];
    costDetailLabel.font = [UIFont systemFontOfSize:14.0f];
    costDetailLabel.numberOfLines = 0;
    costDetailLabel.textAlignment = NSTextAlignmentLeft;
    if (moreOptionButton.selected) {
        costDetailLabel.text = NSLocalizedStringFromTable(@"建議以最高買進價做為停損停利計算依據,\n若以買進均價計算,警示點有可能設的太遠", @"ActionPlan", nil);
    }else{
        costDetailLabel.text = NSLocalizedStringFromTable(@"建議以最低放空價做為停損停利計算依據,\n若以放空均價計算,警示點有可能設的太遠", @"ActionPlan", nil);
    }

    costDetailLabel.adjustsFontSizeToFitWidth = YES;
    [costView addSubview:costDetailLabel];
    
    costTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 85, 300, 90)];
    costTableView.bounces = NO;
    costTableView.delegate = self;
    costTableView.dataSource = self;
    [costView addSubview:costTableView];
    
    [costAlertView setContainerView:costView];
    [costAlertView setButtonTitles:@[NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil)]];
    [costAlertView show];
}

#pragma mark - Alert View Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:deleteAlert]) {
        if (buttonIndex == 1) {
//            刪除PortfolioItem
            //    NSString *idSymbol =_actionPlan.identCodeSymbol;
            //    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            //    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
            //    [[[FSDataModelProc sharedInstance]portfolioData] RemoveItem:portfolioItem->identCode andSymbol:portfolioItem->symbol];
            
            NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:[_actionPlan.identCodeSymbol substringToIndex:2] Symbol:[_actionPlan.identCodeSymbol substringFromIndex:3]];
            [FSHUD showMsg:[NSString stringWithFormat:@"%@ %@ %@", NSLocalizedStringFromTable(@"移除", @"ActionPlan", nil), fullName, NSLocalizedStringFromTable(@"於 交易計劃", @"ActionPlan", nil)]];
            [_actionPlanModel stopWatchIdentcodeSymbol:_actionPlan.identCodeSymbol];
            [_actionPlanDB deleteActionPlanDataWithSymbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
            _actionPlan.buySellType = FSActionPlanAlertTypeNone ;
            [self initWithData];
            [_tableView reloadData];
        }
    }else if ([alertView isEqual:targetAlert]){
        if (buttonIndex == 1) {
            cellTargetTextField.text = [targetAlert textFieldAtIndex:0].text;
            _actionPlan = [_actionArray objectAtIndex:cellTargetTextField.tag];
            _actionPlan.target = [(NSNumber *)cellTargetTextField.text floatValue];
            if ([cellTargetTextField.text isEqualToString:@""]) {
                [_actionPlanDB updateActionPlanDataWithManual:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
            }else{
                [_actionPlanDB updateActionPlanDataWithManual:cellTargetTextField.text Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
            }
            [_actionPlanModel getTargerAlertWithFSActionPlan:_actionPlan];
            [_tableView reloadRowsAtIndexPaths:cellTargetTextField.tag];
        }
        [cellTargetTextField resignFirstResponder];
    }
    alertViewShow = NO;
}

#pragma mark - TextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //限制一個小數點
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *arrayOfString = [newString componentsSeparatedByString:@"."];
    if ([arrayOfString count] > 2){
        return NO;
    }
    
    if ([textField isEqual:[targetAlert textFieldAtIndex:0]]) {
        //限制位數
//        if ([arrayOfString count] == 1) {
            if ([newString length] > 7) {
                return NO;
            }
//        }
        
        //限制小數點後位數
//        if ([arrayOfString count] == 2) {
//            NSRange ran = [textField.text rangeOfString:@"."];
//            int tt = (int)range.location - (int)ran.location;
//            if (tt > 2){
//                return NO;
//            }
//        }
    }else if ([textField isEqual:custTextField]){
        if (custTextField.tag == 1) {
            //限制位數
            if ([arrayOfString count] == 1) {
                if ([newString length] > 3) {
                    return NO;
                }
            }
        }else if (custTextField.tag == 2){
            //限制位數
            if ([arrayOfString count] == 1) {
                if ([newString length] > 2) {
                    return NO;
                }
            }
        }
        
        //限制小數點後位數
        if ([arrayOfString count] == 2) {
            NSRange ran = [textField.text rangeOfString:@"."];
            int tt = (int)range.location - (int)ran.location;
            if (tt > 1){
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - Custom IOS7 AlertView Delegate
-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:spAlertView]) {
        if (buttonIndex == 1) {
            if (cellTextField != nil) { //買進停利價
                _actionPlan = [_actionArray objectAtIndex:cellTextField.tag];
                _actionPlan.buySPPercent = [(NSNumber *)custTextField.text floatValue];
                if ([custTextField.text isEqualToString:@""]) {
                    [_actionPlanDB updateActionPlanDataWithSProfit:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    [_actionPlanDB updateActionPlanDataWithSProfit:custTextField.text Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
                [cellTextField resignFirstResponder];
                [_tableView reloadRowsAtIndexPaths:cellTextField.tag];
            }else if (cellTextField2 != nil){ //賣出停利價
                _actionPlan = [_actionArray objectAtIndex:cellTextField2.tag];
                _actionPlan.sellSPPercent = [(NSNumber *)custTextField.text floatValue];
                if ([custTextField.text isEqualToString:@""]) {
                    [_actionPlanDB updateActionPlanDataWithSProfit2:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    [_actionPlanDB updateActionPlanDataWithSProfit2:custTextField.text Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
                [_actionPlanModel getSellProfitAlertWithFSActionPlan:_actionPlan];
                [cellTextField2 resignFirstResponder];
                [_tableView reloadRowsAtIndexPaths:cellTextField2.tag];
            }
        }
        [spAlertView close];

    }else if ([alertView isEqual:slAlertView]){
        if (buttonIndex == 1) {
            if (cellTextField != nil) { //買進停損價
                _actionPlan = [_actionArray objectAtIndex:cellTextField.tag];
                _actionPlan.buySLPercent = [(NSNumber *)custTextField.text floatValue];
                if ([custTextField.text isEqualToString:@""]) {
                    [_actionPlanDB updateActionPlanDataWithSLoss:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    [_actionPlanDB updateActionPlanDataWithSLoss:custTextField.text Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
                [cellTextField resignFirstResponder];
                [_tableView reloadRowsAtIndexPaths:cellTextField.tag];
            }else if (cellTextField2 != nil){ //賣出停損價
                _actionPlan = [_actionArray objectAtIndex:cellTextField2.tag];
                _actionPlan.sellSLPercent = [(NSNumber *)custTextField.text floatValue];
                if ([custTextField.text isEqualToString:@""]) {
                    [_actionPlanDB updateActionPlanDataWithSLoss2:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    [_actionPlanDB updateActionPlanDataWithSLoss2:custTextField.text Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
                [_actionPlanModel getSellLossAlertWithFSActionPlan:_actionPlan];
                [cellTextField2 resignFirstResponder];
                [_tableView reloadRowsAtIndexPaths:cellTextField2.tag];
            }
        }
        [slAlertView close];
    }

    cellTextField = nil;
    cellTextField2 = nil;
    alertViewShow = NO;
}

-(void)createCustSellProfitIOS7AlertViewWithTag:(int)tag{
    spAlertView = [[CustomIOS7AlertView alloc] init];
    spAlertView.delegate = self;
    UIView *custView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.text = NSLocalizedStringFromTable(@"設定停利價", @"ActionPlan", nil);
    UILabel *leftContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 45, 180, 30)];
    leftContentLabel.font = [UIFont systemFontOfSize:13.0f];
//    leftContentLabel.adjustsFontSizeToFitWidth = YES;
    NSString *stopProfit = NSLocalizedStringFromTable(@"停利價表用", @"ActionPlan", nil);
    NSString *target = NSLocalizedStringFromTable(@"目標價", @"ActionPlan", nil);
    NSString *cost = NSLocalizedStringFromTable(@"成本價", @"ActionPlan", nil);
    if (moreOptionButton.selected == YES && cellTextField != nil) {
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 +", stopProfit, target];
        //@"停利價 = 目標價 x (100 +	";
    }else if (moreOptionButton.selected == YES && cellTextField2 != nil) {
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 +", stopProfit, cost];
        //@"停利價 = 成本價 x (100 +	";
    }else if (moreOptionButton.selected == NO && cellTextField != nil){
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 -", stopProfit, target];
        //@"停利價 = 目標價 x (100 -	";
    }else if (moreOptionButton.selected == NO && cellTextField2 != nil){
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 -", stopProfit, cost];
        //@"停利價 = 成本價 x (100 -	";
    }
    custTextField = [[UITextField alloc] initWithFrame:CGRectMake(185, 47, 50, 25)];
    custTextField.borderStyle = UITextBorderStyleBezel;
    custTextField.delegate = self;
    custTextField.keyboardType = UIKeyboardTypeDecimalPad;
    custTextField.textAlignment = NSTextAlignmentCenter;
    custTextField.tag = 1;
    if (tag == 0) {
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.buySPPercent];
    }else if (tag == 1){
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.buySPPercent];
    }else if (tag == 2){
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.sellSPPercent];
    }else if (tag == 3){
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.sellSPPercent];
    }
    
    UILabel *rightContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 45, 20, 30)];
    rightContentLabel.font = [UIFont systemFontOfSize:14.0f];
    rightContentLabel.text = @")%";
    
    [custView addSubview:titleLabel];
    [custView addSubview:leftContentLabel];
    [custView addSubview:custTextField];
    [custView addSubview:rightContentLabel];
    [spAlertView setContainerView:custView];
    NSArray *array  = @[NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil),NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil)];
    [spAlertView setButtonTitles:array];
    [spAlertView show];
    [custTextField becomeFirstResponder];
}

-(void)creatCustSellLossIOS7AlertViewWithTag:(int)tag{
    slAlertView = [[CustomIOS7AlertView alloc] init];
    slAlertView.delegate = self;
    UIView *custView = [[UIView alloc] init];
    if (cellTextField != nil) {
        custView.frame = CGRectMake(0, 0, 280, 80);
    }else if (cellTextField2 != nil){
        custView.frame = CGRectMake(0, 0, 280, 110);
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    titleLabel.text = NSLocalizedStringFromTable(@"設定停損價", @"ActionPlan", nil);
    UILabel *leftContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 45, 180, 30)];
    leftContentLabel.font = [UIFont systemFontOfSize:13.0f];
//    leftContentLabel.adjustsFontSizeToFitWidth = YES;
    NSString *stopLoss = NSLocalizedStringFromTable(@"停損價表用", @"ActionPlan", nil);
    NSString *target = NSLocalizedStringFromTable(@"目標價", @"ActionPlan", nil);
    NSString *cost = NSLocalizedStringFromTable(@"成本價", @"ActionPlan", nil);
    if (moreOptionButton.selected == YES && cellTextField != nil) {
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 -", stopLoss, target];
        //@"停損價 = 目標價 x (100 -	";
    }else if (moreOptionButton.selected == YES && cellTextField2 != nil) {
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 -", stopLoss, cost];
        //@"停損價 = 成本價 x (100 -	";
    }else if (moreOptionButton.selected == NO && cellTextField != nil){
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 +", stopLoss, target];
        //@"停損價 = 目標價 x (100 +	";
    }else if (moreOptionButton.selected == NO && cellTextField2 != nil){
        leftContentLabel.text = [NSString stringWithFormat:@"%@ = %@ x (100 +", stopLoss, cost];
        //@"停損價 = 成本價 x (100 +	";
    }
    custTextField = [[UITextField alloc] initWithFrame:CGRectMake(185, 47, 50, 25)];
    custTextField.borderStyle = UITextBorderStyleBezel;
    custTextField.delegate = self;
    custTextField.keyboardType = UIKeyboardTypeDecimalPad;
    custTextField.textAlignment = NSTextAlignmentCenter;
    custTextField.tag = 2;
    if (tag == 0) {
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.buySLPercent];
    }else if (tag == 1){
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.buySLPercent];
    }else if (tag == 2){
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.sellSLPercent];
    }else if (tag == 3){
        custTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.sellSLPercent];
    }
    
    UILabel *rightContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 45, 20, 30)];
    rightContentLabel.font = [UIFont systemFontOfSize:14.0f];
    rightContentLabel.text = @")%";
    
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 260, 50)];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.font = [UIFont systemFontOfSize:14.0f];
    bottomLabel.numberOfLines = 0;
//    bottomLabel.adjustsFontSizeToFitWidth = YES;
    if (cellTextField != nil) {
        bottomLabel = nil;
    }else if (moreOptionButton.selected == YES && cellTextField2 != nil){
        bottomLabel.text = NSLocalizedStringFromTable(@"當 現價 ≧ 停利價, 停損價會重新計算.", @"ActionPlan", nil);
    }else if (moreOptionButton.selected ==NO && cellTextField2 != nil){
        bottomLabel.text = NSLocalizedStringFromTable(@"當 現價 ≦ 停利價, 停損價會重新計算.", @"ActionPlan", nil);
    }
    
    [custView addSubview:titleLabel];
    [custView addSubview:leftContentLabel];
    [custView addSubview:custTextField];
    [custView addSubview:rightContentLabel];
    [custView addSubview:bottomLabel];
    [slAlertView setContainerView:custView];
    NSArray *array  = @[NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil),NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil)];
    [slAlertView setButtonTitles:array];
    [slAlertView show];
    [custTextField becomeFirstResponder];
}

#pragma mark - TableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([tableView isEqual:patternTabelView]) {
        return 5;
    }else{
        return 1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:patternTabelView]) {
        if (section == 0) {
            return section0CellNumber;
        }else if (section == 1){
            return section1CellNumber;
        }else if (section == 2){
            return section2CellNumber;
        }else if (section == 3){
            return section3CellNumber;
        }else{
            return section4CellNumber;
        }
    }else if ([tableView isEqual:costTableView]){
        return 2;
    }else{
        return [_actionArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:patternTabelView]) {
        return 44;
    }else if ([tableView isEqual:costTableView]){
        return 44;
    }else{
        _actionPlan = [_actionArray objectAtIndex:indexPath.row];
        if (_actionPlan.cellType) {
            return 100;
        }else{
            return 50;
        }
    }
}

-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"Symbol", @"ActionPlan", nil) ,NSLocalizedStringFromTable(@"Trade", @"ActionPlan", nil)];
}

-(NSArray *)columnsFirstInMainTableView{
    return @[NSLocalizedStringFromTable(@"Pattern", @"ActionPlan", nil)];
}

-(NSArray *)columnsSecondInMainTableView{
    if (moreOptionButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"目標價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"成本價", @"ActionPlan", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"目標價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"成本價", @"ActionPlan", nil)];
    }
}

-(NSArray *)columnsThirdInMainTableView{
    if (moreOptionButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"停損停利", @"ActionPlan", nil), NSLocalizedStringFromTable(@"停利價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"停損價", @"ActionPlan", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"停損停利", @"ActionPlan", nil), NSLocalizedStringFromTable(@"停損價", @"ActionPlan", nil), NSLocalizedStringFromTable(@"停利價", @"ActionPlan", nil)];
    }
}

-(NSArray *)columnsFourthInMainTableView{
    return @[NSLocalizedStringFromTable(@"", @"ActionPlan", nil)];
}

-(void)updateFixedTableViewCellSymbolLabel:(UILabel *)symbolLabel lastLabel:(UILabel *)lastLabel tradeBtn:(UIButton *)tradeBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertFixedTableViewCell *)cell{
    _actionPlan = [_actionArray objectAtIndex:indexPath.row];
   
    //symbol
    NSString *string = _actionPlan.identCodeSymbol;
    NSString *identCode = [string substringToIndex:2];
    NSString *symbol = [string substringFromIndex:3];
    NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        symbolLabel.text = symbol;
    }else {
        symbolLabel.text = fullName;
    }
    
    //警示 long
    if (_actionPlan.buySellType) {
        if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy &&
            _actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy){
            symbolLabel.tag = 1;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
            symbolLabel.tag = 5;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
            symbolLabel.tag = 4;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            symbolLabel.tag = 3;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            symbolLabel.tag = 2;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeTarget) {
            symbolLabel.tag = 1;
        }
        if (symbolLabel != nil) {
            [alertDict setObject:symbolLabel forKey:symbol];
        }
    }
    //lastPrice
    if (isnan(_actionPlan.cng)){
        lastLabel.textColor = [UIColor blueColor];
        if (_actionPlan.last != 0) {
            lastLabel.text = [NSString stringWithFormat:@"%.2f(----)", _actionPlan.last];
        }else{
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"----(----)"];
        }
    }else if (_actionPlan.cng > 0) {
        lastLabel.textColor = [StockConstant PriceUpColor];
        if (_actionPlan.last != 0 && _actionPlan.cng != INFINITY) {
            lastLabel.text = [NSString stringWithFormat:@"%.2f(+%.2f%%)", _actionPlan.last, _actionPlan.cng*100];
        }else if (_actionPlan.last != 0 && _actionPlan.cng == INFINITY){
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"%.2f(----)", _actionPlan.last];
        }else{
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"----(----)"];
        }
    }else if (_actionPlan.cng < 0){
        lastLabel.textColor = [StockConstant PriceDownColor];
        if (_actionPlan.last != 0) {
            lastLabel.text = [NSString stringWithFormat:@"%.2f(%.2f%%)", _actionPlan.last, _actionPlan.cng*100];
        }else{
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"----(----)"];
        }
    }else if (_actionPlan.cng == 0){
        lastLabel.textColor = [UIColor blueColor];
        lastLabel.text = [NSString stringWithFormat:@"%.2f(%.2f%%)", _actionPlan.last, _actionPlan.cng*100];
    }
    
    //tradeBtn
    tradeBtn.tag = indexPath.row;
    if (moreOptionButton.selected == YES) {
        
        [tradeBtn setTitle:NSLocalizedStringFromTable(@"BUY", @"ActionPlan", nil) forState:UIControlStateNormal];
    }else{
        [tradeBtn setTitle:NSLocalizedStringFromTable(@"SHORT", @"ActionPlan", nil) forState:UIControlStateNormal];
    }
    [tradeBtn addTarget:self action:@selector(tradeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateMainTableViewCellPatternView:(UIView *)patternView PatternLabel:(UILabel *)patternLabel PatternBtn:(UIButton *)patternBtn TargetTextField:(UITextField *)targetTextField SPTextField:(UITextField *)SPTextField SLTextField:(UITextField *)SLTextField RemoveBtn:(UIButton *)removeBtn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertMainTableViewCell *)cell{
    //Init
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    _actionPlan = [_actionArray objectAtIndex:indexPath.row];

    //patternBtn
    if (_actionPlan.buyStrategyID == 0) {
        [patternBtn setImage:[UIImage imageNamed:@"DIY Pattern - Long Default"] forState:UIControlStateNormal];
    }else{
        [patternBtn setImage:[UIImage imageWithData:[[FigureSearchMyProfileModel sharedInstance] searchImageWithFigureSearch_ID:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID]]] forState:UIControlStateNormal];
    }
    if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
        patternBtn.frame = CGRectMake(0, 3, 44, 44);
        patternLabel.text = [NSString stringWithFormat:@"%.2f", _actionPlan.pattern1Num];
        if (isUS) {
            patternView.backgroundColor = [StockConstant AlertSellLossColor];
        }else{
            patternView.backgroundColor = [StockConstant AlertSellProfitColor];
        }

    }else{
        patternBtn.frame = CGRectMake(30, 3, 44, 44);
        patternLabel.text = @"";
        patternView.backgroundColor = [UIColor clearColor];
    }
    
    //targetTextField
    if (_actionPlan.target == 0) {
        targetTextField.text = @"";
    }else{
        targetTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.target];
    }
    if (_actionPlan.buySellType & FSActionPlanAlertTypeTarget) {
        targetTextField.layer.cornerRadius = 8.0f;
        targetTextField.layer.masksToBounds = YES;
        targetTextField.layer.borderColor = [[UIColor yellowColor]CGColor];
        targetTextField.layer.borderWidth = 4.0f;
    }else{
        targetTextField.layer.cornerRadius = 0.0f;
        targetTextField.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    
    //spTextField
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySPPercent != 0 && _actionPlan.target == 0) {
            SPTextField.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.buySPPercent];
            SPTextField.textColor = [StockConstant PriceUpColor];
        }else{
            SPTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySP];
            SPTextField.textColor = [UIColor blueColor];
        }
    }else{
        if (_actionPlan.buySLPercent != 0 && _actionPlan.target == 0) {
            SPTextField.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.buySLPercent];
            SPTextField.textColor = [StockConstant PriceUpColor];
        }else{
            SPTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySL];
            SPTextField.textColor = [UIColor blueColor];
        }
    }
    
    //slTextField
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySLPercent != 0 && _actionPlan.target == 0) {
            SLTextField.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.buySLPercent];
            SLTextField.textColor = [StockConstant PriceDownColor];
        }else{
            SLTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySL];
            SLTextField.textColor = [UIColor blueColor];
        }
    }else{
        if (_actionPlan.buySPPercent != 0 && _actionPlan.target == 0) {
            SLTextField.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.buySPPercent];
            SLTextField.textColor = [StockConstant PriceDownColor];
        }else{
            SLTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySP];
            SLTextField.textColor = [UIColor blueColor];
        }
    }
    
    //removeBtn
    [removeBtn setImage:[UIImage imageNamed:@"RedDeleteButton"] forState:UIControlStateNormal];
    removeBtn.tag = indexPath.row;
    [removeBtn addTarget:self action:@selector(deleteTap:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateSecondFixedTableViewCellSymbolLabel:(UILabel *)symbolLabel lastLabel:(UILabel *)lastLabel tradeBtn:(UIButton *)tradeBtn trade2Btn:(UIButton *)trade2Btn cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertSecondFixedTableViewCell *)cell{
    _actionPlan = [_actionArray objectAtIndex:indexPath.row];
    
    //symbol
    NSString *string = _actionPlan.identCodeSymbol;
    NSString *identCode = [string substringToIndex:2];
    NSString *symbol = [string substringFromIndex:3];
    NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        symbolLabel.text = symbol;
    }else {
        symbolLabel.text = fullName;
    }
    
    //警示
    if (_actionPlan.buySellType) {
        if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy &&
            _actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy){
            symbolLabel.tag = 1;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
            symbolLabel.tag = 5;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
            symbolLabel.tag = 4;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            symbolLabel.tag = 3;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            symbolLabel.tag = 2;
        }else if(_actionPlan.buySellType & FSActionPlanAlertTypeTarget) {
            symbolLabel.tag = 1;
        }
        if (symbolLabel != nil) {
            [alertDict setObject:symbolLabel forKey:symbol];
        }
    }
    
    //lastPrice
    if (isnan(_actionPlan.cng)){
        lastLabel.textColor = [UIColor blueColor];
        if (_actionPlan.last != 0) {
            lastLabel.text = [NSString stringWithFormat:@"%.2f(----)", _actionPlan.last];
        }else{
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"----(----)"];
        }
    }else if (_actionPlan.cng > 0) {
        lastLabel.textColor = [StockConstant PriceUpColor];
        if (_actionPlan.last != 0 && _actionPlan.cng != INFINITY) {
            lastLabel.text = [NSString stringWithFormat:@"%.2f(+%.2f%%)", _actionPlan.last, _actionPlan.cng*100];
        }else if (_actionPlan.last != 0 && _actionPlan.cng == INFINITY){
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"%.2f(----)", _actionPlan.last];
        }else{
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"----(----)"];
        }
    }else if (_actionPlan.cng < 0){
        lastLabel.textColor = [StockConstant PriceDownColor];
        if (_actionPlan.last != 0) {
            lastLabel.text = [NSString stringWithFormat:@"%.2f(%.2f%%)", _actionPlan.last, _actionPlan.cng*100];
        }else{
            lastLabel.textColor = [UIColor blueColor];
            lastLabel.text = [NSString stringWithFormat:@"----(----)"];
        }
    }else if (_actionPlan.cng == 0){
        lastLabel.textColor = [UIColor blueColor];
        lastLabel.text = [NSString stringWithFormat:@"%.2f(%.2f%%)", _actionPlan.last, _actionPlan.cng*100];
    }
    
    //tradeBtn
    tradeBtn.tag = indexPath.row;
    if (moreOptionButton.selected == YES) {
        [tradeBtn setTitle:NSLocalizedStringFromTable(@"BUY", @"ActionPlan", nil) forState:UIControlStateNormal];
    }else{
        [tradeBtn setTitle:NSLocalizedStringFromTable(@"SHORT", @"ActionPlan", nil) forState:UIControlStateNormal];
    }
    [tradeBtn addTarget:self action:@selector(tradeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //trade2Btn
    trade2Btn.tag = indexPath.row;
    if (moreOptionButton.selected == YES) {
        [trade2Btn setTitle:NSLocalizedStringFromTable(@"SELL", @"ActionPlan", nil) forState:UIControlStateNormal];
    }else{
        [trade2Btn setTitle:NSLocalizedStringFromTable(@"COVER", @"ActionPlan", nil) forState:UIControlStateNormal];
    }
    [trade2Btn addTarget:self action:@selector(tradeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateSecondMainTableViewCellPattern1View:(UIView *)pattern1View Pattern1Label:(UILabel *)pattern1Label PatternBtn:(UIButton *)patternBtn TargetTextField:(UITextField *)targetTextField SPTextField:(UITextField *)SPTextField SLTextField:(UITextField *)SLTextField costBtn:(UIButton *)costBtn Pattern2View:(UIView *)pattern2View Pattern2Label:(UILabel *)pattern2Label pattern2Btn:(UIButton *)pattern2Btn SP2TextField:(UITextField *)SP2TextField SL2TextField:(UITextField *)SL2TextField cellForRowAtIndexPath:(NSIndexPath *)indexPath cell:(FSActionAlertSecondMainTableViewCell *)cell{
    //Init
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    _actionPlan = [_actionArray objectAtIndex:indexPath.row];
    
    //patternBtn
    if (_actionPlan.buyStrategyID == 0) {
        [patternBtn setImage:[UIImage imageNamed:@"DIY Pattern - Long Default"] forState:UIControlStateNormal];
    }else{
        [patternBtn setImage:[UIImage imageWithData:[[FigureSearchMyProfileModel sharedInstance] searchImageWithFigureSearch_ID:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID]]] forState:UIControlStateNormal];
    }
    if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
        patternBtn.frame = CGRectMake(0, 3, 44, 44);
        pattern1Label.text = [NSString stringWithFormat:@"%.2f", _actionPlan.pattern1Num];
        if (isUS) {
            pattern1View.backgroundColor = [StockConstant AlertSellLossColor];
        }else{
            pattern1View.backgroundColor = [StockConstant AlertSellProfitColor];
        }
    }else{
        patternBtn.frame = CGRectMake(30, 3, 44, 44);
        pattern1Label.text = @"";
        pattern1View.backgroundColor = [UIColor clearColor];
    }
    
    //targetTextField
    if (_actionPlan.target == 0) {
        targetTextField.text = @"";
    }else{
        targetTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.target];
    }
    if (_actionPlan.buySellType & FSActionPlanAlertTypeTarget) {
        targetTextField.layer.cornerRadius = 8.0f;
        targetTextField.layer.masksToBounds = YES;
        targetTextField.layer.borderColor = [[UIColor yellowColor]CGColor];
        targetTextField.layer.borderWidth = 4.0f;
    }else{
        targetTextField.layer.cornerRadius = 0.0f;
        targetTextField.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    
    //spTextField
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySPPercent != 0 && _actionPlan.target == 0) {
            SPTextField.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.buySPPercent];
            SPTextField.textColor = [StockConstant PriceUpColor];
        }else{
            SPTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySP];
            SPTextField.textColor = [UIColor blueColor];
        }
    }else{
        if (_actionPlan.buySLPercent != 0 && _actionPlan.target == 0) {
            SPTextField.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.buySLPercent];
            SPTextField.textColor = [StockConstant PriceUpColor];
        }else{
            SPTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySL];
            SPTextField.textColor = [UIColor blueColor];
        }
    }
    
    //slTextField
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySLPercent != 0 && _actionPlan.target == 0) {
            SLTextField.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.buySLPercent];
            SLTextField.textColor = [StockConstant PriceDownColor];
        }else{
            SLTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySL];
            SLTextField.textColor = [UIColor blueColor];
        }
    }else{
        if (_actionPlan.buySPPercent != 0 && _actionPlan.target == 0) {
            SLTextField.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.buySPPercent];
            SLTextField.textColor = [StockConstant PriceDownColor];
        }else{
            SLTextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySP];
            SLTextField.textColor = [UIColor blueColor];
        }
    }
    
    //pattern2Btn
    if (_actionPlan.sellStrategyID == 0) {
        [pattern2Btn setImage:[UIImage imageNamed:@"DIY Pattern - Long Default"] forState:UIControlStateNormal];
    }else{
        [pattern2Btn setImage:[UIImage imageWithData:[[FigureSearchMyProfileModel sharedInstance] searchImageWithFigureSearch_ID:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID]]] forState:UIControlStateNormal];
    }
    if (_actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
        pattern2Btn.frame = CGRectMake(0, 3, 44, 44);
        pattern2Label.text = [NSString stringWithFormat:@"%.2f", _actionPlan.pattern2Num];
        if (isUS) {
            pattern2View.backgroundColor = [StockConstant AlertSellProfitColor];
        }else{
            pattern2View.backgroundColor = [StockConstant AlertSellLossColor];
        }
    }else{
        pattern2Btn.frame = CGRectMake(30, 3, 44, 44);
        pattern2Label.text = @"";
        pattern2View.backgroundColor = [UIColor clearColor];
    }
    
    //costBtn
    [costBtn setTitle:[NSString stringWithFormat:@"%.2f", _actionPlan.cost] forState:UIControlStateNormal];
    costBtn.tag = indexPath.row;
    [costBtn addTarget:self action:@selector(costBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //SP2TextField
    SP2TextField.textColor = [StockConstant PriceUpColor];
    
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.sellSPPercent != 0 && _actionPlan.cost == 0) {
            SP2TextField.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.sellSPPercent];
        }else{
            SP2TextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.sellSP];
        }
    }else{
        if (_actionPlan.sellSLPercent != 0 && _actionPlan.cost == 0) {
            SP2TextField.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.sellSLPercent];
        }else{
            SP2TextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.sellSL];
        }
    }
    
    if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
        SP2TextField.layer.cornerRadius=8.0f;
        SP2TextField.layer.masksToBounds=YES;
        if (isUS) {
            if (zeroOptionButton.selected || zeroOptionBtnNav.selected) {
                SP2TextField.layer.borderColor=[[StockConstant AlertSellProfitColor]CGColor];
            }else{
                SP2TextField.layer.borderColor=[[StockConstant AlertSellLossColor]CGColor];
            }
        }else{
            if (zeroOptionButton.selected || zeroOptionBtnNav.selected) {
                SP2TextField.layer.borderColor=[[StockConstant AlertSellLossColor]CGColor];
            }else{
                SP2TextField.layer.borderColor=[[StockConstant AlertSellProfitColor]CGColor];
            }
        }

        SP2TextField.layer.borderWidth= 4.0f;
    }else{
        SP2TextField.layer.cornerRadius = 0.0f;
        SP2TextField.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    
    //SL2TextField
    SL2TextField.textColor = [StockConstant PriceDownColor];
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySLPercent != 0 && _actionPlan.cost == 0) {
            SL2TextField.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.sellSLPercent];
        }else{
            SL2TextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.sellSL];
        }
    }else{
        if (_actionPlan.sellSLPercent != 0 && _actionPlan.cost == 0) {
            SL2TextField.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.sellSPPercent];
        }else{
            SL2TextField.text = [NSString stringWithFormat:@"%.2f", _actionPlan.sellSP];
        }
    }
    
    if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
        SL2TextField.layer.cornerRadius=8.0f;
        SL2TextField.layer.masksToBounds=YES;
        if (isUS) {
            if (zeroOptionButton.selected || zeroOptionBtnNav.selected) {
                SL2TextField.layer.borderColor=[[StockConstant AlertSellLossColor]CGColor];
            }else{
                SL2TextField.layer.borderColor=[[StockConstant AlertSellProfitColor]CGColor];
            }
        }else{
            if (zeroOptionButton.selected || zeroOptionBtnNav.selected) {
                SL2TextField.layer.borderColor=[[StockConstant AlertSellProfitColor]CGColor];
            }else{
                SL2TextField.layer.borderColor=[[StockConstant AlertSellLossColor]CGColor];
            }
        }
        SL2TextField.layer.borderWidth= 4.0f;
    }else{
        SL2TextField.layer.cornerRadius = 0.0f;
        SL2TextField.layer.borderColor = [[UIColor clearColor]CGColor];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:costTableView]) {
        static NSString *CellIdentifier = @"ActionPlanCostCell";
        FSCostTableViewCell *cell = (FSCostTableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell=[[FSCostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        if (indexPath.row == 0) {
            if (moreOptionButton.selected) {
                cell.textLabel.text = NSLocalizedStringFromTable(@"最高買進價", @"ActionPlan", nil);
            }else{
                cell.textLabel.text = NSLocalizedStringFromTable(@"最低放空價", @"ActionPlan", nil);
            }

            if (_actionPlan.costType) {
                radioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RadioButtonYES"]];
            }else{
                radioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RadioButtonNO"]];
            }
            radioImageView.frame = CGRectMake(0, 0, 22, 22);
            cell.accessoryView = radioImageView;
        }else if (indexPath.row == 1){
            if (moreOptionButton.selected) {
                cell.textLabel.text = NSLocalizedStringFromTable(@"買進均價", @"ActionPlan", nil);
            }else{
                cell.textLabel.text = NSLocalizedStringFromTable(@"放空均價", @"ActionPlan", nil);
            }
            if (_actionPlan.costType) {
                radioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RadioButtonNO"]];
            }else{
                radioImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RadioButtonYES"]];
            }
            radioImageView.frame = CGRectMake(0, 0, 22, 22);
            cell.accessoryView = radioImageView;
        }

        
        return cell;
    }else{
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"ActionPlanCell";
            FSFigureSearchTableViewCell *cell = (FSFigureSearchTableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell=[[FSFigureSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            if (indexPath.section == 0) {
                cell.textLabel.text = NSLocalizedStringFromTable(@"Typical Pattern (Long)", @"ActionPlan", nil);
            }else if (indexPath.section == 1){
                cell.textLabel.text = NSLocalizedStringFromTable(@"Typical Pattern (Short)", @"ActionPlan", nil);
            }else if (indexPath.section == 2){
                cell.textLabel.text = NSLocalizedStringFromTable(@"DIY Pattern (Long)", @"ActionPlan", nil);
            }else if (indexPath.section == 3){
                cell.textLabel.text = NSLocalizedStringFromTable(@"DIY Pattern (Short)", @"ActionPlan", nil);
            }else if (indexPath.section == 4){
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                if (clickBtn.tag == 600) {
                    if (_actionPlan.buyStrategyID == 0) {
                        cell.imageView.image = nil;
                    }else{
                        UIImageView *pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedDeleteButton"]];
                        pic.center = CGPointMake(self.view.frame.size.width / 2-20, 22);
                        pic.contentMode = UIViewContentModeScaleAspectFit;
                        [cell.contentView addSubview:pic];
                    }
                }else if (clickBtn.tag == 601){
                    if (_actionPlan.sellStrategyID == 0) {
                        cell.imageView.image = nil;
                    }else{
                        UIImageView *pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedDeleteButton"]];
                        pic.center = CGPointMake(self.view.frame.size.width / 2-20, 22);
                        pic.contentMode = UIViewContentModeScaleAspectFit;
                        [cell.contentView addSubview:pic];
                    }
                }
                
            }
            return cell;
        }else{
            static NSString *CellIdentifier = @"ActionPlanCell";
            FSFigureSearchTableViewCell *cell = (FSFigureSearchTableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell=[[FSFigureSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            if (indexPath.section == 0) {
                for (int i = 0; i < 12; i++) {
                    if (indexPath.row == i + 1) {
                        cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                        cell.imageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    }
                }
            }
            if (indexPath.section == 1) {
                for (int i = 12; i < 24; i++) {
                    if (indexPath.row == i - 11) {
                        cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                        cell.imageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    }
                }
            }
            if (indexPath.section == 2) {
                for (int i = 24; i < 36; i++) {
                    if (indexPath.row == i - 23) {
                        cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                        cell.imageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    }
                }
            }
            if (indexPath.section == 3) {
                for (int i = 36; i < 48; i++) {
                    if (indexPath.row == i - 35) {
                        cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                        cell.imageView.image = [UIImage imageWithData:[[figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    }
                }
            }
            return cell;
        }
    }
}

- (void)insertRow:(NSIndexPath *)indexPath Section:(NSInteger)section{
    [showIndex removeAllObjects];
    
    if (section == 0) {
        indicator0Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:0];
            [showIndex addObject:indexPathToInsert];
        }
        section0CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 1) {
        indicator1Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:1];
            [showIndex addObject:indexPathToInsert];
        }
        section1CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 2){
        indicator2Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:2];
            [showIndex addObject:indexPathToInsert];
        }
        section2CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 3){
        indicator3Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:3];
            [showIndex addObject:indexPathToInsert];
        }
        section3CellNumber = indicatorNumberOfTables + 1;
    }
    
    [patternTabelView beginUpdates];
    [patternTabelView insertRowsAtIndexPaths:showIndex withRowAnimation:UITableViewRowAnimationTop];
    [patternTabelView endUpdates];
}

- (void)deleteRow:(NSIndexPath *)RowtoDelete Section:(NSInteger)section{
    if (section == 0) {
        indicator0Show = NO;
        section0CellNumber = 1;
    }
    
    if (section == 1) {
        indicator1Show = NO;
        section1CellNumber = 1;
    }
    
    if (section == 2) {
        indicator2Show = NO;
        section2CellNumber = 1;
    }
    
    if (section == 3) {
        indicator3Show = NO;
        section3CellNumber = 1;
    }
    
    NSMutableArray* rowToDelete = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [showIndex count]; i++) {
        NSIndexPath* indexPathToDelete = [showIndex objectAtIndex:i];
        [rowToDelete addObject:indexPathToDelete];
    }
    [patternTabelView beginUpdates];
    [patternTabelView deleteRowsAtIndexPaths:rowToDelete withRowAnimation:UITableViewRowAnimationLeft];
    [patternTabelView endUpdates];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:patternTabelView]) {
        if (!indicator0Show && indexPath.section == 0 && indexPath.row == 0) {
            if (indicator1Show) {
                [self deleteRow:indexPath Section:1];
            }
            if (indicator2Show) {
                [self deleteRow:indexPath Section:2];
            }
            if (indicator3Show) {
                [self deleteRow:indexPath Section:3];
            }
            [self insertRow:indexPath Section:0];
        }else if (indicator0Show && indexPath.section == 0 && indexPath.row == 0){
            [self deleteRow:indexPath Section:0];
        }else if (!indicator1Show && indexPath.section == 1 && indexPath.row == 0) {
            if (indicator0Show) {
                [self deleteRow:indexPath Section:0];
            }
            if (indicator2Show) {
                [self deleteRow:indexPath Section:2];
            }
            if (indicator3Show) {
                [self deleteRow:indexPath Section:3];
            }
            [self insertRow:indexPath Section:1];
        }else if (indicator1Show && indexPath.section == 1 && indexPath.row == 0){
            [self deleteRow:indexPath Section:1];
        }else if (!indicator2Show && indexPath.section == 2 && indexPath.row == 0) {
            if (indicator0Show) {
                [self deleteRow:indexPath Section:0];
            }
            if (indicator1Show) {
                [self deleteRow:indexPath Section:1];
            }
            if (indicator3Show) {
                [self deleteRow:indexPath Section:3];
            }
            [self insertRow:indexPath Section:2];
        }else if (indicator2Show && indexPath.section == 2 && indexPath.row == 0){
            [self deleteRow:indexPath Section:2];
        }else if (!indicator3Show && indexPath.section == 3 && indexPath.row == 0) {
            if (indicator0Show) {
                [self deleteRow:indexPath Section:0];
            }
            if (indicator1Show) {
                [self deleteRow:indexPath Section:1];
            }
            if (indicator2Show) {
                [self deleteRow:indexPath Section:2];
            }
            [self insertRow:indexPath Section:3];
        }else if (indicator3Show && indexPath.section == 3 && indexPath.row == 0){
            [self deleteRow:indexPath Section:3];
        }else{
            int num = -1;
            if (indexPath.section == 0) {
                num = (int)indexPath.row-1;
            }else if (indexPath.section == 1){
                num = (int)indexPath.row+11;
            }else if (indexPath.section == 2){
                num = (int)indexPath.row+23;
            }else if (indexPath.section == 3){
                num = (int)indexPath.row+35;
            }
            
            if (num != -1) {
                BOOL isSelect = [[selectArray objectAtIndex:num]boolValue];
                [selectArray setObject:[NSNumber numberWithBool:!isSelect] atIndexedSubscript:num];
            }
            
            NSArray * array = [[NSArray alloc]initWithObjects:indexPath, nil];
            [patternTabelView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
        }
        if (indicator0Show && indexPath.section == 0 && indexPath.row > 0) {
            if (clickBtn.tag == 600) {
                [self saveBuyPatternDataWithFSActionPlan:_actionPlan row:indexPath.row - 1];
            }else{
                [self saveSellPatternDataWithFSActionPlan:_actionPlan row:indexPath.row - 1];
            }
            alertViewShow = NO;
            [figureAlertView close];
            [self getAlert];
            [_tableView reloadRowsAtIndexPaths:indexRowNum];
        }else if (indicator1Show && indexPath.section == 1 && indexPath.row > 0){
            if (clickBtn.tag == 600) {
                [self saveBuyPatternDataWithFSActionPlan:_actionPlan row:indexPath.row + 11];
            }else{
                [self saveSellPatternDataWithFSActionPlan:_actionPlan row:indexPath.row + 11];
            }
            alertViewShow = NO;
            [figureAlertView close];
            [self getAlert];
            [_tableView reloadRowsAtIndexPaths:indexRowNum];
        }else if (indicator2Show && indexPath.section == 2 && indexPath.row > 0){
            if (clickBtn.tag == 600) {
                [self saveBuyPatternDataWithFSActionPlan:_actionPlan row:indexPath.row + 22];
            }else{
                [self saveSellPatternDataWithFSActionPlan:_actionPlan row:indexPath.row + 22];
            }
            alertViewShow = NO;
            [figureAlertView close];
            [self getAlert];
            [_tableView reloadRowsAtIndexPaths:indexRowNum];
        }else if (indicator3Show && indexPath.section == 3 && indexPath.row > 0){
            if (clickBtn.tag == 600) {
                [self saveBuyPatternDataWithFSActionPlan:_actionPlan row:indexPath.row + 32];
            }else{
                [self saveSellPatternDataWithFSActionPlan:_actionPlan row:indexPath.row + 32];
            }
            alertViewShow = NO;
            [figureAlertView close];
            [self getAlert];
            [_tableView reloadRowsAtIndexPaths:indexRowNum];
        }
        
        if (indexPath.section == 4) {
            if (clickBtn.tag == 600) {
                _actionPlan.buyStrategyName = @"";
                _actionPlan.buyStrategyID = 0;
                [_tableView reloadRowsAtIndexPaths:indexRowNum];
                [_actionPlanDB updateActionPlanDataWithPattern1:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
            }else{
                _actionPlan.sellStrategyName = @"";
                _actionPlan.sellStrategyID = 0;
                [_tableView reloadRowsAtIndexPaths:indexRowNum];
                [_actionPlanDB updateActionPlanDataWithPattern2:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
            }
            [self getAlert];
            [_tableView reloadRowsAtIndexPaths:indexRowNum];
            alertViewShow = NO;
            [figureAlertView close];
        }
    }else if ([tableView isEqual:costTableView]){
        if (indexPath.row == 0) {
            if (moreOptionButton.selected == YES) {
                [_actionPlanDB updateActionPlanDataWithCostType:@"YES" Symbol:_actionPlan.identCodeSymbol Term:@"Long"];
//                [_actionPlanModel loadActionPlanLongData];
            }else{
                [_actionPlanDB updateActionPlanDataWithCostType:@"YES" Symbol:_actionPlan.identCodeSymbol Term:@"Short"];
//                [_actionPlanModel loadActionPlanShortData];
            }
        }else if (indexPath.row == 1){
            if (moreOptionButton.selected == YES) {
                [_actionPlanDB updateActionPlanDataWithCostType:@"NO" Symbol:_actionPlan.identCodeSymbol Term:@"Long"];
//                [_actionPlanModel loadActionPlanLongData];
            }else{
                [_actionPlanDB updateActionPlanDataWithCostType:@"NO" Symbol:_actionPlan.identCodeSymbol Term:@"Short"];
//                [_actionPlanModel loadActionPlanShortData];
            }
        }
        [self initWithData];
        [_tableView reloadRowsAtIndexPaths:costClickBtn.tag];

        [costAlertView close];
    }else{
        _actionPlan = [_actionArray objectAtIndex:indexPath.row];
        NSString *idSymbol =_actionPlan.identCodeSymbol;

        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        FSInstantInfoWatchedPortfolio *watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        watchedPortfolio.portfolioItem = portfolioItem;
        mainViewController.firstLevelMenuOption =1;
        _actionPlanModel.viewController = nil;
        [self.navigationController pushViewController:mainViewController animated:NO];
    }
}

#pragma mark - savePatternData
-(void)saveBuyPatternDataWithFSActionPlan:(FSActionPlan *)actionPlan row:(NSInteger)row{
    actionPlan.buyStrategyID = [(NSNumber *)[[figureSearchArray objectAtIndex:row] objectForKey:@"FigureSearch_ID"] intValue];
    actionPlan.buyStrategyName = [[figureSearchArray objectAtIndex:row] objectForKey:@"title"];
    [_actionPlanDB updateActionPlanDataWithPattern1:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
}

-(void)saveSellPatternDataWithFSActionPlan:(FSActionPlan *)actionPlan row:(NSInteger)row{
    _actionPlan.sellStrategyID = [(NSNumber *)[[figureSearchArray objectAtIndex:row] objectForKey:@"FigureSearch_ID"] intValue];
    _actionPlan.sellStrategyName = [[figureSearchArray objectAtIndex:row] objectForKey:@"title"];
    [_actionPlanDB updateActionPlanDataWithPattern2:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
}

#pragma mark - Return Cell Delegate
-(void)returnTargetTextField:(UITextField *)targetTextField{
    cellTargetTextField = targetTextField;
    targetAlert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil), nil];
    if (moreOptionButton.selected == YES) {
        [targetAlert setTitle:NSLocalizedStringFromTable(@"設定您想買的目標價", @"ActionPlan", nil)];
    }else{
        [targetAlert setTitle:NSLocalizedStringFromTable(@"設定您想放空的目標價", @"ActionPlan", nil)];
    }
    targetAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [targetAlert textFieldAtIndex:0].delegate = self;
    [[targetAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    [[targetAlert textFieldAtIndex:0] becomeFirstResponder];
    [targetAlert show];
    alertViewShow = YES;
}

-(void)returnSPTextField:(UITextField *)SPTextField{
    cellTextField = SPTextField;
    if (moreOptionButton.selected == YES) {
        [self createCustSellProfitIOS7AlertViewWithTag:0];
    }else{
        [self creatCustSellLossIOS7AlertViewWithTag:0];
    }
    alertViewShow = YES;
}

-(void)returnSLTextField:(UITextField *)SLTextField{
    cellTextField = SLTextField;
    if (moreOptionButton.selected == YES) {
        [self creatCustSellLossIOS7AlertViewWithTag:1];
    }else{
        [self createCustSellProfitIOS7AlertViewWithTag:1];
    }
    alertViewShow = YES;
}

-(void)returnSP2TextField:(UITextField *)SP2TextField{
    cellTextField2 = SP2TextField;
    if (moreOptionButton.selected == YES) {
        [self createCustSellProfitIOS7AlertViewWithTag:2];
    }else{
        [self creatCustSellLossIOS7AlertViewWithTag:2];
    }
    alertViewShow = YES;
}

-(void)returnSL2TextField:(UITextField *)SL2TextField{
    cellTextField2 = SL2TextField;
    if (moreOptionButton.selected == YES) {
        [self creatCustSellLossIOS7AlertViewWithTag:3];
    }else{
        [self createCustSellProfitIOS7AlertViewWithTag:3];
    }
    alertViewShow = YES;
}

-(void)returncellWithPattern:(NSInteger)indexRow sender:(UIButton *)sender{
    alertViewShow = YES;
    clickBtn = (UIButton *)sender;
    _actionPlan = [_actionArray objectAtIndex:indexRow];
    indexRowNum = (int)indexRow;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, 320)];
        patternTabelView = [[UITableView alloc]initWithFrame:CGRectMake(10, 40, 260, 270) style:UITableViewStylePlain];
    }else{
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 280, 200)];
        patternTabelView = [[UITableView alloc]initWithFrame:CGRectMake(10, 40, 260, 170) style:UITableViewStylePlain];
    }
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 30)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = NSLocalizedStringFromTable(@"編輯警示型態", @"ActionPlan", nil);
    [view addSubview:headerLabel];
    
    patternTabelView.delegate = self;
    patternTabelView.dataSource = self;
    patternTabelView.bounces = NO;
    patternTabelView.backgroundView = nil;
    
    section0CellNumber = 1;
    section1CellNumber = 1;
    section2CellNumber = 1;
    section3CellNumber = 1;
    section4CellNumber = 1;
    indicator0Show = NO;
    indicator1Show = NO;
    indicator2Show = NO;
    indicator3Show = NO;
    
    [view addSubview:patternTabelView];
    
    figureAlertView = [[CustomIOS7AlertView alloc] init];
    NSArray *array  = @[NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil)];
    [figureAlertView setButtonTitles:array];
    [figureAlertView setContainerView:view];
    [figureAlertView show];
}

#pragma mark - Alert
-(void)getAlert{
    if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypeStrategyAlert showAlertViewToShopping:NO]) {
#ifdef LPCB
        PortfolioTick *tickBank = [[FSDataModelProc sharedInstance] portfolioTickBank];
        FSSnapshot *snapshot = [tickBank getSnapshotBvalueFromIdentCodeSymbol:_actionPlan.identCodeSymbol];
#else
        EquitySnapshotDecompressed *snapshot = [[[FSDataModelProc sharedInstance] portfolioTickBank] getSnapshotFromIdentCodeSymbol:_actionPlan.identCodeSymbol];
#endif
        FigureSearchData *figureSearchData = [[FigureSearchData alloc] init];
        figureSearchData -> openPrice = [snapshot.open_price calcValue];
        figureSearchData -> highPrice = [snapshot.high_price calcValue];
        figureSearchData -> lowPrice = [snapshot.low_price calcValue];
        figureSearchData -> closePrice = [snapshot.last_price calcValue];
        figureSearchData -> date = [snapshot.trading_date date16];
        
        if (clickBtn.tag == 600) {
            [_actionPlanModel getBuyPatternAlertWithFSActionPlan:_actionPlan FigureSearchData:figureSearchData];
        }else{
            [_actionPlanModel getSellPatternAlertWithFSActionPlan:_actionPlan FigureSearchData:figureSearchData];
        }
    }
}

//送出警示型態後，接收K線通知並重送Alert
-(void)receiveNotification:(NSNotification *)notification{
    [self getAlert];
    [_tableView reloadData];
}

#pragma mark - set WatchList
- (void)setWatchListMode:(BOOL)setMode {
    Portfolio *portfolio = [[FSDataModelProc sharedInstance] portfolioData];
    NSMutableArray *identCodeSymbols = [[NSMutableArray alloc] init];
    for (FSActionPlan *action in _actionArray) {
        [identCodeSymbols addObject:action.identCodeSymbol];
    }
    
    if (setMode) {
        [portfolio addWatchListItemByIdentSymbolArray:identCodeSymbols];
    }else {
        [portfolio removeWatchListItemByIdentSymbolArray];
    }
}

#pragma mark - 旋轉
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.view setNeedsUpdateConstraints];
    [self setNavigationBtn];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
