//
//  UpperValueView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/6.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawAndScrollController.h"


@interface UpperValueView : UIView {

    DrawAndScrollController *drawAndScrollController;
    NSMutableArray *valueLabels;
    NSMutableArray *markViews;
	float lowest;
	float highest;
	
    CGAffineTransform zoomTransform;
    
    NSRecursiveLock * dataLock;
}

@property (nonatomic, readwrite) float lowest;
@property (nonatomic, readwrite) float highest;
@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;
@property (nonatomic) CGAffineTransform zoomTransform;


- (void)updateLabels;
- (void)resetLabelTransform;
- (void)checkLabelStatus;
- (void)adjustForOrientation:(BOOL)isLandscape;

@end
