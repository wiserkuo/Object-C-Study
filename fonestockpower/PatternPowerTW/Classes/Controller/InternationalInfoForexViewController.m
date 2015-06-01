//
//  ViewControllerForShowingXML.m
//  CombineConnectingHTTPAndParseXML
//
//  Created by CooperLin on 2014/10/3.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import "InternationalInfoForexViewController.h"
#import "CustomBtnInScrollView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SortingCustomTableView.h"
#import "SecuritySearchDelegate.h"

#define BUTTON_WIDTH 83

@interface InternationalInfoForexViewController ()<SortingTableViewDelegate, UITableViewDelegate,SecuritySearchDelegate>

@property (nonatomic) int nowSorting;
@property (nonatomic) BOOL nowSortingType;//yes:遞增，no:遞減

@end

@implementation InternationalInfoForexViewController{

    NSMutableArray *arrayForForex;
    NSMutableArray *arrayForImg;

    InternationalInfoObject_v1 *dcap;
    SortingCustomTableView *tView;
    CustomBtnInScrollView *cbiViewForForex;
    
    //common
    NSString *close;
    NSString *d1;
    NSString *w1;
    NSString *m1;
    NSString *m3;
    //forex
    
    forexFormat *fft;
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
    FSUIButton *btnF = [cbiViewForForex.btnDictionary objectForKey:@"btn0"];
    btnF.selected = YES;
    dcap = [[InternationalInfoObject_v1 alloc]init];
    NSString *sectorID = @"3050";
    if([dcap isFileExists:sectorID]){
        self.ttt.forexArray = [dcap parseXML:@"3050" :InternationalTargetForex];
    }else{
        self.ttt.forexArray = [dcap loadWeb:@"3050" :InternationalTargetForex];
    }
    [tView reloadAllData];
}

-(void)initView
{
    [self setUpImageBackButton];
    self.nowSorting = -1;
    self.nowSortingType = NO;
    self.ttt = [[theSecurityNodes_v1 alloc] init];
    self.ttt.forexArray = [[NSMutableArray alloc] init];
    self.ttt.materialArray = [[NSMutableArray alloc] init];
    self.ttt.industryArray = [[NSMutableArray alloc] init];
    self.title = NSLocalizedStringFromTable(@"internationalInfo",@"InternationalInfo",nil);
    
    arrayForForex = [[NSMutableArray alloc] initWithObjects:@"美元",@"歐元",@"日元",@"台幣",@"人民幣",@"港幣",@"澳幣",@"加拿大幣",@"英鎊",@"瑞士法郎",@"新加坡幣", nil];
    arrayForImg = [[NSMutableArray alloc] initWithObjects:@"us",@"eu",@"jp",@"tw",@"cn",@"hk",@"au",@"ca",@"uk",@"ch",@"sg", nil];
    
    cbiViewForForex = [[CustomBtnInScrollView alloc] initWithDataArrayAndImgArray:arrayForForex :arrayForImg Row:1 Column:0 ButtonType:FSUIButtonTypeFlagButton];
    cbiViewForForex.translatesAutoresizingMaskIntoConstraints = NO;
    cbiViewForForex.delegate = self;
    [self.view addSubview:cbiViewForForex];
    
    FSUIButton *btnF = [cbiViewForForex.btnDictionary objectForKey:@"btn0"];
    btnF.selected = YES;
    
    [arrayForImg removeAllObjects];
    [arrayForImg addObject:@"none"];

    tView = [[SortingCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    tView.translatesAutoresizingMaskIntoConstraints = NO;
    tView.delegate = self;
    tView.focuseLabel = -1;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tView];
    
    self.ttt.forexArray = [[NSMutableArray alloc] init];
}

-(void)titleButtonClick:(FSUIButton *)button Object:(CustomBtnInScrollView *)scrl{

    [self titleReset:scrl];
    button.selected = YES;
    NSMutableArray * doParsingThing;
    NSString *searchName = button.textLabel.text;

    if(searchName){
        NSString *theID;
        theID = [dcap getTheSectorID:searchName];
        
        if([dcap isFileExists:theID]){
            doParsingThing = [dcap parseXML:theID :InternationalTargetForex];
        }else{
            doParsingThing = [dcap loadWeb:theID :InternationalTargetForex];
        }
        
        self.ttt.forexArray = doParsingThing;

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
    [cbiViewForForex.mainScrollView setContentSize:CGSizeMake([arrayForForex count]*BUTTON_WIDTH, 40)];
    [cbiViewForForex.secView setFrame:CGRectMake(0, 0,[arrayForForex count]*BUTTON_WIDTH,40)];
}

-(void)updateViewConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(cbiViewForForex, tView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[cbiViewForForex(44)]-1-[tView]|" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cbiViewForForex]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tView]|" options:0 metrics:nil views:allObj]];
    [super updateViewConstraints];
}

-(void)myAction:(UIButton *)sender
{
    [self resetMyChildBtn:1];
    FSUIButton *btn = (FSUIButton *)sender;
    NSMutableArray *doParsingThing;
    sender.selected = YES;
    NSString *searchName;
    NSString *theID;
    searchName = btn.titleLabel.text;

    theID = [dcap getTheSectorID:searchName];

    if([dcap isFileExists:theID]){
        doParsingThing = [dcap parseXML:theID :InternationalTargetForex];
    }else{
        doParsingThing = [dcap loadWeb:theID :InternationalTargetForex];
    }

    self.ttt.forexArray = doParsingThing;
    [tView reloadAllData];
}

-(void)resetMyChildBtn:(NSInteger)which
{
    CustomBtnInScrollView * cbiView = cbiViewForForex;
    NSMutableArray *mutableArray = arrayForForex;

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
    
    NSArray *arr;
    arr = [NSArray arrayWithObjects:close,d1,w1,m1,m3, nil];

    return arr;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    fft = [self.ttt.forexArray objectAtIndex:indexPath.row];

    label.text = fft->name;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor brownColor];
    
}
-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InternationalInfoObject_v1 *obj = [[InternationalInfoObject_v1 alloc] init];

    fft = [self.ttt.forexArray objectAtIndex:indexPath.row];

    CGFloat aa = 0.0;

        switch(columnIndex){
            case 0:
                aa = fft->last;
                label.text = [obj convertDecimalPoint:aa];
                label.textColor = [obj compareToZero:(fft->oneDay * 100)];
                break;
            case 1:
                aa = fft->oneDay * 100;
                label.text = [obj formatCGFloatData:aa];
                label.textColor = [obj compareToZero:aa];
                break;
            case 2:
                aa = fft->oneWeek * 100;
                label.text = [obj formatCGFloatData:aa];
                label.textColor = [obj compareToZero:aa];
                break;
            case 3:
                aa = fft->oneMonth * 100;
                label.text = [obj formatCGFloatData:aa];
                label.textColor = [obj compareToZero:aa];
                break;
            case 4:
                aa = fft->threeMonth * 100;
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
    NSInteger inn = 0;
    inn = self.ttt.forexArray.count;
    return inn;
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
        case 2: sortingKey = @"oneDay"; break;
        case 3: sortingKey = @"oneWeek"; break;
        case 4: sortingKey = @"oneMonth"; break;
        case 5: sortingKey = @"threeMonth"; break;
    }
    beSortedArray = self.ttt.forexArray;

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
    self.ttt.forexArray = beSortedArray;

    [tView reloadDataNoOffset];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell %d", (int)indexPath.row);
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didEndDisplay %d", (int)indexPath.row);
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
