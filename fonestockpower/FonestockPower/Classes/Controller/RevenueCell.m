//
//  RevenueCell.m
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/1/13.
//  Copyright 2009 NHCUE. All rights reserved.
//

#import "RevenueCell.h"
//#import "PlainStyleTableViewUtil.h"

@implementation RevenueCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		self.frame = frame;
        // Initialization code
    }
	
    return self;
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
//        // Initialization code
//    }
//	
//    return self;
//}

-(void)layoutSubviews
{
    self.dataLabels = [self.dataLabels sortedArrayUsingComparator:^NSComparisonResult(id label1, id label2) {
        if ([label1 frame].origin.x < [label2 frame].origin.x) return NSOrderedAscending;
        else if ([label1 frame].origin.x > [label2 frame].origin.x) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
    
    CGFloat labelXPosition = 0;
    CGFloat offset = self.frame.size.width/[_dataLabels count];
    for (UILabel *label in _dataLabels) {
        [label setFrame:CGRectMake(labelXPosition, label.frame.origin.y, label.frame.size.width, label.frame.size.height)];
        labelXPosition += offset;
    }
}

- (void)drawRect:(CGRect)rect {
 
	 [super drawRect:rect];
	
//	 [PlainStyleTableViewUtil backGroundColorOfTableViewCellByRoHeight:rect.size.height];
	
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
