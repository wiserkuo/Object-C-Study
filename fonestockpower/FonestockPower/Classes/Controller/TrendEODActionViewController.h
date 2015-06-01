//
//  TrendEODActionViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendEODActionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
-(void)notifyLongData:(id)target;
-(void)notifyShortData:(id)target;
@end
