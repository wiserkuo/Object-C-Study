//
//  FSWatchlistViewController.h
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSWatchlistItemProtocol.h"
#import "DataArriveProtocol.h"
//#import "FSNaviTitleViewDelegate.h"
//#import "FSPagerNavigationBarItemProtocol.h"


@interface FSWatchlistViewController : FSUIViewController <DataArriveProtocol, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>



@end
