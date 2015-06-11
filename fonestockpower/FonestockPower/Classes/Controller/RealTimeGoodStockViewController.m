//
//  RealTimeGoodStockViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "RealTimeGoodStockViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "GoodStockModel.h"

@interface RealTimeGoodStockViewController ()<UIAlertViewDelegate>{
    UIActionSheet * searchActionSheet;
    UIActionSheet * groupActionSheet;
    NSTimer *timer;
    NSArray *sendArray;
    BOOL update;

}

@end

@implementation RealTimeGoodStockViewController

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
    [self setUpImageBackButton];
    self.navigationItem.title = NSLocalizedStringFromTable(@"即時面密碼", @"GoodStock", nil);
    [self initView];
    [self varInit];
	// Do any additional setup after loading the view.
}

-(void)initView{
    _searchKey = 0;
    _searchGroup = 0;
    
    self.searchKeyBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _searchKeyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchKeyBtn setTitle:NSLocalizedStringFromTable(@"開高走低", @"GoodStock", nil) forState:UIControlStateNormal];
    [_searchKeyBtn addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchKeyBtn];
    
    self.groupBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _groupBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_groupBtn setTitle:NSLocalizedStringFromTable(@"上市", @"GoodStock", nil) forState:UIControlStateNormal];
    [_groupBtn addTarget:self action:@selector(groupBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_groupBtn];
    
    self.mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    
    [self.view addSubview:_mainTableView];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)varInit {
    
    self.columnNames = [[NSMutableArray alloc] initWithObjects:
                        NSLocalizedStringFromTable(@"買進", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"賣出", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"成交", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"最高", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"最低", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"漲跌", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"漲幅", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"振幅", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"單量", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"總量", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"成交總值", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"外內盤比", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"委買賣差", @"GoodStock", nil),
                        nil];
    
    self.groupArray = [[NSMutableArray alloc] initWithObjects:
                           NSLocalizedStringFromTable(@"上市", @"GoodStock", nil),
                       NSLocalizedStringFromTable(@"上櫃", @"GoodStock", nil),nil];
    
    
    self.searchKeyArray = [[NSMutableArray alloc] initWithObjects:
                        NSLocalizedStringFromTable(@"開高走低", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"開低走高", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"連續買單", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"連續賣單", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"瞬間拉抬", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"瞬間殺盤", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"買盤強勢", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"賣盤主導", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"買氣強大", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"賣壓沈重", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"瞬間巨量", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"漲幅排行", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"跌幅排行", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"振幅排行", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"成交價", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"昨量比", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"成交總量", @"GoodStock", nil),
                        NSLocalizedStringFromTable(@"成交總值", @"GoodStock", nil),
                        nil];
    
}

-(void)searchBtnClick{
    searchActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"排序方式", @"GoodStock", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i;
    for (i=0;i<[_searchKeyArray count];i++) {
        NSString * title = [_searchKeyArray objectAtIndex:i];
        [searchActionSheet addButtonWithTitle:title];
    }
    [searchActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [searchActionSheet setCancelButtonIndex:i];
    [self showActionSheet:searchActionSheet];
}

- (void)groupBtnClick {
    
    groupActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類別", @"GoodStock", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i;
    for (i=0;i<[_groupArray count];i++) {
        NSString * title = [_groupArray objectAtIndex:i];
        [groupActionSheet addButtonWithTitle:title];
    }
    [groupActionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [groupActionSheet setCancelButtonIndex:i];
    [self showActionSheet:groupActionSheet];

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [timer invalidate];
    update = NO;
    if ([actionSheet isEqual:searchActionSheet] && buttonIndex<[_searchKeyArray count]) {
        _searchKey = (int)buttonIndex;
        [self sendPacket];


//        sendArray = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:_searchKey],[NSNumber numberWithInt:_searchGroup], nil];
//
//        [dataModal.specialStateModel setTarget:self];
//        [dataModal.goodStockModel performSelector:@selector(searchStockWithArray:) onThread:dataModal.thread withObject:dataArray waitUntilDone:NO];
        if (buttonIndex==7) {
            [_columnNames replaceObjectAtIndex:11 withObject:NSLocalizedStringFromTable(@"內外盤比", @"GoodStock", nil)];
        }else{
            [_columnNames replaceObjectAtIndex:11 withObject:NSLocalizedStringFromTable(@"外內盤比", @"GoodStock", nil)];
        }
        
        [_searchKeyBtn setTitle:[_searchKeyArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }else if(buttonIndex<[_groupArray count]){
        _searchGroup = (int)buttonIndex;
        [self sendPacket];


//        sendArray = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:_searchKey],[NSNumber numberWithInt:_searchGroup], nil];
//        [dataModal.specialStateModel setTarget:self];
//        [dataModal.goodStockModel performSelector:@selector(searchStockWithArray:) onThread:dataModal.thread withObject:dataArray waitUntilDone:NO];
        [_groupBtn setTitle:[_groupArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    }
}

- (void)updateViewConstraints {
//    [self.view removeConstraints:self.view.constraints];
    [super updateViewConstraints];

    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_searchKeyBtn, _groupBtn, _mainTableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_searchKeyBtn]-2-[_mainTableView]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_searchKeyBtn]-2-[_groupBtn(==_searchKeyBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
   
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [timer invalidate];

    [self.navigationController setNavigationBarHidden:NO];
    [self sendPacket];
//    sendArray = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:_searchKey],[NSNumber numberWithInt:_searchGroup], nil];
//    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//    [dataModal.specialStateModel setTarget:self];
//    [dataModal.goodStockModel performSelector:@selector(searchStockWithArray:) onThread:dataModal.thread withObject:sendArray waitUntilDone:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [timer invalidate];
    update = NO;

    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.specialStateModel setTarget:nil];
    
}
-(void)notifyDataArrive:(NSMutableArray *)array{
    NSLog(@"Back");
    [timer invalidate];

    if ([array count] == 0) {
        UIAlertView *noDataAlert = [[UIAlertView alloc]initWithTitle:@"無符合個股" message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [noDataAlert show];
    }
    _dataArray = array;
    
    if (!update) {
        [_mainTableView reloadAllData];
    }else{
        [_mainTableView reloadDataNoOffset];
    }
    
    update = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(sendPacket) userInfo:nil repeats:YES];

}

-(void)sendPacket{
    
    sendArray = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:_searchKey],[NSNumber numberWithInt:_searchGroup], nil];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.specialStateModel setTarget:self];
    [dataModal.goodStockModel performSelector:@selector(searchStockWithArray:update:) withObject:sendArray withObject:[NSNumber numberWithBool:update]];

}
-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    label.textAlignment = NSTextAlignmentLeft;
    
    _stockArray = [_dataArray objectAtIndex:indexPath.row];
    
    SymbolFormat1 * symbol = [[SymbolFormat1 alloc]init];
    symbol = [_stockArray  objectAtIndex:0];
    label.text = [NSString stringWithFormat:@"%@",symbol->fullName];
    label.textColor = [UIColor blueColor];
    
}

-(int)searchArrayWithValue:(int)value{
    int x=0;
    
    for (int i =0; i<[_fieldIdArray count]; i++) {
        if (value == [[_fieldIdArray objectAtIndex:i]intValue]) {
            x=i;
        }
    }
    
    return x;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    _stockArray = [_dataArray objectAtIndex:indexPath.row];
    _fieldIdArray = [_stockArray objectAtIndex:2];
    _fieldDataArray = [_stockArray objectAtIndex:3];
    
    // default value
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.text = @"----";
    if (columnIndex == 0) {
        //買進5
        int buyP = [self searchArrayWithValue:5];
        
        label.text = [NSString stringWithFormat:@"%.2f",[[_fieldDataArray objectAtIndex:buyP]floatValue]];
//        int todayP = [self searchArrayWithValue:2];
        int yesterdayP = [self searchArrayWithValue:3];
//        int upDown =  [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
//        if (upDown!=0) {
//            if (upDown == 4 && [[_fieldDataArray objectAtIndex:todayP] floatValue]==[[_fieldDataArray objectAtIndex:buyP] floatValue]) {
//                    label.backgroundColor = [UIColor redColor];
//            }else if (upDown == 5 && [[_fieldDataArray objectAtIndex:todayP] floatValue]==[[_fieldDataArray objectAtIndex:buyP] floatValue]){
//                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
//            }
//            label.textColor = [UIColor whiteColor];
//        }else{
            if ([[_fieldDataArray objectAtIndex:buyP] floatValue]>[[_fieldDataArray objectAtIndex:yesterdayP] floatValue]) {
                label.textColor = [UIColor redColor];
            }else if ([[_fieldDataArray objectAtIndex:buyP]floatValue]<[[_fieldDataArray objectAtIndex:yesterdayP]floatValue]){
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else{
                label.textColor = [UIColor blueColor];
            }
        //}
        if ([[_fieldDataArray objectAtIndex:buyP]floatValue]==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex == 1) {
        //賣出6
        int sellP = [self searchArrayWithValue:6];
        
        label.text = [NSString stringWithFormat:@"%.2f",[[_fieldDataArray objectAtIndex:sellP]floatValue]];
//        int todayP = [self searchArrayWithValue:2];
        int yesterdayP = [self searchArrayWithValue:3];
//        int upDown =  [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
//        if (upDown!=0) {
//            if (upDown == 4 && [[_fieldDataArray objectAtIndex:todayP] floatValue]==[[_fieldDataArray objectAtIndex:sellP] floatValue]) {
//                label.backgroundColor = [UIColor redColor];
//            }else if (upDown == 5 && [[_fieldDataArray objectAtIndex:todayP] floatValue]==[[_fieldDataArray objectAtIndex:sellP] floatValue]){
//                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
//            }
//            label.textColor = [UIColor whiteColor];
//        }else{
            if ([(NSNumber *)[_fieldDataArray objectAtIndex:sellP] floatValue]>[(NSNumber *)[_fieldDataArray objectAtIndex:yesterdayP] floatValue]) {
                label.textColor = [UIColor redColor];
            }else if ([(NSNumber *)[_fieldDataArray objectAtIndex:sellP]floatValue]<[(NSNumber *)[_fieldDataArray objectAtIndex:yesterdayP]floatValue]){
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else{
                label.textColor = [UIColor blueColor];
            }
        //}
        if ([[_fieldDataArray objectAtIndex:sellP]floatValue]==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex == 2) {
        //成交價2
        int todayP = [self searchArrayWithValue:2];
        //漲/跌停標記23
        int mark = [self searchArrayWithValue:23];
        
        label.text = [NSString stringWithFormat:@"%.2f",[(NSNumber *)[_fieldDataArray objectAtIndex:todayP]floatValue]];
        int yesterdayP = [self searchArrayWithValue:3];
//        int upDown =  [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
//        if (upDown!=0) {
//            if (upDown == 4) {
//                label.backgroundColor = [UIColor redColor];
//            }else if (upDown == 5){
//                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
//            }
//            label.textColor = [UIColor whiteColor];
//        }else{
        
            if ([(NSNumber *)[_fieldDataArray objectAtIndex:todayP] floatValue]>[(NSNumber *)[_fieldDataArray objectAtIndex:yesterdayP] floatValue]) {
                label.textColor = [UIColor redColor];
                
                //int:4(shortInteger = 100)漲停
                
                if ([(NSNumber *)[_fieldDataArray objectAtIndex:mark]intValue] == 4 && [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:17]]floatValue] == [[_fieldDataArray objectAtIndex:todayP] floatValue]){
                    label.backgroundColor = [UIColor redColor];
                    label.textColor = [UIColor whiteColor];
                }
            }else if ([(NSNumber *)[_fieldDataArray objectAtIndex:todayP]floatValue]<[[_fieldDataArray objectAtIndex:yesterdayP]floatValue]){
                    label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
                
                //int:4(shortInteger = 100)跌停
                if ([(NSNumber *)[_fieldDataArray objectAtIndex:mark]floatValue] == 5 && [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:18]]floatValue] == [[_fieldDataArray objectAtIndex:todayP] floatValue]){
                    label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
                    label.textColor = [UIColor whiteColor];
                }
            }else{
                label.textColor = [UIColor blueColor];
            }
        //}
        if ([(NSNumber *)[_fieldDataArray objectAtIndex:todayP]floatValue]==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex ==3){
        //最高17
        label.text = [NSString stringWithFormat:@"%.2f",[[_fieldDataArray objectAtIndex:[self searchArrayWithValue:17]]floatValue]];
        float height = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:17]]floatValue];
        float yesterdayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:3]] floatValue];
//        float todayP = [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:2]] floatValue];
        
//        int upDown =  [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
//        if (upDown!=0) {
//            if (upDown == 4) {
//                label.backgroundColor = [UIColor redColor];
//                label.textColor = [UIColor whiteColor];
//            }else if (upDown == 5){
//                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
//                label.textColor = [UIColor whiteColor];
//                if (height>todayP) {
//                    label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
//                    label.backgroundColor = [UIColor clearColor];
//                }
//            }
//            
//        }else{
            if (height>yesterdayP) {
                label.textColor = [UIColor redColor];
            }else if (height<yesterdayP){
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else{
                label.textColor = [UIColor blueColor];
            }
        //}
        if (height==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
        
    }else if (columnIndex ==4){
        //最低18
        label.text = [NSString stringWithFormat:@"%.2f",[[_fieldDataArray objectAtIndex:[self searchArrayWithValue:18]]floatValue]];
        float low = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:18]]floatValue];
        float yesterdayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:3]] floatValue];
//        float todayP = [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:2]] floatValue];
        
//        int upDown =  [[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
//        if (upDown!=0) {
//            if (upDown == 4) {
//                label.backgroundColor = [UIColor redColor];
//                label.textColor = [UIColor whiteColor];
//                if (todayP>low) {
//                    label.backgroundColor = [UIColor clearColor];
//                    label.textColor = [UIColor redColor];
//                }
//            }else if (upDown == 5){
//                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
//                label.textColor = [UIColor whiteColor];
//            }
//            
//        }else{
            if (low>yesterdayP) {
                label.textColor = [UIColor redColor];
            }else if (low<yesterdayP){
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else{
                label.textColor = [UIColor blueColor];
            }
        //}
        if (low==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex ==5){
        //漲跌 2,3
        float yesterdayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:3]] floatValue];
        float todayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:2]] floatValue];
        if (todayP !=0) {
            if ((todayP-yesterdayP)>0) {
                label.text = [NSString stringWithFormat:@"+%.2f",(todayP-yesterdayP)];
                label.textColor = [UIColor redColor];
            }else if ((todayP-yesterdayP)<0){
                label.text = [NSString stringWithFormat:@"%.2f",(todayP-yesterdayP)];
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else if ((todayP-yesterdayP)==0){
                label.text = [NSString stringWithFormat:@"0.00"];
                label.textColor = [UIColor blueColor];
            }
        }
        
        
    }else if (columnIndex ==6){
        //漲幅 漲跌/3
        float yesterdayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:3]] floatValue];
        float todayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:2]] floatValue];
        if (todayP !=0) {
            if ((todayP-yesterdayP)>0) {
                float range = floorf((todayP-yesterdayP)/yesterdayP*10000)/ 100;
                label.text = [NSString stringWithFormat:@"+%.2f%%",range];
                label.textColor = [UIColor redColor];
            }else if ((todayP-yesterdayP)<0){
                float range = ceilf((todayP-yesterdayP)/yesterdayP*10000)/ 100;
                label.text = [NSString stringWithFormat:@"%.2f%%",range];
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else if ((todayP-yesterdayP)==0){
                label.text = [NSString stringWithFormat:@"0.00%%"];
                label.textColor = [UIColor blueColor];
            }
        }
    }else if (columnIndex ==7){
        //振幅 ＝ （最高-最低）/參考
        float height = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:17]]floatValue];
        float low = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:18]]floatValue];
        float yesterdayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:3]] floatValue];
        
        if ((height-low) == 0.0f) {
            label.text = [NSString stringWithFormat:@"0.00%%"];
        }else{
            float range = floorf((height-low)/yesterdayP*10000)/ 100;
            label.text = [NSString stringWithFormat:@"%.2f%%",range];
        }
        label.textColor = [UIColor purpleColor];
    }else if (columnIndex ==8){
        //單量44
        int total = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:44]] intValue];
        label.text = [NSString stringWithFormat:@"%d",total];
        label.textColor = [UIColor purpleColor];
        if (total == 0) {
            label.text =@"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex ==9){
        //4總量
        int total = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:4]] intValue];
        label.text = [NSString stringWithFormat:@"%d",total];
        label.textColor = [UIColor purpleColor];
        if (total == 0) {
            label.text =@"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex ==10){
        //16成交總值
        float totalMoney = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:16]] floatValue];
        if(totalMoney>=1000000000){
            totalMoney = totalMoney /1000000000;
            label.text = [NSString stringWithFormat:@"%.3fB",totalMoney];
        }else if (totalMoney>=1000000) {
            totalMoney = totalMoney /1000000;
            label.text = [NSString stringWithFormat:@"%.2fM",totalMoney];
        }else if(totalMoney>=1000){
            totalMoney = totalMoney /1000;
            label.text = [NSString stringWithFormat:@"%.2fK",totalMoney];
        }else{
            totalMoney =floorf(totalMoney*10000)/ 100;
            label.text = [NSString stringWithFormat:@"%f",totalMoney];
        }
        
        label.textColor = [UIColor purpleColor];

    }else if (columnIndex ==11){
        float outValue = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:21]] floatValue];
        float inValue = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:20]] floatValue];
        label.text = [NSString stringWithFormat:@"----"];
        if (_searchKey == 7) {
            //內外盤比
            if (outValue!=0.0f) {
                label.text = [NSString stringWithFormat:@"%.2f",(inValue/outValue)];
                label.textColor = [UIColor blueColor];
            }
            
        }else{
            //外內盤比
            if (inValue!=0.0f) {
                label.text = [NSString stringWithFormat:@"%.2f",(outValue/inValue)];
                label.textColor = [UIColor blueColor];
            }
            
        }
        
        if ([label.text isEqualToString:@"0.00"]) {
            label.text = [NSString stringWithFormat:@"----"];
            label.textColor = [UIColor blackColor];
        }

    }else if (columnIndex ==12){
        //委買賣差
        int buy = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:43]] intValue];
        int sell = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:46]] intValue];
        label.text = [NSString stringWithFormat:@"%d",(buy-sell)];
        if ((buy-sell)>0) {
            label.textColor = [UIColor redColor];
        }else if ((buy-sell)<0){
            label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
        }else{
            label.textColor = [UIColor blueColor];
        }

    }
}

- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"名稱", @"GoodStock", nil)];
}

- (NSArray *)columnsInMainTableView {
    NSArray *retArray = nil;
    retArray = _columnNames;
    return retArray;
}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
    
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    _stockArray = [_dataArray objectAtIndex:indexPath.row];
    
    SymbolFormat1 *symbol1 = [_stockArray objectAtIndex:0];
    
    NewSymbolObject *newSymbol = [NewSymbolObject new];
    newSymbol.identCode = [NSString stringWithFormat:@"%c%c", symbol1 ->IdentCode[0], symbol1->IdentCode[1]];
    newSymbol.symbol = symbol1->symbol;
    newSymbol.fullName = symbol1->fullName;
    newSymbol.typeId = symbol1->typeID;
    
    NSMutableArray *newSymbolArray = [NSMutableArray new];
    [newSymbolArray addObject:newSymbol];
    
    NSString *identCodeSymbol = [NSString stringWithFormat:@"%c%c %@", symbol1->IdentCode[0], symbol1->IdentCode[1], symbol1->symbol];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    
    [dataModel.portfolioData setTarget:self];
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:newSymbolArray];
    
    PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:identCodeSymbol];
    FSInstantInfoWatchedPortfolio *instantInfoWatchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    instantInfoWatchedPortfolio.portfolioItem = portfolioItem;
    
}

-(void)reloadData{
    
    FSMainViewController *mainView = [[FSMainViewController alloc]init];
    [self.navigationController pushViewController:mainView animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
