//
//  FSAddFundsViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/4/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAddFundsViewController.h"
#import "FSInvestedViewController.h"
#import "FMDatabase.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "FSActionPlanDatabase.h"

@interface FSAddFundsViewController () <UIActionSheetDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UILabel *dataLabel;
@property (strong, nonatomic) UILabel *remitLabel;
@property (strong, nonatomic) UILabel *amountLabel;
@property (strong, nonatomic) UILabel *dollorLabel;
@property (strong, nonatomic) UITextField *amountTextField;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *saveDateString;
@property (strong, nonatomic) NSString *current;
@property (strong, nonatomic) UIAlertView *alert;
@property (strong, nonatomic) FSUIButton *dateButton;
@property (strong, nonatomic) FSUIButton *remitButton;
@property (strong, nonatomic) FSUIButton *doneButton;

@end

@implementation FSAddFundsViewController

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
    [self setupNavigationBar];
    [self initView];
    [self.view setNeedsUpdateConstraints];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_dateStr != nil) {
        [_dateButton setTitle:_dateStr forState:UIControlStateNormal];
        _saveDateString = _dateStr;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigationBar{
    [self setTitle:NSLocalizedStringFromTable(@"Edit Capital", @"ActionPlan", nil)];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self setUpImageBackButton];
}

-(void)initView{
    _dataLabel = [[UILabel alloc] init];
    _dataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dataLabel.text = NSLocalizedStringFromTable(@"Date", @"ActionPlan", nil);
    [self.view addSubview:_dataLabel];

    _remitLabel = [[UILabel alloc] init];
    _remitLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _remitLabel.text = NSLocalizedStringFromTable(@"匯款", @"ActionPlan", nil);
    [self.view addSubview:_remitLabel];

    _amountLabel = [[UILabel alloc] init];
    _amountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _amountLabel.text = NSLocalizedStringFromTable(@"金額", @"ActionPlan", nil);
    [self.view addSubview:_amountLabel];
    
    _dollorLabel = [[UILabel alloc] init];
    _dollorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dollorLabel.text = @"$";
    [self.view addSubview:_dollorLabel];
    
    NSDate *today = [NSDate date];
    
//    NSDateFormatter *saveDateFormat = [[NSDateFormatter alloc] init];
//    [saveDateFormat setDateFormat:@"yyyy/MM/dd"];
//    _saveDateString = [saveDateFormat stringFromDate:today];
//    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if ([FSFonestock sharedInstance].marketVersion != FSMarketVersionUS) {
        [dateFormat setDateFormat:@"yyyy/MM/dd"];
    }else{
        [dateFormat setDateFormat:@"MM/dd/YYYY"];
    }
    _saveDateString = [dateFormat stringFromDate:today];
    _dateString = [dateFormat stringFromDate:today];
    
    _dateButton =[self.view newButton:FSUIButtonTypeBlueGreenButton];
    [_dateButton setTitle:_dateString forState:UIControlStateNormal];
    [_dateButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_dateButton addTarget:self action:@selector(dateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _remitButton =[self.view newButton:FSUIButtonTypeBlueGreenDetailButton];
    [_remitButton setTitle:NSLocalizedStringFromTable(@"匯入", @"ActionPlan", nil) forState:UIControlStateNormal];
    [_remitButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_remitButton addTarget:self action:@selector(remittButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _doneButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_doneButton setTitle:NSLocalizedStringFromTable(@"OK", @"ActionPlan", nil) forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(saveFunds:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
    
    _amountTextField = [[UITextField alloc] init];
    _amountTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _amountTextField.delegate = self;
    _amountTextField.borderStyle = UITextBorderStyleRoundedRect;
    _amountTextField.keyboardType = UIKeyboardTypeNumberPad;
    _amountTextField.textAlignment = NSTextAlignmentRight;
    [_amountTextField setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_amountTextField];
    
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_dataLabel, _dateButton, _remitLabel, _remitButton ,_amountLabel, _amountTextField, _dollorLabel, _doneButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_dataLabel][_dateButton(_dataLabel)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_remitLabel][_remitButton(_remitLabel)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_amountLabel][_dollorLabel]-[_amountTextField(_remitButton)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_doneButton(100)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_dateButton(30)]-[_remitButton(30)]-[_amountTextField(30)]-[_doneButton(30)]" options:0 metrics:nil views:viewControllers]];
}

-(void)setAutoLayout{
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_datePicker, _toolBar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_datePicker]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolBar]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolBar][_datePicker(160)]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark - Button Action
-(void)dateButtonAction:(id)sender{
    _dateButton.enabled = NO;
    _remitButton.enabled = NO;
    _amountTextField.enabled = NO;
    _doneButton.enabled = NO;
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    _datePicker.backgroundColor = [UIColor whiteColor];
    _datePicker.DatePickerMode = UIDatePickerModeDate;
    if([[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"tw"]){
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    }else{
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    [self.view addSubview:_datePicker];
    
    _toolBar = [[UIToolbar alloc] init];
    _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    FSUIButton *doneBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    doneBtn.frame = CGRectMake(0, 0, 60, 30);
    [doneBtn setTitle:NSLocalizedStringFromTable(@"確認",@"ActionPlan",nil) forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(cancelPicker) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:doneBtn];    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [_toolBar setItems:[NSArray arrayWithObjects:flex, doneButton, nil]];
    [self.view addSubview:_toolBar];
    [self setAutoLayout];
}

-(void)saveFunds:(id)sender{
    if ([_amountTextField.text isEqual:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"Please Enter Content!", @"Trade", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"Trade", nil) otherButtonTitles:nil];
        [alert show];
    }else if ([_remitButton.titleLabel.text isEqual:NSLocalizedStringFromTable(@"匯入", @"ActionPlan", nil)]){
        [[FSActionPlanDatabase sharedInstances] insertInvestedWithDate:_saveDateString Remit:_remitButton.titleLabel.text Amount:_current Term:_termStr];
        
        [self.navigationController popViewControllerAnimated:NO];
    }else if ([_remitButton.titleLabel.text isEqual:NSLocalizedStringFromTable(@"匯出", @"ActionPlan", nil)]){
        NSString *totalAmount = [[FSActionPlanDatabase sharedInstances] searchInvestedTotalAmountByTerm:_termStr Date:_saveDateString];
        if ([(NSNumber *)_current floatValue] > [(NSNumber *)totalAmount floatValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"Insufficient balance!", @"ActionPlan", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"ActionPlan", nil) otherButtonTitles:nil];
            [alert show];
        }else{
            NSString *negative = [NSString stringWithFormat:@"-%@", _current];
            [[FSActionPlanDatabase sharedInstances] insertInvestedWithDate:_saveDateString Remit:_remitButton.titleLabel.text Amount:negative Term:_termStr];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

-(void)cancelPicker {
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    if ([FSFonestock sharedInstance].marketVersion != FSMarketVersionUS) {
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    }else{
        [dateFormatter setDateFormat:@"MM/dd/YYYY"];
    }
    _dateString = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:_datePicker.date]];
    
    NSComparisonResult result = [today compare:_datePicker.date];
    if (result == NSOrderedAscending) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"選擇日期不正確", @"", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil) otherButtonTitles:nil];
        [alertView show];
    }else{
        _dateButton.enabled = YES;
        _remitButton.enabled = YES;
        _amountTextField.enabled = YES;
        _doneButton.enabled = YES;
        
//        if ([FSFonestock sharedInstance].marketVersion != FSMarketVersionUS) {
//            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
//        }else{
//            [dateFormatter setDateFormat:@"MM/dd/YYYY"];
//        }
//        NSDateFormatter *saveDateFormat = [[NSDateFormatter alloc] init];
//        [saveDateFormat setDateFormat:@"yyyy/MM/dd"];
        _saveDateString = [dateFormatter stringFromDate:_datePicker.date];
        
        [_dateButton setTitle:_dateString forState:UIControlStateNormal];
        [_datePicker removeFromSuperview];
        [_toolBar removeFromSuperview];
    }
}

- (void)remittButtonAction:(id)sender {
    UIActionSheet *actionSheet  =
    [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"匯款方式", @"ActionPlan", nil)
                                delegate:self
                       cancelButtonTitle:nil
                  destructiveButtonTitle:nil
                       otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"匯入", @"ActionPlan", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"匯出", @"ActionPlan", nil)];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil)];
    [actionSheet showInView:self.view.window.rootViewController.view];
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_remitButton setTitle:NSLocalizedStringFromTable(@"匯入", @"ActionPlan", nil) forState:UIControlStateNormal];
    }else if (buttonIndex == 1){
        [_remitButton setTitle:NSLocalizedStringFromTable(@"匯出", @"ActionPlan", nil) forState:UIControlStateNormal];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if([[FSFonestock sharedInstance] checkNeedShowAdvertise]){
        if([[UIApplication sharedApplication] statusBarOrientation]== UIInterfaceOrientationLandscapeLeft){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 52, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-32);
        }else if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait){
            self.navigationController.topViewController.view.frame = CGRectMake(0, 64, self.navigationController.topViewController.view.bounds.size.width, self.navigationController.topViewController.view.bounds.size.height-50);
        }
    }
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:_amountTextField]) {
        _alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"請輸入金額", @"ActionPlan", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確認", @"ActionPlan", nil), nil];
        
        _alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [_alert textFieldAtIndex:0].delegate = self;
        [[_alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
        [[_alert textFieldAtIndex:0] becomeFirstResponder];
        [_alert textFieldAtIndex:0].text = @"";
        [_alert show];
        return NO;
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField isEqual:[_alert textFieldAtIndex:0]]) {
        NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([toBeString length] > 9) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if ([[_alert textFieldAtIndex:0].text isEqualToString:@"0"] || [[_alert textFieldAtIndex:0].text isEqualToString:@""]) {
            _current = @"";
        }else{
            _current = [_alert textFieldAtIndex:0].text;
            _amountTextField.text = [NSString stringWithFormat:@"%@", [CodingUtil CoverFloatWithComma:[_current doubleValue] DecimalPoint:0]];
        }
    }
    [_amountTextField resignFirstResponder];

}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
