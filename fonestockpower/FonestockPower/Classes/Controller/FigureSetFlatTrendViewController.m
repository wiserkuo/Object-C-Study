//
//  FigureSetFlatTrendViewController.m
//  WirtsLeg
//
//  Created by Neil on 14/2/5.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "FigureSetFlatTrendViewController.h"
#import "FigureSearchMyProfileModel.h"


@interface FigureSetFlatTrendViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UIImageView * flatTrendImg;
@property (strong, nonatomic) UILabel * dayLabel;
@property (strong, nonatomic) UILabel * weekLabel;
@property (strong, nonatomic) UILabel * monthLabel;
@property (strong, nonatomic) UITextField * dayText;
@property (strong, nonatomic) UITextField * weekText;
@property (strong, nonatomic) UITextField * monthText;
@property (strong, nonatomic) UILabel * exampleTitleLabel;
@property (strong, nonatomic) UILabel * exampleDayLabel;
@property (strong, nonatomic) UILabel * exampleWeekLabel;
@property (strong, nonatomic) UILabel * exampleMonthLabel;
@property (strong ,nonatomic) UILabel * dayPercentLabel;
@property (strong ,nonatomic) UILabel * weekPercentLabel;
@property (strong ,nonatomic) UILabel * monthPercentLabel;
@property (strong, nonatomic) FSUIButton * flatDoneBtn;
@property (strong , nonatomic) FigureSearchMyProfileModel * customModel;
@property (strong, nonatomic) NSMutableArray * figureSearchArray;
@property (nonatomic) int searchNum;
@property (strong , nonatomic) NSString * gategory;
@property (nonatomic,strong) FSUIButton * closeBtn;
//@property (nonatomic,strong) UITextField * editRangeText;
@property (nonatomic,strong) UITextField * nowEditText;

@end

@implementation FigureSetFlatTrendViewController

- (id)initWithGategory:(NSString *)gategory SearchNum:(int)searchNum{
    self = [super init];
    if (self) {
        _searchNum = searchNum;
        self.gategory = gategory;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpImageBackButton];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    self.figureSearchArray = [[NSMutableArray alloc]init];
    self.figureSearchArray =[_customModel searchFigureSearchIdWithGategory:self.gategory ItemOrder:[NSNumber numberWithInt:_searchNum]];
    [self initView];
    [self setFlatTrendLayout];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setTitle: NSLocalizedStringFromTable(@"設定橫盤整理參數", @"FigureSearch", nil)];
}

- (void)setUpImageBackButton {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
}
- (void)popCurrentViewController {
    if ([_dayText.text isEqualToString:@""] || [_weekText.text isEqualToString:@""] || [_monthText.text isEqualToString:@""]) {
        [FSHUD showMsg:NSLocalizedStringFromTable(@"請輸入數值", @"FigureSearch",nil)];
    }else{
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [_customModel updateFlatTrendWithFigureSearchId:[_figureSearchArray objectAtIndex:0] DayRange:[NSNumber numberWithInt:[_dayText.text intValue]] WeekRange:[NSNumber numberWithInt:[_weekText.text intValue]] MonthRange:[NSNumber numberWithInt:[_monthText.text intValue]]];

}

-(void)initView{
    
    self.flatTrendImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"upDownLine"]];
    _flatTrendImg.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_flatTrendImg];
    
    self.dayLabel = [[UILabel alloc]init];
    _dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dayLabel.text = NSLocalizedStringFromTable(@"日", @"FigureSearch", nil);
    [self.view addSubview:_dayLabel];
    
    self.weekLabel = [[UILabel alloc]init];
    _weekLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _weekLabel.text = NSLocalizedStringFromTable(@"週", @"FigureSearch", nil);
    [self.view addSubview:_weekLabel];
    
    
    self.monthLabel = [[UILabel alloc]init];
    _monthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _monthLabel.text = NSLocalizedStringFromTable(@"月", @"FigureSearch", nil);
    [self.view addSubview:_monthLabel];
    
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, [[UIScreen mainScreen]bounds].size.width, 30)];
    customView.backgroundColor = [UIColor clearColor];
    
//    self.editRangeText = [[UITextField alloc]initWithFrame:CGRectMake(0, 300, 250, 30)];
//    _editRangeText.delegate = self;
//    _editRangeText.borderStyle = UITextBorderStyleRoundedRect;
//    _editRangeText.keyboardType = UIKeyboardTypeDecimalPad;
//    [customView addSubview:_editRangeText];
    
    
    self.closeBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_closeBtn setFrame: CGRectMake(250, 0, 70, 30)];
    [_closeBtn addTarget:self action:@selector(closeKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setTitle:NSLocalizedStringFromTable(@"關閉", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [customView addSubview:_closeBtn];
    
    self.dayText = [[UITextField alloc]init];
    _dayText.translatesAutoresizingMaskIntoConstraints = NO;
    _dayText.delegate = self;
    _dayText.inputAccessoryView = customView;
    _dayText.borderStyle = UITextBorderStyleRoundedRect;
    _dayText.textAlignment = NSTextAlignmentCenter;
    _dayText.keyboardType = UIKeyboardTypeDecimalPad;
    _dayText.text = [_figureSearchArray objectAtIndex:12];
    [self.view addSubview:_dayText];
    
    self.weekText = [[UITextField alloc]init];
    _weekText.translatesAutoresizingMaskIntoConstraints = NO;
    _weekText.delegate = self;
    _weekText.inputAccessoryView = customView;
    _weekText.borderStyle = UITextBorderStyleRoundedRect;
    _weekText.textAlignment = NSTextAlignmentCenter;
    _weekText.keyboardType = UIKeyboardTypeDecimalPad;
    _weekText.text = [_figureSearchArray objectAtIndex:13];
    [self.view addSubview:_weekText];
    
    self.monthText = [[UITextField alloc]init];
    _monthText.translatesAutoresizingMaskIntoConstraints = NO;
    _monthText.delegate = self;
    _monthText.inputAccessoryView = customView;
    _monthText.borderStyle = UITextBorderStyleRoundedRect;
    _monthText.textAlignment = NSTextAlignmentCenter;
    _monthText.keyboardType = UIKeyboardTypeDecimalPad;
    _monthText.text = [_figureSearchArray objectAtIndex:14];
    [self.view addSubview:_monthText];
    
    self.dayPercentLabel = [[UILabel alloc]init];
    _dayPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dayPercentLabel.text = @"%";
    [self.view addSubview:_dayPercentLabel];
    
    self.weekPercentLabel = [[UILabel alloc]init];
    _weekPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _weekPercentLabel.text = @"%";
    [self.view addSubview:_weekPercentLabel];
    
    self.monthPercentLabel = [[UILabel alloc]init];
    _monthPercentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _monthPercentLabel.text = @"%";
    [self.view addSubview:_monthPercentLabel];
    
    self.exampleTitleLabel = [[UILabel alloc]init];
    _exampleTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _exampleTitleLabel.text = NSLocalizedStringFromTable(@"範例", @"FigureSearch", nil);
    [self.view addSubview:_exampleTitleLabel];
    
    self.exampleDayLabel = [[UILabel alloc]init];
    _exampleDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _exampleDayLabel.text = NSLocalizedStringFromTable(@"日3%", @"FigureSearch", nil);
    _exampleDayLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_exampleDayLabel];
    
    self.exampleWeekLabel = [[UILabel alloc]init];
    _exampleWeekLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _exampleWeekLabel.text = NSLocalizedStringFromTable(@"週5%", @"FigureSearch", nil);
    _exampleWeekLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_exampleWeekLabel];
    
    self.exampleMonthLabel = [[UILabel alloc]init];
    _exampleMonthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _exampleMonthLabel.text = NSLocalizedStringFromTable(@"月10%", @"FigureSearch", nil);
    _exampleMonthLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_exampleMonthLabel];
    
    
}

-(void)setFlatTrendLayout{
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_flatTrendImg,_dayLabel,_weekLabel,_monthLabel,_dayText,_weekText,_monthText,_dayPercentLabel,_weekPercentLabel,_monthPercentLabel,_exampleTitleLabel,_exampleDayLabel,_exampleWeekLabel,_exampleMonthLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_flatTrendImg(96)]-40-[_dayLabel(30)]-5-[_weekLabel(30)]-5-[_monthLabel(30)]-10-[_exampleTitleLabel(30)]-5-[_exampleDayLabel(30)]-5-[_exampleWeekLabel(30)]-5-[_exampleMonthLabel(30)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[_flatTrendImg(120)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[_dayLabel(70)]-5-[_dayText]-5-[_dayPercentLabel(20)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[_weekLabel(70)]-5-[_weekText]-5-[_weekPercentLabel(20)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[_monthLabel(70)]-5-[_monthText]-5-[_monthPercentLabel(20)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_exampleTitleLabel(240)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_exampleDayLabel(240)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_exampleWeekLabel(240)]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[_exampleMonthLabel(240)]" options:0 metrics:nil views:viewControllers]];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length<3 || [string isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([textField isEqual:_dayText]) {
        [self moveView:-50.0f];
    }else if ([textField isEqual:_weekText]) {
        [self moveView:-80.0f];
    }else if ([textField isEqual:_monthText]) {
        [self moveView:-100.0f];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:_dayText]) {
        [self moveView:50.0f];
    }else if ([textField isEqual:_weekText]) {
        [self moveView:80.0f];
    }else if ([textField isEqual:_monthText]) {
        [self moveView:100.0f];
    }
}


-(void)closeKeyBoard{
    [_dayText resignFirstResponder];
    [_weekText resignFirstResponder];
    [_monthText resignFirstResponder];
    
    NSString * alertStr = @"";
    
    if ([_dayText.text intValue]>100) {
        alertStr = NSLocalizedStringFromTable(@"超過上限", @"FigureSearch", nil);
        _dayText.text = @"100";//[_figureSearchArray objectAtIndex:12];
    }
    if ([_weekText.text intValue]>100) {
        alertStr = NSLocalizedStringFromTable(@"超過上限", @"FigureSearch", nil);
        _weekText.text = @"100";//[_figureSearchArray objectAtIndex:13];
    }
    if ([_monthText.text intValue]>100) {
        alertStr = NSLocalizedStringFromTable(@"超過上限", @"FigureSearch", nil);
        _monthText.text = @"100";//[_figureSearchArray objectAtIndex:14];
    }
    
    
    if (![alertStr isEqualToString:@""]) {
        [FSHUD showMsg:alertStr];
    }

    
}

-(void)moveView:(float)move{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    CGRect frame = self.view.frame;
    frame.origin.y += move;
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
