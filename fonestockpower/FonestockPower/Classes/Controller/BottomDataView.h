//
//  BottomDataView.h
//  Bullseye
//
//  Created by Ray Kuo on 2008/12/29.
//  Copyright 2008 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawAndScrollController.h"
#import "Indicator.h"

@class BottonView;


@interface BottomDataView : UIView {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
	BOOL haveCross;
	int crossIndex;
    UILabel * titleLabel;
    
    NSRecursiveLock * dataLock;
}

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;
@property (nonatomic, strong) BottonView *bottonView;

- (void)updateValueWithIndex:(int)index;		//畫技術分析值用

@end
