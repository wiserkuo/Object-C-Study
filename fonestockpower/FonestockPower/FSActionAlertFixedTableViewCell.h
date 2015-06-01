//
//  FSActionAlertFixedTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/10/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSActionAlertFixedTableViewCell : FSUITableViewCell
@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UILabel *lastLabel;
@property (strong, nonatomic) FSUIButton *tradeBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;
@end
