//
//  TechDrawTopView.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TechDrawTopView.h"
#import "TechIn.h"
#import "Tech.h"
//平均移動線天數 如果這裡修改Controller也要改
#define mNum1 5
#define mNum2 10
#define mNum3 20

#define topAndBottomHeight 7.5
//圓的直徑
#define radius 6
@implementation TechDrawTopView

- (void)drawRect:(CGRect)rect {
    FSDataModelProc *model = [FSDataModelProc sharedInstance];
    
    //設定漲跌顏色，美股與其他股市顏色相反。
    UIColor *upColor;
    UIColor *downColor;
    
    if([[[FSFonestock sharedInstance].appId substringToIndex:2] isEqualToString:@"us"]){
        upColor = [UIColor colorWithRed:82.0/255.0 green:186.0/255.0 blue:0 alpha:1];
        downColor = [UIColor redColor];
    }else{
        downColor = [UIColor colorWithRed:82.0/255.0 green:186.0/255.0 blue:0 alpha:1];
        upColor = [UIColor redColor];
    }
    
    if([_dataArray count]==0){
        return;
    }
    CGMutablePathRef pathHLine = CGPathCreateMutable();
    
    //建立畫布
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //設定畫筆顏色
    [[UIColor grayColor]set];
    //設定畫筆寬度
    CGContextSetLineWidth(context, 0.5);
    
    //length設定虛線如何交替繪制
    //length{1,1}表示繪制1，跳過1   示意圖:. . . . . . . . . . .
    //length{10,5}表示繪制10，跳過5  示意圖:..........     ..........     ..........
    //length{5,10,5}表示繪制5，跳過10，繪制5，跳過5，再繪制10   示意圖:.....          .....     ..........
    CGFloat length[] = {1,1};
    //設定畫虛線
    CGContextSetLineDash(context, 0, length, 1);
    
    //算出虛線的間距
    double dashHeight = (self.frame.size.height) / 6;
    
    //畫水平虛線
    for(int i = 0; i <=5; i++){
        CGContextMoveToPoint(context, 2, topAndBottomHeight * 2 + i * dashHeight);
        CGContextAddLineToPoint(context, self.frame.size.width, topAndBottomHeight * 2 + i * dashHeight);
    }
    CGContextStrokePath(context);
    
    //算出畫面中的區間，第一筆資料與最後一筆資料的資料筆數，此用意為不用重畫全部資料，只要重畫畫面中的資料即可。
    _startCount = _xPoint / _widthRange - 1 ;
    int endCount = _viewWidth / _widthRange + _startCount + 2;
    if(_startCount < 0){
        _startCount = 0;
    }
    if(endCount >= [_dataArray count]){
        endCount = (int)[_dataArray count];
    }

    NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
    [formatterMonth setDateFormat:@"MM"];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    
    highPrice = -MAXFLOAT;
    lowPrice = MAXFLOAT;
    
    //遇到當月的第一天，即把月份印上，並畫出垂直虛線
    for(int i = _startCount; i<endCount; i++){
        TechObject *obj = [_dataArray objectAtIndex:i];

        //算出畫面中資料的最大值與最小值
        double m1Value = [(NSNumber *)[model.tech.m1Array objectAtIndex:i]doubleValue];
        double m2Value = [(NSNumber *)[model.tech.m2Array objectAtIndex:i]doubleValue];
        double m3Value = [(NSNumber *)[model.tech.m3Array objectAtIndex:i]doubleValue];
        
        if(isnan(m1Value) || isnan(m2Value) || isnan(m3Value)){
            highPrice = MAX(highPrice, obj.high);
            lowPrice = MIN(lowPrice, obj.low);
        }else{
            highPrice = MAX(highPrice, obj.high);
            highPrice = MAX(highPrice, m1Value);
            highPrice = MAX(highPrice, m2Value);
            highPrice = MAX(highPrice, m3Value);
            lowPrice = MIN(lowPrice, obj.low);
            lowPrice = MIN(lowPrice, m1Value);
            lowPrice = MIN(lowPrice, m2Value);
            lowPrice = MIN(lowPrice, m3Value);
        }
    }
    //算出資料畫圖高度的比例
    heightRate = (self.frame.size.height - topAndBottomHeight * 2) / (highPrice - lowPrice);
    CGContextSetLineDash(context, 0, length, 0);
    
    
    //M線
    CGMutablePathRef pathM1 = CGPathCreateMutable();
    CGMutablePathRef pathM2 = CGPathCreateMutable();
    CGMutablePathRef pathM3 = CGPathCreateMutable();
    
    //K棒線
    CGMutablePathRef pathKLine = CGPathCreateMutable();


    //移動平均線
    //設定三個firstFlag表示若開始畫第一筆資料時，使用MoveToPoint，接著後續都使用AddLineToPoint。
    BOOL first1Flag = NO;
    BOOL first2Flag = NO;
    BOOL first3Flag = NO;
    //trendFlag如果等於YES表示資料區間內有趨勢線的起始點
    BOOL trendFlag = NO;
    //trendFlag2如果等於YES表示資料區間內有趨勢線的終點
    BOOL trendFlag2 = NO;
    //x1與x2代表趨勢線的起始點與終點為資料的第幾筆
    double x1;
    double x2;
    //y1_h與y2_h存取趨勢線的起始點與終點的值，看趨勢線是畫在哪個值上就記住哪個值，在這邊如果是牛證為最低價，熊證為最高價。
    double y1_h;
    double y2_h;
    
    
    int circleInViewCount = 0;
    
    for (int i = 0; i < endCount; i++) {
        TechObject *obj = [_dataArray objectAtIndex:i];
        
        //趨勢線
        //一開始的_m與_b初始值為0，如果斜率已求出來了，就不必再算了。
        if(_m==0 && _b==0){
            if(obj.date == _startDate){
                x1 = i;
                if(_symbolType){
                    y1_h = obj.low;
                }else{
                    y1_h = obj.high;
                }
                trendFlag = YES;
            }
            if(obj.date == _endDate){
                x2 = i;
                if(_symbolType){
                    y2_h = obj.low;
                }else{
                    y2_h = obj.high;
                }
                trendFlag2 = YES;
            }
        }
        
    }
    
    for(int i = _startCount; i<endCount; i ++){
        /*//bug#10085 wiser start
        if (i == endCount - 4 || i == endCount - 9 || i == endCount - 19) {
            printf("widthRange = %f\n",_widthRange);
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, i * _widthRange, self.frame.size.height-10);
            CGContextAddLineToPoint(context, i * _widthRange - 5, self.frame.size.height);
            CGContextAddLineToPoint(context, i * _widthRange + 5, self.frame.size.height);
            CGContextClosePath(context);
            
            if (i == endCount - 4) {
                CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
            }
            else
                if (i == endCount - 9) {
                    CGContextSetFillColorWithColor(context, [UIColor brownColor].CGColor);
                }
                else
                    if (i == endCount - 19) {
                        CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
                    }
        }
        CGContextFillPath(context);
        //bug#10085 wiser end*/
        TechObject *obj = [_dataArray objectAtIndex:i];
        double m1Value = [(NSNumber *)[model.tech.m1Array objectAtIndex:i]doubleValue];
        double m2Value = [(NSNumber *)[model.tech.m2Array objectAtIndex:i]doubleValue];
        double m3Value = [(NSNumber *)[model.tech.m3Array objectAtIndex:i]doubleValue];
        if(!isnan(m1Value)){
            if(!first1Flag){
                CGPathMoveToPoint(pathM1, NULL, i * _widthRange + _widthRange, (self.frame.size.height-topAndBottomHeight) - (m1Value - lowPrice) * heightRate);
            }else if(i > _startCount){
                CGPathAddLineToPoint(pathM1, NULL, i * _widthRange + _widthRange , (self.frame.size.height-topAndBottomHeight) - (m1Value - lowPrice) * heightRate);
            }
            first1Flag = YES;
        }
        if(!isnan(m2Value)){
            if(!first2Flag){
                CGPathMoveToPoint(pathM2, NULL, i * _widthRange + _widthRange, (self.frame.size.height-topAndBottomHeight) - (m2Value - lowPrice) * heightRate);
            }else if(i > _startCount){
                CGPathAddLineToPoint(pathM2, NULL, i * _widthRange + _widthRange , (self.frame.size.height-topAndBottomHeight) - (m2Value - lowPrice) * heightRate);
            }
            first2Flag = YES;
        }
        if(!isnan(m3Value)){
            if(!first3Flag){
                CGPathMoveToPoint(pathM3, NULL, i * _widthRange + _widthRange, (self.frame.size.height-topAndBottomHeight) - (m3Value - lowPrice) * heightRate);
            }else if(i > _startCount){
                CGPathAddLineToPoint(pathM3, NULL, i * _widthRange + _widthRange , (self.frame.size.height-topAndBottomHeight) - (m3Value - lowPrice) * heightRate);
            }
            first3Flag = YES;
        }
        //K棒線
        CGPathMoveToPoint(pathKLine, NULL, i * _widthRange +_widthRange , (self.frame.size.height) - (obj.low - lowPrice) * heightRate);
        CGPathAddLineToPoint(pathKLine, NULL, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.high - lowPrice) * heightRate);
        
//        //趨勢線
//        //一開始的_m與_b初始值為0，如果斜率已求出來了，就不必再算了。
//        if(_m==0 && _b==0){
//            if(obj.date == _startDate){
//                x1 = i;
//                if(_symbolType){
//                    y1_h = obj.low;
//                }else{
//                    y1_h = obj.high;
//                }
//                trendFlag = YES;
//            }
//            if(obj.date == _endDate){
//                x2 = i;
//                if(_symbolType){
//                    y2_h = obj.low;
//                }else{
//                    y2_h = obj.high;
//                }
//                trendFlag2 = YES;
//            }
//        }
        //圓點
        //因趨勢線的起始點及終點不會變動，所以只要算出起始點或終點為第幾筆資料筆數，使用者滑動如果落在區間內，才會進去畫出圓點。
        if((_startCount <= _circleStart && endCount >= _circleStart) || (_startCount <= _circleEnd && endCount >= _circleEnd) || _circleStart == 0 || _circleEnd == 0){
            if(obj.date == _startDate){
                
                circleInViewCount++;
                
                _circleStart = i;
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                CGContextSetLineWidth(context, 1.0);
                
                if(_symbolType){
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (obj.low - lowPrice) * heightRate, radius + _obj.pinchValue, 0, 2*M_PI, 0);
                    _circleTouchX_Start = i * _widthRange + _widthRange;
                    _circleTouchY_Start = (self.frame.size.height) - (obj.low - lowPrice) * heightRate;
                }else{
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (obj.high - lowPrice) * heightRate, radius + _obj.pinchValue, 0, 2*M_PI, 0);
                    _circleTouchX_Start = i * _widthRange + _widthRange;
                    _circleTouchY_Start = (self.frame.size.height) - (obj.high - lowPrice) * heightRate;
                }
                CGContextSetLineDash(context, 0, length, 0);
                
                CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
                CGContextDrawPath(context,kCGPathFillStroke);
            }
            if(obj.date == _endDate){
                
                circleInViewCount++;
                
                _circleEnd = i;
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0 alpha:1].CGColor);
                CGContextSetLineWidth(context, 1.0);
                
                if(_symbolType){
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (obj.low - lowPrice) * heightRate, radius + _obj.pinchValue, 0, 2*M_PI, 0);
                    _circleTouchX_End = i * _widthRange + _widthRange;
                    _circleTouchY_End = (self.frame.size.height) - (obj.low - lowPrice) * heightRate;
                }else{
                    CGContextAddArc(context, i * _widthRange + _widthRange, (self.frame.size.height) - (obj.high - lowPrice) * heightRate, radius + _obj.pinchValue, 0, 2*M_PI, 0);
                    _circleTouchX_End = i * _widthRange + _widthRange;
                    _circleTouchY_End = (self.frame.size.height) - (obj.high - lowPrice) * heightRate;
                }
                
                CGContextSetLineDash(context, 0, length, 0);
                CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
                CGContextDrawPath(context,kCGPathFillStroke);
            }
        }
        
    }
    
    CGContextSetLineDash(context, 0, length, 0);
    CGContextSetLineWidth(context, 1);
    CGContextAddPath(context,pathM1);
    [[UIColor purpleColor] set];
    CGPathRelease(pathM1);
    CGContextStrokePath(context);
    
    CGContextAddPath(context,pathM2);
    [[UIColor brownColor] set];
    CGPathRelease(pathM2);
    CGContextStrokePath(context);
    
    CGContextAddPath(context,pathM3);
    [[UIColor blueColor] set];
    CGPathRelease(pathM3);
    CGContextStrokePath(context);
    
    CGContextAddPath(context,pathKLine);
    [[UIColor blueColor] set];
    CGPathRelease(pathKLine);
    CGContextStrokePath(context);
    
    //K棒
    BOOL hLineFirstFlag = NO;
    CGContextSetLineWidth(context, 3 + _obj.pinchValue);
    for(int i = _startCount; i <endCount; i ++){
        TechObject *obj = [_dataArray objectAtIndex:i];
        if(obj.open > obj.last){
            [downColor set];
            CGContextMoveToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.open - lowPrice) * heightRate);
            CGContextAddLineToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.last - lowPrice) * heightRate);
        }else if(obj.open < obj.last){
            [upColor set];
            CGContextMoveToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.last - lowPrice) * heightRate);
            CGContextAddLineToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.open - lowPrice) * heightRate);
        }else{
            [[UIColor blueColor]set];
            CGContextMoveToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.last - lowPrice) * heightRate);
            
            if (obj.last == lowPrice) {
                CGContextAddLineToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.last - lowPrice + 0.05 + (obj.last - lowPrice) / 200) * heightRate);
            } else {
                CGContextAddLineToPoint(context, i * _widthRange+_widthRange, (self.frame.size.height) - (obj.last - lowPrice + (obj.last - lowPrice) / 200) * heightRate);
            }
            
        }
        CGContextStrokePath(context);
        
        
        if (circleInViewCount >= 1) {
            
            
            //算出趨勢線斜率
            if(trendFlag && trendFlag2){
                _m = (y2_h - y1_h)/(x2 - x1);
                _b = -(_m * x1 - y1_h);
            }
            //將資料區間的數值代入斜率，畫出無限延伸的趨勢線
            if(!(_m==0 && _b==0)){
                double y = _m * i + _b;
                if(!hLineFirstFlag){
                    if(!((self.frame.size.height) - (y - lowPrice) * heightRate > self.frame.size.height || (self.frame.size.height-0) - (y - lowPrice) * heightRate < 0)){
                        CGPathMoveToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowPrice) * heightRate);
                        hLineFirstFlag = YES;
                    }
                }else{
                    if(!((self.frame.size.height) - (y - lowPrice) * heightRate > self.frame.size.height || (self.frame.size.height-0) - (y - lowPrice) * heightRate < 0)){
                        CGPathAddLineToPoint(pathHLine, NULL, i * _widthRange + _widthRange, (self.frame.size.height) - (y - lowPrice) * heightRate);
                    }
                }
                
                if(endCount == [_dataArray count]){
                    int lastCount = endCount + 1;
                    double y = _m * lastCount + _b;
                    if(!hLineFirstFlag){
                        if(!((self.frame.size.height) - (y - lowPrice) * heightRate > self.frame.size.height || (self.frame.size.height-0) - (y - lowPrice) * heightRate < 0)){
                            CGPathMoveToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowPrice) * heightRate);
                            hLineFirstFlag = YES;
                        }
                    }else{
                        if(!((self.frame.size.height) - (y - lowPrice) * heightRate > self.frame.size.height || (self.frame.size.height) - (y - lowPrice) * heightRate < 0)){
                            CGPathAddLineToPoint(pathHLine, NULL, lastCount * _widthRange + _widthRange, (self.frame.size.height) - (y - lowPrice) * heightRate);
                        }
                    }
                }
                
            }
            
            
        }
        
        
    }
    
    CGContextSetLineWidth(context, 3);
    CGContextAddPath(context,pathHLine);
    [[UIColor blackColor] set];
    CGPathRelease(pathHLine);
    CGContextStrokePath(context);

    //圖畫完後，通知controller做設定Label的動作
    [_obj setPriceLabel];
    [_obj setMLabel:(_xPoint + _viewWidth - _widthRange) / _widthRange];
    
    [self.obj reDraw];
    
}

-(void)longPressHandler:(NSSet *)touches withEvent:(UIEvent *)event
{
    //長按秒數不明確
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    int selectNum = touchPoint.x / _widthRange;
    if(selectNum<[_dataArray count]){
        int lineNum = selectNum - _startCount - 1;
        TechObject *obj = [_dataArray objectAtIndex:selectNum];
        double yPoint;
        yPoint = (self.frame.size.height) - (obj.last - lowPrice) * heightRate;
        [_obj touchHandler:lineNum touch:touch yPoint:yPoint selectNum:selectNum];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _obj.touch = touches;
    _obj.event = event;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if(touchPoint.x >= _circleTouchX_Start-(radius + _obj.pinchValue) && touchPoint.x <= _circleTouchX_Start+(radius + _obj.pinchValue) && touchPoint.y <= _circleTouchY_Start + (radius+ + _obj.pinchValue) && touchPoint.y >= _circleTouchY_Start - (radius+ + _obj.pinchValue)){
        int lineNum = _circleStart - _startCount - 1;
        TechObject *obj = [_dataArray objectAtIndex:_circleStart];
        double yPoint;
        yPoint = (self.frame.size.height-topAndBottomHeight) - (obj.last - lowPrice) * heightRate;
        [_obj touchHandler:lineNum touch:touch yPoint:yPoint selectNum:_circleStart];
    }
    if(touchPoint.x >= _circleTouchX_End-(radius+ + _obj.pinchValue) && touchPoint.x <= _circleTouchX_End+(radius + _obj.pinchValue) && touchPoint.y <= _circleTouchY_End + (radius + _obj.pinchValue) && touchPoint.y >= _circleTouchY_End - (radius + _obj.pinchValue)){
        int lineNum = _circleEnd - _startCount - 1;
        TechObject *obj = [_dataArray objectAtIndex:_circleEnd];
        double yPoint;
        yPoint = (self.frame.size.height-topAndBottomHeight) - (obj.last - lowPrice) * heightRate;
        [_obj touchHandler:lineNum touch:touch yPoint:yPoint selectNum:_circleEnd];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self];
//    int selectNum = touchPoint.x / _widthRange;
//    if(selectNum<[_dataArray count]){
//        int lineNum = selectNum - _startCount;
//        TechObject *obj = [_dataArray objectAtIndex:selectNum];
//        double yPoint;
//        yPoint = (self.frame.size.height-topAndBottomHeight) - (obj.last - lowPrice) * heightRate;
//        [_obj touchHandler:lineNum touch:touch yPoint:yPoint selectNum:selectNum];
//    }
}

-(void)theTranportDestination:(BOOL)startOrEnd :(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    if(startOrEnd){
        int lineNum = _circleStart - _startCount - 1;
        TechObject *obj = [_dataArray objectAtIndex:_circleStart];
        double yPoint;
        yPoint = (self.frame.size.height-topAndBottomHeight) - (obj.last - lowPrice) * heightRate;
        [_obj touchHandler:lineNum touch:touch yPoint:yPoint selectNum:_circleStart];
    }else{
        int lineNum = _circleEnd - _startCount - 1;
        TechObject *obj = [_dataArray objectAtIndex:_circleEnd];
        double yPoint;
        yPoint = (self.frame.size.height-topAndBottomHeight) - (obj.last - lowPrice) * heightRate;
        [_obj touchHandler:lineNum touch:touch yPoint:yPoint selectNum:_circleEnd];
    }
}
@end


@implementation TechDrawDateView

- (void)drawRect:(CGRect)rect {
    _startCount = _xPoint / _widthRange - 1 ;
    int endCount = _viewWidth / _widthRange + _startCount + 2;
    if(_startCount < 0){
        _startCount = 0;
    }
    if(endCount >= [_dataArray count]){
        endCount = (int)[_dataArray count];
    }
    
    NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
    [formatterMonth setDateFormat:@"MM"];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    UIFont * font = [UIFont systemFontOfSize:13.0f];
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    TechObject *firstObject = [_dataArray firstObject];
    
    if (firstObject) {
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        /*
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 0, 10);
        CGContextAddLineToPoint(ctx, self.frame.size.width, 10);
        CGContextStrokePath(ctx);
        
        CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
        CGContextStrokePath(ctx);*/

        int detailMonth = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:firstObject.date]uint16ToDate]]intValue];
        BOOL monthFlag = NO;
        
        for (int i = 0; i < endCount; i++) {
            
            if (i == endCount - 4 || i == endCount - 9 || i == endCount - 19) {
                
                CGContextBeginPath(ctx);
                CGContextMoveToPoint(ctx, i * _widthRange, 0);
                CGContextAddLineToPoint(ctx, i * _widthRange - 5, 10);
                CGContextAddLineToPoint(ctx, i * _widthRange + 5, 10);
                CGContextClosePath(ctx);
                
                if (i == endCount - 4) {
                    CGContextSetFillColorWithColor(ctx, [UIColor purpleColor].CGColor);
                }
                else
                if (i == endCount - 9) {
                    CGContextSetFillColorWithColor(ctx, [UIColor brownColor].CGColor);
                }
                else
                if (i == endCount - 19) {
                    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
                }
                
                CGContextFillPath(ctx);
            }
            TechObject *obj = [_dataArray objectAtIndex:i];
            
            //日期;
            int month = [[formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:obj.date]uint16ToDate]]intValue];
            //因為有假日的關係，所以1號不一定是當月的第一天，所以此判斷方式是第一次進入到下個月份即為第一天
            if(month != detailMonth){
                if(!monthFlag){
                    NSString * timeLabel = [NSString stringWithFormat:@"%d", month];
                    //將label 畫上畫布所吃的資源比想像中還多，所以使用上須特別注意
                    [timeLabel drawInRect:CGRectMake(i * _widthRange, self.frame.size.height-topAndBottomHeight * 2, 20, topAndBottomHeight *2) withAttributes:attributes];
                    
                    detailMonth = month;
                }
            }
        }
    }
    
}

@end
