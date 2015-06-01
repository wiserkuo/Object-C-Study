//
//  MarginTradingAccFixedCell.m
//  WirtsLeg
//
//  Created by Connor on 13/7/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "MarginTradingAccFixedCell.h"

@implementation MarginTradingAccFixedCell
@synthesize field1;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        field1 = [UILabel new];
        field1.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:field1];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	field1.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    
    field1.frame = CGRectMake(0, 0, contentRect.size.width, contentRect.size.height);
}

@end
