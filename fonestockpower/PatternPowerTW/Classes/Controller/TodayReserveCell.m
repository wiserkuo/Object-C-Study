//
//  TodayReserveCell.m
//  Bullseye
//
//  Created by Connor on 13/9/5.
//
//

#import "TodayReserveCell.h"

@implementation TodayReserveCell

@synthesize field1, field2, field3, field4, field5, field6;

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
        
        [self.contentView addSubview:field1];
        [self.contentView addSubview:field2];
        [self.contentView addSubview:field3];
        [self.contentView addSubview:field4];
        [self.contentView addSubview:field5];
        [self.contentView addSubview:field6];
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
    
    
}

@end
