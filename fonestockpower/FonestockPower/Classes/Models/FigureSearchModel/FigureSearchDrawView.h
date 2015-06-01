//
//  FigureSearchDrawView.h
//  FonestockPower
//
//  Created by CooperLin on 2015/1/13.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FigureSearchDrawView : UIView

typedef NS_ENUM(NSUInteger, FSDrawType) {
    FSDrawTypePlainLine = 0,        // 0: 一般直線
    FSDrawTypeArrowHead,            // 1: 箭頭
};

@property (nonatomic) int type;
@property (nonatomic) BOOL isRedColor;
@property (strong, nonatomic) NSArray *upLineArray;
@property (strong, nonatomic) NSArray *mainBodyArray;
@property (strong, nonatomic) NSArray *upDownArray;
@property (strong, nonatomic) NSArray *downLineArray;

@property (strong, nonatomic) UIBezierPath *path;

@end
