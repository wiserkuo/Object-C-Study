//
//  MacroeconomicDrawTableViewCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/7/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MacroeconomicDrawTableViewCell : FSUITableViewCell
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *changeLabel;
@property (nonatomic, strong) UILabel *changePrecentLabel;
@end
