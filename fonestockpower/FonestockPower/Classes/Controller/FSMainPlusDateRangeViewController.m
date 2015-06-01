//
//  FSMainPlusDateRangeViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/26.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainPlusDateRangeViewController.h"
#import "FSRadioButtonSet.h"
#import "TSQCalendarView.h"
#import "FSMainPlusOut.h"
#import "TSQCalendarView.h"
#import "TSQTACalendarRowCell.h"
#import "CustomIOS7AlertView.h"
#import "CYQModel.h"

@interface FSMainPlusDateRangeViewController ()<FSRadioButtonSetDelegate,TSQCalendarViewDelegate >{

    UILabel *pickDateRange;
    
    FSRadioButtonSet *radioBtnController;
    
//    option 1
    UILabel *recentlyDateOf;
    UIButton *optionBtn1;
    FSUIButton *todayBtn;
    FSUIButton *fiveDaysBtn;
    FSUIButton *tenDaysBtn;
    FSUIButton *twentyDaysBtn;
    FSUIButton *confirmBtn;
    
//    option 2
    UILabel *startAndEndDay;
    UILabel *wave;
    UIButton *optionBtn2;
    FSUIButton *startDateBtn;
    FSUIButton *endDateBtn;
    TSQCalendarView *calendarView;
    UILabel *dateIndicatorLabel;
    int pickDays;

    NSString *symbol;
    int sortType;
    
    CustomIOS7AlertView *custAlert;
    FSDataModelProc *dataModel;

}
enum DateButtonMode {
    DateButtonStartDateMode,
    DateButtonEndDateMode
};
@property (unsafe_unretained, nonatomic) enum DateButtonMode dateButtonMode;

@end

@implementation FSMainPlusDateRangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}



-(void)initView{
    [self varInit];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *today = [NSDate date];
    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    int year = (int)[comps year];
    int month = (int)[comps month];
    int day = (int)[comps day];
    
    pickDateRange = [[UILabel alloc]init];
    pickDateRange.text = @"選擇資料期間";
    pickDateRange.textAlignment = NSTextAlignmentCenter;
    pickDateRange.textColor = [UIColor brownColor];
    pickDateRange.font = [UIFont systemFontOfSize:22.0f];
    pickDateRange.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pickDateRange];
    
    recentlyDateOf = [[UILabel alloc]init];
    recentlyDateOf.text =@"由最近日期算起1天內";
    recentlyDateOf.textAlignment = NSTextAlignmentLeft;
    recentlyDateOf.textColor = [UIColor brownColor];
    recentlyDateOf.font = [UIFont systemFontOfSize:22.0f];
    recentlyDateOf.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:recentlyDateOf];
    
    startAndEndDay = [[UILabel alloc]init];
    startAndEndDay.text =@"起始日～截止日";
    startAndEndDay.textAlignment = NSTextAlignmentLeft;
    startAndEndDay.textColor = [UIColor brownColor];
    startAndEndDay.font = [UIFont systemFontOfSize:22.0f];
    startAndEndDay.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:startAndEndDay];
    
    wave = [[UILabel alloc]init];
    wave.text =@"～";
    wave.textAlignment = NSTextAlignmentLeft;
    wave.textColor = [UIColor brownColor];
    wave.font = [UIFont systemFontOfSize:22.0f];
    wave.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:wave];
    
    optionBtn1 = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeRadio];
    optionBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:optionBtn1];
    
    optionBtn2 = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeRadio];
    optionBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:optionBtn2];
    
    todayBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    todayBtn.translatesAutoresizingMaskIntoConstraints = NO;
    todayBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [todayBtn setTitle:@"當日" forState:UIControlStateNormal];
    [todayBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:todayBtn];
    
    fiveDaysBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    fiveDaysBtn.translatesAutoresizingMaskIntoConstraints = NO;
    fiveDaysBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [fiveDaysBtn setTitle:@"5日" forState:UIControlStateNormal];
    [fiveDaysBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fiveDaysBtn];
    
    tenDaysBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    tenDaysBtn.translatesAutoresizingMaskIntoConstraints = NO;
    tenDaysBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [tenDaysBtn setTitle:@"10日" forState:UIControlStateNormal];
    [tenDaysBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tenDaysBtn];
    
    twentyDaysBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    twentyDaysBtn.translatesAutoresizingMaskIntoConstraints = NO;
    twentyDaysBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [twentyDaysBtn setTitle:@"20日" forState:UIControlStateNormal];
    [twentyDaysBtn addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twentyDaysBtn];
    
    confirmBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    confirmBtn.translatesAutoresizingMaskIntoConstraints = NO;
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [confirmBtn setTitle:@"確定" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(exitHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    
    startDateBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    startDateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    startDateBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [startDateBtn setTitle:[NSString stringWithFormat:@"%d/%d/%d", year, month, day-1] forState:UIControlStateNormal];
    [startDateBtn addTarget:self action:@selector(startDateBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startDateBtn];
    
    endDateBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    endDateBtn.translatesAutoresizingMaskIntoConstraints = NO;
    endDateBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [endDateBtn setTitle:[NSString stringWithFormat:@"%d/%d/%d", year, month, day-1] forState:UIControlStateNormal];
    [endDateBtn addTarget:self action:@selector(endDateBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:endDateBtn];
    
    radioBtnController = [[FSRadioButtonSet alloc]init];
    radioBtnController.delegate = self;
    radioBtnController.buttons = @[optionBtn1, optionBtn2];
    
//    calendar
    UIView *calenderAlertView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 316)];
    
    calendarView = [[TSQCalendarView alloc]init];
    calendarView.frame = CGRectMake(0, 22, 320, 296);
    calendarView.delegate = self;
    calendarView.calendar = [NSCalendar currentCalendar];
    int startDateVal = [(NSNumber *)[dataModel.cyqModel.dateArray objectAtIndex:0] intValue];
    
    calendarView.firstDate = [[NSNumber numberWithInt:startDateVal] uint16ToDate];
    calendarView.lastDate = [NSDate date];
    calendarView.rowCellClass = [TSQTACalendarRowCell class];
    calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    
    calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    
    dateIndicatorLabel = [[UILabel alloc] init];
    dateIndicatorLabel.frame = CGRectMake(0, 0, 320, 22);
    dateIndicatorLabel.text = @"起始日";
    dateIndicatorLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    dateIndicatorLabel.textColor = [UIColor whiteColor];
    dateIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    dateIndicatorLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:132.0f/255.0f alpha:1.0f];
    
    [calenderAlertView addSubview:calendarView];
    [calenderAlertView addSubview:dateIndicatorLabel];
    
    custAlert = [[CustomIOS7AlertView alloc] init];
    [custAlert setButtonTitles:@[@"關閉"]];
    [custAlert setContainerView:calenderAlertView];

//    btnRecover
    [self whichBtnIsSelected:dataModel.cyqModel.pickDays];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *dateConstraints = [[NSMutableArray alloc]init];
    NSDictionary *dateViewArray = NSDictionaryOfVariableBindings(pickDateRange, recentlyDateOf, todayBtn, fiveDaysBtn, tenDaysBtn, twentyDaysBtn, confirmBtn, optionBtn1, optionBtn2, startDateBtn, endDateBtn, startAndEndDay, wave);
    
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pickDateRange]|" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[optionBtn1(35)]-[recentlyDateOf]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[todayBtn][fiveDaysBtn(todayBtn)][tenDaysBtn(fiveDaysBtn)][twentyDaysBtn(tenDaysBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dateViewArray]];
    
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[confirmBtn]-60-|" options:0 metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[optionBtn2(35)]-[startAndEndDay]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dateViewArray]];
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[startDateBtn(120)]-[wave]-[endDateBtn(120)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dateViewArray]];
    
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[pickDateRange]-10-[optionBtn1(35)]-[todayBtn]" options:0 metrics:nil views:dateViewArray]];
    
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[optionBtn2(35)]-5-[startDateBtn]" options:0 metrics:nil views:dateViewArray]];

    
    [dateConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[confirmBtn]|" options:0 metrics:nil views:dateViewArray]];
    
    [self replaceCustomizeConstraints:dateConstraints];
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    switch (dataModel.cyqModel.mainPlusAccumulateOptionType) {
        case MainPlusAcuumulateOptionTypeRecently:
            radioBtnController.selectedIndex = MainPlusAcuumulateOptionTypeRecently;
            break;
        case MainPlusAcuumulateOptionTypeCalendar:
            radioBtnController.selectedIndex = MainPlusAcuumulateOptionTypeCalendar;
            break;
        default:
            break;
    }
    
    calendarView.selectedDate = dataModel.cyqModel.startDate;
}
- (void)varInit {
    dataModel = [FSDataModelProc sharedInstance];
    if (dataModel.cyqModel.startDate == nil || dataModel.cyqModel.endDate == nil) {
        if ([dataModel.cyqModel.dateArray count] > 0) {
            int dateVal = [(NSNumber *)[dataModel.cyqModel.dateArray lastObject] intValue];
            dataModel.cyqModel.startDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
            dataModel.cyqModel.endDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
        }
    }
}
-(void)btnHandler:(UIButton *)sender{
    radioBtnController.selectedIndex = MainPlusAcuumulateOptionTypeRecently;
    dataModel.cyqModel.mainPlusAccumulateOptionType = MainPlusAcuumulateOptionTypeRecently;
    todayBtn.selected = NO;
    fiveDaysBtn.selected = NO;
    tenDaysBtn.selected = NO;
    twentyDaysBtn.selected = NO;

    sender.selected = YES;

    if (todayBtn.selected) {
        recentlyDateOf.text =@"由最近日期算起1天內";
        pickDays = 1;
    }else if (fiveDaysBtn.selected){
        recentlyDateOf.text =@"由最近日期算起5天內";
        pickDays = 5;
    }else if (tenDaysBtn.selected){
        recentlyDateOf.text =@"由最近日期算起10天內";
        pickDays = 10;
    }else{
        recentlyDateOf.text =@"由最近日期算起20天內";
        pickDays = 20;
    }

}
-(void)whichBtnIsSelected:(int)idx{
    switch (idx) {
        case 1:
            todayBtn.selected = YES;
            recentlyDateOf.text =@"由最近日期算起1天內";
            break;
        case 5:
            fiveDaysBtn.selected = YES;
            recentlyDateOf.text =@"由最近日期算起5天內";
            break;
        case 10:
            tenDaysBtn.selected = YES;
            recentlyDateOf.text =@"由最近日期算起10天內";
            break;
        case 20:
            twentyDaysBtn.selected = YES;
            recentlyDateOf.text =@"由最近日期算起20天內";
            break;
        default:
            break;
    }
}
-(void)startDateBtnHandler{
    radioBtnController.selectedIndex = MainPlusAcuumulateOptionTypeCalendar;
    dataModel.cyqModel.mainPlusAccumulateOptionType = MainPlusAcuumulateOptionTypeCalendar;
    
    _dateButtonMode = DateButtonStartDateMode;
    
    dateIndicatorLabel.text = @"起始日";
    calendarView.selectedDate = dataModel.cyqModel.startDate;
    
    [custAlert show];
}

-(void)endDateBtnHandler{
    radioBtnController.selectedIndex = MainPlusAcuumulateOptionTypeCalendar;
    dataModel.cyqModel.mainPlusAccumulateOptionType = MainPlusAcuumulateOptionTypeCalendar;
    
    _dateButtonMode = DateButtonEndDateMode;
    
    dateIndicatorLabel.text = @"截止日";
    calendarView.selectedDate = dataModel.cyqModel.endDate;
    
    [custAlert show];

}

-(void)exitHandler{
    
    dataModel.cyqModel.pickDays = pickDays;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidLayoutSubviews {
    [calendarView scrollToDate:dataModel.cyqModel.startDate animated:NO];
    
}

-(void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex{
    if (selectedIndex == 0) {
        dataModel.cyqModel.mainPlusAccumulateOptionType = MainPlusAcuumulateOptionTypeRecently;
    }else if(selectedIndex == 1){
        dataModel.cyqModel.mainPlusAccumulateOptionType = MainPlusAcuumulateOptionTypeCalendar;
    }
}

- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectDate:(NSDate *)date {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [currentCalendar components:NSWeekdayCalendarUnit fromDate:date];
    if ([weekdayComponents weekday] == 1 || [weekdayComponents weekday] == 7) {
        return NO;
    }
    
    if (_dateButtonMode == DateButtonStartDateMode) {
        
        if ([date compare:dataModel.cyqModel.endDate] == NSOrderedAscending) {
            return YES;
        } else if ([date compare:dataModel.cyqModel.endDate] == NSOrderedSame) {
            return YES;
        }
        
    } else if (_dateButtonMode == DateButtonEndDateMode) {
        if ([date compare:dataModel.cyqModel.startDate] == NSOrderedDescending) {
            return YES;
        } else if ([date compare:dataModel.cyqModel.startDate] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date {
    
    if (_dateButtonMode == DateButtonStartDateMode) {
        dataModel.cyqModel.startDate = date;
    } else if (_dateButtonMode == DateButtonEndDateMode) {
        dataModel.cyqModel.endDate = date;
    }
    dataModel.cyqModel.mainPlusAccumulateOptionType = MainPlusAcuumulateOptionTypeCalendar;
    
    [self showDate];
}

- (void)showDate {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *startDateDateComponents =
    [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                           ) fromDate:dataModel.cyqModel.startDate];
    
    NSString *startDateString = [[NSString alloc] initWithFormat:@"%d/%d/%d",
                                 (int)[startDateDateComponents year],
                                 (int)[startDateDateComponents month],
                                 (int)[startDateDateComponents day]];
    
    NSDateComponents *endDateDateComponents =
    [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                           ) fromDate:dataModel.cyqModel.endDate];
    
    NSString *endDateString = [[NSString alloc] initWithFormat:@"%d/%d/%d",
                               (int)[endDateDateComponents year],
                               (int)[endDateDateComponents month],
                               (int)[endDateDateComponents day]];
    
    [startDateBtn setTitle:startDateString forState:UIControlStateNormal];
    [endDateBtn setTitle:endDateString forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
