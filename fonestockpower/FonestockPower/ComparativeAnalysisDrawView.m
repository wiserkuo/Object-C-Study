//
//  ComparativeAnalysisDrawView.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ComparativeAnalysisDrawView.h"

@implementation ComparativeAnalysisDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
        _view.hidden = YES;
        [self addSubview:_view];
        saveArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    //外框
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, 40, 20);
    CGContextAddLineToPoint(context, self.frame.size.width - 10, 20);
    CGContextAddLineToPoint(context, self.frame.size.width - 10, self.frame.size.height - 20);
    CGContextAddLineToPoint(context, 40, self.frame.size.height - 20);
    CGContextAddLineToPoint(context, 40, 20);
    CGContextStrokePath(context);
    
    double drawViewHeight = self.frame.size.height - 40;
    double drawViewWidth = self.frame.size.width - 50;
    
    //虛線
    CGContextSetLineWidth(context, 0.5);
    CGFloat lengths[] = {1,1};
    CGContextSetLineDash(context, 0, lengths, 2);

    for(int i = 1; i < 5; i++){
        CGContextMoveToPoint(context, 40, 20+drawViewHeight/5*i);
        CGContextAddLineToPoint(context, self.frame.size.width-10, 20+drawViewHeight/5*i);
        
        CGContextMoveToPoint(context, 40+drawViewWidth/5*i, 20);
        CGContextAddLineToPoint(context, 40+drawViewWidth/5*i, self.frame.size.height - 20);
        
    }
    CGContextStrokePath(context);
    
    

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:10.0f],
                                  NSParagraphStyleAttributeName: paragraphStyle,
                                  NSForegroundColorAttributeName: [UIColor redColor]};
    NSDictionary *attributes2 = @{ NSFontAttributeName: [UIFont systemFontOfSize:10.0f],
                                  NSParagraphStyleAttributeName: paragraphStyle,
                                  NSForegroundColorAttributeName: [UIColor greenColor]};
    
    NSDictionary *attributesText = @{ NSFontAttributeName: [UIFont systemFontOfSize:10.0f],
                                   NSParagraphStyleAttributeName: paragraphStyle,
                                   NSForegroundColorAttributeName: [UIColor blackColor]};
    
    double maxY = -MAXFLOAT;
    double minY = MAXFLOAT;
    double maxX = -MAXFLOAT;
    double minX = MAXFLOAT;
    
    for(int i = 0; i<[_dataArray count] ; i++){
        ComparativeObject *obj = [_dataArray objectAtIndex:i];
        maxY = MAX(obj->yValue, maxY);
        minY = MIN(obj->yValue, minY);
        maxX = MAX(obj->xValue, maxX);
        minX = MIN(obj->xValue, minX);
    }
    
    if(_dataArray){
        for(int i = 0; i < 6; i++){
            NSString * yLabel = [NSString stringWithFormat:@"%.2f", minY + ((maxY - minY)/5) * i];
            [yLabel drawInRect:CGRectMake(2, (self.frame.size.height-20) - (drawViewHeight/5) * i - 10 , 35, 10) withAttributes:attributesText];
            
            NSString * xLabel = [NSString stringWithFormat:@"%.2f", minX + ((maxX - minX)/5) * i];
            [xLabel drawInRect:CGRectMake((drawViewWidth/5) * i + 10, self.frame.size.height-15 , 35, 10) withAttributes:attributesText];
        }
    }
    
    
    
    
    double heightRate = (self.frame.size.height - 40) / (maxY - minY);
    double widthRate = (self.frame.size.width - 50) / (maxX - minX) ;
    
    for(int i = 0; i<[_dataArray count]; i++){
        ComparativeObject *obj = [_dataArray objectAtIndex:i];
        if([obj->type isEqualToString:@"認購"]){
            NSString *cgText = @"○";
            obj->cg = CGPointMake((obj->xValue - minX) * widthRate + 35, (self.frame.size.height - 20 ) - (obj->yValue - minY) * heightRate -6);
            [cgText drawInRect:CGRectMake((obj->xValue - minX) * widthRate + 35, (self.frame.size.height - 20 ) - (obj->yValue - minY) * heightRate -6, 10, 12) withAttributes:attributes];
        }else{
            NSString *cgText = @"△";
            obj->cg = CGPointMake((obj->xValue - minX) * widthRate + 35, (self.frame.size.height - 20 ) - (obj->yValue - minY) * heightRate -6);
            [cgText drawInRect:CGRectMake((obj->xValue - minX) * widthRate + 35, (self.frame.size.height - 20 ) - (obj->yValue - minY) * heightRate -6, 10, 12) withAttributes:attributes2];
        }
        [_dataArray setObject:obj atIndexedSubscript:i];
    }
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL findFlag = NO;
    [saveArray removeAllObjects];
    for(int i= 0; i<[_dataArray count]; i++){
        ComparativeObject *obj = [_dataArray objectAtIndex:i];
        if(touchPoint.x < obj->cg.x+16 && touchPoint.x > obj->cg.x-3 && touchPoint.y-4 < obj->cg.y+14 && touchPoint.y > obj->cg.y){
            [_view setFrame:CGRectMake(touchPoint.x-6, touchPoint.y-7, 10, 10)];
            [saveArray addObject:obj];
            _view.hidden = NO;
            findFlag = YES;
        }else{
            if(!findFlag){
                _view.hidden = YES;
            }
        }
    }
    
    [self.controller reload:saveArray touchPoint:touchPoint.x];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    BOOL findFlag = NO;
    [saveArray removeAllObjects];
    for(int i= 0; i<[_dataArray count]; i++){
        ComparativeObject *obj = [_dataArray objectAtIndex:i];
        if(touchPoint.x < obj->cg.x+16 && touchPoint.x > obj->cg.x-3 && touchPoint.y-4 < obj->cg.y+14 && touchPoint.y > obj->cg.y){
            [_view setFrame:CGRectMake(touchPoint.x-6, touchPoint.y-7, 10, 10)];
            [saveArray addObject:obj];
            _view.hidden = NO;
            findFlag = YES;
        }else{
            if(!findFlag){
                _view.hidden = YES;
            }
        }
    }
    
    [self.controller reload:saveArray touchPoint:touchPoint.x];
}

-(void)setTarget:(ComparativeAnalysisViewController *)obj
{
    self.controller = obj;
}
@end
