//
//  ChangeStockSearchViewController.m
//  WirtsLeg
//
//  Created by Neil on 14/2/17.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "ChangeStockSearchViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSUIButton.h"
#import "BtnCollectionView.h"


@interface ChangeStockSearchViewController ()<UITextFieldDelegate>
@property (strong)MacroeconomicDrawViewController * macroeconomicViewController;
@property (strong)UITextField * searchText;
@property (strong)FSUIButton * searchBtn;
@property (strong) UILabel * titleLabel;
@property (strong) BtnCollectionView * collectionView;
@property (strong) UILabel * noStockLabel;
@property (nonatomic) int portfolioNum;
@property (strong, nonatomic)NSString * symbolStr;
@property (strong, nonatomic)NSString * identSymbolStr;
@property (nonatomic) BOOL goToTechViewFlag;

@property (strong)NSMutableArray * dataArray;//搜尋出來的股票 symbol name
@property (strong) NSMutableArray * dataNameArray;//搜尋出來的股票 name
@property (strong)NSMutableArray * dataIdArray;//搜尋出來的股票symbol
@property (strong)NSMutableArray * dataIdentCodeArray;
@property (strong)NSMutableArray * serverInArray;

@end

@implementation ChangeStockSearchViewController

- (id)initWithNumber:(int)num
{
    self = [super init];
    if (self) {
        // Custom initialization
        _portfolioNum = num;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpImageBackButton];
    
    self.dataArray = [[NSMutableArray alloc]init];
    self.dataNameArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    self.dataIdentCodeArray = [[NSMutableArray alloc]init];
    [self initView];
    
    [self setLayOut];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)initView{
    self.searchText = [[UITextField alloc]init];
    _searchText.placeholder = NSLocalizedStringFromTable(@"輸入代碼或名稱", @"SecuritySearch", nil);
    _searchText.translatesAutoresizingMaskIntoConstraints = NO;
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.font = [UIFont systemFontOfSize:20.0f];
    [_searchText addTarget:self action:@selector(search:) forControlEvents:UIControlEventEditingChanged];
    _searchText.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchText.clearButtonMode = UITextFieldViewModeAlways;
    _searchText.delegate = self;
    [self.view addSubview:_searchText];
    
    self.searchBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _searchBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchBtn setTitle:NSLocalizedStringFromTable(@"搜尋", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchBtn];
    
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = NSLocalizedStringFromTable(@"選取股票", @"SecuritySearch", nil);
    _titleLabel.textColor = [UIColor blueColor];
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_titleLabel];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    aFlowLayout.itemSize = CGSizeMake(308, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    _collectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:aFlowLayout rowCount:1];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionView.myDelegate = self;
    _collectionView.searchGroup =1;
    _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
    _collectionView.aligment = UIControlContentHorizontalAlignmentLeft;
    
    [self.view addSubview:_collectionView];
    
    self.noStockLabel = [[UILabel alloc]init];
    _noStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noStockLabel.text = NSLocalizedStringFromTable(@"無相符個股", @"SecuritySearch", nil);
    _noStockLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_noStockLabel];
    _noStockLabel.hidden = YES;
}

-(void)setTarget:(MacroeconomicDrawViewController *)controller
{
    self.macroeconomicViewController = controller;
}

- (void)setLayOut {
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_titleLabel,_collectionView,_searchText,_searchBtn);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_searchText(29)]-10-[_titleLabel(25)]-2-[_collectionView]-2-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_searchBtn(44)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_searchText]-5-[_searchBtn(65)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_collectionView]-3-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

-(void)titleButtonClick:(FSUIButton *)button{
    self.macroeconomicViewController.portfolioFlag = YES;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    
    self.identSymbolStr =[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]];
    self.symbolStr =[_dataIdArray objectAtIndex:button.tag];
    _goToTechViewFlag = YES;
    
    [dataModal.securitySearchModel setTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModal.thread withObject:[_dataIdArray objectAtIndex:button.tag] waitUntilDone:NO];

    //    [self.navigationController popViewControllerAnimated:YES];
}

-(void)notifyDataArrive:(NSMutableArray *)dataArray{
    
    self.serverInArray = [[NSMutableArray alloc]init];
    _serverInArray = dataArray;
    _dataNameArray=[dataArray objectAtIndex:0];
    _dataIdArray = [dataArray objectAtIndex:1];
    
    [_dataArray removeAllObjects];
    for (int i=0; i<[_dataIdArray count]; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@" %@    %@",[_dataIdArray objectAtIndex:i],[_dataNameArray objectAtIndex:i]]];
    }
    [self reloadBtn];
    
    if ([[dataArray objectAtIndex:0]count]==0) {
        _noStockLabel.hidden = NO;
    }else{
        _noStockLabel.hidden = YES;
    }
    [self.view hideHUD];
    
}

-(void)notifyArrive:(NSMutableArray *)array{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    if (_goToTechViewFlag) {
        if ([[array objectAtIndex:1]count]>0) {
            [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[_identSymbolStr]];
            PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:_identSymbolStr];
            FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
            if (_portfolioNum ==1) {
                if ([[portfolioItem getIdentCodeSymbol]isEqualToString:[watchPortfolio.comparedPortfolioItem getIdentCodeSymbol]]) {
                    watchPortfolio.comparedPortfolioItem = watchPortfolio.portfolioItem;
                    watchPortfolio.portfolioItem = portfolioItem;
                    
                }else{
                    watchPortfolio.portfolioItem = portfolioItem;
                }
                
            }else{
                if ([[portfolioItem getIdentCodeSymbol]isEqualToString:[watchPortfolio.portfolioItem getIdentCodeSymbol]]) {
                    watchPortfolio.portfolioItem = watchPortfolio.comparedPortfolioItem;
                    watchPortfolio.comparedPortfolioItem = portfolioItem;
                    
                }else{
                    watchPortfolio.comparedPortfolioItem = portfolioItem;
                }
            }
            
            [_delegate navigationPop];
        }else{
            NSMutableArray * array = [[NSMutableArray alloc]init];
            array = [_serverInArray objectAtIndex:2];
            NSMutableArray * symbolaArray = [[NSMutableArray alloc]init];
            symbolaArray = [_serverInArray objectAtIndex:3];
            SymbolFormat1 * symbol = [[SymbolFormat1 alloc]init];
            symbol = [symbolaArray objectAtIndex:0];
            
            
            if ([array count]>0){
                
                [dataModal.securityName addOneSecurity:[symbolaArray objectAtIndex:0]];
                
                [dataModal.securitySearchModel setTarget:self];
                [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModal.thread withObject:_symbolStr waitUntilDone:NO];
            }
        }
        
        
    }else{
        _dataNameArray=[array objectAtIndex:0];
        _dataIdArray = [array objectAtIndex:1];
        _dataIdentCodeArray = [array objectAtIndex:2];
        
        [_dataArray removeAllObjects];
        for (int i=0; i<[_dataIdArray count]; i++) {
            [_dataArray addObject:[NSString stringWithFormat:@" %@    %@",[_dataIdArray objectAtIndex:i],[_dataNameArray objectAtIndex:i]]];
        }
        [self reloadBtn];
        
        if ([[array objectAtIndex:0]count]==0) {
            _noStockLabel.hidden = NO;
        }else{
            _noStockLabel.hidden = YES;
        }
        [self.view hideHUD];
    }
}


-(void)search:(UITextField *)textField{
    NSString *newString = [textField.text uppercaseString];
    textField.text = newString;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    if (![textField.text isEqual:@""]) {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockWithName:) onThread:dataModal.thread withObject:textField.text waitUntilDone:NO];
        _noStockLabel.hidden = YES;
    }else{
        [_dataArray removeAllObjects];
        [self reloadBtn];
        _noStockLabel.hidden = YES;
    }
    
}

-(void)reloadBtn{
    _collectionView.btnArray=_dataArray;
    _collectionView.holdBtn = 99999;
    [_collectionView reloadData];
}

-(void)searchBtnClick{
    [_searchText resignFirstResponder];
    if (![_searchText.text isEqual:@""]) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModal.thread withObject:_searchText.text waitUntilDone:NO];
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
        
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
