//
//  AmericaEditConditionViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/14.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "AmericaEditConditionViewController.h"
#import "TextFieldTableViewCell.h"
#import "FSWatchlistPortfolioItem.h"
#import "FSUIButton.h"

@interface AmericaEditConditionViewController ()

@property (strong) UILabel * label;


@property (strong) NSMutableArray * columnNames;

@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;

@property (nonatomic,strong) TextFieldTableViewCell * editCell;

@property (nonatomic,strong) FSUIButton * closeBtn;

@property (nonatomic,strong) NSRecursiveLock *datalock;

@property (nonatomic) float offsetY;

@property (nonatomic, strong) FSDataModelProc *dataModel;

@end

@implementation AmericaEditConditionViewController

//@synthesize alertData;

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
    _dataModel = [FSDataModelProc sharedInstance];
    self.datalock = [[NSRecursiveLock alloc] init];
    [self initView];
    [self varInit];
    [self registerForKeyboardNotifications];
	// Do any additional setup after loading the view.
}

-(void)initView{
    self.dataArray = [[NSMutableArray alloc]init];
    
    self.mainTableView = [[UITableView alloc] init];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.bounces = NO;

    
    [_mainTableView setEditing:YES animated:NO];
    _mainTableView.allowsSelectionDuringEditing = YES;
    
    
    [self.view addSubview:_mainTableView];
    
    self.label = [[UILabel alloc]init];//WithFrame:CGRectMake(170, 0, 70, 30)];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.text = NSLocalizedStringFromTable(@"警示", @"SecuritySearch", nil);
    _label.font = [UIFont boldSystemFontOfSize:18.0f];
    _label.textColor = [UIColor whiteColor];
    _label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_label];
    
    self.closeBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _closeBtn.translatesAutoresizingMaskIntoConstraints = YES;
    [_closeBtn setFrame: CGRectMake(240, self.view.frame.size.height-361, 70, 30)];
    [_closeBtn addTarget:self action:@selector(closeKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setTitle:NSLocalizedStringFromTable(@"關閉", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [self.view addSubview:_closeBtn];
    _closeBtn.hidden = YES;
    
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.watchlistItem = [[FSWatchlistPortfolioItem alloc] init];
    _closeBtn.hidden = YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSLocalizedStringFromTable(@"刪除", @"SecuritySearch", nil);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	if(fromIndexPath.row != toIndexPath.row)
	{
		[[[FSDataModelProc sharedInstance]portfolioData] moveWatchList:(int)fromIndexPath.row ToRowIndex:(int)toIndexPath.row];
        [[[FSDataModelProc sharedInstance]portfolioData]  reSetNewWatchListToDB];
	}
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		PortfolioItem *item = [[[FSDataModelProc sharedInstance]portfolioData] getItemAt:(int)indexPath.row];
		int beforeRemovePortfolioCount = [[[FSDataModelProc sharedInstance]portfolioData] getCount];
		[[[FSDataModelProc sharedInstance]portfolioData] RemoveItem:item->identCode andSymbol:item->symbol];
		int afterRemovePortfolioCount = [[[FSDataModelProc sharedInstance]portfolioData] getCount];
		
		if(beforeRemovePortfolioCount-1 != afterRemovePortfolioCount) // 刪除兩個以上identcode symbol相同的商品 (特例情況)
		{
			[_mainTableView reloadData];
		}
		
		else // 正常情況
		{
			[_mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
			[_mainTableView reloadData];
            //			[self showValueAddedInfo];
		}
		
	}

}

- (void)updateViewConstraints {
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings( _mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
  
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_mainTableView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_mainTableView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:35]];

      [super updateViewConstraints];
}


- (void)varInit {
    
    self.columnNames = [[NSMutableArray alloc] initWithObjects:
                        NSLocalizedStringFromTable(@"股名", @"SecuritySearch", nil),
                        NSLocalizedStringFromTable(@"獲利", @"SecuritySearch", nil),
                        NSLocalizedStringFromTable(@"停損", @"SecuritySearch", nil),
                        NSLocalizedStringFromTable(@"移動", @"SecuritySearch", nil),
                        nil];
}


// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [_dataArray count];
    return [_watchlistItem count];
}

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"cellIdentifier";
    PortfolioItem * item = [_watchlistItem portfolioItem:indexPath];

    
    TextFieldTableViewCell * cell = (TextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.tag = indexPath.row;
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        cell.label.text =  item->symbol;
    }
    else {
        cell.label.text =  item->fullName;
    }
    
    cell.indexPath = indexPath;
    NSMutableArray * dataArray = [_dataModel.alert findAlertDataByIdentSybmol:[item getIdentCodeSymbol]];
    
    if ([dataArray count]>0) {
        if ([_dataModel.alert findAlertDataByAlertID:profitAlert DataArray:dataArray ]!=nil) {
            NSMutableDictionary * data = [[_dataModel alert] findAlertDataByAlertID:profitAlert DataArray:dataArray];
            cell.profitTextField.text = [NSString stringWithFormat:@"%.2f",[[data objectForKey:@"alertValue"]floatValue]];
        }
        if ([[_dataModel alert] findAlertDataByAlertID:lostAlert DataArray:dataArray]!=nil) {
            NSMutableDictionary * data = [[_dataModel alert] findAlertDataByAlertID:lostAlert DataArray:dataArray];
            cell.lostTextField.text = [NSString stringWithFormat:@"%.2f",[[data objectForKey:@"alertValue"]floatValue]];
        }
    }
    return cell;
}

-(void)cellTextChangeWithCell:(TextFieldTableViewCell *)cell TextField:(UITextField *)text{
    //NSLog(@"%d,%d",cell.tag,text.tag);
    PortfolioItem * item = [_watchlistItem portfolioItem:cell.indexPath];
    NSMutableArray * dataArray = [[_dataModel alert] findAlertDataByIdentSybmol:[item getIdentCodeSymbol]];
    NSMutableDictionary * insertData = [[NSMutableDictionary alloc]init];
    [insertData setObject:[NSNumber numberWithFloat:[text.text floatValue]] forKey:@"alertValue"];
    
    if (text.tag == 0) { //獲利
        if ([[_dataModel alert] findAlertDataByAlertID:profitAlert DataArray:dataArray]!=nil) {
            [[_dataModel alert] removeAlertByAlertID:profitAlert InIdentCodeSymbol:[item getIdentCodeSymbol]];
        }
            [insertData setObject:[NSNumber numberWithInt:profitAlert] forKey:@"alertId"];
        
    }else{ //停損
        if ([[_dataModel alert] findAlertDataByAlertID:lostAlert DataArray:dataArray]!=nil) {
            [[_dataModel alert] removeAlertByAlertID:lostAlert InIdentCodeSymbol:[item getIdentCodeSymbol]];
        }
             [insertData setObject:[NSNumber numberWithInt:lostAlert] forKey:@"alertId"];

    }
    if (![text.text isEqualToString:@""]) {
        [[_dataModel alert] addNewAlertData:insertData InIdentCodeSymbol:[item getIdentCodeSymbol]];
    }
	[[[FSDataModelProc sharedInstance]alert] performSelector:@selector(saveAlertDataToFile) onThread:[[FSDataModelProc sharedInstance]thread] withObject:nil waitUntilDone:NO];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    UIView *mainTableHeader = [[UIView alloc] init];
    mainTableHeader.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
    
    for (int i = 0; i < [_columnNames count]; i++) {
        
        UILabel *label = [[UILabel alloc] init];
        if (i==0) {
            label.Frame=CGRectMake(0, 0, 110, 44);
        }else if (i==1){
            label.Frame=CGRectMake(120, 0, 70, 44);
        }else if (i==2){
            label.Frame=CGRectMake(200, 0, 70, 44);
        }else if (i==3){
            label.Frame=CGRectMake(260, 0, 70, 44);
        }
        
        label.numberOfLines = 2;
        [label setAdjustsFontSizeToFitWidth:YES];
        label.lineBreakMode = NSLineBreakByCharWrapping;
        if (i ==0) {
            label.backgroundColor = [UIColor colorWithRed: 0.0/255.0 green: 78.0/255.0 blue: 162.0/255.0 alpha: 1.0];
        }else{
            label.backgroundColor = [UIColor clearColor];
        }
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text =[NSString stringWithFormat:@"\n%@",[_columnNames objectAtIndex:i]];
        [mainTableHeader addSubview:label];
    }
    
    return mainTableHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)cellBeginEditWithCell:(TextFieldTableViewCell *)cell{
    
    self.editCell = cell;
    _closeBtn.hidden = NO;
}

-(void)closeKeyBoard{
    [self.editCell.lostTextField resignFirstResponder];
    [self.editCell.profitTextField resignFirstResponder];
    _closeBtn.hidden = YES;
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    [_datalock lock];
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    _offsetY = 0;
    if ( self.editCell.frame.origin.y+aRect.origin.y>aRect.size.height ) {
        _offsetY = _mainTableView.contentOffset.y;
        [self.mainTableView setContentOffset:CGPointMake(_mainTableView.contentOffset.x, self.editCell.frame.origin.y-70) animated:YES];
    }

    [_datalock unlock];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [_datalock lock];
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    _mainTableView.contentInset = contentInsets;
//    _mainTableView.scrollIndicatorInsets = contentInsets;
    [self.mainTableView setContentOffset:CGPointMake(0, _offsetY) animated:YES];
    [_datalock unlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
