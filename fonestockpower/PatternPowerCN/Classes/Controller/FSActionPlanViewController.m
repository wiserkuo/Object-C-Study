//
//  FSActionPlanViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/4/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//
#define indicatorNumberOfTables 12

#import "FSActionPlanViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FSAddActionPlanSettingViewController.h"
#import "FSWatchlistPortfolioItem.h"
#import "FSLauncherViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "FSActionPlanDatabase.h"
#import "EODActionModel.h"
#import "FSDataModelProc.h"
#import "FSActionPlanModel.h"
#import "FSActionSheetCell.h"
#import "FSActionPlanCell.h"
#import "FSTradeViewController.h"
#import "Snapshot.h"
#import "CustomIOS7AlertView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface FSActionPlanViewController ()<UITextFieldDelegate, UIActionSheetDelegate,UIAlertViewDelegate, FSActionPlanMainCellDelegate, UITableViewDataSource, UITableViewDelegate>
{
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
    NSUInteger time;
    NSTimer *timer;
    
    UIInterfaceOrientation test;
    FSActionPlanMainCell * mainCell;
    FSInstantInfoWatchedPortfolio *watchedPortfolio;

}
@property (weak, nonatomic) FSUIButton *clickBtn;
@property (strong, nonatomic) FSUIButton *longButton;
@property (strong, nonatomic) FSUIButton *shortButton;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UITableView *actionTableView;

@property (strong, nonatomic) NSArray *keys;
@property (weak, nonatomic) NSMutableArray *actionArray;
@property (strong, nonatomic) NSMutableArray *figureSearchArray;
@property (strong, nonatomic) NSMutableArray *showIndex;
@property (strong, nonatomic) NSMutableDictionary *alertDict;

@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UITapGestureRecognizer *tradeTap;
@property (strong, nonatomic) FigureSearchMyProfileModel *customModel;
@property (strong, nonatomic) FSDataModelProc *model;

@property (weak, nonatomic) FSActionPlanModel *actionPlanModel;
@property (weak, nonatomic) FSActionPlan *actionPlan;
@property (weak, nonatomic) FSActionPlanDatabase *actionPlanDB;

@end

@implementation FSActionPlanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _actionPlanModel = [[FSDataModelProc sharedInstance] actionPlanModel];
        _actionPlanDB = [FSActionPlanDatabase sharedInstances];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    _actionPlanModel.viewController = self;
    watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
	// Do any additional setup after loading the view.
    _btnTerm = YES;
    _actionSheetShow = NO;
    [self setUpImageBackButton];
    [self setupNavigationBar];
    [self setupView];
    _alertDict = [[NSMutableDictionary alloc] init];
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];

    [self initWithData];
    [self alertTimer];
    time = 0;
}

-(void)viewWillDisappear:(BOOL)animated{
    _actionPlanModel.viewController = nil;
    [super viewWillDisappear:animated];
    [timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initWithData{
    _figureSearchArray = [[FigureSearchMyProfileModel alloc] actionSearchFigureSearchId];

    if (_longButton.selected == YES) {
        [_actionPlanModel loadActionPlanLongData];
        _actionArray = _actionPlanModel.actionPlanLongArray;
        _controllerType = YES;
    }else{
        [_actionPlanModel loadActionPlanShortData];
        _actionArray = _actionPlanModel.actionPlanShortArray;
        _controllerType = NO;
    }
    [_tableView reloadData];
}

-(void)changeKeyBoardValue:(BOOL)value{
    _keyBoardShow = value;
}

-(void)reloadRowWithIdentCodeSymbol:(NSString *)ids lastPrice:(float)lastPrice row:(int)row{
    if (_keyBoardShow == YES || !_actionSheetShow == YES) {
        for (FSActionPlan *action in _actionArray) {
            if ([action.identCodeSymbol isEqualToString:ids] && row < [_actionArray count]){
                [_tableView reloadRowsAtIndexPaths:row lastPrice:lastPrice];
            }
        }
    }
}

-(void)updateLastPrice:(NSNumber *)i{
    if (!_keyBoardShow) {
        [_tableView reloadRowsAtIndexPaths:[i intValue]];
    }
}

-(void)returnCellWithSP:(NSInteger)indexRow SPTextField:(UITextField *)SPTextField{
    _actionPlan = [_actionArray objectAtIndex:indexRow];
    SPTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.buySPPercent];
}

-(void)returnCellWithSL:(NSInteger)indexRow SLTextField:(UITextField *)SLTextField{
    _actionPlan = [_actionArray objectAtIndex:indexRow];
    SLTextField.text = [NSString stringWithFormat:@"%.f", _actionPlan.buySLPercent];
}

#pragma mark - return Cell With Text Field
//Target
- (void)returnCellWithTarget:(NSInteger)indexRow TargetText:(NSString *)targetText SPText:(UITextField *)spText SLText:(UITextField *)slText{
    _actionPlan = [_actionArray objectAtIndex:indexRow];
    _actionPlan.target = [(NSNumber *)targetText floatValue];
    if ([targetText isEqualToString:@""]) {
        [_actionPlanDB updateActionPlanDataWithManual:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
    }else{
        [_actionPlanDB updateActionPlanDataWithManual:targetText Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
    }
    
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySP < _actionPlan.last && _actionPlan.buySPPercent != 0 && _actionPlan.target != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
            }
        }
    }else{
        if (_actionPlan.buySP > _actionPlan.last && _actionPlan.buySPPercent != 0 && _actionPlan.target != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
            }
        }
    }

    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySL > _actionPlan.last && _actionPlan.buySLPercent != 0 && _actionPlan.target != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
            }
        }
    }else{
        if (_actionPlan.buySL < _actionPlan.last && _actionPlan.buySLPercent != 0 && _actionPlan.target != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
            }
        }
    }

    [_tableView reloadRowsAtIndexPaths:indexRow];
}

//S@P
-(void)returnCellWithSP:(NSInteger)indexRow Text:(NSString *)text{
    _actionPlan = [_actionArray objectAtIndex:indexRow];
    _actionPlan.buySPPercent = [(NSNumber *)text floatValue];
    if ([text isEqualToString:@""]) {
        [_actionPlanDB updateActionPlanDataWithSProfit:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
    }else{
        [_actionPlanDB updateActionPlanDataWithSProfit:text Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
    }
    
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySP < _actionPlan.last && _actionPlan.buySPPercent != 0 && _actionPlan.cost != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
            }
        }else if (_actionPlan.buySP < _actionPlan.last && _actionPlan.buySPPercent != 0 && _actionPlan.target != 0){
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
            }
        }
    }else{
        if (_actionPlan.buySP > _actionPlan.last && _actionPlan.buySPPercent != 0 && _actionPlan.cost != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
            }
        }else if (_actionPlan.buySP > _actionPlan.last && _actionPlan.buySPPercent != 0 && _actionPlan.target != 0){
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellProfit;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellProfit;
            }
        }
    }

    [_tableView reloadRowsAtIndexPaths:indexRow];
}

//S@L
-(void)returnCellWithSL:(NSInteger)indexRow Text:(NSString *)text{
    _actionPlan = [_actionArray objectAtIndex:indexRow];
    _actionPlan.buySLPercent = [(NSNumber *)text floatValue];
    if ([text isEqualToString:@""]) {
        [_actionPlanDB updateActionPlanDataWithSLoss:@"0" Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
    }else{
        [_actionPlanDB updateActionPlanDataWithSLoss:text Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
    }
    
    if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
        if (_actionPlan.buySL > _actionPlan.last && _actionPlan.buySLPercent != 0 && _actionPlan.cost != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
            }
        }else if (_actionPlan.buySL > _actionPlan.last && _actionPlan.buySLPercent != 0 && _actionPlan.target != 0){
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
            }
        }
    }else{
        if (_actionPlan.buySL < _actionPlan.last && _actionPlan.buySLPercent != 0 && _actionPlan.cost != 0) {
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
            }
        }else if (_actionPlan.buySL < _actionPlan.last && _actionPlan.buySLPercent != 0 && _actionPlan.target != 0){
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            }else{
                _actionPlan.buySellType |= FSActionPlanAlertTypeSellLoss;
            }
        }else{
            if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
                _actionPlan.buySellType -= FSActionPlanAlertTypeSellLoss;
            }
        }
    }

    [_tableView reloadRowsAtIndexPaths:indexRow];
}

#pragma mark - Set up Views
-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Action & Alerts", @"Launcher", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [addButton setImage:[UIImage imageNamed:@"+藍色小球"] forState:UIControlStateNormal];
    UIBarButtonItem *barAddButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = barAddButtonItem;
    [addButton addTarget:self action:@selector(AddPortfolioLongTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.hidesBackButton = YES;
}

-(void)setupView{
    _longButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [_longButton setTitle:NSLocalizedStringFromTable(@"多方選股形勢", @"ActionPlan", nil) forState:UIControlStateNormal];
    [_longButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    _longButton.selected = YES;
    [_longButton addTarget:self action:@selector(termButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _shortButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [_shortButton setTitle:NSLocalizedStringFromTable(@"空方選股形勢", @"ActionPlan", nil) forState:UIControlStateNormal];
    [_shortButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_shortButton addTarget:self action:@selector(termButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[FSActionPlanTableView alloc] initWithfixedColumnWidth:73 mainColumnWidth:140 AndColumnHeight:44];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    _tableView.term = _btnTerm;
    [self.view addSubview:_tableView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_longButton, _shortButton, _tableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_longButton][_shortButton(_longButton)]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_longButton(44)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_shortButton(44)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[_tableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}

#pragma mark - Button Click Action
-(void)AddPortfolioLongTapped:(id)sender {
    [self.navigationController pushViewController:[[FSAddActionPlanSettingViewController alloc] init] animated:NO];
}

-(void)backBtnClick{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)termButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:_longButton]) {
        _shortButton.selected = NO;
        _longButton.selected = YES;
        _tableView.term = YES;
        _controllerType = YES;
        [self initWithData];
    }else{
        _shortButton.selected = YES;
        _longButton.selected = NO;
        _tableView.term = NO;
        _controllerType = NO;
        [self initWithData];
    }
    [_tableView reloadData];
}

-(void)alertTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(showAlert:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)showAlert:(NSTimer *)timer{
    time ++;
    for (NSString *aKey in [_alertDict allKeys]) {
        UILabel *label = [_alertDict objectForKey:aKey];
        [label.layer removeAllAnimations];
        if (time % 2 == 0) {
            if (label.tag == 1) {
                label.layer.backgroundColor = [StockConstant PriceUpColor].CGColor;
            }else if (label.tag == 2){
                label.layer.backgroundColor = [StockConstant PriceDownColor].CGColor;
            }
        }else{
            label.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
    }
}

#pragma mark - Set up table view cell
- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (columnIndex == 0) {
        label.frame = CGRectMake(label.frame.origin.x+15, 2, 40, 40);
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:18.0f];
        label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"T藍色小球"]];
        label.userInteractionEnabled = YES;
        _tradeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTrade:)];
        label.tag = indexPath.row;
        [label addGestureRecognizer:_tradeTap];
    }
    if (columnIndex == 1) {
        _actionPlan = [_actionArray objectAtIndex:indexPath.row];
        label.textColor = [UIColor blueColor];
        NSString *string = _actionPlan.identCodeSymbol;
        NSString *identCode = [string substringToIndex:2];
        NSString *symbol = [string substringFromIndex:3];
        NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
        NSString *appid = [FSFonestock sharedInstance].appId;
        NSString *group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"]) {
            label.text = symbol;
        }
        else {
            label.text = fullName;
        }
        
        if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit || _actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
            label.tag = 1;
            [_alertDict setObject:label forKey:symbol];
        }else if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss || _actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy){
            label.tag = 2;
            [_alertDict setObject:label forKey:symbol];
        }else{
            label.tag = 0;
            [_alertDict removeObjectForKey:symbol];
            [label.layer removeAllAnimations];
        }
    }
}

-(void)addTrade:(UITapGestureRecognizer *)sender{
    UILabel *label = (UILabel *)sender.view;
    _actionPlan = [_actionArray objectAtIndex:label.tag];
    FSTradeViewController *trade = [[FSTradeViewController alloc] init];
    trade.symbolStr = [NSString stringWithFormat:@"%@", _actionPlan.identCodeSymbol];
    trade.lastNum = _actionPlan.last;
    if (_longButton.selected == YES) {
        trade.termStr = @"Long";
        trade.dealStr = @"BUY";
    }else{
        trade.termStr = @"Short";
        trade.dealStr = @"SHORT";
    }
    [self.navigationController pushViewController:trade animated:NO];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_tableView]) {
        if ([_actionArray count] != 0) {
            _actionPlan = [_actionArray objectAtIndex:indexPath.row];
        }
        NSString *string = _actionPlan.identCodeSymbol;
        NSString *symbol = [string substringFromIndex:3];
        [_alertDict removeObjectForKey:symbol];
    }
}

-(void)updateMainTableViewCellStrBuyBtn:(FSUIButton *)strBuyBtn TargetText:(UITextField *)targetText BuyRefLabel:(UILabel *)buyRefLabel CostLabel:(UILabel *)costLabel LastLabel:(UILabel *)lastLabel SPText:(UITextField *)spText SLText:(UITextField *)slText StrSellBtn:(FSUIButton *)strSellBtn RefLabel:(UILabel *)refLabel RemoveLabel:(UILabel *)removeLabel cellForRowAtIndexPath:(NSIndexPath *)indexPath Cell:(FSActionPlanMainCell *)cell{
    _actionPlan = [_actionArray objectAtIndex:indexPath.row];
    
    //Init
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    //StrategyBuyBtn
    if (_actionPlan.buyStrategyID == 0) {
        if (_longButton.selected == YES) {
            [strBuyBtn setImage:[UIImage imageNamed:@"DIY Pattern - Long Default"] forState:UIControlStateNormal];
        }else{
            [strBuyBtn setImage:[UIImage imageNamed:@"DIY Pattern - Short Default"] forState:UIControlStateNormal];
        }
    }else{
        [strBuyBtn setImage:[UIImage imageWithData:[[FigureSearchMyProfileModel sharedInstance] searchImageWithFigureSearch_ID:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID]]] forState:UIControlStateNormal];
    }

    if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
        strBuyBtn.layer.cornerRadius = 8.0f;
        strBuyBtn.layer.masksToBounds = YES;
        strBuyBtn.layer.borderColor = [[UIColor greenColor]CGColor];
        strBuyBtn.layer.borderWidth = 2.0f;
    }else{
        strBuyBtn.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    
    //TargetText
    targetText.text = [NSString stringWithFormat:@"%.2f", _actionPlan.target];
    
    //buyRef
    if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
        buyRefLabel.text = [NSString stringWithFormat:@"%.2f", _actionPlan.last];
    }else{
        buyRefLabel.text = @"0.00";
    }
    
    //CostPrice
    costLabel.text = [NSString stringWithFormat:@"%.2f", _actionPlan.cost];
    
    //S@P
    if (_actionPlan.cost != 0) {
        spText.textColor = [StockConstant PriceUpColor];
    }else{
        spText.textColor = [UIColor blueColor];
    }
    if (_actionPlan.buySPPercent != 0 && _actionPlan.target == 0 && _actionPlan.cost == 0) {
        if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
            spText.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.buySPPercent];
        }else{
            spText.text = [NSString stringWithFormat:@"+%.1f%%", _actionPlan.buySLPercent];
        }
    }else{
        if (_longButton.selected == YES) {
            spText.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySP];
        }else{
            spText.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySL];
        }
    }
    if (_longButton.selected == YES) {
        if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            spText.layer.cornerRadius=8.0f;
            spText.layer.masksToBounds=YES;
            spText.layer.borderColor=[[StockConstant PriceUpColor]CGColor];
            spText.layer.borderWidth= 2.0f;
        }else{
            spText.layer.borderColor = [[UIColor clearColor]CGColor];
        }
    }else{
        if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            spText.layer.cornerRadius=8.0f;
            spText.layer.masksToBounds=YES;
            spText.layer.borderColor=[[StockConstant PriceDownColor]CGColor];
            spText.layer.borderWidth= 2.0f;
        }else{
            spText.layer.borderColor = [[UIColor clearColor]CGColor];
        }
    }
    
    //S@L
    if (_actionPlan.cost != 0) {
        slText.textColor = [StockConstant PriceDownColor];
    }else{
        slText.textColor = [UIColor blueColor];
    }
    if (_actionPlan.buySLPercent != 0 && _actionPlan.target == 0 && _actionPlan.cost == 0) {
        if ([_actionPlan.longShortType isEqualToString:@"Long"]) {
            slText.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.buySLPercent];
        }else{
            slText.text = [NSString stringWithFormat:@"-%.1f%%", _actionPlan.buySPPercent];
        }
    }else{
        if (_longButton.selected == YES) {
            slText.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySL];
        }else{
            slText.text = [NSString stringWithFormat:@"%.2f", _actionPlan.buySP];
        }
    }
    if (_longButton.selected == YES) {
        if (_actionPlan.buySellType & FSActionPlanAlertTypeSellLoss) {
            slText.layer.cornerRadius=8.0f;
            slText.layer.masksToBounds=YES;
            slText.layer.borderColor=[[StockConstant PriceDownColor]CGColor];
            slText.layer.borderWidth= 2.0f;
            
        }else{
            slText.layer.borderColor = [[UIColor clearColor]CGColor];
        }
    }else{
        if (_actionPlan.buySellType & FSActionPlanAlertTypeSellProfit) {
            slText.layer.cornerRadius=8.0f;
            slText.layer.masksToBounds=YES;
            slText.layer.borderColor=[[StockConstant PriceUpColor]CGColor];
            slText.layer.borderWidth= 2.0f;
            
        }else{
            slText.layer.borderColor = [[UIColor clearColor]CGColor];
        }
    }
    
    //LastPrice
    lastLabel.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    lastLabel.text = [NSString stringWithFormat:@"%.2f", _actionPlan.last];

    //StrategySellBtn
    if (_actionPlan.sellStrategyID == 0) {
        if (_longButton.selected == YES) {
            [strSellBtn setImage:[UIImage imageNamed:@"DIY Pattern - Long Default"] forState:UIControlStateNormal];
        }else{
            [strSellBtn setImage:[UIImage imageNamed:@"DIY Pattern - Short Default"] forState:UIControlStateNormal];
        }
    }else{
        [strSellBtn setImage:[UIImage imageWithData:[[FigureSearchMyProfileModel sharedInstance] searchImageWithFigureSearch_ID:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID]]] forState:UIControlStateNormal];
    }
    if (_actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
        strSellBtn.layer.cornerRadius = 8.0f;
        strSellBtn.layer.masksToBounds = YES;
        strSellBtn.layer.borderColor = [[UIColor redColor]CGColor];
        strSellBtn.layer.borderWidth = 2.0f;
    }else{
        strSellBtn.layer.borderColor = [[UIColor clearColor]CGColor];
    }
    
    //Ref.
    if (_actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
        refLabel.text = [NSString stringWithFormat:@"%.2f", _actionPlan.last];
    }else{
        refLabel.text = @"0.00";
    }
    
    //Remove
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTap:)];
    removeLabel.tag = indexPath.row;
    [removeLabel addGestureRecognizer:_tap];
}

-(void)deleteTap:(UITapGestureRecognizer *)sender{
    UILabel * label =(UILabel *)sender.view;
    _tap = sender;
    _actionPlan = [_actionArray objectAtIndex:label.tag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"Are you sure you want to delete?", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) otherButtonTitles:NSLocalizedStringFromTable(@"OK", @"ActionPlan", nil), nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
//        [_actionPlanModel stopWatchIdentcodeSymbol:_actionPlan.identCodeSymbol];
        [_actionPlanDB deleteActionPlanDataWithSymbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
        [_actionPlanDB deletePositionsWithIdentCodeSymbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
        [self initWithData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual:_actionTableView]) {
        return 5;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:_actionTableView]) {
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
    }else{
        return  [_actionArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"ActionPlanCell";
        FSActionSheetCell *cell = (FSActionSheetCell *)[_actionTableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell=[[FSActionSheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
            if (_clickBtn.tag == 600) {
                if (_actionPlan.buyStrategyID == 0) {
                    cell.imageView.image = nil;
                }else{
                    UIImageView *pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedDeleteButton"]];
                    pic.center = CGPointMake(self.view.frame.size.width / 2 - 15, 22);
                    pic.contentMode = UIViewContentModeScaleAspectFit;
                    [cell.contentView addSubview:pic];
                }
            }else{
                if (_actionPlan.sellStrategyID == 0) {
                    cell.imageView.image = nil;
                }else{
                    UIImageView *pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedDeleteButton"]];
                    pic.center = CGPointMake(self.view.frame.size.width / 2 - 15, 22);
                    pic.contentMode = UIViewContentModeScaleAspectFit;
                    [cell.contentView addSubview:pic];
                }
            }

        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"ActionPlanCell";
        FSActionSheetCell *cell = (FSActionSheetCell *)[_actionTableView dequeueReusableHeaderFooterViewWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell=[[FSActionSheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        if (indexPath.section == 0) {
            for (int i = 0; i < 12; i++) {
                if (indexPath.row == i + 1) {
                    cell.imageView.image = [UIImage imageWithData:[[_figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[_figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                }
            }
        }
        if (indexPath.section == 1) {
            for (int i = 12; i < 24; i++) {
                if (indexPath.row == i - 11) {
                    cell.imageView.image = [UIImage imageWithData:[[_figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[_figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                }
            }
        }
        if (indexPath.section == 2) {
            for (int i = 24; i < 36; i++) {
                if (indexPath.row == i - 23) {
                    cell.imageView.image = [UIImage imageWithData:[[_figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[_figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                }
            }
        }
        if (indexPath.section == 3) {
            for (int i = 36; i < 48; i++) {
                if (indexPath.row == i - 35) {
                    cell.imageView.image = [UIImage imageWithData:[[_figureSearchArray objectAtIndex:i] objectForKey:@"image_binary"]];
                    cell.textLabel.text = [NSString stringWithFormat:@"   %@", NSLocalizedStringFromTable([[_figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"FigureSearch", nil)];
                }
            }
        }
        return cell;
    }
}

- (void)insertRow:(NSIndexPath *)indexPath Section:(NSInteger)section{
    [_showIndex removeAllObjects];
    
    if (section == 0) {
        indicator0Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:0];
            [_showIndex addObject:indexPathToInsert];
        }
        section0CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 1) {
        indicator1Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:1];
            [_showIndex addObject:indexPathToInsert];
        }
        section1CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 2){
        indicator2Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:2];
            [_showIndex addObject:indexPathToInsert];
        }
        section2CellNumber = indicatorNumberOfTables + 1;
    }
    else if (section == 3){
        indicator3Show = YES;
        for (int i = 1; i <= indicatorNumberOfTables; i++) {
            NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:3];
            [_showIndex addObject:indexPathToInsert];
        }
        section3CellNumber = indicatorNumberOfTables + 1;
    }
    
    [_actionTableView beginUpdates];
    [_actionTableView insertRowsAtIndexPaths:_showIndex withRowAnimation:UITableViewRowAnimationTop];
    [_actionTableView endUpdates];
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

    for (int i = 0; i < [_showIndex count]; i++) {
        NSIndexPath* indexPathToDelete = [_showIndex objectAtIndex:i];
        [rowToDelete addObject:indexPathToDelete];
    }
    [_actionTableView beginUpdates];
    [_actionTableView deleteRowsAtIndexPaths:rowToDelete withRowAnimation:UITableViewRowAnimationLeft];
    [_actionTableView endUpdates];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_actionTableView]) {
        _actionSheetShow = NO;
        if (indexPath.section == 4) {
            if (_clickBtn.tag == 600) {
                [_clickBtn setImage:[UIImage imageNamed:@"DIY Pattern - Long Default"] forState:UIControlStateNormal];
                _actionPlan.buyStrategyName = @"";
                _actionPlan.buyStrategyID = 0;
                [self getAlert];
                [_tableView reloadRowsAtIndexPaths:indexRowNum];
                [_actionPlanDB updateActionPlanDataWithPattern1:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
            }else{
                [_clickBtn setImage:[UIImage imageNamed:@"DIY Pattern - Short Default"] forState:UIControlStateNormal];
                _actionPlan.sellStrategyID = 0;
                _actionPlan.sellStrategyName = @"";
                [self getAlert];
                [_tableView reloadRowsAtIndexPaths:indexRowNum];
                [_actionPlanDB updateActionPlanDataWithPattern2:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
            }
        }
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
            [_actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        }
        
        
        for (int i = 0; i < indicatorNumberOfTables; i++) {
            if (indicator0Show && indexPath.section == 0 && indexPath.row == i + 1) {
                [_clickBtn setTitle:NSLocalizedStringFromTable([[_figureSearchArray objectAtIndex:i] objectForKey:@"title"], @"ActionPlanPattern", nil) forState:UIControlStateNormal];
                if (_clickBtn.tag == 600) {
                    _actionPlan.buyStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.buyStrategyName = [[_figureSearchArray objectAtIndex:i] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern1:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    _actionPlan.sellStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.sellStrategyName = [[_figureSearchArray objectAtIndex:i] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern2:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
            }else if (indicator1Show && indexPath.section == 1 && indexPath.row == i + 1) {
                [_clickBtn setTitle:NSLocalizedStringFromTable([[_figureSearchArray objectAtIndex:i+12] objectForKey:@"title"], @"ActionPlanPattern", nil) forState:UIControlStateNormal];
                if (_clickBtn.tag == 600) {
                    _actionPlan.buyStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i+12] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.buyStrategyName = [[_figureSearchArray objectAtIndex:i+12] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern1:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    _actionPlan.sellStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i+12] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.sellStrategyName = [[_figureSearchArray objectAtIndex:i+12] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern2:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
                
            }else if (indicator2Show && indexPath.section == 2 && indexPath.row == i + 1) {
                if (_clickBtn.tag == 600) {
                    _actionPlan.buyStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i+24] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.buyStrategyName = [[_figureSearchArray objectAtIndex:i+24] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern1:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    _actionPlan.sellStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i+24] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.sellStrategyName = [[_figureSearchArray objectAtIndex:i+24] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern2:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
                
            }else if (indicator3Show && indexPath.section == 3 && indexPath.row == i + 1) {
                if (_clickBtn.tag == 600) {
                    _actionPlan.buyStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i+36] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.buyStrategyName = [[_figureSearchArray objectAtIndex:i+36] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern1:[NSString stringWithFormat:@"%.f", _actionPlan.buyStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }else{
                    _actionPlan.sellStrategyID = [(NSNumber *)[[_figureSearchArray objectAtIndex:i+36] objectForKey:@"FigureSearch_ID"] intValue];
                    _actionPlan.sellStrategyName = [[_figureSearchArray objectAtIndex:i+36] objectForKey:@"title"];
                    [self getAlert];
                    [_tableView reloadRowsAtIndexPaths:indexRowNum];
                    [_actionPlanDB updateActionPlanDataWithPattern2:[NSString stringWithFormat:@"%.f", _actionPlan.sellStrategyID] Symbol:_actionPlan.identCodeSymbol Term:_actionPlan.longShortType];
                }
            }
        }
    }else if ([tableView isEqual:_tableView.fixedTableView]){
        FSActionPlan *actionPlan = [[FSActionPlan alloc] init];
        actionPlan = [_actionArray objectAtIndex:indexPath.row];
        NSString *idSymbol =actionPlan.identCodeSymbol;
        
        FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:idSymbol];
        watchedPortfolio.portfolioItem = portfolioItem;
        mainViewController.firstLevelMenuOption =1;
        [self.navigationController pushViewController:mainViewController animated:NO];
    }
}

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
        EODActionModel *eodActionModel = [[FSDataModelProc sharedInstance] edoActionModel];
        
        if (_clickBtn.tag == 600) {
            [eodActionModel ImageNumber:_actionPlan.buyStrategyID Symbol:_actionPlan.identCodeSymbol FSData:figureSearchData Alert:^(BOOL needAlert) {
                if (needAlert == YES) {
                    if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
                    }else{
                        _actionPlan.buySellType |= FSActionPlanAlertTypeBuyStrategy;
                    }
                }else{
                    if (_actionPlan.buySellType & FSActionPlanAlertTypeBuyStrategy) {
                        _actionPlan.buySellType -= FSActionPlanAlertTypeBuyStrategy;
                    }
                }
            }];
        }else{
            [eodActionModel ImageNumber:_actionPlan.sellStrategyID Symbol:_actionPlan.identCodeSymbol FSData:figureSearchData Alert:^(BOOL needAlert) {
                if (needAlert == YES) {
                    if (_actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                    }else{
                        _actionPlan.buySellType |= FSActionPlanAlertTypeSellStrategy;
                    }
                }else{
                    if (_actionPlan.buySellType & FSActionPlanAlertTypeSellStrategy) {
                        _actionPlan.buySellType -= FSActionPlanAlertTypeSellStrategy;
                    }
                }
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Table View Columns Name
-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"Trade", @"ActionPlan", nil) ,NSLocalizedStringFromTable(@"Symbol", @"ActionPlan", nil)];
}

-(NSArray *)columnsInMainTableView{
    if (_longButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"BUY", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Price", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Profit & loss", @"ActionPlan", nil), NSLocalizedStringFromTable(@"SELL", @"ActionPlan", nil)];
    }else{
        return @[NSLocalizedStringFromTable(@"SHORT", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Price", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Profit & loss", @"ActionPlan", nil), NSLocalizedStringFromTable(@"COVER", @"ActionPlan", nil)];
    }
}

-(NSArray *)columnsSecondInMainTableView{
    if (_longButton.selected == YES) {
        return @[NSLocalizedStringFromTable(@"Pattern", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Ref.", @"ActionPlan", nil),NSLocalizedStringFromTable(@"Average$", @"ActionPlan", nil),NSLocalizedStringFromTable(@"Last$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"S@P", @"ActionPlan", nil),NSLocalizedStringFromTable(@"S@L", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Pattern", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Ref.", @"ActionPlan", nil)];

    }else{
        return @[NSLocalizedStringFromTable(@"Pattern", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Ref.", @"ActionPlan", nil),NSLocalizedStringFromTable(@"Average$", @"ActionPlan", nil),NSLocalizedStringFromTable(@"Last$", @"ActionPlan", nil), NSLocalizedStringFromTable(@"S@L", @"ActionPlan", nil),NSLocalizedStringFromTable(@"S@P", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Pattern", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Ref.", @"ActionPlan", nil)];

    }
}

-(NSArray *)columnsRemoveInMainTableView{
    return @[NSLocalizedStringFromTable(@"", @"ActionPlan", nil)];
}

-(NSArray *)columnsManualInMainTableView{
    return @[NSLocalizedStringFromTable(@"Target$", @"ActionPlan", nil)];
}

#pragma mark - Action sheet
-(void)returnCell:(NSInteger)indexRow Sender:(FSUIButton *)sender BtnTag:(NSInteger)btnTag{
    _clickBtn = sender;
    _actionPlan = [_actionArray objectAtIndex:indexRow];
    indexRowNum = (int)indexRow;
    _showIndex = [[NSMutableArray alloc] init];
    _actionSheetShow = YES;
    if (btnTag == 600 || btnTag == 601) {
        if (btnTag == 600) {
            _clickBtn.tag = 600;
        }else{
            _clickBtn.tag = 601;
        }
        NSString *title = NSLocalizedStringFromTable(@"Select Pattern", @"ActionPlan", nil);
        title = [title stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
        _actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ActionPlan", nil)  destructiveButtonTitle:nil otherButtonTitles:nil];
        [_actionSheet showInView:self.view.window.rootViewController.view];
        _actionTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 45, _actionSheet.frame.size.width-40, _actionSheet.frame.size.height - 120) style:UITableViewStylePlain];
        _actionTableView.delegate = self;
        _actionTableView.dataSource = self;
        _actionTableView.bounces = NO;
        _actionTableView.backgroundView = nil;
        
        section0CellNumber = 1;
        section1CellNumber = 1;
        section2CellNumber = 1;
        section3CellNumber = 1;
        section4CellNumber = 1;
        indicator0Show = NO;
        indicator1Show = NO;
        indicator2Show = NO;
        indicator3Show = NO;
   
        [_actionSheet addSubview:_actionTableView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        _actionSheetShow = NO;
    }
}

- (void)returnCell:(UITableViewCell *)cell{
    mainCell = (FSActionPlanMainCell *)cell;
    float width;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        width = [[UIScreen mainScreen]bounds].size.width;
    }else{
        width = [[UIScreen mainScreen]bounds].size.height;
    }
    [mainCell setWindowWidth:width];
}

-(void)rotate{
    float width;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        width = [[UIScreen mainScreen]bounds].size.width;
    }else{
        width = [[UIScreen mainScreen]bounds].size.height;
    }
    [mainCell setWindowWidth:width];
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
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

@end
