//
//  CrossInfoView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/1/9.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "CrossInfoView.h"

@implementation CrossInfoView

@synthesize openLabelTitle,highLabelTitle,lowLabelTitle,closeLabelTitle,chgLabelTitle,chgPerLabelTitle,volumeLabelTitle;
@synthesize dateLabel, openLabel, highLabel, lowLabel, closeLabel,chgLabel,chgPerLabel, volumeLabel;
@synthesize viewController;
@synthesize portraitFlag;
@synthesize isCrossInfoShowing;

- (id)init {
    
    if (self = [super init]) {
        isCrossInfoShowing = YES;
        
        dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(2, 2, 120, 25)];
        dateLabel.backgroundColor = [UIColor colorWithRed:0 green:138.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
        dateLabel.textColor = [UIColor colorWithRed:1 green:250.0f/255.0f blue:160.0f/255.0f alpha:1.0f];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.hidden = YES;
        [self addSubview:dateLabel];

        
        openLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(3, 30, 44, 19)];
        openLabelTitle.text = NSLocalizedStringFromTable(@"Open", @"Draw", @"");
        openLabelTitle.textColor = [UIColor blackColor];
        openLabelTitle.hidden = YES;
        [self addSubview:openLabelTitle];
        
        highLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(3, 52, 44, 19)];
        highLabelTitle.text = NSLocalizedStringFromTable(@"High", @"Draw", @"");
        highLabelTitle.textColor = [UIColor blackColor];
        highLabelTitle.hidden = YES;
        [self addSubview:highLabelTitle];
        
        lowLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(3, 74, 44, 19)];
        lowLabelTitle.text = NSLocalizedStringFromTable(@"Low", @"Draw", @"");
        lowLabelTitle.textColor = [UIColor blackColor];
        lowLabelTitle.hidden = YES;
        [self addSubview:lowLabelTitle];
        
        closeLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(3, 96, 44, 19)];
        closeLabelTitle.text = NSLocalizedStringFromTable(@"Close", @"Draw", @"");
        closeLabelTitle.textColor = [UIColor blackColor];
        closeLabelTitle.hidden = YES;
        [self addSubview:closeLabelTitle];
        
        volumeLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(3, 162, 44, 19)];
        volumeLabelTitle.text = NSLocalizedStringFromTable(@"Volume", @"Draw", @"");
        volumeLabelTitle.textColor = [UIColor blackColor];
        volumeLabelTitle.hidden = YES;
        [self addSubview:volumeLabelTitle];
        
        openLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 30, 65, 19)];
        openLabel.adjustsFontSizeToFitWidth = YES;
        openLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:openLabel];
        
        highLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 52, 65, 19)];
        highLabel.textAlignment = NSTextAlignmentRight;
        highLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:highLabel];
        
        lowLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 74, 65, 19)];
        lowLabel.textAlignment = NSTextAlignmentRight;
        lowLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:lowLabel];
        
        closeLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 96, 65, 19)];
        closeLabel.textAlignment = NSTextAlignmentRight;
        closeLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:closeLabel];
        
        volumeLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 162, 65, 19)];
        volumeLabel.textAlignment = NSTextAlignmentRight;
        volumeLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:volumeLabel];
        
        self.chgLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(3, 118, 49, 19)];
        chgLabelTitle.text = NSLocalizedStringFromTable(@"ChgLandScape", @"Draw", @"");
        chgLabelTitle.hidden = YES;
        [self addSubview:chgLabelTitle];
        
        self.chgPerLabelTitle = [[UILabel alloc]initWithFrame:CGRectMake(3, 140, 49, 19)];
        chgPerLabelTitle.text = NSLocalizedStringFromTable(@"ChgPerLandScape", @"Draw", @"");
        chgPerLabelTitle.hidden = YES;
        [self addSubview:chgPerLabelTitle];
        
        self.chgLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 118, 65, 19)];
        chgLabel.backgroundColor = [UIColor clearColor];
        chgLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:chgLabel];
        
        self.chgPerLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 140, 65, 19)];
        chgPerLabel.adjustsFontSizeToFitWidth = YES;
        chgPerLabel.backgroundColor = [UIColor clearColor];
        chgPerLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:chgPerLabel];
        
        volumeLabel.adjustsFontSizeToFitWidth = YES;
        
        //兩檔比較
        self.stock1CloseTitle= [[UILabel alloc]initWithFrame:CGRectMake(3, 35, 35, 19)];
        _stock1CloseTitle.text = NSLocalizedStringFromTable(@"Close", @"Draw", @"");
        _stock1CloseTitle.textColor = [UIColor blueColor];
        _stock1CloseTitle.adjustsFontSizeToFitWidth = YES;
        _stock1CloseTitle.hidden = YES;
        [self addSubview:_stock1CloseTitle];
        
        self.stock1VolumeTitle= [[UILabel alloc]initWithFrame:CGRectMake(3, 57, 35, 19)];
        _stock1VolumeTitle.text = NSLocalizedStringFromTable(@"doubleStockVolume", @"Draw", @"");
        _stock1VolumeTitle.textColor = [UIColor blueColor];
        _stock1VolumeTitle.hidden = YES;
        [self addSubview:_stock1VolumeTitle];
        
        
        self.stock1Close= [[UILabel alloc]initWithFrame:CGRectMake(40, 35, 63, 19)];
        _stock1Close.textColor = [UIColor blueColor];
        _stock1Close.textAlignment = NSTextAlignmentRight;
        _stock1Close.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_stock1Close];
        
        self.stock1Volume= [[UILabel alloc]initWithFrame:CGRectMake(40, 57, 63, 19)];
        _stock1Volume.adjustsFontSizeToFitWidth = YES;
        _stock1Volume.textColor = [UIColor blueColor];
        _stock1Volume.textAlignment = NSTextAlignmentRight;
        [self addSubview:_stock1Volume];
        
        
        self.stock2CloseTitle= [[UILabel alloc]initWithFrame:CGRectMake(3, 79, 35, 19)];
        _stock2CloseTitle.text = NSLocalizedStringFromTable(@"Close", @"Draw", @"");
        _stock2CloseTitle.textColor = [UIColor brownColor];
        _stock2CloseTitle.adjustsFontSizeToFitWidth = YES;
        _stock2CloseTitle.hidden = YES;
        [self addSubview:_stock2CloseTitle];
        
        self.stock2VolumeTitle= [[UILabel alloc]initWithFrame:CGRectMake(3, 101, 35, 19)];
        _stock2VolumeTitle.text = NSLocalizedStringFromTable(@"doubleStockVolume", @"Draw", @"");
        _stock2VolumeTitle.textColor = [UIColor brownColor];
        _stock2VolumeTitle.hidden = YES;
        [self addSubview:_stock2VolumeTitle];
        
        
        self.stock2Close= [[UILabel alloc]initWithFrame:CGRectMake(40, 79, 63, 19)];
        _stock2Close.textColor = [UIColor brownColor];
        _stock2Close.adjustsFontSizeToFitWidth = YES;
        _stock2Close.textAlignment = NSTextAlignmentRight;
        [self addSubview:_stock2Close];
        
        self.stock2Volume= [[UILabel alloc]initWithFrame:CGRectMake(40, 101, 63, 19)];
        _stock2Volume.adjustsFontSizeToFitWidth = YES;
        _stock2Volume.textColor = [UIColor brownColor];
        _stock2Volume.textAlignment = NSTextAlignmentRight;
        [self addSubview:_stock2Volume];
    }
    return self;
}

//- (id)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        // Initialization code
//		
//	    openLabelTitle.text = NSLocalizedStringFromTable(@"Open", @"Draw", @"");
//		highLabelTitle.text = NSLocalizedStringFromTable(@"High", @"Draw", @"");
//		lowLabelTitle.text = NSLocalizedStringFromTable(@"Low", @"Draw", @"");
//		closeLabelTitle.text = NSLocalizedStringFromTable(@"Close", @"Draw", @"");
//		volumeLabelTitle.text = NSLocalizedStringFromTable(@"Volume", @"Draw", @"");
//        openLabelTitle.textColor = [UIColor blackColor];
//        highLabelTitle.textColor = [UIColor blackColor];
//        lowLabelTitle.textColor = [UIColor blackColor];
//        closeLabelTitle.textColor = [UIColor blackColor];
//        volumeLabelTitle.textColor = [UIColor blackColor];
//        dateLabel.textColor = [UIColor blackColor];
//    }
//    return self;
//}

-(void)setTitleStringWithType:(int)type realtimeOrHistoric:(int)chartType{
	
	// chartType 0 : 即時線圖 chartType 1 :歷史線圖
	// type 0 : 直式 , type 1 : 橫式 （目前用1）
	
	if(chartType==0) //即時
	{
		
		type = 1;
		switch (type) {
			case 0:
				openLabelTitle.text = NSLocalizedStringFromTable(@"BidString", @"Draw", @"");
				highLabelTitle.text = NSLocalizedStringFromTable(@"AskString", @"Draw", @"");
				lowLabelTitle.text = NSLocalizedStringFromTable(@"TradeString", @"Draw", @"");
				closeLabelTitle.text = NSLocalizedStringFromTable(@"ChgString", @"Draw", @"");
				volumeLabelTitle.text = NSLocalizedStringFromTable(@"VolString", @"Draw", @"");
				break;
			case 1:
				openLabelTitle.text = [NSString stringWithFormat:@"%@:",NSLocalizedStringFromTable(@"BidLandScape", @"Draw", @"")];
				highLabelTitle.text = [NSString stringWithFormat:@"%@:",NSLocalizedStringFromTable(@"AskLandScape", @"Draw", @"")];
				lowLabelTitle.text = [NSString stringWithFormat:@"%@:",NSLocalizedStringFromTable(@"PriceLandScape", @"Draw", @"")];
				closeLabelTitle.text = [NSString stringWithFormat:@"%@:",NSLocalizedStringFromTable(@"ChgLandScape", @"Draw", @"")];
				volumeLabelTitle.text = [NSString stringWithFormat:@"%@:",NSLocalizedStringFromTable(@"VolumeLandScape", @"Draw", @"")];
				break;
			default:
				break;
		}
		
	}
	else //歷史
	{
		
		type = 1;
		switch (type) {
			case 0:
				openLabelTitle.text = NSLocalizedStringFromTable(@"Open", @"Draw", @"");
				highLabelTitle.text = NSLocalizedStringFromTable(@"High", @"Draw", @"");
				lowLabelTitle.text = NSLocalizedStringFromTable(@"Low", @"Draw", @"");
				closeLabelTitle.text = NSLocalizedStringFromTable(@"Close", @"Draw", @"");
				volumeLabelTitle.text = NSLocalizedStringFromTable(@"Volume", @"Draw", @"");
				
				break;
			case 1:
				openLabelTitle.text = NSLocalizedStringFromTable(@"OpenLandScape", @"Draw", @"");
				highLabelTitle.text = NSLocalizedStringFromTable(@"HighLandScape", @"Draw", @"");
				lowLabelTitle.text = NSLocalizedStringFromTable(@"LowLandScape", @"Draw", @"");
				closeLabelTitle.text = NSLocalizedStringFromTable(@"CloseLandScape", @"Draw", @"");
				volumeLabelTitle.text = NSLocalizedStringFromTable(@"VolumeLandScape", @"Draw", @"");
				break;
			default:
				break;
		}
		
		
	}
	
	
	
	
	
}

- (void)drawRect:(CGRect)rect {
	
	if(portraitFlag)	//直式
	{
		[[UIColor blackColor] set];
		CGRect r = self.bounds;
		UIRectFrame(r);
	}
	else
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGRect bounds = self.bounds;
		CGGradientRef gradient;
		
		if (self.frame.origin.y > 1) {
			
			[[UIColor redColor] set];
			UIRectFill(CGRectMake(0, 0, bounds.size.width, 1));
			
			const CGFloat locations[] = { 0, 0.45, 1 };
			const CGFloat components[] = { 0.58, 0.60, 0.64, 1,
				0.31, 0.33, 0.38, 1,
			0.21, 0.23, 0.27, 1, };
			gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 3);
			CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 1), CGPointMake(0, bounds.size.height), 0);
		}
		else {
			
			[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1] set];
			UIRectFill(CGRectMake(0, bounds.size.height-1, bounds.size.width, bounds.size.height-1));
			
			const CGFloat locations[] = { 0, 1 };
			const CGFloat components[] = { 0.42, 0.44, 0.48, 1,
			0.21, 0.23, 0.27, 1, };
			gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
			CGContextDrawLinearGradient(context, gradient, CGPointMake(0, bounds.size.height-1), CGPointMake(0, 0), 0);
		}
		
		CGGradientRelease(gradient);
		CGColorSpaceRelease(colorspace);
	}
	
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    [(NSObject<CrollInfoProtocol> *)viewController openCrossView:NO];
}
@end
