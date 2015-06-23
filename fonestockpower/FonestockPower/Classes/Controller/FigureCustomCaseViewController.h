//
//  FigureCustomCaseViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureSearchModel.h"

typedef enum {
    upTrend,
    downTrend,
    flatTrend,
}trendType;


@interface FigureCustomCaseViewController : FSUIViewController

- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber;
@property (nonatomic) BOOL firstTimeFlag;//bug#10581 wiser.kuo

@end
