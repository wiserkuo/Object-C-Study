//
//  SGInfoAlert.m
//
//  Created by Azure_Sagi on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGInfoAlert.h"

@implementation SGInfoAlert


// 画出圆角矩形背景
static void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float ovalWidth,float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) { 
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context); 
    CGContextTranslateCTM (context, CGRectGetMinX(rect), 
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight); 
    fw = CGRectGetWidth (rect) / ovalWidth; 
    fh = CGRectGetHeight (rect) / ovalHeight; 
    CGContextMoveToPoint(context, fw, fh/2); 
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1); 
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); 
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); 
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); 
    CGContextClosePath(context); 
    CGContextRestoreGState(context); 
}

- (id)initWithFrame:(CGRect)frame bgColor:(CGColorRef)color info:(NSString*)info{
    CGRect viewR = CGRectMake(0, 0, frame.size.width*1.2, frame.size.height*1.2);
    self = [super initWithFrame:viewR];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgcolor_ = color;
        info_ = [[NSString alloc] initWithString:info];
        fontSize_ = frame.size;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 背景0.8透明度
    CGContextSetAlpha(context, .8);
    addRoundedRectToPath(context, rect, 4.0f, 4.0f);
    //CGContextSetFillColorWithColor(context, bgcolor_); //bug#10713 crash issue
    CGContextFillPath(context);
    
    // 文字1.0透明度
    CGContextSetAlpha(context, 1.0);
//    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor] CGColor]);
//    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    float x = (rect.size.width - fontSize_.width) / 2.0;
    float y = (rect.size.height - fontSize_.height) / 2.0;
    CGRect r = CGRectMake(x, y, fontSize_.width, fontSize_.height);
    UIFont * font = [UIFont systemFontOfSize:kSGInfoAlert_fontSize];
    NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor whiteColor]};
//    [info_ drawInRect:r withFont:[UIFont systemFontOfSize:kSGInfoAlert_fontSize] lineBreakMode:UILineBreakModeTailTruncation];
    [info_ drawWithRect:r options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
}

// 从上层视图移除并释放
- (void)remove{
    [self removeFromSuperview];
}

// 渐变消失
- (void)fadeAway{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    self.alpha = .0;
    [UIView commitAnimations];
    [self performSelector:@selector(remove) withObject:nil afterDelay:1.0f];
}

+ (void)showInfo:(NSString *)info 
         bgColor:(CGColorRef)color
          inView:(UIView *)view {
    UIFont * font = [UIFont systemFontOfSize:kSGInfoAlert_fontSize];
    NSDictionary *attributes = @{ NSFontAttributeName: font};
    CGSize size =[info boundingRectWithSize:kMax_ConstrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    // [info sizeWithFont:[UIFont systemFontOfSize:kSGInfoAlert_fontSize]constrainedToSize:kMax_ConstrainedSize];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    SGInfoAlert *alert = [[SGInfoAlert alloc] initWithFrame:frame bgColor:color info:info];
    alert.center = CGPointMake(view.center.x, view.frame.size.height - 100);
    alert.alpha = 0;
    [view addSubview:alert];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    alert.alpha = 1.5;
    [UIView commitAnimations];
    [alert performSelector:@selector(fadeAway) withObject:nil afterDelay:1.0];
}

+ (void)showInfo_EOD:(NSString *)info
         bgColor:(CGColorRef)color
          inView:(UIView *)view {
//    UIFont * font = [UIFont systemFontOfSize:kSGInfoAlert_fontSize];
//    NSDictionary *attributes = @{ NSFontAttributeName: font};
    CGRect frame;
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        frame = CGRectMake(0, 0, 250, 40);
    }else{
        frame = CGRectMake(0, 0, 250, 25);
    }
    SGInfoAlert *alert = [[SGInfoAlert alloc] initWithFrame:frame bgColor:color info:info];
    
    alert.center = CGPointMake(view.center.x, view.frame.size.height - 50);
    alert.alpha = 0;
    [view addSubview:alert];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    alert.alpha = 1.5;
    [UIView commitAnimations];
    [alert performSelector:@selector(fadeAway) withObject:nil afterDelay:3.0];
}


@end
