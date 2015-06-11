//
//  FSOptionMainViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/10/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionData;
@interface FSOptionMainViewController : UIViewController {
    NSInteger catID;
}
@property (strong, nonatomic) id mainViewController;
@property (strong, nonatomic) NSArray *titleArray;


-(void)sendOptionDataWithGoodsNum:(NSUInteger)goodsArrayNum MonthNum:(NSUInteger)monthArrayNum;
@end
