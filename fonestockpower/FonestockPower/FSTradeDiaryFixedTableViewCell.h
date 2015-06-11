//
//  FSTradeDiaryFixedTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSTradeDiaryFixedTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *symbolLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
