//
//  MacroeconomicIndexDrawView.h
//  FonestockPower
//
//  Created by Kenny on 2014/7/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroeconomicDrawViewController.h"

@interface MacroeconomicIndexDrawView : UIView
@property (nonatomic, strong) NSMutableArray *firstValueArray;
@property (nonatomic, strong) NSMutableArray *date1Array;
@property (nonatomic, strong) NSMutableArray *secondValueArray;
@property (nonatomic, strong) NSMutableArray *date2Array;
@property (nonatomic) BOOL drawType;
@property (nonatomic) BOOL draw2Type;
@property (nonatomic) BOOL secondFlag;
@property (nonatomic) float dayWidth;
@property (nonatomic, strong) MacroeconomicDrawViewController * macroeconomicDrawViewController;
- (id)initWithController:(MacroeconomicDrawViewController *)controller;
@end
