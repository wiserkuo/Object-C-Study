//
//  RevenueChartViewController.h
//  WirtsLeg
//
//  Created by Connor on 13/12/3.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RevenueChartView.h"

@interface RevenueChartViewController : UIViewController <NewRevenueChartViewDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) RevenueChartView *revenueChartView;
@property (nonatomic, strong) NSMutableArray *revenueArray;
@end
