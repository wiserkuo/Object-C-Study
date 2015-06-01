//
//  UpperView.h
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/29.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexView.h"
#import "DrawAndScrollController.h"

@class DrawAndScrollController;
@class IndexView;


@interface UpperView : UIView <UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,CustomIOS7AlertViewDelegate>{
	
    DrawAndScrollController *drawAndScrollController;
	double parmValue1;
	double parmValue2;	
	double parmValue3;
    double parmValue4;
	double parmValue5;
	double parmValue6;
    
    double ma4Param;
    double ma5Param;
    double ma6Param;
    double ma4BeforeParam;
    double ma5BeforeParam;
    double ma6BeforeParam;
    
	int selectMainChartIndex;
    int selectIndicatorIndex;
    
    UITableView *tableview;
    BOOL mainCharShow;
    BOOL indicatorShow;
    NSInteger section1CellNumber;
    NSInteger section2CellNumber;
    
    UILabel * titleLabel;
    CustomIOS7AlertView * cxAlertView;
	
}
@property (nonatomic,strong) NSMutableArray *ShowIndex;

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

- (NSString *)titleForAnalysisPeriod:(AnalysisPeriod)period;
- (void)loadUpperViewIndicatorValueFor:(UpperViewIndicator)type withParmValue1:(double)value1 parmValue2:(double)value2 parmValue3:(double)value3 parmValue4:(double)value4 parmValue5:(double)value5 parmValue6:(double)value6;
- (void)loadMAValueFor:(UpperViewIndicator)type withMa4Param:(double)value1 Ma5Param:(double)value2 Ma6Param:(double)value3 Ma4BeforeParam:(double)value4 Ma5BeforeParam:(double)value5 Ma6BeforeParam:(double)value6;

- (void)refleshPeriodTitleAndIndicatorValue;

- (NSString *)upperViewIndicatorNameWithIndex:(int)index;

- (void)openUpperIndicatorPicker;
- (void)closeUpperIndicatorPicker;
- (void)dismissActionSheet;
-(void)selectUpperViewType;

@end
