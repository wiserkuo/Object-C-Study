//
//  AmericaStockSettingViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/14.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"
#import "FSTeachPopDelegate.h"

@interface AmericaStockSettingViewController : FSUIViewController<UITextFieldDelegate,SecuritySearchDelegate,UIScrollViewDelegate,FSTeachPopDelegate,UIActionSheetDelegate>


@end
