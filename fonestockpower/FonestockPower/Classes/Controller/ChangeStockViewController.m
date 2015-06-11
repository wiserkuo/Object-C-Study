//
//  ChangeStockViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/11/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "ChangeStockViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "SecuritySearchDelegate.h"
#import "FSUIButton.h"
#import "BtnCollectionView.h"
#import "ChangeStockSearchViewController.h"
#import "ChangeUserStockViewController.h"
#import "TaiwanChangeStockViewController.h"


@interface ChangeStockViewController ()<SecuritySearchDelegate>{
    BOOL userFlag;
    MacroeconomicDrawViewController *macroeconomic;
}

@property (nonatomic) int portfolioNum;
@property (strong)NSMutableDictionary * objDictionary;

@property (strong, nonatomic) UIView * rootView;

@property (strong, nonatomic) FSUIButton * searchGroupBtn;
@property (strong, nonatomic) FSUIButton * userStockBtn;

@property (strong, nonatomic) ChangeStockSearchViewController * searchStockView;
@property (strong, nonatomic) TaiwanChangeStockViewController * taiwanStockView;
@property (strong, nonatomic) ChangeUserStockViewController * userStockView;

@property (strong, nonatomic) NSString * stringV;
@property (strong, nonatomic) NSString * stringH;

@property (nonatomic, strong) NSMutableDictionary *mainDict;
@end

@implementation ChangeStockViewController

- (id)initWithNumber:(int)num
{
    self = [super init];
    if (self) {
        // Custom initialization
        _portfolioNum = num;
    }
    return self;
}

-(id)initWithTarget:(MacroeconomicDrawViewController *)controller
{
    self = [super init];
    if(self){
        macroeconomic = controller;
    }
    return  self;
}

-(void)viewDidLoad{
    [self setUpImageBackButton];
    [self initView];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"ChangeStock.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if(_searchGroupBtn.selected==YES){
        userFlag = YES;
    }else if(_userStockBtn.selected ==YES){
        userFlag = NO;
    }
    self.mainDict = [[NSMutableDictionary alloc] init];
    [self.mainDict setObject:[NSNumber numberWithBool:userFlag] forKey:@"UserFlag"];
    [self.mainDict writeToFile:path atomically:YES];
}

-(void)initView{
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"換股", @"Equity", nil)];
    self.objDictionary = [[NSMutableDictionary alloc]init];
    
    self.searchGroupBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    self.searchGroupBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_searchGroupBtn setTitle:NSLocalizedStringFromTable(@"搜尋市場", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_searchGroupBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchGroupBtn];
    [_objDictionary setObject:_searchGroupBtn forKey:@"_searchGroupBtn"];
    
    self.userStockBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    self.userStockBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_userStockBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_userStockBtn setTitle:NSLocalizedStringFromTable(@"自選股", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_userStockBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_userStockBtn];
    [_objDictionary setObject:_userStockBtn forKey:@"_userStockBtn"];
    
    self.rootView = [[UIView alloc]init];
    _rootView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_rootView];
    [_objDictionary setObject:_rootView forKey:@"_rootView"];
    
    
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW || [FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        _taiwanStockView = [[TaiwanChangeStockViewController alloc]init];
        _taiwanStockView.delegate = self;
        _taiwanStockView.view.translatesAutoresizingMaskIntoConstraints = NO;
        [_objDictionary setObject:_taiwanStockView.view forKey:@"_searchStockView"];
        [self addChildViewController:_taiwanStockView];
    }
    else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        self.searchStockView = [[ChangeStockSearchViewController alloc]initWithNumber:_portfolioNum];
        [_searchStockView setTarget:macroeconomic];
        _searchStockView.view.translatesAutoresizingMaskIntoConstraints = NO;
        _searchStockView.delegate = self;
        [_objDictionary setObject:_searchStockView.view forKey:@"_searchStockView"];
    }
    

    self.userStockView =[[ChangeUserStockViewController alloc]initWithNumber:_portfolioNum];
    [_userStockView setTarget:macroeconomic];
    _userStockView.view.translatesAutoresizingMaskIntoConstraints = NO;
    _userStockView.delegate = self;
    [_objDictionary setObject:_userStockView.view forKey:@"_userStockView"];
    [self addChildViewController:_userStockView];
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"ChangeStock.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if(_mainDict){
        userFlag = [[_mainDict objectForKey:@"UserFlag"]boolValue];
    }
    
    if(userFlag){
        _searchGroupBtn.selected = YES;
        [_userStockView.view removeFromSuperview];
//        NSString * appid = [FSFonestock sharedInstance].appId;
//        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
//        if ([group isEqualToString:@"tw"]){
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW || [FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
            [_rootView addSubview:_taiwanStockView.view ];
        }else{
            [_rootView addSubview:_searchStockView.view ];
        }
        
        self.stringV = @"V:|[_searchStockView]|";
        self.stringH = @"H:|[_searchStockView]|";
    }else{
        _userStockBtn.selected = YES;
        
        [_rootView addSubview:_userStockView.view ];
        self.stringV = @"V:|[_userStockView]|";
        self.stringH = @"H:|[_userStockView]|";
    }
    
    [self setAutoLayout];
    [self setRootViewAutoLayout];
    
}

-(void)btnClick:(FSUIButton *)btn{
    _searchGroupBtn.selected = NO;
    _userStockBtn.selected = NO;

    if ([btn isEqual:_searchGroupBtn]) {
        [_userStockView.view removeFromSuperview];
        if( [FSFonestock sharedInstance].marketVersion == FSMarketVersionCN || [FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){
            [_rootView addSubview:_taiwanStockView.view ];
        }else{
            [_rootView addSubview:_searchStockView.view ];
        }
        self.stringV = @"V:|[_searchStockView]|";
        self.stringH = @"H:|[_searchStockView]|";
        
    }else if ([btn isEqual:_userStockBtn]){
        if( [FSFonestock sharedInstance].marketVersion == FSMarketVersionCN || [FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){
            [_taiwanStockView.view removeFromSuperview];
        }else{
            [_searchStockView.view removeFromSuperview];;
        }
        
        [_rootView addSubview:_userStockView.view ];
        self.stringV = @"V:|[_userStockView]|";
        self.stringH = @"H:|[_userStockView]|";
    }
    btn.selected = YES;
    [self setRootViewAutoLayout];
}

-(void)setAutoLayout{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_searchGroupBtn(44)]-2-[_rootView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_userStockBtn(44)]-2-[_rootView]|" options:NSLayoutFormatAlignAllRight metrics:nil views:_objDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchGroupBtn]-3-[_userStockBtn(==_searchGroupBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_rootView]|" options:0 metrics:nil views:_objDictionary]];
}


-(void)setRootViewAutoLayout{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:_stringV options:0 metrics:nil views:_objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:_stringH options:0 metrics:nil views:_objDictionary]];
}

- (void)setUpImageBackButton {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
}

-(void)changeStockWithPortfolioItem:(PortfolioItem *)item{
    FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    if (_portfolioNum ==1) {
        if ([[item getIdentCodeSymbol]isEqualToString:[watchPortfolio.comparedPortfolioItem getIdentCodeSymbol]]) {
            watchPortfolio.comparedPortfolioItem = watchPortfolio.portfolioItem;
            watchPortfolio.portfolioItem = item;
        }else{
            watchPortfolio.portfolioItem = item;
        }
    }else{
        if ([[item getIdentCodeSymbol]isEqualToString:[watchPortfolio.portfolioItem getIdentCodeSymbol]]) {
            watchPortfolio.portfolioItem = watchPortfolio.comparedPortfolioItem;
            watchPortfolio.comparedPortfolioItem = item;
            
        }else{
            watchPortfolio.comparedPortfolioItem = item;
        }
    }
    [self navigationPop];
}

- (void)popCurrentViewController {
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)navigationPop{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
