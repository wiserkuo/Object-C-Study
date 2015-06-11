//
//  FSPositionInformationViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/7/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKCustomTableView.h"
#import "SKCustomTableViewCell.h"

@interface FSPositionInformationViewController : UIViewController <SKCustomTableViewDelegate>
@property (strong, nonatomic) SKCustomTableView *tableView;
@property (strong, nonatomic) NSString *termStr;
@property (strong, nonatomic) NSString *symbolStr;

@end
