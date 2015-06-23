//
//  BottomDataView.m
//  Bullseye
//
//  Created by Ray Kuo on 2008/12/29.
//  Copyright 2008 TelePaq Inc. All rights reserved.
//

#import "BottomDataView.h"
#import "BottonView.h"
#import "ValueUtil.h"
#import "MACDView.h"
#import "VolumeView.h"
#import "OBVView.h"
#import "OscillatorView.h"
#import "MomentumView.h"
#import "BiasView.h"
#import "OBVView.h"
#import "MACDView.h"
#import "VRView.h"
#import "ARBRView.h"
#import "DMIView.h"
#import "TowerView.h"
#import "GainView.h"
#import "FSInstantInfoWatchedPortfolio.h"

#define IS_IPAD [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound
@interface BottomDataView(){
    NSInteger currentStatus;
    NSInteger lastStatus;
    BOOL isGain;
}
@end

@implementation BottomDataView

@synthesize drawAndScrollController;
@synthesize bottonView;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        dataLock = [[NSRecursiveLock alloc]init];
    }
    return self;
}


- (void)drawGridValue:(NSString *)str atY:(float)y withSize:(CGSize)size xOffset:(float)xOffset {

    UIFont *font = [UIFont fontWithName:@"Arial" size:11];
    CGRect frame = bottonView.dataScrollView.frame;
    

    float x = frame.origin.x + frame.size.width + 1;
//    UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
    x += 1.6;

    CGRect r = CGRectMake(x+xOffset, y-size.height/2, size.width, size.height);
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    paragraphStyle.alignment = NSTextAlignmentRight;
    if((int)bottonView.subDataViewsIndex==BottomViewAnalysisTypeOBV){
        paragraphStyle.alignment = NSTextAlignmentLeft;
    }
    NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor],
                                  NSParagraphStyleAttributeName: paragraphStyle };
//    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
    
    [str drawInRect:r withAttributes:attributes];
}


- (void)gridValueSize:(CGSize *)size fromString:(NSString *)str {

    UIFont *font = [UIFont fontWithName:@"Arial" size:11];
    CGRect frame = bottonView.dataScrollView.frame;

    float x = frame.origin.x + frame.size.width + 1 + 1.6;
    float w = self.bounds.size.width - x;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle };

//    CGSize s = [str sizeWithFont:font constrainedToSize:CGSizeMake(w-3, 11.8) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize s = [str boundingRectWithSize:CGSizeMake(w-3, 11.8) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;

    if ((*size).width < s.width)
        *size = s;
}


- (NSString *)titleForAnalysisType:(AnalysisType)type {
    
    NSString * period;
    NSString *titleString;
    
    if (drawAndScrollController.analysisPeriod==AnalysisPeriodDay) {
        period = @"dayLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodWeek){
        period = @"weekLine";
    }else if (drawAndScrollController.analysisPeriod==AnalysisPeriodMonth){
        period = @"monthLine";
    }else {
        period = @"minuteLine";
    }
	
    //if (type==AnalysisTypeKDJ) {
//        titleString = [NSString stringWithFormat:@"%d",[[DataModalProc getDataModal].indicator getValueInNewIndicatorByParameter:@"KD" Period:period]];
//    }else{
        titleString = [[[FSDataModelProc sharedInstance]indicator] newIndicatorNameAndParameterByAnalysisType:type Period:period];
    //}
	

    
	
	return titleString;
}


- (void)drawRect:(CGRect)rect {
    [dataLock lock];
    
    PortfolioItem * portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1);
	[[UIColor blackColor] set];

    CGRect bounds = self.bounds;
	//UIRectFrame(bounds);

    UIScrollView *scrollView = bottonView.dataScrollView;

    float chartWidth = scrollView.frame.size.width;
    float chartHeight = bottonView.subViewChartFrame.size.height;

    float x = scrollView.frame.origin.x + chartWidth + 1;
    float y = scrollView.frame.origin.y + bottonView.subViewChartFrameOffset.y;
    
    float title1Location;
    float title2Location;
    float title2_2Location;
    float title3Location;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        title1Location = 3;
        title2Location = 130;
        title2_2Location = 100;
        title3Location = 190;
    }else{
        
        title1Location = 3;
        title2Location = 240;
        title2_2Location = 140;
        title3Location = 280;

    }

// 畫chart frame邊框
    UIRectFrame(CGRectMake(-1, y-1, x+1, chartHeight+2));

// 顯示指標名稱
    UIFont *font = [UIFont fontWithName:@"Arial" size:9];
    NSDictionary *attributes;// = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
    NSString *str = @"";
    switch (bottonView.subDataViewsIndex) {
        case BottomViewAnalysisTypePSY:
        case BottomViewAnalysisTypeVR:
        case BottomViewAnalysisTypeWR:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [[self titleForAnalysisType:(int)bottonView.subDataViewsIndex] stringByAppendingString:@":"];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeRSI:
           attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [[self titleForAnalysisType:AnalysisTypeRSI1] stringByAppendingString:@":"];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [[self titleForAnalysisType:AnalysisTypeRSI2] stringByAppendingString:@":"];
//            [str drawAtPoint:CGPointMake(130, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeKDJ:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [[self titleForAnalysisType:AnalysisTypeKDJ] stringByAppendingString:@"K:"];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [[self titleForAnalysisType:AnalysisTypeKDJ] stringByAppendingString:@"D:"];
//            [str drawAtPoint:CGPointMake(100, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2_2Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor orangeColor]};
            str = [[self titleForAnalysisType:AnalysisTypeKDJ] stringByAppendingString:@"J:"];
//            [str drawAtPoint:CGPointMake(190, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title3Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeVOL:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [[self titleForAnalysisType:AnalysisTypeAVS] stringByAppendingString:@":"];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [[self titleForAnalysisType:AnalysisTypeAVL] stringByAppendingString:@":"];
//            [str drawAtPoint:CGPointMake(130, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeMACD:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [[self titleForAnalysisType:AnalysisTypeMACD] stringByAppendingString:@"D:"];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [[self titleForAnalysisType:AnalysisTypeMACD] stringByAppendingString:@"M:"];
//            [str drawAtPoint:CGPointMake(100, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2_2Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor orangeColor]};
            str = @"D-M:";
//            [str drawAtPoint:CGPointMake(190, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title3Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeBias:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [[self titleForAnalysisType:AnalysisTypeBias] stringByAppendingString:@":"];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeOBV:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [[self titleForAnalysisType:AnalysisTypeOBV] stringByAppendingString:@":"];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeMTM:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [NSString stringWithFormat:@"%@%@:",@"MTM",[self titleForAnalysisType:AnalysisTypeMTM]];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [NSString stringWithFormat:@"%@%@:",@"MA",[self titleForAnalysisType:AnalysisTypeMTM]];
//            [str drawAtPoint:CGPointMake(130, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeOSC:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [NSString stringWithFormat:@"%@%@:",@"OSC",[self titleForAnalysisType:AnalysisTypeOSC]];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [NSString stringWithFormat:@"%@%@:",@"MA",[self titleForAnalysisType:AnalysisTypeOSC]];
//            [str drawAtPoint:CGPointMake(130, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeARBR:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [NSString stringWithFormat:@"%@%@:",@"AR",[self titleForAnalysisType:AnalysisTypeAR]];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [NSString stringWithFormat:@"%@%@:",@"BR",[self titleForAnalysisType:AnalysisTypeBR]];
//            [str drawAtPoint:CGPointMake(130, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeDMI:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = [NSString stringWithFormat:@"%@%@:",@"+DI",[self titleForAnalysisType:AnalysisTypeDMI]];
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = [NSString stringWithFormat:@"%@%@:",@"-DI",[self titleForAnalysisType:AnalysisTypeDMI]];
//            [str drawAtPoint:CGPointMake(100, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2_2Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor orangeColor]};
            str = [NSString stringWithFormat:@"%@%@:",@"ADX",[self titleForAnalysisType:AnalysisTypeDMI]];
//            [str drawAtPoint:CGPointMake(190, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title3Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeTower:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = @"OPEN:";
//            [str drawAtPoint:CGPointMake(3, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.4 green:0.7 blue:1 alpha:1]};
            str = @"CLOSE:";
//            [str drawAtPoint:CGPointMake(130, 1) withFont:font];
            [str drawAtPoint:CGPointMake(title2Location, 1) withAttributes:attributes];
            break;
        case BottomViewAnalysisTypeGain:
            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor magentaColor]};
            str = NSLocalizedStringFromTable(@"Gain:", @"Draw", nil);;
            [str drawAtPoint:CGPointMake(title1Location, 1) withAttributes:attributes];
            break;
        default:
            [[UIColor colorWithRed:0.45 green:1 blue:0.45 alpha:1] set];
    }
    
// 標Y軸刻度(指標數值)
    if ([drawAndScrollController.historicData tickCount:drawAndScrollController.historicType] > 0) {

        CGRect r;
        float y0 = y + chartHeight;
        float w = bounds.size.width - x;
        float h = 11.8;
        int yLines = bottonView.yLines;
        int chartType = (int)bottonView.subDataViewsIndex;
        float titleLabelWidth = 45;
        if(IS_IPAD)
            titleLabelWidth = UIInterfaceOrientationIsPortrait(drawAndScrollController.interfaceOrientation)?45 : 38;//w;//45;
        else
            titleLabelWidth = w;
        float titleLabelOffsetDown = 0;
        
        if(currentStatus==0){
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x - 0.5, titleLabelOffsetDown, titleLabelWidth, 13)];
            [self addSubview:titleLabel];
            titleLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont systemFontOfSize:10.0f];
            titleLabel.textAlignment = NSTextAlignmentCenter;
        }
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            currentStatus = 1;
        }else{
            currentStatus = 2;
        }
        
        if(currentStatus == lastStatus){
            [titleLabel setFrame:CGRectMake(x - 0.5, titleLabelOffsetDown, titleLabelWidth, 13)];
        }else{
            //[titleLabel removeFromSuperview];
            //titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x - 0.5, titleLabelOffsetDown, titleLabelWidth, 13)];
            titleLabel.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:140.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont systemFontOfSize:10.0f];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            //[self addSubview:titleLabel];
        }
        lastStatus = currentStatus;

        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor],NSParagraphStyleAttributeName: paragraphStyle};
        float maxV = 100,minV = 0;
        id view = [bottonView.subDataViews objectAtIndex:chartType];
        int n = yLines / 2,index=0;
        float v = 0,value;
        CGSize size = CGSizeZero;
        NSMutableArray *texts = [[NSMutableArray alloc] init];
        BottomViewAnalysisType a = chartType;
        switch (a) {

            case BottomViewAnalysisTypeRSI:{
                titleLabel.text = NSLocalizedStringFromTable(@"RSI", @"Draw", nil);
                int rsi=0;
                for (int i = 2; i < yLines-1; i += 2) {
                    
                    y = y0 - chartHeight * i / yLines;
                    //r = CGRectMake(x+w*0.12, y-h/2, w*0.88, h);
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    rsi+=25;
                    str = [NSString stringWithFormat:@"%d",rsi];
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    
                    //                    UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
            case BottomViewAnalysisTypePSY:{
                titleLabel.text = NSLocalizedStringFromTable(@"PSY", @"Draw", nil);
                int a=0;
                for (int i = 2; i < yLines-1; i += 2) {
                    
                    y = y0 - chartHeight * i / yLines;
                    //r = CGRectMake(x+w*0.12, y-h/2, w*0.88, h);
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    a+=25;
                    str = [NSString stringWithFormat:@"%d",a];
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    
                    //                    UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
            case BottomViewAnalysisTypeWR:{
                if(IS_IPAD)
                    titleLabel.font = [UIFont systemFontOfSize:9.5f];
                titleLabel.text = NSLocalizedStringFromTable(@"Williams", @"Draw", nil);
                int wrNum = 100;
                for (int i = 2; i <= yLines-1; i += 2) {
                    
                    y = y0 - chartHeight * i / yLines;
                    //r = CGRectMake(x+w*0.12, y-h/2, w*0.88, h);
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    wrNum -=25;
//                    float v = chartType == AnalysisTypeWR ? yLines - i : i;
                    str = [NSString stringWithFormat:@"%d",wrNum];
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    //                    UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
            case BottomViewAnalysisTypeKDJ:{
                titleLabel.text = NSLocalizedStringFromTable(@"KDJ", @"Draw", nil);
                int kdj=0;
                for (int i = 2; i < yLines-1; i += 2) {
                    
                    y = y0 - chartHeight * i / yLines;
                    //r = CGRectMake(x+w*0.12, y-h/2, w*0.88, h);
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    kdj+=25;
                    str = [NSString stringWithFormat:@"%d",kdj];
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    //UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
			case BottomViewAnalysisTypeVR:{
				titleLabel.text = NSLocalizedStringFromTable(@"VR", @"Draw", nil);
                VRView * vrView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                maxV =[vrView maxValue];
                minV = [vrView minValue];
				
				
                for (int i = 2; i < yLines-1; i += 2) {

                    y = y0 - chartHeight * i / yLines;
                    //r = CGRectMake(x+w*0.12, y-h/2, w*0.88, h);
                    r = CGRectMake(x+2, y-h/2, w-4, h);

                    float v = chartType == AnalysisTypeWR ? yLines - i : i;
                    str = [NSString stringWithFormat:@"%.1f",minV +( v * fabs(maxV-minV) / yLines)];
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
//                    UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
            case BottomViewAnalysisTypeMACD:{
                titleLabel.text = NSLocalizedStringFromTable(@"MACD", @"Draw", nil);
                MACDView * macdView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                float highestVolume = [macdView maxValue];
                y0 = chartHeight / 2 + y;
                
                [texts addObject:@"0.00"];
                
                
                for (int i = 2; i < n; i += 2) {
                    v = highestVolume*i/n;
                    [texts addObject:[NSString stringWithFormat:@"%+.*f", v<100?2:1, v]];
                    [texts addObject:[NSString stringWithFormat:@"%+.*f", v<100?2:1, -v]];
                }
                
                
                for (NSString *s in texts)
                    [self gridValueSize:&size fromString:s];
                
                [self drawGridValue:[texts objectAtIndex:index++] atY:y0 withSize:size xOffset:0];
                
                for (int i = 2; i < n; i += 2) {
                    
                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0-chartHeight/2*i/n withSize:size xOffset:0];
                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0+chartHeight/2*i/n withSize:size xOffset:0];
                }
                
                break;
            }
            case BottomViewAnalysisTypeBias:{
                titleLabel.text = NSLocalizedStringFromTable(@"Bias", @"Draw", nil);
                BiasView * biasView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                float highestVolume = [biasView maxValue];
                y0 = chartHeight / 2 + y;
                
                [texts addObject:@"0.00"];
                
                for (int i = 2; i < n; i += 2) {
                    v = highestVolume * i/n;
                    [texts addObject:[NSString stringWithFormat:@"%+.*f", v<100?2:1, v]];
                    [texts addObject:[NSString stringWithFormat:@"%+.*f", v<100?2:1, -v]];
                }
                
                for (NSString *s in texts)
                    [self gridValueSize:&size fromString:s];
                
                [self drawGridValue:[texts objectAtIndex:index++] atY:y0 withSize:size xOffset:0];
                
                for (int i = 2; i < n; i += 2) {
                    
                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0-chartHeight/2*i/n withSize:size xOffset:0];
                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0+chartHeight/2*i/n withSize:size xOffset:0];
                }
                
                break;
            }
            case BottomViewAnalysisTypeMTM: {
                titleLabel.text = NSLocalizedStringFromTable(@"Momentum", @"Draw", nil);
                MomentumView * mtmView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                float highestVolume = [mtmView maxValue];
               
                y0 = chartHeight / 2 + y;

                [texts addObject:@"0.00"];

                for (int i = 2; i < n; i += 2) {
                    v = highestVolume*i/n;
                    [texts addObject:[NSString stringWithFormat:@"%+.*f", v<100?2:1, v]];
                    [texts addObject:[NSString stringWithFormat:@"%+.*f", v<100?2:1, -v]];
                }

                for (NSString *s in texts)
                    [self gridValueSize:&size fromString:s];

                [self drawGridValue:[texts objectAtIndex:index++] atY:y0 withSize:size xOffset:0];

                for (int i = 2; i < n; i += 2) {

                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0-chartHeight/2*i/n withSize:size xOffset:0];
                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0+chartHeight/2*i/n withSize:size xOffset:0];
                }

                break;
            }

            case BottomViewAnalysisTypeOBV: {
                titleLabel.text = NSLocalizedStringFromTable(@"OBV", @"Draw", nil);
                UInt8 maxUnit = [view maxVolUnit];
                OBVView * obvView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                float highestVolume = [obvView maxValue];
                y0 = chartHeight / 2 + y;
                NSArray *textArray = @[@"", @"K", @"M", @"B", @"T", @"Q"];
                [texts addObject:@"0"];
                
                for (int i = 2; i < n; i += 2) {
                    v = highestVolume * i / n;
                    
                    [texts addObject:[[CodingUtil volumeRoundRownWithDouble:v]stringByAppendingString:textArray[maxUnit]]];
                    [texts addObject:[[CodingUtil volumeRoundRownWithDouble:-v]stringByAppendingString:textArray[maxUnit]]];
                       //[texts addObject:[ValueUtil stringWithValue:v unit:maxUnit font:font width:w-4 sign:YES]];
                       //[texts addObject:[ValueUtil stringWithValue:-v unit:maxUnit font:font width:w-4 sign:YES]];
//                   [texts addObject:[NSString stringWithFormat:@"%d"];
//                   [texts addObject:[ValueUtil stringWithValue:-v unit:maxUnit font:font width:w-4 sign:YES]];
                }

                for (NSString *s in texts)
                    [self gridValueSize:&size fromString:s];

                int index = 0;
                [self drawGridValue:[texts objectAtIndex:index++] atY:y0 withSize:size xOffset:0];
                

                for (int i = 2; i < n; i += 2) {
                    v = chartHeight / 2 * i / n;
                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0-v withSize:size xOffset:0];
                    [self drawGridValue:[texts objectAtIndex:index++] atY:y0+v withSize:size xOffset:0];
                }

                break;
            }

            case BottomViewAnalysisTypeVOL: {
                titleLabel.text = NSLocalizedStringFromTable(@"VolumeTitle", @"Draw", nil);
                float highestVolume = drawAndScrollController.theHighestVolume;
                UInt8 maxUnit = drawAndScrollController.maxVolumeUnit;
                float scaleValue;

                for (int i = 2; i < yLines-1; i += 2) {

                    scaleValue = highestVolume * i / yLines;

                    y = y0 - (chartHeight * i / yLines);
                    r = CGRectMake(x+2, y-h/2, MAXFLOAT, h);

                    if ([group isEqualToString:@"tw"] || [group isEqualToString:@"cn"])
                    {
                        if (portfolioItem->type_id == 3 || portfolioItem ->type_id == 6) {
                            str = [CodingUtil volumeRoundRownWithDouble:scaleValue];
                        }else{
                            str = [NSString stringWithFormat:@"%.0f",scaleValue];
                        }
                        
                    }else{
                        str = [ValueUtil stringWithValue:scaleValue unit:maxUnit font:font width:w-4];
                    }
                    

//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    //UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
				}
                break;
            }

            case BottomViewAnalysisTypeOSC:{
                titleLabel.text = NSLocalizedStringFromTable(@"Oscillator", @"Draw", nil);
                OscillatorView * oscView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                maxV =[oscView maxValue];
                minV = [oscView minValue];
                for (int i = 2; i < yLines-1; i += 2) {
                    
                    value = minV + (maxV - minV) * i / yLines;
                    
                    str = [NSString stringWithFormat:@"%.1f", value*100];
                    
                    y = y0 - chartHeight * i / yLines;
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    // UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
            case BottomViewAnalysisTypeARBR:{
                titleLabel.text = NSLocalizedStringFromTable(@"ARBR", @"Draw", nil);
                ARBRView * arbrView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                maxV =[arbrView maxValue];
                minV = [arbrView minValue];
                for (int i = 2; i < yLines-1; i += 2) {
                    
                    value = minV + (maxV - minV) * i / yLines;
                    
                    str = [NSString stringWithFormat:@"%.3f", value];
                    
                    y = y0 - chartHeight * i / yLines;
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    //UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
            case BottomViewAnalysisTypeDMI:{
                titleLabel.text = NSLocalizedStringFromTable(@"DMI", @"Draw", nil);
                DMIView * dmiView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                maxV =[dmiView maxValue];
                minV = [dmiView minValue];
                for (int i = 2; i < yLines-1; i += 2) {
                    
                    value = minV + (maxV - minV) * i / yLines;
                    
                    str = [NSString stringWithFormat:@"%.1f", value];
                    
                    y = y0 - chartHeight * i / yLines;
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
                    //UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
			case BottomViewAnalysisTypeTower: {
                if(IS_IPAD)
                    titleLabel.font = [UIFont systemFontOfSize:9.5f];
                titleLabel.text = NSLocalizedStringFromTable(@"TLB", @"Draw", nil);
                TowerView * tlbView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                maxV =[tlbView maxValue];
                minV = [tlbView minValue];

                for (int i = 2; i < yLines-1; i += 2) {

                    value = minV + (maxV - minV) * i / yLines;

                    str = [NSString stringWithFormat:@"%.2f", value];


                    y = y0 - chartHeight * i / yLines;
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    
                    if (value>1000) {
                        font = [UIFont fontWithName:@"Arial" size:9];
                    }

//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                    [str drawInRect:r withAttributes:attributes];
//                    UIRectFill(CGRectMake(x+0.1, y-1.25, 1.5, 2.5));
                }
                break;
            }
            case BottomViewAnalysisTypeGain: {
                titleLabel.text = NSLocalizedStringFromTable(@"Gain", @"Draw", nil);
                isGain = YES;
                GainView * gainView =[bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
                maxV = gainView.maxValue;
                minV = gainView.minValue;
                NSMutableArray *tempGainArray = [[NSMutableArray alloc]init];
                NSMutableArray *tempCgrectArray = [[NSMutableArray alloc]init];
                for (int i = 2; i < yLines-1; i += 2) {
                    
                    y = y0 - chartHeight * i / yLines;
                    //r = CGRectMake(x+w*0.12, y-h/2, w*0.88, h);
                    r = CGRectMake(x+2, y-h/2, w-4, h);
                    
                    float v = chartType == AnalysisTypeGain ? yLines - i : i;
                    float tempGain = 0;
                    if (maxV !=-MAXFLOAT && minV != MAXFLOAT){
                        if (maxV == minV) {
                            tempGain = (v * maxV / 4) * 100;
                        }else{
                            tempGain = (minV +( v * fabs(maxV-minV) / yLines)) * 100;
                        }
                    }else{
                        tempGain = 0;
                    }
                    [tempGainArray addObject:[NSNumber numberWithFloat:tempGain]];
                    [tempCgrectArray addObject:[NSValue valueWithCGRect:r]];
//                    [str drawInRect:r withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
                }
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:Nil ascending:YES selector:@selector(compare:)];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSMutableArray *sortedArray = [[NSMutableArray alloc]initWithArray:[tempGainArray sortedArrayUsingDescriptors:sortDescriptors]];
                
                for (int i = 0; i < [sortedArray count]; i++){
                    [[NSString  stringWithFormat:@"%.2f%%", [(NSNumber *)[sortedArray objectAtIndex:i] floatValue]] drawInRect:[[tempCgrectArray objectAtIndex:i] CGRectValue] withAttributes:attributes];
                }
                break;
            }
        }
    }
	
//畫數值
    
    float value1Location;
    float value1_2Location;
    float value2Location;
    float value2_2Location;
    float value3Location;
    
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        value1Location = 40;
        value1_2Location = 40;
        value2Location = 170;
        value2_2Location = 140;
        value3Location = 230;
    }else{
        value1Location = 40;
        value1_2Location = 60;
        value2Location = 275;
        value2_2Location = 200;
        value3Location = 340;
    }
    
    if (isGain)
    {
        //針對部位風險、績效日記的報酬率做的補丁，這樣對技術的影響比較小，但是技術的位置跟跟補丁後的位置是不一樣的，待QA確認要將技術改成跟upperView 的相同間距時再將此移除
        value2_2Location = 40;
        isGain = NO;
    }
	
	if((int)bottonView.subDataViewsIndex >= 0 && haveCross)
	{
        
		double value1,value2,value3,value4,value5,value6;
		UIView<AnalysisChart> *view = [bottonView.subDataViews objectAtIndex:bottonView.subDataViewsIndex];
		[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3];
		UIFont *font = [UIFont fontWithName:@"Arial" size:11];
        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
		NSString *valueString;
	    [[UIColor colorWithRed:0.78 green:0.76 blue:0.45 alpha:1] set];
		switch (bottonView.subDataViewsIndex) {
			case BottomViewAnalysisTypeVOL:
				[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4];
                
                if ([group isEqualToString:@"tw"] || [group isEqualToString:@"cn"])
                {
                    if (portfolioItem->type_id == 3 || portfolioItem ->type_id == 6) {
                        if(value1>value2){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
//                            valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil twStringWithVolumeByValue:value1]] ;
                            valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value1]];
                        }else if (value2>value1){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
//                            valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil twStringWithVolumeByValue:value1]];
                            valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value1]];
                        }else{
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            NSString * valueStr = valueString = [CodingUtil twStringWithVolumeByValue:value1];
                            if (![valueStr isEqualToString:@"----"]) {
//                                valueString = [NSString stringWithFormat:@"%@",[CodingUtil twStringWithVolumeByValue:value1]];
                                valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value1]];
                            }else{
                                valueString = @"";
                            }
                        }
                        
                        [valueString drawAtPoint:CGPointMake(value1Location, 1) withAttributes:attributes];
                        
                        if(value3>value4){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
//                            valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil twStringWithVolumeByValue:value3]];
                            valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value3]];
                        }else if (value4>value3){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
//                            valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil twStringWithVolumeByValue:value3]];
                            valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value3]];
                        }else{
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            NSString * valueStr = valueString = [CodingUtil twStringWithVolumeByValue:value3];
                            if (![valueStr isEqualToString:@"----"]) {
//                                valueString = [NSString stringWithFormat:@"%@",[CodingUtil twStringWithVolumeByValue:value3]];
                                valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value3]];
                            }else{
                                valueString = @"";
                            }
                        }
                        
                        [valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
                    }else{
                        if(value1>value2){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
//                            valueString = [NSString stringWithFormat:@"%.0f↑",value1] ;
                            valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value1]];
                        }else if (value2>value1){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
//                            valueString = [NSString stringWithFormat:@"%.0f↓",value1];
                            valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value1]];
                        }else{
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            NSString * valueStr = valueString = [CodingUtil twStringWithVolumeByValue:value1];
                            if (![valueStr isEqualToString:@"----"]) {
//                                valueString = [NSString stringWithFormat:@"%.0f",value1];
                                valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value1]];
                            }else{
                                valueString = @"";
                            }
                        }
                        
                        [valueString drawAtPoint:CGPointMake(value1Location, 1) withAttributes:attributes];
                        
                        if(value3>value4){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
//                            valueString = [NSString stringWithFormat:@"%.0f↑",value3];
                            valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value3]];
                        }else if (value4>value3){
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
//                            valueString = [NSString stringWithFormat:@"%.0f↓",value3];
                            valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value3]];
                        }else{
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            NSString * valueStr = valueString = [CodingUtil twStringWithVolumeByValue:value3];
                            if (![valueStr isEqualToString:@"----"]) {
//                                valueString = [NSString stringWithFormat:@"%.0f",value3];
                                valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value3]];
                            }else{
                                valueString = @"";
                            }
                        }
                        
                        [valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
                    }
                    
                    
                }else{
                    if(value1>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
//                        valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value1]] ;
                        valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value1]];
                    }else if (value2>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
//                        valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value1]];
                        valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value1]];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        NSString * valueStr = valueString = [CodingUtil stringWithVolumeByValue:value1];
                        if (![valueStr isEqualToString:@"----"]) {
//                            valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value1]];
                            valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value1]];
                        }else{
                            valueString = @"";
                        }
                    }
                    
                    //				[valueString drawAtPoint:CGPointMake(70, 1) withFont:font];
                    [valueString drawAtPoint:CGPointMake(value1Location, 1) withAttributes:attributes];
                    
                    if(value3>value4){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
//                        valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value3]];
                        valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue:value3]];
                    }else if (value4>value3){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
//                        valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value3]];
                        valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue:value3]];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        NSString * valueStr = valueString = [CodingUtil stringWithVolumeByValue:value3];
                        if (![valueStr isEqualToString:@"----"]) {
//                            valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value3]];
                            valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue:value3]];
                        }else{
                            valueString = @"";
                        }
                    }
                    
                    //				[valueString drawAtPoint:CGPointMake(200, 1) withFont:font];
                    [valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
                }
                
                
				
				break;
			case BottomViewAnalysisTypeRSI:
                [view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4];
				if(value1>value2){
                    if(value2!=-0.0){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }
                    
                }else if (value2>value1){
                    if (value2!=-0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }
                    
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value1 !=-0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                    
                }
				[valueString drawAtPoint:CGPointMake(value1Location, 1) withAttributes:attributes];
                
                if(value3>value4){
                    if (value4 !=-0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    valueString = [NSString stringWithFormat:@"%.2lf↑",value3];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value3];
                    }
                    
                }else if (value4>value3){
                    if (value4 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    valueString = [NSString stringWithFormat:@"%.2lf↓",value3];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
      
                    if (value3 !=-0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value3];
                    }else{
                        valueString = @"";
                    }
                }

				[valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
				break;
			case BottomViewAnalysisTypeKDJ:
                [view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4 Value5:&value5 Value6:&value6];
                if(value1>value4){
                    if (value4 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }
                    
                }else if (value4>value1){
                    if (value4 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value1 != -0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                    
                }
				[valueString drawAtPoint:CGPointMake(value1_2Location - 10, 1) withAttributes:attributes];
                
                if(value2>value5){
                    if (value5 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value2];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }
                }else if (value5>value2){
                    if (value5 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value2];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if(value2 != -0.0){
                       valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }else{
                        valueString = @"";
                    }
                    
                }
				[valueString drawAtPoint:CGPointMake(value2_2Location - 10, 1) withAttributes:attributes];
                
                if(value3>value6){
                    if (value6 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value3];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value3];
                    }
                }else if (value6>value3){
                    if (value6 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value3];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value3];
                    }
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value3 != -0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value3];
                    }else{
                        valueString = @"";
                    }
                }
                [valueString drawAtPoint:CGPointMake(value3Location - 10, 1) withAttributes:attributes];
				
				break;
			case BottomViewAnalysisTypeMACD:
				[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4];
                if (value3 !=-0.0) {
                    if(value1>value3){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value3>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        if (value1 != -0.0) {
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                    }
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value1 != -0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
				
				
				[valueString drawAtPoint:CGPointMake(value1_2Location - 10, 1) withAttributes:attributes];
                if (value4 !=-0.0) {
                    if(value2>value4){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value2];
                    }else if (value4>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value2];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        if (value2 != -0.0) {
                            valueString = [NSString stringWithFormat:@"%.2lf",value2];
                        }else{
                            valueString = @"";
                        }
                    }
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value2 != -0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }else{
                        valueString = @"";
                    }
                }
                
				
				[valueString drawAtPoint:CGPointMake(value2_2Location - 10, 1) withAttributes:attributes];
                if(value2 !=-0.0){
                    if(value1>value2){
                        [[UIColor orangeColor] set];
                    }else {
                        [[UIColor colorWithRed:157.0f/255.0f green:185.0f/255.0f blue:185.0f/255.0f alpha:1] set];
                    }
                    valueString = [NSString stringWithFormat:@"%.2lf",value1-value2];
                    [valueString drawAtPoint:CGPointMake(value3Location - 10, 1) withAttributes:attributes];
                }
				break;
			case BottomViewAnalysisTypeBias:
                if(value1>value2){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                    valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                }else if (value2>value1){
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                    valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value1 != -0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                    
                }
				[valueString drawAtPoint:CGPointMake(value2_2Location - 90, 1) withAttributes:attributes];
				break;
			case BottomViewAnalysisTypeOBV:
                
                if (value2 != -0.0) {
                    if(value1>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%@↑",[CodingUtil stringWithVolumeByValue2NoFloat:value1]];
                    }else if (value2>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%@↓",[CodingUtil stringWithVolumeByValue2NoFloat:value1]];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        if (value1 !=-0.0) {
                            valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue2NoFloat:value1]];
                        }else{
                            valueString = @"";
                        }
                    }
                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value1 !=-0.0) {
                        valueString = [NSString stringWithFormat:@"%@",[CodingUtil stringWithVolumeByValue2NoFloat:value1]];
                    }else{
                        valueString = @"";
                    }
                }
				
                [valueString drawAtPoint:CGPointMake(value2_2Location - 90, 1) withAttributes:attributes];
				
				break;
			case BottomViewAnalysisTypePSY:
                if (value2 !=-0.0) {
                    if(value1>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value2>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        if (value1 !=-0.0) {
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                    }

                }else{
                    attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                    if (value1 !=-0.0) {
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
                
                [valueString drawAtPoint:CGPointMake(value2_2Location - 90, 1) withAttributes:attributes];
            
				break;
			case BottomViewAnalysisTypeWR:
                if (value2 !=-0.0){
                    if(value1>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value2>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        if (value1 !=-0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                    }
                }else{
                    if (value1 !=-0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
                
				
                [valueString drawAtPoint:CGPointMake(value2_2Location - 90, 1) withAttributes:attributes];
				break;
			case BottomViewAnalysisTypeMTM:
				[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4];
                if (value3 != -0.0) {
                    if(value1>value3){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value3>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        if (value1!=-0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                    }
                }else{
                    if (value1!=-0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
				
				[valueString drawAtPoint:CGPointMake(value1Location + 10, 1) withAttributes:attributes];
                
                if (value4 != -0.0) {
                    if(value2>value4){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value2];
                    }else if (value4>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value2];
                    }else{
                        if (value2 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value2];
                        }else{
                            valueString = @"";
                        }
                    }
                }else{
                    if (value2 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }else{
                        valueString = @"";
                    }
                } 
				
				[valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
				break;
			case BottomViewAnalysisTypeOSC:
				[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4];
                if (value3 != -0.0) {
                    if(value1>value3){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value3>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        if (value1 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString =@"";
                        }
                    }
                }else{
                    if (value1 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString =@"";
                    }
                }

				[valueString drawAtPoint:CGPointMake(value1Location + 10, 1) withAttributes:attributes];
                
                if (value4 != -0.0) {
                    if(value2>value4){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value2];
                    }else if (value4>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value2];
                    }else{
                        if (value2 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value2];
                        }else{
                            valueString =@"";
                        }
                        
                    }
                }else{
                    if (value2 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }else{
                        valueString =@"";
                    }
                }
				
				[valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
				break;
			case BottomViewAnalysisTypeARBR:
				[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4];
                if (value3 !=-0.0) {
                    if(value1>value3){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value3>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        if (value1 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                        
                    }
                }else{
                    if (value1 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
				
				[valueString drawAtPoint:CGPointMake(value1Location, 1) withAttributes:attributes];
                if (value4 != -0.0) {
                    if(value2>value4){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value2];
                    }else if (value4>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value2];
                    }else{
                        if (value2 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value2];
                        }else{
                            valueString = @"";
                        }
                    }
                }else{
                    if (value2 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }else{
                        valueString = @"";
                    }
                }
				
				[valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
				break;
			case BottomViewAnalysisTypeDMI:
				[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4 Value5:&value5 Value6:&value6];
                if (value4 != -0.0) {
                    if(value1>value4){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value4>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        if (value1 !=-0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                        
                    }
                }else{
                    if (value1 !=-0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
                
				[valueString drawAtPoint:CGPointMake(value1_2Location, 1) withAttributes:attributes];
                
                if (value5 != -0.0) {
                    if(value2>value5){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value2];
                    }else if (value5>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value2];
                    }else{
                        if (value2 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value2];
                        }else{
                            valueString = @"";
                        }
                        
                    }
                }else{
                    if (value2 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }else{
                        valueString = @"";
                    }
                }
                
				[valueString drawAtPoint:CGPointMake(value2_2Location, 1) withAttributes:attributes];
                
                if (value6 != -0.0) {
                    if(value3>value6){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value3];
                    }else if (value6>value3){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value3];
                    }else{
                        if (value3 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value3];
                        }else{
                            valueString = @"";
                        }
                        
                    }
                }else{
                    if (value3 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value3];
                    }else{
                        valueString = @"";
                    }
                }
                
                [valueString drawAtPoint:CGPointMake(value3Location, 1) withAttributes:attributes];
				
				break;
			case BottomViewAnalysisTypeTower:
				[view getValueWithIndex:crossIndex Value1:&value1 Value2:&value2 Value3:&value3 Value4:&value4];
                if (value3 != -0.0) {
                    if(value1>value3){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value3>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        if (value1 !=-0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                        
                    }
                }else {
                    if (value1 !=-0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
				
				
				[valueString drawAtPoint:CGPointMake(value1Location, 1) withAttributes:attributes];
                
                if (value4 != -0.0) {
                    if(value2>value4){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value2];
                    }else if (value4>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value2];
                    }else{
                        if (value2 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value2];
                        }else{
                            valueString = @"";
                        }
                        
                    }
                }else{
                    if (value2 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value2];
                    }else{
                        valueString = @"";
                    }
                }
                
				
				[valueString drawAtPoint:CGPointMake(value2Location, 1) withAttributes:attributes];
				break;

				
			case BottomViewAnalysisTypeVR:
				if (value2 != -0.0) {
                    if(value1>value2){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceUpColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↑",value1];
                    }else if (value2>value1){
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[StockConstant PriceDownColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf↓",value1];
                    }else{
                        if (value1 != -0.0) {
                            attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                            valueString = [NSString stringWithFormat:@"%.2lf",value1];
                        }else{
                            valueString = @"";
                        }
                        
                    }
                }else{
                    if (value1 != -0.0) {
                        attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blueColor]};
                        valueString = [NSString stringWithFormat:@"%.2lf",value1];
                    }else{
                        valueString = @"";
                    }
                }
				
                [valueString drawAtPoint:CGPointMake(value2_2Location - 100, 1) withAttributes:attributes];
                break;
                
            case BottomViewAnalysisTypeGain:
            {
                UIColor *printOutColor = [UIColor blueColor];
                if (value1 != -0.0) {
                    valueString = [NSString stringWithFormat:@"%.2f%%",value1*100];
                    if(value1>0){
//                        valueString = [NSString stringWithFormat:@"+%.2f%%",value1*100];
                        printOutColor = [StockConstant PriceUpColor];
                    }else if(value1<0){
                        printOutColor = [StockConstant PriceDownColor];
                    }
                }else{
                    valueString = @"0.00%";
                }
                attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:printOutColor};
                [valueString drawAtPoint:CGPointMake(value2_2Location, 1) withAttributes:attributes];
                break;
            }
		}
	}
    [dataLock unlock];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [bottonView doTouchesBegan:touches withEvent:event];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    CGRect r = bottonView.dataScrollView.frame;

    if ([[touches anyObject] locationInView:self].x < r.origin.x + r.size.width) {

        [bottonView doTouchesMoved:touches withEvent:event];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    CGRect r = bottonView.dataScrollView.frame;

    if ([[touches anyObject] locationInView:self].x < r.origin.x + r.size.width) {

        [bottonView doTouchesEnded:touches withEvent:event];
    }
    else
        [bottonView doTouchesEnded:touches withEvent:event timeInterval:10];
}


- (void)updateValueWithIndex:(int)index		//畫技術分析值用
{
	//  cross info view 關掉會代 [bottomDataView updateValueWithIndex:-1] 進來
	
	if(index < 0 ) 
		haveCross = NO;
	else
	{
		haveCross = YES;
		crossIndex = index;
	}
}

-(void)touch{
    NSLog(@"123");
}



@end
