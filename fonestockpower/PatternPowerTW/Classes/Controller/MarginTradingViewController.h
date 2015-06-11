//
//  MarginTradingViewController.h
//  Bullseye
//
//  Created by Connor on 13/9/4.
//
//

#import <UIKit/UIKit.h>
#import "SKCustomTableView.h"

@class PortfolioItem;

@interface MarginTradingViewController : UIViewController <SKCustomTableViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
@property (strong, nonatomic) PortfolioItem *portfolioItem;
@end
