//
//  FSTodayReserve2Cell.m
//  FonestockPower
//
//  Created by Derek on 2015/1/15.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSTodayReserve2Cell.h"

@implementation FSTodayReserve2Cell

@synthesize field1, field2, field3, field4, field5, field6, field7, field8;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        field1 = [UILabel new];
        field1.textAlignment = NSTextAlignmentCenter;
        field1.backgroundColor = [UIColor clearColor];
        field1.numberOfLines = 0;
        
        field2 = [UILabel new];
        field2.textAlignment = NSTextAlignmentCenter;
        field2.backgroundColor = [UIColor clearColor];
        
        field3 = [UILabel new];
        field3.textAlignment = NSTextAlignmentCenter;
        field3.backgroundColor = [UIColor clearColor];
        
        field4 = [UILabel new];
        field4.textAlignment = NSTextAlignmentCenter;
        field4.backgroundColor = [UIColor clearColor];
        
        field5 = [UILabel new];
        field5.textAlignment = NSTextAlignmentCenter;
        field5.backgroundColor = [UIColor clearColor];
        
        field6 = [UILabel new];
        field6.textAlignment = NSTextAlignmentCenter;
        field6.backgroundColor = [UIColor clearColor];
        
        field7 = [UILabel new];
        field7.textAlignment = NSTextAlignmentCenter;
        field7.backgroundColor = [UIColor clearColor];
        
        field8 = [UILabel new];
        field8.textAlignment = NSTextAlignmentCenter;
        field8.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:field1];
        [self.contentView addSubview:field2];
        [self.contentView addSubview:field3];
        [self.contentView addSubview:field4];
        [self.contentView addSubview:field5];
        [self.contentView addSubview:field6];
        [self.contentView addSubview:field7];
        [self.contentView addSubview:field8];

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
    field6.text = nil;
    field7.text = nil;
    field8.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    
    CGFloat cellWidth = self.contentView.bounds.size.width / 4;
    
    field1.frame = CGRectMake(0, 0, cellWidth, contentRect.size.height);
    field2.frame = CGRectMake(cellWidth, 0, cellWidth, contentRect.size.height);
    field3.frame = CGRectMake(cellWidth * 2, 0, cellWidth, contentRect.size.height);
    field4.frame = CGRectMake(cellWidth * 3, 0, cellWidth, contentRect.size.height);
    
    field5.frame = CGRectMake(0, 0, cellWidth * 2, contentRect.size.height);
    field6.frame = CGRectMake(cellWidth * 2, 0, cellWidth * 2, contentRect.size.height);
    
    field7.frame = CGRectMake(cellWidth, 0, cellWidth * 4 / 3, contentRect.size.height);
    field8.frame = CGRectMake((cellWidth * 4 / 3) + cellWidth, 0, cellWidth * 4 / 3, contentRect.size.height);

}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
