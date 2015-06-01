//
//  UpperValueView.m
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/6.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import "UpperValueView.h"
#import "IndexView.h"


#define lineWidthOffset  1.25
#define valueHeight      14
#define valueOffset      5.0//1.0


@implementation UpperValueView

@synthesize drawAndScrollController;
@synthesize zoomTransform;
@synthesize lowest,highest;


- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame])
	{
        // Initialization code
        valueLabels = [[NSMutableArray alloc] init];
        markViews = [[NSMutableArray alloc] init];
        dataLock = [[NSRecursiveLock alloc]init];
    }
    return self;
}


/*
- (void)drawRect:(CGRect)rect {
}
*/


- (void)checkLabelStatus:(BOOL)checkScale 
{

    if (valueLabels.count == 0) return;

    float y;
    UILabel *label;
    UIView *view;

    IndexView *indexView = drawAndScrollController.indexView;
    UIScrollView *indexScrollView = drawAndScrollController.indexScrollView;
    int yLines = (int)indexView.yLines;

    CGPoint point = [indexView convertPoint:indexView.chartFrameOffset toView:self];
    float chartHeight = indexView.chartFrame.size.height;
    float y0 = point.y + chartHeight;

    float minY = indexScrollView.bounds.origin.y - lineWidthOffset;
    float maxY = minY + indexScrollView.bounds.size.height + lineWidthOffset * 2;

    CGAffineTransform transform;
    float yOffset;

    if (checkScale) 
	{
        transform = CGAffineTransformMakeScale(1, 1/self.transform.d);
        yOffset = valueOffset / self.transform.d;
    }

    for (int i = 0; i <= yLines; i++)
	{

        y = y0 - chartHeight * i / yLines;
        point = [self convertPoint:CGPointMake(0, y) toView:indexScrollView];

        label = [valueLabels objectAtIndex:i];
        view = [markViews objectAtIndex:i];

        if (checkScale) 
		{
            label.transform = transform;
            view.transform = transform;
            label.center = CGPointMake(label.center.x, y+yOffset);
            view.center = CGPointMake(view.center.x, y);
        }

        if (point.y >= minY && point.y <= maxY)
		{

            if (label.hidden || view.hidden)
			{
                label.hidden = NO;
                view.hidden = NO;
            }
        }
        else 
		{
            if (!label.hidden || !view.hidden) 
			{
                label.hidden = YES;
                view.hidden = YES;
            }
        }
    }
}


- (void)checkLabelStatus
{

    [self checkLabelStatus:NO];
}


- (void)resetLabelTransform 
{

    [self checkLabelStatus:YES];
}


- (void)updateLabels 
{
    [dataLock lock];
    IndexView *indexView = drawAndScrollController.indexView;

    int i;
    UILabel *label;
    UIView *view;
    int yLines = (int)indexView.yLines;

    if (valueLabels.count <= yLines) 
	{

        CGPoint origin = [indexView convertPoint:indexView.chartFrameOffset toView:self];
        float chartHeight = indexView.chartFrame.size.height;
        float y0 = origin.y + chartHeight;
        float y;

        float w = self.bounds.size.width;
        UIFont *font = [UIFont fontWithName:@"Arial" size:11];

        for (i = (int)valueLabels.count; i <= yLines; i++)
		{
            label = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, w, valueHeight)];
            label.font = font;
            label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor blueColor];

            y = y0 - chartHeight * i / yLines;
            label.center = CGPointMake(label.center.x - 2, y+valueOffset);

            [self addSubview:label];
            [valueLabels addObject:label];

            view = [[UIView alloc] initWithFrame:CGRectMake(0.1, y-1.25, 1.5, 2.5)];
            view.center = CGPointMake(view.center.x, y);
            view.backgroundColor = [UIColor clearColor];

            [self addSubview:view];
            [markViews addObject:view];
        }
    }

    if ([indexView.historicData tickCount:drawAndScrollController.historicType] > 0) 
	{

        if (drawAndScrollController.twoLine)
		{

            float value;
            float lowScale = drawAndScrollController.indexScaleView.lowestValue * 100;
            float highScale = drawAndScrollController.indexScaleView.highestValue * 100;
            NSString *format = lowScale > -10 && highScale < 10 ? @"%+.2f%%" :
                               lowScale > -100 && highScale < 100 ? @"%+.1f%%" : @"%+.0f%%";

            for (i = 0; i <= yLines; i++)
			{

                label = [valueLabels objectAtIndex:i];
                value = lowScale + (highScale - lowScale) * i / yLines;
                
                    label.text = [NSString stringWithFormat:format, value];
            }
        }
        else
		{

            float value;
            
#pragma mark -
#pragma mark K線 線圖y軸刻度值
			
            for (i = 0; i <= yLines; i++) 
			{

                label = [valueLabels objectAtIndex:i];
                value = lowest + (highest - lowest) * i / yLines;
				
				/*
				if([drawAndScrollController.idSymbol && [[drawAndScrollController.idSymbol hasPrefix:@"HK"])
				{
					label.text = [CodingUtil ConvertPriceValueToString:value withIdSymbol:idSymbol];
				}
				else
				{
					label.text = [NSString stringWithFormat:value<1000?@"%.2f":@"%.1f", value];
				}
				 */
				label.text = [CodingUtil ConvertPriceValueToString:value withIdSymbol:drawAndScrollController.idSymbol];
				
				UIFont *font;
				if (value>=10000) {
					font = [UIFont fontWithName:@"Arial" size:9];
					label.font = font;
				}

				
            }
        }
    }
    else 
	{

        for (UILabel *l in valueLabels)
            l.text = nil;
    }

    if (!CGAffineTransformIsIdentity(zoomTransform))
	{
        self.transform = zoomTransform;
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self resetLabelTransform];
        zoomTransform = CGAffineTransformIdentity;
    }
    
    [dataLock unlock];
}


- (void)adjustForOrientation:(BOOL)isLandscape 
{

    IndexView *indexView = drawAndScrollController.indexView;
    CGPoint origin = [indexView convertPoint:indexView.chartFrameOffset toView:self];
    CGFloat chartHeight = indexView.chartFrame.size.height;
    CGFloat y0 = origin.y + chartHeight;
    CGFloat y;

    CGFloat w = self.bounds.size.width;
    CGFloat x = isLandscape ? 5 : 4;

    UIFont *font = [UIFont fontWithName:@"Arial" size:isLandscape?14:11];
    NSUInteger count = valueLabels.count;
    UILabel *label;
    UIView *view;

    for (int i = 0; i < count; i++)
	{

        y = y0 - chartHeight * i / (count - 1);

        label = [valueLabels objectAtIndex:i];
        label.font = font;
        label.frame = CGRectMake(x, label.frame.origin.y, w-x, valueHeight);
        label.center = CGPointMake(label.center.x, y+valueOffset);

        view = [markViews objectAtIndex:i];
        view.center = CGPointMake(view.center.x, y);
    }
}

@end
