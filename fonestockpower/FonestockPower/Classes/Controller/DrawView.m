//
//  DrawView.m
//  B
//
//  Created by Connor on 13/12/25.
//  Copyright (c) 2013年 Fonestock. All rights reserved.
//

#import "DrawView.h"

@interface DrawView()
@property (nonatomic, strong) NSMutableArray *drawLinePoints;
@end
@implementation Line
@end

@implementation DrawView

- (id)init {
    if (self = [super init]) {
        self.drawLinePoints = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)resetView {
    ac = KprepareAction;
    [self.drawLinePoints removeAllObjects];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {

    if (ac == KprepareAction) {
        return;
    }

    context = UIGraphicsGetCurrentContext();

    [[UIColor blackColor] setStroke];
    
    if (ac == KMoveAction) {
        UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
        if (self.eraseMode) {
            [[UIColor clearColor] setStroke];
        }
        [additionPolygon moveToPoint:firstTouch];
        [additionPolygon addLineToPoint:lastTouch];
        [additionPolygon setLineWidth:1.0f];
        [additionPolygon stroke];
    }
    
    [[UIColor blackColor] setStroke];
    for (Line *line in self.drawLinePoints) {
        UIBezierPath *additionPolygon = [UIBezierPath bezierPath];
        [additionPolygon moveToPoint:line.pointA];
        [additionPolygon addLineToPoint:line.pointB];
        [additionPolygon setLineWidth:1.0f];
        [additionPolygon stroke];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] lastObject];
    ac = KPainAction;
    
    firstTouch = [touch locationInView:self];
//    lastTouch = [touch locationInView:self];
    
   
    
    NSMutableArray *discardedItems = [NSMutableArray array];
    if (self.eraseMode) {
        for (Line *line in self.drawLinePoints) {
            if (lastTouch.x >= MIN(line.pointA.x, line.pointB.x) &&
                lastTouch.x <= MAX(line.pointA.x, line.pointB.x) &&
                lastTouch.y >= MIN(line.pointA.y, line.pointB.y) &&
                lastTouch.y <= MAX(line.pointA.y, line.pointB.y)) {
                
                double m2 = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                double b = line.pointB.y - m2 * line.pointB.x;
                
                // 斜率大於85 magic number
                if (abs(m2) > 85) {
                    [discardedItems addObject:line];
                    break;
                }
                
                if (abs(m2 * lastTouch.x + b - lastTouch.y) < 22) {
                    [discardedItems addObject:line];
                    break;
                }
            }
        }
        
        [self.drawLinePoints removeObjectsInArray:discardedItems];
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] lastObject];
    lastTouch = [touch locationInView:self];

    ac = KMoveAction;
    
    NSMutableArray *discardedItems = [NSMutableArray array];
    if (self.eraseMode) {
        for (Line *line in self.drawLinePoints) {
            if (lastTouch.x >= MIN(line.pointA.x, line.pointB.x) &&
                lastTouch.x <= MAX(line.pointA.x, line.pointB.x) &&
                lastTouch.y >= MIN(line.pointA.y, line.pointB.y) &&
                lastTouch.y <= MAX(line.pointA.y, line.pointB.y)) {
                
                float m2 = (line.pointB.y - line.pointA.y) / (line.pointB.x - line.pointA.x);
                float b = line.pointB.y - m2 * line.pointB.x;
                
                NSLog(@"%f", m2);
                
                // 斜率大於85 magic number
                if (abs(m2) > 85) {
                    [discardedItems addObject:line];
                    break;
                }
                
                if (abs(m2 * lastTouch.x + b - lastTouch.y) < 22) {
//                    [discardedItems addObject:line];
                    break;
                }
                
            }
        }

        [self.drawLinePoints removeObjectsInArray:discardedItems];
    }

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.eraseMode) {
        return;
    }
     double m2 = (lastTouch.y - firstTouch.y) / (lastTouch.x - firstTouch.x);
    double c = lastTouch.y - m2*lastTouch.x;
    NSLog(@"//// %f ////  c:%f///",m2,c);
    
    
    if(lastTouch.x == firstTouch.x){
        firstTouch = CGPointMake(firstTouch.x, 0);
        lastTouch = CGPointMake(lastTouch.x, 300);

    }else{
        double newY1 = m2*0 +c;
        double newY2 = m2*300 +c;
        firstTouch = CGPointMake(0, newY1);
        lastTouch = CGPointMake(300, newY2);

    }
    
        Line *line = [[Line alloc] init];
    line.pointA = firstTouch;
    line.pointB = lastTouch;
    [self.drawLinePoints addObject:line];
    [self setNeedsDisplay];
}
@end
