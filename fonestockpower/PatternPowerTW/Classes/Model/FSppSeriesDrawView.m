//
//  FSppSeriesDrawView.m
//  FonestockPower
//
//  Created by CooperLin on 2014/12/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSppSeriesDrawView.h"
#import "FSPowerSeriesObject.h"

@interface FSppSeriesDrawView(){
    double currentNum;
    double totalNum;
    
    double temper;
}
@end
@implementation FSppSeriesDrawView

-(instancetype)init
{
    self = [super init];
    if(self != nil){
        temper = 0.0;
        
        _theBuyData = 0.0;
        _theSellData = 0.0;
        _theForce = 0.0;
        _marketSentiment = 0.0;
        
        currentNum = 0;
        totalNum = 0.0;
        _totalOffsetForBuy = 0.0;
        _totalOffsetForSell = 0.0;
    }
    return self;
}

-(void)putTheLabelsOntoTheView:(double)centerPointX :(double)centerPointY offset:(double)moveTo howManyTimes:(int)times labelContext:(double)str :(NSDictionary *)attr
{
    for(int i = 1; i <= times; i++){
        NSString *buyStr1 = [NSString stringWithFormat:@"%.0f", str * i];
        [buyStr1 drawInRect:CGRectMake(centerPointX + moveTo * i, centerPointY, 20, 10) withAttributes:attr];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 
//    //一般畫法
//    double initPointX = self.frame.size.width / 2;
//    double initPointY = self.frame.size.height / 2;
//    double widthRate = self.frame.size.width / 2;
//    [[UIColor redColor] set];
//    CGContextSetLineWidth(context, self.frame.size.height);
//    CGContextMoveToPoint(context, initPointX + 0.5, initPointY);
//    CGContextAddLineToPoint(context, initPointX + 0.5 + self.concentrationBuy * widthRate, initPointY);
//    CGContextStrokePath(context);
     
     
     if(self.storeBuyArray != nil && self.totalOffsetForBuy != 0.0){

         double initPointX = self.frame.size.width / (_storeBuyArray.count + _storeSellArray.count) * _storeSellArray.count;
         double initPointY = self.frame.size.height / 2;
         double widthRate = self.frame.size.height / 2;
         
         //------將label 放上去的程式區塊------
         UIFont *font = [UIFont systemFontOfSize:8.0f];
         NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
         paragraphStyle.alignment = NSTextAlignmentCenter;
         NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName: paragraphStyle };
         
         NSString *initValue = @"0";
         [initValue drawInRect:CGRectMake(initPointX, initPointY, 10, 10) withAttributes:attributes];
         
         double maxCount = MAX(_storeSellArray.count, _storeBuyArray.count);
         double rangeCount = maxCount / 4;
         double strRange;
         if(_storeBuyArray.count >= _storeSellArray.count){
             strRange = (self.frame.size.width - initPointX) / 4;
         }else{
             strRange = initPointX / 4;
         }
         [self putTheLabelsOntoTheView:initPointX :initPointY offset:strRange howManyTimes:3 labelContext:rangeCount :attributes];
         [self putTheLabelsOntoTheView:initPointX :initPointY - 10 offset:(strRange * -1) howManyTimes:((int)(self.storeSellArray.count / strRange))>3?3:((int)(self.storeSellArray.count / strRange)) labelContext:rangeCount :attributes];
         
         //------

         CGContextSetLineWidth(context, 0.1);
         temper = _totalOffsetForBuy;
         totalNum = _storeBuyArray.count;
         currentNum = totalNum;
         CGContextBeginPath (context);
         CGContextMoveToPoint(context, initPointX, initPointY);
         CGContextAddLineToPoint(context, self.frame.size.width, initPointY);
         
         for(StoreBrokerBranch *sbb in _storeBuyArray){
            //畫曲線，然後再將其填滿（需要for loop前的前三行，還需close)
            CGContextAddLineToPoint(context, initPointX + (currentNum / totalNum * (self.frame.size.width - initPointX)), initPointY + (temper / _totalOffsetForBuy) * widthRate * -1);
             currentNum--;
             temper -= sbb.sellOffset.calcValue;
             
            //以畫垂直線的方式畫圖 - 會產生鋸齒（不需for 迴圈前的前三行）
//             CGContextMoveToPoint(context, initPointX + (currentNum / totalNum * initPointX), initPointY);
//             CGContextAddLineToPoint(context, initPointX + (currentNum / totalNum * initPointX), initPointY + (temper / _totalOffsetForBuy) * widthRate * -1);
//             currentNum--;
//             temper -= sbb.sellOffset.calcValue;
         }
         CGContextClosePath (context);
         [[UIColor colorWithRed:230.0/255.0 green:19.0/255.0 blue:23.0/255.0 alpha:1]setFill];
          CGContextDrawPath(context, kCGPathFillStroke);
         //紅色區域的code
         //---------------8<----------
         //綠色區域的code
         //CGContextStrokePath(context);
//         [[UIColor colorWithRed:95.0/255.0 green:212.0/255.0 blue:28.0/255.0 alpha:1] set];
         temper = 0.0;
         totalNum = _storeSellArray.count;
         currentNum = 1;
         CGContextBeginPath (context);
         CGContextMoveToPoint(context, 0, initPointY);
         CGContextAddLineToPoint(context, initPointX, initPointY);
         
         for(StoreBrokerBranch *sbb in _storeSellArray){
             CGContextAddLineToPoint(context, initPointX - (currentNum / totalNum * (initPointX)), initPointY + (temper / _totalOffsetForSell) * widthRate);
             currentNum++;
             temper += sbb.sellOffset.calcValue * -1;
             
//             CGContextMoveToPoint(context, initPointX - (currentNum / totalNum * initPointX), initPointY);
//             CGContextAddLineToPoint(context, initPointX - (currentNum / totalNum * initPointX), initPointY + (temper / _totalOffsetForSell) * widthRate);
//             currentNum++;
//             temper += sbb.sellOffset.calcValue * -1;
         }
         CGContextClosePath (context);
         [[UIColor colorWithRed:95.0/255.0 green:212.0/255.0 blue:28.0/255.0 alpha:1]setFill];
         CGContextDrawPath(context, kCGPathFillStroke);
         
         [[UIColor grayColor] set];
         CGContextSetLineWidth(context, 0.1);
         CGContextMoveToPoint(context, 0, initPointY);
         CGContextAddLineToPoint(context, self.frame.size.width, initPointY);
         CGContextStrokePath(context);
     }
     if(self.theSellData != 0.0 || self.theBuyData != 0.0){
         double initPointX = self.frame.size.width / 2;
         double initPointY = self.frame.size.height / 2;
         double widthRate = self.frame.size.width / 2;
         
         // 建立一個 RGB 的顏色空間
         CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
         // 建立漸層用的顏色，這邊只用兩個顏色，要更多顏色可以自行加入
         UIColor *beginColor = [UIColor colorWithRed:226.0/255.0 green:112.0/255.0 blue:0 alpha:1];
         UIColor *endColor = [UIColor colorWithRed:220.0/255.0 green:0 blue:0 alpha:1];
         // 將顏色加入陣列中
         NSArray *gradientColors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
         // 建立漸層顏色的啟始點，因為有兩個顏色，所以有兩個數值，如果有多個顏色就需要多個數值
         // 數值的範圍為 0~1。
         CGFloat gradientLocation[] = {0, 1};
         // 建立繪製漸層的基本資訊
         CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocation);
         // 建立繪製漸層的起點
         CGPoint beginPoint = CGPointMake(initPointX + 0.5, initPointY);
         // 建立繪製漸層的終點
         CGPoint endPoint = CGPointMake(initPointX + 0.5 + self.theBuyData * widthRate, initPointY);
         CGContextSetLineWidth(context, self.frame.size.height);
         CGContextDrawLinearGradient(context, gradient, beginPoint, endPoint, 0);
         CGContextSaveGState(context);
         
         //------------------------------
         //green part
         
         // 建立一個 RGB 的顏色空間
         CGColorSpaceRef colorSpace2 = CGColorSpaceCreateDeviceRGB();
         // 建立漸層用的顏色，這邊只用兩個顏色，要更多顏色可以自行加入
         UIColor *beginColor2 = [UIColor colorWithRed:123.0/255 green:187.0/255 blue:0 alpha:1];
         UIColor *endColor2 = [UIColor colorWithRed:30/255.0 green:150.0/255.0 blue:40.0/255.0 alpha:1];
         // 將顏色加入陣列中
         NSArray *gradientColors2 = [NSArray arrayWithObjects:(id)beginColor2.CGColor, (id)endColor2.CGColor, nil];
         // 建立漸層顏色的啟始點，因為有兩個顏色，所以有兩個數值，如果有多個顏色就需要多個數值
         // 數值的範圍為 0~1。
         CGFloat gradientLocation2[] = {0, 1};
         // 建立繪製漸層的基本資訊
         CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace2, (CFArrayRef)gradientColors2, gradientLocation2);
         // 建立繪製漸層的起點
         CGPoint beginPoint2 = CGPointMake(initPointX - 0.5, initPointY);
         // 建立繪製漸層的終點
         CGPoint endPoint2 = CGPointMake(initPointX -  self.theSellData * widthRate, initPointY);
         CGContextSetLineWidth(context, self.frame.size.height);
         CGContextDrawLinearGradient(context, gradient2, beginPoint2, endPoint2, 0);
         CGContextSaveGState(context);
    }
     if(_marketSentiment != 0.0 || _theForce != 0.0){
         double initPointX = self.frame.size.width / 2;
         double initPointY = self.frame.size.height / 2;
         double widthRate = self.frame.size.width / 2;
         if(_marketSentiment > 1.0 || _theForce > 1.0){
             // 建立一個 RGB 的顏色空間
             CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
             // 建立漸層用的顏色，這邊只用兩個顏色，要更多顏色可以自行加入
             UIColor *beginColor = [UIColor colorWithRed:226.0/255.0 green:112.0/255.0 blue:0 alpha:1];
             UIColor *endColor = [UIColor colorWithRed:220.0/255.0 green:0 blue:0 alpha:1];
             // 將顏色加入陣列中
             NSArray *gradientColors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
             // 建立漸層顏色的起始點，因為有兩個顏色，所以有兩個數值，如果有多個顏色就需要多個數值
             // 數值的範圍為 0~1。
             CGFloat gradientLocation[] = {0, 1};
             // 建立繪製漸層的基本資訊
             CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocation);
             // 建立繪製漸層的起點
             CGPoint beginPoint = CGPointMake(initPointX + 0.5, initPointY);
             // 建立繪製漸層的終點
             CGPoint endPoint = CGPointMake(initPointX + 0.5 + ((_marketSentiment!=0.0)?_marketSentiment:_theForce) * widthRate / ((_theForce!=0.0)?13:13) , initPointY);
             CGContextSetLineWidth(context, self.frame.size.height);
             CGContextDrawLinearGradient(context, gradient, beginPoint, endPoint, 0);
             CGContextSaveGState(context);
         }else{
         //------------------------------
         //green part
         
             // 建立一個 RGB 的顏色空間
             CGColorSpaceRef colorSpace2 = CGColorSpaceCreateDeviceRGB();
             // 建立漸層用的顏色，這邊只用兩個顏色，要更多顏色可以自行加入
             UIColor *beginColor2 = [UIColor colorWithRed:123.0/255 green:187.0/255 blue:0 alpha:1];
             UIColor *endColor2 = [UIColor colorWithRed:30/255.0 green:150.0/255.0 blue:40.0/255.0 alpha:1];
             // 將顏色加入陣列中
             NSArray *gradientColors2 = [NSArray arrayWithObjects:(id)beginColor2.CGColor, (id)endColor2.CGColor, nil];
             // 建立漸層顏色的啟始點，因為有兩個顏色，所以有兩個數值，如果有多個顏色就需要多個數值
             // 數值的範圍為 0~1。
             CGFloat gradientLocation2[] = {0, 1};
             // 建立繪製漸層的基本資訊
             CGGradientRef gradient2 = CGGradientCreateWithColors(colorSpace2, (CFArrayRef)gradientColors2, gradientLocation2);
             // 建立繪製漸層的起點
             CGPoint beginPoint2 = CGPointMake(initPointX - 0.5, initPointY);
             // 建立繪製漸層的終點
             CGPoint endPoint2 = CGPointMake(initPointX -  widthRate / ((_theForce!=0.0)?8:7) * ((_marketSentiment!=0.0)?_marketSentiment:_theForce), initPointY);
             CGContextSetLineWidth(context, self.frame.size.height);
             CGContextDrawLinearGradient(context, gradient2, beginPoint2, endPoint2, 0);
             CGContextSaveGState(context);
         }
         
     }
 
 }


@end
