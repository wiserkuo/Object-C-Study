//
//  TechDrawBottomView.h
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TechViewController.h"

@interface TechDrawBottomView : UIView
{
    double heightRate;
    double highValue;
    double lowValue;
}
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *value_1Array;
@property (nonatomic, strong) NSMutableArray *value_2Array;
@property (nonatomic, strong) NSMutableArray *value_3Array;
@property (nonatomic, strong) NSString *drawType;
@property (nonatomic) int xPoint;
@property (nonatomic) int viewWidth;
@property (nonatomic) int startCount;
@property (nonatomic) double widthRange;
@property (nonatomic) int valueNum1;
@property (nonatomic) int valueNum2;
@property (nonatomic) double m;
@property (nonatomic) double b;
@property (nonatomic, strong) TechViewController *obj;
@property (nonatomic) UInt16 startDate;
@property (nonatomic) UInt16 endDate;
@property (nonatomic) int circleStart;
@property (nonatomic) int circleEnd;
@property (nonatomic) double circleTouchX_Start;
@property (nonatomic) double circleTouchY_Start;
@property (nonatomic) double circleTouchX_End;
@property (nonatomic) double circleTouchY_End;
-(id)initWithType:(NSString *)type;
@end
