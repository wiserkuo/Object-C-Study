//
//  FinancialTableViewCell.h
//  WirtsLeg
//
//  Created by Neil on 13/11/12.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MarqueeLabel;


@interface FinancialTableViewCell : FSUITableViewCell

@property (strong, nonatomic) MarqueeLabel * titleLabel;
@property (strong, nonatomic) UILabel * group1Label;
@property (strong, nonatomic) UILabel * group2Label;

@end
