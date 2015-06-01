//
//  UnitCell.m
//  UsingFixed2322ItemsAutolayout
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import "UnitCell.h"

static NSInteger _imageSize = 80;
@interface UnitCell(){
    UIView *vv;
    int heightOfLabel;
}
@end

@implementation UnitCell

-(id)initWithCell:(NSString *)imgItem :(NSString *)lblItem imageSize:(NSInteger)imageSize
{
    self = [super init];
    if(self){
        self.img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgItem]];
        self.img.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.img];
        self.lbl = [[UILabel alloc] init];
        self.lbl.text = lblItem;
        if(!isnan(imageSize) && _imageSize != imageSize)_imageSize = imageSize;
        heightOfLabel = 33;
#ifdef PatternPowerUS
        self.lbl.font = [UIFont systemFontOfSize:15];
        self.lbl.numberOfLines = 0;
        if([lblItem isEqualToString:@"Pattern\nTracking"]){// || [lblItem isEqualToString:@"My\nPatterns"]  || [lblItem isEqualToString:@"Action\nPlan"]){
            self.lbl.textAlignment = NSTextAlignmentCenter;
            heightOfLabel = 40;
        }
#else
        self.lbl.font = [UIFont boldSystemFontOfSize:18];
        self.lbl.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        self.lbl.shadowOffset = CGSizeMake(1.0f, 1.0f);
#endif
        self.lbl.textColor = [UIColor whiteColor];
        self.lbl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.lbl];
        [self doAutolayout];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)doAutolayout
{
    [self removeConstraints:self.constraints];
    
    NSNumber *heightOfLabels = [NSNumber numberWithInt:heightOfLabel];
    NSDictionary *metrics = @{@"HeightOfLabel":heightOfLabels,@"imageSize":[NSNumber numberWithInteger:_imageSize]};
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_img, _lbl);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_img(imageSize)]" options:0 metrics:metrics views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_img(imageSize)][_lbl(HeightOfLabel)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_lbl]" options:0 metrics:nil views:allObj]];
    [super updateConstraints];
}

-(instancetype)initWithCloserCell:(NSString *)imgItem :(NSString *)lblItem howClose:(NSInteger)theDistance imageSize:(NSInteger)imageSize
{
    self = [super init];
    if(self){
        vv = [[UIView alloc] init];
        vv.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:vv];
        self.img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgItem]];
        self.img.translatesAutoresizingMaskIntoConstraints = NO;
        [vv addSubview:self.img];
        self.lbl = [[UILabel alloc] init];
        self.lbl.text = lblItem;
        heightOfLabel = 33;
        if(!isnan(imageSize))_imageSize = imageSize;
#ifdef PatternPowerUS
        self.lbl.font = [UIFont systemFontOfSize:15];
        self.lbl.numberOfLines = 0;
        if([lblItem isEqualToString:@"型態追蹤"]){// || [lblItem isEqualToString:@"我的自選"] || [lblItem isEqualToString:@"交易警示"]){
            heightOfLabel = 60;
        }
#else
        self.lbl.font = [UIFont boldSystemFontOfSize:18];
        self.lbl.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
        self.lbl.shadowOffset = CGSizeMake(1.0f, 1.0f);
#endif
        self.lbl.textColor = [UIColor whiteColor];
        self.lbl.translatesAutoresizingMaskIntoConstraints = NO;
        [vv addSubview:self.lbl];
        [self doCloserAutolayout];
        self.userInteractionEnabled = YES;
    }
    
    return self;
}
-(void)doCloserAutolayout
{
    [self removeConstraints:self.constraints];
    
    NSNumber *heightOfLabels = [NSNumber numberWithInt:heightOfLabel];
    NSDictionary *metrics = @{@"HeightOfLabel":heightOfLabels,@"imageSize":[NSNumber numberWithInteger:_imageSize]};
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_img, _lbl, vv);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[vv]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vv]|" options:0 metrics:nil views:allObj]];
    
    [vv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_img(imageSize)]|" options:0 metrics:metrics views:allObj]];
    [vv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_img(imageSize)][_lbl(HeightOfLabel)]|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [vv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_lbl]" options:0 metrics:nil views:allObj]];
    [super updateConstraints];
}



//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
