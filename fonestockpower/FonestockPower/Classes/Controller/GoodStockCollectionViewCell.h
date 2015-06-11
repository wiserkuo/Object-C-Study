//
//  GoodStockCollectionViewCell.h
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodStockCollectionViewCell : UICollectionViewCell


@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel * label;

-(void)setImage:(UIImage *)image;
-(void)setText:(NSString *)text;
@end
