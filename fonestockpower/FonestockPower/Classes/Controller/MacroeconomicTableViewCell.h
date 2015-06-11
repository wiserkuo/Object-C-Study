//
//  MacroeconomicTableViewCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/7/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"
@interface MacroeconomicTableViewCell : FSUITableViewCell
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) MarqueeLabel *nameLabel;
@property (nonatomic, strong) UILabel *nameDetailLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *arrowImage;
@end
