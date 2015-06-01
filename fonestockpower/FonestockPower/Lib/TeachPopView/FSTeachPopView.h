//
//  FSTeachPopView2.h
//  WirtsLeg
//
//  Created by Neil on 14/4/14.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSTeachPopDelegate.h"
#import "KxMenu.h"
@class FSUIButton;

@interface FSTeachPopView : UIView{
    KxMenu * kx;
    UIButton * closeBtn;
}

@property (nonatomic ,weak) id <FSTeachPopDelegate> delegate;
@property (nonatomic ,strong)FSUIButton * checkBtn;;


-(void)showMenuWithRect:(CGRect)rect String:(NSString *)str Detail:(BOOL)detail Direction:(KxMenuViewArrowDirection)direction;
-(void)addHandImageWithType:(NSString *)type Rect:(CGRect)rect;
@end
