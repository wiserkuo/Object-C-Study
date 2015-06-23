//
//  FSInsetsLabel.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/6/17.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSInsetsLabel : UILabel{
    CGFloat topInset;
    CGFloat leftInset;
    CGFloat bottomInset;
    CGFloat rightInset;
}

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) CGFloat rightInset;

@end
