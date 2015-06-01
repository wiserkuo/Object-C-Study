//
//  SpecialStateViewController.m
//  Bullseye
//
//  Created by Neil on 13/8/28.
//
//

#import "SpecialStateViewController.h"
#import "SpecialStateModel.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface SpecialStateViewController ()

@property (strong, nonatomic) FSUIButton * stateBtn;
@property (strong, nonatomic) UILabel * stateLabel;
@property (strong, nonatomic) SKCustomTableView *mainTableView;

@property (strong, nonatomic) NSArray *categoryArray;
@property (strong, nonatomic) NSArray *columnNames;

@end

@implementation SpecialStateViewController

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
    self.navigationItem.title =NSLocalizedStringFromTable(@"特殊狀態", @"SpecialState", nil);
    _searchNum = 0;
    [self initView];
    [self varInit];
    
    [self.view setNeedsUpdateConstraints];
    
	// Do any additional setup after loading the view.
}

-(void)initView{
    
    self.stateLabel = [[UILabel alloc]init];
    _stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _stateLabel.text = NSLocalizedStringFromTable(@"狀態", @"SpecialState", nil);
    _stateLabel.font = [UIFont systemFontOfSize:24.0f];
    [self.view addSubview:_stateLabel];
    
    self.stateBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    _stateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_stateBtn setTitle:NSLocalizedStringFromTable(@"全部狀態", @"SpecialState", nil) forState:UIControlStateNormal];
    [_stateBtn addTarget:self action:@selector(actionInit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stateBtn];
    
    self.mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:44];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    
    [self.view addSubview:_mainTableView];
    
    [self.view setNeedsUpdateConstraints];
    
    
}


-(void)notifyDataArrive:(NSMutableArray *)array{
    //reload TableView
    if (_searchNum == 0) {
        self.dataArray =[self searchAllDataWithArray:array];

    }else{
        self.dataArray = array;
    }
    [self.view hideHUD];
    if ([array count]==0) {
        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"系統提示", @"SpecialState", nil) message:NSLocalizedStringFromTable(@"無符合個股", @"SpecialState", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"SpecialState", nil) otherButtonTitles:nil];
        [alert show];
    }
    [_mainTableView reloadAllData];
}

-(NSMutableArray *)searchAllDataWithArray:(NSMutableArray *)array{
    self.allDataArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[array count]; i++) {
        _stockArray = [[array objectAtIndex:i] mutableCopy];
        _fieldIdArray = [_stockArray objectAtIndex:2];
        _fieldDataArray = [_stockArray objectAtIndex:3];
        
        int objectInt = [self searchArrayWithValue:27];
        int status =[(NSNumber *)[_fieldDataArray objectAtIndex:objectInt]intValue];
        
        if (status==1 || status==2 ||status==4 ||status==8 ||status==16 ||status==32 ) {
            [_allDataArray addObject:_stockArray];
        }else{
            
            if (status>=32) {
                NSMutableArray * newDataArray = [[NSMutableArray alloc]init];
                newDataArray = [_fieldDataArray mutableCopy];
                NSMutableArray * newStockArray = [[NSMutableArray alloc]init];
                newStockArray = [_stockArray mutableCopy];
                [newDataArray replaceObjectAtIndex:objectInt withObject:[NSNumber numberWithInt:32]];
                [newStockArray replaceObjectAtIndex:3 withObject:newDataArray];
                [_allDataArray addObject:newStockArray];
                status = status -32;
            }
            if (status>=16) {
                NSMutableArray * newDataArray = [[NSMutableArray alloc]init];
                newDataArray = [_fieldDataArray mutableCopy];
                NSMutableArray * newStockArray = [[NSMutableArray alloc]init];
                newStockArray = [_stockArray mutableCopy];
                [newDataArray replaceObjectAtIndex:objectInt withObject:[NSNumber numberWithInt:16]];
                [newStockArray replaceObjectAtIndex:3 withObject:newDataArray];
                [_allDataArray addObject:newStockArray];
                status = status -16;
            }
            if (status>=8) {
                NSMutableArray * newDataArray = [[NSMutableArray alloc]init];
                newDataArray = [_fieldDataArray mutableCopy];
                NSMutableArray * newStockArray = [[NSMutableArray alloc]init];
                newStockArray = [_stockArray mutableCopy];
                [newDataArray replaceObjectAtIndex:objectInt withObject:[NSNumber numberWithInt:8]];
                [newStockArray replaceObjectAtIndex:3 withObject:newDataArray];
                [_allDataArray addObject:newStockArray];
                status = status -8;
            }
            if (status>=4) {
                NSMutableArray * newDataArray = [[NSMutableArray alloc]init];
                newDataArray = [_fieldDataArray mutableCopy];
                NSMutableArray * newStockArray = [[NSMutableArray alloc]init];
                newStockArray = [_stockArray mutableCopy];
                [newDataArray replaceObjectAtIndex:objectInt withObject:[NSNumber numberWithInt:4]];
                [newStockArray replaceObjectAtIndex:3 withObject:newDataArray];
                [_allDataArray addObject:newStockArray];
                status = status -4;
            }
            if (status>=2) {
                NSMutableArray * newDataArray = [[NSMutableArray alloc]init];
                newDataArray = [_fieldDataArray mutableCopy];
                NSMutableArray * newStockArray = [[NSMutableArray alloc]init];
                newStockArray = [_stockArray mutableCopy];
                [newDataArray replaceObjectAtIndex:objectInt withObject:[NSNumber numberWithInt:2]];
                [newStockArray replaceObjectAtIndex:3 withObject:newDataArray];
                [_allDataArray addObject:newStockArray];
                status = status -2;
            }
            if (status>=1) {
                NSMutableArray * newDataArray = [[NSMutableArray alloc]init];
                newDataArray = [_fieldDataArray mutableCopy];
                NSMutableArray * newStockArray = [[NSMutableArray alloc]init];
                newStockArray = [_stockArray mutableCopy];
                [newDataArray replaceObjectAtIndex:objectInt withObject:[NSNumber numberWithInt:1]];
                [newStockArray replaceObjectAtIndex:3 withObject:newDataArray];
                [_allDataArray addObject:newStockArray];
                status = status -1;
            }
        }
    }
    return _allDataArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.specialStateModel setTarget:self];
    [dataModal.specialStateModel performSelector:@selector(showSpecialStateWithState:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchNum] waitUntilDone:NO];
    [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"SpecialState", nil) ];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.specialStateModel setTarget:nil];
    
    [super viewWillDisappear:animated];
}


- (void)varInit {
    
    _categoryArray = [[NSArray alloc] initWithObjects:
                      NSLocalizedStringFromTable(@"全部狀態", @"SpecialState", nil),
                      NSLocalizedStringFromTable(@"處置股票", @"SpecialState", nil),
                      NSLocalizedStringFromTable(@"延後收盤", @"SpecialState", nil),
                      NSLocalizedStringFromTable(@"暫停交易", @"SpecialState", nil),
                      NSLocalizedStringFromTable(@"異常推介", @"SpecialState", nil),
                      NSLocalizedStringFromTable(@"特殊異常", @"SpecialState", nil),
                      nil];
    
    _columnNames = [[NSArray alloc] initWithObjects:
                     NSLocalizedStringFromTable(@"成交", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"狀態", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"暫停", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"恢復", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"最高", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"最低", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"漲跌", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"漲幅", @"SpecialState", nil),
                     NSLocalizedStringFromTable(@"總量", @"SpecialState", nil),
                     nil];

}

- (void)actionInit {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"排序方式", @"SpecialState", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i;
    for (i=0;i<[_categoryArray count];i++) {
        NSString * title = [_categoryArray objectAtIndex:i];
        [actionSheet addButtonWithTitle:title];
    }
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil)];
    [actionSheet setCancelButtonIndex:i];
    [self showActionSheet:actionSheet];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=_searchNum && buttonIndex <[_categoryArray count]) {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中", @"SpecialState", nil)];
        _searchNum = (int)buttonIndex;
        
        //NSLog(@"%d",_searchNum);
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.specialStateModel setTarget:self];
        [dataModal.specialStateModel performSelector:@selector(showSpecialStateWithState:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:self.searchNum] waitUntilDone:NO];
    }
    
    [_stateBtn setTitle:[_categoryArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];

}


- (void)updateViewConstraints {
    
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_stateBtn, _stateLabel, _mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stateLabel(50)]-5-[_stateBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_stateLabel(40)]-5-[_mainTableView]-2-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [super updateViewConstraints];
}

-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    label.textAlignment = NSTextAlignmentCenter;
    
    _stockArray = [_dataArray objectAtIndex:indexPath.row];
    
    SymbolFormat1 * symbol = [[SymbolFormat1 alloc]init];
    symbol = [_stockArray  objectAtIndex:0];
    label.text = [NSString stringWithFormat:@"%@",symbol->fullName];
    label.textColor = [UIColor blueColor];
    
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
        //2
        int todayP = [self searchArrayWithValue:2];
        
        label.text = [NSString stringWithFormat:@"%.2f",[[_fieldDataArray objectAtIndex:todayP]floatValue]];
        int yesterdayP = [self searchArrayWithValue:3];
        int upDown =  [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
        if (upDown!=0) {
            if (upDown == 4) {
                label.backgroundColor = [UIColor redColor];
            }else if (upDown == 5){
                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }
            label.textColor = [UIColor whiteColor];
        }else{
            if ([[_fieldDataArray objectAtIndex:todayP] floatValue]>[[_fieldDataArray objectAtIndex:yesterdayP] floatValue]) {
                label.textColor = [UIColor redColor];
            }else if ([[_fieldDataArray objectAtIndex:todayP]floatValue]<[[_fieldDataArray objectAtIndex:yesterdayP]floatValue]){
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
        if ([[_fieldDataArray objectAtIndex:[self searchArrayWithValue:2]]floatValue]==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex ==1){
        //27
        int status =[(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:27]]intValue];
        if (_searchNum !=0) {
            if (_searchNum == 1) {
                label.text = NSLocalizedStringFromTable(@"處置", @"SpecialState", nil);
            }else if (_searchNum == 2){
                label.text = NSLocalizedStringFromTable(@"延收", @"SpecialState", nil);
            }else if (_searchNum == 3){
                label.text = NSLocalizedStringFromTable(@"暫停交易", @"SpecialState", nil);
            }else if (_searchNum == 4){
                label.text = NSLocalizedStringFromTable(@"異常推介", @"SpecialState", nil);
            }else if (_searchNum == 5){
                label.text = NSLocalizedStringFromTable(@"特殊異常", @"SpecialState", nil);
            }else if (_searchNum == 6){
                label.text = NSLocalizedStringFromTable(@"非10元面額註記", @"SpecialState", nil);
            }
        }else{
            if (status ==1) {
                label.text = NSLocalizedStringFromTable(@"處置", @"SpecialState", nil);
            }else if (status ==2){
                label.text = NSLocalizedStringFromTable(@"延收", @"SpecialState", nil);
            }else if (status ==4){
                label.text = NSLocalizedStringFromTable(@"暫停交易", @"SpecialState", nil);
            }else if (status ==8){
                label.text = NSLocalizedStringFromTable(@"異常推介", @"SpecialState", nil);
            }else if (status ==16){
                label.text = NSLocalizedStringFromTable(@"特殊異常", @"SpecialState", nil);
            }else if (status ==32){
                label.text = NSLocalizedStringFromTable(@"非10元面額註記", @"SpecialState", nil);
            }

        }
                label.textColor = [UIColor blueColor];
        //NSLog(@"%@",[_fieldDataArray objectAtIndex:index]);
    }else if (columnIndex ==2){
        //28
        int stopTime = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:28]]intValue];
        if(stopTime != 0){
            label.text = [NSString stringWithFormat:@"%02d:%02d",stopTime/60,stopTime%60];
            label.textColor = [UIColor blueColor];
        }else{
            label.text = @"----";
        }

    }else if (columnIndex ==3){
        //29
        int restartTime = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:29]]intValue];
        if(restartTime != 0){
            label.text = [NSString stringWithFormat:@"%02d:%02d",restartTime/60,restartTime%60];
            label.textColor = [UIColor blueColor];
        }else{
            label.text = @"----";
        }
    }else if (columnIndex ==4){
        //17
        label.text = [NSString stringWithFormat:@"%.2f",[[_fieldDataArray objectAtIndex:[self searchArrayWithValue:17]]floatValue]];
        float height = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:17]]floatValue];
        float yesterdayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:3]] floatValue];
        float todayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:2]] floatValue];
        
        int upDown =  [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
        if (upDown!=0) {
            if (upDown == 4) {
                label.backgroundColor = [UIColor redColor];
                label.textColor = [UIColor whiteColor];
            }else if (upDown == 5){
                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
                label.textColor = [UIColor whiteColor];
                if (height>todayP) {
                    label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
                    label.backgroundColor = [UIColor clearColor];
                }
            }
            
        }else{
            if (height>yesterdayP) {
                label.textColor = [UIColor redColor];
            }else if (height<yesterdayP){
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
        if (height==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
        
    }else if (columnIndex ==5){
        //18
        label.text = [NSString stringWithFormat:@"%.2f",[[_fieldDataArray objectAtIndex:[self searchArrayWithValue:18]]floatValue]];
        float low = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:18]]floatValue];
        float yesterdayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:3]] floatValue];
        float todayP = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:2]] floatValue];
        
        int upDown =  [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:23]]intValue];
        
        if (upDown!=0) {
            if (upDown == 4) {
                label.backgroundColor = [UIColor redColor];
                label.textColor = [UIColor whiteColor];
                if (todayP>low) {
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor redColor];
                }
            }else if (upDown == 5){
                label.backgroundColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
                label.textColor = [UIColor whiteColor];
            }
            
        }else{
            if (low>yesterdayP) {
                label.textColor = [UIColor redColor];
            }else if (low<yesterdayP){
                label.textColor = [UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
            }else{
                label.textColor = [UIColor blueColor];
            }
        }
        if (low==0.0f) {
            label.text = @"----";
            label.textColor = [UIColor blackColor];
        }
    }else if (columnIndex ==6){
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
        
        
    }else if (columnIndex ==7){
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
    }else if (columnIndex ==8){
        //4
        int total = [(NSNumber *)[_fieldDataArray objectAtIndex:[self searchArrayWithValue:4]] intValue];
        label.text = [NSString stringWithFormat:@"%d",total];
        label.textColor = [UIColor purpleColor];
        if (total == 0) {
            label.text =@"----";
            label.textColor = [UIColor blackColor];
        }
    }
    
    
}

-(int)searchArrayWithValue:(int)value{
    int x=0;
    
    for (int i =0; i<[_fieldIdArray count]; i++) {
        if (value == [(NSNumber *)[_fieldIdArray objectAtIndex:i]intValue]) {
            x=i;
        }
    }
    
    return x;
}
- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"股名", @"SpecialState", nil)];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray * stock = [_dataArray objectAtIndex:indexPath.row];
    SymbolFormat1 * symbol = [[SymbolFormat1 alloc]init];
    symbol = [stock  objectAtIndex:0];
    FSMainViewController *instantInfoMainViewController = [[FSMainViewController alloc] init];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSString * symbolStr =[NSString stringWithFormat:@"%c%c %@",symbol->IdentCode[0],symbol->IdentCode[1],symbol->symbol];
        [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
    PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:[NSString stringWithFormat:@"%c%c %@",symbol->IdentCode[0],symbol->IdentCode[1],symbol->symbol]];
    if (portfolioItem != nil) {
        FSInstantInfoWatchedPortfolio * watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        watchedPortfolio.portfolioItem = portfolioItem;
        
        [self.navigationController pushViewController:instantInfoMainViewController animated:YES];
    }
    
}



@end
