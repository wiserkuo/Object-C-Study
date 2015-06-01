//
//  SKCustomTableViewCell.m
//  WirtsLeg
//
//  Created by Connor on 13/8/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "SKCustomTableViewCell.h"

@implementation SKCustomTableViewCell
@synthesize labels;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.labels = [[NSMutableArray alloc] initWithCapacity:capacity];
        
        for (int i = 0; i < capacity; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * 77, 0, 77, 44)];
            [self.labels addObject:label];
            [self.contentView addSubview:label];
        }
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
    for (UILabel *label in labels) {
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
