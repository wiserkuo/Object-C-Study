//
//  IndexQuotesViewController.h
//  IndexQuotesViewController
//
//  Created by CooperLin on 2014/10/17.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexQuotesObject.h"

@interface IndexQuotesViewController : UIViewController<DataArriveProtocol>
-(void)reloadData;
@end
