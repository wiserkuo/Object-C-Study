//
//  FSOptionCell.m
//  FonestockPower
//
//  Created by Derek on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionCell.h"

@implementation FSOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _labels = [[NSMutableArray alloc] initWithCapacity:capacity];
        
        for (int i = 0; i < capacity; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * 77, 0, 77, 44)];
            label.textAlignment = NSTextAlignmentCenter;
            [_labels addObject:label];
            [self.contentView addSubview:label];
        }
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
    
    for (UILabel *label in _labels) {
        label.text = nil;
    }
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
