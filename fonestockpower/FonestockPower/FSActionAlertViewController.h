//
//  FSActionAlertViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/10/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSActionAlertTableView.h"

@interface FSActionAlertViewController : FSUIViewController <FSActionAlertTableViewDelegate>
@property (strong, nonatomic) FSActionAlertTableView *tableView;
@property (nonatomic) BOOL controllerType;

-(void)reloadRowWithIdentCodeSymbol:(NSString *)ids lastPrice:(float)lastPrice row:(int)row;

@end
