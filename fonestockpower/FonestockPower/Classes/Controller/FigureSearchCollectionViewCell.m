//
//  FGFigureSearchCollectionViewCell.m
//  WirtsLeg
//
//  Created by Connor on 13/10/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchCollectionViewCell.h"

@implementation FigureSearchCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addTitleLabel];
        [self addImage];
        [self setNeedsUpdateConstraints];
        self.layer.shouldRasterize = YES;
        [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    }
    return self;
}

- (void)addTitleLabel {
    self.title = [[UILabel alloc] init];
    self.title.backgroundColor = [UIColor clearColor];
//    self.title.adjustsFontSizeToFitWidth = YES;
    self.title.numberOfLines = 2;
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_title];
}

- (void)addImage {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_imageView];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_title, _imageView);
    NSDictionary *metrics = @{@"imageWidth": @(CGRectGetHeight(self.frame) * 1.0)
                              };
    
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView(imageWidth)]-2-[_title]" options:0 metrics:metrics views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_title]|" options:0 metrics:nil views:viewDictionary]];
}

@end
