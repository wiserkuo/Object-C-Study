//
//  DrawAndScrollView.h
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/3/16.
//  Copyright 2009 telepaq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawAndScrollController.h"

@class DrawAndScrollController;
@interface DrawAndScrollView : UIView {
	
	DrawAndScrollController *drawAndScrollController;
	
	UIView *targetView;		
	
	UITouch *multiTouchFinger1;
	UITouch *multiTouchFinger2;
	
	CGPoint multiTouchStartPoint1;
	CGPoint multiTouchStartPoint2;
	CGPoint multiTouchEndPoint1;
	CGPoint multiTouchEndPoint2;
	
}

//@property (nonatomic, retain) IBOutlet DrawAndScrollController *drawAndScrollController;
@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

-(void)cleanTouchesStatus:(NSSet *)touches;

-(BOOL)isFingersScrollSameXDirectionOnPreviousPoint1:(CGPoint)previousPoint1 currentPoint1:(CGPoint)currentPoint1 previousPoint2:(CGPoint)previousPoint2 currentPoint2:(CGPoint)currentPoint2;

-(BOOL)isFingersScrollSameYDirectionOnPreviousPoint1:(CGPoint)previousPoint1 currentPoint1:(CGPoint)currentPoint1 previousPoint2:(CGPoint)previousPoint2 currentPoint2:(CGPoint)currentPoint2;

-(void)multiTouchBottonToDown;
-(void)multiTouchDownToBotton;
-(void)multiTouchLeftToRight;
-(void)multiTouchRightToLeft;

@end
