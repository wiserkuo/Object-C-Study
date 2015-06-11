//
//  FinancialTableViewCell.m
//  WirtsLeg
//
//  Created by Neil on 13/11/12.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FinancialTableViewCell.h"
#import "MarqueeLabel.h"


@implementation FinancialTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:232.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
        // Initialization code
        self.titleLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(0, 0, 130, 30) duration:6.0 andFadeLength:0.0f];
        _titleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:232.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
        [_titleLabel addGestureRecognizer:tapRecognizer];
        _titleLabel.userInteractionEnabled = YES;
        _titleLabel.marqueeType = 4;
        _titleLabel.continuousMarqueeExtraBuffer = 30.0f;
        [_titleLabel setLabelize:YES];
        [self.contentView addSubview:_titleLabel];
        
        self.group1Label = [[UILabel alloc]initWithFrame:CGRectMake(130, 0, 90, 30)];
        self.group1Label.backgroundColor = [UIColor whiteColor];
        _group1Label.textAlignment = NSTextAlignmentRight;
        _group1Label.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_group1Label];
        
        self.group2Label = [[UILabel alloc]initWithFrame:CGRectMake(220, 0, 100, 30)];
        _group2Label.textAlignment = NSTextAlignmentRight;
        _group2Label.adjustsFontSizeToFitWidth = YES;
        self.group2Label.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_group2Label];
        
        
        
    }
    return self;
}

- (void)labelTap:(UITapGestureRecognizer *)recognizer{
    NSLog(@"click");
    [(MarqueeLabel *)recognizer.view setLabelize:NO];
}
- (void)prepareForReuse {
	[super prepareForReuse];
    
    _titleLabel.text = nil;
    _group1Label.text = nil;
    _group2Label.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
