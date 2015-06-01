//
//  FSTradeDiaryFixedTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSTradeDiaryFixedTableViewCell.h"

@implementation FSTradeDiaryFixedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 80, 30)];
        _symbolLabel.textAlignment = NSTextAlignmentCenter;
        _symbolLabel.textColor = [UIColor blueColor];
        [self.contentView addSubview:_symbolLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _symbolLabel = nil;
}

@end
