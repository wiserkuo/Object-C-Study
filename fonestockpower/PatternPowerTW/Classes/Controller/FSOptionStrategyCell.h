//
//  FSOptionStrategyCell.h
//  FonestockPower
//
//  Created by Derek on 2014/10/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSOptionStrategyCell : FSUITableViewCell
@property (strong, nonatomic) UILabel *header1;
@property (strong, nonatomic) UILabel *header2;
@property (strong, nonatomic) UILabel *header3;
@property (strong, nonatomic) UILabel *header4;

@property (strong, nonatomic) UILabel *monthLabel;
@property (strong, nonatomic) UIButton *strikeBtn;
@property (strong, nonatomic) UILabel *powerLabel;
@property (strong, nonatomic) UILabel *priceLabe;

@end
