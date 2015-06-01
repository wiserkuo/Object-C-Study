//
//  AmericaEditConditionViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/14.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"
#import "FSWatchlistItemProtocol.h"
#import "TextFieldTableViewDelegate.h"

@interface AmericaEditConditionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,TextFieldTableViewDelegate>
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;

@property (strong) UITableView *mainTableView;
@property (strong) NSMutableArray * dataArray;
@end
