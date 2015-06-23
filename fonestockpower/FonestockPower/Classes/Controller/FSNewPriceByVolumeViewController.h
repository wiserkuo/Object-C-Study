//
//  FSNewPriceByVolumeViewController.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/29.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSDistributeIn.h"
@interface FSNewPriceByVolumeViewController : FSUIViewController

-(void)sectorIdCallBack:(NSMutableArray *)dataArray;
-(void)dataArrive:(FSDistributeIn *)data;
@end
