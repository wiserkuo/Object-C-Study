//
//  RevenueChartView.m
//  WirtsLeg
//
//  Created by Connor on 13/12/3.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//


#import "FGColor.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "RevenueChartView.h"

@implementation RevenueChartView

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
       _chartViewType = 0;
    }
    return self;
}

-(void)cleanChartView
{
    [revenueArray removeAllObjects];
    [self setNeedsDisplay];
}

-(void)setChartViewType:(int)chartViewType
{
    _chartViewType = chartViewType;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
#ifdef PatternPowerUS
    identCode = @"US";
#endif
    
#ifdef PatternPowerTW
    identCode = @"TW";
#endif
    
#ifdef PatternPowerCN
    identCode = @"SS";
#endif
    NSMutableArray *quarterRevenue = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray *quarterDate = [[NSMutableArray alloc] initWithCapacity:4];
    NSMutableArray *growRate = [[NSMutableArray alloc] initWithCapacity:4];
    int count = (int)[revenueArray count];
    if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
        if( count > 12){
            count = 12;
        }
    }else{
        if( count > 8){
            count = 8;
        }
    }
    for (int i = 0; i < count; i++) {
        [quarterRevenue addObject:[[revenueArray objectAtIndex:i]objectForKey:@"Revenue"]];
        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
            if(_chartViewType == 0){//0 合併營收
                [growRate addObject:[[revenueArray objectAtIndex:i]objectForKey:@"MergedRevenueYoY"]];
            }else{ //1 非合併營收
                [growRate addObject:[[revenueArray objectAtIndex:i]objectForKey:@"RevenueYoY"]];
            }
            
        }else if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"us"] || [[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"cn"]){
            [growRate addObject:[[revenueArray objectAtIndex:i]objectForKey:@"RevenueYoY"]];
        }
        [quarterDate addObject:[self getDateStr:[[revenueArray objectAtIndex:i]objectForKey:@"Date"]]];
    }

    float reserveTopHeight = 0;
    float reserveBottomHeight = 44;
    float reserveLeftWidth = 55;
    float reserveRightWidth = 55;
    
    float reserveGraphicTopHeight = 33;
    
    float histogramGapWidth = 5;
    
    if ([quarterRevenue count] == 0) {
        return;
    }
    
    double min_rev = DBL_MAX;
    double max_rev = DBL_MIN;
    
    NSNumber *NaN = [NSDecimalNumber notANumber];
    
    for (int i = 0; i < [quarterRevenue count]; i++) {
        
        if ([[quarterRevenue objectAtIndex:[quarterRevenue count]-1-i] isEqualToNumber:NaN]) {
            continue;
        }
        
        double itValue = [(NSNumber *)[quarterRevenue objectAtIndex:i] doubleValue];
        
        if (min_rev > itValue) {
            min_rev = itValue;
        }
        
        if (max_rev < itValue) {
            max_rev = itValue;
        }
    }
    
    double range_rev = max_rev - min_rev;
    
    
    double min_grow = DBL_MAX;
    double max_grow = DBL_MIN;
    
    for (int i = 0; i < [growRate count]; i++) {
        
        if ([[growRate objectAtIndex:[growRate count]-1-i] isEqualToNumber:NaN]) {
            continue;
        }
        
        double itValue = [(NSNumber *)[growRate objectAtIndex:[growRate count]-1-i] doubleValue];
        
        if (min_grow > itValue) {
            min_grow = itValue;
        }
        
        if (max_grow < itValue) {
            max_grow = itValue;
        }
    }
    
    double range_grow = max_grow - min_grow;
    
    
    CGRect chartRect = CGRectMake(reserveLeftWidth,
                                  reserveTopHeight,
                                  rect.size.width - reserveLeftWidth - reserveRightWidth,
                                  rect.size.height - reserveBottomHeight);
    
    float histogramWidth = (chartRect.size.width - ([growRate count] + 1) * histogramGapWidth) / [growRate count];
    
    
    CGMutablePathRef chartViewBorderRantangle = CGPathCreateMutable();
  
    CGPathAddRect(chartViewBorderRantangle, NULL, rect);

    // 內框
    CGPathAddRect(chartViewBorderRantangle, NULL, chartRect);

    // 十億, 百萬, 千, 元
    
    NSString *basedUnitText;
    NSString *revText;
    if (max_rev >= 1000) {
        basedUnitText = NSLocalizedStringFromTable(@"十億", @"Equity", nil);
        revText = [NSString stringWithFormat:@"%.2f", floor(max_rev / 1000 * 100) / 100];
    } else{
        basedUnitText = NSLocalizedStringFromTable(@"百萬", @"Equity", nil);
        revText = [NSString stringWithFormat:@"%.2f", max_rev];

    }

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    UIFont * font = [UIFont boldSystemFontOfSize:16.0f];
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };
    
    [basedUnitText drawInRect:CGRectMake(3, reserveTopHeight, reserveLeftWidth + 5, 20) withAttributes:attributes];

    paragraphStyle.alignment = NSTextAlignmentRight;
    font = [UIFont boldSystemFontOfSize:13.0f];
    [revText drawInRect:CGRectMake(0, reserveTopHeight + reserveGraphicTopHeight*2/3, reserveLeftWidth - 5, 20) withAttributes:attributes];
    
    paragraphStyle.alignment = NSTextAlignmentLeft;
    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor orangeColor],NSParagraphStyleAttributeName: paragraphStyle };
    NSString *growText = [self getPrecent:max_grow];
    [growText drawInRect:CGRectMake(rect.size.width+3 - reserveRightWidth, reserveTopHeight + reserveGraphicTopHeight*2/3, reserveRightWidth, 20) withAttributes:attributes];
    
    [[UIColor blackColor] set];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat lengths[] = {1,1};
    CGContextSetLineWidth(context, 2);
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextMoveToPoint(context, reserveLeftWidth, reserveTopHeight + reserveGraphicTopHeight);
    CGContextAddLineToPoint(context, rect.size.width - reserveRightWidth, reserveTopHeight + reserveGraphicTopHeight);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    
    if(min_grow<=0){
        CGContextSetLineWidth(context, 1);
        double lineBaseSize;
        lineBaseSize = chartRect.size.height / [quarterDate count] + (chartRect.size.height * ([growRate count]-1) / [quarterDate count] - reserveGraphicTopHeight) * (0 - min_grow) / range_grow;
        
        CGContextMoveToPoint(context, reserveLeftWidth, rect.size.height - reserveBottomHeight - lineBaseSize);
        CGContextAddLineToPoint(context, rect.size.width - reserveRightWidth, rect.size.height - reserveBottomHeight - lineBaseSize);
        CGContextStrokePath(context);
        
        NSString *growText = [self getPrecent:0.00];
        [growText drawInRect:CGRectMake(rect.size.width+3 - reserveRightWidth, rect.size.height - reserveBottomHeight - lineBaseSize-10, reserveRightWidth, 20) withAttributes:attributes];
    }
    
    
    for (int i = 0; i < [quarterDate count]; i++) {
        
        if ([[quarterRevenue objectAtIndex:[quarterDate count]-1-i] isEqualToNumber:NaN]) {
            continue;
        }
        NSString *a1 = [quarterDate objectAtIndex:[quarterDate count]-1-i];
        int month;
        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
            month = [[a1 substringFromIndex:4] intValue];
        }else{
            month = [[a1 substringFromIndex:5] intValue];
        }
        
        
        //年的Label
        if(month == 1){
            if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
                UIFont *yearFont = [UIFont boldSystemFontOfSize:17.0f];
                NSDictionary *attributes2 = @{ NSFontAttributeName: yearFont,NSForegroundColorAttributeName:[UIColor blueColor],NSParagraphStyleAttributeName: paragraphStyle };
                NSDate *now = [[NSDate alloc]init];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy"];
                NSString *dateString = [formatter stringFromDate:now];
                int year = [dateString intValue];
                year -= 1911;
                NSString *yearString = [NSString stringWithFormat:@"%d", year];
                
                CGRect yearRect =
                CGRectMake(reserveLeftWidth + histogramGapWidth + histogramWidth * i + histogramGapWidth * i,
                           rect.size.height - reserveBottomHeight + 13,
                           histogramWidth + 20,
                           25);
                [yearString drawInRect:yearRect withAttributes:attributes2];
                [[UIColor blackColor] set];
            }
        }
        
        
        NSString *month_TW = [a1 substringFromIndex:4];
        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
            paragraphStyle.alignment = NSTextAlignmentCenter;
            font = [UIFont boldSystemFontOfSize:12.0f];
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName: paragraphStyle };
            [month_TW drawInRect:CGRectMake(reserveLeftWidth + histogramGapWidth + histogramWidth * i + histogramGapWidth * i, rect.size.height - reserveBottomHeight, histogramWidth+5, 20) withAttributes:attributes];
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor],NSParagraphStyleAttributeName: paragraphStyle };
            
            
            
            
        }else{
        
            NSString *monthString;
            if (month>=1 && month<=3) {
                monthString = @"Q1";
            }else if (month>=4 && month<=6){
                monthString = @"Q2";
            }else if (month>=7 && month<=9){
                monthString = @"Q3";
            }else if (month>=10 && month<=12){
                monthString = @"Q4";
            }
            paragraphStyle.alignment = NSTextAlignmentCenter;
            font = [UIFont boldSystemFontOfSize:14.0f];
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName: paragraphStyle };
            [monthString drawInRect:CGRectMake(reserveLeftWidth + histogramGapWidth + histogramWidth * i + histogramGapWidth * i, rect.size.height - reserveBottomHeight, histogramWidth, 20) withAttributes:attributes];
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor],NSParagraphStyleAttributeName: paragraphStyle };
            if ([@"Q1" isEqualToString:monthString]) {
                
                int year = [[a1 substringToIndex:4] intValue];
                NSString *yearString = [NSString stringWithFormat:@"%d", year];
                
                CGRect yearRect =
                CGRectMake(reserveLeftWidth + histogramGapWidth + histogramWidth * i + histogramGapWidth * i,
                           rect.size.height - reserveBottomHeight + 13,
                           histogramWidth + 15,
                           20);
                [yearString drawInRect:yearRect withAttributes:attributes];
                [[UIColor blackColor] set];
            }
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGContextSetShadow(context, CGSizeMake(1, 1), 5);
        
        // quarterRevenue
        
        double histogramBaseSize;
        if ([(NSNumber *)[quarterRevenue objectAtIndex:[quarterDate count]-1-i] doubleValue] == min_rev) {
            histogramBaseSize = (chartRect.size.height - reserveGraphicTopHeight) * 0.125;
        } else if ([(NSNumber *)[quarterRevenue objectAtIndex:[quarterDate count]-1-i] doubleValue] == max_rev) {
            histogramBaseSize = chartRect.size.height - reserveGraphicTopHeight;
        } else {
            histogramBaseSize = (chartRect.size.height - reserveGraphicTopHeight) * 0.125 + ((chartRect.size.height - reserveGraphicTopHeight) * 0.875 * ([(NSNumber *)[quarterRevenue objectAtIndex:[quarterDate count]-1-i] doubleValue] - min_rev) / range_rev);
        }
        
        CGRect rectangle = CGRectMake(reserveLeftWidth + histogramGapWidth + histogramGapWidth * i + histogramWidth * i, rect.size.height - reserveBottomHeight, histogramWidth, -histogramBaseSize);
        CGPathAddRect(path, NULL, rectangle);
        
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
            [[FGColor colorWithIndex:month%12] setFill];
        } else {
            [[FGColor colorWithIndex:month%4] setFill];
        }
        
        
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextRestoreGState(context);
        CGContextSaveGState(context);
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetLineWidth(context, 2);
    
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW) {
        int firstPointFlag = 0;
        
        for (int i = 0; i < [quarterDate count]; i++) {
            
            if ([[growRate objectAtIndex:[quarterDate count]-1-i] isEqualToNumber:NaN]) {
                continue;
            }
            
            double lineBaseSize;
            
            if ([(NSNumber *)[growRate objectAtIndex:[quarterDate count] - 1 - i] doubleValue] == min_grow) {
                //            lineBaseSize = (chartRect.size.height - reserveGraphicTopHeight) / [quarterDate count];
                lineBaseSize = (chartRect.size.height - reserveGraphicTopHeight) / ([quarterDate count] - 4);
            } else if ([(NSNumber *)[growRate objectAtIndex:[quarterDate count]-1-i] doubleValue] == max_grow) {
                lineBaseSize = chartRect.size.height - reserveGraphicTopHeight - 1;
            } else {
                lineBaseSize = chartRect.size.height / ([quarterDate count] - 3 ) + (chartRect.size.height * ([growRate count]-1) / [quarterDate count] - reserveGraphicTopHeight) * ([(NSNumber *)[growRate objectAtIndex:[growRate count]-1-i] doubleValue] - min_grow) / range_grow;
                //            lineBaseSize = chartRect.size.height / [quarterDate count] + (chartRect.size.height * ([growRate count]-1) / [quarterDate count] - reserveGraphicTopHeight) * ([(NSNumber *)[growRate objectAtIndex:[growRate count]-1-i] doubleValue] - min_grow) / range_grow;
            }
            
            if (firstPointFlag == 0) {
                CGContextMoveToPoint(context,
                                     reserveLeftWidth + histogramGapWidth + histogramWidth * i + histogramWidth / 2, rect.size.height - reserveBottomHeight - lineBaseSize);
                firstPointFlag = 1;
            } else {
                CGContextAddLineToPoint(context, reserveLeftWidth + histogramGapWidth + histogramGapWidth * i + histogramWidth * i + histogramWidth / 2, rect.size.height - reserveBottomHeight - lineBaseSize);
            }
        }
    }
    else {
        int firstPointFlag = 0;
        
        for (int i = 0; i < [quarterDate count]; i++) {
            
            if ([[growRate objectAtIndex:[quarterDate count]-1-i] isEqualToNumber:NaN]) {
                continue;
            }
            
            double lineBaseSize;
            
            if ([(NSNumber *)[growRate objectAtIndex:[quarterDate count]-1-i] doubleValue] == min_grow) {
                lineBaseSize = (chartRect.size.height - reserveGraphicTopHeight) / [quarterDate count];
            } else if ([(NSNumber *)[growRate objectAtIndex:[quarterDate count]-1-i] doubleValue] == max_grow) {
                lineBaseSize = chartRect.size.height - reserveGraphicTopHeight - 1;
            } else {
                lineBaseSize = chartRect.size.height / [quarterDate count] + (chartRect.size.height * ([growRate count]-1) / [quarterDate count] - reserveGraphicTopHeight) * ([(NSNumber *)[growRate objectAtIndex:[growRate count]-1-i] doubleValue] - min_grow) / range_grow;
            }
            
            if (firstPointFlag == 0) {
                CGContextMoveToPoint(context,
                                     reserveLeftWidth + histogramGapWidth + histogramWidth * i + histogramWidth / 2, rect.size.height - reserveBottomHeight - lineBaseSize);
                
                firstPointFlag = 1;
            } else {
                CGContextAddLineToPoint(context, reserveLeftWidth + histogramGapWidth + histogramGapWidth * i + histogramWidth * i + histogramWidth / 2, rect.size.height - reserveBottomHeight - lineBaseSize);
            }
        }
    }
    
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGContextSaveGState(context);
    
    
    CGContextAddPath(context, chartViewBorderRantangle);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    
    CGContextRestoreGState(context);
}

- (void)a {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, screenRect.origin.x, screenRect.origin.y);
    CGPathAddLineToPoint(path, NULL, screenRect.size.width, screenRect.size.height);
    CGPathMoveToPoint(path, NULL, screenRect.size.width, screenRect.origin.y);
    CGPathAddLineToPoint(path, NULL, screenRect.origin.x, screenRect.size.height);
    
    CGContextSetLineWidth(context, 5);
    CGContextSetRGBStrokeColor(context, 1, 1, 0, 1);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGPathRelease(path);
    
    
    CGContextMoveToPoint(context, 10, 10);
    CGContextAddLineToPoint(context, 30, 30);
    CGContextAddLineToPoint(context, 100, 100);
    CGContextAddLineToPoint(context, 200, 400);
    
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    
    
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathMoveToPoint(path2, NULL, screenRect.origin.x/2+10, screenRect.origin.y/2);
    CGPathAddLineToPoint(path2, NULL, screenRect.size.width/2, screenRect.size.height/2);
    CGPathMoveToPoint(path2, NULL, screenRect.size.width/2, screenRect.origin.y/2);
    CGPathAddLineToPoint(path2, NULL, screenRect.origin.x+10/2, screenRect.size.height/2);
    
    CGContextSetLineWidth(context, 10);
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    
    CGContextAddPath(context, path2);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGPathRelease(path2);
    
    CGContextRestoreGState(context);
    
}

-(void)setNeedsDisplayWithArray:(NSMutableArray *)array
{
    revenueArray = array;
    [super setNeedsDisplay];
    
}


-(void)dealloc {
    NSLog(@"dealloc %s", __FUNCTION__);
}

-(NSString *)getDateStr:(NSDate*)date
{
    NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
    [yearFormat setDateFormat:@"yyyy"];
    int year = [[yearFormat stringFromDate:date]intValue];
    year-=1911;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM"];
    
    NSDateFormatter *monthFormat = [[NSDateFormatter alloc] init];
    [monthFormat setDateFormat:@"MM"];
    NSString *month = [monthFormat stringFromDate:date];
    
    if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
        return [NSString stringWithFormat:@"%d/%@",year,month];
    }else{
        return [formatter stringFromDate:date];
    }
}

-(NSString *)getPrecent:(double)value
{
    if(value > 0 ){
        if(value <10){
            return [NSString stringWithFormat:@"%.2f%%", value];
        }else if(value < 100){
            return [NSString stringWithFormat:@"%.1f%%", value];
        }else{
            return [NSString stringWithFormat:@"%.0f%%", value];
        }
    }else{
        if(value <10){
            return [NSString stringWithFormat:@"%-.2f%%", value];
        }else if(value < 100){
            return [NSString stringWithFormat:@"%-.1f%%", value];
        }else{
            return [NSString stringWithFormat:@"%-.0f%%", value];
        }
    }
}
@end
