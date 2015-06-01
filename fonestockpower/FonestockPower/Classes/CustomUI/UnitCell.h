//
//  UnitCell.h
//  UsingFixed2322ItemsAutolayout
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitCell : UIView

@property (nonatomic, strong) UIImageView *img;
@property (nonatomic, strong) UILabel *lbl;

-(id)initWithCell:(NSString *)imgItem :(NSString *)lblItem imageSize:(NSInteger)imageSize;
-(instancetype)initWithCloserCell:(NSString *)imgItem :(NSString *)lblItem howClose:(NSInteger)theDistance imageSize:(NSInteger)imageSize;

@end
