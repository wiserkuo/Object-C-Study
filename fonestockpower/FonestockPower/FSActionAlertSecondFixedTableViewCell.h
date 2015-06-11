//
//  FSActionAlertSecondFixedTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/10/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSActionAlertSecondFixedTableViewCell : FSUITableViewCell
@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UILabel *lastLabel;
@property (strong, nonatomic) FSUIButton *tradeBtn;
@property (strong, nonatomic) FSUIButton *trade2Btn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;
@end
