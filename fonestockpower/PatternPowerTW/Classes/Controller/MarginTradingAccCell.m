//
//  MarginTradingAccCell.m
//  WirtsLeg
//
//  Created by Connor on 13/7/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "MarginTradingAccCell.h"

@implementation MarginTradingAccCell
@synthesize field1, field2, field3, field4, field5;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        field1 = [UILabel new];
        field1.textAlignment = NSTextAlignmentCenter;
        
        field2 = [UILabel new];
        field2.textAlignment = NSTextAlignmentCenter;
        
        field3 = [UILabel new];
        field3.textAlignment = NSTextAlignmentCenter;
        
        field4 = [UILabel new];
        field4.textAlignment = NSTextAlignmentCenter;
        
        field5 = [UILabel new];
        field5.textAlignment = NSTextAlignmentCenter;

        
        [self.contentView addSubview:field1];
        [self.contentView addSubview:field2];
        [self.contentView addSubview:field3];
        [self.contentView addSubview:field4];
        [self.contentView addSubview:field5];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	field1.text = nil;
    field2.text = nil;
    field3.text = nil;
    field4.text = nil;
    field5.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    
    CGFloat cellWidth = self.contentView.bounds.size.width / 5;
    
    field1.frame = CGRectMake(0, 0, cellWidth, contentRect.size.height);
    field2.frame = CGRectMake(cellWidth, 0, cellWidth, contentRect.size.height);
    field3.frame = CGRectMake(cellWidth * 2, 0, cellWidth, contentRect.size.height);
    field4.frame = CGRectMake(cellWidth * 3, 0, cellWidth, contentRect.size.height);
    field5.frame = CGRectMake(cellWidth * 4, 0, cellWidth, contentRect.size.height);
    
}

@end
