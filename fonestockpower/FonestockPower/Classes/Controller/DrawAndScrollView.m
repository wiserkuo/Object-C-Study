//
//  DrawAndScrollView.m
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/3/16.
//  Copyright 2009 telepaq. All rights reserved.
//

#import "DrawAndScrollView.h"

#define X_MOVE_MAX_DIST 40
#define X_MOVE_MIN_DIST 15

#define Y_MOVE_MAX_DIST 40
#define Y_MOVE_MIN_DIST 15

static BOOL fingersScrollSameXDirection = YES;
static BOOL fingersScrollSameYDirection = YES;

@implementation DrawAndScrollView

@synthesize drawAndScrollController;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


// touch controls
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	targetView = [super hitTest:point withEvent:event];
	
	return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	static NSTimeInterval timeBegan = 0;	
	if(timeBegan ==  [event timestamp])
		return;
	else
		timeBegan = [event timestamp];	
	

	if([touches count]>=2){ 
		
		//NSLog(@"touches began event, finger count = 2");
		
		multiTouchFinger1 = [[touches allObjects] objectAtIndex:0];		
		multiTouchFinger2 = [[touches allObjects] objectAtIndex:1];				
		
	}
	else{
		
		//NSLog(@"touches began event, finger count = 1");		
		
		if(!multiTouchFinger1)
			multiTouchFinger1 = [[touches allObjects] objectAtIndex:0];
		else
			multiTouchFinger2 = [[touches allObjects] objectAtIndex:0];
		
		
		//if(!multiTouchFinger2)
			//[targetView touchesBegan:touches withEvent:event];
		
	}

	

	[targetView touchesBegan:touches withEvent:event];	
	
	//drawAndScrollController.multiTouchMode = NO;		
	
	
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"touches moved event");
	static NSTimeInterval timeMoved = 0;
	if(timeMoved ==  [event timestamp])
		return;
	else
		timeMoved = [event timestamp];	
	
	
	if(!multiTouchFinger2){
		
		//[targetView touchesMoved:touches withEvent:event];
		//NSLog(@"target moved");
		
	}
	
    else if(multiTouchFinger1 && multiTouchFinger2){ 
	//if(multiTouchFinger1 && multiTouchFinger2){ 
		
		if([touches count]>=2){ // get 
			
	        BOOL sameXDirection;		
			BOOL sameYDirection;
			
			//drawAndScrollController.multiTouchMode = YES;
			
			//第一次的 multi-touch touchMove座標值給 multiTouchStartPoint1 ＆ multiTouchStartPoint2
			if((multiTouchStartPoint1.x==0) && (multiTouchStartPoint1.y==0)){
				
				multiTouchStartPoint1 = [[[touches allObjects] objectAtIndex:0] locationInView:self];
				multiTouchEndPoint1 = [[[touches allObjects] objectAtIndex:0] locationInView:self];		
				
			}			
			if((multiTouchStartPoint2.x==0) && (multiTouchStartPoint2.y==0)){
				
				multiTouchStartPoint2 = [[[touches allObjects] objectAtIndex:1] locationInView:self];
				multiTouchEndPoint2 = [[[touches allObjects] objectAtIndex:1] locationInView:self];		
				
			}
			
			
		    //接著給 multiTouchEndPoint1 ＆ multiTouchEndPoint2			
			CGPoint prePoint1 = multiTouchEndPoint1;
			CGPoint prePoint2 = multiTouchEndPoint2;
			multiTouchEndPoint1 = [[[touches allObjects] objectAtIndex:0] locationInView:self];  //持續更新 multiTouchEndPoint1,
			multiTouchEndPoint2 = [[[touches allObjects] objectAtIndex:1] locationInView:self];  //持續更新 multiTouchEndPoint2,
			
			sameXDirection = [self isFingersScrollSameXDirectionOnPreviousPoint1:prePoint1 currentPoint1:multiTouchEndPoint1 
																  previousPoint2:prePoint2 currentPoint2:multiTouchEndPoint2];
			sameYDirection = [self isFingersScrollSameYDirectionOnPreviousPoint1:prePoint1 currentPoint1:multiTouchEndPoint1 
																  previousPoint2:prePoint2 currentPoint2:multiTouchEndPoint2];			
			
			
			
			// 只要 sameXDirection or sameYDirection 有一次方向不相同 就判斷為不往相同方向移動
			if(!sameXDirection){
				fingersScrollSameXDirection = NO;
				//NSLog(@"scroll same X direction:NO");
			}
			else{
			
			}
			
			
			if(!sameYDirection){
				fingersScrollSameYDirection = NO;
				//NSLog(@"scroll same Y direction:NO");
			} 
			
			
			
		}
		
		
		
	}

	
	if([touches count]>=2){
		
		if(!fingersScrollSameXDirection || !fingersScrollSameYDirection)
			[targetView touchesMoved:touches withEvent:event];
	
	}
	else{
		
			[targetView touchesMoved:touches withEvent:event];		
	
	}
	
	//[super touchesMoved:touches withEvent:event];
	
	
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	//NSLog(@"touches ended event");	
	
	static NSTimeInterval timeEnded = 0;
	if(timeEnded ==  [event timestamp])
		return;
	else
		timeEnded = [event timestamp];	
	

    if(multiTouchFinger1 && multiTouchFinger2){
		
		float finger1XDist = fabsf(multiTouchStartPoint1.x - multiTouchEndPoint1.x);
		float finger1YDist = fabsf(multiTouchStartPoint1.y - multiTouchEndPoint1.y);
		
		float finger2XDist = fabsf(multiTouchStartPoint2.x - multiTouchEndPoint2.x);
		float finger2YDist = fabsf(multiTouchStartPoint2.y - multiTouchEndPoint2.y);
		
		//NSLog(@"finger1 distance(%.0f,%.0f)",finger1XDist,finger1YDist);
		//NSLog(@"finger2 distance(%.0f,%.0f)",finger2XDist,finger2YDist);		
		
		
		//處理 multi-touch 左右scroll
		if((finger1XDist >=X_MOVE_MIN_DIST) && (finger2XDist >=X_MOVE_MIN_DIST) && (finger1YDist <=Y_MOVE_MAX_DIST && finger2YDist <=Y_MOVE_MAX_DIST ))
		{
			[targetView touchesEnded:touches withEvent:event];
			[targetView touchesCancelled:touches withEvent:event];
			//NSLog(@"target cancel");
			
			//向右
			if((multiTouchStartPoint1.x < multiTouchEndPoint1.x) && fingersScrollSameXDirection) 
				[self multiTouchLeftToRight];
			
			//向左
			else if ((multiTouchStartPoint1.x > multiTouchEndPoint1.x) && fingersScrollSameXDirection) 
				[self multiTouchRightToLeft]; 
			
		}

		//處理 multi-touch 上下scroll		
		else if((finger1YDist >=Y_MOVE_MIN_DIST) && (finger2YDist >=Y_MOVE_MIN_DIST) && (finger1XDist <=X_MOVE_MAX_DIST && finger2XDist <=X_MOVE_MAX_DIST ))
		{
			
			[targetView touchesEnded:touches withEvent:event];			
			[targetView touchesCancelled:touches withEvent:event];
			//NSLog(@"target cancel");
			
			//向下
			if((multiTouchStartPoint1.y < multiTouchEndPoint1.y) && fingersScrollSameYDirection) 
				[self multiTouchBottonToDown]; 
				
			
			//向上
			else if ((multiTouchStartPoint1.y > multiTouchEndPoint1.y) && fingersScrollSameYDirection) 
				[self multiTouchDownToBotton];
		
		}
		else{ // 傳multi-touch事件
			
			[targetView touchesEnded:touches withEvent:event];
			//NSLog(@"傳 multi-touch touchesEnded to targetView");
		
		}
		
    }
	
    else{
		
		[targetView touchesEnded:touches withEvent:event];
		//NSLog(@"target ended");
		
	}

	
	
	//[targetView touchesEnded:touches withEvent:event];
	//[super touchesEnded:touches withEvent:event];
	
	
	//clean status:
	[self cleanTouchesStatus:touches];
	
	
	
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//if(!multiTouchFinger2)
		//[targetView touchesCancelled:touches withEvent:event];
}


-(BOOL)isFingersScrollSameXDirectionOnPreviousPoint1:(CGPoint)previousPoint1 currentPoint1:(CGPoint)currentPoint1 
									  previousPoint2:(CGPoint)previousPoint2 currentPoint2:(CGPoint)currentPoint2{
	
	int finger1XDirection = -1; // 0:向左 1:向右
	int finger2XDirection = -1; // 0:向左 1:向右	
	
	//依正負值判斷方向		
	float finger1XDist = previousPoint1.x - currentPoint1.x;
	float finger2XDist = previousPoint2.x - currentPoint2.x;	
	
	// case 向左
	if(finger1XDist>=0) // touchMoved x值愈來愈小, maybe向左scroll
	{
		finger1XDirection = 0;
	}
	
	// case 向右
	else if(finger1XDist<0)  // touchMoved x值愈來愈大, maybe向右scroll
	{				
		finger1XDirection = 1;			
	}

	
	
	// case 向左
	if(finger2XDist>=0) // touchMoved x值愈來愈小, maybe向左scroll
	{
		finger2XDirection = 0;
	}
	
	// case 向右
	else if(finger2XDist<0)  // touchMoved x值愈來愈大, maybe向右scroll
	{				
		finger2XDirection = 1;			
	}

	
	if(finger1XDirection==finger2XDirection)
		return YES;
	else
		return NO;
	
}



-(BOOL)isFingersScrollSameYDirectionOnPreviousPoint1:(CGPoint)previousPoint1 currentPoint1:(CGPoint)currentPoint1 
									  previousPoint2:(CGPoint)previousPoint2 currentPoint2:(CGPoint)currentPoint2{
	
	int finger1YDirection = -1; // 0:向左 1:向右
	int finger2YDirection = -1; // 0:向左 1:向右	
	
	//依正負值判斷方向		
	float finger1YDist = previousPoint1.y - currentPoint1.y;
	float finger2YDist = previousPoint2.y - currentPoint2.y;	
	
	// case 向上
	if(finger1YDist>=0) // touchMoved y值愈來愈小, x值在界限範圍內 => maybe向上scroll
	{
		finger1YDirection = 0;
	}			
	// case 向下
	else if(finger1YDist<0)// touchMoved y值愈來愈大, maybe向下scroll
	{			
		finger1YDirection = 1;			
	}

	
	
	// case 向上
	if(finger2YDist>=0) // touchMoved y值愈來愈小, x值在界限範圍內 => maybe向上scroll
	{
		finger2YDirection = 0;
	}			
	// case 向下
	else if(finger2YDist<0)// touchMoved y值愈來愈大, maybe向下scroll
	{			
		finger2YDirection = 1;			
	}
	
	if(finger1YDirection==finger2YDirection)
		return YES;
	else
		return NO;	
}


-(void)cleanTouchesStatus:(NSSet *)touches{
	
	/*
    for(UITouch *touch in touches)
    {
        if(touch == multiTouchFinger1)
            multiTouchFinger1 = nil;
        else if(touch == multiTouchFinger2)
            multiTouchFinger2 = nil;
    }
	 */
	multiTouchFinger1 = nil;
	multiTouchFinger2 = nil;
	
	
	multiTouchStartPoint1 = CGPointMake(0,0);
	multiTouchStartPoint2 = CGPointMake(0,0);		
	multiTouchEndPoint1 = CGPointMake(0,0);
	multiTouchEndPoint2 = CGPointMake(0,0);		
	
	fingersScrollSameXDirection = YES;
	fingersScrollSameYDirection = YES;
	
	//drawAndScrollController.multiTouchMode = NO;
		
}



#pragma mark Handle Multi-Touch Event

-(void)multiTouchBottonToDown{
	
	//NSLog(@"                  : 手指頭們向下");	
 
	 [drawAndScrollController performSelectorOnMainThread:@selector(nextEquityName) withObject:nil waitUntilDone:NO];		
 	
}


-(void)multiTouchDownToBotton{
	
	//NSLog(@"                  : 手指頭們向上");
	
	 [drawAndScrollController performSelectorOnMainThread:@selector(previousEquityName) withObject:nil waitUntilDone:NO];			

	
}

-(void)multiTouchRightToLeft{
	
	//NSLog(@"                  : 執行！手指頭們向左");
	
//    [drawAndScrollController performSelectorOnMainThread:@selector(previousViewContent) withObject:nil waitUntilDone:NO];	
	
}


-(void)multiTouchLeftToRight{
	
	//NSLog(@"                  : 執行！手指頭們向右");	
	
//    [drawAndScrollController performSelectorOnMainThread:@selector(nextViewContent) withObject:nil waitUntilDone:NO];			
	
}



@end
