//
//  FigureRangeSetupViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/29.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureRangeSetupViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "KxMenu.h"
#import "FSTeachPopView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSTeachPopDelegate.h"


#define IS_IOS8 [[UIDevice currentDevice] systemVersion].floatValue >= 8.0

@interface FigureRangeSetupViewController ()<UITextFieldDelegate,FSTeachPopDelegate,UIAlertViewDelegate>

@property (nonatomic) int searchNum;
@property (nonatomic) int currentOption;
@property (nonatomic) int kNumber;

@property (strong ,nonatomic) UILabel * titleLabel;
@property (strong ,nonatomic) UILabel * dayLabel;
@property (strong ,nonatomic) UILabel * weekLabel;
@property (strong ,nonatomic) UILabel * monthLabel;

@property (strong ,nonatomic) UITextField * dayText;
@property (strong ,nonatomic) UITextField * weekText;
@property (strong ,nonatomic) UITextField * monthText;

@property (strong ,nonatomic) UILabel * dayPercentLabel;
@property (strong ,nonatomic) UILabel * weekPercentLabel;
@property (strong ,nonatomic) UILabel * monthPercentLabel;

@property (strong ,nonatomic) UILabel * subTitleLabel;
@property (strong ,nonatomic) UILabel * rangeLabel;
@property (strong ,nonatomic) UILabel * colorLabel;
@property (strong ,nonatomic) UILabel * upLineLabel;
@property (strong ,nonatomic) UILabel * kLineLabel;
@property (strong ,nonatomic) UILabel * downLineLabel;

@property (strong ,nonatomic) FSUIButton * rangebtn;
@property (strong ,nonatomic) FSUIButton * colorbtn;
@property (strong ,nonatomic) FSUIButton * upLinebtn;
@property (strong ,nonatomic) FSUIButton * kLinebtn;
@property (strong ,nonatomic) FSUIButton * downLinebtn;

@property (strong) NSMutableArray * figureSearchArray;
@property (nonatomic) float high;
@property (nonatomic) float low;
@property (strong, nonatomic) FSTeachPopView * explainView;
@property (strong, nonatomic) FigureSearchMyProfileModel * customModel;
//@property (nonatomic,strong) FSUIButton * closeBtn;

@property (strong, nonatomic) UIAlertView *exitAlertView;
@property (strong, nonatomic) UIAlertController *exitAlertController;

@property (nonatomic) float forDD;
@property (nonatomic) float forWW;
@property (nonatomic) float forMM;

@property (strong, nonatomic) NSArray *theOriginTextFieldData;

@property (strong, nonatomic) UIAlertView *textFieldAlertView;
@property (strong, nonatomic) UIAlertController *textFieldAlertController;
@property (nonatomic) int whichTextFieldBeTapped; //FSFigureCustomTextFieldType

@end

@implementation FigureRangeSetupViewController

- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber dataArray:(NSMutableArray *)array kNumber:(int)kNumber
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.currentOption = current;
        self.searchNum = searchNumber;
        self.figureSearchArray =[[NSMutableArray alloc]init];
        _figureSearchArray = array;
        _kNumber = kNumber;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    //bug#11100  range轉成浮點數與整數形式比較兩者是否相同 判斷整數去小數點再顯示
    if([[_figureSearchArray objectAtIndex:2] floatValue]==[[_figureSearchArray objectAtIndex:2] intValue])
        _dayText.text = [NSString stringWithFormat:@"%d",[[_figureSearchArray objectAtIndex:2]intValue]];
    else
        _dayText.text =[NSString stringWithFormat:@"%.1f",[[_figureSearchArray objectAtIndex:2]floatValue]];
    
    if([[_figureSearchArray objectAtIndex:3] floatValue]==[[_figureSearchArray objectAtIndex:3] intValue])
        _weekText.text = [NSString stringWithFormat:@"%d",[[_figureSearchArray objectAtIndex:3]intValue]];
    else
        _weekText.text =[NSString stringWithFormat:@"%.1f",[[_figureSearchArray objectAtIndex:3]floatValue]];
    
    if([[_figureSearchArray objectAtIndex:4] floatValue]==[[_figureSearchArray objectAtIndex:4] intValue])
        _monthText.text = [NSString stringWithFormat:@"%d",[[_figureSearchArray objectAtIndex:4]intValue]];
    else
        _monthText.text =[NSString stringWithFormat:@"%.1f",[[_figureSearchArray objectAtIndex:4]floatValue]];
    
    //_weekText.text = [_figureSearchArray objectAtIndex:3];
    //_monthText.text = [_figureSearchArray objectAtIndex:4];
    _theOriginTextFieldData = [NSArray arrayWithObjects:_dayText.text, _weekText.text, _monthText.text, nil];
    //被註解起來的內容改在FigureCustomDetailViewController，以其他方式實作
//    NSMutableArray * conditionArray = [_customModel searchkBarConditionsWithFigureSearchId:[_figureSearchArray objectAtIndex:0] tNumber:[NSNumber numberWithInt:_kNumber]];
//    if ([conditionArray count]==0) {
//        _rangebtn.selected = YES;
//        _colorbtn.selected = YES;
//        _upLinebtn.selected = NO;
//        _kLinebtn.selected = YES;
//        _downLinebtn.selected = NO;
//    }else{
//        if ([[conditionArray objectAtIndex:0]boolValue]) {
//            _rangebtn.selected = YES;
//        }
//        if ([[conditionArray objectAtIndex:1]boolValue]) {
//            _colorbtn.selected = YES;
//        }
//        if ([[conditionArray objectAtIndex:2]boolValue]) {
//            _upLinebtn.selected = YES;
//        }
//        if ([[conditionArray objectAtIndex:3]boolValue]) {
//            _kLinebtn.selected = YES;
//        }
//        if ([[conditionArray objectAtIndex:4]boolValue]) {
//            _downLinebtn.selected = YES;
//        }
//    }
    
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)alertControllerAction:(int)target sender:(UIAlertController *)sender
{
    if(sender == _exitAlertController){
        if(target == 1){
            if (!([(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]==[(NSNumber *)_dayText.text floatValue])) {
                for (int i=0; i<5; i++) {
                    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
                    dataArray = [_customModel searchCustomKbarWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:i]];
                    if (![dataArray count]==0) {
                        float high;
                        float low;
                        float open;
                        float close;
                        
                        
                        if ([(NSNumber *)[dataArray objectAtIndex:0]floatValue]*100>[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                            high = ([(NSNumber *)[dataArray objectAtIndex:0]floatValue]-0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])+0.01;
                        }else{
                            high = [(NSNumber *)[dataArray objectAtIndex:0]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                        }
                        if ([(NSNumber *)[dataArray objectAtIndex:1]floatValue]*100<0-[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                            low = ([(NSNumber *)[dataArray objectAtIndex:1]floatValue]+0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])-0.01;
                        }else{
                            low = [(NSNumber *)[dataArray objectAtIndex:1]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                        }
                        
                        if ([(NSNumber *)[dataArray objectAtIndex:2]floatValue]*100>[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                            open = ([(NSNumber *)[dataArray objectAtIndex:2]floatValue]-0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])+0.01;
                        }else if([(NSNumber *)[dataArray objectAtIndex:2]floatValue]*100<0-[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]){
                            open = ([(NSNumber *)[dataArray objectAtIndex:2]floatValue]+0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])-0.01;
                        }else {
                            open = [(NSNumber *)[dataArray objectAtIndex:2]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                        }
                        if ([(NSNumber *)[dataArray objectAtIndex:3]floatValue]*100>[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                            close = ([(NSNumber *)[dataArray objectAtIndex:3]floatValue]-0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])+0.01;
                        }else if([(NSNumber *)[dataArray objectAtIndex:3]floatValue]*100<0-[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]){
                            close = ([(NSNumber *)[dataArray objectAtIndex:3]floatValue]+0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])-0.01;
                        }else{
                            close = [(NSNumber *)[dataArray objectAtIndex:3]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                        }
                        
                        [_customModel editKbarValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:i] High:[NSNumber numberWithFloat:high] Low:[NSNumber numberWithFloat:low] Open:[NSNumber numberWithFloat:open] Close:[NSNumber numberWithFloat:close]];
                    }
                }
            }
            [_customModel updateRangeWithFigureSearchId:[_figureSearchArray objectAtIndex:0] DayRange:[NSNumber numberWithFloat:[(NSNumber *)_dayText.text floatValue]] WeekRange:[NSNumber numberWithFloat:[(NSNumber *)_weekText.text floatValue]] MonthRange:[NSNumber numberWithFloat:[(NSNumber *)_monthText.text floatValue]]];
            [self.navigationController popViewControllerAnimated:NO];
        }else {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }else if(sender == _textFieldAlertController){
        if(target == 1){
            CGFloat limit = 0.0;
            NSArray *textFieldArray = [NSArray arrayWithObjects:_dayText, _weekText, _monthText, nil];
            //取得日、週、月各自的上限值
            NSArray *sgInfoContentArray = [NSArray arrayWithObjects:@"日設定值超過上限",@"週設定值超過上限",@"月設定值超過上限", nil];
            switch(_whichTextFieldBeTapped){
                case FSFigureCustomTextFieldTypeDaily: limit = _forDD; break;
                case FSFigureCustomTextFieldTypeWeekly: limit = _forWW; break;
                case FSFigureCustomTextFieldTypeMonthly: limit = _forMM; break;
                default:
                    break;
            }
            UITextField *textTextField = sender.textFields.firstObject;
            //如果使用者輸入的數值在範圍內，則將該數值透過程式塞回給textField，否則跳出sgInfoAlert
            if(([(NSNumber *)textTextField.text floatValue] > 0.0)&&([(NSNumber *)textTextField.text floatValue] <= limit)){
                if([(NSNumber *)textTextField.text floatValue]==[(NSNumber *)textTextField.text intValue])
                    ((UITextField*)[textFieldArray objectAtIndex:_whichTextFieldBeTapped]).text =[NSString stringWithFormat:@"%d",[(NSNumber *)textTextField.text intValue] ];
                else
                    ((UITextField*)[textFieldArray objectAtIndex:_whichTextFieldBeTapped]).text = [NSString stringWithFormat:@"%.1f",[(NSNumber *)textTextField.text floatValue]];
            }
            //bug#10725 wiser start
            else if ([textTextField.text isEqualToString:@""]){
                [FSHUD showMsg:[NSString stringWithFormat:NSLocalizedStringFromTable(@"請輸入數值", @"FigureSearch", nil),limit]];
            }
            //bug#10725 wiser end
            else{
                [FSHUD showMsg:[NSString stringWithFormat:NSLocalizedStringFromTable([sgInfoContentArray objectAtIndex:_whichTextFieldBeTapped], @"FigureSearch", nil),limit]];
            }
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == _exitAlertView && buttonIndex == 1){
        if (!([(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]==[(NSNumber *)_dayText.text floatValue])) {
            for (int i=0; i<5; i++) {
                NSMutableArray * dataArray = [[NSMutableArray alloc]init];
                dataArray = [_customModel searchCustomKbarWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:i]];
                if (![dataArray count]==0) {
                    float high;
                    float low;
                    float open;
                    float close;
                    
                    
                    if ([(NSNumber *)[dataArray objectAtIndex:0]floatValue]*100>[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                        high = ([(NSNumber *)[dataArray objectAtIndex:0]floatValue]-0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])+0.01;
                    }else{
                        high = [(NSNumber *)[dataArray objectAtIndex:0]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                    }
                    if ([(NSNumber *)[dataArray objectAtIndex:1]floatValue]*100<0-[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                        low = ([(NSNumber *)[dataArray objectAtIndex:1]floatValue]+0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])-0.01;
                    }else{
                        low = [(NSNumber *)[dataArray objectAtIndex:1]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                    }
                    
                    if ([(NSNumber *)[dataArray objectAtIndex:2]floatValue]*100>[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                        open = ([(NSNumber *)[dataArray objectAtIndex:2]floatValue]-0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])+0.01;
                    }else if([(NSNumber *)[dataArray objectAtIndex:2]floatValue]*100<0-[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]){
                        open = ([(NSNumber *)[dataArray objectAtIndex:2]floatValue]+0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])-0.01;
                    }else {
                        open = [(NSNumber *)[dataArray objectAtIndex:2]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                    }
                    if ([(NSNumber *)[dataArray objectAtIndex:3]floatValue]*100>[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]) {
                        close = ([(NSNumber *)[dataArray objectAtIndex:3]floatValue]-0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])+0.01;
                    }else if([(NSNumber *)[dataArray objectAtIndex:3]floatValue]*100<0-[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]){
                        close = ([(NSNumber *)[dataArray objectAtIndex:3]floatValue]+0.01)*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue])-0.01;
                    }else{
                        close = [(NSNumber *)[dataArray objectAtIndex:3]floatValue]*([(NSNumber *)_dayText.text floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
                    }
                    
                    [_customModel editKbarValueWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:i] High:[NSNumber numberWithFloat:high] Low:[NSNumber numberWithFloat:low] Open:[NSNumber numberWithFloat:open] Close:[NSNumber numberWithFloat:close]];
                }
            }
        }
        [_customModel updateRangeWithFigureSearchId:[_figureSearchArray objectAtIndex:0] DayRange:[NSNumber numberWithFloat:[(NSNumber *)_dayText.text floatValue]] WeekRange:[NSNumber numberWithFloat:[(NSNumber *)_weekText.text floatValue]] MonthRange:[NSNumber numberWithFloat:[(NSNumber *)_monthText.text floatValue]]];
        [self.navigationController popViewControllerAnimated:NO];
    }else if(alertView == _exitAlertView && buttonIndex == 0){
        [self.navigationController popViewControllerAnimated:NO];
    }
    //只在按下alertView 的確認鍵時才做檢查的動作
    if(alertView == _textFieldAlertView){
        if(!(buttonIndex == 1)) return;
        CGFloat limit = 0.0;
        NSArray *textFieldArray = [NSArray arrayWithObjects:_dayText, _weekText, _monthText, nil];
        //取得日、週、月各自的上限值
        NSArray *sgInfoContentArray = [NSArray arrayWithObjects:@"日設定值超過上限",@"週設定值超過上限",@"月設定值超過上限", nil];
        switch(_whichTextFieldBeTapped){
            case FSFigureCustomTextFieldTypeDaily: limit = _forDD; break;
            case FSFigureCustomTextFieldTypeWeekly: limit = _forWW; break;
            case FSFigureCustomTextFieldTypeMonthly: limit = _forMM; break;
            default:
                break;
        }
        //如果使用者輸入的數值在範圍內，則將該數值透過程式塞回給textField，否則跳出sgInfoAlert
        if(([(NSNumber *)[alertView textFieldAtIndex:0].text floatValue] > 0.0)&&([(NSNumber *)[alertView textFieldAtIndex:0].text floatValue] <= limit)){
            ((UITextField*)[textFieldArray objectAtIndex:_whichTextFieldBeTapped]).text = [NSString stringWithFormat:@"%.1f",[(NSNumber *)[alertView textFieldAtIndex:0].text floatValue]];
        }
        //bug#10725 wiser start
        else if ([[alertView textFieldAtIndex:0].text isEqualToString:@""]){
            [FSHUD showMsg:[NSString stringWithFormat:NSLocalizedStringFromTable(@"請輸入數值", @"FigureSearch", nil),limit]];
        }
        //bug#10725 wiser end
        else{
            [FSHUD showMsg:[NSString stringWithFormat:NSLocalizedStringFromTable([sgInfoContentArray objectAtIndex:_whichTextFieldBeTapped], @"FigureSearch", nil),limit]];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setBackBtn];
    
    self.navigationItem.title = NSLocalizedStringFromTable(@"漲跌幅設定", @"FigureSearch", nil);
    _high = 0;
    _low = 0;
    [self initView];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    [self.view setNeedsUpdateConstraints];
    NSString * show = [_customModel searchInstructionByControllerName:[[self class] description]];
    if ([show isEqualToString:@"YES"]) {
        [self teachPop];
    }
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    //依各個市場設定可容許的最大幅度
    if([group isEqualToString:@"tw"]){
        _forDD = 10;
        _forWW = 35;
        _forMM = 100;
    }else{
        _forDD = 100;
        _forWW = 200;
        _forMM = 300;
    }
	// Do any additional setup after loading the view.
}

-(void)setBackBtn
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backButtonView = [[UIView alloc] init];
    [backButtonView addSubview:backButton];
    [backButtonView setFrame:CGRectMake(0, 0, 33, 33)];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
}

//用_theOriginTextFieldData 儲存本viewController 一呈現時，三個textField 所顯示的值
//而欲跳回前一頁時，才讓_theOriginTextFieldData 與目前的textField 所儲存的值進行比較
//只是將三個textField 的值儲存在currentTextFieldData 裡，直接進行array 與array 的比較
- (void)popCurrentViewController {
    NSArray *currentTextFieldData = [NSArray arrayWithObjects:_dayText.text, _weekText.text, _monthText.text, nil];
    if(![_theOriginTextFieldData isEqualToArray:currentTextFieldData]){
        if(IS_IOS8){
            _exitAlertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTable(@"漲跌幅已更新，是否要儲存？", @"FigureSearch", nil) preferredStyle:UIAlertControllerStyleAlert];
            [_exitAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"否", @"FigureSearch", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self alertControllerAction:0 sender:_exitAlertController];}]];
            [_exitAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self alertControllerAction:1 sender:_exitAlertController];}]];
            [self presentViewController:_exitAlertController animated:YES completion:nil];
        }else{
            _exitAlertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"漲跌幅已更新，是否要儲存？", @"FigureSearch", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"否", @"FigureSearch", nil),
                              NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
            [_exitAlertView show];
        }
    }else{
        [self.navigationController popViewControllerAnimated:NO];
    }
}


- (void)updateViewConstraints {
    
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_titleLabel,_dayLabel,_weekLabel,_monthLabel,_dayText,_weekText,_monthText,_dayPercentLabel,_weekPercentLabel,_monthPercentLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleLabel(30)]-5-[_dayLabel(30)]-5-[_weekLabel(30)]-5-[_monthLabel(30)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_titleLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_dayLabel(90)]-5-[_dayText]-5-[_dayPercentLabel(20)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_weekLabel(90)]-5-[_weekText]-5-[_weekPercentLabel(20)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_monthLabel(90)]-5-[_monthText]-5-[_monthPercentLabel(20)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [super updateViewConstraints];
}

-(void)initView{
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = NSLocalizedStringFromTable(@"設定最大幅度", @"FigureSearch", nil);
    [self.view addSubview:_titleLabel];
    
    self.dayLabel = [[UILabel alloc]init];
    _dayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dayLabel.text = NSLocalizedStringFromTable(@"日K", @"FigureSearch", nil);
    _dayLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_dayLabel];
    
    self.weekLabel = [[UILabel alloc]init];
    _weekLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _weekLabel.text = NSLocalizedStringFromTable(@"週K", @"FigureSearch", nil);
    _weekLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_weekLabel];

    
    self.monthLabel = [[UILabel alloc]init];
    _monthLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _monthLabel.text = NSLocalizedStringFromTable(@"月K", @"FigureSearch", nil);
    _monthLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_monthLabel];
    
    self.dayText = [[UITextField alloc]init];
    _dayText.translatesAutoresizingMaskIntoConstraints = NO;
    _dayText.delegate = self;
    _dayText.borderStyle = UITextBorderStyleRoundedRect;
    _dayText.textAlignment = NSTextAlignmentCenter;
    _dayText.keyboardType = UIKeyboardTypeDecimalPad;
    [self.view addSubview:_dayText];
    
    self.weekText = [[UITextField alloc]init];
    _weekText.translatesAutoresizingMaskIntoConstraints = NO;
    _weekText.delegate = self;
    _weekText.borderStyle = UITextBorderStyleRoundedRect;
    _weekText.textAlignment = NSTextAlignmentCenter;
    _weekText.keyboardType = UIKeyboardTypeDecimalPad;
    [self.view addSubview:_weekText];
    
    self.monthText = [[UITextField alloc]init];
    _monthText.translatesAutoresizingMaskIntoConstraints = NO;
    _monthText.delegate = self;
    _monthText.borderStyle = UITextBorderStyleRoundedRect;
    _monthText.textAlignment = NSTextAlignmentCenter;
    _monthText.keyboardType = UIKeyboardTypeDecimalPad;
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
    
    //被註解起來的內容改在FigureCustomDetailViewController，以其他方式實作
//    self.subTitleLabel = [[UILabel alloc]init];
//    _subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _subTitleLabel.text = NSLocalizedStringFromTable(@"設定篩選條件", @"FigureSearch", nil);
//    _subTitleLabel.numberOfLines = 2;
//    [self.view addSubview:_subTitleLabel];
    
//    self.rangebtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
//    _rangebtn.selected = NO;
//    _rangebtn.translatesAutoresizingMaskIntoConstraints = NO;
//    [self initCheckBtnWithButton:_rangebtn];
//    [self.view addSubview:_rangebtn];
    
//    self.rangeLabel = [[UILabel alloc]init];
//    _rangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _rangeLabel.text = NSLocalizedStringFromTable(@"Change Range", @"FigureSearch", nil);
//    _rangeLabel.numberOfLines = 2;
//    [self.view addSubview:_rangeLabel];
    
//    self.colorbtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
//    _colorbtn.selected = NO;
//    _colorbtn.translatesAutoresizingMaskIntoConstraints = NO;
//    [self initCheckBtnWithButton:_colorbtn];
//    [self.view addSubview:_colorbtn];
    
//    self.colorLabel = [[UILabel alloc]init];
//    _colorLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _colorLabel.text = NSLocalizedStringFromTable(@"紅黑K", @"FigureSearch", nil);
//    [self.view addSubview:_colorLabel];
    
//    self.upLinebtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
//    _upLinebtn.selected = NO;
//    _upLinebtn.translatesAutoresizingMaskIntoConstraints = NO;
//    [self initCheckBtnWithButton:_upLinebtn];
//    [self.view addSubview:_upLinebtn];
    
//    self.upLineLabel = [[UILabel alloc]init];
//    _upLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _upLineLabel.text = NSLocalizedStringFromTable(@"上影線", @"FigureSearch", nil);
//    [self.view addSubview:_upLineLabel];
    
//    self.kLinebtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
//    _kLinebtn.selected = NO;
//    _kLinebtn.translatesAutoresizingMaskIntoConstraints = NO;
//    [self initCheckBtnWithButton:_kLinebtn];
//    [self.view addSubview:_kLinebtn];
    
//    self.kLineLabel = [[UILabel alloc]init];
//    _kLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _kLineLabel.text = NSLocalizedStringFromTable(@"實體線", @"FigureSearch", nil);
//    [self.view addSubview:_kLineLabel];
    
//    self.downLinebtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
//    _downLinebtn.selected = NO;
//    _downLinebtn.translatesAutoresizingMaskIntoConstraints = NO;
//    [self initCheckBtnWithButton:_downLinebtn];
//    [self.view addSubview:_downLinebtn];
    
//    self.downLineLabel = [[UILabel alloc]init];
//    _downLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    _downLineLabel.text = NSLocalizedStringFromTable(@"下影線", @"FigureSearch", nil);
//    [self.view addSubview:_downLineLabel];

//    self.closeBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
//    _closeBtn.translatesAutoresizingMaskIntoConstraints = YES;
//    [_closeBtn setFrame: CGRectMake(240, self.view.frame.size.height-310, 70, 30)];
//    [_closeBtn addTarget:self action:@selector(closeKeyBoard) forControlEvents:UIControlEventTouchUpInside];
//    [_closeBtn setTitle:NSLocalizedStringFromTable(@"關閉", @"SecuritySearch", nil) forState:UIControlStateNormal];
//    [self.view addSubview:_closeBtn];
//    _closeBtn.hidden = YES;
}

- (void)initCheckBtnWithButton:(FSUIButton *)button {
    
    [button addTarget:self action:@selector(CheckBoxClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)CheckBoxClick:(FSUIButton *)btn{
    btn.selected = !btn.selected;
}

//按下textField 後，跳出一個讓使用者輸入欲修改百分比數值的alertView，而return NO 則是讓textField 不可直接直接被編輯
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == _dayText){
        _whichTextFieldBeTapped = FSFigureCustomTextFieldTypeDaily;
        [self callTheTextFieldAlertView];
        return NO;
    }
    if(textField == _weekText){
        _whichTextFieldBeTapped = FSFigureCustomTextFieldTypeWeekly;
        [self callTheTextFieldAlertView];
        return NO;
    }
    if(textField == _monthText){
        _whichTextFieldBeTapped = FSFigureCustomTextFieldTypeMonthly;
        [self callTheTextFieldAlertView];
        return NO;
    }
    
    return YES;
}

//限制按下dayText 等三個textField後跳出的alertView 的可輸入字元長度不得大於 8
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(textField == [_textFieldAlertView textFieldAtIndex:0] ||
       textField == _textFieldAlertController.textFields.firstObject){
        if(newString.length > 8){
            return NO;
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//按下dayText 等textField 後欲跳出的alertView
-(BOOL)callTheTextFieldAlertView
{
    if(IS_IOS8){
        _textFieldAlertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [_textFieldAlertController addTextFieldWithConfigurationHandler:nil];
        [_textFieldAlertController.textFields[0] setKeyboardType:UIKeyboardTypeDecimalPad];
//        [_textFieldAlertController.textFields[0] becomeFirstResponder];
        [_textFieldAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){[self alertControllerAction:0 sender:_textFieldAlertController];}]];
        [_textFieldAlertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"確認", @"FigureSearch", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){[self alertControllerAction:1 sender:_textFieldAlertController];}]];
        [self presentViewController:_textFieldAlertController animated:YES completion:nil];
    }else{
        _textFieldAlertView = [[UIAlertView alloc] initWithTitle:@"" message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
        [_textFieldAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [_textFieldAlertView textFieldAtIndex:0].delegate = self;
        [[_textFieldAlertView textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
        [[_textFieldAlertView textFieldAtIndex:0] becomeFirstResponder];
        [_textFieldAlertView show];
    }
    return NO;
}

-(void)closeKeyBoard{
    [_dayText resignFirstResponder];
    [_weekText resignFirstResponder];
    [_monthText resignFirstResponder];
}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];

    [_explainView showMenuWithRect:CGRectMake(150,140, 0, 0) String:NSLocalizedStringFromTable(@"設定K棒", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(150,100, 30, 56)];
    [_explainView showMenuWithRect:CGRectMake(20, 305, 0, 0) String:NSLocalizedStringFromTable(@"選擇搜尋條件", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionUp];
    
}

-(void)closeTeachPop:(UIView *)view{
    //存資料庫
    [view removeFromSuperview];
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    if (teachPopView.checkBtn.selected) {
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"NO"];
    }else{
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"YES"];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
