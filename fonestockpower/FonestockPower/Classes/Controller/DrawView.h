//
//  DrawView.h
//  B
//
//  Created by Connor on 13/12/25.
//  Copyright (c) 2013年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef enum {
//	KprepareAction,
//	KPainAction,
//    KMoveAction
//}Action;

@interface DrawView : UIView {
    Action ac;
    CGContextRef context;
    
    CGPoint firstTouch;
    CGPoint lastTouch;
}

- (void)resetView;

@property (nonatomic, unsafe_unretained) BOOL eraseMode;

@end

//@interface Line : NSObject
//@property (nonatomic, unsafe_unretained) CGPoint pointA;
//@property (nonatomic, unsafe_unretained) CGPoint pointB;
//@end
