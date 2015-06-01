//
//  TQuotedPriceLeftCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TQuotedPriceLeftCell : UITableViewCell
@property (nonatomic , strong) UILabel *nameLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier CellWidth:(double)width Type:(int)type;
@end
