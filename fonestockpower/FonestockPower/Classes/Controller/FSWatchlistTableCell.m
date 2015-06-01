//
//  FSWatchlistTableCell.m
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSWatchlistTableCell.h"

@implementation FSWatchlistTableCell

- (id)init {
    if (self = [super init]) {
        self.defaultFont = [UIFont systemFontOfSize:15];
        [self addNameLabel];
        [self addDynamicLabel];
        [self addVolumeLabel];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.defaultFont = [UIFont systemFontOfSize:15];
        [self addNameLabel];
        [self addDynamicLabel];
        [self addVolumeLabel];
    }
    return self;
}

#pragma mark - UI Init

- (void)addNameLabel
{
#ifdef PatternPowerUS
    self.nameLabel = [[MarqueeLabel alloc]initWithFrame:CGRectZero duration:6.0 andFadeLength:0.0f];
    _nameLabel.marqueeType = MLContinuousOneTimes;
    _nameLabel.continuousMarqueeExtraBuffer = 30.0f;
    _nameLabel.font = _defaultFont;
    [_nameLabel setLabelize:YES];
#else
    _nameLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _nameLabel.numberOfLines = 1;
    _nameLabel.adjustsFontSizeToFitWidth = YES;
#endif
    _nameLabel.lineBreakMode = NSLineBreakByClipping;
    _nameLabel.textColor = [UIColor blueColor];
    [self.contentView addSubview:_nameLabel];
}

- (void)addDynamicLabel
{
    for (NSUInteger count=0; count < 3; count++) {
        NSString *labelKeypath = [NSString stringWithFormat:@"dynamicLabel%d", (int)count];
        [self setValue:[[UILabel alloc] initWithFrame:self.contentView.bounds] forKey:labelKeypath];
        UILabel *label = [self valueForKey:labelKeypath];
        label.textAlignment = NSTextAlignmentRight;
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
        label.font = _defaultFont;
        [self.contentView addSubview:[self valueForKeyPath:labelKeypath]];
    }
}

- (void)addVolumeLabel
{
    self.volumeLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _volumeLabel.textAlignment = NSTextAlignmentRight;
    _volumeLabel.font = _defaultFont;
    [_volumeLabel sizeToFit];
    _volumeLabel.numberOfLines = 1;
    _volumeLabel.adjustsFontSizeToFitWidth = YES;
    _volumeLabel.textColor = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
    [self.contentView addSubview:_volumeLabel];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellWidth = CGRectGetWidth(self.bounds);
    CGFloat offset = cellWidth/5-1;

    _nameLabel.frame = CGRectMake(0, 0, offset, self.bounds.size.height);
    _dynamicLabel0.frame = CGRectMake(offset, 0, offset, self.bounds.size.height);
    _dynamicLabel0.textAlignment = NSTextAlignmentRight;
    _dynamicLabel1.frame = CGRectMake(offset*2, 0, offset, self.bounds.size.height);
    _dynamicLabel1.textAlignment = NSTextAlignmentRight;
    _dynamicLabel2.frame = CGRectMake(offset*3, 0, offset, self.bounds.size.height);
    _dynamicLabel2.textAlignment = NSTextAlignmentRight;
    _volumeLabel.frame = CGRectMake(cellWidth - offset+3 , 0, offset-5, self.bounds.size.height);

    [self performSelector:@selector(delayPointFiveSecondToCallLabelize) withObject:nil afterDelay:0.5];

}

-(void)delayPointFiveSecondToCallLabelize
{
#ifdef PatternPowerUS
    [_nameLabel setLabelize:NO];
#endif
}

- (void)prepareForReuse {
	[super prepareForReuse];
    _dynamicLabel0.text = @"----";
    _dynamicLabel1.text = @"----";
    _dynamicLabel2.text = @"----";
    _volumeLabel.text = @"----";
    _nameLabel.backgroundColor = [UIColor clearColor];
    _dynamicLabel0.backgroundColor = [UIColor clearColor];
    _dynamicLabel1.backgroundColor = [UIColor clearColor];
    _dynamicLabel2.backgroundColor = [UIColor clearColor];
}

@end
