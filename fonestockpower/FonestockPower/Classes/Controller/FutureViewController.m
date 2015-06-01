//
//  FutureViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/9/27.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FutureViewController.h"
#import "FutureModel.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "UIViewController+CustomNavigationBar.h"

@interface FutureViewController (){
    UIActionSheet *groupActionSheet;
}

@end

@implementation FutureViewController

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
    self.navigationItem.title =NSLocalizedStringFromTable(@"期貨商品", @"Future", nil);

    [self initView];
    [self varInit];
    
}
-(void)initView{
    [self setUpImageBackButton];
    self.categoryArray =[[NSMutableArray alloc]init];
    self.categoryIdArray =[[NSMutableArray alloc]init];
    self.stockNameArray =[[NSMutableArray alloc]init];
    self.stockIdArray =[[NSMutableArray alloc]init];
    self.allDataArray = [[NSMutableArray alloc] init];
    self.stockIdentCodeArray = [[NSMutableArray alloc] init];
    _searchNum = 0;
    _typeNum = 0;
    _searchTimes =0;
    
    self.stateLabel = [[UILabel alloc]init];
    _stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _stateLabel.text = NSLocalizedStringFromTable(@"類別", @"Future", nil);
    _stateLabel.font = [UIFont systemFontOfSize:24.0f];
    [self.view addSubview:_stateLabel];
    
    self.stateBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _stateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_stateBtn addTarget:self action:@selector(actionInit) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_stateBtn];
    
    self.mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    
    [self.view addSubview:_mainTableView];
    
    [self.view setNeedsUpdateConstraints];

}


- (void)startWatch{ //獲取螢幕畫面所顯示表格
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	scrollFlag = NO;
    NSMutableArray *idArray = [[NSMutableArray alloc] init];
    NSMutableArray *rowArray = [[NSMutableArray alloc] init];
    [_allDataArray removeAllObjects];
	NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[_mainTableView indexPathsForVisibleRows]];
	int count = (int)[_stockNameArray count];
	if([pathArray count] <= 0 && count > 0)		//table 還沒reload 可是有東西了
	{
		int max = count > 10 ? 10 : count;
		for(int i=0 ; i<max ; i++)
		{
			[pathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
	}
    if (count > 0 && count>=[pathArray count])
	{
        for(NSIndexPath *indexPath in pathArray)
        {
            
            NSString * secuName = [_stockIdArray objectAtIndex:indexPath.row];
            if(![secuName isEqual:@""])
            {
                NSString *icSymbol = [NSString stringWithFormat:@"%@ %@",[_stockIdentCodeArray objectAtIndex:indexPath.row],[_stockIdArray objectAtIndex:indexPath.row]];
                [idArray addObject:icSymbol];
                [rowArray addObject:[NSNumber numberWithInteger:indexPath.row]];
            }
        }
        [_allDataArray addObject:rowArray];
        [_allDataArray addObject:idArray];
        
        [dataModal.futureModel setTarget:self];
        [dataModal.futureModel performSelector:@selector(updateSnapshotWithArray:) onThread:dataModal.thread withObject:idArray waitUntilDone:NO];
	}
    [_mainTableView reloadDataNoOffset];
	
}



-(void)groupNotifyDataArrive:(NSMutableArray *)array{
    //接收回傳之期貨下子標題
    _categoryArray = [array objectAtIndex:0];
    _categoryIdArray = [array objectAtIndex:1];
    [_stateBtn setTitle:[NSString stringWithFormat:@"%@ - %@",NSLocalizedStringFromTable(@"期貨", @"Future", nil),[_categoryArray objectAtIndex:_typeNum]] forState:UIControlStateNormal];
    //傳送電文確認子類別下的項目 SecurityNameData 104
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    if (_searchNum == 0) {
        if ([_categoryIdArray count] !=0) {
            [dataModal.securityName setTarget:self];
            [dataModal.securityName selectCatID:[(NSNumber *)[_categoryIdArray objectAtIndex:0]intValue]];
            _searchNum = [(NSNumber *)[_categoryIdArray objectAtIndex:0]intValue];
        }
        
    }else{
        [dataModal.securityName setTarget:self];
        [dataModal.securityName selectCatID:_searchNum];
    }
    [_mainTableView reloadAllData];
    [self startWatch];
}

-(void)notifySqlDataArrive:(NSMutableArray *)array{
    //接收所選標題之所有 期貨項目
    _stockNameArray = [array objectAtIndex:0];
    _stockIdArray = [array objectAtIndex:1];
    _stockIdentCodeArray = [array objectAtIndex:2];
    [_mainTableView reloadDataNoOffset];
    [self startWatch];
    
}

-(void)notifyDataArrive{
    //搜尋現在畫面之表格Snapshot
    if ([_allDataArray count]>0) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.futureModel setTarget:self];
        [dataModal.futureModel performSelector:@selector(searchSnapshotWithArray:) onThread:dataModal.thread withObject:_allDataArray waitUntilDone:NO];
    }else{
        [self startWatch];
    }
}


-(void)SnapshotNnotifyDataArrive:(NSMutableArray *)array{
    //接收從snapshot回來之資料
    _bidPriceDictionary = [array objectAtIndex:0];
    if ([_bidPriceDictionary count] != [[_allDataArray objectAtIndex:0]count]) {
        if (_searchTimes <150) {
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            [dataModal.futureModel setTarget:self];
            [dataModal.futureModel performSelector:@selector(searchSnapshotWithArray:) onThread:dataModal.thread withObject:_allDataArray waitUntilDone:NO];
            _searchTimes +=1;
        }else{
            _searchTimes =0;
        }
    }else{
        _searchTimes =0;
    }
    _askPriceDictionary = [array objectAtIndex:1];
    _currentPriceDictionary = [array objectAtIndex:2];
    _highestPriceDictionary = [array objectAtIndex:3];
    _lowestPriceDictionary = [array objectAtIndex:4];
    _chgDictionary = [array objectAtIndex:5];
    _p_chgDictionary = [array objectAtIndex:6];
    _VolumeDictionary = [array objectAtIndex:7];
    _accumulatedVolumeDictionary = [array objectAtIndex:8];
    _referencePriceDictionary = [array objectAtIndex:9];
    _statusDictionary = [array objectAtIndex:10];
    _topPriceDictionary = [array objectAtIndex:11];
    _bottomPriceDictionary = [array objectAtIndex:12];
    [self.view hideHUD];
    [_mainTableView reloadDataNoOffset];
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
	scrollFlag = YES;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isKindOfClass:[UITableView class]]) {
        if (!decelerate) {
            [self startWatch];
        }
    }
		
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
		//table scroll view
    if ([scrollView isKindOfClass:[UITableView class]]) {
        [self startWatch];
    }
	
}


- (void)viewWillDisappear:(BOOL)animated {
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setGroupTarget:nil];
    [dataModal.securitySearchModel setTarget:nil];
    [dataModal.futureModel setTarget:nil];
    
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    //SQL-期貨子標題
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.futureModel setGroupTarget:self];
    [dataModal.futureModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:3] waitUntilDone:NO];
    
}

- (void)varInit {
    
    self.columnNames = [[NSMutableArray alloc] initWithObjects:
                    NSLocalizedStringFromTable(@"買進", @"Future", nil),
                    NSLocalizedStringFromTable(@"賣出", @"Future", nil),
                    NSLocalizedStringFromTable(@"成交", @"Future", nil),
                    NSLocalizedStringFromTable(@"最高", @"Future", nil),
                    NSLocalizedStringFromTable(@"最低", @"Future", nil),
                    NSLocalizedStringFromTable(@"漲跌", @"Future", nil),
                    NSLocalizedStringFromTable(@"漲幅", @"Future", nil),
                    NSLocalizedStringFromTable(@"單量", @"Future", nil),
                    NSLocalizedStringFromTable(@"總量", @"Future", nil),
                    nil];
    
}

- (void)actionInit {
    
    groupActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"期貨商品", @"Future", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i;
    for (i=0;i<[_categoryArray count];i++) {
        NSString * title = [_categoryArray objectAtIndex:i];
        [groupActionSheet addButtonWithTitle:title];
    }
    [groupActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [groupActionSheet setCancelButtonIndex:i];
    [self showActionSheet:groupActionSheet];
    

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"Future", nil)];
    
    if (buttonIndex <[_categoryArray count]){
        //傳送電文確認子類別下的項目 SecurityNameData 104
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securityName setTarget:self];
        [dataModal.securityName selectCatID:[(NSNumber *)[_categoryIdArray objectAtIndex:buttonIndex]intValue]];
        
        self.typeNum = (int)buttonIndex;
        self.searchNum = [(NSNumber *)[_categoryIdArray objectAtIndex:buttonIndex]intValue];
        
        [_stateBtn setTitle:[NSString stringWithFormat:@"%@ - %@",NSLocalizedStringFromTable(@"期貨", @"Future", nil),[_categoryArray objectAtIndex:buttonIndex]] forState:UIControlStateNormal];
    }
    
}

-(void)notify{ //SQL-搜尋該子類別下所有項目
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchStock:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchNum] waitUntilDone:NO];
}

- (void)updateViewConstraints {
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_stateBtn, _stateLabel, _mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stateLabel(50)]-5-[_stateBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_stateBtn(44)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_stateLabel(40)]-5-[_mainTableView]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [super updateViewConstraints];

}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    label.textAlignment = NSTextAlignmentCenter;
    label.text  = [_stockNameArray objectAtIndex:indexPath.row];
    label.textColor = [UIColor blueColor];
    
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    label.text = @"----";
    label.backgroundColor = [UIColor clearColor];
    if (columnIndex == 0) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_bidPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];

        if ([[_bidPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]>[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]) {
            label.textColor = [UIColor redColor];
            
        }else if ([[_bidPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]<[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]){
            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }
        if ([[_bidPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual:[_topPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]) {
            label.backgroundColor = [UIColor redColor];
            label.textColor = [UIColor whiteColor];
        }else if ([[_bidPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual: [_bottomPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]){
            label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor whiteColor];
        }
        
    }
    if (columnIndex == 1) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_askPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];
        if ([[_askPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]>[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]) {
            label.textColor = [UIColor redColor];
            
        }else if ([[_askPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]<[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]){

            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }
        if ([[_askPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual:[_topPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]) {
            label.backgroundColor = [UIColor redColor];
            label.textColor = [UIColor whiteColor];
        }else if ([[_askPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual: [_bottomPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]){
            label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor whiteColor];
        }

    }
    if (columnIndex == 2) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_currentPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];
        if ([[_currentPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]>[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]) {
            label.textColor = [UIColor redColor];
            
        }else if ([[_currentPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]<[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]){
            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }
        if ([[_currentPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual:[_topPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]) {
            label.backgroundColor = [UIColor redColor];
            label.textColor = [UIColor whiteColor];
        }else if ([[_currentPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual: [_bottomPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]){
            label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor whiteColor];
        }
    }
    if (columnIndex == 3) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_highestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];
        if ([[_highestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]>[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]) {
            label.textColor = [UIColor redColor];
            
        }else if ([[_highestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]<[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]){
            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }
        if ([[_highestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual:[_topPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]) {
            label.backgroundColor = [UIColor redColor];
            label.textColor = [UIColor whiteColor];
        }else if ([[_highestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual: [_bottomPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]){
            label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor whiteColor];
        }
    }
    if (columnIndex == 4) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_lowestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];

        if ([[_lowestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]>[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]) {
            label.textColor = [UIColor redColor];
            
        }else if ([[_lowestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]<[[_referencePriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]floatValue]){
            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }
        if ([[_lowestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]] isEqual:[_topPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]) {
            label.backgroundColor = [UIColor redColor];
            label.textColor = [UIColor whiteColor];
        }else if ([[_lowestPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]isEqual:[_bottomPriceDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]]){
            label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor whiteColor];
        }
    }
    if (columnIndex == 5) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];
        if ([(NSNumber *)[_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]doubleValue]>0) {
            label.textColor = [UIColor redColor];
            label.text =[NSString stringWithFormat:@"+%@",[_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]];
        }else if ([(NSNumber *)[_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]doubleValue]<0){
            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }
    }
    if (columnIndex == 6) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_p_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];
        if ([(NSNumber *)[_p_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]doubleValue]>0) {
            label.textColor = [UIColor redColor];
            label.text =[NSString stringWithFormat:@"+%@",[_p_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]];
        }else if ([(NSNumber *)[_p_chgDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]]doubleValue]<0){
            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }

    }
    if (columnIndex == 7) {
        label.backgroundColor = [UIColor clearColor];
        label.text =[_VolumeDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }else{
            label.textColor = [UIColor purpleColor];
        }
    }
    if (columnIndex == 8) {
        label.backgroundColor = [UIColor clearColor];
        label.text = [_accumulatedVolumeDictionary objectForKey:[NSNumber numberWithInteger: indexPath.row]];
        if ([label.text isEqual:@"----"]) {
            label.textColor = [UIColor blackColor];
        }else{
            label.textColor = [UIColor purpleColor];
        }
    }
    
}

- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"名稱", @"Future", nil)];
}

- (NSArray *)columnsInMainTableView {
    NSArray *retArray = nil;
    retArray = _columnNames;
    return retArray;
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_stockNameArray count];
    
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //轉換畫面至線圖
    FSMainViewController *mainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSString * symbolStr =[NSString stringWithFormat:@"%@ %@",[_stockIdentCodeArray objectAtIndex:indexPath.row],[_stockIdArray objectAtIndex:indexPath.row]];
    [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_stockIdentCodeArray objectAtIndex:indexPath.row],[_stockIdArray objectAtIndex:indexPath.row]]];
    if (portfolioItem != nil) {
        FSInstantInfoWatchedPortfolio * watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        [self.navigationController pushViewController:mainViewController animated:NO];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
