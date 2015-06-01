//
//  TaiwanStockListViewController.m
//  Bullseye
//
//  Created by Neil on 13/9/17.
//
//

#import "TaiwanStockListViewController.h"
#import "CustomBtnInScrollView.h"
#import "SecuritySearchModel.h"
#import "BtnCollectionView.h"
#import "FSActionPlanDatabase.h"


#define SECTOR_SHANG_JIAO   101    //上交所
#define SECTOR_SHEN_JIAO    121    //深交所
#define IS_IOS8 [[UIDevice currentDevice] systemVersion].floatValue >= 8.0

@interface TaiwanStockListViewController ()<UIActionSheetDelegate>{
//更新_group2CollectionView 時並不是依照：按下板塊→搜尋upperBtn 內容→搜尋bottomBtn 內容→最後才搜尋_group2CollectionView 所需的資料，並更新
    int count;
    int totalCount;
    int rootIndex;
    BOOL secFlag;
    //底下兩個是用來分辦目前_storeUpperDataAry 及_storeBottomDataAry 各是要取第幾筆資料出來使用
    NSInteger upperBtnData;
    NSInteger bottomBtnData;
    //因為在actionSheetDelegate method 需要知道是哪個按鈕被按下，於是用該布林值來儲存是哪個按鈕被按下
    BOOL ubFlag;
    //因不知名的原因viewWillAppear 會跑兩次，所以才加此method 將其擋起來
    BOOL runOnlyOnce;
    BOOL isShowPlate;
}
//在plateNotifyDataArrive 裡進行陣列的更新時，因為每次的動作只會有一個陣列的內容，所以必須將動作分兩次，才以此property 做分別
@property (nonatomic) BOOL upperBottomFlag;
//儲存板塊底下兩個按鈕內容的兩個陣列
@property (nonatomic, strong) NSMutableArray *storeUpperDataAry;
@property (nonatomic, strong) NSMutableArray *storeBottomDataAry;
@property (nonatomic, strong) FSUIButton *plateUpperBtn;
@property (nonatomic, strong) FSUIButton *plateBottomBtn;
@property (nonatomic, strong) UIActionSheet *showPlateAS;
@property (nonatomic, strong) UIAlertController *showPlateAC;
@end

@implementation TaiwanStockListViewController
@synthesize storeArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.objDictionary = [[NSMutableDictionary alloc]init];
    self.titleData1 = [[NSMutableArray alloc]init];
    self.id1Array = [[NSMutableArray alloc]init];
    self.id2Array = [[NSMutableArray alloc]init];
    self.id2IdentCodeArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    self.dataICArray = [[NSMutableArray alloc] init];
    self.id3Array = [[NSMutableArray alloc]init];
    self.data3Array = [[NSMutableArray alloc]init];
    [self initView];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        [self initPlateArray];
    }
	// Do any additional setup after loading the view.
}

-(void) initPlateArray
{
    upperBtnData = 0;
    bottomBtnData = 0;
    _storeUpperDataAry = [[NSMutableArray alloc] init];
    _storeBottomDataAry = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchPlateData:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:113] waitUntilDone:YES];
}

-(void)initView{

    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        self.titleData1 = [[NSMutableArray alloc]initWithObjects:@"集中",@"店頭",@"概念",@"集團",@"成份",@"產業", nil];
        self.titleId1 = [[NSMutableArray alloc]initWithObjects:@"21",@"2",@"500",@"400",@"450", @"2000", nil];
    
        self.titleData2 = [[NSMutableArray alloc]initWithObjects:@"ETF",@"TDR",@"REIT",@"F股", nil];
        self.titleId2 = [[NSMutableArray alloc]initWithObjects:@"2600",@"2601",@"2602",@"2603",@"2604", nil];
    }
    else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        self.titleData1 = [[NSMutableArray alloc]initWithObjects:@"上交",@"深交", nil];
        self.titleId1 = [[NSMutableArray alloc]initWithObjects:@SECTOR_SHANG_JIAO, @SECTOR_SHEN_JIAO, nil];
    }

    self.titleScrollView1 = [[CustomBtnInScrollView alloc]initWithDataArray:_titleData1 Row:1 Column:0 ButtonType:FSUIButtonTypeNormalBlue];
    _titleScrollView1.translatesAutoresizingMaskIntoConstraints = NO;
    _titleScrollView1.delegate = self;
    [self.view addSubview:_titleScrollView1];
    [_objDictionary setObject:_titleScrollView1 forKey:@"_titleScrollView1"];
    
    self.titleScrollView2 = [[CustomBtnInScrollView alloc]initWithDataArray:_titleData2 Row:1 Column:0 ButtonType:FSUIButtonTypeNormalBlue];
    _titleScrollView2.translatesAutoresizingMaskIntoConstraints = NO;
    _titleScrollView2.delegate = self;
    [self.view addSubview:_titleScrollView2];
    [_objDictionary setObject:_titleScrollView2 forKey:@"_titleScrollView2"];

    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    aFlowLayout.itemSize = CGSizeMake(102, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    self.group1CollectionView= [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:aFlowLayout];
    _group1CollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_group1CollectionView setCollectionViewLayout:aFlowLayout animated:YES];
    _group1CollectionView.myDelegate = self;
    _group1CollectionView.btnSelectOnlyOne = YES;
    _group1CollectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _group1CollectionView.layer.borderWidth = 1.0f;
    _group1CollectionView.btnArray = _data1Array;
    [_objDictionary setObject:_group1CollectionView forKey:@"_group1CollectionView"];
    [self.view addSubview:_group1CollectionView];
    
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = NSLocalizedStringFromTable(@"由下列標的物選取股票", @"SecuritySearch", nil);
    _titleLabel.textColor = [UIColor blueColor];
    _titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [_objDictionary setObject:_titleLabel forKey:@"_titleLabel"];
    [self.view addSubview:_titleLabel];
    
    self.promptLabel = [[UILabel alloc]init];
    _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _promptLabel.text = NSLocalizedStringFromTable(@"橘色為已加入自選股", @"SecuritySearch", nil);
    _promptLabel.textColor = [UIColor blueColor];
    _promptLabel.font = [UIFont systemFontOfSize:18.0f];
    [_objDictionary setObject:_promptLabel forKey:@"_promptLabel"];
    [self.view addSubview:_promptLabel];
    
    UICollectionViewFlowLayout *bFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    bFlowLayout.itemSize = CGSizeMake(102, 40);
    bFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    bFlowLayout.minimumInteritemSpacing = 1.0f;
    bFlowLayout.minimumLineSpacing = 1.0f;
    
    self.group2CollectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:bFlowLayout];
    _group2CollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_group2CollectionView setCollectionViewLayout:bFlowLayout animated:YES];
    _group2CollectionView.myDelegate = self;
    _group2CollectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _group2CollectionView.layer.borderWidth = 1.0f;
    _group2CollectionView.btnArray = _data2Array;
    [_objDictionary setObject:_group2CollectionView forKey:@"_group2CollectionView"];
    [self.view addSubview:_group2CollectionView];
    
    UICollectionViewFlowLayout *cFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    cFlowLayout.itemSize = CGSizeMake(102, 40);
    cFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    cFlowLayout.minimumInteritemSpacing = 1.0f;
    cFlowLayout.minimumLineSpacing = 1.0f;
    
    self.group3CollectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:cFlowLayout];
    _group3CollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_group3CollectionView setCollectionViewLayout:cFlowLayout animated:YES];
    _group3CollectionView.myDelegate = self;
    _group3CollectionView.btnSelectOnlyOne = YES;
    _group3CollectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _group3CollectionView.layer.borderWidth = 1.0f;
    _group3CollectionView.btnArray = _data3Array;
    [_objDictionary setObject:_group3CollectionView forKey:@"_group3CollectionView"];
    [self.view addSubview:_group3CollectionView];
    
    _plateUpperBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [_plateUpperBtn addTarget:self action:@selector(plateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _plateUpperBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _plateUpperBtn.hidden = YES;
    [_objDictionary setObject:_plateUpperBtn forKey:@"_plateUpperBtn"];
    upperBtnData = 113;
    [self.view addSubview:_plateUpperBtn];
    
    _plateBottomBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [_plateBottomBtn addTarget:self action:@selector(plateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _plateBottomBtn.translatesAutoresizingMaskIntoConstraints = NO;
    _plateBottomBtn.hidden = YES;
    [_objDictionary setObject:_plateBottomBtn forKey:@"_plateBottomBtn"];
    bottomBtnData = 115;
    [self.view addSubview:_plateBottomBtn];
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        _stringV = @"V:|-2-[_titleScrollView1(44)][_titleScrollView2(44)]-3-[_group1CollectionView]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-|";
    }
    else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        _stringV = @"V:|-2-[_titleScrollView1(44)]-3-[_group1CollectionView]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-|";
    }
    
    [self.view setNeedsUpdateConstraints];
}


-(void)groupNotifyDataArrive:(NSMutableArray *)array{
    //選title
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    if (rootIndex==5) {
        if(secFlag){
            secFlag = NO;
            _id3Array = [array objectAtIndex:1];
            _data3Array = [array objectAtIndex:0];
            _group3CollectionView.btnArray = _data3Array;
            [_group3CollectionView reloadData];
            _group3CollectionView.holdBtn = 0;
            
            [dataModal.securitySearchModel setTarget:self];
            if([_id3Array count]>0){
                [dataModal.securitySearchModel performSelector:@selector(searchStock:) onThread:dataModal.thread withObject:[_id3Array objectAtIndex:0] waitUntilDone:NO];
                _groupIndex =[_id3Array objectAtIndex:0];
            }
           
            [dataModal.securityName setTarget:self];
            [dataModal.securityName selectCatID:[_groupIndex intValue]];
        }else{
            _id1Array = [array objectAtIndex:1];
            _data1Array = [array objectAtIndex:0];
            _group1CollectionView.btnArray =[array objectAtIndex:0];
            [_group1CollectionView reloadData];
            _group1CollectionView.holdBtn = 0;
            _groupIndex =[_id1Array objectAtIndex:0];
            secFlag = YES;
            [dataModal.securitySearchModel setTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:_groupIndex waitUntilDone:NO];
        }
        
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
            if([_id3Array count]>0){
                _stringV = @"V:|-2-[_titleScrollView1(44)][_titleScrollView2(44)]-3-[_group1CollectionView][_group3CollectionView(==_group1CollectionView)]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-[_promptLabel(20)]-2-|";
                
            }else{
                _stringV = @"V:|-2-[_titleScrollView1(44)][_titleScrollView2(44)]-3-[_group1CollectionView]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-[_promptLabel(20)]-2-|";
                
            }
        }
        else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
            if([_id3Array count]>0){
                _stringV = @"V:|-2-[_titleScrollView1(44)]-3-[_group1CollectionView][_group3CollectionView(==_group1CollectionView)]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-|";
                
            }else{
                _stringV = @"V:|-2-[_titleScrollView1(44)]-3-[_group1CollectionView]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-|";
            }
        }
        
    }
    else{
        _id1Array = [array objectAtIndex:1];
        _data1Array = [array objectAtIndex:0];
        if ([_id1Array count]!=0) {
            _group1CollectionView.btnArray =[array objectAtIndex:0];
            [_group1CollectionView reloadData];
            [_group1CollectionView setContentOffset:CGPointMake(0, 0)];
            _group1CollectionView.holdBtn = 0;
            
            [dataModal.securitySearchModel setTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(searchStock:) onThread:dataModal.thread withObject:[_id1Array objectAtIndex:0] waitUntilDone:NO];
            
            _groupIndex =[_id1Array objectAtIndex:0];
            
            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
                _stringV = @"V:|-2-[_titleScrollView1(44)][_titleScrollView2(44)]-3-[_group1CollectionView]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-[_promptLabel(20)]-2-|";
            }
            else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
                _stringV = @"V:|-2-[_titleScrollView1(44)]-3-[_group1CollectionView(110)]-3-[_titleLabel(20)]-3-[_group2CollectionView]-2-[_promptLabel(20)]-2-|";
            }
            //        SKCustomButton * newDataBtn =  [_group1CollectionView.btnDictionary objectForKey:@"btn0"];
            //        newDataBtn.selected = YES;
            //        [newDataBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
        }else{

            if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
                _stringV = @"V:|-2-[_titleScrollView1(44)][_titleScrollView2(44)]-3-[_titleLabel(20)]-3-[_group2CollectionView][_group1CollectionView(1)]-2-[_promptLabel(20)]-2-|";
            }
            else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
                _stringV = @"V:|-2-[_titleScrollView1(44)]-3-[_titleLabel(20)]-3-[_group2CollectionView][_group1CollectionView(1)]-2-[_promptLabel(20)]-2-|";
            }
            
//            _stringV = @"V:|-2-[_titleScrollView1(44)][_titleScrollView2(44)]-3-[_titleLabel(20)]-3-[_group2CollectionView]-2-|";
        }
        [dataModal.securityName setTarget:self];
        [dataModal.securityName selectCatID:[_groupIndex intValue]];
    }
    [self.view setNeedsUpdateConstraints];
}

-(void)plateNotifyDataArrive:(NSMutableArray *)array
{
    if(!_upperBottomFlag){
        _upperBottomFlag = !_upperBottomFlag;
        _storeUpperDataAry = [[NSMutableArray alloc] init];
        NSMutableArray *forIdArray = [array objectAtIndex:1];
        NSMutableArray *forData1Array = [array objectAtIndex:0];
        for(int i = 0; i < forIdArray.count; i++){
            ForPlateOnly *fpOnly = [[ForPlateOnly alloc] init];
            fpOnly.stringData = forData1Array[i];
            fpOnly.catIDData = forIdArray[i];
            [_storeUpperDataAry addObject:fpOnly];
        }
        [_plateUpperBtn setTitle:((ForPlateOnly *)_storeUpperDataAry[upperBtnData]).stringData forState:UIControlStateNormal];
        //更新完upperBtn 後再送一次查詢DB 的動作以更新bottomBtn
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchPlateData:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:[((ForPlateOnly *)_storeUpperDataAry[0]).catIDData intValue]] waitUntilDone:NO];
    }else {
        _upperBottomFlag = !_upperBottomFlag;
        _storeBottomDataAry = [[NSMutableArray alloc] init];
        NSMutableArray *forIdArray = [array objectAtIndex:1];
        NSMutableArray *forData1Array = [array objectAtIndex:0];
        for(int i = 0; i < forIdArray.count; i++){
            ForPlateOnly *fpOnly = [[ForPlateOnly alloc] init];
            fpOnly.stringData = forData1Array[i];
            fpOnly.catIDData = forIdArray[i];
            [_storeBottomDataAry addObject:fpOnly];
        }
        [_plateBottomBtn setTitle:((ForPlateOnly *)_storeBottomDataAry[0]).stringData forState:UIControlStateNormal];
        if(isShowPlate)[self startSearchStuffFromSQLite:0];
    }
}

-(void)notifySqlDataArrive:(NSMutableArray *)array{
    //選group1
    _id2Array = [array objectAtIndex:1];
    _data2Array = [array objectAtIndex:0];
    _id2IdentCodeArray = [array objectAtIndex:2];
    _group2CollectionView.btnArray = _data2Array;
    
    if(_changeStock){
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取股票", @"SecuritySearch", nil)];
        _group2CollectionView.chooseArray = [[NSMutableArray alloc]init];
    }else{
        
        _group2CollectionView.chooseArray = [self changeBtnColor];
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
    }
//    [self groupReset:_group2CollectionView];
    [_group2CollectionView reloadData];
    _group2CollectionView.holdBtn = 99999;
}


-(void)viewWillAppear:(BOOL)animated{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    
    [dataModal.securitySearchModel setTarget:self];
    
    if(runOnlyOnce)return;
    NSNumber *firstSector = [_titleId1 firstObject];
    if (firstSector ) {
        [dataModal.securitySearchModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:firstSector waitUntilDone:NO];
    }
    else {
        [dataModal.securitySearchModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:21] waitUntilDone:NO];
    }
    runOnlyOnce = YES;
    
    
    totalCount = [dataModal.securitySearchModel countUserStockNum];
    
//    [self changeGroup];
    
    [self titleReset:_titleScrollView1];
    FSUIButton * newBtn =  [_titleScrollView1.btnDictionary objectForKey:@"btn0"];
    newBtn.selected = YES;
    
    [self titleReset:_titleScrollView2];
    
    [self groupReset:_group1CollectionView];
    FSUIButton * newDataBtn =  [_group1CollectionView.btnDictionary objectForKey:@"btn0"];
    newDataBtn.selected = YES;
    [newDataBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self groupReset:_group2CollectionView];
    
    _stringV = @"V:|-2-[_titleScrollView1(44)][_titleScrollView2(44)]-3-[_group1CollectionView]-3-[_titleLabel(20)]-3-[_group2CollectionView(==_group1CollectionView)]-2-|";
    
}

-(void)changeGroup{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchGroup] waitUntilDone:NO];
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    _dataIdArray = [array objectAtIndex:1];
    _dataICArray = [array objectAtIndex:2];

    if(_changeStock){
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取股票", @"SecuritySearch", nil)];
        _group2CollectionView.chooseArray = [[NSMutableArray alloc]init];
    }else{
        
        _group2CollectionView.chooseArray = [self changeBtnColor];
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
    }
    _group2CollectionView.holdBtn = 99999;
    [_group2CollectionView reloadData];
    
}

-(NSMutableArray *)changeBtnColor{
    count = 0;
    NSMutableArray * array = [[NSMutableArray alloc]init];
    for (int i=0; i<[_dataIdArray count]; i++) {
        for (int j=0; j<[_id2Array count]; j++) {
            if ([[_dataIdArray objectAtIndex:i] isEqual:[_id2Array objectAtIndex:j]]&&
                [[_dataICArray objectAtIndex:i] isEqual:[_id2IdentCodeArray objectAtIndex:j]]) {
                [array addObject:[NSNumber numberWithInt:j]];
                count +=1;
            }
        }
    }
    return array;
}

-(void)titleReset:(CustomBtnInScrollView *)scrl{
    for (int i=0; i<[scrl.dataArray count]; i++) {
        FSUIButton * otherBtn =  [scrl.btnDictionary objectForKey:[NSString stringWithFormat:@"btn%d",i]];
        otherBtn.selected = NO;
        [otherBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}


-(void)groupReset:(BtnCollectionView *)collection{
    for (int i=0; i<[collection.btnArray count]; i++) {
        FSUIButton * otherBtn =  [collection.btnDictionary objectForKey:[NSString stringWithFormat:@"btn%d",i]];
        otherBtn.selected = NO;
        [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:nil];
    
    [super viewWillDisappear:animated];
}


- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:_stringV options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleScrollView1]|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleScrollView2]|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_group1CollectionView]|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_group2CollectionView]|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_group3CollectionView]|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[_titleLabel]-1-|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[_plateUpperBtn]-1-|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[_plateBottomBtn]-1-|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[_promptLabel]-1-|" options:0 metrics:nil views:_objDictionary]];
    [self replaceCustomizeConstraints:constraints];

}

- (void)viewDidLayoutSubviews{
    
    [_titleScrollView1.mainScrollView setContentSize:CGSizeMake([self.titleData1 count]*56.5, 40)];
    [_titleScrollView1.secView setFrame:CGRectMake(0, 0,[self.titleData1 count]*56.5,40)];
    
    [_titleScrollView2.mainScrollView setContentSize:CGSizeMake(340, 40)];
    [_titleScrollView2.secView setFrame:CGRectMake(0, 0,340,40)];
}

-(void)setSearchGroup{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    if (_searchGroup == 0){
        _searchGroup =1;
    }
    [dataModal.portfolioData selectGroupID: _searchGroup];
    [self changeGroup];
}

-(void)editTotalCount:(NSNumber *)count{
    
}

-(void)plateBtnClicked:(FSUIButton *)sender
{
    if(sender == _plateUpperBtn){
        ubFlag = NO;
        [self showPlateActionSheet:_storeUpperDataAry];
    }else if(sender == _plateBottomBtn){
        ubFlag = YES;
        [self showPlateActionSheet:_storeBottomDataAry];
    }
}

-(void)showPlateActionSheet:(NSMutableArray *)dataArray
{
    switch (IS_IOS8) {
        case NO:
            if(_showPlateAS){
            _showPlateAS = nil;
            }
            _showPlateAS = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"分類群組", @"SecuritySearch", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil  otherButtonTitles:nil, nil];
    
            for (int i = 0; i < [dataArray count]; i++){
                NSString *title = ((ForPlateOnly *)dataArray[i]).stringData;
                [_showPlateAS addButtonWithTitle:title];
            }
    
            [_showPlateAS addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
            [self showActionSheet:_showPlateAS];
        break;
        case YES:
            if(_showPlateAC){
                _showPlateAC = nil;
            }
            _showPlateAC =   [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"分類群組", @"SecuritySearch", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            NSInteger index =0;
            for (int i = 0; i < [dataArray count]; i++){
                
                NSInteger buttonIndex =index;
            
                NSString *title = ((ForPlateOnly *)dataArray[i]).stringData;
                UIAlertAction* plateAction = [UIAlertAction
                                              actionWithTitle:title
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action)
                                              {
                                                  printf("index=%ld\n",(long)index);
                                                  if(!ubFlag){
                                                      upperBtnData = buttonIndex;
                                                      [_plateUpperBtn setTitle:((ForPlateOnly *)_storeUpperDataAry[buttonIndex]).stringData forState:UIControlStateNormal];
                                                      FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
                                                      [dataModal.securitySearchModel setTarget:self];
                                                      [dataModal.securitySearchModel performSelector:@selector(searchPlateData:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:[((ForPlateOnly *)_storeUpperDataAry[buttonIndex]).catIDData intValue]] waitUntilDone:NO];
                                                      _upperBottomFlag = !_upperBottomFlag;
                                                  }else {
                                                      bottomBtnData = buttonIndex;
                                                      _groupIndex = ((ForPlateOnly *)_storeBottomDataAry[buttonIndex]).catIDData;
                                                      [self startSearchStuffFromSQLite:buttonIndex];
                                                  }
                                                  
                                              }];
                [_showPlateAC addAction:plateAction];
                index++;
            }

            UIAlertAction* cancelAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)
                                          style:UIAlertActionStyleDefault
                                          handler:nil];
            [_showPlateAC addAction:cancelAction];
            [self presentViewController:_showPlateAC animated:YES completion:nil];
        break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex >= _showPlateAS.numberOfButtons - 1) return;
    if(!ubFlag){
        upperBtnData = buttonIndex;
        [_plateUpperBtn setTitle:((ForPlateOnly *)_storeUpperDataAry[buttonIndex]).stringData forState:UIControlStateNormal];
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchPlateData:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:[((ForPlateOnly *)_storeUpperDataAry[buttonIndex]).catIDData intValue]] waitUntilDone:NO];
        _upperBottomFlag = !_upperBottomFlag;
    }else {
        bottomBtnData = buttonIndex;
        _groupIndex = ((ForPlateOnly *)_storeBottomDataAry[buttonIndex]).catIDData;
        [self startSearchStuffFromSQLite:buttonIndex];
    }
}

-(void)startSearchStuffFromSQLite:(NSInteger)buttonIndex
{
    [_plateBottomBtn setTitle:((ForPlateOnly *)_storeBottomDataAry[buttonIndex]).stringData forState:UIControlStateNormal];
    
    _groupIndex = ((ForPlateOnly *)_storeBottomDataAry[buttonIndex]).catIDData;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchStock:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:[_groupIndex intValue]] waitUntilDone:NO];
    
    [dataModal.securityName setTarget:self];
    
    [dataModal.securityName selectCatID:[((ForPlateOnly *)_storeBottomDataAry[buttonIndex]).catIDData intValue]];
}

-(void)groupButtonClick:(FSUIButton *)button Object:(BtnCollectionView *)scrl{
    //if (button.selected != NO) {
        //[self groupReset:scrl];
    _plateUpperBtn.hidden = YES;
    _plateBottomBtn.hidden = YES;
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        if ([scrl isEqual:_group2CollectionView]) {
            if(isShowPlate){
                _plateUpperBtn.hidden = NO;
                _plateBottomBtn.hidden = NO;
            }
            if(_changeStock){
                NSString * symbolStr = [NSString stringWithFormat:@"%@ %@",[_id2IdentCodeArray objectAtIndex:button.tag],[_id2Array objectAtIndex:button.tag]];
                [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
                PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:symbolStr];
                
                [_delegate changeStockWithPortfolioItem:portfolioItem];
            }else{
                NSLog(@"%@:%@",button.titleLabel.text,[_id2Array objectAtIndex:button.tag]);
                
                storeArray = [[NSMutableArray alloc]init];
                [storeArray addObject:[NSString stringWithFormat:@"%@ %@",[_id2IdentCodeArray objectAtIndex:button.tag],[_id2Array objectAtIndex:button.tag]]];
                [storeArray addObject:[NSNumber numberWithInt:_searchGroup]];
                if (button.selected == NO) {
                    BOOL existFlag = NO;
                    NSMutableArray *actionPlan = [[FSActionPlanDatabase sharedInstances] searchActionPlanIdentCodeSymbol];
                    for (int i = 0; i < [actionPlan count]; i++) {
                        if ([[storeArray objectAtIndex:0] isEqualToString:[actionPlan objectAtIndex:i]]) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"我的自選" message:@"此檔股票已在交易計劃清單當中\n若要移除\n請先至交易計劃刪除此檔股票\n再回到我的自選做刪除" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                            [alert show];
                            existFlag = YES;
                        }
                    }
                    
                    if (!existFlag) {
                        button.titleLabel.textColor = [UIColor blackColor];
                        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        //delete 自選股
                        NSLog(@"%d", (int)button.tag);
                        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_id2IdentCodeArray objectAtIndex:button.tag],[_id2Array objectAtIndex:button.tag]]];
                        [dataModal.portfolioData RemoveItem:secu->identCode andSymbol:secu->symbol];
                        totalCount-=1;
                        count-=1;
                    }

                }else{
                    if (totalCount<[[FSFonestock sharedInstance]portfolioQuota]) {
                        //判斷是否已加入自選
                        NSMutableArray * totalCountArray = [[NSMutableArray alloc]init];
                        
                        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
                        FSDatabaseAgent *dbAgent = dataModel.mainDB;
                        
                        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                            FMResultSet *  message = [db executeQuery:@"SELECT count(IdentCodeSymbol) as count FROM groupPortfolio where  IdentCodeSymbol = ? ",[storeArray objectAtIndex:0]];
                            while ([message next]) {
                                [totalCountArray addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
                            }
                        }];
                        if ([(NSNumber *)[totalCountArray objectAtIndex:0]intValue]==0) { //未加入
                            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_id2IdentCodeArray objectAtIndex:button.tag],[_id2Array objectAtIndex:button.tag]]];
                            //加入Item & DB
                            [dataModal.portfolioData AddItem:secu];
                            totalCount+=1;
                            count+=1;
                        }else{ //加入
                            _storeBtn = button;
                            NSArray *numArray = @[@"", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十"];
                            _existAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"此檔股票已存在,\n確定要移到自選%@嗎?", [numArray objectAtIndex:[(NSNumber *)[storeArray objectAtIndex:1] intValue]]] message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確認", nil];
                            [_existAlert show];
                            return;
                        }
                        
//                        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//                        //判斷是否已存在 如已加入則修改
//                        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//                        [dataModal.securitySearchModel setEditChooseTarget:self];
//                        [dataModal.securitySearchModel performSelector:@selector(editUserStock:) onThread:dataModal.thread withObject:array waitUntilDone:NO];
//                        
//                        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_id2IdentCodeArray objectAtIndex:button.tag],[_id2Array objectAtIndex:button.tag]]];
//                        //加入Item & DB
//                        [dataModal.portfolioData AddItem:secu];
//                        totalCount+=1;
//                        count+=1;
                    }else{
                        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"警告", @"SecuritySearch", nil) message:NSLocalizedStringFromTable(@"自選股已達上限", @"SecuritySearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"SecuritySearch", nil) otherButtonTitles:nil];
                        [alert show];
                    }
                }
                _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
                [dataModal.securitySearchModel setChooseTarget:self];
                [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchGroup] waitUntilDone:NO];
            }
            
        }
        if ([scrl isEqual:_group1CollectionView]) {
            //[self groupReset:scrl];
            _groupIndex = [_id1Array objectAtIndex:button.tag];
            isShowPlate = NO;
            if([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
                _stringV = @"V:|-2-[_titleScrollView1(44)]-3-[_group1CollectionView(==110)]-3-[_titleLabel(20)]-3-[_group2CollectionView]-2-[_promptLabel(20)]-2-|";
            }
            if([@"板块" isEqualToString:button.titleLabel.text]){
                _plateUpperBtn.hidden = NO;
                _plateBottomBtn.hidden = NO;
                isShowPlate = YES;
                _stringV = @"V:|-2-[_titleScrollView1(44)]-3-[_group1CollectionView(110)]-1-[_plateUpperBtn(40)]-1-[_plateBottomBtn(40)]-3-[_titleLabel(20)]-3-[_group2CollectionView]-2-[_promptLabel(20)]-2-|";
                _groupIndex = ((ForPlateOnly*)_storeBottomDataAry[bottomBtnData]).catIDData;
                [self startSearchStuffFromSQLite:bottomBtnData];
            }
            [self.view setNeedsUpdateConstraints];
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            
            if (rootIndex == 5) {
                secFlag = YES;
                [dataModal.securitySearchModel setTarget:self];
                [dataModal.securitySearchModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:_groupIndex waitUntilDone:NO];
            }else{
                FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
                [dataModal.securitySearchModel setTarget:self];
                [dataModal.securitySearchModel performSelector:@selector(searchStock:) onThread:dataModal.thread withObject:_groupIndex waitUntilDone:NO];
                
                [dataModal.securityName setTarget:self];
                
                [dataModal.securityName selectCatID:[(NSNumber *)[_id1Array objectAtIndex:button.tag]intValue]];
            }
            
        }
    
    if ([scrl isEqual:_group3CollectionView]) {
        _groupIndex = [_id3Array objectAtIndex:button.tag];
        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        
        [dataModal.securityName setTarget:self];
            
        [dataModal.securityName selectCatID:[(NSNumber *)[_id3Array objectAtIndex:button.tag]intValue]];
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:_existAlert]) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        if (buttonIndex == 1) {
            [_storeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //判斷是否已存在 如已加入則修改
            [dataModal.securitySearchModel setEditChooseTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(editUserStock:) onThread:dataModal.thread withObject:storeArray waitUntilDone:NO];
            
            SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_id2IdentCodeArray objectAtIndex:_storeBtn.tag],[_id2Array objectAtIndex:_storeBtn.tag]]];
            //加入Item & DB
            [dataModal.portfolioData AddItem:secu];
            totalCount+=1;
            count+=1;
        }
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
        [dataModal.securitySearchModel setChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchGroup] waitUntilDone:NO];
    }
}

-(void)titleButtonClick:(FSUIButton *)button Object:(CustomBtnInScrollView *)scrl{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    if (button.selected == NO) {
        _plateUpperBtn.hidden = YES;
        _plateBottomBtn.hidden = YES;
        isShowPlate = NO;
        [self titleReset:scrl];
        [self groupReset:_group1CollectionView];
        
        
        if ([scrl isEqual:_titleScrollView1]) {
            [self titleReset:_titleScrollView2];
            _groupIndex = [_titleId1 objectAtIndex:button.tag];
            rootIndex = (int)button.tag;
            [dataModal.securitySearchModel setTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:[_titleId1 objectAtIndex:button.tag] waitUntilDone:NO];
            if([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN){
                upperBtnData = 0;
                bottomBtnData = 0;
                FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
                int targetInt = ([_groupIndex intValue] == 101)?113:114;
                [dataModal.securitySearchModel setTarget:self];
                [dataModal.securitySearchModel performSelector:@selector(searchPlateData:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:targetInt] waitUntilDone:YES];
            }
        }
        if ([scrl isEqual:_titleScrollView2]){
            [self titleReset:_titleScrollView1];
            _groupIndex = [_titleId2 objectAtIndex:button.tag];
            rootIndex = 0;
            if ([_groupIndex intValue] ==3) {
                [dataModal.futureModel setGroupTarget:self];
                [dataModal.futureModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:[_titleId2 objectAtIndex:button.tag] waitUntilDone:NO];
            }else{
                [dataModal.securitySearchModel setTarget:self];
                [dataModal.securitySearchModel performSelector:@selector(searchData:) onThread:dataModal.thread withObject:[_titleId2 objectAtIndex:button.tag] waitUntilDone:NO];
            }
            
        }
        button.selected = YES;
    
    }

}


-(void)searchData:(int)num{
    
}

-(void)notify{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(searchStock:) onThread:dataModal.thread withObject:_groupIndex waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation ForPlateOnly
@end