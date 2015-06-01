//
//  FigureSearchConditionViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/23.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureSearchModel.h"

@interface FigureSearchConditionViewController : FSUIViewController

- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber;
- (void)goSearch;
@end
