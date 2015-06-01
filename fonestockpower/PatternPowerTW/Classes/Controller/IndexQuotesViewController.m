//
//  IndexQuotesViewController.m
//  IndexQuotesViewController
//
//  Created by CooperLin on 2014/10/17.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import "IndexQuotesViewController.h"
#import "CustomBtnInScrollView.h"
#import "SKCustomTableView.h"
#import "SecuritySearchDelegate.h"
#import "UIViewController+CustomNavigationBar.h"
#import "IndexQuotesObject.h"

#define BUTTON_WIDTH 57

@interface IndexQuotesViewController ()<SKCustomTableViewDelegate, SecuritySearchDelegate>

@end

@implementation IndexQuotesViewController{
    NSMutableArray *arrayForTopButton;
    NSMutableArray *arrayForReturnDB;
    NSMutableArray *arrayForCatID;
    
    NSMutableArray *theStockNameArray;
    
    NSMutableArray *fillUpSymbolObject;
    
    IndexQuotesObject *iqObj;
    
    SKCustomTableView *tView;
    
    CustomBtnInScrollView *cbiView;

    FSDataModelProc *dataModel;
    
    NSInteger whichTopButtonBeClicked;
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
    [self getTheInitData];
    [self initView];
	// Do any additional setup after loading the view.
}

-(void)getTheInitData
{
    whichTopButtonBeClicked = 3001;
    dataModel = [FSDataModelProc sharedInstance];
    iqObj = [[IndexQuotesObject alloc] init];
    fillUpSymbolObject = [iqObj fillSymbolObject:whichTopButtonBeClicked];
    [dataModel.securityName setTarget:self];
    [dataModel.securityName selectCatID:whichTopButtonBeClicked];
}

-(void)initView
{
    [self setUpImageBackButton];
    self.title = NSLocalizedStringFromTable(@"indexquotes", @"IndexQuotes", nil);

    fillUpSymbolObject = [[NSMutableArray alloc] init];
    fillUpSymbolObject = [iqObj fillSymbolObject:whichTopButtonBeClicked];

    arrayForReturnDB = [iqObj getNameAndIDFromDB];
    arrayForTopButton = [[NSMutableArray alloc] init];
    arrayForCatID = [[NSMutableArray alloc] init];
    for(showNameAndID * sna in arrayForReturnDB){
        [arrayForTopButton addObject:sna->name];
        [arrayForCatID addObject:sna->catID];
    }
    
     
    theStockNameArray = [iqObj getStockNameFromCatFullName:[NSString stringWithFormat:@"%d",(int)whichTopButtonBeClicked]];

//    cbiView = [[CustomBtnInScrollView alloc] initWithDataArray:arrayForTopButton Row:1 Column:0 ButtonType:FSUIButtonTypeNormalRed];
    cbiView = [[CustomBtnInScrollView alloc] initWithDataArrayAndImgArray:arrayForTopButton :nil Row:1 Column:0 ButtonType:FSUIButtonTypeNormalRed];
    cbiView.translatesAutoresizingMaskIntoConstraints = NO;
    cbiView.delegate = self;
    [self.view addSubview:cbiView];
    
    FSUIButton *btn0 = [cbiView.btnDictionary objectForKey:@"btn0"];
    btn0.selected = YES;
    
    tView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    tView.translatesAutoresizingMaskIntoConstraints = NO;
    tView.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tView];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(cbiView, tView);
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[cbiView(44)]" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[cbiView(44)]-2-[tView]|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cbiView]|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tView]|" options:0 metrics:nil views:dict]];
    
    [super updateViewConstraints];
}

-(void)viewDidLayoutSubviews
{
    [cbiView.mainScrollView setContentSize:CGSizeMake([arrayForTopButton count]*BUTTON_WIDTH, 40)];
    [cbiView.secView setFrame:CGRectMake(0, 0,[arrayForTopButton count]*BUTTON_WIDTH,40)];
}

-(void)titleButtonClick:(FSUIButton *)button Object:(CustomBtnInScrollView *)scrl
{
    [self titleReset:scrl];

    if(button.selected ==NO){
        [dataModel.portfolioData removeWatchListItemByIdentSymbolArray];
        [dataModel.portfolioTickBank removeIndexQuotesAllKeyWithTaget:self];
        fillUpSymbolObject = [iqObj fillSymbolObject:whichTopButtonBeClicked];
        [dataModel.securityName setTarget:self];
        [dataModel.securityName selectCatID:[(NSNumber *)[arrayForCatID objectAtIndex:button.tag] intValue]];
        whichTopButtonBeClicked = [(NSNumber *)[arrayForCatID objectAtIndex:button.tag] intValue];
        
        button.selected = YES;
        [tView reloadAllData];
    }
    
}

-(void)notify
{
    theStockNameArray = [iqObj getStockNameFromCatFullName:[NSString stringWithFormat:@"%d",(int)whichTopButtonBeClicked]];
    fillUpSymbolObject = [iqObj fillSymbolObject:whichTopButtonBeClicked];
    [dataModel.portfolioData setTarget:self];
    
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:fillUpSymbolObject];
}

-(void)reloadData{
    [tView reloadAllData];
    for (NewSymbolObject * obj in fillUpSymbolObject) {
        [dataModel.portfolioTickBank setTaget:self IdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",obj.identCode,obj.symbol]];
        
        //這裡將組裝好的identCode symbol送至server ，讓server 在收到此次送上去的股名資料時會將資料送回現在的controller
    }
}

-(void)titleReset:(CustomBtnInScrollView *)scrl
{
    for (int i=0; i<[scrl.dataArray count]; i++) {
        FSUIButton * otherBtn =  [scrl.btnDictionary objectForKey:[NSString stringWithFormat:@"btn%d",i]];
        otherBtn.selected = NO;
        [otherBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

-(NSArray *)columnsInFixedTableView
{
    return @[NSLocalizedStringFromTable(@"name", @"IndexQuotes", nil)];
}
-(NSArray *)columnsInMainTableView
{
    
    NSString *last = NSLocalizedStringFromTable(@"last", @"IndexQuotes", nil);
    NSString *change = NSLocalizedStringFromTable(@"change", @"IndexQuotes", nil);
    NSString *changeRate = NSLocalizedStringFromTable(@"changeRate", @"IndexQuotes", nil);
    NSString *highest = NSLocalizedStringFromTable(@"highest", @"IndexQuotes", nil);
    NSString *lowest = NSLocalizedStringFromTable(@"lowest", @"IndexQuotes", nil);
    NSString *singleAmount = NSLocalizedStringFromTable(@"singleAmount", @"IndexQuotes", nil);
    NSString *totalAmount = NSLocalizedStringFromTable(@"totalAmount", @"IndexQuotes", nil);
    NSArray *arr = [[NSArray alloc] initWithObjects:last, change, changeRate, highest, lowest, singleAmount, totalAmount, nil];
    return arr;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fillUpSymbolObject.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewSymbolObject * obj = [fillUpSymbolObject objectAtIndex:indexPath.row];
    label.text = obj.fullName;
    label.textAlignment = NSTextAlignmentLeft;//NSTextAlignmentCenter;
    label.textColor = [UIColor blueColor];
    
}
-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewSymbolObject * obj = [fillUpSymbolObject objectAtIndex:indexPath.row];
    EquitySnapshotDecompressed *mySnapshot = [dataModel.portfolioTickBank getSnapshotFromIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",obj.identCode,obj.symbol]];
    CGFloat aa = 0.0;
    NSString *str = @"";
    switch(columnIndex){
        case 0:
            label.text = [iqObj convertDecimalPoint:mySnapshot.currentPrice];
            label.textColor = [iqObj compareToZero:(mySnapshot.currentPrice - mySnapshot.referencePrice)];
            break;
        case 1:
            aa = (mySnapshot.currentPrice - mySnapshot.referencePrice);
            label.text = [iqObj formatCGFloatData:aa];
            label.textColor = [iqObj compareToZero:aa];
            break;
        case 2:
            aa = ((mySnapshot.currentPrice - mySnapshot.referencePrice)/mySnapshot.currentPrice)* 100;
            if(![[iqObj formatCGFloatData:aa] isEqualToString:@"----"]){
                label.text = [NSString stringWithFormat:@"%@%%",[iqObj formatCGFloatData:aa]];
                label.textColor = [iqObj compareToZero:aa];
            }else{
                label.text = @"----";
                label.textColor = [iqObj compareToZero:0];
            }

            break;
        case 3:
            label.text = [iqObj convertDecimalPoint:mySnapshot.highestPrice];
            aa = mySnapshot.highestPrice - mySnapshot.week52High;
            label.textColor = [iqObj compareToZero:mySnapshot.highestPrice];
            break;
        case 4:
            label.text = [iqObj convertDecimalPoint:mySnapshot.lowestPrice];
            aa = mySnapshot.lowestPrice - mySnapshot.highestPrice;
            label.textColor = [iqObj compareToZero:aa];
            break;
        case 5:
            str = [CodingUtil stringWithVolumeByValue:(mySnapshot.volume * pow(1000,mySnapshot.volumeUnit))];
            if(whichTopButtonBeClicked == 3001){
                label.text = [iqObj forTWUse:str];
            }else{
                label.text = str;
            }
            label.textColor = [UIColor purpleColor];
            break;
        case 6:
            str = [CodingUtil stringWithVolumeByValue:(mySnapshot.accumulatedVolume * pow(1000,mySnapshot.accumulatedVolumeUnit))];
            if(whichTopButtonBeClicked == 3001){
                label.text = [iqObj forTWUse:str];
            }else{
                label.text = str;
            }
            label.textColor = [UIColor purpleColor];
            break;
    }
    label.textAlignment = NSTextAlignmentRight;
    
}

-(void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource{
    if ([dataSource isKindOfClass:[EquityTick class]]) {
        EquityTick * data = (EquityTick *)dataSource;
        NSString * identCodeSymbol =  data.identCodeSymbol;
        int row = -1;
        
        for (int i =0;i<[fillUpSymbolObject count];i++) {
            NewSymbolObject * obj = [fillUpSymbolObject objectAtIndex:i];
            if ([identCodeSymbol isEqualToString:[NSString stringWithFormat:@"%@ %@",obj.identCode,obj.symbol]]) {
                row = i;
                //在送回來的資料中，利用for迴圈找到目前頁面所需要的股名資料
                //將所找到資料的所在筆數位置輸出並跳出迴圈
                break;
            }
        }
        if  (row>=0){
            //row 不等於-1 代表有找到所需要的股名資料
            NSIndexPath * indexPath = [[tView indexPathsForVisibleRows] objectAtIndex:row];
            //並讓更新該筆資料
            [tView.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }
    
}
                         
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
