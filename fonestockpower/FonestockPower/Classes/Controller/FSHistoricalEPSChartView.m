//
//  HistoricalEPSChartView.m
//  FonestockPower
//
//  Created by Connor on 14/4/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSHistoricalEPSChartView.h"
#import "FGColor.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface FSHistoricalEPSChartView (){
    NSArray *epsRecords;
    enum EPSchartMode mode;
    float max;
    float min;
    UIFont *font;
    NSMutableDictionary *colorDict;
    NSMutableArray *epsRecordsBySeason;
    PortfolioItem *item;
}

@end

@implementation FSHistoricalEPSChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor blackColor] CGColor];
        font = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
        epsRecordsBySeason = [[NSMutableArray alloc] init];
        colorDict = [[NSMutableDictionary alloc] init];
        max = -MAXFLOAT;
        min = 0;
        
        item = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    }
    return self;
}

- (void)notifyDrawChart:(NSArray *)epsRecord mode:(enum EPSchartMode)chartMode {
    epsRecords = epsRecord;
    mode = chartMode;
    
    max = -MAXFLOAT;
    min = 0;
    
    for (NSDictionary *epsRecordDictionary in epsRecord) {
        float epsValue = [(NSNumber *)[epsRecordDictionary objectForKey:@"epsValue"] floatValue];
        if (max < epsValue) {
            max = epsValue;
        }
        if (min > epsValue) {
            min = epsValue;
        }
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (mode == EPSChartMode_Year) {
        [self setColorByYear];
        [self drawYearChart:rect];
    } else {
        [self seasonSort];
        [self setColorBySeason];
        [self drawSeasonChart:rect];
    }
}

- (void)setColorByYear {
    [colorDict removeAllObjects];
    
    int colorSelectedIndex = 0;
    
    for (NSDictionary *epsRecord in epsRecords) {
        NSString *seasonString = [[epsRecord objectForKey:@"seasonValue"] stringValue];
        NSString *test = [colorDict objectForKey:seasonString];
        if (test == nil) {
            UIColor *selectedColor = [FGColor colorWithIndex:colorSelectedIndex];
            [colorDict setObject:selectedColor forKey:seasonString];
            colorSelectedIndex++;
        }
    }
}

- (void)setColorBySeason {
    
    [colorDict removeAllObjects];
    
    int colorSelectedIndex = 0;
    

    for (NSDictionary *epsRecord in epsRecords) {
        NSString *yearString;
        if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
            
            yearString = [NSString stringWithFormat:@"%02d", ([[epsRecord objectForKey:@"yearValue"] intValue])];
        }else{
            yearString = [NSString stringWithFormat:@"%02d", ([[epsRecord objectForKey:@"yearValue"] intValue] + 1911)%100];
        }
        //[[epsRecord objectForKey:@"yearValue"] stringValue];
        
        NSString *test = [colorDict objectForKey:yearString];
        if (test == nil) {
            UIColor *selectedColor = [FGColor colorWithIndex:colorSelectedIndex];
            [colorDict setObject:selectedColor forKey:yearString];
            colorSelectedIndex++;
        }
    }
}


- (void)seasonSort {
    
    [epsRecordsBySeason removeAllObjects];
    
    int lastRecordSeason;
    if ([epsRecords count] > 0) {
        NSDictionary *epsRecord = [epsRecords objectAtIndex:0];
        lastRecordSeason = [(NSNumber *)[epsRecord objectForKey:@"seasonValue"] intValue];
    }
    
    // 季節排序
    for (int s = 0; s < 4; s++) {
        for (int i = 0; i < [epsRecords count]; i++) {
            NSDictionary *epsRecord = [epsRecords objectAtIndex:i];
            
            int tmpSeason = 0;
            if ((lastRecordSeason - s) > 0) {
                tmpSeason = lastRecordSeason - s;
            } else {
                tmpSeason = (lastRecordSeason -s) + 4;
            }
            
            int seasonValue = [(NSNumber *)[epsRecord objectForKey:@"seasonValue"] intValue];
            if (seasonValue == tmpSeason) {
                [epsRecordsBySeason addObject:epsRecord];
            }
        }
    }
}

- (void)drawSeasonChart:(CGRect)rect {
    
    int reserveTopHeight = 22;
    int reserveBottomHeight = 44;
    int reserveRightWidth = 30;
    int reserveLeftWidth = 5;
    
    int realHeight = self.frame.size.height;
    int realWidth = self.frame.size.width;
    int chartHeight = realHeight - reserveTopHeight - reserveBottomHeight;
    int chartWidth = realWidth - reserveLeftWidth - reserveRightWidth;
    
    int barChartWidth = 0;
    if ([epsRecords count] > 0) {
        barChartWidth = chartWidth / [epsRecords count];
    }
    
    float range = max - min;
    float percent = max / range;
    
    float baseZeroLineY = chartHeight * percent;
    
    int valueRightOffset = 2;
    int valueTopOffset = -7;
    
    // 取得繪圖context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // 建立path, 繪矩形
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGRect rectangle = CGRectMake(3.0f, 3.0f, rect.size.width - 6, rect.size.height - 15);
    CGPathAddRect(path, NULL, rectangle);
    
    CGContextAddPath(currentContext, path);
    
    // 棕色
    [[UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1.0f] setStroke];
    
    // 無邊框 好計算
    CGContextSetLineWidth(currentContext, 1.0f);
    
    CGContextDrawPath(currentContext, kCGPathStroke);
    
    //    NSLog(@"%@", _epsRecordsBySeason);
    
    NSString *checkYear;
    NSString *checkSeason;
    int seasonCountForYear = 0;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
    
    for (int i = 0; i < [epsRecordsBySeason count]; i++) {
        NSDictionary *epsRecord = [epsRecordsBySeason objectAtIndex:i];
        
        NSString *seasonString = [[epsRecord objectForKey:@"seasonValue"] stringValue];
        
        NSString *yearString;
        if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){

            yearString = [NSString stringWithFormat:@"%02d", ([[epsRecord objectForKey:@"yearValue"] intValue])];
        }else{
            yearString = [NSString stringWithFormat:@"%02d", ([[epsRecord objectForKey:@"yearValue"] intValue] + 1911)%100];
        }
        if ([[epsRecordsBySeason objectAtIndex:0] isEqual:epsRecord]) {
            [[UIColor grayColor] set];
            CGContextSetLineDash(currentContext, 0, nil, 0);
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i), 3);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i), realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            checkSeason = seasonString;
            checkYear = yearString;
            
            seasonCountForYear++;
        }
        
        if (![[epsRecordsBySeason lastObject] isEqual:epsRecord]) {
            NSDictionary *nextEpsRecord = [epsRecordsBySeason objectAtIndex:i+1];
            NSString *nextEpsRecordSeasonString = [[nextEpsRecord objectForKey:@"seasonValue"] stringValue];
            
            if ([seasonString isEqualToString:nextEpsRecordSeasonString]) {
                seasonCountForYear++;
            } else {
                [[UIColor grayColor] set];
                
                // 畫直線
                CGContextSetLineDash(currentContext, 0, nil, 0);
                
                CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), 3);
                CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), realHeight - reserveBottomHeight);
                CGContextStrokePath(currentContext);
                
                
                NSString *printSeasonString = [NSString stringWithFormat:@"Q%@", seasonString];
                
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                
                [printSeasonString drawAtPoint:CGPointMake(realWidth - reserveRightWidth - barChartWidth * (i+1) + (barChartWidth * seasonCountForYear)/2 - seasonCountForYear-5, reserveTopHeight + baseZeroLineY + (-min / range * chartHeight)+10) withAttributes:attributes];
                
                seasonCountForYear = 1;
            }
        }
        
        if ([[epsRecordsBySeason lastObject] isEqual:epsRecord]) {
            [[UIColor grayColor] set];
            CGContextSetLineDash(currentContext, 0, nil, 0);
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), 3);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
            
            NSString *printSeasonString = [NSString stringWithFormat:@"Q%@", seasonString];
            [printSeasonString drawAtPoint:CGPointMake(realWidth - reserveRightWidth - barChartWidth * (i+1) + (barChartWidth * seasonCountForYear)/2 - seasonCountForYear-5 , reserveTopHeight + baseZeroLineY + (-min / range * chartHeight)+10) withAttributes:attributes];
        }
        
        UIColor *drawColor = [colorDict objectForKey:yearString];
        [drawColor setFill];
        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:drawColor};
        
        float epsValue = [(NSNumber *)[epsRecord objectForKey:@"epsValue"] floatValue];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGContextSetShadow(currentContext, CGSizeMake(1, 1), 5);
        CGRect rectangle = CGRectMake(realWidth - reserveRightWidth - barChartWidth * i, reserveTopHeight + baseZeroLineY, -barChartWidth, -epsValue / range * chartHeight);
        CGPathAddRect(path, NULL, rectangle);
        
        //        [seasonString drawInRect:CGRectMake(realWidth - reserveRightWidth - 19 * i, reserveTopHeight + baseZeroLineY + 10, -19, -epsValue / range * chartHeight) withFont:_font];
        
        
        // 計算位移數量
        int diff = 0;
        if ([yearString length] == 2) {
            diff = 3;
        } else if ([yearString length] == 3) {
            diff = 1;
        }
        
        [yearString drawAtPoint:CGPointMake(realWidth - reserveRightWidth - barChartWidth * (i+1) + diff, reserveTopHeight + baseZeroLineY + (-min / range * chartHeight)) withAttributes:attributes];
        
        
        [[UIColor blackColor] setStroke];
        
        CGContextAddPath(currentContext, path);
        CGContextDrawPath(currentContext, kCGPathFillStroke);
        
        if (i == 0) {
            
            [[UIColor grayColor] set];
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth, reserveTopHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth, realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            CGFloat lengths[] = {1,1};
            CGContextSetLineDash(currentContext, 0, lengths, 2);
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth, realHeight - reserveBottomHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], realHeight - reserveBottomHeight);
            
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth, reserveTopHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], reserveTopHeight);
            CGContextStrokePath(currentContext);
            
            CGContextSetLineDash(currentContext, 0, nil, 0);
            
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], reserveTopHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            
            NSString *zeroString = @"0.00";
            NSString *maxValueString = [NSString stringWithFormat:@"%.2f", max];
            NSString *minValueString = [NSString stringWithFormat:@"%.2f", min];
            
            if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
            }
            
            [zeroString drawAtPoint:CGPointMake(realWidth - reserveRightWidth + valueRightOffset, reserveTopHeight + baseZeroLineY + valueTopOffset) withAttributes:attributes];
            
            if (max > 0) {
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
            } else {
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
            }
            [maxValueString drawAtPoint:CGPointMake(realWidth - reserveRightWidth + valueRightOffset, reserveTopHeight + valueTopOffset) withAttributes:attributes];
            
            if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
                if (min > 0) {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                } else if(min == 0) {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                } else {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                }
            }else{
                if (min > 0) {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                } else {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                }
            }
            
            [minValueString drawAtPoint:CGPointMake(realWidth - reserveRightWidth + valueRightOffset, realHeight - reserveBottomHeight + valueTopOffset) withAttributes:attributes];
        }
    }
    
    CGPathRelease(path);
}

- (void)drawYearChart:(CGRect)rect {
    
    int reserveTopHeight = 22;
    int reserveBottomHeight = 44;
    int reserveRightWidth = 30;
    int reserveLeftWidth = 5;
    
    int realHeight = self.frame.size.height;
    int realWidth = self.frame.size.width;
    int chartHeight = realHeight - reserveTopHeight - reserveBottomHeight;
    int chartWidth = realWidth - reserveLeftWidth - reserveRightWidth;
    
    int barChartWidth = 0;
    if ([epsRecords count] > 0) {
        barChartWidth = chartWidth / [epsRecords count];
    }
    
    
    float range = max - min;
    float percent = max / range;
    
    float baseZeroLineY = chartHeight * percent;
    
    int valueRightOffset = 2;
    int valueTopOffset = -7;
    
    // 取得繪圖context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // 建立path, 繪矩形
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGRect rectangle = CGRectMake(3.0f, 3.0f, rect.size.width - 6, rect.size.height - 15);
    CGPathAddRect(path, NULL, rectangle);
    
    CGContextAddPath(currentContext, path);
    
    // 棕色
    [[UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1.0f] setStroke];
    
    // 無邊框 好計算
    CGContextSetLineWidth(currentContext, 1.0f);
    
    CGContextDrawPath(currentContext, kCGPathStroke);
    
    //    NSLog(@"%@", epsRecords);
    
    NSString *checkYear;
    int seasonCountForYear = 0;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
    
    for (int i = 0; i < [epsRecords count]; i++) {
        NSDictionary *epsRecord = [epsRecords objectAtIndex:i];
        
        NSString *seasonString = [[epsRecord objectForKey:@"seasonValue"] stringValue];
    
        NSString *yearString;
        if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
            
            yearString = [NSString stringWithFormat:@"%02d", ([[epsRecord objectForKey:@"yearValue"] intValue])];
        }else{
            yearString = [NSString stringWithFormat:@"%02d", ([[epsRecord objectForKey:@"yearValue"] intValue] + 1911)];
        }

        if ([[epsRecords objectAtIndex:0] isEqual:epsRecord]) {
            [[UIColor grayColor] set];
            CGContextSetLineDash(currentContext, 0, nil, 0);
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i), 3);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i), realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            checkYear = yearString;
            
            seasonCountForYear++;
        }
        
        if (![[epsRecords lastObject] isEqual:epsRecord]) {
            NSDictionary *nextEpsRecord = [epsRecords objectAtIndex:i+1];
            NSString *nextEpsRecordYearString;
            if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){

                nextEpsRecordYearString = [NSString stringWithFormat:@"%02d", [[nextEpsRecord objectForKey:@"yearValue"] intValue]];
            }else{
                nextEpsRecordYearString = [NSString stringWithFormat:@"%02d", [[nextEpsRecord objectForKey:@"yearValue"] intValue] + 1911];
            }
            if ([yearString isEqualToString:nextEpsRecordYearString]) {
                seasonCountForYear++;
            } else {
                [[UIColor grayColor] set];
                
                // 畫直線
                CGContextSetLineDash(currentContext, 0, nil, 0);
                
                CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), 3);
                CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), realHeight - reserveBottomHeight);
                CGContextStrokePath(currentContext);
                
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                
                [yearString drawAtPoint:CGPointMake(realWidth - reserveRightWidth - barChartWidth * (i+1) + (barChartWidth * seasonCountForYear)/2 - seasonCountForYear-5, reserveTopHeight + baseZeroLineY + (-min / range * chartHeight)+10) withAttributes:attributes];
                
                seasonCountForYear = 1;
            }
        }
        
        if ([[epsRecords lastObject] isEqual:epsRecord]) {
            [[UIColor grayColor] set];
            CGContextSetLineDash(currentContext, 0, nil, 0);
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), 3);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * (i + 1), realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
            
            [yearString drawAtPoint:CGPointMake(realWidth - reserveRightWidth - barChartWidth * (i+1) + (barChartWidth * seasonCountForYear)/2 - seasonCountForYear-5 , reserveTopHeight + baseZeroLineY + (-min / range * chartHeight)+10) withAttributes:attributes];
        }
        
        
        UIColor *drawColor = [colorDict objectForKey:seasonString];
        [drawColor setFill];
        
        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:drawColor};
        
        float epsValue = [(NSNumber *)[epsRecord objectForKey:@"epsValue"] floatValue];
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGContextSetShadow(currentContext, CGSizeMake(1, 1), 5);
        CGRect rectangle = CGRectMake(realWidth - reserveRightWidth - barChartWidth * i, reserveTopHeight + baseZeroLineY, -barChartWidth, -epsValue / range * chartHeight);
        CGPathAddRect(path, NULL, rectangle);
        
        //        [seasonString drawInRect:CGRectMake(realWidth - reserveRightWidth - 19 * i, reserveTopHeight + baseZeroLineY + 10, -19, -epsValue / range * chartHeight) withFont:font];
        
        NSString *printSeasonString = [NSString stringWithFormat:@"Q%@", seasonString];
        [printSeasonString drawAtPoint:CGPointMake(realWidth - reserveRightWidth - barChartWidth * (i+1) + 3, reserveTopHeight + baseZeroLineY + (-min / range * chartHeight)) withAttributes:attributes];
        
        
        [[UIColor blackColor] setStroke];
        
        CGContextAddPath(currentContext, path);
        CGContextDrawPath(currentContext, kCGPathFillStroke);
        
        if (i == 0) {
            
            [[UIColor grayColor] set];
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth, reserveTopHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth, realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            CGFloat lengths[] = {1,1};
            CGContextSetLineDash(currentContext, 0, lengths, 2);
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth, realHeight - reserveBottomHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], realHeight - reserveBottomHeight);
            
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth, reserveTopHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], reserveTopHeight);
            CGContextStrokePath(currentContext);
            
            CGContextSetLineDash(currentContext, 0, nil, 0);
            
            CGContextMoveToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], reserveTopHeight);
            CGContextAddLineToPoint(currentContext, realWidth - reserveRightWidth - barChartWidth * [epsRecords count], realHeight - reserveBottomHeight);
            CGContextStrokePath(currentContext);
            
            
            NSString *zeroString = @"0.00";
            NSString *maxValueString = [NSString stringWithFormat:@"%.2f", max];
            NSString *minValueString = [NSString stringWithFormat:@"%.2f", min];
            
            if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
                
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
            }

            [zeroString drawAtPoint:CGPointMake(realWidth - reserveRightWidth + valueRightOffset, reserveTopHeight + baseZeroLineY + valueTopOffset) withAttributes:attributes];
            
            if (max > 0) {
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
            } else {
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
            }
            [maxValueString drawAtPoint:CGPointMake(realWidth - reserveRightWidth + valueRightOffset, reserveTopHeight + valueTopOffset) withAttributes:attributes];
            
            if([[[item getIdentCodeSymbol]substringToIndex:2]isEqualToString:@"TW"]){
                if (min > 0) {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                } else if(min == 0) {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                } else {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                }
            }else{
                if (min > 0) {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                } else {
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                }
            }
            
            
            
            [minValueString drawAtPoint:CGPointMake(realWidth - reserveRightWidth + valueRightOffset, realHeight - reserveBottomHeight + valueTopOffset) withAttributes:attributes];
        }
    }
    
    CGPathRelease(path);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
