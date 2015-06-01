//
//  UpperDateView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/9.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawAndScrollController.h"


@interface UpperDateView : UIView {

    DrawAndScrollController *drawAndScrollController;
    NSMutableArray *dateLabels;
	NSMutableDictionary *dateLabelInfoDict;

    CGAffineTransform zoomTransform;
	id targetView;
    
    NSRecursiveLock * dataLock;
}

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;
@property (nonatomic, strong) NSMutableArray *dateLabels;
@property (nonatomic) CGAffineTransform zoomTransform;

- (void)updateLabels;
- (void)resetLabelTransform;
- (void)adjustForOrientation:(BOOL)isLandscape;

@end
