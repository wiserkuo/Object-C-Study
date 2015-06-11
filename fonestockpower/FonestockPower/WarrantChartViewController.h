//
//  WarrantChartViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WarrantChartViewController : UIViewController
- (void)doTouchesWithPoint:(CGPoint)point number:(int)num;
@end

@interface ChartObject: NSObject
{
    @public
    int date;
    int volume;
    double bid;
    double ask;
    double price;
    double change;
}
@end