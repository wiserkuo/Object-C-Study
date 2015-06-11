//
//  FSAddActionEditCondictionCell.m
//  FonestockPower
//
//  Created by Derek on 2014/5/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAddActionEditCondictionCell.h"

@implementation FSAddActionEditCondictionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
#ifdef PatternPowerUS
        self.label = [[MarqueeLabel alloc] initWithFrame:CGRectZero duration:6.0 andFadeLength:0.0f];
        _label.marqueeType = MLContinuousOneTimes;
        _label.continuousMarqueeExtraBuffer = 30.0f;
        [_label setLabelize:YES];
#else
        _label = [[UILabel alloc]init];
        _label.textAlignment = NSTextAlignmentCenter;
#endif
        _label.lineBreakMode = NSLineBreakByClipping;
        
        _addButton = [[UIButton alloc] init];
        [_addButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _nonButton = [[FSUIButton alloc] init];
        [_nonButton setImage:[UIImage imageNamed:@"+藍色小球"] forState:UIControlStateNormal];
        
        if ([reuseIdentifier isEqualToString:@"Landscape"]) {
            _addButton.frame = CGRectMake(300, 0, [[UIScreen mainScreen]applicationFrame].size.height-200, 44);
            _nonButton.frame = CGRectMake(340, 0, 44, 44);
            _label.frame = CGRectMake(20, 0, 130, 44);
        }else{
            _addButton.frame = CGRectMake(120, 0, [[UIScreen mainScreen]applicationFrame].size.width-140, 44);
            _nonButton.frame = CGRectMake(190, 0, 44, 44);
            _label.frame = CGRectMake(20, 0, 70, 44);
        }
        [_addButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_nonButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_addButton];
        [self.contentView addSubview:_nonButton];
        [self performSelector:@selector(delayPointFiveSecondToCallLabelize) withObject:nil afterDelay:0.5];
    }
    return self;
}

-(void)delayPointFiveSecondToCallLabelize
{
#ifdef PatternPowerUS
    [_label setLabelize:NO];
#endif
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];
    [_addButton setTitle:@"" forState:UIControlStateNormal];
    _label.text = nil;
}

- (void)buttonAction:(FSUIButton *)sender{
    [_delegate cellButtonActionBegainWithCell:self];
    [_delegate cellButtonAction:self];
}


@end
