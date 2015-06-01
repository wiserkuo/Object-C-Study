//
//  FSTradeDiaryViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTradeDiaryTableView.h"

@interface FSTradeDiaryViewController : FSUIViewController <FSTradeDiaryTableViewDelegate>
@property (strong, nonatomic) FSTradeDiaryTableView *tableView;

@end
