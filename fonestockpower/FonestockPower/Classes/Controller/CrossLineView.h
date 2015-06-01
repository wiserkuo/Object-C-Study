//
//  CrossLineView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/1/12.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CrossLineView : UIView {

    CGPoint crossPoint;
    UIColor *lineColor;

    BOOL horizontalHidden;
}

@property (nonatomic) CGPoint crossPoint;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic) BOOL horizontalHidden;

@end
