//
//  ChooseReferenceViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/7/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroeconomicDrawViewController.h"

@interface ChooseReferenceViewController : UIViewController< UITableViewDataSource, UITableViewDelegate>
-(id)initWithTitle:(NSMutableArray *)TitleArray Name:(NSMutableArray *)NameArray Controller:(MacroeconomicDrawViewController *)controller;
@end
