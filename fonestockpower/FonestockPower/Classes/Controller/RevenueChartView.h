//
//  RevenueChartView.h
//  WirtsLeg
//
//  Created by Connor on 13/12/3.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface RevenueChartView : UIView
{
    NSMutableArray *revenueArray;
    NSString *identCode;
}
@property (nonatomic) int chartViewType;
-(void)setNeedsDisplayWithArray:(NSMutableArray *)array;
-(void)cleanChartView;
@end
