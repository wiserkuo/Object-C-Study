//
//  FSPositionInformationViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/7/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSPositionInformationViewController.h"
#import "FSActionPlanDatabase.h"
#import "UIViewController+CustomNavigationBar.h"

@interface FSPositionInformationViewController () <UIAlertViewDelegate>
@property (strong, nonatomic) FSUIButton *longButton;
@property (strong, nonatomic) FSUIButton *shortButton;
@property (strong, nonatomic) NSMutableArray *positionInfoArray;
@property (strong, nonatomic) UIGestureRecognizer *tap;
@property (nonatomic) float count;
@end

@implementation FSPositionInformationViewController

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
	// Do any additional setup after loading the view.
    [self setUpImageBackButton];
    [self setupNavigationBar];
    [self initOptionButton];
    [self initData];
    [self initTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData{
    if ([_termStr isEqualToString:@"Long"]) {
        _longButton.selected = YES;
        _shortButton.selected = NO;
        _positionInfoArray = [[NSMutableArray alloc] init];
        _positionInfoArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:_termStr Symbol:_symbolStr];
    }else{
        _longButton.selected = NO;
        _shortButton.selected = YES;
        _positionInfoArray = [[NSMutableArray alloc] init];
        _positionInfoArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:_termStr Symbol:_symbolStr];
    }

    [_tableView reloadAllData];
}

#pragma mark - Set up Navigation
-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Trade History", @"Launcher", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];

    self.navigationItem.hidesBackButton = YES;
}

-(void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Set up Views
-(void)initOptionButton{
    _longButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _longButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_longButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _longButton.selected = YES;
    [_longButton setTitle:NSLocalizedStringFromTable(@"多方選股形勢", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_longButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_longButton];
    
    _shortButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _shortButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_shortButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shortButton setTitle:NSLocalizedStringFromTable(@"空方選股形勢", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_shortButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shortButton];
}

-(void)initTableView{
    self.tableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:90 mainColumnWidth:90 AndColumnHeight:44];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_longButton, _shortButton, _tableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_longButton][_shortButton(_longButton)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_longButton(44)][_tableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_shortButton(44)]" options:0 metrics:nil views:viewController]];
}

#pragma mark - Button click action
-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:_longButton]) {
        _shortButton.selected = NO;
        _longButton.selected = YES;
        _positionInfoArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Long" Symbol:_symbolStr];
    }else{
        _shortButton.selected = YES;
        _longButton.selected = NO;
        _positionInfoArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:@"Short" Symbol:_symbolStr];
    }
    [_tableView reloadAllData];
}

#pragma mark - Set Up Table View Cell
-(void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate * date = [formatter dateFromString:[[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Date"]];
#ifdef LPCB
    [formatter setDateFormat:@"MM/dd/yyyy"];
#else
    [formatter setDateFormat:@"yyyy/MM/dd"];
#endif
    
    NSString * dateStr = [formatter stringFromDate:date];
    
    label.text = dateStr;
}

-(void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (columnIndex == 0) {
        NSString *string = [[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Symbol"];
        NSString *identCode = [string substringToIndex:2];
        NSString *symbol = [string substringFromIndex:3];
        NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
        NSString *appid = [FSFonestock sharedInstance].appId;
        NSString *group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"]) {
            label.text = symbol;
        }else {
            label.text = fullName;
        }
    }
    if (columnIndex == 1) {
        NSString *dealStr = [[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Deal"];
        label.text = NSLocalizedStringFromTable(dealStr, @"Trade", nil);
    }
    if (columnIndex == 2) {
        if ([[[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Deal"] isEqualToString:@"BUY"]|| [[[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Deal"] isEqualToString:@"SHORT"]) {
            label.text = [NSString stringWithFormat:@"+%@", [[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Count"]];
        }else{
            label.text = [NSString stringWithFormat:@"%@", [[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Count"]];
        }
    }
    if (columnIndex == 3) {
        label.text = [CodingUtil CoverFloatWithComma:[[[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Price"] floatValue] DecimalPoint:2];
    }
    if (columnIndex == 4) {
        label.textAlignment = NSTextAlignmentRight;
        if ([[[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Deal"] isEqualToString:@"BUY"]) {
            label.text = [CodingUtil CoverFloatWithComma:[[[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Amount"] floatValue]*-1 DecimalPoint:0];
            
        }else{
            label.text = [CodingUtil CoverFloatWithComma:fabs([[[_positionInfoArray objectAtIndex:indexPath.row] objectForKey:@"Amount"] floatValue]) DecimalPoint:0];
        }
    }
    if (columnIndex == 5) {
        label.frame = CGRectMake(label.frame.origin.x + 25, 0, 44, 44);
        label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"RedDeleteButton"]];
        label.tag = indexPath.row;
        label.userInteractionEnabled = YES;
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTap:)];
        [label addGestureRecognizer:_tap];
    }
}

-(void)deleteTap:(UITapGestureRecognizer *)sender{
    UILabel * label =(UILabel *)sender.view;
    _tap = sender;
    _count = label.tag;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"Delete?", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ActionPlan", nil) otherButtonTitles:NSLocalizedStringFromTable(@"OK", @"Trade", nil), nil];
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        for (int i = _count; i < [_positionInfoArray count]; i++) {
            if ([(NSNumber *)[[_positionInfoArray objectAtIndex:_count] objectForKey:@"Count"] floatValue] > [(NSNumber *)[[_positionInfoArray objectAtIndex:i] objectForKey:@"TotalCount"] floatValue]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"總買進數量需大於總賣出數量，請確認刪除動作", @"ActionPlan", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                return;
            }
        }
        [[FSActionPlanDatabase sharedInstances] deletePositionsWithrowid:[[_positionInfoArray objectAtIndex:_count] objectForKey:@"rowid"]];
        _positionInfoArray = [[FSActionPlanDatabase sharedInstances] searchPositionWithTerm:_termStr Symbol:_symbolStr];
        [_tableView reloadDataNoOffset];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_positionInfoArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Table View Columns Name
-(NSArray *)columnsInFixedTableView{
    return @[NSLocalizedStringFromTable(@"Date", @"ActionPlan", nil)];
}

-(NSArray *)columnsInMainTableView{
    return @[NSLocalizedStringFromTable(@"Symbol", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Action", @"ActionPlan", nil), NSLocalizedStringFromTable(@"QTY", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Price", @"ActionPlan", nil), NSLocalizedStringFromTable(@"Total", @"ActionPlan", nil), NSLocalizedStringFromTable(@"", @"ActionPlan", nil)];
}

@end
