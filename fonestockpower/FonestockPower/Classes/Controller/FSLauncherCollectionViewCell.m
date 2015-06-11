//
//  FGLauncherCollectionViewCell.m
//  WirtsLeg
//
//  Created by Connor on 13/10/18.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSLauncherCollectionViewCell.h"

@implementation FSLauncherCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addTitleLabel];
        [self addImage];
        self.layer.shouldRasterize = YES;
        [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];

        [self processLayout];
    }
    return self;
}

- (void)addTitleLabel {
    self.title = [[UILabel alloc] init];
    self.title.backgroundColor = [UIColor clearColor];
    
#ifdef PatternPowerUS
    self.title.font = [UIFont systemFontOfSize:14];
#else
    self.title.font = [UIFont systemFontOfSize:16.0f];
#endif
    self.title.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
    self.title.shadowOffset = CGSizeMake(1.0f, 1.0f);
    self.title.textColor = [UIColor whiteColor];
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.numberOfLines = 0;
    [self.contentView addSubview:_title];
}

- (void)addImage {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_imageView];
}

- (void)processLayout {
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_title, _imageView);
    
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView(92)]-2-[_title]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_imageView(92)]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_title]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:viewDictionary]];
}

@end
