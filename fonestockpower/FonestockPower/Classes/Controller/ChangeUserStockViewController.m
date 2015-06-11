//
//  ChangeUserStockViewController.m
//  WirtsLeg
//
//  Created by Neil on 14/2/17.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "ChangeUserStockViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSUIButton.h"
#import "BtnCollectionView.h"

@interface ChangeUserStockViewController ()<UIActionSheetDelegate>{
    int groupNumber;
}



@property (strong, nonatomic) FSUIButton * searchGroupBtn;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) BtnCollectionView * collectionView;
@property (strong, nonatomic) UILabel * noStockLabel;

@property (strong) NSMutableArray * dataNameArray;
@property (strong) NSMutableArray * dataIdArray;
@property (strong) NSMutableArray * dataIdentCodeArray;
@property (strong, nonatomic) NSMutableArray * categoryArray;
@property (strong, nonatomic) NSMutableArray * groupIdArray;
@property (nonatomic)int searchNum;
@property (nonatomic) int portfolioNum;


@property (nonatomic, strong) NSMutableDictionary *mainDict;
@end

@implementation ChangeUserStockViewController

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
    self.dataNameArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    self.dataIdentCodeArray = [[NSMutableArray alloc]init];
    self.categoryArray = [[NSMutableArray alloc]init];
    self.groupIdArray = [[NSMutableArray alloc]init];
    
    [self initView];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"ChangeStock.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if(_mainDict){
        _searchNum= [(NSNumber *)[_mainDict objectForKey:@"SearchNum"]intValue];
    }else{
        _searchNum=0;
    }
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"ChangeStock.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.mainDict = [[NSMutableDictionary alloc] init];
    [self.mainDict setObject:[NSNumber numberWithInt:_searchNum] forKey:@"SearchNum"];
    [self.mainDict writeToFile:path atomically:YES];
}

-(void)initView{
    self.searchGroupBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    self.searchGroupBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_searchGroupBtn];
    
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = NSLocalizedStringFromTable(@"選取股票", @"SecuritySearch", nil);
    _titleLabel.textColor = [UIColor blueColor];
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_titleLabel];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    aFlowLayout.itemSize = CGSizeMake(100, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    _collectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:aFlowLayout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionView.myDelegate = self;
    _collectionView.searchGroup =1;
    _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
    _collectionView.aligment = UIControlContentHorizontalAlignmentCenter;
    [self.view addSubview:_collectionView];
    
    self.noStockLabel = [[UILabel alloc]init];
    _noStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noStockLabel.text = NSLocalizedStringFromTable(@"無相符個股", @"SecuritySearch", nil);
    _noStockLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_noStockLabel];
    _noStockLabel.hidden = YES;
    
    [self setAutoLayout];
}

-(void)setAutoLayout{
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_searchGroupBtn,_titleLabel,_collectionView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_searchGroupBtn(44)][_titleLabel(25)]-2-[_collectionView]-2-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchGroupBtn]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_collectionView]-3-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex<[_categoryArray count]) {
        self.searchNum = (int)buttonIndex;
        int searchNum = [(NSNumber *)[self.groupIdArray objectAtIndex:self.searchNum]intValue];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:searchNum] waitUntilDone:NO];
    
        [self.searchGroupBtn setTitle:[_categoryArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
}

-(void)groupButtonClick{
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

-(void)groupNotifyDataArrive:(NSMutableArray *)array{
    _categoryArray = [array objectAtIndex:0];
    _groupIdArray = [array objectAtIndex:1];
    [_searchGroupBtn addTarget:self action:@selector(groupButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];
    int searchNum = [(NSNumber *)[_groupIdArray objectAtIndex:_searchNum]intValue];
    [_searchGroupBtn setTitle:[_categoryArray objectAtIndex:_searchNum] forState:UIControlStateNormal];
    
    [dataModal.securitySearchModel setChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:searchNum] waitUntilDone:NO];
}

-(void)notifyDataArrive:(NSMutableArray *)dataArray{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    _dataIdArray = [dataArray objectAtIndex:1];
    _dataIdentCodeArray = [dataArray objectAtIndex:2];
    [_dataNameArray removeAllObjects];
    for (int i=0; i<[_dataIdArray count]; i++) {
        NSString * symbol = [_dataIdArray objectAtIndex:i];
        NSString * identCode = [_dataIdentCodeArray objectAtIndex:i];
        NSString * fullName = [dataModal.securitySearchModel searchFullNameWithIdentCode:identCode Symbol:symbol];
        if (fullName !=nil) {
            [_dataNameArray addObject:fullName];
        }else{
            [_dataNameArray addObject:@""];
        }
    }
    
    [self reloadBtn];
}

-(void)setTarget:(MacroeconomicDrawViewController *)controller
{
    self.macroeconomicViewController = controller;
}

-(void)reloadBtn{
    _collectionView.btnArray=_dataNameArray;
    _collectionView.holdBtn = 99999;
    [_collectionView reloadData];
}

-(void)titleButtonClick:(FSUIButton *)button{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    self.macroeconomicViewController.portfolioFlag = YES;
    NSString * symbolStr =[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]];
//    [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:symbolStr];
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
    //    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
