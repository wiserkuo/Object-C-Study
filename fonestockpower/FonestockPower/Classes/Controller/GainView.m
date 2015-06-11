//
//  GainView.m
//  FonestockPower
//
//  Created by Neil on 2014/7/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "GainView.h"

@implementation GainView

- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset{
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		_chartFrame = frame;
		_chartFrameOffset = offset;
        _dataDictionary = [[NSMutableDictionary alloc]init];

	}
	
	return self;
}

- (void)getValueWithIndex:(int)index Value1:(double*)value1 Value2:(double*)value2 Value3:(double*)value3{
	double gain = -0.0;
    UInt8 type = 'D';
    
    for (int i=0; i<index; i++) {
        DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:index-i];
        NSMutableDictionary * dict = [_dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:historic.date]];
        if (dict) {
            float totalBuy = [(NSNumber *)[dict objectForKey:@"totalBuy"] floatValue];
            float totalSell = [(NSNumber *)[dict objectForKey:@"totalSell"] floatValue];
            float count = [(NSNumber *)[dict objectForKey:@"count"] floatValue];
            float v = 0;
            if (_status) {
                v = (historic.close * count + totalSell) / totalBuy;
                gain = v - 1;
            }else{
                v = 1 - ((historic.close * count + totalSell) / totalBuy);
                gain = v;
            }
            break;
        }
    }
    
	*value1 = gain;
	*value2 = 0;
	*value3 = 0;
}

- (void)drawRect:(CGRect)rect
{
    _status = _drawAndScrollController.status;
    _dataDictionary  = _drawAndScrollController.gainDateDictionary;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    _chartFrameOffset = _drawAndScrollController.chartFrameOffset;
    //畫虛線
    [_drawAndScrollController drawMonthLineWithChartFrame:_chartFrame xLines:_xLines offsetStartPoint:_chartFrameOffset];
    
    float chartWidth = _chartFrame.size.width;
    float chartHeight = _chartFrame.size.height;
    
    [_drawAndScrollController drawBottomChartFrameWithOffset:_chartFrameOffset frameWidth:chartWidth frameHeight:chartHeight];
    
    float viewHeight = self.frame.size.height/4.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor lightGrayColor] set];
    CGFloat length[]={2,1};
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, length, 1);
    for (int i=1; i<4; i++) {
        
        CGContextMoveToPoint(context, 0, i*viewHeight);
        CGContextAddLineToPoint(context, self.frame.size.width, i*viewHeight);
        
    }
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0, NULL, 0);
    
    float xSize = _drawAndScrollController.indexScaleView.frame.size.width;
    float ySize = _drawAndScrollController.indexScaleView.frame.size.height;
    ySize -=1;
    float winLocationX;
    if(xSize<273)
        winLocationX = 0;
    else
        winLocationX = _drawAndScrollController.indexScaleView.frame.origin.x;
    
    
    NSInteger dataStartIndex = [self getSeqNumberFromPointXValue:winLocationX];
    NSInteger dataEndIndex = [self getSeqNumberFromPointXValue:winLocationX+xSize-1];
    
    _maxValue = -MAXFLOAT;
    _minValue = MAXFLOAT;
    
    UInt8 type = 'D';
    
    float totalBuy = 0;
    float totalSell = 0;
    float count = 0;
    
    for (NSInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:(int)i];
        if ([_dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:historic.date]]!=nil) {
            dict = [_dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:historic.date]];
            totalBuy = [(NSNumber *)[dict objectForKey:@"totalBuy"] floatValue];
            totalSell = [(NSNumber *)[dict objectForKey:@"totalSell"] floatValue];
            count = [(NSNumber *)[dict objectForKey:@"count"] floatValue];
            float v = 0;
            if (_status) {
                v = (historic.close * count + totalSell) / totalBuy;
                v = v - 1;
            }else{
                v = 1 - ((historic.close * count + totalSell) / totalBuy);
            }
            _maxValue = MAX(_maxValue, v);
            _minValue = MIN(_minValue, v);
        }
    }
    
    float amp = _maxValue - _minValue;
    if (amp == 0) return;
    
    float x, y, v, oldV =0;
    BOOL first = TRUE;
    float xScale = chartWidth / _xLines;
    float x0 = _chartFrameOffset.x;// + _drawAndScrollController.chartBarWidth / 2;
    float yScale = chartHeight / amp;
    float y0 = _chartFrameOffset.y + chartHeight;
    float totalBuyv = 0;
    float totalSellv= 0;
    float countv = 0;
    
    CGContextSetLineWidth(context, _drawAndScrollController.bottomChartLineWidth);
    
    CGMutablePathRef gainPath = CGPathCreateMutable();
    for (NSUInteger i = dataStartIndex; i <= dataEndIndex; i++) {
        
        DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:(int)i];
        if ([_dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:historic.date]]!=nil) {
            dict = [_dataDictionary objectForKey:[NSNumber numberWithUnsignedInt:historic.date]];
            totalBuyv = [(NSNumber *)[dict objectForKey:@"totalBuy"] floatValue];
            totalSellv = [(NSNumber *)[dict objectForKey:@"totalSell"] floatValue];
            countv = [(NSNumber *)[dict objectForKey:@"count"] floatValue];
            if (_status) {
                if (totalBuy == 0) {
                    v = 0;
                }else{
                    v = (historic.close * countv + totalSellv) / totalBuyv;
                    v = v - 1;
                }
            }else{
                if (totalBuy == 0) {
                    v = 0;
                }else{
                    v = 1 - ((historic.close * countv + totalSellv) / totalBuyv);
                }
            }
            x = x0 + i * xScale;
            y = y0 - (v - _minValue) * yScale;
            
            if (first) {
                CGPathMoveToPoint(gainPath, NULL, x, y);
                first = FALSE;
            }
            
            CGPathAddLineToPoint(gainPath, NULL, x, y);
            oldV = v;
        }
    }
        

    [[UIColor magentaColor] set];
    CGContextAddPath(context, gainPath);
    CGContextStrokePath(context);
    CGPathRelease(gainPath);

}

-(int)getSeqNumberFromPointXValue:(float)x
{
	
    UInt32 histCount = [_historicData tickCount:self.drawAndScrollController.historicType];
    if (histCount == 0) return -1;
	
    float xScale = _drawAndScrollController.barDateWidth;
    int x0 =0;// offsetX;
    int n = x > x0 ? (x - x0) / xScale : 0;
	
    if (n >= histCount)
		n = histCount - 1;
    
	return n;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [_bottonView doTouchesBegan:touches withEvent:event];
}

@end
