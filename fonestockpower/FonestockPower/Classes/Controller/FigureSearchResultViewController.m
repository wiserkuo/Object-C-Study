//
//  FigureSearchResultViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchResultViewController.h"
#import "BtnCollectionView.h"
#import "FigureSearchMyProfileModel.h"
#import "FSMainViewController.h"
#import "KxMenu.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SecuritySearchDelegate.h"
#import "SGInfoAlert.h"
#import "FSActionPlanDatabase.h"

@interface FigureSearchResultViewController ()<SecuritySearchDelegate>{
    NSMutableArray * groupNameArray;
    NSMutableArray * groupIdArray;
    NSMutableArray * watchListNameArray;
    NSMutableArray * watchListIdArray;
    NSMutableArray * watchListSymbolArray;
    int totalCount;
    int groupNum;
    BOOL addWatchListFlag;
    
    UIView * line1View;
    UIView * line2View;
    FSDataModelProc *dataModal;
}

@property (strong, nonatomic)FSInstantInfoWatchedPortfolio * watchedPortfolio;

@property (strong ,nonatomic) NSArray * markPriceArray;

@property (strong ,nonatomic)NSNumber * figureSearchId;
@property (strong ,nonatomic)NSDate * searchDate;
@property (strong, nonatomic) NSString * searchType;
@property (nonatomic) AnalysisPeriod analysisPeriod;

@property (strong, nonatomic) UIView *searchInfo;
@property (strong ,nonatomic) NSString * itemText;
@property (strong, nonatomic) UILabel * timeLabel;
@property (strong ,nonatomic) NSString * timeText;
@property (strong, nonatomic) UILabel * resultLabel;
@property (strong ,nonatomic) NSString * resultText;
@property (strong ,nonatomic) NSString * searchGroupText;
@property (strong, nonatomic) UIView *searchResultTable;

@property (strong, nonatomic) UIView *searchResultRectView;
@property (strong, nonatomic) UILabel *searchResultLabel;
@property (strong)BtnCollectionView * collectionViewBtn;

@property (strong, nonatomic) NSMutableArray * btnNameArray;
@property (strong, nonatomic) NSMutableArray * btnIdArray;
@property (strong, nonatomic) NSMutableArray * trackBtnNameArray;

@property (strong, nonatomic) UIView *trackRectView;
@property (strong, nonatomic) UILabel *trackLabel;
@property (strong, nonatomic) UIImageView *trashView;
@property (strong)BtnCollectionView * trackCollectionView;

@property (strong, nonatomic) UIView *watchListRectView;
@property (strong, nonatomic) UILabel *watchListLabel;
@property (strong, nonatomic) FSUIButton *watchListBtn;
@property (strong)BtnCollectionView * watchListCollectionView;

@property (strong,nonatomic)FSUIButton * moveBtn;
@property (strong , nonatomic) FigureSearchMyProfileModel * customModel;

@property (nonatomic)float beginY;
@property (strong, nonatomic) NSMutableArray * resultSymbolData;
@property (strong, nonatomic) NSMutableArray * trackDataArray;

@property (strong, nonatomic) SymbolFormat1 * symbol;
@property (nonatomic) BOOL toTechViewFlag;
@property (nonatomic) BOOL trashIsShowingPendingDropAppearance;

@end

@implementation FigureSearchResultViewController

- (id)initWithFigureSearchId:(NSNumber *)figureSearchId
            FuctionName:(NSString *)functionName
            conditionName:(NSString *)conditionName
              searchGroup:(NSString *)searchGroup
                 datetime:(NSDate *)datetime
                 Opportunity:(NSString *)opportunity
             targetMarket:(NSString *)targetMarket
              totalAmount:(int)totalAmount
            displayAmount:(int)displayAmount
                dataArray:(NSArray *)dataArray
              markPriceArray:(NSArray *)markPriceArray{
    
    if (self = [super init]) {
        
        self.itemText = NSLocalizedStringFromTable(conditionName, @"FigureSearch", nil);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            [formatter setDateFormat:@"MM/dd/yyyy"];
        }else{
            [formatter setDateFormat:@"yyyy/MM/dd"];
        }
        
        NSString * dateStr = [formatter stringFromDate:datetime];
        self.searchDate = [formatter dateFromString:dateStr];
        self.timeText = [formatter stringFromDate:datetime];
        
        if (totalAmount==0) {
            self.resultText = NSLocalizedStringFromTable(@"無相符個股", @"FigureSearch", nil);
        }else if (totalAmount>100){
            NSString *searchResultPattern = NSLocalizedStringFromTable(@"筆數", @"FigureSearch", nil);
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                self.resultText = [NSString stringWithFormat:searchResultPattern, displayAmount, totalAmount];
            }else{
                self.resultText = [NSString stringWithFormat:searchResultPattern,displayAmount,totalAmount];
            }
        }else{
            NSString *searchResultPattern = NSLocalizedStringFromTable(@"筆數無僅", @"FigureSearch", nil);
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                self.resultText = [NSString stringWithFormat:searchResultPattern, displayAmount, totalAmount];
            }else{
                self.resultText = [NSString stringWithFormat:searchResultPattern,totalAmount,displayAmount];
            }
        }
        self.searchGroupText = NSLocalizedStringFromTable(searchGroup, @"FigureSearch", nil);
        
        self.searchType = opportunity;
        
        self.figureSearchId = figureSearchId;
        self.btnNameArray = [[NSMutableArray alloc]init];
        self.btnIdArray = [[NSMutableArray alloc]init];
        self.customModel = [[FigureSearchMyProfileModel alloc]init];
        self.resultSymbolData = [[NSMutableArray alloc]initWithArray:dataArray];
        self.trackBtnNameArray = [[NSMutableArray alloc]init];
        self.trackDataArray = [[NSMutableArray alloc]init];
        self.markPriceArray = [[NSArray alloc]initWithArray:markPriceArray];
        
        groupNameArray = [[NSMutableArray alloc]init];
        groupIdArray = [[NSMutableArray alloc]init];
        watchListIdArray = [[NSMutableArray alloc]init];
        watchListNameArray = [[NSMutableArray alloc]init];
        watchListSymbolArray = [[NSMutableArray alloc]init];
        [self resetTrackArray];
        
        for (int i=0; i<[dataArray count]; i++) {
            SymbolFormat1 * data = [dataArray objectAtIndex:i];
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                [_btnNameArray addObject:[NSString stringWithFormat:@"%@",data->symbol]];
            }else{
                [_btnNameArray addObject:data->fullName];
            }

            [_btnIdArray addObject:[NSString stringWithFormat:@"%@",data->symbol]];
        }
        
        if ([searchGroup isEqualToString:@"Day"]) {
            _analysisPeriod = AnalysisPeriodDay;
        }else if ([searchGroup isEqualToString:@"Week"]){
            _analysisPeriod = AnalysisPeriodWeek;
        }else if ([searchGroup isEqualToString:@"Month"]){
            _analysisPeriod = AnalysisPeriodMonth;
        }
    }
    return self;
}

-(void)resetTrackArray{
    [_trackBtnNameArray removeAllObjects];
    [_trackDataArray removeAllObjects];
    _trackDataArray = [_customModel searchAllTrackWithFigureSearchId:_figureSearchId RangeType:_searchGroupText];
    if (![_trackDataArray count]==0) {
        for (int i=0; i<[_trackDataArray count]; i++) {
            TrackUpFormat * data = [_trackDataArray objectAtIndex:i];
            
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                [_trackBtnNameArray addObject:[NSString stringWithFormat:@"%@",data->symbol]];
            }else{
                [_trackBtnNameArray addObject:data->fullName];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dataModal = [FSDataModelProc sharedInstance];

    [self setUpImageBackButton];
    [self initCollectionView];
    [self setInfoText];
    [self initTrackCollectionView];
    [self initWatchListCollectionView];
    
    groupNum =0;
    self.moveBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalGreen];
    _moveBtn.translatesAutoresizingMaskIntoConstraints = YES;
    [_moveBtn setFrame:CGRectMake(0, 0, 100, 40)];
    [_moveBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _moveBtn.titleLabel.lineBreakMode = NSLineBreakByClipping;
    _moveBtn.hidden = YES;
    _moveBtn.alpha = 0.8f;

    [self.view addSubview:_moveBtn];
    
    self.watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    
    [self.view setNeedsUpdateConstraints];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[dataModal securitySearchModel]setChooseGroupTarget:self];
    [[dataModal securitySearchModel]searchUserGroup];
    
    _collectionViewBtn.myDelegate = self;
    _trackCollectionView.myDelegate = self;
    _watchListCollectionView.myDelegate = self;
    
    NSMutableArray * dataArray =[[dataModal securitySearchModel]searchUserStockArrayWithGroup:[NSNumber numberWithInt:0]];
    totalCount = (int)[[dataArray objectAtIndex:0] count];
    
}

- (void)viewWillDisappear:(BOOL)animated {

    [[dataModal securitySearchModel]setChooseGroupTarget:nil];
    [dataModal.securitySearchModel setTarget:nil];
    _collectionViewBtn.myDelegate = nil;
    _trackCollectionView.myDelegate = nil;
    _watchListCollectionView.myDelegate = nil;
    
    [super viewWillDisappear:animated];
}

#pragma mark InitView
- (void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_timeLabel,_resultLabel, _searchResultRectView,_collectionViewBtn,_trackRectView,_trackLabel,_trackCollectionView,_watchListRectView,_watchListLabel,_watchListCollectionView,_watchListBtn,line1View,line2View);
    
    NSDictionary * metrics = @{@"height": @(self.view.frame.size.height/3)};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_searchResultRectView(height)]-2-[line1View(1)]-2-[_trackRectView]-2-[line2View(1)]-2-[_watchListRectView(==_trackRectView)]-2-|" options:0 metrics:metrics views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_searchResultRectView]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[line1View]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_trackRectView]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[line2View]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_watchListRectView]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_resultLabel(30)]-2-[_collectionViewBtn]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_resultLabel]-5-[_timeLabel(100)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel(30)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionViewBtn]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_trackLabel(30)]-2-[_trackCollectionView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_trackLabel]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_trackCollectionView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_watchListLabel(30)]-2-[_watchListCollectionView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_watchListLabel]-5-[_watchListBtn(100)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_watchListCollectionView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_watchListBtn(30)]" options:0 metrics:nil views:viewControllers]];
 
    [self replaceCustomizeConstraints:constraints];
}

-(void)setInfoText{
    self.title = _itemText;
    _timeLabel.text = _timeText;
    _resultLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedStringFromTable(@"搜尋結果", @"FigureSearch", nil),_resultText];

}
-(void)groupActionSheet{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"群組", @"SecuritySearch", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    int i;
    for (i=0;i<[groupNameArray count];i++) {
        NSString * title = [groupNameArray objectAtIndex:i];
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [actionSheet setCancelButtonIndex:i];
    [self showActionSheet:actionSheet];
}
#pragma mark InitCollectionViews
-(void)initCollectionView{
    self.searchResultRectView = [[UIView alloc] init];
    self.searchResultRectView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.searchResultRectView.layer.borderColor = [UIColor blackColor].CGColor;
//    self.searchResultRectView.layer.borderWidth = 1;
    [self.view addSubview:self.searchResultRectView];
    
    line1View = [[UIView alloc] init];
    line1View.translatesAutoresizingMaskIntoConstraints = NO;
    line1View.layer.borderColor = [UIColor blackColor].CGColor;
    line1View.layer.borderWidth = 1;
    [self.view addSubview:line1View];
    
//    self.searchResultLabel = [[UILabel alloc] init];
//    self.searchResultLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.searchResultLabel.text = NSLocalizedStringFromTable(@"搜尋結果", @"FigureSearch", nil);
//    [self.searchResultRectView addSubview:self.searchResultLabel];
    
    self.resultLabel = [[UILabel alloc]init];
    _resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _resultLabel.backgroundColor = [UIColor clearColor];
    [self.searchResultRectView addSubview:_resultLabel];
    
    self.timeLabel = [[UILabel alloc]init];
    _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self.searchResultRectView addSubview:_timeLabel];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    aFlowLayout.itemSize = CGSizeMake(100, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    self.collectionViewBtn = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 310, 200) collectionViewLayout:aFlowLayout];
    _collectionViewBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionViewBtn setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionViewBtn.myDelegate = self;
    _collectionViewBtn.searchGroup = 1;
    _collectionViewBtn.holdBtn = 199999;
    _collectionViewBtn.btnArray = _btnNameArray;
    _collectionViewBtn.aligment = UIControlContentHorizontalAlignmentCenter;
    
    [self.searchResultRectView addSubview:_collectionViewBtn];
}

-(void)initTrackCollectionView{
    self.trackRectView = [[UIView alloc] init];
    self.trackRectView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.trackRectView.layer.borderColor = [UIColor blackColor].CGColor;
//    self.trackRectView.layer.borderWidth = 1;
    [self.view addSubview:self.trackRectView];
    
    line2View = [[UIView alloc] init];
    line2View.translatesAutoresizingMaskIntoConstraints = NO;
    line2View.layer.borderColor = [UIColor blackColor].CGColor;
    line2View.layer.borderWidth = 1;
    [self.view addSubview:line2View];
    
    self.trackLabel = [[UILabel alloc] init];
    self.trackLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.trackLabel.text = NSLocalizedStringFromTable(@"加入追蹤", @"FigureSearch", nil);
    [self.trackRectView addSubview:self.trackLabel];
    
    _trashView = [[UIImageView alloc]initWithFrame:CGRectMake(290, 5, 25, 25)];
    _trashView.image = [UIImage imageNamed:@"TrashCan.png"];
    _trashView.userInteractionEnabled = YES;    
    [self.trackRectView addSubview:_trashView];
    
    UICollectionViewFlowLayout *bFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    bFlowLayout.itemSize = CGSizeMake(100, 40);
    bFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    bFlowLayout.minimumInteritemSpacing = 1.0f;
    bFlowLayout.minimumLineSpacing = 1.0f;
    
    self.trackCollectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 310, 200) collectionViewLayout:bFlowLayout];
    _trackCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_trackCollectionView setCollectionViewLayout:bFlowLayout animated:YES];
    _trackCollectionView.myDelegate = self;
    _trackCollectionView.searchGroup = 1;
    _trackCollectionView.holdBtn = 199999;
    _trackCollectionView.btnArray = _trackBtnNameArray;
    _trackCollectionView.aligment = UIControlContentHorizontalAlignmentCenter;
    
    [self.trackRectView addSubview:_trackCollectionView];
}

-(void)initWatchListCollectionView{
    //    dataModal = [FSDataModelProc sharedInstance];
    self.watchListRectView = [[UIView alloc] init];
    self.watchListRectView.translatesAutoresizingMaskIntoConstraints = NO;
    //    self.watchListRectView.layer.borderColor = [UIColor blackColor].CGColor;
    //    self.watchListRectView.layer.borderWidth = 1;
    [self.view addSubview:self.watchListRectView];
    
    self.watchListLabel = [[UILabel alloc] init];
    self.watchListLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.watchListLabel.text = NSLocalizedStringFromTable(@"加入自選", @"FigureSearch", nil);
    [self.watchListRectView addSubview:self.watchListLabel];
    
    self.watchListBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _watchListBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_watchListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_watchListBtn addTarget:self action:@selector(groupActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.watchListRectView addSubview:_watchListBtn];
    
    UICollectionViewFlowLayout *bFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    bFlowLayout.itemSize = CGSizeMake(100, 40);
    bFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    bFlowLayout.minimumInteritemSpacing = 1.0f;
    bFlowLayout.minimumLineSpacing = 1.0f;
    
    self.watchListCollectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 310, 200) collectionViewLayout:bFlowLayout];
    _watchListCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_watchListCollectionView setCollectionViewLayout:bFlowLayout animated:YES];
    _watchListCollectionView.myDelegate = self;
    _watchListCollectionView.searchGroup = 1;
    _watchListCollectionView.holdBtn = 199999;
    NSMutableArray * dataArray =[[dataModal securitySearchModel]searchUserStockArrayWithGroup:[NSNumber numberWithInt:1] ];
    watchListIdArray = [dataArray objectAtIndex:0];
    watchListSymbolArray = [dataArray objectAtIndex:1];
    watchListNameArray = [dataArray objectAtIndex:2];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        _watchListCollectionView.btnArray =  [dataArray objectAtIndex:1];
    }else{
        _watchListCollectionView.btnArray =  [dataArray objectAtIndex:2];
    }
    _watchListCollectionView.aligment = UIControlContentHorizontalAlignmentCenter;
    
    [self.watchListRectView addSubview:_watchListCollectionView];
}
#pragma mark TrashCamAnimation
- (void)updateTrashAppearanceForPendingDrop {
    
    self.trashView.transform = CGAffineTransformMakeRotation(-.1);
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        self.trashView.transform = CGAffineTransformMakeRotation(.1);
    } completion:nil];
}

- (void)updateTrashAppearanceForNoPendingDrop {

    [UIView animateWithDuration:0.15 animations:^{
        self.trashView.transform = CGAffineTransformIdentity;
    }];
}

-(void)deleteBtn:(UIButton *)button{
    _trashView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView beginAnimations:@"_trashView" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationRepeatCount:0.0f];
    _trashView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView commitAnimations];
    
}
#pragma mark NotifyArrive
-(void)notifyArrive:(NSMutableArray *)dataArray{
    if ([[dataArray objectAtIndex:1]count]>0) {
        if (_toTechViewFlag) {
            FSMainViewController *instantInfoMainViewController = [[FSMainViewController alloc] init];
            NSString * symbolStr =[NSString stringWithFormat:@"%c%c %@",_symbol->IdentCode[0],_symbol->IdentCode[1],_symbol->symbol];
            [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
            PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[NSString stringWithFormat:@"%c%c %@",_symbol->IdentCode[0],_symbol->IdentCode[1],_symbol->symbol]];
            _watchedPortfolio.portfolioItem = portfolioItem;
            instantInfoMainViewController.firstLevelMenuOption = 1;
            instantInfoMainViewController.techOption = _analysisPeriod;
            [self.navigationController pushViewController:instantInfoMainViewController animated:NO];
        }
        if (addWatchListFlag && !_toTechViewFlag) {
            SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%c%c %@",_symbol->IdentCode[0],_symbol->IdentCode[1],_symbol->symbol]];
            [dataModal.portfolioData selectGroupID:groupNum+1];
            [dataModal.portfolioData AddItem:secu];
            totalCount+=1;
            
            BOOL same = NO;
            for (int i=0; i<[watchListSymbolArray count]; i++) {
                NSString * symbolStr = [watchListSymbolArray objectAtIndex:i];
                if ([symbolStr isEqualToString:_symbol->symbol]) {
                    same = YES;
                }
            }
            if (!same) {
                [watchListIdArray addObject:[NSString stringWithFormat:@"%c%c",_symbol->IdentCode[0],_symbol->IdentCode[1]]];
                [watchListSymbolArray addObject:_symbol->symbol];
                [watchListNameArray addObject:_symbol->fullName];
            }
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                _watchListCollectionView.btnArray = watchListSymbolArray;
            }else{
                _watchListCollectionView.btnArray = watchListNameArray;
            }
            
            [_watchListCollectionView reloadData];
        }
    }else{
        
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockFromServerWithName:) onThread:dataModal.thread withObject:_symbol->symbol waitUntilDone:NO];
    }
}

-(void)notifyDataArrive:(NSMutableArray *)dataArray{
    NSMutableArray * array = [[NSMutableArray alloc]init];
    array = [dataArray objectAtIndex:0];
    NSMutableArray * symbolaArray = [[NSMutableArray alloc]init];
    symbolaArray = [dataArray objectAtIndex:1];
    SymbolFormat1 * symbol = [[SymbolFormat1 alloc]init];
   // symbol = [symbolaArray objectAtIndex:0];
    symbol->fullName = [array objectAtIndex:0];
    symbol->symbol = [symbolaArray objectAtIndex:0];
    
    if ([array count]>0){
        [dataModal.securityName addOneSecurity:symbol];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchAmericaStockWithSymbol:) onThread:dataModal.thread withObject:_symbol->symbol waitUntilDone:NO];
    }
}

-(void)groupNotifyDataArrive:(NSMutableArray *)dataArray{
    groupNameArray = [dataArray objectAtIndex:0];
    groupIdArray = [dataArray objectAtIndex:1];
    
    [_watchListBtn setTitle:[groupNameArray objectAtIndex:groupNum] forState:UIControlStateNormal];
}

#pragma mark ActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];

    if (buttonIndex <[groupNameArray count]) {
        [_watchListBtn setTitle:[groupNameArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        NSMutableArray * dataArray =[[dataModal securitySearchModel]searchUserStockArrayWithGroup:[NSNumber numberWithInteger:buttonIndex+1] ];
        watchListIdArray = [dataArray objectAtIndex:0];
        watchListSymbolArray = [dataArray objectAtIndex:1];
        watchListNameArray = [dataArray objectAtIndex:2];
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            _watchListCollectionView.btnArray =  [dataArray objectAtIndex:1];
        }else{
            _watchListCollectionView.btnArray = [dataArray objectAtIndex:2];
        }
        
        groupNum = (int)buttonIndex;
        [_watchListCollectionView reloadData];
    }
}
#pragma mark GroupButtonHandler
-(void)groupButtonClick:(FSUIButton *)button Object:(BtnCollectionView *)scrl{
    button.selected = NO;
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if ([scrl isEqual:_collectionViewBtn]) {
        self.symbol = [_resultSymbolData objectAtIndex:button.tag];
    }else if([scrl isEqual:_trackCollectionView]){
        TrackUpFormat * data = [_trackDataArray objectAtIndex:button.tag];
        SymbolFormat1 * newSymbol = [[SymbolFormat1 alloc]init];
        newSymbol->IdentCode[0] = (char)[data->identCode characterAtIndex:0];
        newSymbol->IdentCode[1] = (char)[data->identCode characterAtIndex:1];
        newSymbol->symbol = data->symbol;
        self.symbol =newSymbol;
    }else{
        NSString * identCode = [watchListIdArray objectAtIndex:button.tag];
        SymbolFormat1 * newSymbol = [[SymbolFormat1 alloc]init];
        newSymbol->IdentCode[0] = (char)[identCode characterAtIndex:0];
        newSymbol->IdentCode[1] = (char)[identCode characterAtIndex:1];
        newSymbol->symbol = [watchListSymbolArray objectAtIndex:button.tag];
        self.symbol =newSymbol;
    }
    _toTechViewFlag = YES;
    [dataModal.securitySearchModel setTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchSymbolAndFullNameWithSymbolFormat1:) onThread:dataModal.thread withObject:_symbol waitUntilDone:NO];

    //goto Kline
    _collectionViewBtn.holdBtn = 99999;
    _trackCollectionView.holdBtn = 99999;
    _watchListCollectionView.holdBtn = 99999;
}
#pragma mark GestureRecognizer
-(void)buttonPan:(UILongPressGestureRecognizer *)sender{
    if ([sender state] == UIGestureRecognizerStateBegan) {

        [self begin:sender];
    }else if ([sender state] == UIGestureRecognizerStateChanged){
        CGPoint location = [sender locationInView:self.view];
        if (_beginY > _trackRectView.frame.origin.y && CGRectIntersectsRect([_moveBtn convertRect:_moveBtn.bounds toView:_trashView], _trashView.bounds) ) {
            [self updateTrashAppearanceForPendingDrop];
        }else{
            [self updateTrashAppearanceForNoPendingDrop];
        }
//        NSLog(@"location.y:%f",location.y);
//        NSLog(@"sender:%f",sender.view.center.y);
        [_moveBtn setCenter:CGPointMake(location.x, location.y)];
    }else if ([sender state] == UIGestureRecognizerStateEnded){
        [self end:sender];
        if (!CGRectIntersectsRect([_moveBtn convertRect:_moveBtn.bounds toView:_trashView], _trashView.bounds) ) {
            [self updateTrashAppearanceForNoPendingDrop];
        }
    }
}
-(void)begin:(UILongPressGestureRecognizer *)sender{
    CGPoint location = [sender locationInView:self.view];
    _beginY = location.y;
    _moveBtn.center = CGPointMake(location.x, location.y);
    NSString * moveBtnString = @"";

    if (_beginY>_trackRectView.frame.origin.y && _beginY<_watchListRectView.frame.origin.y) {
        [_moveBtn setTitle:[_trackBtnNameArray objectAtIndex:sender.view.tag] forState:UIControlStateNormal];
    }else if (_beginY>_watchListRectView.frame.origin.y){
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            moveBtnString = [watchListSymbolArray objectAtIndex:sender.view.tag];
        }else{
            moveBtnString = [watchListNameArray objectAtIndex:sender.view.tag];
        }
        [_moveBtn setTitle:moveBtnString forState:UIControlStateNormal];
    }else{
        [_moveBtn setTitle:[_btnNameArray objectAtIndex:sender.view.tag] forState:UIControlStateNormal];
    }
    [_moveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _moveBtn.hidden = NO;
    
}

-(void)end:(UILongPressGestureRecognizer *)sender{
    CGPoint location = [sender locationInView:self.view];
    if (_beginY <_trackRectView.frame.origin.y) {
        SymbolFormat1 * symbol = [_resultSymbolData objectAtIndex:sender.view.tag];
        if (location.y > _trackRectView.frame.origin.y && location.y<_watchListRectView.frame.origin.y) {
            if ([_trackBtnNameArray count] >= 12) {
                [SGInfoAlert showInfo:NSLocalizedStringFromTable(@"追蹤股票支數已超過", @"FigureSearch",nil) bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
            }else{
                NSNumber * markPrice = [_markPriceArray objectAtIndex:sender.view.tag];
                [self addTrackList:symbol MarkPrice:markPrice];
            }
        }else if (location.y > _watchListRectView.frame.origin.y){
            [self addWatchList:nil SymbolFormat1:symbol];
        }
    }else if(_beginY>_trackRectView.frame.origin.y && _beginY<_watchListRectView.frame.origin.y){
        TrackUpFormat * track = [_trackDataArray objectAtIndex:sender.view.tag];
        if (CGRectIntersectsRect([_moveBtn convertRect:_moveBtn.bounds toView:_trashView], _trashView.bounds) ) {
            [self updateTrashAppearanceForNoPendingDrop];
            [self removeTrackList:track];
        }else if (location.y >_watchListRectView.frame.origin.y){
            [self addWatchList:track SymbolFormat1:nil];
        }
    }else{
        if (CGRectIntersectsRect([_moveBtn convertRect:_moveBtn.bounds toView:_trashView], _trashView.bounds) ) {
            [self updateTrashAppearanceForNoPendingDrop];
            [self removeWatchList:sender];
        }
    }
    _moveBtn.hidden = YES;
}

-(void)editTotalCount:(int)count{
    
}

#pragma mark AddFromList
//加入形態追蹤
-(void)addTrackList:(SymbolFormat1 *)symbol MarkPrice:(NSNumber *)markPrice{
    BOOL TrackCount = [_customModel searchTrackWithFigureSearchId:_figureSearchId RangeType:_searchGroupText IdentCode:[NSString stringWithFormat:@"%c%c",symbol->IdentCode[0],symbol->IdentCode[1]] Symbol:symbol->symbol TrackDate:_searchDate SearchType:_searchType];
    if (!TrackCount) {
        [_customModel addTrackWithFigureSearchId:_figureSearchId RangeType:_searchGroupText IdentCode:[NSString stringWithFormat:@"%c%c",symbol->IdentCode[0],symbol->IdentCode[1]] Symbol:symbol->symbol TrackDate:_searchDate SearchType:_searchType MarkPrice:markPrice FullName:symbol->fullName];
        [self resetTrackArray];
        _symbol = symbol;
        _toTechViewFlag = NO;
        addWatchListFlag = NO;
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchSymbolAndFullNameWithSymbolFormat1:) onThread:dataModal.thread withObject:_symbol waitUntilDone:NO];
        [_trackCollectionView reloadData];
        
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS){
            NSString *addToTrackList = NSLocalizedStringFromTable(@"加入某支追蹤", @"FigureSearch",nil);
            addToTrackList = [addToTrackList stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:symbol -> symbol];
            [SGInfoAlert showInfo:addToTrackList bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
        }else{
            [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"加入追蹤", @"FigureSearch",nil),symbol -> fullName] bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
        }
    }else {
        [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"已加入追蹤", @"FigureSearch",nil)] bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
    }
}
//加入watchList
-(void)addWatchList:(TrackUpFormat *)track SymbolFormat1:(SymbolFormat1 *)symbol1{
    if (track == nil && symbol1 != nil) {
        track = [[TrackUpFormat alloc]init];
        track -> symbol = symbol1 -> symbol;
        track -> fullName = symbol1 -> fullName;
        track -> identCode = [NSString stringWithFormat:@"%c%c", symbol1 -> IdentCode[0], symbol1 -> IdentCode[1]];
        
    }else{
        const char * trackIdentCode = [track -> identCode cStringUsingEncoding:NSUTF8StringEncoding];
        symbol1 = [[SymbolFormat1 alloc]init];
        symbol1 -> IdentCode[0] = trackIdentCode[0];
        symbol1 -> IdentCode[1] = trackIdentCode[1];
        symbol1 -> symbol = track -> symbol;
    }
    
    if (totalCount<[[FSFonestock sharedInstance]portfolioQuota]) {
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        
        int count = [dataModal.securitySearchModel searchUserStockWithName:track->symbol Group:groupNum + 1 Country:group];
        if (count>0) {
            [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@",NSLocalizedStringFromTable(@"已加入自選", @"FigureSearch",nil)] bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
        }else{
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                NSString *addToWatchList = NSLocalizedStringFromTable(@"加入某支自選", @"FigureSearch",nil);
                addToWatchList = [addToWatchList stringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:track -> symbol];
                [SGInfoAlert showInfo:addToWatchList bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
            }else{
                [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"加入自選", @"FigureSearch",nil),track->fullName] bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
            }
        }
        //判斷是否已存在 如已加入則修改
        NSMutableArray * array = [[NSMutableArray alloc]init];
        [array addObject:[NSString stringWithFormat:@"%@ %@",track->identCode,track->symbol]];
        [array addObject:[NSNumber numberWithInt:groupNum + 1]];
        
        [dataModal.securitySearchModel setEditChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(editUserStock:) onThread:dataModal.thread withObject:array waitUntilDone:NO];
        
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchSymbolAndFullNameWithSymbolFormat1:) onThread:dataModal.thread withObject:symbol1 waitUntilDone:NO];
        _symbol = symbol1;
        _toTechViewFlag = NO;
        addWatchListFlag = YES;
        //        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",track->identCode,track->symbol]];
        //        [dataModal.portfolioData selectGroupID:groupNum + 1];
        //        [dataModal.portfolioData AddItem:secu];
        totalCount+=1;
        BOOL same = NO;
        for (int i=0; i<[watchListSymbolArray count]; i++) {
            NSString * symbolStr = [watchListSymbolArray objectAtIndex:i];
            if ([symbolStr isEqualToString:track->symbol]) {
                same = YES;
            }
        }
        if (!same) {
            [watchListIdArray addObject:track->identCode];
            [watchListSymbolArray addObject:track->symbol];
            [watchListNameArray addObject:track->fullName];
        }
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            _watchListCollectionView.btnArray = watchListSymbolArray;
        }else{
            _watchListCollectionView.btnArray = watchListNameArray;
        }
        
        [_watchListCollectionView reloadData];
    }
    
}
#pragma mark RemoveFromList
//取消形態追蹤
-(void)removeTrackList:(TrackUpFormat *)track{
    
    [_customModel deleteAllTrackWithFigureSearchId:_figureSearchId RangeType:_searchGroupText IdentCode:track->identCode Symbol:track->symbol SearchType:_searchType];
    [self resetTrackArray];
    [_trackCollectionView reloadData];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        NSString *removeFromTrackList = NSLocalizedStringFromTable(@"取消追蹤股票", @"FigureSearch",nil);
        removeFromTrackList = [removeFromTrackList stringByReplacingCharactersInRange:NSMakeRange(7, 1) withString:track -> symbol];
        [SGInfoAlert showInfo:removeFromTrackList bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
    }else{
        [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"取消追蹤股票", @"FigureSearch",nil),track -> fullName] bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
    }
}
//取消watchList
-(void)removeWatchList:(UILongPressGestureRecognizer *)sender{
    [dataModal.portfolioData selectGroupID:groupNum+1];
    SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[watchListIdArray objectAtIndex:sender.view.tag],[watchListSymbolArray objectAtIndex:sender.view.tag]]];
    
    BOOL exist = [[FSActionPlanDatabase sharedInstances] searchExistSymbolWithSymbol:[NSString stringWithFormat:@"%c%c %@", secu->identCode[0], secu->identCode[1], secu->symbol]];
    if(!exist){
        [dataModal.portfolioData RemoveItem:secu->identCode andSymbol:secu->symbol];
        totalCount-=1;
        [watchListIdArray removeObjectAtIndex:sender.view.tag];
        [watchListSymbolArray removeObjectAtIndex:sender.view.tag];
        [watchListNameArray removeObjectAtIndex:sender.view.tag];

        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            _watchListCollectionView.btnArray = watchListSymbolArray;
            NSString *removeFromWatchList = NSLocalizedStringFromTable(@"取消自選", @"FigureSearch",nil);
            removeFromWatchList = [removeFromWatchList stringByReplacingCharactersInRange:NSMakeRange(7, 1) withString:secu -> symbol];
            [SGInfoAlert showInfo:removeFromWatchList bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
        }else{
            _watchListCollectionView.btnArray = watchListNameArray;
            [SGInfoAlert showInfo:[NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"取消自選", @"FigureSearch",nil),secu->fullName] bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
        }
        [_watchListCollectionView reloadData];
    }else{
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
            UIAlertView *deleteAlert = [[UIAlertView alloc]initWithTitle:@"Watchlists" message:@"This stock is in Action Plan.\nIf you wish to remove it from the watchlist,\nplease go to Action Plan to delete it first." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
            [deleteAlert show];
        }else{
            [SGInfoAlert showInfo:NSLocalizedStringFromTable(@"請先由交易計劃清單移除此檔股票", @"FigureSearch",nil) bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:self.view];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
