//
//  HistoricalEPSChartView.h
//  FonestockPower
//
//  Created by Connor on 14/4/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSHistoricalEPSViewController.h"

@interface FSHistoricalEPSChartView : UIView
- (void)notifyDrawChart:(NSArray *)epsRecord mode:(enum EPSchartMode)chartMode;
@end
