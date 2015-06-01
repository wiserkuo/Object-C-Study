//
//  FSOptionTrialViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/10/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSOptionTableView.h"

@interface FSOptionTrialViewController : UIViewController <FSOptionTableViewDelegate>
@property (strong, nonatomic) FSOptionTableView *tableView;

-(void)initLabelText;
-(void)scrollToNearestStrikePrice;
@end
