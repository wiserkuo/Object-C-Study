//
//  FSPositionMainTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/11/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPositionMainTableViewCell : FSUITableViewCell
@property (strong, nonatomic) UILabel *qtyLabel;
@property (strong, nonatomic) UILabel *avgCostLabel;
@property (strong, nonatomic) UILabel *totalCostLabel;
@property (strong, nonatomic) UILabel *lastLabel;
@property (strong, nonatomic) UILabel *totalValLabel;
@property (strong, nonatomic) UILabel *gainLabel;
@property (strong, nonatomic) UILabel *gainPercentLabel;
@property (strong, nonatomic) UILabel *riskLabel;
@property (strong, nonatomic) UILabel *riskPercentLabel;
@property (strong, nonatomic) FSUIButton *hBtn;
@property (strong, nonatomic) FSUIButton *nBtn;
@property (strong, nonatomic) FSUIButton *gBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
