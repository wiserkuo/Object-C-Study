//
//  FSPositionFixedTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/11/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPositionFixedTableViewCell : FSUITableViewCell
@property (strong, nonatomic) UILabel *symbolLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
