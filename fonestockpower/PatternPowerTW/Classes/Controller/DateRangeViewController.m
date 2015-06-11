//
//  DateRangeViewController2.m
//  Bullseye
//
//  Created by Connor on 13/9/3.
//
//

#import "DateRangeViewController.h"
#import "TSQCalendarView.h"
#import "TSQTACalendarRowCell.h"
#import "CYQModel.h"
#import "UIView+NewComponent.h"
#import "FSDataModelProc.h"
#import "CustomIOS7AlertView.h"

@interface DateRangeViewController () {
    NSMutableArray *layoutConstraints;
    CustomIOS7AlertView *custAlert;
}

enum DateButtonMode {
    DateButtonStartDateMode,
    DateButtonEndDateMode
};

// 利用按鈕 切換 日曆的 起始日與截止日 mode
@property (unsafe_unretained, nonatomic) enum DateButtonMode dateButtonMode;

// radio button
@property (strong, nonatomic) FSRadioButtonSet *radioButtonSetController;

// option 1
@property (strong, nonatomic) UIButton *optionButton1;
@property (strong, nonatomic) UILabel *optionLabel1;
@property (strong, nonatomic) FSUIButton *startDateButton;
@property (strong, nonatomic) FSUIButton *endDateButton;
@property (strong, nonatomic) UILabel *tildeSymbol;

// 日曆
@property (strong, nonatomic) TSQCalendarView *calendarView;
@property (strong, nonatomic) UILabel *dateIndicatorLabel;


// optionButton2
@property (strong, nonatomic) UIButton *optionButton2;
@property (strong, nonatomic) UILabel *optionLabel2;
@property (strong, nonatomic) UILabel *optionLabel2_2;

@property (strong, nonatomic) FSUIButton *addDateRangeButton;
@property (strong, nonatomic) FSUIButton *minusDateRangeButton;

@property (strong, nonatomic) UILabel *dayRangeNumberLabel;
@property (strong, nonatomic) UILabel *dayRangeLabel;

@property (unsafe_unretained, nonatomic) NSInteger recentDay;

// 儲存與關閉
@property (strong, nonatomic) FSUIButton *saveAndExitButton;

@property (weak, nonatomic) FSDataModelProc *dataModel;

@end

@implementation DateRangeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)varInit {
    _dataModel = [FSDataModelProc sharedInstance];
    if (_dataModel.cyqModel.startDate == nil || _dataModel.cyqModel.endDate == nil) {
        if ([_dataModel.cyqModel.dateArray count] > 0) {
            int dateVal = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
            _dataModel.cyqModel.startDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
            _dataModel.cyqModel.endDate = [[NSNumber numberWithInt:dateVal] uint16ToDate];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    layoutConstraints = [[NSMutableArray alloc] init];
    
    [self varInit];
    
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    
    /* UI initialize */
    
    /**************************
     選項1 起始日~截止日
     **************************/
    
    // 主選項按鈕  (1) 日曆選日期
    _optionButton1 = [self.view newButton:FSUIButtonTypeRadio];
    _optionButton1.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_optionButton1];
    
    // 主選項敘述  (1) 日曆選日期
    _optionLabel1 = [[UILabel alloc] init];
    _optionLabel1.text = @"起始日~截止日";
    _optionLabel1.font = font;
    _optionLabel1.textColor = [UIColor colorWithRed:155.0f/255.0f green:97.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
    _optionLabel1.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_optionLabel1];
    
    // 日期按鈕 起始日
    _startDateButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [self.view addSubview:_startDateButton];
    
    // 日期按鈕 截止日
    _endDateButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [self.view addSubview:_endDateButton];
    
    // 新增 tildeSymbol '~' 符號
    _tildeSymbol = [[UILabel alloc] init];
    _tildeSymbol.translatesAutoresizingMaskIntoConstraints = NO;
    _tildeSymbol.text = @"~";
    _tildeSymbol.font = [UIFont boldSystemFontOfSize:24.0f];
    _tildeSymbol.textColor = [UIColor colorWithRed:155.0f/255.0f green:97.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
    [self.view addSubview:_tildeSymbol];
    
    
    /**************************
     日曆
     **************************/

    
    UIView *calenderAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 316)];
    
    
    _calendarView = [[TSQCalendarView alloc] init];
    _calendarView.frame = CGRectMake(0, 22, 320, 296);
    _calendarView.delegate = self;
    _calendarView.calendar = [NSCalendar currentCalendar];
    
    
    int startDateVal = [(NSNumber *)[_dataModel.cyqModel.dateArray objectAtIndex:0] intValue];
    
    _calendarView.firstDate = [[NSNumber numberWithInt:startDateVal] uint16ToDate];
    _calendarView.lastDate = [NSDate date];
    _calendarView.rowCellClass = [TSQTACalendarRowCell class];
    _calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    _calendarView.pagingEnabled = YES;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    _calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
    
    // 指示日曆目前的功能
    _dateIndicatorLabel = [[UILabel alloc] init];
    _dateIndicatorLabel.frame = CGRectMake(0, 0, 320, 22);
    _dateIndicatorLabel.text = @"起始日";
    _dateIndicatorLabel.font = font;
    _dateIndicatorLabel.textColor = [UIColor whiteColor];
    _dateIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    _dateIndicatorLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:132.0f/255.0f alpha:1.0f];
    
    [calenderAlertView addSubview:_calendarView];
    [calenderAlertView addSubview:_dateIndicatorLabel];
    
    custAlert = [[CustomIOS7AlertView alloc] init];
    [custAlert setButtonTitles:@[@"關閉"]];
    [custAlert setContainerView:calenderAlertView];
    
    /**************************
     選項2 由最近日期算起
     **************************/
    
    _optionButton2 = [self.view newButton:FSUIButtonTypeRadio];
    [self.view addSubview:self.optionButton2];
    
    // 選項2 敘述前端 Label
    _optionLabel2 = [[UILabel alloc] init];
    _optionLabel2.text = @"由最近日期算起";
    _optionLabel2.font = font;
    _optionLabel2.textColor = [UIColor colorWithRed:155.0f/255.0f green:97.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
    _optionLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_optionLabel2];
    
    // 選項2 敘述後端 Label
    _optionLabel2_2 = [[UILabel alloc] init];
    _optionLabel2_2.text = @"天內";
    _optionLabel2_2.font = font;
    _optionLabel2_2.textColor = [UIColor colorWithRed:155.0f/255.0f green:97.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
    _optionLabel2_2.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_optionLabel2_2];
    
    // 選項2 天數 Label
    _dayRangeNumberLabel = [[UILabel alloc] init];
    _dayRangeNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dayRangeNumberLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    _dayRangeNumberLabel.textColor = [UIColor blackColor];
    _dayRangeNumberLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_dayRangeNumberLabel];
    
    // 選項2 天數範圍 Label
    _dayRangeLabel = [[UILabel alloc] init];
    _dayRangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dayRangeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    _dayRangeLabel.textColor = [UIColor blueColor];
    [self.view addSubview:_dayRangeLabel];
    
    // 選項2 按鈕 + Button
    _addDateRangeButton = [self.view newButton:FSUIButtonTypeNormalBlue];
    [_addDateRangeButton setTitle:@"+" forState:UIControlStateNormal];
    [self.view addSubview:_addDateRangeButton];
    
    // 選項2 按鈕 - Button
    _minusDateRangeButton = [self.view newButton:FSUIButtonTypeNormalBlue];
    [_minusDateRangeButton setTitle:@"-" forState:UIControlStateNormal];
    [self.view addSubview:_minusDateRangeButton];
    
    
    // 關閉按鈕
    _saveAndExitButton = [self.view newButton:FSUIButtonTypeNormalRed];
    _saveAndExitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_saveAndExitButton setTitle:@"離開設定" forState:UIControlStateNormal];
    [self.view addSubview:_saveAndExitButton];
    
    
    /* radio Button Set Controller */
    
    _radioButtonSetController = [[FSRadioButtonSet alloc] init];
    _radioButtonSetController.delegate = self;
    _radioButtonSetController.buttons = @[self.optionButton1,
                                          self.optionButton2
                                          ];
    
        
    /* button's actionEventHandler */

//    __weak __typeof(self) weakSelf = self;

    // 選擇起始日
    [_startDateButton addTarget:self action:@selector(startDateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    [_startDateButton addEventHandler:^(UIButton *button) {
//        __strong __typeof(self) strongSelf = weakSelf;
//        
//        strongSelf.radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeCalendar;
//        strongSelf.dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeCalendar;
//        
//        strongSelf.dateButtonMode = DateButtonStartDateMode;
//        
//        strongSelf.dateIndicatorLabel.text = @"起始日";
//        strongSelf.calendarView.selectedDate = strongSelf.dataModel.cyqModel.startDate;
//        
//        
//
//    } forControlEvents:UIControlEventTouchUpInside];

    // 選擇截止日
    [_endDateButton addTarget:self action:@selector(endDateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    [_endDateButton addEventHandler:^(UIButton *button) {
//        __strong __typeof(self) strongSelf = weakSelf;
//        
//        strongSelf.radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeCalendar;
//        strongSelf.dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeCalendar;
//        
//        strongSelf.dateButtonMode = DateButtonEndDateMode;
//
//        strongSelf.dateIndicatorLabel.text = @"截止日";
//        strongSelf.calendarView.selectedDate = strongSelf.dataModel.cyqModel.endDate;
//        
//                
//
//    } forControlEvents:UIControlEventTouchUpInside];

    // 最近日期算起 X 天 運算加
    [_addDateRangeButton addTarget:self action:@selector(addDateRangeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    [_addDateRangeButton addEventHandler:^(UIButton *button) {
//        __strong __typeof(self) strongSelf = weakSelf;
//        strongSelf.radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeRecently;
//        strongSelf.dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeRecently;
//        
//        if ([strongSelf.dataModel.cyqModel.dateArray count] > strongSelf.dataModel.cyqModel.recentlyDay && strongSelf.dataModel.cyqModel.recentlyDay < 99) {
//            
//            strongSelf.dataModel.cyqModel.recentlyDay++;
//
//            int numDate = [[strongSelf.dataModel.cyqModel.dateArray objectAtIndex:[strongSelf.dataModel.cyqModel.dateArray count]-strongSelf.dataModel.cyqModel.recentlyDay] intValue];
//                        
//            NSDate *startDate = [[NSNumber numberWithInt:numDate] uint16ToDate];
//            strongSelf.dayRangeNumberLabel.text = [NSString stringWithFormat:@"%d", strongSelf.dataModel.cyqModel.recentlyDay];
//            
//            int numEndDate = [[strongSelf.dataModel.cyqModel.dateArray lastObject] intValue];
//            NSDate *endDate = [[NSNumber numberWithInt:numEndDate] uint16ToDate];
//            
//            NSDateFormatter *format = [[NSDateFormatter alloc] init];
//            [format setDateFormat:@"yyyy/MM/dd"];
//            
//            strongSelf.dayRangeLabel.text =  [NSString stringWithFormat:@"%@~%@", [format stringFromDate:startDate], [format stringFromDate:endDate]];
//        }
// 
//    } forControlEvents:UIControlEventTouchUpInside];

    // 最近日期算起 X 天 運算減
    [_minusDateRangeButton addTarget:self action:@selector(minusDateRangeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    [_minusDateRangeButton addEventHandler:^(UIButton *button) {
//        __strong __typeof(self) strongSelf = weakSelf;
//        strongSelf.radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeRecently;
//        strongSelf.dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeRecently;
//                
//        if (strongSelf.dataModel.cyqModel.recentlyDay > 1) {
//            
//            strongSelf.dataModel.cyqModel.recentlyDay--;
//            
//            int numDate = [[strongSelf.dataModel.cyqModel.dateArray objectAtIndex:[strongSelf.dataModel.cyqModel.dateArray count]-strongSelf.dataModel.cyqModel.recentlyDay] intValue];
//            
//            NSDate *startDate = [[NSNumber numberWithInt:numDate] uint16ToDate];
//            strongSelf.dayRangeNumberLabel.text = [NSString stringWithFormat:@"%d", strongSelf.dataModel.cyqModel.recentlyDay];
//            
//            int numEndDate = [[strongSelf.dataModel.cyqModel.dateArray lastObject] intValue];
//            NSDate *endDate = [[NSNumber numberWithInt:numEndDate] uint16ToDate];
//            
//            NSDateFormatter *format = [[NSDateFormatter alloc] init];
//            [format setDateFormat:@"yyyy/MM/dd"];
//            
//            strongSelf.dayRangeLabel.text =  [NSString stringWithFormat:@"%@~%@", [format stringFromDate:startDate], [format stringFromDate:endDate]];
//        }
//
//    } forControlEvents:UIControlEventTouchUpInside];

    // 關閉裝載自己的popover
    [_saveAndExitButton addTarget:self action:@selector(saveAndExitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
//    [_saveAndExitButton addEventHandler:^(UIButton *button) {
//        __strong __typeof(self) strongSelf = weakSelf;
//
//        [strongSelf dismissViewControllerAnimated:YES completion:^{
//            // CLOSE WINDOW
//        }];
//    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)startDateBtnClick{
    _radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeCalendar;
    _dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeCalendar;
    
    _dateButtonMode = DateButtonStartDateMode;
    
    _dateIndicatorLabel.text = @"起始日";
    _calendarView.selectedDate = _dataModel.cyqModel.startDate;
    
    [custAlert show];
}

-(void)endDateBtnClick{
    _radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeCalendar;
    _dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeCalendar;
    
    _dateButtonMode = DateButtonEndDateMode;
    
    _dateIndicatorLabel.text = @"截止日";
    _calendarView.selectedDate = _dataModel.cyqModel.endDate;
    
    [custAlert show];
}

-(void)addDateRangeBtnClick{
    _radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeRecently;
    _dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeRecently;
    
    if ([_dataModel.cyqModel.dateArray count] > _dataModel.cyqModel.recentlyDay && _dataModel.cyqModel.recentlyDay < 99) {
        
        _dataModel.cyqModel.recentlyDay++;
        
        int numDate = [(NSNumber *)[_dataModel.cyqModel.dateArray objectAtIndex:[_dataModel.cyqModel.dateArray count]-_dataModel.cyqModel.recentlyDay] intValue];
        
        NSDate *startDate = [[NSNumber numberWithInt:numDate] uint16ToDate];
        _dayRangeNumberLabel.text = [NSString stringWithFormat:@"%d", _dataModel.cyqModel.recentlyDay];
        
        int numEndDate = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
        NSDate *endDate = [[NSNumber numberWithInt:numEndDate] uint16ToDate];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy/MM/dd"];
        
        _dayRangeLabel.text =  [NSString stringWithFormat:@"%@~%@", [format stringFromDate:startDate], [format stringFromDate:endDate]];
    }
}

-(void)minusDateRangeBtnClick{
    _radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeRecently;
    _dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeRecently;
    
    if (_dataModel.cyqModel.recentlyDay > 1) {
        
        _dataModel.cyqModel.recentlyDay--;
        
        int numDate = [(NSNumber *)[_dataModel.cyqModel.dateArray objectAtIndex:[_dataModel.cyqModel.dateArray count]-_dataModel.cyqModel.recentlyDay] intValue];
        
        NSDate *startDate = [[NSNumber numberWithInt:numDate] uint16ToDate];
        _dayRangeNumberLabel.text = [NSString stringWithFormat:@"%d", _dataModel.cyqModel.recentlyDay];
        
        int numEndDate = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
        NSDate *endDate = [[NSNumber numberWithInt:numEndDate] uint16ToDate];
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy/MM/dd"];
        
        _dayRangeLabel.text =  [NSString stringWithFormat:@"%@~%@", [format stringFromDate:startDate], [format stringFromDate:endDate]];
    }
}

-(void)saveAndExitBtnClick{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    switch (_dataModel.cyqModel.accumulateOptionType) {
        case CYQAcuumulateOptionTypeCalendar:
             _radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeCalendar;
            break;
        case CYQAcuumulateOptionTypeRecently:
            _radioButtonSetController.selectedIndex = CYQAcuumulateOptionTypeRecently;
            break;
        default:
            break;
    }
    
    _calendarView.selectedDate = _dataModel.cyqModel.startDate;
    _dayRangeNumberLabel.text = [NSString stringWithFormat:@"%d",_dataModel.cyqModel.recentlyDay];
//    [self showDate];
    
    int numDate = [(NSNumber *)[_dataModel.cyqModel.dateArray objectAtIndex:[_dataModel.cyqModel.dateArray count]-_dataModel.cyqModel.recentlyDay] intValue];
    int numEndDate = [(NSNumber *)[_dataModel.cyqModel.dateArray lastObject] intValue];
    
    NSDate *startDate = [[NSNumber numberWithInt:numDate] uint16ToDate];
    NSDate *endDate = [[NSNumber numberWithInt:numEndDate] uint16ToDate];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy/MM/dd"];
    
    _dayRangeLabel.text =  [NSString stringWithFormat:@"%@~%@", [format stringFromDate:startDate], [format stringFromDate:endDate]];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_tildeSymbol, _optionButton1, _optionLabel1, _startDateButton, _endDateButton, _optionButton2, _optionLabel2, _optionLabel2_2, _addDateRangeButton, _minusDateRangeButton, _dayRangeLabel, _dayRangeNumberLabel, _saveAndExitButton);
    
    // 選項1
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_optionButton1(35)][_optionLabel1]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    
    // 設定選項1 與起始日按鈕邊界距離和高度
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-33-[_optionButton1(35)]-5-[_startDateButton]" options:0 metrics:nil views:viewsDictionary]];
    
    // tildeSymbol置中
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tildeSymbol attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_startDateButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:33]];
    
    // 按鈕在tildeSymbol左右隔8
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_startDateButton(120)]-[_tildeSymbol]-[_endDateButton(120)]" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:nil views:viewsDictionary]];
    
    // 選項2
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_optionButton2(35)][_optionLabel2][_minusDateRangeButton(28)]-2-[_dayRangeNumberLabel(22)]-2-[_addDateRangeButton(28)]-2-[_optionLabel2_2]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    
    // 日曆 左右
//    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_calendarView]|" options:0 metrics:nil views:viewsDictionary]];
    
    // 日曆 上下
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_startDateButton]-25-[_optionButton2(35)]-10-[_dayRangeLabel]" options:0 metrics:nil views:viewsDictionary]];
    
    // 日期範圍 Label 置中
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_dayRangeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    // 離開設定按鈕 下置底
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_saveAndExitButton]|" options:0 metrics:nil views:viewsDictionary]];
    
    // 離開設定按鈕 右置右邊
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_saveAndExitButton(100)]|" options:0 metrics:nil views:viewsDictionary]];
    
    [self.view addConstraints:layoutConstraints];
}

- (void)viewDidLayoutSubviews {
    [self.calendarView scrollToDate:_dataModel.cyqModel.startDate animated:NO];
}

- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectDate:(NSDate *)date {
    
//    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
//    NSDateComponents *weekdayComponents = [currentCalendar components:NSWeekdayCalendarUnit fromDate:date];
//    if ([weekdayComponents weekday] == 1 || [weekdayComponents weekday] == 7) {
//        return NO;
//    }
    
    if (_dateButtonMode == DateButtonStartDateMode) {
        
        if ([date compare:_dataModel.cyqModel.endDate] == NSOrderedAscending) {
            return YES;
        } else if ([date compare:_dataModel.cyqModel.endDate] == NSOrderedSame) {
            return YES;
        }
        
    } else if (_dateButtonMode == DateButtonEndDateMode) {
        if ([date compare:_dataModel.cyqModel.startDate] == NSOrderedDescending) {
            return YES;
        } else if ([date compare:_dataModel.cyqModel.startDate] == NSOrderedSame) {
            return YES;
        }
    }
    return NO;
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date {
    // 重新redraw日曆
//    [_calendarView reloadCalendar];
    
    // 將值儲存
    if (_dateButtonMode == DateButtonStartDateMode) {
        _dataModel.cyqModel.startDate = date;
    } else if (_dateButtonMode == DateButtonEndDateMode) {
        _dataModel.cyqModel.endDate = date;
    }
    
    _dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeCalendar;
    
    [self showDate];
}

- (void)showDate {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *startDateDateComponents =
    [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                           ) fromDate:_dataModel.cyqModel.startDate];
    
    NSString *startDateString = [[NSString alloc] initWithFormat:@"%d/%d/%d",
                                 (int)[startDateDateComponents year],
                                 (int)[startDateDateComponents month],
                                 (int)[startDateDateComponents day]];
    
    NSDateComponents *endDateDateComponents =
    [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                           ) fromDate:_dataModel.cyqModel.endDate];
    
    NSString *endDateString = [[NSString alloc] initWithFormat:@"%d/%d/%d",
                               (int)[endDateDateComponents year],
                               (int)[endDateDateComponents month],
                               (int)[endDateDateComponents day]];
    
    [_startDateButton setTitle:startDateString forState:UIControlStateNormal];
    [_endDateButton setTitle:endDateString forState:UIControlStateNormal];
}

-(void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex{
    
    // 儲存點擊的項目
    
    if (selectedIndex == 0) {
        _dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeCalendar;
    } else if (selectedIndex == 1) {
        _dataModel.cyqModel.accumulateOptionType = CYQAcuumulateOptionTypeRecently;
    }
}

@end
