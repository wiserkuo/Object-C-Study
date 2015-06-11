//
//  RelatedNewsListCell.m
//  WirtsLeg
//
//  Created by Connor on 13/6/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//  相關新聞Cell

#import "RelatedNewsListCell.h"

@implementation RelatedNewsListCell
@synthesize titleLabel, datetimeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.datetimeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:datetimeLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    
    CGFloat boundsX = contentRect.origin.x;
//    CGFloat boundsY = contentRect.origin.y;
    CGFloat width = contentRect.size.width;
    CGFloat height = contentRect.size.height;
    
    CGFloat paddingWidth = 10;
    
    CGRect frame;
    
    frame = CGRectMake(boundsX + 10, 0, width - paddingWidth * 2, 50);
    self.titleLabel.frame = frame;
    
    frame = CGRectMake(boundsX + 10, height - 25, width - paddingWidth * 2, 25);
    self.datetimeLabel.frame = frame;
}
@end
