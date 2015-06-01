//
//  UIBezierPath+dqd_arrowhead.h
//  FonestockPower
//
//  Created by CooperLin on 2015/1/13.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

//在網路上找到畫箭頭的category
@interface UIBezierPath (dqd_arrowhead)

+ (UIBezierPath *)dqd_bezierPathWithArrowFromPoint:(CGPoint)startPoint
                                           toPoint:(CGPoint)endPoint
                                         tailWidth:(CGFloat)tailWidth
                                         headWidth:(CGFloat)headWidth
                                        headLength:(CGFloat)headLength;

@end
