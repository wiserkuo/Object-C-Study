//
//  FSHistoricalEPSCell.m
//  FonestockPower
//
//  Created by Connor on 14/4/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSHistoricalEPSCell.h"

@implementation FSHistoricalEPSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _field1 = [self newLabel];
        _field2 = [self newLabel];
        _field3 = [self newLabel];
        _field4 = [self newLabel];
        _field5 = [self newLabel];
        _field6 = [self newLabel];
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    _field1.text = nil;
    _field2.text = nil;
    _field3.text = nil;
    _field4.text = nil;
    _field5.text = nil;
    _field6.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect contentRect = self.contentView.bounds;
    CGFloat cellWidth = self.contentView.bounds.size.width / 6;
    
    _field1.frame = CGRectMake(0, 0, cellWidth, contentRect.size.height);
    _field2.frame = CGRectMake(cellWidth, 0, cellWidth-2, contentRect.size.height);
    _field3.frame = CGRectMake(cellWidth * 2, 0, cellWidth, contentRect.size.height);
    _field4.frame = CGRectMake(cellWidth * 3, 0, cellWidth-2, contentRect.size.height);
    _field5.frame = CGRectMake(cellWidth * 4, 0, cellWidth, contentRect.size.height);
    _field6.frame = CGRectMake(cellWidth * 5, 0, cellWidth-2, contentRect.size.height);
    
}

- (UILabel *)newLabel {
    UILabel *result = [[UILabel alloc] init];
    result.backgroundColor = [UIColor clearColor];
    result.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:result];
    return result;
}

@end
