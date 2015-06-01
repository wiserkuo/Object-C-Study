//
//  FSInvestedCell.h
//  FonestockPower
//
//  Created by Derek on 2014/4/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSInvestedCell : FSUITableViewCell
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *remitLabel;
@property (strong, nonatomic) UILabel *amountLabel;
@property (strong, nonatomic) UILabel *totalAmountLabel;
@property (strong, nonatomic) UIButton *removeBtn;

@end
