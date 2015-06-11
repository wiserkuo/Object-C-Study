//
//  FSDiaryViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/7/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSDiaryTableView.h"

@interface FSDiaryViewController : UIViewController <FSDiaryTableViewDelegate>
@property (strong, nonatomic)FSDiaryTableView *tableView;

@end
