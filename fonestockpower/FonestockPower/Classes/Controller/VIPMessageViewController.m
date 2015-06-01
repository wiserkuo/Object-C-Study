//
//  VIPMessageViewController.m
//  Bullseye
//
//  Created by Neil on 13/8/28.
//
//

#import "VIPMessageViewController.h"
#import "MessageDetailViewController.h"
#import "VIPMessage.h"

@interface VIPMessageViewController ()

@property (strong, nonatomic) UITableView *mainTableView;

@property (strong)NSMutableArray * titleArray;
@property (strong)NSMutableArray * contentArray;
@property (strong)NSMutableArray * subTitleArray;
@property (strong)NSMutableArray * readArray;
@property (nonatomic)int longPressRow;

@end

@implementation VIPMessageViewController

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
    self.navigationItem.title =NSLocalizedStringFromTable(@"神乎飛信", @"VIPMessage", nil);

    [self initTableView];
    
    [self.view setNeedsUpdateConstraints];
    
	// Do any additional setup after loading the view.
}

-(void)initTableView{
    self.mainTableView = [[UITableView alloc] init];
    _mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    [self.view addSubview:_mainTableView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    [self.mainTableView addGestureRecognizer:longPress];
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.mainTableView];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        NSIndexPath *indexPath = [self.mainTableView indexPathForRowAtPoint:p];
        if (indexPath != nil){
            _longPressRow = (int)indexPath.row;
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"刪除", @"VIPMessage", nil) message:NSLocalizedStringFromTable(@"是否確定刪除", @"VIPMessage", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"VIPMessage", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"VIPMessage", nil), nil];
            [alert show];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {        
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.vipMessage performSelector:@selector(deleteMessage:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_longPressRow] waitUntilDone:NO];
    }
}

- (void)notifyArrive:(NSArray *)array{
    
    _titleArray = [array objectAtIndex:0];
    _contentArray = [array objectAtIndex:1];
    _subTitleArray = [array objectAtIndex:2];
    _readArray = [array objectAtIndex:3];
    [_mainTableView reloadData];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.vipMessage initDatabase];
    [dataModal.vipMessage setTarget:self];
    [dataModal.vipMessage vipSNQueryOut];
    [dataModal.vipMessage performSelector:@selector(showVIPMessageTitle) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.vipMessage setTarget:nil];
    
    [super viewWillDisappear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageDetailViewController * messageDetailView = [[MessageDetailViewController alloc]initWithTitle:[_titleArray objectAtIndex:indexPath.row] content:[_contentArray objectAtIndex:indexPath.row]];
    
    int row = (int)indexPath.row;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.vipMessage performSelector:@selector(setRead2:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:row] waitUntilDone:NO];
    
    [self.navigationController pushViewController:messageDetailView animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    
    cell.textLabel.text = [_titleArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [_subTitleArray objectAtIndex:indexPath.row];
    if ([(NSNumber *)[_readArray objectAtIndex:indexPath.row] intValue] != 0) {
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.textLabel.numberOfLines = 2;
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel * numberLabel=[[UILabel alloc] init];
    numberLabel.frame=CGRectMake(0, 0, 150, 25);
    numberLabel.text=[NSString stringWithFormat:@"%d/100", (int)[_titleArray count]];
    numberLabel.font=[UIFont boldSystemFontOfSize:20];
    numberLabel.textAlignment=NSTextAlignmentCenter;
    return numberLabel;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0f;
}



- (void)updateViewConstraints {
    
    
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainTableView]-49-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:0 metrics:nil views:viewControllers]];
    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
