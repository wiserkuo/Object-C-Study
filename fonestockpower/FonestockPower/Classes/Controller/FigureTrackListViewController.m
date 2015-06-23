//
//  FigureTrackListViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureTrackListViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "KxMenu.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSTeachPopView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SortingCustomTableView.h"
#import "TrackCenter.h"
#import "FSTeachPopDelegate.h"
#import "SecuritySearchModel.h"

@interface FigureTrackListViewController ()<SortingTableViewDelegate,TrackCenterDelegate,FSTeachPopDelegate,UIActionSheetDelegate,UIAlertViewDelegate>{
    UIAlertView * deleteAlert;
}

@property (strong, nonatomic)FSInstantInfoWatchedPortfolio * watchedPortfolio;

@property (strong , nonatomic) FigureSearchMyProfileModel * customModel;
@property (nonatomic) AnalysisPeriod analysisPeriod;

@property (nonatomic) int nowSorting;
@property (nonatomic) BOOL nowSortingType;//YES:遞增 NO:遞減

@property (strong, nonatomic)NSMutableArray * trackUpArray;
@property (strong, nonatomic)NSString * figureSearchName;
@property (strong, nonatomic)NSNumber * figureSearchId;
@property (strong, nonatomic)NSString * range;

@property (strong, nonatomic)UIView * infoView;
@property (strong, nonatomic)UILabel * caseTitleLabel;
@property (strong, nonatomic)UILabel * caseLabel;

@property (strong, nonatomic)FSUIButton * searchGroupBtn;

@property (strong, nonatomic)UILabel * tradesTitleLabel;
@property (strong, nonatomic)UILabel * tradesLabel;

@property (strong, nonatomic)UILabel * wonTradesTitleLabel;
@property (strong, nonatomic)UILabel * wonTradesLabel;
@property (nonatomic)int profitItem;

@property (strong, nonatomic)UILabel * avgTitleLabel;
@property (strong, nonatomic)UILabel * avgLabel;

@property (strong, nonatomic)UILabel * totalTitleLabel;
@property (strong, nonatomic)UILabel * totalLabel;
@property (nonatomic)float totalProfit;

@property (strong, nonatomic)UILabel * bestTitleLabel;
@property (strong, nonatomic)UILabel * bestLabel;
@property (nonatomic)float bestProfit;

@property (strong, nonatomic)UILabel * worstTitleLabel;
@property (strong, nonatomic)UILabel * worstLabel;
@property (nonatomic)float worstProfit;

@property (strong, nonatomic)SortingCustomTableView * tableView;

@property (strong, nonatomic) NSMutableArray * columnNames;
@property (strong, nonatomic) NSMutableArray * searchKeyArray;

@property (strong, nonatomic) NSMutableArray * trackDataArray;

@property (strong, nonatomic) FSTeachPopView * explainView;

@property (strong, nonatomic) NSMutableArray * categoryArray;
@property (strong, nonatomic) NSMutableArray * groupIdArray;

@property (strong, nonatomic) NSMutableArray * dataNameArray;
@property (strong, nonatomic) NSMutableArray * dataIdArray;

@property (nonatomic) int userStockCount;
@property (strong, nonatomic) UIActionSheet *groupActionSheet;

@property (nonatomic)BOOL firstInFlag;
@property (strong, nonatomic) TrackDownFormat * trackDown;
@property (strong, nonatomic) UILabel * addLabel;
@property (strong, nonatomic) UITapGestureRecognizer * tap;

@end

@implementation FigureTrackListViewController


- (id)initWithTrackUpArray:(NSMutableArray *)trackUpArray FigureSearchName:(NSString *)name FigureSearchId:(NSNumber *)figureSearchId Range:(NSString *)range{
    self = [super init];
    if (self) {
        self.trackUpArray = [[NSMutableArray alloc]init];
        _trackUpArray = trackUpArray;
        _figureSearchName = name;
        self.figureSearchId =figureSearchId;
        self.range = range;
//        if ([range isEqualToString:NSLocalizedStringFromTable(@"Day", @"FigureSearch", nil)]) {
//            _analysisPeriod = AnalysisPeriodDay;
//        }else if ([range isEqualToString:NSLocalizedStringFromTable(@"Week", @"FigureSearch", nil)]){
//            _analysisPeriod = AnalysisPeriodWeek;
//        }else if ([range isEqualToString:NSLocalizedStringFromTable(@"Month", @"FigureSearch", nil)]){
//            _analysisPeriod = AnalysisPeriodMonth;
//        }
        if([@"Day" isEqualToString:range]){
            _analysisPeriod = AnalysisPeriodDay;
        }else if([@"Week" isEqualToString:range]){
            _analysisPeriod = AnalysisPeriodWeek;
        }else if([@"Month" isEqualToString:range]){
            _analysisPeriod = AnalysisPeriodMonth;
        }
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self registerLoginNotificationCallBack:self seletor:@selector(loginReload)];
    [self loginReload];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self unregisterLoginNotificationCallBack:self];
}

-(void)loginReload{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    
    [dataModal.securitySearchModel setChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:0] waitUntilDone:NO];
    
    [dataModal.securitySearchModel setChooseGroupTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserGroup) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
}

-(void)upTrack{
    
    _totalProfit = 0.0f;
    _bestProfit = 0.0f;
    _worstProfit = 0.0f;
    _profitItem = 0;
    
    TrackCenter *trackCenter = [TrackCenter sharedInstance];
    trackCenter.delegate = self;
    if ([_trackUpArray count]>0) {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"FigureSearch", nil)];
        [trackCenter upTrackWithTrackUpArray:_trackUpArray];
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedStringFromTable(@"無追蹤股票", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil)  otherButtonTitles:nil, nil];
        [alert show];
        _avgLabel.text = @"0.00%";
        _totalLabel.text = @"0.00%";
        _bestLabel.text = @"0.00%";
        _worstLabel.text = @"0.00%";
        _wonTradesLabel.text = @"0";
        _tradesLabel.text = @"0";
        [_trackDataArray removeAllObjects];
        [_tableView reloadDataNoOffset];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpImageBackButton];
    self.navigationItem.title = NSLocalizedStringFromTable(@"型態追蹤列表", @"FigureSearch", nil);
    
    self.trackDataArray = [[NSMutableArray alloc]init];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    self.categoryArray = [[NSMutableArray alloc]init];
    self.groupIdArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    [self initInfo];
    [self initVar];
    [self initTableView];
    [self.view setNeedsUpdateConstraints];
    NSString * show = [_customModel searchInstructionByControllerName:[[self class] description]];
    if ([show isEqualToString:@"YES"]) {
        [self teachPop];
    }
    
    self.watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    _firstInFlag = YES;
    
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    _dataNameArray = [array objectAtIndex:0];
    _dataIdArray = [array objectAtIndex:1];
    _userStockCount = (int)[_dataIdArray count];
    if (_firstInFlag) {
        [self upTrack];
        _firstInFlag = NO;
    }
    [_tableView reloadDataNoOffset];
}

-(void)groupNotifyDataArrive:(NSMutableArray *)array{ //查詢自選群組名之結果
    _categoryArray = [array objectAtIndex:0];
    _groupIdArray = [array objectAtIndex:1];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_infoView,_tableView,_caseTitleLabel,_caseLabel,_searchGroupBtn,_tradesTitleLabel,_tradesLabel,_wonTradesTitleLabel,_wonTradesLabel,_avgTitleLabel,_avgLabel,_totalTitleLabel,_totalLabel,_bestTitleLabel,_bestLabel,_worstTitleLabel,_worstLabel);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_infoView(120)]-1-[_tableView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoView]|" options:0 metrics:nil views:viewControllers]];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:viewControllers]];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_caseLabel(20)]-8-[_tradesTitleLabel(20)]-8-[_avgTitleLabel(20)]-8-[_bestTitleLabel(20)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewControllers]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_caseLabel]-95-[_searchGroupBtn(70)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7-[_caseTitleLabel(20)]-8-[_tradesTitleLabel(20)]-8-[_avgTitleLabel(20)]-8-[_bestTitleLabel(20)]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewControllers]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_caseTitleLabel(85)]-2-[_caseLabel]-2-[_searchGroupBtn(80)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    }
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[_searchGroupBtn(35)]" options:0 metrics:nil views:viewControllers]];
#ifdef PatternPowerUS
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_tradesTitleLabel(85)]-2-[_tradesLabel(70)]-2-[_wonTradesTitleLabel(100)]-2-[_wonTradesLabel]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
#else
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_tradesTitleLabel(85)]-2-[_tradesLabel(70)]-2-[_wonTradesTitleLabel(85)]-2-[_wonTradesLabel]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
#endif
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_avgTitleLabel(85)]-2-[_avgLabel(70)]-2-[_totalTitleLabel(85)]-2-[_totalLabel]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_bestTitleLabel(85)]-2-[_bestLabel(70)]-2-[_worstTitleLabel(85)]-2-[_worstLabel]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(void)initInfo{
    self.infoView = [[UIView alloc]init];
    _infoView.translatesAutoresizingMaskIntoConstraints = NO;
    _infoView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
    [self.view addSubview:_infoView];
    
    self.caseTitleLabel = [[UILabel alloc]init];
    _caseTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _caseTitleLabel.backgroundColor = [UIColor clearColor];
    _caseTitleLabel.text = NSLocalizedStringFromTable(@"型態名稱", @"FigureSearch", nil);
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"tw"] || [group isEqualToString:@"cn"]) {
        [self.infoView addSubview:_caseTitleLabel];
    }
    
    
    self.caseLabel = [[UILabel alloc]init];
    _caseLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _caseLabel.backgroundColor = [UIColor clearColor];
    _caseLabel.text = NSLocalizedStringFromTable(_figureSearchName, @"FigureSearch", nil);
    [self.infoView addSubview:_caseLabel];
    
    self.searchGroupBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _searchGroupBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchGroupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_searchGroupBtn addTarget:self action:@selector(changeSearchGroup) forControlEvents:UIControlEventTouchUpInside];
    [self.infoView addSubview:_searchGroupBtn];
    
    self.tradesTitleLabel = [[UILabel alloc]init];
    _tradesTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tradesTitleLabel.backgroundColor = [UIColor clearColor];
    _tradesTitleLabel.text = NSLocalizedStringFromTable(@"追蹤筆數", @"FigureSearch", nil);
    [self.infoView addSubview:_tradesTitleLabel];
    
    self.tradesLabel = [[UILabel alloc]init];
    _tradesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tradesLabel.backgroundColor = [UIColor clearColor];
    [self.infoView addSubview:_tradesLabel];
    
    self.wonTradesTitleLabel = [[UILabel alloc]init];
    _wonTradesTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _wonTradesTitleLabel.backgroundColor = [UIColor clearColor];
    _wonTradesTitleLabel.text = NSLocalizedStringFromTable(@"獲利筆數", @"FigureSearch", nil);
    [self.infoView addSubview:_wonTradesTitleLabel];
    
    self.wonTradesLabel = [[UILabel alloc]init];
    _wonTradesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _wonTradesLabel.backgroundColor = [UIColor clearColor];
    [self.infoView addSubview:_wonTradesLabel];
    
    self.avgTitleLabel = [[UILabel alloc]init];
    _avgTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _avgTitleLabel.backgroundColor = [UIColor clearColor];
//    _avgTitleLabel.font = [UIFont systemFontOfSize:15.0f];
    _avgTitleLabel.text = NSLocalizedStringFromTable(@"平均報酬", @"FigureSearch", nil);
    [self.infoView addSubview:_avgTitleLabel];
    
    self.avgLabel = [[UILabel alloc]init];
    _avgLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _avgLabel.backgroundColor = [UIColor clearColor];
    _avgLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.infoView addSubview:_avgLabel];
    
    self.totalTitleLabel = [[UILabel alloc]init];
    _totalTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _totalTitleLabel.backgroundColor = [UIColor clearColor];
//    _totalTitleLabel.font = [UIFont systemFontOfSize:15.0f];
    _totalTitleLabel.text = NSLocalizedStringFromTable(@"累加報酬", @"FigureSearch", nil);
    [self.infoView addSubview:_totalTitleLabel];
    
    self.totalLabel = [[UILabel alloc]init];
    _totalLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _totalLabel.backgroundColor = [UIColor clearColor];
    _totalLabel.font = [UIFont systemFontOfSize:15.0f];
    _totalLabel.adjustsFontSizeToFitWidth = YES;
    [self.infoView addSubview:_totalLabel];
    
    self.bestTitleLabel = [[UILabel alloc]init];
    _bestTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bestTitleLabel.backgroundColor = [UIColor clearColor];
//    _bestTitleLabel.font = [UIFont systemFontOfSize:15.0f];
    _bestTitleLabel.text = NSLocalizedStringFromTable(@"最大獲利", @"FigureSearch", nil);
    [self.infoView addSubview:_bestTitleLabel];
    
    self.bestLabel = [[UILabel alloc]init];
    _bestLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bestLabel.backgroundColor = [UIColor clearColor];
    _bestLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.infoView addSubview:_bestLabel];
    
    self.worstTitleLabel = [[UILabel alloc]init];
    _worstTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _worstTitleLabel.backgroundColor = [UIColor clearColor];
//    _worstTitleLabel.font = [UIFont systemFontOfSize:15.0f];
    _worstTitleLabel.text = NSLocalizedStringFromTable(@"最大損失", @"FigureSearch", nil);
    [self.infoView addSubview:_worstTitleLabel];
    
    self.worstLabel = [[UILabel alloc]init];
    _worstLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _worstLabel.backgroundColor = [UIColor clearColor];
    _worstLabel.font = [UIFont systemFontOfSize:15.0f];
    [self.infoView addSubview:_worstLabel];
}

-(void)initTableView{
    self.tableView = [[SortingCustomTableView alloc] initWithfixedColumnWidth:73 mainColumnWidth:70 AndColumnHeight:44];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    _tableView.selectType = NO;
    _tableView.whiteLine = YES;
    [self.view addSubview:_tableView];
}

-(void)initVar{
    self.columnNames = [[NSMutableArray alloc]initWithObjects:
                        NSLocalizedStringFromTable(@"選股日股價", @"FigureSearch", nil),
                        NSLocalizedStringFromTable(@"今日股價", @"FigureSearch", nil),
                        NSLocalizedStringFromTable(@"報酬率", @"FigureSearch", nil),
                        NSLocalizedStringFromTable(@"期間最高價", @"FigureSearch", nil),
                        NSLocalizedStringFromTable(@"期間最低價", @"FigureSearch", nil),
                        NSLocalizedStringFromTable(@"加入自選股", @"FigureSearch", nil),
                        NSLocalizedStringFromTable(@"", @"", nil),nil];
    
    self.searchKeyArray = [[NSMutableArray alloc] initWithObjects:
                           NSLocalizedStringFromTable(@"日線", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"週線", @"FigureSearch", nil),
                           NSLocalizedStringFromTable(@"月線", @"FigureSearch", nil),nil];
}

-(void)changeSearchGroup{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedStringFromTable(@"類型", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"日線", @"FigureSearch", nil),
                                  NSLocalizedStringFromTable(@"週線", @"FigureSearch", nil),
                                  NSLocalizedStringFromTable(@"月線", @"FigureSearch", nil),nil];
    [actionSheet showInView:self.view.window.rootViewController.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([actionSheet isEqual:_groupActionSheet]) {
        if (buttonIndex <[_categoryArray count]){
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",_trackDown->identCode,_trackDown->symbol]];
                [dataModal.portfolioData selectGroupID:(int)buttonIndex+1];
                [dataModal.portfolioData AddItem:secu];
                _addLabel.backgroundColor = [UIColor clearColor];
                [_addLabel removeGestureRecognizer:_tap];
                [dataModal.securitySearchModel setChooseTarget:self];
                [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:0] waitUntilDone:NO];
            NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
            [FSHUD showMsg:[NSString stringWithFormat:@"%@：%@", NSLocalizedStringFromTable(@"新增自選股", @"FigureSearch", nil), title]];
        }
    }else{
        if (buttonIndex<3) {
            NSString * title = [_searchKeyArray objectAtIndex:buttonIndex];
            _trackUpArray = [_customModel searchAllTrackWithFigureSearchId:_figureSearchId RangeType:title];
            _range = title;
            
            [self upTrack];
            
            
            [_searchGroupBtn setTitle:title forState:UIControlStateNormal];
        }
    }
    
    
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TrackDownFormat * trackDown = [_trackDataArray objectAtIndex:indexPath.row];
    if (columnIndex ==0) {
        label.text =[NSString stringWithFormat:@"%@\n%@",trackDown->date,trackDown->session];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textAlignment = NSTextAlignmentRight;
        label.numberOfLines = 2;
        
    }
    if (columnIndex ==1) {
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"]) {
            label.text = trackDown->symbol;
        }else{
            label.text = trackDown->fullName;
        }
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentRight;
    }

}



-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.textColor = [UIColor blueColor];
    label.adjustsFontSizeToFitWidth = YES;
    TrackDownFormat * trackDown = [_trackDataArray objectAtIndex:indexPath.row];

    if (columnIndex ==0) {
        label.text =[NSString stringWithFormat:@"%.2f",trackDown->trackPrice];
        label.textColor = [UIColor blackColor];
    }
    if (columnIndex ==1) {
        if (trackDown->todayPrice>trackDown->trackPrice) {
            label.textColor = [StockConstant PriceUpColor];
        }else if (trackDown->todayPrice<trackDown->trackPrice){
            label.textColor = [StockConstant PriceDownColor];
        }
        if(trackDown->todayPrice>0.0){
            label.text =[NSString stringWithFormat:@"%.2f",trackDown->todayPrice];
        }else{
            label.text =@"----";
            label.textColor = [UIColor blackColor];
        }
    }
    if (columnIndex ==2) {
        float range = 0.0;
        if(trackDown->todayPrice>0.0 && trackDown->trackPrice != 0){
            range =(trackDown->todayPrice-trackDown->trackPrice)/trackDown->trackPrice;
        }
//        if (indexPath.row==0) {
//            _bestProfit = range;
//            _worstProfit = range;
//        }else{
//            if (range>_bestProfit) {
//                _bestProfit = range;
//            }
//            if (range<_worstProfit) {
//                _worstProfit = range;
//            }
//        }
        trackDown->ROI = range;
        
        if (range>0) {
            label.text =[NSString stringWithFormat:@"+%.2f",range*100];
            label.textColor = [StockConstant PriceUpColor];
        }else if (range<0){
            label.text =[NSString stringWithFormat:@"%.2f",range*100];
            label.textColor = [StockConstant PriceDownColor];
        }else{
            label.text =@"0.00";
            label.textColor = [UIColor blueColor];
        }

        _bestLabel.text = [NSString stringWithFormat:@"%.2f%%",_bestProfit*100];
        
        _worstLabel.text = [NSString stringWithFormat:@"%.2f%%",_worstProfit*100];
        
        _wonTradesLabel.text = [NSString stringWithFormat:@"%d",_profitItem];
    }
    if (columnIndex ==3) {
        if (trackDown->high>0) {
            if (trackDown->high>trackDown->trackPrice) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (trackDown->high<trackDown->trackPrice){
                label.textColor = [StockConstant PriceDownColor];
                
            }
            label.text =[NSString stringWithFormat:@"%.2f",trackDown->high];
        }else{
            label.text =@"----";
            label.textColor = [UIColor blackColor];
        }
        
        
        
    }
    if (columnIndex ==4) {
        if (trackDown->low>0) {
            if (trackDown->low>trackDown->trackPrice) {
                label.textColor = [StockConstant PriceUpColor];
            }else if (trackDown->low<trackDown->trackPrice){
                label.textColor = [StockConstant PriceDownColor];
            }
            label.text =[NSString stringWithFormat:@"%.2f",trackDown->low];
        }else{
            label.text =@"----";
            label.textColor = [UIColor blackColor];
        }
        
    }
    if (columnIndex==5) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AddTap:)];
        label.tag = indexPath.row;
        label.userInteractionEnabled = YES;
//        NSLog(@"self label's height %.2f  %.2f",label.frame.size.height,label.frame.size.width);
        if (![self btnHide:trackDown->symbol]) {
            label.frame = CGRectMake(label.frame.origin.x+22, 6, 35, 35);
            [label addGestureRecognizer:tap];
            label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BluePlusButton"]];
        }else{
            label.frame = CGRectMake(label.frame.origin.x + 22, 6, 32, 32);
            UITapGestureRecognizer *tapNothing = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing)];
            [label addGestureRecognizer:tapNothing];
            label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"+灰色小球"]];
        }

    }
    
    if (columnIndex==6) {
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTap:)];
        label.tag = indexPath.row;
        [label addGestureRecognizer:tap];
        label.userInteractionEnabled = YES;
        label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"RedDeleteButton"]];
        label.frame = CGRectMake(label.frame.origin.x+20, 8, 33, 30);
    }
}

-(void)doNothing{
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TrackDownFormat * symbol = [_trackDataArray objectAtIndex:indexPath.row];
    
    FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSString * symbolStr =[NSString stringWithFormat:@"%@ %@",symbol->identCode,symbol->symbol];
    [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",symbol->identCode,symbol->symbol]];
    _watchedPortfolio.portfolioItem = portfolioItem;
    if (([_figureSearchId intValue]>=1 && [_figureSearchId intValue]<=12) || ([_figureSearchId intValue]>=25 &&[_figureSearchId intValue]<=36)) {
        mainViewController.arrowUpDownType = 1;
    }else{
        mainViewController.arrowUpDownType = 2;
    }

    mainViewController.firstLevelMenuOption =1;
    mainViewController.techOption = _analysisPeriod;
    mainViewController.arrowType =_analysisPeriod;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }else{
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }

    NSDate * date  = [dateFormatter dateFromString:symbol->date];
    mainViewController.arrowDate = [date uint16Value];
        [self.navigationController pushViewController:mainViewController animated:NO];

}

-(BOOL)btnHide:(NSString *)symbol{
    for (int i=0; i<[_dataIdArray count]; i++) {
        if ([[_dataIdArray objectAtIndex:i] isEqual:symbol]) {
            return YES;
        }
    }
    return NO;
}

-(void)deleteTap:(UITapGestureRecognizer *)sender{
    deleteAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"確定要刪除?", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
    [deleteAlert show];
    
    UILabel * label =(UILabel *)sender.view;
    _tap = sender;
    _addLabel = label;
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:deleteAlert]) {
        if (buttonIndex==1) {
            TrackDownFormat * trackDown = [_trackDataArray objectAtIndex:_addLabel.tag];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSString * appid = [FSFonestock sharedInstance].appId;
            NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
            if ([group isEqualToString:@"us"]) {
                [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            }else{
                [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            }

            NSDate * date  = [dateFormatter dateFromString:trackDown->date];
            [_customModel deleteTrackWithFigureSearchId:_figureSearchId RangeType:_range IdentCode:trackDown->identCode Symbol:trackDown->symbol TrackDate:date];
            [_trackDataArray removeObjectAtIndex:_addLabel.tag];
            [_tableView reloadDataNoOffset];

            _tradesLabel.text = [NSString stringWithFormat:@"%d",(int)[_trackDataArray count]];
            
            _totalProfit = 0;
            _bestProfit = -MAXFLOAT;
            _worstProfit = MAXFLOAT;
            for (int i=0; i<[_trackDataArray count]; i++) {
                TrackDownFormat * trackDown = [_trackDataArray objectAtIndex:i];
                if (trackDown->todayPrice!=0 && trackDown->trackPrice != 0) {
                    float range =(trackDown->todayPrice-trackDown->trackPrice)/trackDown->trackPrice;
                    _totalProfit +=range;
                    _bestProfit = MAX(range, _bestProfit);
                    _worstProfit = MIN(range, _worstProfit);
//                    if (range>_bestProfit) {
//                        _bestProfit = range;
//                    }
//                    if (range<_worstProfit) {
//                        _worstProfit = range;
//                    }
                }
            }
            if([_trackDataArray count] == 0){
                _avgLabel.text = @"0.00%";
                _worstLabel.text = @"0.00%";
                _bestLabel.text = @"0.00%";
                _wonTradesLabel.text = @"0";
            }else{
                _avgLabel.text = [NSString stringWithFormat:@"%.2f%%",(_totalProfit*100)/[_trackDataArray count]];
            }
            _totalLabel.text = [NSString stringWithFormat:@"%.2f%%",_totalProfit*100];

            float range =(trackDown->todayPrice-trackDown->trackPrice)/trackDown->trackPrice;
            if (range>0) {
                _profitItem --;
            }
            [_tableView reloadDataNoOffset];
        }
    }
}

-(void)AddTap:(UITapGestureRecognizer *)sender{
//    if (_userStockCount<20) {
    UILabel * label =(UILabel *)sender.view;
    _trackDown = [_trackDataArray objectAtIndex:label.tag];
    
    self.groupActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"加入自選", @"FigureSearch", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        int i;
        for (i = 0;i < [_categoryArray count]; i++) {
            NSString * title = [_categoryArray objectAtIndex:i];
            [self.groupActionSheet addButtonWithTitle:title];
        }
        [self.groupActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
        [self.groupActionSheet setCancelButtonIndex:i];
        [self showActionSheet:self.groupActionSheet];
//    }else{
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"警告", @"SecuritySearch", nil) message:NSLocalizedStringFromTable(@"自選股已達上限", @"SecuritySearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"SecuritySearch", nil) otherButtonTitles:nil];
//        [alert show];
//    }
    
}

- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"選股日期", @"FigureSearch", nil),NSLocalizedStringFromTable(@"股名", @"FigureSearch", nil)];
}

- (NSArray *)columnsInMainTableView {
    NSArray *retArray = nil;
    retArray = _columnNames;
    return retArray;
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_trackDataArray count];
    
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


-(void)trackCenterDidFinishWithData:(TrackCenter *)trackCenterData{
    [self.view hideHUD];
    _trackDataArray = trackCenterData.trackDownArray;
    _nowSortingType = YES;
    _nowSorting = 1;
    _tableView.focuseLabel = 99;
    _totalProfit = 0.0f;
    _worstProfit = 0.0f;
    _bestProfit = -MAXFLOAT;
    _worstProfit = MAXFLOAT;
    _profitItem = 0;
    _tradesLabel.text = [NSString stringWithFormat:@"%d",(int)[_trackDataArray count]];
    
    [_searchGroupBtn setTitle:NSLocalizedStringFromTable(_range, @"FigureSearch", nil) forState:UIControlStateNormal];
    [_tableView reloadDataNoOffset];
    
    for (int i=0; i<[_trackDataArray count]; i++) {
        TrackDownFormat * trackDown = [_trackDataArray objectAtIndex:i];
        if (trackDown->todayPrice!=0 && trackDown->trackPrice != 0) {
            float range =(trackDown->todayPrice-trackDown->trackPrice)/trackDown->trackPrice;
            _totalProfit +=range;
            
            _bestProfit = MAX(range, _bestProfit);
            _worstProfit = MIN(range, _worstProfit);
            
//            if (range > _bestProfit) {
//                _bestProfit = range;
//            }
//            if (range < _worstProfit) {
//                _worstProfit = range;
//            }
        }
    }
    
    float range = 0.0;
    
    for(int i = 0; i <[_trackDataArray count]; i++){
        TrackDownFormat * trackDown = [_trackDataArray objectAtIndex:i];
        
        if(trackDown->todayPrice>0.0 && trackDown->trackPrice != 0){
            range =(trackDown->todayPrice-trackDown->trackPrice)/trackDown->trackPrice;
        }
        if (range>0) {
            _profitItem +=1;
        }
    }
    
    
    
    
    _avgLabel.text = [NSString stringWithFormat:@"%.2f%%",(_totalProfit*100)/[_trackDataArray count]];
    _totalLabel.text = [NSString stringWithFormat:@"%.2f%%",_totalProfit*100];
    
    if ([_trackDataArray count]==0) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedStringFromTable(@"無追蹤股票", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil)  otherButtonTitles:nil, nil];
        [alert show];
        _avgLabel.text = @"0.00%";
        _totalLabel.text = @"0.00%";
        _bestLabel.text = @"0.00%";
        _worstLabel.text = @"0.00%";
        _wonTradesLabel.text = @"0";
    }

}

-(void)trackCenterDidFailWithError:(NSError *)error{
    [self.view hideHUD];
    NSLog(@"Server Error");
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"Server error, please try again.",@"Launcher",nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消",@"Launcher",nil) otherButtonTitles:nil];
    [alert show];
}

-(void)trackCenterDidFailWithData:(TrackCenter *)trackCenterData{
    [self.view hideHUD];
    NSLog(@"Server Fail");
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"Server error, please try again.",@"Launcher",nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消",@"Launcher",nil) otherButtonTitles:nil];
    [alert show];
    
}


-(void)labelTap:(UILabel *)label{
    if (label.tag == 0 || label.tag == 1) {
        return;
    }
//    NSLog(@"sorting %d",(int)label.tag);
    NSString * sortingKey = @"";
    if (label.tag ==0) {
        sortingKey = @"date";
    }else if (label.tag == 1){
        sortingKey = @"symbol";
    }else if (label.tag ==2) {
        sortingKey = @"trackPrice";
    }else if (label.tag == 3){
        sortingKey = @"todayPrice";
    }else if (label.tag == 4){
        sortingKey = @"ROI";
    }else if (label.tag == 5){
        sortingKey = @"high";
    }else if (label.tag == 6){
        sortingKey = @"low";
    }
    if (label.tag<7) {
        if (_nowSorting != label.tag) {
            _nowSorting = (int)label.tag;
            _tableView.focuseLabel = (int)label.tag;
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:YES];
            _nowSortingType = YES;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[_trackDataArray sortedArrayUsingDescriptors:sortDescriptors]];
            
            _trackDataArray = sortedArray;
        }else{
            if (_nowSortingType) {
                _nowSortingType = NO;
            }else{
                _nowSortingType = YES;
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:_nowSortingType];
            
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[_trackDataArray sortedArrayUsingDescriptors:sortDescriptors]];
            
            _trackDataArray = sortedArray;
        }
        
        _totalProfit = 0.0f;
        _profitItem = 0;
        [_tableView reloadDataNoOffset];
    }
}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];

    [_explainView showMenuWithRect:CGRectMake(260, 90, 0, 0) String:NSLocalizedStringFromTable(@"選擇追蹤時間", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(260, 55, 30, 56)];
    [_explainView showMenuWithRect:CGRectMake(260, 220, 0, 0) String:NSLocalizedStringFromTable(@"滑動看更多", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handMoveRight"Rect:CGRectMake(260, 170, 30, 56)];
    [_explainView showMenuWithRect:CGRectMake(70, 220, 0, 0) String:NSLocalizedStringFromTable(@"排序", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(70, 170, 30, 56)];
    
    [_explainView showMenuWithRect:CGRectMake(120, 330, 0, 0) String:NSLocalizedStringFromTable(@"點擊至技術線圖", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(120, 290, 30, 56)];
}

-(void)closeTeachPop:(UIView *)view{
    //存資料庫
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    [view removeFromSuperview];
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
