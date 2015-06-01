//
//  TodayReserveViewController.h
//  Bullseye
//
//  Created by Connor on 13/9/5.
//
//

#import <UIKit/UIKit.h>

#import "DataArriveProtocol.h"

@class PortfolioItem;

@interface TodayReserveViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DataNotifyProtocol>
@property (strong, nonatomic) PortfolioItem *portfolioItem;
- (void)notifyVolume;
- (void)notifyInvesterHoldData;
@end
