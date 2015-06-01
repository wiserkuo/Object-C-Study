//
//  BtnCollectionViewCell.h
//  WirtsLeg
//
//  Created by Neil on 13/10/8.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"

@class FSUIButton;
@interface BtnCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;

@property (strong)FSUIButton * button;
@property (strong)UILongPressGestureRecognizer *pan;
@property (nonatomic) int btnFlag;
-(void)setButtonText:(NSString *)button;
-(void)setButtonTextColor:(UIColor *)color;
-(void)setButtonTag:(int)tag;
-(void)click:(FSUIButton *)btn;
@end
