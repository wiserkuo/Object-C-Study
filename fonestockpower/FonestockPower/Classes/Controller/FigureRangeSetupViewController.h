//
//  FigureRangeSetupViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/29.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureSearchModel.h"

@interface FigureRangeSetupViewController : UIViewController
- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber dataArray:(NSMutableArray *)array kNumber:(int)kNumber;

@end
