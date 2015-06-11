//
//  FSRootViewController.h
//  FonestockPower
//
//  Created by Connor on 14/3/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSRootViewController : UIViewController

//判斷是要使用哪一種儲存方式
typedef NS_ENUM(NSUInteger, FSCurrentUsingType){
    FSCurrentUsingTypeTips = 0,         // 0: 現在使用Tips
    FSCurrentUsingTypeTW = 1,           // 1: 現在使用台股
    FSCurrentUsingTypeUS = 2,           // 2: 現在使用美股
    FSCurrentUsingTypeCN = 3,           // 3: 現在使用陸股
    FSCurrentUsingTypeSP = 4            // 4: 現在使用神奇力
};

@end
