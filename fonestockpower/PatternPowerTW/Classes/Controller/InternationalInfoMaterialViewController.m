//
//  ViewControllerForShowingXML.m
//  CombineConnectingHTTPAndParseXML
//
//  Created by CooperLin on 2014/10/3.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import "InternationalInfoMaterialViewController.h"
#import "CustomBtnInScrollView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SortingCustomTableView.h"
#import "SecuritySearchDelegate.h"

#define BUTTON_WIDTH 83

@interface InternationalInfoMaterialViewController ()<SortingTableViewDelegate, UITableViewDelegate,SecuritySearchDelegate>

@property (nonatomic) int nowSorting;
@property (nonatomic) BOOL nowSortingType;//yes:遞增，no:遞減

@end

@implementation InternationalInfoMaterialViewController{
    
    NSMutableArray *arrayForMaterial;
    NSMutableArray *arrayForImg;

    InternationalInfoObject_v1 *dcap;
    SortingCustomTableView *tView;
    CustomBtnInScrollView *cbiViewForMaterial;
    
    //common
    NSString *close;
    NSString *d1;
    NSString *w1;
    NSString *m1;
    NSString *m3;
    //forex
    //material
    NSString *exchange;
    
    materialFormat *mft;
}

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
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {  // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone;                       //layout adjustements
    }
    
    [self initView];
    [self.view setNeedsUpdateConstraints];
    
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getTheBeginData];
}

-(void)getTheBeginData
{
    FSUIButton *btnF = [cbiViewForMaterial.btnDictionary objectForKey:@"btn0"];
    btnF.selected = YES;
    dcap = [[InternationalInfoObject_v1 alloc]init];
    NSString *sectorID = @"3070";
    if([dcap isFileExists:sectorID]){
        self.ttt.materialArray = [dcap parseXML:@"3070" :InternationalTargetMaterial];
    }else{
        self.ttt.materialArray = [dcap loadWeb:@"3070" :InternationalTargetMaterial];
    }
    [tView reloadAllData];
}

-(void)initView
{
    [self setUpImageBackButton];
    self.nowSorting = -1;
    self.nowSortingType = NO;
    self.ttt = [[theSecurityNodes_v1 alloc] init];
    self.ttt.materialArray = [[NSMutableArray alloc] init];
    self.title = NSLocalizedStringFromTable(@"internationalInfo",@"InternationalInfo",nil);
    
    arrayForImg = [[NSMutableArray alloc] initWithObjects:@"us",@"eu",@"jp",@"tw",@"cn",@"hk",@"au",@"ca",@"uk",@"ch",@"sg", nil];
    arrayForMaterial = [[NSMutableArray alloc] initWithObjects:@"貴金屬",@"農產品", nil];

    FSUIButton *btnF = [cbiViewForMaterial.btnDictionary objectForKey:@"btn0"];
    btnF.selected = YES;
    
    [arrayForImg removeAllObjects];
    [arrayForImg addObject:@"none"];

    cbiViewForMaterial = [[CustomBtnInScrollView alloc] initWithDataArrayAndImgArray:arrayForMaterial :arrayForImg Row:1 Column:0 ButtonType:FSUIButtonTypeFlagButton];
    cbiViewForMaterial.translatesAutoresizingMaskIntoConstraints = NO;
    cbiViewForMaterial.delegate = self;
    [self.view addSubview:cbiViewForMaterial];
    
    tView = [[SortingCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    tView.translatesAutoresizingMaskIntoConstraints = NO;
    tView.delegate = self;
    tView.focuseLabel = -1;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tView];
    
    self.ttt.materialArray = [[NSMutableArray alloc] init];
}

-(void)titleButtonClick:(FSUIButton *)button Object:(CustomBtnInScrollView *)scrl{

    [self titleReset:scrl];
    button.selected = YES;
    NSMutableArray * doParsingThing;
    NSString *searchName = button.titleLabel.text;
    
    if(searchName){
        NSString *theID = [dcap getTheSectorID:searchName];
        
        if([dcap isFileExists:theID]){
            doParsingThing = [dcap parseXML:theID :InternationalTargetMaterial];
        }else{
            doParsingThing = [dcap loadWeb:theID :InternationalTargetMaterial];
        }
        self.ttt.materialArray = doParsingThing;

        [tView reloadAllData];
    }
}

-(void)titleReset:(CustomBtnInScrollView *)scrl{
    for (int i=0; i<[scrl.dataArray count]; i++) {
        FSUIButton * otherBtn =  [scrl.btnDictionary objectForKey:[NSString stringWithFormat:@"btn%d",i]];
        otherBtn.selected = NO;
        [otherBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

-(void)viewDidLayoutSubviews{

    [cbiViewForMaterial.mainScrollView setContentSize:CGSizeMake([arrayForMaterial count] * BUTTON_WIDTH, 40)];
    [cbiViewForMaterial.secView setFrame:CGRectMake(0,0,[arrayForMaterial count]*BUTTON_WIDTH,40)];
}

-(void)updateViewConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(cbiViewForMaterial, tView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[cbiViewForMaterial(45)]-2-[tView]|" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cbiViewForMaterial]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tView]|" options:0 metrics:nil views:allObj]];
    
    [super updateViewConstraints];
}

-(void)myAction:(UIButton *)sender
{
    [self resetMyChildBtn:2];
    FSUIButton *btn = (FSUIButton *)sender;
    NSMutableArray *doParsingThing;
    sender.selected = YES;
    NSString *searchName = btn.titleLabel.text;
    NSString *theID = [dcap getTheSectorID:searchName];

    if([dcap isFileExists:theID]){
        doParsingThing = [dcap parseXML:theID :InternationalTargetMaterial];
    }else{
        doParsingThing = [dcap loadWeb:theID :InternationalTargetMaterial];
    }

    self.ttt.materialArray = doParsingThing;

    [tView reloadAllData];
}

-(void)resetMyChildBtn:(NSInteger)which
{
    CustomBtnInScrollView * cbiView = cbiViewForMaterial;
    NSMutableArray *mutableArray = arrayForMaterial;

    for(int i = 0; i < mutableArray.count; i++){
        FSUIButton *btnF = [cbiView.btnDictionary objectForKey:[NSString stringWithFormat:@"btn%d",i]];
        btnF.selected = NO;
    }
}

-(NSArray *)columnsInFixedTableView
{
    return @[NSLocalizedStringFromTable(@"name", @"InternationalInfo", nil)];
}
-(NSArray *)columnsInMainTableView
{
    close = NSLocalizedStringFromTable(@"close", @"InternationalInfo", nil);
    d1 = NSLocalizedStringFromTable(@"d1", @"InternationalInfo", nil);
    w1 = NSLocalizedStringFromTable(@"w1", @"InternationalInfo", nil);
    m1 = NSLocalizedStringFromTable(@"m1", @"InternationalInfo", nil);
    m3 = NSLocalizedStringFromTable(@"m3", @"InternationalInfo", nil);
    exchange = NSLocalizedStringFromTable(@"exchange", @"InternationalInfo", nil);
    
    NSArray *arr = [NSArray arrayWithObjects:exchange, close, d1, w1, m1, nil];

    return arr;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    mft = [self.ttt.materialArray objectAtIndex:indexPath.row];

    label.text = mft->name;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor brownColor];
    
}
-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InternationalInfoObject_v1 *obj = [[InternationalInfoObject_v1 alloc] init];
    mft = [self.ttt.materialArray objectAtIndex:indexPath.row];
    CGFloat aa = 0.0;
    switch(columnIndex){
    case 0:
        label.text = mft->exchange;
        label.textColor = [UIColor brownColor];
        break;
    case 1:
        label.text = [obj convertDecimalPoint:mft->last];
        label.textColor = [UIColor blueColor];
        break;
    case 2:
        aa = mft->oneDay * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    case 3:
        aa = mft->oneWeek * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    case 4:
        aa = mft->oneMonth * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    default:
        break;
}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ttt.materialArray.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)labelTap:(UILabel *)label
{
    NSLog(@"show the label tag %d", (int)label.tag);
    NSString *sortingKey;
    NSMutableArray *beSortedArray;
    switch(label.tag){
        case 1: sortingKey = @"last"; break;
        case 2: sortingKey = @"last"; break;
        case 3: sortingKey = @"oneDay"; break;
        case 4: sortingKey = @"oneWeek"; break;
        case 5: sortingKey = @"oneMonth"; break;
    }
    beSortedArray = self.ttt.materialArray;
    if (_nowSorting != label.tag) {
        if (label.tag != 0) {
            _nowSorting = (int)label.tag;
            tView.focuseLabel = (int)label.tag;
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:YES];
            _nowSortingType = YES;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[beSortedArray sortedArrayUsingDescriptors:sortDescriptors]];
            
            beSortedArray = sortedArray;
        }
        
    }else{
        if (label.tag != 0) {
            if (_nowSortingType) {
                _nowSortingType = NO;
            }else{
                _nowSortingType = YES;
            }
            
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:_nowSortingType];
            
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[beSortedArray sortedArrayUsingDescriptors:sortDescriptors]];
            
            beSortedArray = sortedArray;
        }
    }
    self.ttt.materialArray = beSortedArray;
    [tView reloadDataNoOffset];
}




/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"the showing %d",indexPath.row);
    NSLog(@"the length %d",self.ttt.forexArray.count);
    float aa = (1000/7.0);
    NSLog(@"___________ %.1f",aa);
}*/
@end
