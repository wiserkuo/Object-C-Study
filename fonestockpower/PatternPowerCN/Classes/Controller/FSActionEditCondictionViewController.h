//
//  FSActionEditCondictionViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/5/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"
#import "FSWatchlistItemProtocol.h"
#import "FSActionEditCondictionDelegate.h"

@interface FSActionEditCondictionViewController : FSUIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, FSActionEditCondictionDelegate>
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;

@property (strong) UITableView *mainTableView;
@property (strong) NSMutableArray * dataArray;


@end
