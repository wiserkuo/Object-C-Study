//
//  UpperDateView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/9.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "UpperDateView.h"
#import "IndexView.h"


@implementation UpperDateView

@synthesize drawAndScrollController;
@synthesize dateLabels;
@synthesize zoomTransform;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        dateLabels = [[NSMutableArray alloc] init];
		dateLabelInfoDict = [[NSMutableDictionary alloc] init];
        dataLock = [[NSRecursiveLock alloc]init];
    }
    return self;
}


- (void)drawRect:(CGRect)rect 
{
}


- (UILabel *)labelAtIndex:(int)index {

    UILabel *label;

    if (index < dateLabels.count) {
        label = [dateLabels objectAtIndex:index];
    }
    else {
        label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"Arial" size:12];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        [dateLabels addObject:label];
    }

    if (![label isDescendantOfView:self])
        [self addSubview:label];

    return label;
}

- (int)indexOnLabel:(UILabel *)targetLabel{
	
	int index = -1;
	for(UILabel *label in dateLabels)
	{
		
		index++;
		
		if(targetLabel == label)
			return index;
		else
			continue;
	
	}
	
	return -1;

}


- (void)removeExtraLabels:(int)index {

    UILabel *label;

    for ( ; index < dateLabels.count; index++) {

        label = [dateLabels objectAtIndex:index];
        if ([label isDescendantOfView:self])
            [label removeFromSuperview];
    }
}


- (void)resetLabelTransform {
    [dataLock lock];
    CGAffineTransform transform = CGAffineTransformMakeScale(1/self.transform.a, 1);
    CGRect frame;
    if (dateLabels) {
        for (UILabel *label in dateLabels) {
            
            frame.origin = label.frame.origin;
            label.transform = transform;
            
            frame.size = label.frame.size;
            label.frame = frame;
        }
    }

    [dataLock unlock];
}


- (void)updateLabels {

    id<HistoricTickDataSourceProtocol> historicData = drawAndScrollController.historicData;
    UInt8 type = drawAndScrollController.historicType;
    UInt32 histCount = [historicData tickCount:type];

    if (histCount == 0) {
	
        for (UILabel *label in dateLabels) {
            if ([label isDescendantOfView:self])
                [label removeFromSuperview];
        }
       return;
    }

    int i;
    float x;
    UILabel *label;

    IndexView *indexView = drawAndScrollController.indexView;
    float xOrigin = indexView.chartFrameOffset.x;
    float xScale = indexView.chartFrame.size.width / indexView.xLines;
    float y = -3;//1.5;
    float w = 21;
    float h = 18;

	//日線擺每個月第一天
    if (drawAndScrollController.analysisPeriod == AnalysisPeriodDay) {

        NSCalendar *calendar = [DrawAndScrollController sharedGregorianCalendar];
        NSDate *todayDate = [drawAndScrollController setTodayDate];
        NSDate *oldesetDate = [drawAndScrollController getOldestDate];
        NSMutableArray *firstDateDateArray = [drawAndScrollController getMonthArrayFromTodayDate:todayDate toOldestDate:oldesetDate];
        NSDate *date;
        int index;

		[dateLabelInfoDict removeAllObjects];
		
		//int rangeNewsCount = 0;
        for (i = 0; i < firstDateDateArray.count; i++)  //array index第一筆為最近的日期 , index愈大日期愈古老
		{
			
            date = [firstDateDateArray objectAtIndex:i];
			
			/*
			if(i==0)
			{
				//區間內最近的日期
				UInt16 endDate =  [ValueUtil stkDateFromNSDate:todayDate];
				
				//區間內最古的日期
				NSDate *startNSDate = [firstDateDateArray objectAtIndex:i];
				UInt16 startDate = [ValueUtil stkDateFromNSDate:startNSDate];
				
				rangeNewsCount = [[DataModalProc getDataModal].informationMine getNewsCountByStartDate:startDate endDate:endDate];
				if(rangeNewsCount > 0)
				{
					NSMutableDictionary *dateDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:(int)startDate],@"startDate",[NSNumber numberWithInt:(int)endDate],@"endDate",nil];
					[dateLabelInfoDict setObject:dateDict forKey:[NSNumber numberWithInt:i]];
					[dateDict release];
				}
				
			}
			else if(i < (firstDateDateArray.count - 1))
			{
				
				//區間內最近的日期
				NSDate *endNSDate = [firstDateDateArray objectAtIndex:i-1];
				UInt16 endDate = [ValueUtil stkDateFromNSDate:endNSDate]-1;
				
				//區間內最古的日期
				NSDate *startNSDate = date;
				UInt16 startDate =  [ValueUtil stkDateFromNSDate:startNSDate];
				
				rangeNewsCount = [[DataModalProc getDataModal].informationMine getNewsCountByStartDate:startDate endDate:endDate];				
				if(rangeNewsCount > 0)
				{
					NSMutableDictionary *dateDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:(int)startDate],@"startDate",[NSNumber numberWithInt:(int)endDate],@"endDate",nil];
					[dateLabelInfoDict setObject:dateDict forKey:[NSNumber numberWithInt:i]];
					[dateDict release];
				}
				
			
			}
			else if(i == firstDateDateArray.count-1)
			{
				
				//區間內最近的日期
				NSDate *endNSDate = [firstDateDateArray objectAtIndex:i-1];				
				UInt16 endDate = [ValueUtil stkDateFromNSDate:endNSDate]-1;
				
				//區間內最古的日期
				UInt16 startDate = [ValueUtil stkDateFromNSDate:date];
				
				rangeNewsCount = [[DataModalProc getDataModal].informationMine getNewsCountByStartDate:startDate endDate:endDate];
				if(rangeNewsCount > 0)
				{
					NSMutableDictionary *dateDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:(int)startDate],@"startDate",[NSNumber numberWithInt:(int)endDate],@"endDate",nil];
					[dateLabelInfoDict setObject:dateDict forKey:[NSNumber numberWithInt:i]];
					[dateDict release];
				}
				
			}
			*/
			
	
            index = [drawAndScrollController scaleLocationIndexValueFromDate:date ordestDate:oldesetDate];

            x = xOrigin + xScale * index;

            label = [self labelAtIndex:i];
			[self bringSubviewToFront:label];
			label.userInteractionEnabled = YES;
			
			label.frame = CGRectMake(x-1, y, w+20, h); //日線寬度拉大
			
			//if(rangeNewsCount > 0)				
				//label.text = [NSString stringWithFormat:@"%02d %@", [calendar components:NSMonthCalendarUnit fromDate:date].month,@"*"];
			//else
				label.text = [NSString stringWithFormat:@"%d", (int)[calendar components:NSMonthCalendarUnit fromDate:date].month];
			
			/*
			if(rangeNewsCount > 0)
			{
				UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"news-small.png"]];
				imgView.frame = CGRectMake(x-1+w/2, 0, 18, 18);
				[self addSubview:imgView];
				[imgView release];
			}
			*/
        }


        [self removeExtraLabels:i];
    }
	
	
	// others : 除日線以外 
    else {

        CGRect r;
        NSString *str;
        CGSize size;
        UIFont *font = [UIFont fontWithName:@"Arial" size:11];
        float boundWidth = self.bounds.size.width;
        float scaleFactor = drawAndScrollController.chartZoomOrigin * self.transform.a;
        float x0 = 0;
        int index = 0;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{ NSFontAttributeName: font,
                                      NSParagraphStyleAttributeName: paragraphStyle };

        switch (drawAndScrollController.analysisPeriod) {
            case AnalysisPeriodDay:
                break;
            case AnalysisPeriodWeek:
            {
                
                BOOL isWeek = drawAndScrollController.analysisPeriod == AnalysisPeriodWeek;
                int bitOffset = isWeek ? 5 : 9;
                int date;
                
                DecompressedHistoricData *hist = [historicData copyHistoricTick:type sequenceNo:0];
                int prevDate = (hist.date >> bitOffset)& 0xF;
                if (prevDate>=1 && prevDate<=3) {
                    prevDate=1;
                }else if (prevDate>=4 && prevDate<=6){
                    prevDate = 4;
                }else if (prevDate>=7 && prevDate<=9){
                    prevDate = 7;
                }else if (prevDate>=10 && prevDate<=12){
                    prevDate = 10;
                }
                
                for (int i = 1; i < histCount; i++) {
                    
                    hist = [historicData copyHistoricTick:type sequenceNo:i];
                    date = (hist.date >> bitOffset)& 0xF;
                    if (date>=1 && date<=3) {
                        date=1;
                    }else if (date>=4 && date<=6){
                        date = 4;
                    }else if (date>=7 && date<=9){
                        date = 7;
                    }else if (date>=10 && date<=12){
                        date = 10;
                    }
                    
                    if (prevDate != date) {
                        
                        prevDate = date;
                        x = xOrigin + xScale * i;
                        r = CGRectMake(x-1, y, w, h);
                        str = [NSString stringWithFormat:@"%d", date];
                        
                        
                        size = [str  boundingRectWithSize:r.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                        
                        size.width *= scaleFactor;
                        
                        if (r.origin.x <= x0 && r.origin.x >= x0-1)
                            r.origin.x = x0+1;
                        
                        x = boundWidth - size.width;
                        if (r.origin.x > x)
                            r.origin.x = x;
                        
                        if (r.origin.x > x0) {
                            label = [self labelAtIndex:index++];
                            label.text = str;
							label.frame = r;
							x0 = r.origin.x + size.width;
                            
                            
                        }
                    }
                }
                break;
            }
            case AnalysisPeriodMonth: {

                BOOL isWeek = drawAndScrollController.analysisPeriod == AnalysisPeriodWeek;
                int bitOffset = isWeek ? 5 : 9;
                int date;

                DecompressedHistoricData *hist = [historicData copyHistoricTick:type sequenceNo:0];
                int prevDate = hist.date >> bitOffset;

                for (int i = 1; i < histCount; i++) {

                    hist = [historicData copyHistoricTick:type sequenceNo:i];
                    date = hist.date >> bitOffset;

                    if (prevDate != date) {

                        prevDate = date;
                        x = xOrigin + xScale * i;
                        r = CGRectMake(x-1, y, w, h);
                        str = [NSString stringWithFormat:@"%d", isWeek ? date&0xF : (date+1960)%100];

                        size = [str  boundingRectWithSize:r.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                        size.width *= scaleFactor;

                        if (r.origin.x <= x0 && r.origin.x >= x0-1)
                            r.origin.x = x0+1;

                        x = boundWidth - size.width;
                        if (r.origin.x > x)
                            r.origin.x = x;

                        if (r.origin.x > x0) {
                            label = [self labelAtIndex:index++];
                            label.text = str;
							label.frame = r;
							x0 = r.origin.x + size.width;
				 
                            
                        }
                    }
                }
                break;
            }

            case AnalysisPeriod5Minute:
            {
                DecompressedHistoric5Minute *hist5Min;
                int date, time;
                int prevDate = 0, prevTime = 0;
				int m = 5;
				if(drawAndScrollController.analysisPeriod == AnalysisPeriod15Minute) m = 15;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod30Minute) m = 30;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod60Minute) m = 60;
                
                for (int i = 0; i < histCount; i++) {
                    
                    hist5Min = [historicData copyHistoricTick:type sequenceNo:i];
                    date = hist5Min.date;
                    time = hist5Min.time;
                    
                    if (prevDate != date || prevTime/60 != time/60) {
                        
//                        if (!(prevDate != date && time%60 > m)) {
                        
                            x = xOrigin + xScale * i;
                            r = CGRectMake(i==0?x+0.5:x-1, y, w, h);
                            str = [NSString stringWithFormat:@"%d", time/60];
                            
                            size = [str  boundingRectWithSize:r.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                            size.width *= scaleFactor;
                            
                            x = boundWidth - size.width;
                            if (r.origin.x > x)
                                r.origin.x = x;
                            
                            if (r.origin.x > x0) {
                                label = [self labelAtIndex:index++];
                                label.text = str;
								label.frame = r;
								x0 = r.origin.x + size.width;
								
                                
//                            }
                        }
                        
                        prevDate = date;
                        prevTime = time;
                    }
                }
                break;
            }
			case AnalysisPeriod15Minute:
            {
                DecompressedHistoric5Minute *hist5Min;
                int date, time;
                int prevDate = 0, prevTime = 0;
				int m = 5;
				if(drawAndScrollController.analysisPeriod == AnalysisPeriod15Minute) m = 15;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod30Minute) m = 30;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod60Minute) m = 60;
                int hr=0;
                for (int i = 0; i < histCount; i++) {
                    
                    hist5Min = [historicData copyHistoricTick:type sequenceNo:i];
                    date = hist5Min.date;
                    time = hist5Min.time;
                    
                    if (prevDate != date || prevTime/60 != time/60) {
                        
                        //if (!(prevDate != date && time%60 > m)) {
                            
                            if (hr==2 || prevDate != date) {
                                x = xOrigin + xScale * i;
                                r = CGRectMake(i==0?x+0.5:x-1, y, w, h);
                                str = [NSString stringWithFormat:@"%d", time/60];
                            
                                size = [str  boundingRectWithSize:r.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                                size.width *= scaleFactor;
                            
                                x = boundWidth - size.width;
                                if (r.origin.x > x)
                                    r.origin.x = x;
                            
                                if (r.origin.x > x0) {
                                    label = [self labelAtIndex:index++];
                                    label.text = str;
                                    label.frame = r;
                                    x0 = r.origin.x + size.width;

                                }
                                hr=0;
                            }else{
                                hr+=1;
                            }
                        //}
                        
                        prevDate = date;
                        prevTime = time;
                    }
                }
                break;
            }
            case AnalysisPeriod30Minute:
            {
                DecompressedHistoric5Minute *hist5Min;
                int date, time;
                int prevDate = 0, prevTime = 0;
				int m = 5;
				if(drawAndScrollController.analysisPeriod == AnalysisPeriod15Minute) m = 15;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod30Minute) m = 30;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod60Minute) m = 60;
                
                for (int i = 0; i < histCount; i++) {
                    
                    hist5Min = [historicData copyHistoricTick:type sequenceNo:i];
                    date = hist5Min.date;
                    time = hist5Min.time;
                    
                    if (prevDate != date) {
                        
//                        if (!(prevDate != date && time%60 > m)) {
                        
                            x = xOrigin + xScale * i;
                            r = CGRectMake(i==0?x+0.5:x-1, y, w, h);
                            str = [NSString stringWithFormat:@"%d",(date & 0x1F)];
                            
                            size = [str  boundingRectWithSize:r.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                            size.width *= scaleFactor;
                            
                            x = boundWidth - size.width;
                            if (r.origin.x > x)
                                r.origin.x = x;
                            
                            if (r.origin.x > x0) {
                                label = [self labelAtIndex:index++];
                                label.text = str;
								label.frame = r;
								x0 = r.origin.x + size.width;
								
                                
                            }
//                        }
                        
                        prevDate = date;
                        prevTime = time;
                    }
                }
                break;
            }
			case AnalysisPeriod60Minute:
			{
                DecompressedHistoric5Minute *hist5Min;
                int date, time;
                int prevDate = 0, prevTime = 0;
				int m = 5;
				if(drawAndScrollController.analysisPeriod == AnalysisPeriod15Minute) m = 15;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod30Minute) m = 30;
				else if(drawAndScrollController.analysisPeriod == AnalysisPeriod60Minute) m = 60;
//                DecompressedHistoricData *hist = [historicData copyHistoricTick:type sequenceNo:0];
//                prevDate = hist.date;
                BOOL day = NO;//兩天加一數值
                for (int i = 0; i < histCount; i++) {

                    hist5Min = [historicData copyHistoricTick:type sequenceNo:i];
                    date = hist5Min.date;
                    time = hist5Min.time;

                    if (prevDate != date) {

//                        if (!(prevDate != date && time%60 > m)) {
                        if (day) {
                            day=NO;
                        }else{
                            x = xOrigin + xScale * i;
                            r = CGRectMake(i==0?x+0.5:x-1, y, w, h);
                            str = [NSString stringWithFormat:@"%d", (date & 0x1F)];

                            size = [str  boundingRectWithSize:r.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
                            size.width *= scaleFactor;

                            x = boundWidth - size.width;
                            if (r.origin.x > x)
                                r.origin.x = x;

                            if (r.origin.x > x0) {
                                label = [self labelAtIndex:index++];
                                label.text = str;
								label.frame = r;
								x0 = r.origin.x + size.width;
								
                               
                            }
                            day = YES;

                        }
//                        }

                        prevDate = date;
                        prevTime = time;
                    }
                }
                break;
            }
        }

        [self removeExtraLabels:index];
    }

    if (!CGAffineTransformIsIdentity(zoomTransform)) {
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self resetLabelTransform];
        zoomTransform = CGAffineTransformIdentity;
    }
}


- (void)adjustForOrientation:(BOOL)isLandscape {

    CGFloat fontSize = isLandscape ? 14 : 11;
    UIFont *font = [UIFont fontWithName:@"Arial" size:fontSize];
    CGRect r;

    for (UILabel *label in dateLabels) {
        r = label.frame;
        r.size.height = fontSize;
        label.frame = r;
        label.font = font;
    }
}

/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	targetView = [super hitTest:point withEvent:event];
	
	if([targetView isKindOfClass:[UILabel class]])
	{
		int labelIndex = [self indexOnLabel:targetView];
		
		if(labelIndex == -1)
			return self;
		
		NSMutableDictionary *dateDict = [dateLabelInfoDict objectForKey:[NSNumber numberWithInt:labelIndex]];
		if(dateDict)
		{
			
			UInt16 startDate = [(NSNumber *)[dateDict objectForKey:@"startDate"]intValue];
			UInt16 endDate = [(NSNumber *)[dateDict objectForKey:@"endDate"]intValue];
			
			if(startDate == 0 || endDate == 0)
				return self;
			
			[drawAndScrollController openInformationNewsTitleViewControllerByStartDate:startDate endDate:endDate];	
			
		
		}
		
	}
	
	return self;	
	
}
 */


@end
