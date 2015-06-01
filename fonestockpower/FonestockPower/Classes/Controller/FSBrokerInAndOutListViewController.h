//
//  FSBrokerInAndOutListViewController.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSBrokerInAndOutListViewController : FSUIViewController<BrokerProtocol>

-(void)reloadData;

@property (nonatomic) int dayType;

@end
