//
//  FSTradeHistoryFixedTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTradeHistoryFixedTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
