//
//  FSTradeViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/7/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTradeViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FMDatabase.h"
#import "FSActionPlanDatabase.h"
#import "FigureSearchMyProfileModel.h"
#import "FSAddFundsViewController.h"
#import "CustomIOS7AlertView.h"

@interface FSTradeViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate, CustomIOS7AlertViewDelegate, UIScrollViewDelegate> {
    float count;
    float price;
    float cash;
    float qty;
    NSString *symbolName;
    UIAlertView *alert;
    UIAlertView *textAlert;
    CustomIOS7AlertView *custAlertView;
    
    NSDate *today;
    NSString *todayStr;
}
@property (strong, nonatomic) UILabel *dateTitleLabel;
@property (strong, nonatomic) UILabel *symbolTitleLabel;
@property (strong, nonatomic) UILabel *dealTitleLabel;
@property (strong, nonatomic) UILabel *countTitleLabel;
@property (strong, nonatomic) UILabel *priceTitleLabel;
@property (strong, nonatomic) UILabel *amountPayableTitleLabel;
@property (strong, nonatomic) UILabel *amountPayableLabel;
@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UILabel *sharesOwnedTitleLabel;
@property (strong, nonatomic) UILabel *sharesOwnedLabel;
@property (strong, nonatomic) UILabel *cashTitleLabel;
@property (strong, nonatomic) UILabel *cashLabel;
@property (strong, nonatomic) UILabel *tradeLabel;
@property (strong, nonatomic) UILabel *promptLabel;
@property (strong, nonatomic) UILabel *suggestQTYTitle;
@property (strong, nonatomic) UILabel *suggestQTY;

@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UITextField *countTextField;
@property (strong, nonatomic) UITextField *priceTextField;
@property (strong, nonatomic) FSUIButton *dateButton;
@property (strong, nonatomic) FSUIButton *doneButton;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *toolBar;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray *tradeArray;
@property (strong, nonatomic) NSMutableDictionary *term;

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *targetSymbol;
@property (nonatomic) float cashNum;

@property (strong, nonatomic) UIAlertView *buyAlertView;
@property (strong, nonatomic) UIAlertView *soldAlertView;
@property (strong, nonatomic) UIAlertView *shortAlertView;
@property (strong, nonatomic) UIAlertView *coverAlertView;
@property (strong, nonatomic) FSPositionModel *positionModel;
@property (strong, nonatomic) FSActionPlanDatabase *actionPlanDB;

@end

@implementation FSTradeViewController

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
	// Do any additional setup after loading the view.
    [self getToday];
    [self setupNavigationBar];
    [self setupView];
    [self.view setNeedsUpdateConstraints];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Set up views
-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Trade", @"Trade", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self setUpImageBackButton];
}

-(void)setupView{
    _contentView = [[UIView alloc] init];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [_scrollView addSubview:_contentView];
    [self.view addSubview:_scrollView];
    
    //日期
    _dateTitleLabel = [[UILabel alloc] init];
    _dateTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dateTitleLabel.text = NSLocalizedStringFromTable(@"Date", @"Trade", nil);
    [_contentView addSubview:_dateTitleLabel];
    
    _dateString = todayStr;
    _dateButton =[_contentView newButton:FSUIButtonTypeBlueGreenButton];
    [_dateButton setTitle:todayStr forState:UIControlStateNormal];
    [_dateButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_dateButton addTarget:self action:@selector(dateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //名稱
    _symbolTitleLabel = [[UILabel alloc] init];
    _symbolTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _symbolTitleLabel.text = NSLocalizedStringFromTable(@"Symbol", @"Trade", nil);
    [_contentView addSubview:_symbolTitleLabel];
    
    _symbolLabel = [[UILabel alloc] init];
    _symbolLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _symbolLabel.textAlignment = NSTextAlignmentCenter;
    _symbolLabel.text = [self getGroupTextWithids:_symbolStr];
    [_contentView addSubview:_symbolLabel];
    
    //交易
    _dealTitleLabel = [[UILabel alloc] init];
    _dealTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dealTitleLabel.text = NSLocalizedStringFromTable(@"Action", @"Trade", nil);
    [_contentView addSubview:_dealTitleLabel];
    
    _tradeLabel = [[UILabel alloc] init];
    _tradeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _tradeLabel.textAlignment = NSTextAlignmentCenter;
    _tradeLabel.text = NSLocalizedStringFromTable(_dealStr, @"Trade", nil);
    [_contentView addSubview:_tradeLabel];
    
    //股數
    _countTitleLabel = [[UILabel alloc] init];
    _countTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _countTitleLabel.text = NSLocalizedStringFromTable(@"Shares", @"Trade", nil);
    [_contentView addSubview:_countTitleLabel];
    
    _countTextField = [[UITextField alloc] init];
    _countTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _countTextField.borderStyle = UITextBorderStyleRoundedRect;
    _countTextField.textAlignment = NSTextAlignmentRight;
    _countTextField.delegate = self;
    [_contentView addSubview:_countTextField];
    
    //價格
    _priceTitleLabel = [[UILabel alloc] init];
    _priceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _priceTitleLabel.text = NSLocalizedStringFromTable(@"Price", @"Trade", nil);
    [_contentView addSubview:_priceTitleLabel];
    
    _priceTextField = [[UITextField alloc] init];
    _priceTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _priceTextField.borderStyle = UITextBorderStyleRoundedRect;
    _priceTextField.textAlignment = NSTextAlignmentRight;
    _priceTextField.delegate = self;
    _priceTextField.inputView = textAlert;
    if (_lastNum == 0 && _ref_Price == 0) {
        _priceTextField.text = @"";
    }else if (_lastNum != 0){
        _priceTextField.text = [NSString stringWithFormat:@"%.2f", _lastNum];
    }else if (_ref_Price != 0){
        _priceTextField.text = [NSString stringWithFormat:@"%.2f", _ref_Price];
    }
    price = _lastNum;
    [_contentView addSubview:_priceTextField];
    
    //庫存股數
    _sharesOwnedTitleLabel = [[UILabel alloc] init];
    _sharesOwnedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _sharesOwnedTitleLabel.text = NSLocalizedStringFromTable(@"Shares Owned", @"Trade", nil);
    [_contentView addSubview:_sharesOwnedTitleLabel];
    
    _sharesOwnedLabel = [[UILabel alloc] init];
    _sharesOwnedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _sharesOwnedLabel.textAlignment = NSTextAlignmentRight;
    [_contentView addSubview:_sharesOwnedLabel];
    
    //現金餘額
    _cashTitleLabel = [[UILabel alloc] init];
    _cashTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _cashTitleLabel.text = NSLocalizedStringFromTable(@"Cash", @"Trade", nil);
    [_contentView addSubview:_cashTitleLabel];
    
    _cashLabel = [[UILabel alloc] init];
    _cashLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _cashLabel.textAlignment = NSTextAlignmentRight;
    [_contentView addSubview:_cashLabel];
    
    //交易金額
    _amountPayableTitleLabel = [[UILabel alloc] init];
    _amountPayableTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _amountPayableTitleLabel.text = NSLocalizedStringFromTable(@"交易金額", @"Trade", nil);
    [_contentView addSubview:_amountPayableTitleLabel];
    
    _amountPayableLabel = [[UILabel alloc] init];
    _amountPayableLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _amountPayableLabel.textAlignment = NSTextAlignmentRight;
    _amountPayableLabel.adjustsFontSizeToFitWidth = YES;
    [_contentView addSubview:_amountPayableLabel];
    
    //確認(儲存)
    _doneButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [_doneButton setTitle:NSLocalizedStringFromTable(@"OK", @"Trade", nil) forState:UIControlStateNormal];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_doneButton addTarget:self action:@selector(saveTrade:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_doneButton];
    
    //提示
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _promptLabel.text = NSLocalizedStringFromTable(@"(建議曝險金額控制在資產淨值2%內)", @"Trade", nil);
    _promptLabel.adjustsFontSizeToFitWidth = YES;
    _promptLabel.hidden = YES;
    [_contentView addSubview:_promptLabel];
        
    _suggestQTYTitle = [[UILabel alloc] init];
    _suggestQTY = [[UILabel alloc] init];

    if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SHORT"]) {
        _suggestQTYTitle.translatesAutoresizingMaskIntoConstraints = NO;
        _suggestQTYTitle.adjustsFontSizeToFitWidth = YES;
        if ([_dealStr isEqualToString:@"BUY"]) {
            _suggestQTYTitle.text = NSLocalizedStringFromTable(@"建議買進張數小於", @"Trade", nil);
            _promptLabel.hidden = NO;
        }else if ([_dealStr isEqualToString:@"SHORT"]){
            _suggestQTYTitle.text = NSLocalizedStringFromTable(@"建議放空張數小於", @"Trade", nil);
            _promptLabel.hidden = NO;
        }
        [_contentView addSubview:_suggestQTYTitle];
        
        _suggestQTY.translatesAutoresizingMaskIntoConstraints = NO;
        _suggestQTY.adjustsFontSizeToFitWidth = YES;
        _suggestQTY.textAlignment = NSTextAlignmentRight;
        _suggestQTY.text = @"0";
        [_contentView addSubview:_suggestQTY];
    }
}

-(void)updateViewConstraints{
    [super updateViewConstraints];

    NSMutableArray *layoutContraints = [[NSMutableArray alloc]init];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_dateTitleLabel, _symbolTitleLabel, _dealTitleLabel,_countTitleLabel, _priceTitleLabel, _amountPayableTitleLabel, _tradeLabel, _dateButton, _symbolLabel, _countTextField, _priceTextField, _amountPayableLabel, _sharesOwnedTitleLabel, _sharesOwnedLabel, _cashTitleLabel, _cashLabel, _doneButton, _promptLabel, _scrollView, _contentView, _suggestQTYTitle, _suggestQTY);
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:viewControllers]];
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentView(==_scrollView)]" options:0 metrics:nil views:viewControllers]];
    if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SHORT"]) {
        if ([_dateString isEqualToString:todayStr]) {
            [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView(>=335)]|" options:0 metrics:nil views:viewControllers]];
        }else{
            [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView(>=305)]|" options:0 metrics:nil views:viewControllers]];
        }
    }else{
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView(>=305)]|" options:0 metrics:nil views:viewControllers]];
    }
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_dateTitleLabel][_dateButton(_dateTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_symbolTitleLabel][_symbolLabel(_symbolTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_dealTitleLabel][_tradeLabel(_dealTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_countTitleLabel][_countTextField(_countTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    
    if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SHORT"]) {
        if ([_dateString isEqualToString:todayStr]) {
            [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_suggestQTYTitle][_suggestQTY(_suggestQTYTitle)]-|" options:0 metrics:nil views:viewControllers]];
        }
    }
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_priceTitleLabel][_priceTextField(_priceTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_amountPayableTitleLabel][_amountPayableLabel(_amountPayableTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_sharesOwnedTitleLabel][_sharesOwnedLabel(_sharesOwnedTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cashTitleLabel][_cashLabel(_cashTitleLabel)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_doneButton(100)]-|" options:0 metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_promptLabel]|" options:0 metrics:nil views:viewControllers]];

    if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SHORT"]) {
        if ([_dateString isEqualToString:todayStr]) {
            [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_dateTitleLabel(30)][_symbolTitleLabel(30)][_dealTitleLabel(30)][_countTitleLabel(30)][_suggestQTYTitle(30)][_promptLabel(30)][_priceTitleLabel(30)][_amountPayableTitleLabel(30)][_sharesOwnedTitleLabel(30)][_cashTitleLabel(30)]" options:0 metrics:nil views:viewControllers]];
            [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_dateButton(30)][_symbolLabel(30)][_tradeLabel(30)][_countTextField(30)][_suggestQTY(30)]-30-[_priceTextField(30)][_amountPayableLabel(30)][_sharesOwnedLabel(30)][_cashLabel(30)][_doneButton(30)]" options:0 metrics:nil views:viewControllers]];
        }else{
            [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_dateTitleLabel(30)][_symbolTitleLabel(30)][_dealTitleLabel(30)][_countTitleLabel(30)][_priceTitleLabel(30)][_amountPayableTitleLabel(30)][_sharesOwnedTitleLabel(30)][_cashTitleLabel(30)]" options:0 metrics:nil views:viewControllers]];
            [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_dateButton(30)][_symbolLabel(30)][_tradeLabel(30)][_countTextField(30)][_priceTextField(30)][_amountPayableLabel(30)][_sharesOwnedLabel(30)][_cashLabel(30)][_doneButton(30)]" options:0 metrics:nil views:viewControllers]];
        }

    }else{
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_dateTitleLabel(30)][_symbolTitleLabel(30)][_dealTitleLabel(30)][_countTitleLabel(30)][_priceTitleLabel(30)][_amountPayableTitleLabel(30)][_sharesOwnedTitleLabel(30)][_cashTitleLabel(30)]" options:0 metrics:nil views:viewControllers]];
        [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_dateButton(30)][_symbolLabel(30)][_tradeLabel(30)][_countTextField(30)][_priceTextField(30)][_amountPayableLabel(30)][_sharesOwnedLabel(30)][_cashLabel(30)][_doneButton(30)]" options:0 metrics:nil views:viewControllers]];
    }
    
    [self replaceCustomizeConstraints:layoutContraints];
}

-(void)setAutoLayout{
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_datePicker, _toolBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_datePicker]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolBar]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolBar][_datePicker(160)]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark - init Data
-(void)initData{
    _positionModel = [[FSDataModelProc sharedInstance] positionModel];
    _positionModel.isOrderByRow = NO;
    [_positionModel loadPositionData:_termStr];
    
    [self calculateCashValue];
    [self calculateSuggestQTY];
}

#pragma mark - get Date
-(void)getToday{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }else{
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    today = [dateFormatter dateFromString:strDate];
    todayStr = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:today]];
}

#pragma mark - get identCode or symbol
-(NSString *)getGroupTextWithids:(NSString *)ids{
    NSString *string = ids;
    NSString *identCode = [string substringToIndex:2];
    NSString *symbol = [string substringFromIndex:3];
    NSString *fullName = [[[FSDataModelProc sharedInstance] securitySearchModel] searchFullNameWithIdentCode:identCode Symbol:symbol];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        return symbol;
    }else{
        return fullName;
    }
}

#pragma mark - Button click action
-(void)dateButtonAction:(id)sender{
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    _datePicker.backgroundColor = [UIColor whiteColor];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }else{
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    }
    [self.view addSubview:_datePicker];
    
    _toolBar = [[UIToolbar alloc] init];
    _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    FSUIButton *doneBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    doneBtn.frame = CGRectMake(0, 0, 60, 30);
    [doneBtn setTitle:NSLocalizedStringFromTable(@"確認", @"Trade", nil) forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [_toolBar setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
    [self.view addSubview:_toolBar];
    _dateButton.enabled = NO;
    _saveButton.enabled = NO;
    _countTextField.enabled = NO;
    _priceTextField.enabled = NO;
    _doneButton.enabled = NO;
    
    [self setAutoLayout];
}

#pragma mark - datePicker確認
-(void)cancelPicker{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }else{
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }
    _dateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:_datePicker.date]];
    NSDate *datePickerDate = [dateFormatter dateFromString:_dateString];

    NSComparisonResult result = [today compare:datePickerDate];
    if (result == NSOrderedAscending) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"選擇日期不正確", @"Trade", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"Trade", nil) otherButtonTitles:nil];
        [alertView show];
    }else{
        _dateButton.enabled = YES;
        _saveButton.enabled = YES;
        _countTextField.enabled = YES;
        _priceTextField.enabled = YES;
        _doneButton.enabled = YES;
        
        //顯示用

        NSString * newDate = [dateFormatter stringFromDate:_datePicker.date];
        
        [_dateButton setTitle:newDate forState:UIControlStateNormal];
        [_datePicker removeFromSuperview];
        [_toolBar removeFromSuperview];
        
        [self calculateCashValue];
        
        if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SHORT"]) {
            [self.view setNeedsUpdateConstraints];
            if ([_dateString isEqualToString:todayStr]) {
                _suggestQTYTitle.hidden = NO;
                _suggestQTY.hidden = NO;
            }else{
                _suggestQTYTitle.hidden = YES;
                _suggestQTY.hidden = YES;
            }
        }
    }
    if ([_dateString isEqualToString:todayStr]){
        _promptLabel.text = NSLocalizedStringFromTable(@"(建議曝險金額控制在資產淨值2%內)", @"Trade", nil);
    }else{
        _promptLabel.text = nil;
    }
}

-(void)saveTrade:(id)sender{
    custAlertView = [[CustomIOS7AlertView alloc] init];
    custAlertView.delegate = self;
    
    symbolName = [self getGroupTextWithids:_symbolStr];
    
    if ([_countTextField.text isEqualToString:@"0"] || [_countTextField.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"數量未輸入", @"Trade", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"Trade", nil) otherButtonTitles:nil];
        [alertView show];
        
    }else if ([_priceTextField.text floatValue] == 0 || [_priceTextField.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"價格未輸入", @"Trade", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"Trade", nil) otherButtonTitles:nil];
        [alertView show];
        
    }else if ([_tradeLabel.text isEqualToString:NSLocalizedStringFromTable(@"BUY", @"Trade", nil)]) {
        if (cash < [self determineCountry:count * price]) {
            alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"現金餘額不足, 請先投入資金", @"Trade", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"Trade", nil) otherButtonTitles: nil];
            alert.tag = 400;
            [alert show];
        }else{
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 80)];
            if ([_countTextField.text floatValue] > 1) {
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已購買 %@ 複數張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
                
            }else{
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已購買 %@ 張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
            }
            label.numberOfLines = 0;
            [customView addSubview:label];
            [custAlertView setContainerView:customView];
            NSArray *array  = @[NSLocalizedStringFromTable(@"確認", @"Trade", nil)];
            [custAlertView setButtonTitles:array];
            custAlertView.tag = 500;
            [custAlertView show];
        }
    }else if ([_tradeLabel.text isEqualToString:NSLocalizedStringFromTable(@"SHORT", @"Trade", nil)]){
        if (cash < [self determineCountry:count * price]) {
            alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"現金餘額不足, 請先投入資金", @"Trade", @"") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ActionPlan", nil) otherButtonTitles: nil];
            alert.tag = 400;
            [alert show];
        }else{
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 80)];
            if ([_countTextField.text floatValue] > 1) {
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已賣出 %@ 複數張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
            }else{
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已賣出 %@ 張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
            }
            label.numberOfLines = 0;
            [customView addSubview:label];
            [custAlertView setContainerView:customView];
            NSArray *array  = @[NSLocalizedStringFromTable(@"確認", @"Trade", nil)];
            [custAlertView setButtonTitles:array];
            custAlertView.tag = 501;
            [custAlertView show];
        }
    }else if ([_tradeLabel.text isEqualToString:NSLocalizedStringFromTable(@"SELL", @"Trade", nil)]) {
        _tradeArray = [[NSMutableArray alloc] init];
        _tradeArray = [[FSActionPlanDatabase sharedInstances] searchTradeCountWithSymbol:_symbolStr Date:_dateString];
        if ([(NSNumber *)_countTextField.text floatValue] > [(NSNumber *)[[_tradeArray lastObject] objectForKey:@"TotalCount"] floatValue]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"Out of stock!", @"Trade", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"Trade", nil) otherButtonTitles:nil];
            [alertView show];
            return;
        }else{
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 80)];
            if ([_countTextField.text floatValue] > 1) {
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已賣出 %@ 複數張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
            }else{
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已賣出 %@ 張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
            }
            label.numberOfLines = 0;
            [customView addSubview:label];
            [custAlertView setContainerView:customView];
            NSArray *array  = @[NSLocalizedStringFromTable(@"確認", @"Trade", nil)];
            [custAlertView setButtonTitles:array];
            custAlertView.tag = 502;
            [custAlertView show];
        }
    }else if ([_tradeLabel.text isEqualToString:NSLocalizedStringFromTable(@"COVER", @"Trade", nil)]){
        _tradeArray = [[NSMutableArray alloc] init];
        _tradeArray = [[FSActionPlanDatabase sharedInstances] searchTradeCountWithSymbol:_symbolStr Date:_dateString];
        if ([(NSNumber *)_countTextField.text floatValue] > [(NSNumber *)[[_tradeArray lastObject] objectForKey:@"TotalCount"] floatValue]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Out of stock!" delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"Trade", nil) otherButtonTitles:nil];
            [alertView show];
            return;
        }else{
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 80)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 80)];
            if ([_countTextField.text floatValue] > 1) {
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已購買 %@ 複數張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
            }else{
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"已購買 %@ 張,\n%@ %@ 元,\n共 %@ 元.", @"Trade", nil), [CodingUtil CoverFloatWithComma:count DecimalPoint:0], symbolName, [CodingUtil ConvertFloatWithComma:price DecimalPoint:2], [CodingUtil CoverFloatWithComma:[self determineCountry:count * price] DecimalPoint:0]];
            }
            label.numberOfLines = 0;
            [customView addSubview:label];
            [custAlertView setContainerView:customView];
            NSArray *array  = @[NSLocalizedStringFromTable(@"確認", @"Trade", nil)];
            [custAlertView setButtonTitles:array];
            custAlertView.tag = 503;
            [custAlertView show];
        }
    }
}

#pragma mark - textField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:_countTextField]) {
        textAlert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Trade", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確認", @"Trade", nil), nil];
        textAlert.title = NSLocalizedStringFromTable(@"請輸入數量", @"Trade", nil);
        textAlert.tag = 300;
        textAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[textAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [textAlert textFieldAtIndex:0].delegate = self;
        [[textAlert textFieldAtIndex:0] resignFirstResponder];
        [textAlert textFieldAtIndex:0].text = @"";
        [textAlert show];
        return NO;
    }else if ([textField isEqual:_priceTextField]){
        textAlert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Trade", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確認", @"Trade", nil), nil];
        textAlert.title = NSLocalizedStringFromTable(@"請輸入價格", @"Trade", nil);
        textAlert.tag = 301;
        textAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[textAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
        [textAlert textFieldAtIndex:0].delegate = self;
        [[textAlert textFieldAtIndex:0] resignFirstResponder];
        [textAlert textFieldAtIndex:0].text = @"";
        [textAlert show];
        return NO;
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //限制一個小數點
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray  *arrayOfString = [newString componentsSeparatedByString:@"."];
    if ([arrayOfString count] > 2){
        return NO;
    }
    
    if (textAlert.tag == 300) {
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([toBeString length] > 6) {
            return NO;
        }
    }else if (textAlert.tag == 301){
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([toBeString length] > 7) {
            return NO;
        }
        if ([arrayOfString count] == 2) {
            NSString *decimal = @".";
            if ([toBeString isEqualToString:decimal]) {
                return NO;
            }
            if ([toBeString length] == 7) {
                if ([[toBeString substringFromIndex:6] isEqualToString:decimal]) {
                    return NO;
                }
            }
//            NSRange ran = [textField.text rangeOfString:@"."];
//            NSUInteger tt = range.location - ran.location;
//            if (tt > 2){
//                return NO;
//            }
        }
    }
    return YES;
}

#pragma mark - alertView Delegate
-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    BOOL hasData = NO;
    if (custAlertView.tag == 500) {
        hasData = [[FSActionPlanDatabase sharedInstances] insertTradeWithDate:_dateString Symbol:_symbolStr Deal:_dealStr Count:_countTextField.text Price:_priceTextField.text Term:_termStr Note:@""];
        [self setCellType];
        [self.navigationController popViewControllerAnimated:NO];
    }else if (custAlertView.tag == 502){
        hasData = [[FSActionPlanDatabase sharedInstances] insertTradeWithDate:_dateString Symbol:_symbolStr Deal:_dealStr Count:[NSString stringWithFormat:@"-%@",_countTextField.text] Price:_priceTextField.text Term:_termStr Note:@""];
        [self setCellType];
        [self.navigationController popViewControllerAnimated:NO];
    }else if (custAlertView.tag == 501){
        hasData = [[FSActionPlanDatabase sharedInstances] insertTradeWithDate:_dateString Symbol:_symbolStr Deal:_dealStr Count:_countTextField.text Price:_priceTextField.text Term:_termStr Note:@""];
        [self setCellType];
        [self.navigationController popViewControllerAnimated:NO];
    }else if (custAlertView.tag == 503){
        hasData = [[FSActionPlanDatabase sharedInstances] insertTradeWithDate:_dateString Symbol:_symbolStr Deal:_dealStr Count:[NSString stringWithFormat:@"-%@",_countTextField.text] Price:_priceTextField.text Term:_termStr Note:@""];
        [self setCellType];
        [self.navigationController popViewControllerAnimated:NO];
    }
    if (hasData) {
        _positionModel.isOrderByRow = NO;
    }else{
        _positionModel.isOrderByRow = YES;
    }
    [custAlertView close];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (textAlert.tag == 300 && [alertView isEqual:textAlert]) {
        if (buttonIndex == 1) {
            _countTextField.text = [textAlert textFieldAtIndex:0].text;
            count = [(NSNumber *)[textAlert textFieldAtIndex:0].text floatValue];
        }
        [self setAmountPayableLabel];
        [_countTextField resignFirstResponder];
    }else if (textAlert.tag == 301 && [alertView isEqual:textAlert]){
        if (buttonIndex == 1) {
            _priceTextField.text = [textAlert textFieldAtIndex:0].text;
            price = [(NSNumber *)[textAlert textFieldAtIndex:0].text floatValue];
        }
        [_priceTextField resignFirstResponder];
        [self setAmountPayableLabel];
        [self calculateSuggestQTY];
    }else if (alert.tag == 400){
        FSAddFundsViewController *view = [[FSAddFundsViewController alloc] init];
        view.termStr = _termStr;
        view.dateStr = _dateString;
        [self.navigationController pushViewController:view animated:NO];
    }
}

#pragma mark - 現金餘額計算
-(void)calculateCashValue{
    _actionPlanDB = [FSActionPlanDatabase sharedInstances];
    float fund = [(NSNumber *)[_actionPlanDB searchInvestedTotalAmountByTerm:_termStr Date:_dateString] floatValue];
    qty = 0;
    cash = 0;
    
    //庫存張數
    qty = [(NSNumber *)[_actionPlanDB searchQTYOfTradeWithSymbol:_symbolStr Date:_dateString Term:_termStr] floatValue];
    _sharesOwnedLabel.text = [NSString stringWithFormat:@"%.f", qty];

    //已實現損益
    NSMutableArray *realizedDataArray = [[NSMutableArray alloc] init];
    if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SELL"]) {
        realizedDataArray = [_actionPlanDB searchRealizedOfTradeWithDate:_dateString];
    }else{
        realizedDataArray = [_actionPlanDB searchRealizedOfTradeWithDate:_dateString];
    }
    float totalGain = 0;
    float position = 0;


//Michael:這段太神了,有時間再重構==============

    for (int i = 0; i < [realizedDataArray count]; i++) {
        NSMutableArray *costArray = [[NSMutableArray alloc] init];
        costArray = [[FSActionPlanDatabase sharedInstances] searchAvgCosOfTradetWithSymbol:[[realizedDataArray objectAtIndex:i] objectForKey:@"Symbol"] Date:_dateString];
        
        NSMutableArray *buyCostDataArray = [[NSMutableArray alloc] init];
        if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SELL"]) {
            buyCostDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[realizedDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"BUY" date:_dateString];
        }else{
            buyCostDataArray = [[FSActionPlanDatabase sharedInstances] searchBuyDataOrderByPriceWithSymbol:[[realizedDataArray objectAtIndex:i] objectForKey:@"Symbol"] deal:@"SHORT" date:_dateString];
        }
        NSMutableArray *gainArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < [costArray count]; j++) {
            NSString *deal = [[costArray objectAtIndex:j] objectForKey:@"Deal"];
            if ([deal isEqualToString:@"SELL"]||[deal isEqualToString:@"COVER"]){
                float sellCount = [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
                for (int z = 0; z < [buyCostDataArray count]; z++) {
                    if ([deal isEqualToString:@"SELL"] && ([[[buyCostDataArray objectAtIndex:z]objectForKey:@"Deal"] isEqualToString:@"BUY"] || [[[buyCostDataArray objectAtIndex:z]objectForKey:@"Deal"] isEqualToString:@"SELL"])) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                        }else{
                            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                        }
                        NSDate *date = [dateFormatter dateFromString:[[costArray objectAtIndex:j] objectForKey:@"Date"]];
                        NSDate *buyDate = [dateFormatter dateFromString:[[buyCostDataArray objectAtIndex:z] objectForKey:@"Date"]];
                        if ([date compare:buyDate] == NSOrderedDescending || [date compare:buyDate] == NSOrderedSame) {
                            float buyCount = [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Count"] floatValue];
                            if (fabsf(sellCount) >= buyCount && buyCount > 0) {
                                NSDictionary *dict = [buyCostDataArray objectAtIndex:z];
                                NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                                [gainArray addObject:[buyCostDataArray objectAtIndex:z]];
                                
                                //更新count
                                [mutableDict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"Count"];
                                [buyCostDataArray setObject: mutableDict atIndexedSubscript:z];
                                
                                //獲利
                                totalGain += [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*fabsf(sellCount) - [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*fabsf(sellCount);
                                
                                sellCount = sellCount + buyCount;
                            }else if (buyCount > fabsf(sellCount) && fabsf(sellCount) > 0){
                                NSDictionary *dict = [buyCostDataArray objectAtIndex:z];
                                NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                                
                                //更新count
                                [mutableDict setObject:[NSString stringWithFormat:@"%.f", buyCount + sellCount] forKey:@"Count"];
                                
                                NSDictionary *addGaindict = [buyCostDataArray objectAtIndex:z];
                                NSMutableDictionary *addGainMutableDict = [NSMutableDictionary dictionaryWithDictionary:addGaindict];
                                [addGainMutableDict setObject:[NSString stringWithFormat:@"%f", fabsf(sellCount)] forKey:@"Count"];
                                
                                [gainArray addObject:addGainMutableDict];
                                [buyCostDataArray setObject:mutableDict atIndexedSubscript:z];
                                
                                //獲利
                                totalGain += [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*fabsf(sellCount) - [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*fabsf(sellCount);
                                
                                sellCount = 0;
                            }
                        }
                    }
   
                    if ([deal isEqualToString:@"COVER"] && ([[[buyCostDataArray objectAtIndex:z]objectForKey:@"Deal"] isEqualToString:@"SHORT"] || [[[buyCostDataArray objectAtIndex:z]objectForKey:@"Deal"] isEqualToString:@"COVER"])) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
                            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                        }else{
                            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                        }
                        NSDate *date = [dateFormatter dateFromString:[[costArray objectAtIndex:j] objectForKey:@"Date"]];
                        NSDate *buyDate = [dateFormatter dateFromString:[[buyCostDataArray objectAtIndex:z] objectForKey:@"Date"]];
                        if ([date compare:buyDate] == NSOrderedDescending || [date compare:buyDate] == NSOrderedSame) {
                            float buyCount = [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Count"] floatValue];
                            if (fabsf(sellCount) >= buyCount && buyCount > 0) {
                                NSDictionary *dict = [buyCostDataArray objectAtIndex:z];
                                NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                                [gainArray addObject:[buyCostDataArray objectAtIndex:z]];
                                
                                //更新count
                                [mutableDict setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"Count"];
                                [buyCostDataArray setObject: mutableDict atIndexedSubscript:z];
                                
                                //獲利
                                totalGain += [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*fabsf(sellCount) - [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*fabsf(sellCount);
                                
                                sellCount = sellCount + buyCount;
                            }else if (buyCount > fabsf(sellCount) && fabsf(sellCount) > 0){
                                NSDictionary *dict = [buyCostDataArray objectAtIndex:z];
                                NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                                
                                //更新count
                                [mutableDict setObject:[NSString stringWithFormat:@"%.f", buyCount + sellCount] forKey:@"Count"];
                                
                                NSDictionary *addGaindict = [buyCostDataArray objectAtIndex:z];
                                NSMutableDictionary *addGainMutableDict = [NSMutableDictionary dictionaryWithDictionary:addGaindict];
                                [addGainMutableDict setObject:[NSString stringWithFormat:@"%f", fabsf(sellCount)] forKey:@"Count"];
                                
                                [gainArray addObject:addGainMutableDict];
                                [buyCostDataArray setObject:mutableDict atIndexedSubscript:z];
                                
                                //獲利
                                totalGain += [(NSNumber *)[[costArray objectAtIndex:j] objectForKey:@"Price"] floatValue]*fabsf(sellCount) - [(NSNumber *)[[buyCostDataArray objectAtIndex:z] objectForKey:@"Price"] floatValue]*fabsf(sellCount);
                                
                                sellCount = 0;
                            }
                        }
                    }
                }
            }
        }
        //持有部位
        for (int j = 0; j < [buyCostDataArray count]; j++) {
            float countNum = [(NSNumber *)[[buyCostDataArray objectAtIndex:j] objectForKey:@"Count"] floatValue];
            float priceNum = [(NSNumber *)[[buyCostDataArray objectAtIndex:j] objectForKey:@"Price"] floatValue];
            position += countNum * priceNum;
        }
    }
    
//================================
    
    //現金餘額
    
    cash = fund + totalGain * _positionModel.suggestCount - position * _positionModel.suggestCount ;

    _cashLabel.text = [NSString stringWithFormat:@"$%@", [CodingUtil CoverFloatWithComma:cash DecimalPoint:0]];
}

#pragma mark - 建議張數計算
-(void)calculateSuggestQTY{
    if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SHORT"]) {
        FSPositionModel *positionModel = [[FSDataModelProc sharedInstance] positionModel];
        float suggestNum = 0;
        float avgCost = 0;
//        float userPrice = [_priceTextField.text floatValue];
        //均價
        NSMutableArray *positionArray = positionModel.positionArray;
        for (FSPositions *positions in positionArray) {
            if ([_actionPlan.identCodeSymbol isEqualToString:positions.identCodeSymbol]) {
                avgCost = positions.avgCost;
                break;
            }
        }
        if ([_dealStr isEqualToString:@"BUY"] || [_dealStr isEqualToString:@"SHORT"]) {
            if (price == _actionPlan.last) {
                if (_costType) { //買進最高價
                    suggestNum = [self highestBuyingPrice:avgCost];
                    
                    if (suggestNum < 0) {
                        suggestNum = [self averageBuyingPrice:avgCost];
                    }
                }else{ //買進均價
                    suggestNum = [self averageBuyingPrice:avgCost];
                }
            }else{
                _suggestQTY.text = @"";
            }
        }


        if (suggestNum < 0 || suggestNum == -0){
            _suggestQTY.text = @"0";
        }else if (suggestNum == INFINITY || isnan(suggestNum)){
            _suggestQTY.text = @"----";
        }else{
            _suggestQTY.text = [NSString stringWithFormat:@"%.f",floorf(suggestNum / _positionModel.suggestCount)];
        }
    }
}
-(float)highestBuyingPrice:(float)avgCost {
    FSPositionModel *positionModel = [[FSDataModelProc sharedInstance] positionModel];
    float networth = positionModel.netWorth;
    float suggestNum = 0;
    float stopLossPrice = 0;
    
    if ([_dealStr isEqualToString:@"BUY"]) {
//        多
        if (price > _actionPlan.cost) {
            stopLossPrice = price * (1 - (_actionPlan.sellSLPercent / 100));
        }else{
            stopLossPrice = _actionPlan.cost * (1 - (_actionPlan.sellSLPercent / 100));
        }
        suggestNum = floorf(((networth * 0.02) - ((avgCost - stopLossPrice) * qty * _positionModel.suggestCount)) / (1.02 * price - stopLossPrice - (0.02 * _actionPlan.last)));
        
        int suggestNum_temp = suggestNum / 1000;
        
        if (suggestNum_temp <= 0) {
            suggestNum = floorf(((0.02 * networth) - ((_actionPlan.sellSLPercent / 100) * avgCost * qty * _positionModel.suggestCount)) / ((((_actionPlan.sellSLPercent / 100) + 0.02) * price) - (0.02 * _actionPlan.last)));
        }else{
            if (_actionPlan.last < (((avgCost * qty * _positionModel.suggestCount + (price * suggestNum)) / (suggestNum + qty * _positionModel.suggestCount)) * (1 - (_actionPlan.sellSLPercent / 100)))) {
                suggestNum = floorf(((0.02 * networth) - ((avgCost - _actionPlan.last) * qty * _positionModel.suggestCount)) / (1.02 * price - (1.02 * _actionPlan.last)));
            }
        }
    }else{
//        空
        if (price < _actionPlan.cost) {
            stopLossPrice = price * (1 + (_actionPlan.sellSLPercent / 100));
        }else{
            stopLossPrice = _actionPlan.cost * (1 + (_actionPlan.sellSLPercent / 100));
        }
        
        suggestNum = floorf((((0.02 * networth) - ((stopLossPrice - avgCost) * qty * _positionModel.suggestCount)) / (stopLossPrice - 1.02 * price + (0.02 * _actionPlan.last))));
        
        int suggestNum_temp = suggestNum / 1000;
        
        if (suggestNum_temp <= 0) {
            suggestNum = floorf(((0.02 * networth) - ((_actionPlan.sellSLPercent / 100) * avgCost * qty * _positionModel.suggestCount)) / ((((_actionPlan.sellSLPercent / 100) - 0.02) * price) + (0.02 * _actionPlan.last)));
        }else{
            if (_actionPlan.last > ((avgCost * qty * _positionModel.suggestCount + (price * suggestNum)) / ((suggestNum + qty * _positionModel.suggestCount)) * (1 + (_actionPlan.sellSLPercent / 100)))) {
                suggestNum = floorf(((0.02 * networth) - ((_actionPlan.last - avgCost) * qty * _positionModel.suggestCount)) / (1.02 * _actionPlan.last - (1.02 * price)));
            }
        }
    }
    
    if (_actionPlan.last >= stopLossPrice) {
        if (price < stopLossPrice) {
            _suggestQTY.text = @"----";
        }
    }else{
        if (price >= stopLossPrice) {
            _suggestQTY.text = @"----";
        }
    }
    return suggestNum;
}

-(float)averageBuyingPrice:(float)avgCost {
    FSPositionModel *positionModel = [[FSDataModelProc sharedInstance] positionModel];
    float networth = positionModel.netWorth;
    float suggestNum = 0;
    
    if ([_dealStr isEqualToString:@"BUY"]){
        suggestNum = floorf(((networth * 0.02) - ((_actionPlan.sellSLPercent / 100) * avgCost * qty * _positionModel.suggestCount)) / ((((_actionPlan.sellSLPercent / 100) + 0.02) * price) - (0.02 * _actionPlan.last)));
        if (_actionPlan.last < (((avgCost * qty * _positionModel.suggestCount + (price * suggestNum)) / (suggestNum + qty * _positionModel.suggestCount)) * (1 - (_actionPlan.sellSLPercent / 100)))) {
            suggestNum = floorf(((0.02 * networth) - ((avgCost - _actionPlan.last) * qty * _positionModel.suggestCount)) / (1.02 * price - (1.02 * _actionPlan.last)));
        }
    }else{
        suggestNum = floorf(((networth * 0.02) - ((_actionPlan.sellSLPercent / 100.0f) * avgCost * qty * _positionModel.suggestCount)) / ((((_actionPlan.sellSLPercent / 100) - 0.02) * price) + (0.02 * _actionPlan.last)));
        if (_actionPlan.last > ((avgCost * qty * _positionModel.suggestCount + (price * suggestNum)) / ((suggestNum + qty * _positionModel.suggestCount)) * (1 + (_actionPlan.sellSLPercent / 100)))) {
            suggestNum = floorf(((0.02 * networth) - ((_actionPlan.last - avgCost) * qty * _positionModel.suggestCount)) / (1.02 * _actionPlan.last - (1.02 * price)));
        }
    }
    
    return suggestNum;
}
#pragma mark - 交易金額更新
-(void)setAmountPayableLabel{
    float amountPayableNum = [self determineCountry:count * price];
    
    NSString *amountPayable = [CodingUtil CoverFloatWithComma:amountPayableNum DecimalPoint:0];
    if (amountPayableNum == 0) {
        _amountPayableLabel.text = @"";
    }else {
        _amountPayableLabel.text = [NSString stringWithFormat:@"$%@", amountPayable];
    }
}

#pragma mark - ActionPlan Cell Type(In Stock or not)
-(void)setCellType{
    NSString * sharesOwnedStr = [[FSActionPlanDatabase sharedInstances] searchSharesOwnedWithSymbol:_symbolStr term:_termStr];
    if ([(NSNumber *)sharesOwnedStr floatValue] > 0) {
        _actionPlan.cellType = YES;
    }else{
        _actionPlan.cellType = NO;
        [[FSActionPlanDatabase sharedInstances] updateActionPlanDataWithPattern2:@"0" SProfit2:@"15" SLoss2:@"8" Symbol:_symbolStr Term:_termStr];
    }
}
-(double)determineCountry:(double)tempPrice{
    float amountPayableNum = 0.0f;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        amountPayableNum = tempPrice * 1000;
    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        amountPayableNum = tempPrice;
    }else if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
        amountPayableNum = tempPrice * 100;
    }
    
    return amountPayableNum;
}
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
