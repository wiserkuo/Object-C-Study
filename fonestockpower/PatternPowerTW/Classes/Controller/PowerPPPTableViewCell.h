//
//  PowerPPPTableViewCell.h
//  FonestockPower
//
//  Created by CooperLin on 2014/11/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSUITableViewCell.h"

@interface PowerPPPTableViewCell : FSUITableViewCell

@property (nonatomic, strong) UILabel *mainLbl;
@property (nonatomic, strong) UILabel *subLbl;

- (instancetype)initWithLStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (instancetype)initWithRStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
