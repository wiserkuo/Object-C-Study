//
//  VolatilityViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VolatilityViewController : UIViewController
-(void)notifyHistoryData:(NSMutableArray *)dataArray;
-(id)initWithViewHeight:(double)height;
@property (nonatomic)double viewHeight;
@end
