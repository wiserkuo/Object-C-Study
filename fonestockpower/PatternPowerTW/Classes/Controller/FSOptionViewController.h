//
//  FSOptionViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSOptionTableView.h"

@interface FSOptionViewController : UIViewController <FSOptionTableViewDelegate>{
    NSInteger catID;
}
@property (strong, nonatomic) FSOptionTableView *tableView;

-(void)initLabelText;
-(void)initBtnTitle;
-(void)scrollToNearestStrikePrice;
@end
