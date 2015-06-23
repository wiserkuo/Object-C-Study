//
//  NetWorthBottonView.m
//  FonestockPower
//
//  Created by Neil on 14/6/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "NetWorthBottonView.h"
#import "NetWorthViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HistoricDataTypes.h"

@interface NetWorthBottonView (){
    UILabel * valueLabel;
    NSMutableArray *layoutConstraints;
}

@end

@implementation NetWorthBottonView

- (id)init
{
    self = [super init];
    if (self) {
        layoutConstraints = [[NSMutableArray alloc]init];
        _netWorthDataArray = [[NSMutableArray alloc]init];
        _netWorthDataDictionary = [[NSMutableDictionary alloc]init];
        [self initView];

    }
    return self;
}

-(void)initView{
    
    valueLabel = [[UILabel alloc] init];
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    valueLabel.font = [UIFont systemFontOfSize:12.0f];
    valueLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:valueLabel];
    
    [self setNeedsUpdateConstraints];
}

-(void)updateConstraints{
    [super updateConstraints];
    
    [self removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(valueLabel);
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[valueLabel(15)]" options:0 metrics:nil views:viewControllers]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-185-[valueLabel(100)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self addConstraints:layoutConstraints];
}

- (void)drawRect:(CGRect)rect
{
    valueLabel.text = @"";
    float bottonDashLineHeight = self.frame.size.height/5.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGFloat length[]={2,1};
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, length, 2);
    for (int i=1; i<5; i++) {
        
        CGContextMoveToPoint(context, 0, i*bottonDashLineHeight);
        CGContextAddLineToPoint(context, self.frame.size.width, i*bottonDashLineHeight);
        
    }
    CGContextStrokePath(context);
    
    DecompressedHistoricData *lastData = [_histDataArray lastObject];
    
    
    //畫柱狀圖
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *component = [gregorian components:NSCalendarUnitDay fromDate:_beginDay toDate:[[NSNumber numberWithUnsignedInt:lastData.date] uint16ToDate] options:0];
    NSMutableArray *drawDateArray = [[NSMutableArray alloc]init];
    int dayCount;
    if ([_histDataArray count] > 0) {
        for (int i = 0; i < [_histDataArray count]; i ++){
            DecompressedHistoricData *data = [_histDataArray objectAtIndex:i];
            if (data.date >= [[_beginDay dayOffset:0] uint16Value]) {
                [drawDateArray addObject:[[NSNumber numberWithUnsignedInt:data.date] uint16ToDate]];
            }
        }
        dayCount = (unsigned int)[drawDateArray count];
    }else{
        dayCount = (int)[component day]+1;;
    }
    float dayWidth = self.frame.size.width / dayCount;
    
    float imageHeigh = (bottonDashLineHeight*2)/_maxDaily;
    for (int i=0; i<[_netWorthDataArray count]; i++) {
        NetWorthData * data = [_netWorthDataArray objectAtIndex:i];
      
        for (int n = 0; n < [drawDateArray count]; n++){
            if ([data -> date uint16Value] == [[[drawDateArray objectAtIndex:n]dayOffset:0]uint16Value] ) {
                if (data->dailyValue == 0) {
                    // 不畫
                }
                else if (data->dailyValue > 0) { // dailyValue為正數
                    
                    CGRect longRect = CGRectMake(dayWidth * n - dayWidth / 2, (bottonDashLineHeight*3)-data->dailyValue*imageHeigh, dayWidth, data->dailyValue*imageHeigh);
                    
                    CGContextAddRect(context, longRect);
                    [[UIColor orangeColor] set];
                    CGContextFillPath(context);
                }
                else { // dailyValue 是負數
                    
                    CGRect longRect = CGRectMake(dayWidth * n - dayWidth / 2, (bottonDashLineHeight*3), dayWidth, data->dailyValue*imageHeigh*(-1.0));
                    
                    CGContextAddRect(context, longRect);
                    [[UIColor colorWithRed:122.0f/255.0f green:142.0f/255.0f blue:190.0f/255.0f alpha:1.0f] set];
                    CGContextFillPath(context);
                }
                break;
            }
        }
    }
}
-(void)changeDate:(NSString *)date Value:(float)value{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[self dateFormateDefinition]];
    NSDate *touchDate = [formatter dateFromString:date];
    
    if([_netWorthDataArray count] != 0){
        NetWorthData *data = [_netWorthDataArray objectAtIndex:0];
        if([CodingUtil makeDateFromDate:touchDate] >= [CodingUtil makeDateFromDate:data->date]){
            valueLabel.text = [NSString stringWithFormat:@"$%@",[CodingUtil CoverFloatWithCommaForCN:value]];
            if (value == 0) {
                valueLabel.text = @"0";
            }
        }else{
            valueLabel.text = @"";
        }
    }else{
        valueLabel.text = @"";
    }
    if (value > 0) {
        valueLabel.textColor = [StockConstant PriceUpColor];
    }else if (value < 0){
        valueLabel.textColor = [StockConstant PriceDownColor];
    }else{
        valueLabel.textColor = [UIColor blueColor];
    }
}

-(NSString *)dateFormateDefinition{
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        return @"MM/dd/yyyy";
    }else{
        return @"yyyy/MM/dd";
    }
}
@end
