//
//  FSActionEditCondictionCell.m
//  FonestockPower
//
//  Created by Derek on 2014/5/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionEditCondictionCell.h"

@implementation FSActionEditCondictionCell 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
#ifdef PatternPowerUS
        self.label = [[MarqueeLabel alloc] initWithFrame:CGRectZero duration:6.0 andFadeLength:0.0f];
        _label.marqueeType = MLContinuousOneTimes;
        _label.continuousMarqueeExtraBuffer = 30.0f;
        _label.textAlignment = NSTextAlignmentCenter;
        [_label setLabelize:YES];
#else
        _label = [[UILabel alloc]init];
        _label.textAlignment = NSTextAlignmentCenter;
#endif
        _label.lineBreakMode = NSLineBreakByClipping;
        
        if ([reuseIdentifier isEqualToString:@"Landscape"]) {
            _label.frame = CGRectMake(0, 0, 250, 44);
        }else{
            _label.frame = CGRectMake(60, 0, 140, 44);
        }
        
        [self.contentView addSubview:_label];
#ifdef PatternPowerUS
        [_label setLabelize:NO];
#endif
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
    _label.text = nil;
}


@end
