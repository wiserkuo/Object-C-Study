//
//  FSEmergingQuotesViewController.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSEmergingQuotesViewController : FSUIViewController<DataArriveProtocol>

-(void)reloadData;
@property (nonatomic, strong) NSString *buttonTitle;

@end
