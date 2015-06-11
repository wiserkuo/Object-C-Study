//
//  FSTradeHistoryMainTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTradeHistoryMainTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *symbolLabel;
@property (strong, nonatomic) UILabel *qtyLabel;
@property (strong, nonatomic) UILabel *buyDealLabel;
@property (strong, nonatomic) UILabel *buyAmountLabel;
@property (strong, nonatomic) UILabel *sellDealLabel;
@property (strong, nonatomic) UILabel *sellAmountLabel;
@property (strong, nonatomic) UIButton *removeBtn;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
