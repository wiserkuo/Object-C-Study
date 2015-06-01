//
//  FSAddActionEditCondictionViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/5/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"
#import "FSWatchlistItemProtocol.h"
#import "FSAddActionEditCondictionDelegate.h"

@interface FSAddActionEditCondictionViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, FSAddActionEditCondictionDelegate>
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;

@property (strong) UITableView *mainTableView;
@property (strong) NSMutableArray * dataArray;
@property (strong) NSString *termStr;

-(void)reloadDataArray;


@end
