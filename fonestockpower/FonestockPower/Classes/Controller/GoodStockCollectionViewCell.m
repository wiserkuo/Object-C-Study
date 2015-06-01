//
//  GoodStockCollectionViewCell.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "GoodStockCollectionViewCell.h"

@implementation GoodStockCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.imageView];
        
        self.label = [[UILabel alloc]init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.numberOfLines = 3;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.font = [UIFont boldSystemFontOfSize:18];
        [self.contentView addSubview:self.label];
        
        [self setNeedsUpdateConstraints];
        
    }
    return self;
}
- (void)updateConstraints {
    
    [self.contentView removeConstraints:self.contentView.constraints];
    
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_imageView,_label);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_imageView(70)]-2-[_label(20)]" options:0 metrics:nil views:viewControllers]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[_imageView(70)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_label]|" options:0 metrics:nil views:viewControllers]];
    
    [super updateConstraints];
    
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

-(void)setText:(NSString *)text{
    self.label.text = text;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
