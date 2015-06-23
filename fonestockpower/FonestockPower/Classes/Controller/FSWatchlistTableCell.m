//
//  FSWatchlistTableCell.m
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSWatchlistTableCell.h"

@interface FSWatchlistTableCell() {
    NSMutableDictionary *viewDict;
}
@end

@implementation FSWatchlistTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _defaultFont = [UIFont systemFontOfSize:15];
        viewDict = [[NSMutableDictionary alloc] init];
        
        [self addNameLabel];
        [self addDynamicLabel];
        [self addVolumeLabel];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel][_dynamicLabel0(_nameLabel)][_dynamicLabel1(_nameLabel)][_dynamicLabel2(_nameLabel)][_volumeLabel(_nameLabel)]|" options:0 metrics:nil views:viewDict]];

        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel]|" options:0 metrics:nil views:viewDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dynamicLabel0]|" options:0 metrics:nil views:viewDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dynamicLabel1]|" options:0 metrics:nil views:viewDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dynamicLabel2]|" options:0 metrics:nil views:viewDict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_volumeLabel]|" options:0 metrics:nil views:viewDict]];
    }
    return self;
}


- (void)addNameLabel {
#ifdef PatternPowerTW
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = _defaultFont;
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.numberOfLines = 1;
#else
    _nameLabel = [[MarqueeLabel alloc]initWithFrame:CGRectZero duration:6.0 andFadeLength:0.0f];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.numberOfLines = 1;
    _nameLabel.marqueeType = MLContinuousOneTimes;
    _nameLabel.continuousMarqueeExtraBuffer = 30.0f;
    _nameLabel.font = _defaultFont;
    [_nameLabel setLabelize:YES];
    
#endif
    _nameLabel.lineBreakMode = NSLineBreakByClipping;
    _nameLabel.textColor = [UIColor blueColor];
    [self.contentView addSubview:_nameLabel];
    
    [viewDict setValue:_nameLabel forKey:@"_nameLabel"];
}

- (void)addDynamicLabel {
    
    _dynamicLabel0 = [[UILabel alloc] init];
    _dynamicLabel0.translatesAutoresizingMaskIntoConstraints = NO;
    _dynamicLabel0.textAlignment = NSTextAlignmentRight;
    _dynamicLabel0.numberOfLines = 1;
    _dynamicLabel0.adjustsFontSizeToFitWidth = YES;
    _dynamicLabel0.font = _defaultFont;
    [self.contentView addSubview:_dynamicLabel0];
    [viewDict setObject:_dynamicLabel0 forKey:@"_dynamicLabel0"];
    
    _dynamicLabel1 = [[UILabel alloc] init];
    _dynamicLabel1.translatesAutoresizingMaskIntoConstraints = NO;
    _dynamicLabel1.textAlignment = NSTextAlignmentRight;
    _dynamicLabel1.numberOfLines = 1;
    _dynamicLabel1.adjustsFontSizeToFitWidth = YES;
    _dynamicLabel1.font = _defaultFont;
    [self.contentView addSubview:_dynamicLabel1];
    [viewDict setObject:_dynamicLabel1 forKey:@"_dynamicLabel1"];
    
    _dynamicLabel2 = [[UILabel alloc] init];
    _dynamicLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    _dynamicLabel2.textAlignment = NSTextAlignmentRight;
    _dynamicLabel2.numberOfLines = 1;
    _dynamicLabel2.adjustsFontSizeToFitWidth = YES;
    _dynamicLabel2.font = _defaultFont;
    [self.contentView addSubview:_dynamicLabel2];
    [viewDict setObject:_dynamicLabel2 forKey:@"_dynamicLabel2"];
    
}

- (void)addVolumeLabel
{
    self.volumeLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _volumeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _volumeLabel.textAlignment = NSTextAlignmentRight;
    _volumeLabel.font = _defaultFont;
    [_volumeLabel sizeToFit];
    _volumeLabel.numberOfLines = 1;
    _volumeLabel.adjustsFontSizeToFitWidth = YES;
    _volumeLabel.textColor = [UIColor colorWithRed:0.436 green:0.000 blue:0.455 alpha:1.000];
    [self.contentView addSubview:_volumeLabel];
    
    
    [viewDict setValue:_volumeLabel forKey:@"_volumeLabel"];
}

-(void)delayPointFiveSecondToCallLabelize
{
#ifdef PatternPowerUS
//    [_nameLabel setLabelize:NO];
#endif
}

- (void)prepareForReuse {
	[super prepareForReuse];
//    _dynamicLabel0.text = @"----";
//    _dynamicLabel1.text = @"----";
//    _dynamicLabel2.text = @"----";
//    _volumeLabel.text = @"----";
//    _nameLabel.backgroundColor = [UIColor clearColor];
//    _dynamicLabel0.backgroundColor = [UIColor clearColor];
//    _dynamicLabel1.backgroundColor = [UIColor clearColor];
//    _dynamicLabel2.backgroundColor = [UIColor clearColor];
}
@end
