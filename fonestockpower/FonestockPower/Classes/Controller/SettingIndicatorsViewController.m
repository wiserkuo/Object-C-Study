//
//  NewViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/11/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "SettingIndicatorsViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "DDPageControl.h"
#import "settingIndicatorsTableViewCell.h"
#import "FSUIButton.h"
#import "ChangeStockViewController.h"
#import "TermExplainWebViewController.h"
#import "TextFieldTableViewDelegate.h"
#import "IndicatorParameterUrlCenter.h"


@interface SettingIndicatorsViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,TextFieldTableViewDelegate,IndicatorParameterUrlCenterDelegate,FSSettingIndicatorsTableViewCellDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableDictionary * dictionary;
@property (strong, nonatomic) FSDataModelProc * dataModal;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DDPageControl *pageControl;

@property (unsafe_unretained, nonatomic) NSInteger numberOfPages;
@property (unsafe_unretained, nonatomic) NSInteger selectedOptionIndex;


@property (strong, nonatomic) UIView * settingHeaderView;
@property (strong, nonatomic) UIView * settingView;
@property (strong, nonatomic) UITableView * settingTableView;
@property (strong, nonatomic) UIView * webUrlView;
@property (strong, nonatomic) UITableView * webUrlTableView;


@property (strong,nonatomic) settingIndicatorsTableViewCell *editCell;

@property (strong, nonatomic) NSMutableDictionary * dataDictionary;

@property (nonatomic,strong) FSUIButton * closeBtn;
@property (nonatomic) float offsetY;

@property (strong, nonatomic) UIAlertView *inputAlert;
@property (strong, nonatomic) UITextField *targetTextField;
@property (strong, nonatomic) NSMutableArray *storeCellTitle;
@property (nonatomic) NSInteger storeCellTag;
@property (nonatomic) NSInteger storeBtnTag;

@end

@implementation SettingIndicatorsViewController

/*
從cache 裡的indicatorParameterTable.plist裡讀取每個參數欄位的數值，將該plist的值暫存在_dataModel.indicator
 而從FSDataModelProc 內的property 都是readonly ，所以須改值會透過
 -(void)changeValueByKey:(NSString *)key Type:(NSString *)type Value:(NSNumber *)value
 key 值是各個指標的name (非fullName)
 type 為 @"dayLine",@"weekLine",@"monthLine",@"minuteLine" 這四個裡其中一個
 value 則是使用者輸入的值
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpImageBackButton];
    
    self.dictionary = [[NSMutableDictionary alloc]init];
    self.dataDictionary = [[NSMutableDictionary alloc]init];
    self.storeCellTitle = [[NSMutableArray alloc] init];
    self.dataModal = [FSDataModelProc sharedInstance];
    self.view.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:252.0f/255.0f blue:247.0f/255.0f alpha:1.0f];

    [self initScrollView];
    [self initPageControl];
    [self initTableView];
    
    [self registerForKeyboardNotifications];
    [self setLayout];
//    [self getUrl];
    [self searchData];
//    self.closeBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
//    _closeBtn.translatesAutoresizingMaskIntoConstraints = YES;
//    [_closeBtn setFrame: CGRectMake(240, self.view.frame.size.height-311, 70, 30)];
//    [_closeBtn addTarget:self action:@selector(closeKeyBoard) forControlEvents:UIControlEventTouchUpInside];
//    [_closeBtn setTitle:NSLocalizedStringFromTable(@"關閉", @"SecuritySearch", nil) forState:UIControlStateNormal];
//    [self.view addSubview:_closeBtn];
//    _closeBtn.hidden = YES;
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.title =NSLocalizedStringFromTable(@"設定指標參數", @"Draw", nil);
}

-(void)getUrl{
    
    IndicatorParameterUrlCenter * urlCenter = [IndicatorParameterUrlCenter sharedInstance];
    urlCenter.delegate = self;
    [urlCenter IndicatorParameterUrlUpWithTime:[_dataModal.indicator getTimeFromIndicatorParameterUrlTable]];
}

- (void)setLayout {
    
    //[self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]-22-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[settingTableView]|" options:0 metrics:nil views:_dictionary]];
    
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[settingTableView]|" options:0 metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webUrlTableView]|" options:0 metrics:nil views:_dictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webUrlTableView]|" options:0 metrics:nil views:_dictionary]];

}

- (void)viewDidLayoutSubviews {
    
    
    [self.scrollView setContentSize: CGSizeMake(self.scrollView.bounds.size.width * self.numberOfPages, self.scrollView.bounds.size.height)];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * 1, 0);
    
    [self.pageControl setCenter:CGPointMake(self.scrollView.center.x, self.view.bounds.size.height - 10)];
    
    [self.settingView setFrame:CGRectMake(self.scrollView.bounds.size.width * 1, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.webUrlView setFrame:CGRectMake(self.scrollView.bounds.size.width * 0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    
    [self.view layoutSubviews];
}


- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:self.scrollView];
}

- (void)initPageControl {
    self.numberOfPages = 2;
    self.pageControl = [[DDPageControl alloc] init];
    self.pageControl.numberOfPages = self.numberOfPages;
    self.pageControl.currentPage = 0;
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor redColor]];
	[self.pageControl setOffColor: [UIColor redColor]];
	[self.pageControl setIndicatorDiameter: 7.0f] ;
	[self.pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:self.pageControl];
}

-(void)initTableView{
    self.settingView = [[UIView alloc]init];
    [self.scrollView addSubview:_settingView];
    self.webUrlView = [[UIView alloc]init];
    [self.scrollView addSubview:_webUrlView];
    
    self.settingTableView = [[UITableView alloc]init];
    _settingTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _settingTableView.dataSource = self;
    _settingTableView.delegate = self;
    _settingTableView.bounces = NO;
    [_dictionary setObject:_settingTableView forKey:@"settingTableView"];
    [_settingView addSubview:_settingTableView];
    
    self.webUrlTableView = [[UITableView alloc]init];
    _webUrlTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _webUrlTableView.dataSource = self;
    _webUrlTableView.delegate = self;
    _webUrlTableView.bounces = NO;
    [_dictionary setObject:_webUrlTableView forKey:@"webUrlTableView"];
    [_webUrlView addSubview:_webUrlTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataDictionary count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellIdentifier";
    
    if(_storeCellTitle.count == 0){
        _storeCellTitle = [_dataModal.indicator keyArray];
    }
    if ([tableView isEqual:_settingTableView]) {
        
        settingIndicatorsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell = [[settingIndicatorsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
        cell.delegate = self;
        cell.delegateForClicked = self;
        cell.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:252.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
        
        NSMutableArray * nameArray = [_dataModal.indicator keyArray];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString * key = [nameArray objectAtIndex:indexPath.row];
        NSMutableDictionary * data = [_dataDictionary objectForKey:key];
        cell.titleLabel.text = [data objectForKey:@"name"];
        NSDictionary * dic = [[NSDictionary alloc]initWithDictionary:[_dataModal.indicator getDictionaryByKey:[nameArray objectAtIndex:indexPath.row]]];
        
        cell.dayTextField.text = [[dic objectForKey:@"dayLine"] stringValue];
        cell.weekTextField.text = [[dic objectForKey:@"weekLine"]stringValue];
        cell.monthTextField.text = [[dic objectForKey:@"monthLine"]stringValue];
        cell.minuteTextField.text = [[dic objectForKey:@"minuteLine"]stringValue];
        cell.tag = indexPath.row;
        return cell;
    }else if ([tableView isEqual:_webUrlTableView]){
        FSUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell = [[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:252.0f/255.0f blue:247.0f/255.0f alpha:1.0f];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSMutableArray * nameArray = [_dataModal.indicator keyArray];
        NSString * key = [nameArray objectAtIndex:indexPath.row];
        NSMutableDictionary * data = [_dataDictionary objectForKey:key];
        if (data) {
            cell.textLabel.text = [data objectForKey:@"fullName"];
            
        }
        
        return cell;
    }else{
        return NULL;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_webUrlTableView]) {
        //設定參數連結網頁
//        NSMutableArray * nameArray = [_dataModal.indicator keyArray];
//        NSString * key = [nameArray objectAtIndex:indexPath.row];
//        NSMutableDictionary * data = [_dataDictionary objectForKey:key];
        
//        TermExplainWebViewController * termExplainWebView = [[TermExplainWebViewController alloc]initWithWebUrl:[data objectForKey:@"url"]];
        
//        [self.navigationController pushViewController:termExplainWebView animated:YES];
        
        
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    self.settingHeaderView = [[UIView alloc]init];
    _settingHeaderView.frame=CGRectMake(0, 0, tableView.frame.size.width, 40);
    if ([tableView isEqual:_settingTableView]) {
        
        _settingHeaderView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:138.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
        
        UILabel * targetLabel=[[UILabel alloc] init];
        targetLabel.translatesAutoresizingMaskIntoConstraints = NO;
        targetLabel.text = NSLocalizedStringFromTable(@"指標", @"FigureSearch", nil);
        targetLabel.backgroundColor = [UIColor clearColor];
        targetLabel.textAlignment = NSTextAlignmentCenter;
        targetLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [_dictionary setObject:targetLabel forKey:@"targetLabel"];
        [_settingHeaderView addSubview:targetLabel];
        
        UILabel * dayLineLabel=[[UILabel alloc] init];
        dayLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        dayLineLabel.text = NSLocalizedStringFromTable(@"Daily", @"Draw", nil);
        dayLineLabel.backgroundColor = [UIColor clearColor];
        dayLineLabel.textAlignment = NSTextAlignmentCenter;
        dayLineLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [_dictionary setObject:dayLineLabel forKey:@"dayLineLabel"];
        [_settingHeaderView addSubview:dayLineLabel];
        
        UILabel * weekLineLabel=[[UILabel alloc] init];
        weekLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        weekLineLabel.text = NSLocalizedStringFromTable(@"Weekly", @"Draw", nil);
        weekLineLabel.backgroundColor = [UIColor clearColor];
        weekLineLabel.textAlignment = NSTextAlignmentCenter;
        weekLineLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [_dictionary setObject:weekLineLabel forKey:@"weekLineLabel"];
        [_settingHeaderView addSubview:weekLineLabel];
        
        UILabel * monthLineLabel=[[UILabel alloc] init];
        monthLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        monthLineLabel.text = NSLocalizedStringFromTable(@"Monthly", @"Draw", nil);
        monthLineLabel.backgroundColor = [UIColor clearColor];
        monthLineLabel.textAlignment = NSTextAlignmentCenter;
        monthLineLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [_dictionary setObject:monthLineLabel forKey:@"monthLineLabel"];
        [_settingHeaderView addSubview:monthLineLabel];
        
        UILabel * minuteLineLabel=[[UILabel alloc] init];
        minuteLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        minuteLineLabel.text = NSLocalizedStringFromTable(@"Minutely", @"Draw", nil);
        minuteLineLabel.backgroundColor = [UIColor clearColor];
        
        minuteLineLabel.textAlignment = NSTextAlignmentCenter;
        minuteLineLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [_dictionary setObject:minuteLineLabel forKey:@"minuteLineLabel"];
        [_settingHeaderView addSubview:minuteLineLabel];
        [self setHeader];
    }else{
        _settingHeaderView.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:252.0f/255.0f blue:247.0f/255.0f alpha:1.0f];
    }

    return _settingHeaderView;
}

-(void)setHeader{
    [self.settingHeaderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[targetLabel(35)]" options:0 metrics:nil views:_dictionary]];
    [self.settingHeaderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[targetLabel(75)][dayLineLabel][weekLineLabel(==dayLineLabel)][monthLineLabel(==dayLineLabel)][minuteLineLabel(==dayLineLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:_dictionary]];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35.0f;

    
}

#pragma marks cell button call back method
-(void)textFieldBeClicked:(UITextField *)targetTextField cellTag:(NSInteger)cellTag textFieldTag:(NSInteger)textFieldTag
{
    _targetTextField = targetTextField;
    _storeCellTag = cellTag;
    _storeBtnTag = textFieldTag;
    NSArray *headerArray = @[
                             NSLocalizedStringFromTable(@"日線", @"Draw", nil),NSLocalizedStringFromTable(@"週線", @"Draw", nil),
                             NSLocalizedStringFromTable(@"月線", @"Draw", nil),NSLocalizedStringFromTable(@"分線", @"Draw", nil)];
    NSString *alertTitle = [NSString stringWithFormat:@"%@   %@",[[_dataDictionary objectForKey:[_storeCellTitle objectAtIndex:cellTag]] objectForKey:@"name"],[headerArray objectAtIndex:textFieldTag]];
    [self wakeTheInputCheckAlert:alertTitle];
}

-(void)wakeTheInputCheckAlert:(NSString *)alertTitle
{
    _inputAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(alertTitle, @"Draw", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Draw", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"Draw", nil), nil];
    [_inputAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [_inputAlert textFieldAtIndex:0].delegate = self;
    [[_inputAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[_inputAlert textFieldAtIndex:0] becomeFirstResponder];
    [_inputAlert textFieldAtIndex:0].placeholder = _targetTextField.text;
    [_inputAlert show];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField == [_inputAlert textFieldAtIndex:0]){
        if(newStr.length > 3){
            return NO;
        }
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == _inputAlert && buttonIndex == 1){
        if([(NSNumber *)[alertView textFieldAtIndex:0].text intValue] > 0){
            _targetTextField.text = [alertView textFieldAtIndex:0].text;
            [self storeUserInput:[alertView textFieldAtIndex:0].text];
        }else{
            [FSHUD showMsg:NSLocalizedStringFromTable(@"請輸入大於零的數字", @"Draw", nil)];
        }
    }else if(alertView == _inputAlert && buttonIndex ==0){
        return;
    }
}

-(void)storeUserInput:(NSString *)insertData;
{
    NSArray *headerArray = @[@"dayLine",@"weekLine",@"monthLine",@"minuteLine"];
    
    [_dataModal.indicator changeValueByKey:[_storeCellTitle objectAtIndex:_storeCellTag] Type:[headerArray objectAtIndex:_storeBtnTag] Value:[NSNumber numberWithInt:[insertData intValue]]];
}

#pragma marks indicators cell call back method
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)indicatorsCellBeginEditWithCell:(settingIndicatorsTableViewCell *)cell{
    
    self.editCell = cell;
}

-(void)indicatorsCellTextChangeWithCell:(settingIndicatorsTableViewCell *)cell TextField:(UITextField *)textField{
    NSString * type = @"";
    if (textField.tag==0) {
        type = @"dayLine";
    }else if (textField.tag == 1){
        type = @"weekLine";
    }else if (textField.tag == 2){
        type = @"monthLine";
    }else if (textField.tag == 3){
        type = @"minuteLine";
    }
    
    [_dataModal.indicator changeValueByKey:cell.titleLabel.text Type:type Value:[NSNumber numberWithInt:[textField.text intValue]]];
    
}

-(void)closeKeyBoard{
    [self.editCell.dayTextField resignFirstResponder];
    [self.editCell.weekTextField resignFirstResponder];
    [self.editCell.monthTextField resignFirstResponder];
    [self.editCell.minuteTextField resignFirstResponder];
//    _closeBtn.hidden = YES;
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    _offsetY = 0;
    if ( self.editCell.frame.origin.y+aRect.origin.y>aRect.size.height ) {
        _offsetY = _settingTableView.contentOffset.y;
        [self.settingTableView setContentOffset:CGPointMake(_settingTableView.contentOffset.x, self.editCell.frame.origin.y-80) animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    _settingTableView.contentInset = contentInsets;
//    _settingTableView.scrollIndicatorInsets = contentInsets;
//    [self.settingTableView setContentOffset:CGPointMake(0, _offsetY) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
	CGFloat pageWidth = self.scrollView.bounds.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
	
	if (self.pageControl.currentPage != nearestNumber) {
		self.pageControl.currentPage = nearestNumber;
		if (self.scrollView.dragging) {
            
			[self.pageControl updateCurrentPageDisplay] ;
            if (nearestNumber==0) {
                [self closeKeyBoard];
            }
        }
	}
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView ==_settingTableView) {
        _webUrlTableView.contentOffset = _settingTableView.contentOffset;
    }else if(scrollView == _webUrlTableView){
        _settingTableView.contentOffset = _webUrlTableView.contentOffset;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //NSLog(@"X:%f  Y:%f",scrollView.contentOffset.x,scrollView.contentOffset.y);
    if (scrollView ==_settingTableView) {
        _webUrlTableView.contentOffset = _settingTableView.contentOffset;
    }else if(scrollView == _webUrlTableView){
        _settingTableView.contentOffset = _webUrlTableView.contentOffset;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
    
	[self.pageControl updateCurrentPageDisplay] ;
}


-(void)urlCenterDidFailWithData:(IndicatorParameterUrlCenter *)urlCenterData{
    NSLog(@"Fail With Data");
    [self searchData];
}

-(void)urlCenterDidFailWithError:(NSError *)error{
    NSLog(@"Fail With Error");
    [self searchData];
}

-(void)urlCenterDidFinishWithData:(IndicatorParameterUrlCenter *)urlCenterData{
    [self searchData];
}

-(void)searchData{
    _dataDictionary = [_dataModal.indicator readIndicatorParameterUrlTable];
    [_dataModal.indicator setKeyArray];
    NSString *localePrefferred = @"";
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        localePrefferred = @"en";
    }else if ([group isEqualToString:@"tw"]){
        localePrefferred = @"zh-Hant";
    }else if ([group isEqualToString:@"cn"]){
        localePrefferred = @"zh-Hans";
    }
    _dataDictionary = [_dataDictionary objectForKey:localePrefferred];
    
    [self.settingTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    [self.webUrlTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
