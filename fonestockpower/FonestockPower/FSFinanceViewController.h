//
//  FSFinanceViewController.h
//  pricevolume
//
//  Created by Connor on 2015/5/13.
//  Copyright (c) 2015年 Connor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSFinanceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property int a;
@end


@interface FSFinanceTableView : UITableView

@end


@interface FSFinanceTableViewCell : UITableViewCell
@property UILabel *tableTitleLabel;
@property UILabel *stock1Label;
@property UILabel *stock2Label;
@end