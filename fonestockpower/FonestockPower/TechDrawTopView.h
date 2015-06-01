//
//  TechDrawTopView.h
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TechViewController.h"

@interface TechDrawTopView : UIView
{
    double heightRate;
    double highPrice;
    double lowPrice;
}
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) int xPoint;
@property (nonatomic) int viewWidth;
@property (nonatomic) double widthRange;
@property (nonatomic) int startCount;
@property (nonatomic) double m;
@property (nonatomic) double b;
@property (nonatomic, strong) TechViewController *obj;
@property (nonatomic) UInt16 startDate;
@property (nonatomic) UInt16 endDate;
@property (nonatomic) BOOL symbolType;
@property (nonatomic) int circleStart;
@property (nonatomic) int circleEnd;
@property (nonatomic) double circleTouchX_Start;
@property (nonatomic) double circleTouchY_Start;
@property (nonatomic) double circleTouchX_End;
@property (nonatomic) double circleTouchY_End;
-(void)longPressHandler:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)theTranportDestination:(BOOL)startOrEnd :(NSSet *)touches;

@end

@interface TechDrawDateView : UIView
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) int xPoint;
@property (nonatomic) int viewWidth;
@property (nonatomic) double widthRange;
@property (nonatomic) int startCount;
@property (nonatomic) UInt16 startDate;
@property (nonatomic) UInt16 endDate;
@end
