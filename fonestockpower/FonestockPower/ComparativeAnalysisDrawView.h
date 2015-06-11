//
//  ComparativeAnalysisDrawView.h
//  FonestockPower
//
//  Created by Kenny on 2014/10/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComparativeAnalysisViewController.h"

@interface ComparativeAnalysisDrawView : UIView
{
    NSMutableArray *saveArray;
}
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) NSMutableArray *cgArray;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) ComparativeAnalysisViewController *controller;
-(void)setTarget:(ComparativeAnalysisViewController *)obj;
@end
