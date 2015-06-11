//
//  RealtimeListController.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/16.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RealtimeListController : UIViewController <UITableViewDelegate, UITableViewDataSource, DataArriveProtocol>

- (void)showBidSellInfoWithBidOrSell:(int)bidorSell rowIndex:(int)index;
- (void)esmDataDataArrive;
- (void)type19NotifyDataArrive;
-(void)sectorIdCallBack:(NSMutableArray *)dataArray;

@end
