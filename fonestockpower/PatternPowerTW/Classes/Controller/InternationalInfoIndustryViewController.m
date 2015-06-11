//
//  ViewControllerForShowingXML.m
//  CombineConnectingHTTPAndParseXML
//
//  Created by CooperLin on 2014/10/3.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import "InternationalInfoIndustryViewController.h"
#import "CustomBtnInScrollView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SortingCustomTableView.h"
#import "SecuritySearchDelegate.h"

#define BUTTON_WIDTH 83

@interface InternationalInfoIndustryViewController ()<SortingTableViewDelegate, UITableViewDelegate,SecuritySearchDelegate>

@property (nonatomic) int nowSorting;
@property (nonatomic) BOOL nowSortingType;//yes:遞增，no:遞減

@end

@implementation InternationalInfoIndustryViewController{
    NSMutableArray *arrayForIndustry;
    NSMutableArray *arrayForImg;

    InternationalInfoObject_v1 *dcap;
    SortingCustomTableView *tView;
    CustomBtnInScrollView *cbiViewForIndustry;
    
    //common
    NSString *close;
    NSString *d1;
    NSString *w1;
    NSString *m1;
    NSString *m3;
    //forex
    //material
    //industry
    NSString *m6;
    NSString *highFor52w;
    NSString *lowFor52w;
    NSString *highest;
    NSString *lowest;
    
    industryFormat *ift;
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
    FSUIButton *btnF = [cbiViewForIndustry.btnDictionary objectForKey:@"btn0"];
    btnF.selected = YES;
    dcap = [[InternationalInfoObject_v1 alloc]init];
    NSString *sectorID = @"3090";
    if([dcap isFileExists:sectorID]){
        self.ttt.industryArray = [dcap parseXML:@"3090" :InternationalTargetIndustry];
    }else{
        self.ttt.industryArray = [dcap loadWeb:@"3090" :InternationalTargetIndustry];
    }
    [tView reloadAllData];
}

-(void)initView
{
    [self setUpImageBackButton];
    self.nowSorting = -1;
    self.nowSortingType = NO;
    self.ttt = [[theSecurityNodes_v1 alloc] init];
    self.ttt.industryArray = [[NSMutableArray alloc] init];
    self.title = NSLocalizedStringFromTable(@"internationalInfo",@"InternationalInfo",nil);

    arrayForIndustry = [[NSMutableArray alloc] initWithObjects:@"半導體",@"電信服務",@"資訊產品",@"光電產品",@"軟體網路",@"生物科技",@"能源化學",@"基礎原料",@"汽車機械",@"運輸服務",@"金融業",@"生活零售",@"食品零售", nil];
    
    FSUIButton *btnF = [cbiViewForIndustry.btnDictionary objectForKey:@"btn0"];
    btnF.selected = YES;
    
    arrayForImg = [[NSMutableArray alloc] init];
    
    [arrayForImg removeAllObjects];
    [arrayForImg addObject:@"none"];

    cbiViewForIndustry = [[CustomBtnInScrollView alloc] initWithDataArrayAndImgArray:arrayForIndustry :arrayForImg Row:1 Column:0 ButtonType:FSUIButtonTypeFlagButton];
    cbiViewForIndustry.translatesAutoresizingMaskIntoConstraints = NO;
    cbiViewForIndustry.delegate = self;
    [self.view addSubview:cbiViewForIndustry];
    
    tView = [[SortingCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    tView.translatesAutoresizingMaskIntoConstraints = NO;
    tView.delegate = self;
    tView.focuseLabel = -1;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tView];
    
    self.ttt.industryArray = [[NSMutableArray alloc] init];
}

-(void)titleButtonClick:(FSUIButton *)button Object:(CustomBtnInScrollView *)scrl{

    [self titleReset:scrl];
    button.selected = YES;
    NSMutableArray * doParsingThing;
    NSString *searchName = button.titleLabel.text;
    
    if(searchName){
        NSString *theID;
        if([searchName isEqualToString:@"金融業"]){
            theID = @"3100";
        }else{
            theID = [dcap getTheSectorID:searchName];
        }
        if([dcap isFileExists:theID]){
            doParsingThing = [dcap parseXML:theID :InternationalTargetIndustry];
        }else{
            doParsingThing = [dcap loadWeb:theID :InternationalTargetIndustry];
        }
        
        self.ttt.industryArray = doParsingThing;

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

    [cbiViewForIndustry.mainScrollView setContentSize:CGSizeMake([arrayForIndustry count]*BUTTON_WIDTH, 40)];
    [cbiViewForIndustry.secView setFrame:CGRectMake(0, 0,[arrayForIndustry count]*BUTTON_WIDTH,40)];
}

-(void)updateViewConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(cbiViewForIndustry, tView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[cbiViewForIndustry(45)]-1-[tView]|" options:0 metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cbiViewForIndustry]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tView]|" options:0 metrics:nil views:allObj]];
    [super updateViewConstraints];
}

-(void)myAction:(UIButton *)sender
{
    [self resetMyChildBtn:3];
    FSUIButton *btn = (FSUIButton *)sender;

    NSMutableArray *doParsingThing;
    sender.selected = YES;
    NSString *searchName = btn.titleLabel.text;
    NSString *theID;
    
    theID = [dcap getTheSectorID:searchName];

    if([dcap isFileExists:theID]){
        doParsingThing = [dcap parseXML:theID :InternationalTargetIndustry];
    }else{
        doParsingThing = [dcap loadWeb:theID :InternationalTargetIndustry];
    }
    
    self.ttt.industryArray = doParsingThing;

    [tView reloadAllData];
}

-(void)resetMyChildBtn:(NSInteger)which
{
    CustomBtnInScrollView * cbiView = cbiViewForIndustry;
    NSMutableArray *mutableArray = arrayForIndustry;

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
    m6 = NSLocalizedStringFromTable(@"m6", @"InternationalInfo", nil);
    highFor52w = NSLocalizedStringFromTable(@"highFor52w", @"InternationalInfo", nil);
    lowFor52w = NSLocalizedStringFromTable(@"lowFor52w", @"InternationalInfo", nil);
    highest = NSLocalizedStringFromTable(@"highest", @"InternationalInfo", nil);
    lowest = NSLocalizedStringFromTable(@"lowest", @"InternationalInfo", nil);
    NSArray *arr = [NSArray arrayWithObjects:close, d1, w1, m1, m3, m6, highFor52w, lowFor52w, highest, lowest, nil];

    return arr;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    ift = [self.ttt.industryArray objectAtIndex:indexPath.row];
    label.text = ift->name;
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor brownColor];
    
}
-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InternationalInfoObject_v1 *obj = [[InternationalInfoObject_v1 alloc] init];

    ift = [self.ttt.industryArray objectAtIndex:indexPath.row];

    CGFloat aa = 0.0;
    switch(columnIndex){
    case 0:
        label.text = [NSString stringWithFormat:@"%.2f",ift->last];
        aa = ift->oneDay * 100;
        label.textColor = [obj compareToZero:aa];
        break;
    case 1:
        aa = ift->oneDay * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    case 2:
        aa = ift->oneWeek * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    case 3:
        aa = ift->oneMonth * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    case 4:
        aa = ift->threeMonth * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    case 5:
        aa = ift->sixMonth * 100;
        label.text = [obj formatCGFloatData:aa];
        label.textColor = [obj compareToZero:aa];
        break;
    case 6:
        if(ift->w52High){
            label.text = [NSString stringWithFormat:@"%.2f",ift->w52High];
        }else{
            label.text = @"----";
        }
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentRight;
        break;
    case 7:
        if(ift->w52Low){
            label.text = [NSString stringWithFormat:@"%.2f",ift->w52Low];
        }else{
            label.text = @"----";
        }
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentRight;
        break;
    case 8:
        if(ift->thisYearHigh){
            label.text = [NSString stringWithFormat:@"%.2f",ift->thisYearHigh];
        }else{
            label.text = @"----";
        }
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentRight;
        break;
    case 9:
        if(ift->thisYearLow){
            label.text = [NSString stringWithFormat:@"%.2f",ift->thisYearLow];
        }else{
            label.text = @"----";
        }
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentRight;
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
    return self.ttt.industryArray.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)labelTap:(UILabel *)label
{
    NSLog(@"show the label tag %d",(int)label.tag);
    NSString *sortingKey;
    NSMutableArray *beSortedArray;

    switch(label.tag){
        case 1: sortingKey = @"last"; break;
        case 2: sortingKey = @"oneDay"; break;
        case 3: sortingKey = @"oneWeek"; break;
        case 4: sortingKey = @"oneMonth"; break;
        case 5: sortingKey = @"threeMonth"; break;
        case 6: sortingKey = @"sixMonth"; break;
        case 7: sortingKey = @"w52High"; break;
        case 8: sortingKey = @"w52Low"; break;
        case 9: sortingKey = @"thisYearHigh"; break;
        case 10: sortingKey = @"thisYearLow"; break;
    }
    beSortedArray = self.ttt.industryArray;

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
    self.ttt.industryArray = beSortedArray;
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
