//
//  FSTradeDiaryMainTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTradeDiaryMainTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *qtyLabel;
@property (strong, nonatomic) UILabel *avgSellLabel;
@property (strong, nonatomic) UILabel *sellAmountLabel;
@property (strong, nonatomic) UILabel *gainLabel;
@property (strong, nonatomic) UILabel *gainPercentLabel;
@property (strong, nonatomic) UILabel *avgCostLabel;
@property (strong, nonatomic) UILabel *costAmountLabel;
@property (strong, nonatomic) FSUIButton *hBtn;
@property (strong, nonatomic) FSUIButton *nBtn;
@property (strong, nonatomic) FSUIButton *gBtn;
//@property (strong, nonatomic) UIButton *removeBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
