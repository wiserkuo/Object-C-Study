//
//  FSOptionInfoCell.m
//  FonestockPower
//
//  Created by Derek on 2014/10/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSOptionInfoCell.h"

@implementation FSOptionInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _field1 = [self newLabel];
        _field2 = [self newLabel];
        _field3 = [self newLabel];
        _field4 = [self newLabel];
        _header1 = [self newLabel];
        _header2 = [self newLabel];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    _field1.text = nil;
    _field2.text = nil;
    _field3.text = nil;
    _field4.text = nil;
    _header1.text = nil;
    _header2.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    CGFloat cellWidth = self.contentView.bounds.size.width / 4;
    CGFloat cellHeaderWidth = self.contentView.bounds.size.width / 2;
    
    _field1.frame = CGRectMake(0, 0, cellWidth, contentRect.size.height);
    _field2.frame = CGRectMake(cellWidth, 0, cellWidth-2, contentRect.size.height);
    _field3.frame = CGRectMake(cellWidth * 2, 0, cellWidth, contentRect.size.height);
    _field4.frame = CGRectMake(cellWidth * 3, 0, cellWidth-2, contentRect.size.height);
    
    _header1.frame = CGRectMake(0, 0, cellHeaderWidth, contentRect.size.height);
    _header2.frame = CGRectMake(cellHeaderWidth, 0, cellHeaderWidth-2, contentRect.size.height);
}

- (UILabel *)newLabel {
    UILabel *result = [[UILabel alloc] init];
    result.backgroundColor = [UIColor clearColor];
    result.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:result];
    return result;
}


@end
