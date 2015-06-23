//
//  NetWorthUpperView.m
//  FonestockPower
//
//  Created by Neil on 14/6/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "NetWorthUpperView.h"
#import <QuartzCore/QuartzCore.h>
#import "HistoricDataTypes.h"

@interface NetWorthUpperView (){
    NSDate * beginDay;
    NSDate * endDay;
    NSMutableArray * labelArray;
    NSMutableArray * dateArray;
    UILabel * dateLabel;
    UILabel * valueLabel;
    
    UILabel * crossLine;
    float dayWidth;
    NSMutableArray *layoutConstraints;
    int index;
}

@end

@implementation NetWorthUpperView

- (id)init
{
    self = [super init];
    if (self) {
        layoutConstraints = [[NSMutableArray alloc]init];
        labelArray = [[NSMutableArray alloc]init];
        dateArray = [[NSMutableArray alloc]init];
        _netWorthDataArray = [[NSMutableArray alloc]init];
        _netWorthDataDictionary = [[NSMutableDictionary alloc]init];
        [self initView];
    }
    return self;
}

-(void)initView{
    crossLine = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    crossLine.layer.borderColor = [UIColor blackColor].CGColor;
    crossLine.layer.borderWidth = 1;
    [self addSubview:crossLine];
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dateLabel.font = [UIFont systemFontOfSize:12.0f];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.text = @"";
    [self addSubview:dateLabel];
    
    valueLabel = [[UILabel alloc] init];
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    valueLabel.font = [UIFont systemFontOfSize:12.0f];
    valueLabel.textAlignment = NSTextAlignmentLeft;
    valueLabel.backgroundColor = [UIColor clearColor];
    valueLabel.text = @"";
    [self addSubview:valueLabel];
    
    [self setNeedsUpdateConstraints];
}

-(void)removeLabel{
    for (int i=0; i<[labelArray count]; i++) {
        UILabel * label = [labelArray objectAtIndex:i];
        [label removeFromSuperview];
    }
}

-(void)updateConstraints{
    [super updateConstraints];
    
    [self removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(dateLabel,valueLabel);
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dateLabel(20)]" options:0 metrics:nil views:viewControllers]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[valueLabel(20)]" options:0 metrics:nil views:viewControllers]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dateLabel(180)]-5-[valueLabel(100)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [self addConstraints:layoutConstraints];
}

-(void)setRange:(RangeID)rangeId{
    range = rangeId;
    crossLine.hidden = YES;
    if ([_histDataArray count] > 0) {
        DecompressedHistoricData *historicData = [_histDataArray lastObject];
        endDay = [[NSNumber numberWithUnsignedInt:historicData.date ] uint16ToDate];
    }else{
        endDay = [NSDate date];
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endDay];
    int year = (int)[comps year];
    int month = (int)[comps month];
    int day = (int)[comps day];
    
    if (rangeId==threeMonth) {
        beginDay = [endDay monthOffset:-3];
        
    }else if (rangeId==sixMonth){
        beginDay = [endDay monthOffset:-6];
        
    }else if (rangeId==YTD){
        month = 1;
        day = 1;

    }else if (rangeId==oneYear){
        beginDay = [endDay yearOffset:-1];
        
    }else if (rangeId==threeYear){
        beginDay = [endDay yearOffset:-3];;
        
    }
    
    UInt16 date;
    if (rangeId == YTD) {
        date = [CodingUtil makeDate:year month:month day:day];
    }else{
        date = [beginDay uint16Value];
    }
    if ([_histDataArray count] > 0) {
        for (int i = 0; i < [_histDataArray count]; i++) {
            DecompressedHistoricData *data = [_histDataArray objectAtIndex:i];
            if (data.date >= date) {
                index = i;
                date = data.date;
                beginDay =[[NSNumber numberWithUnsignedInt:date] uint16ToDate];
                break;
            }
        }
    }
    _netWorthViewController.beginDay = beginDay;
    
    [_netWorthViewController setBeginDay:beginDay];
}

- (void)drawRect:(CGRect)rect
{
    crossLine.hidden = YES;
    dateLabel.text = @"";
    valueLabel.text = @"";
    [self removeLabel];
    [labelArray removeAllObjects];
    [dateArray removeAllObjects];
    float upperDashLineHeight = self.frame.size.height/6.5f;
//    float upperDashLineHeightHalf = upperDashLineHeight/2;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGFloat length[] = {2, 1};
    CGContextSetLineWidth(context, 0.5);
    CGContextSetLineDash(context, 0, length, 2);
    for (int i=1; i<6; i++) {
        
        CGContextMoveToPoint(context, 0, i * upperDashLineHeight);
        CGContextAddLineToPoint(context, self.frame.size.width, i * upperDashLineHeight);
        
    }
    
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextMoveToPoint(context, 0, 6*upperDashLineHeight);
    CGContextAddLineToPoint(context, self.frame.size.width, 6*upperDashLineHeight);
    CGContextStrokePath(context);
    
    CGContextSetLineDash(context, 0, length, 2);
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *component = [gregorian components:NSCalendarUnitDay fromDate:beginDay toDate:endDay options:0];
    NSMutableArray *hisDateArray = [[NSMutableArray alloc]init];
    

    int dayCount;

    if ([_histDataArray count] > 0) {
        for (int i = index; i < [_histDataArray count]; i++){
            DecompressedHistoricData *data = [_histDataArray objectAtIndex:i];
            [hisDateArray addObject:[[NSNumber numberWithUnsignedInt:data.date] uint16ToDate]];
            
        }
        dayCount = (unsigned int)[hisDateArray count];
    }else{
        dayCount = (int)[component day] + 1;
    }
    dayWidth = self.frame.size.width / dayCount;
    int tempMonth;
    
    for (int i=0; i < [hisDateArray count]; i++) {
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[hisDateArray objectAtIndex:i]];
        int month = (int)[comps month];
        if (i == 0) {
            tempMonth = month;
        }
        if (tempMonth != month) {
            tempMonth = month;
            if (range == oneYear) {
                if (month == 1 || month == 4 || month == 7 ||month== 10){
                    [self drawMonthOnTheUpperview:context monthNum:month index:i lineHeight:upperDashLineHeight];
                }
            }else if (range == threeYear){
                if (month == 1 || month == 7 ){
                    [self drawMonthOnTheUpperview:context monthNum:month index:i lineHeight:upperDashLineHeight];
                }
            }else{
                [self drawMonthOnTheUpperview:context monthNum:month index:i lineHeight:upperDashLineHeight];
            }
        }
    }
    CGContextStrokePath(context);
    
    dateArray = [[NSMutableArray alloc]initWithArray:hisDateArray];
    
    //畫線
    int num;
    if (_maxTotal-_minTotal <=0) {
        num = 1;
    }else{
        num = _maxTotal-_minTotal;
    }
    float imageHeigh = (upperDashLineHeight*6-upperDashLineHeight*1)/num;
    [[UIColor blueColor] set];
    CGContextSetLineWidth(context, 1);
    CGContextSetLineDash(context, 0, NULL, 0);
    NSDate * lastDate;
    float lastTotal;
    for (int i = 0; i < [_netWorthDataArray count]; i++) {
        NetWorthData * data = [_netWorthDataArray objectAtIndex:i];
        if (data) {
            num = [self getHisdataAndNetWorthDataRange:hisDateArray netWorthData:data];
            if (i == 0) {
                CGContextMoveToPoint(context, dayWidth*num, upperDashLineHeight*6-((data->totalValue-_minTotal)*imageHeigh));
            }else{
//                if (count >1) {
//                    CGContextAddLineToPoint(context, dayWidth*(num-1), upperDashLineHeight*6-((lastTotal-_minTotal)*imageHeigh));
//                }
                CGContextAddLineToPoint(context, dayWidth*num, upperDashLineHeight*6-((data->totalValue-_minTotal)*imageHeigh));
            }
            lastDate = data->date;
            lastTotal = data->totalValue;
        }
    }
    CGContextStrokePath(context);
}

-(void)drawMonthOnTheUpperview:(CGContextRef)context monthNum:(int)MonthNum index:(int)Index lineHeight:(float)lineHeight{
    CGContextMoveToPoint(context, Index * dayWidth, lineHeight);
    CGContextAddLineToPoint(context, Index * dayWidth, self.frame.size.height - lineHeight/ 2);
    
    CGRect r;
    if (Index * dayWidth < 7.5){
        r = CGRectMake(Index * dayWidth, 6 * lineHeight, 15, 15);
    }else{
        r = CGRectMake(Index * dayWidth - 7.5, 6 * lineHeight, 15, 15);
    }
    
    NSString * str = [NSString stringWithFormat:@"%d",MonthNum];
    UIFont *font = [UIFont fontWithName:@"Arial" size:12.0f];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:[UIColor blackColor],NSParagraphStyleAttributeName: paragraphStyle };
    
    [str drawInRect:r withAttributes:attributes];
}
-(int)getHisdataAndNetWorthDataRange:(NSMutableArray *)Array netWorthData:(NetWorthData *)NetWorthData{
    
    int num = 0;
    
    for (int n = 0; n < [Array count]; n++){
        if ([NetWorthData -> date uint16Value] == [[[Array objectAtIndex:n]dayOffset:0]uint16Value] ) {
            num = n;
            break;
        }
    }
    return num;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    crossLine.hidden = YES;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    int result = touchPoint.x / dayWidth;
    float restNum = fmodf(touchPoint.x, dayWidth);
    if (restNum >= dayWidth / 2){
        result ++;
    }
    
   // if (fmodf(touchPoint.x, dayWidth)<1) {
        
    int num = result;
    if(num <= [dateArray count]-1){
        result *= dayWidth;
        NSDate * date = [dateArray objectAtIndex:num];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
        int day = (int)[comps day];
        int month = (int)[comps month];
        int year = (int)[comps year];
        
        float upperDashLineHeight = self.frame.size.height/6.5f;
        float num1;
        if (_maxTotal-_minTotal <=0) {
            num1 = 1;
        }else{
            num1 = _maxTotal-_minTotal;
        }
        float imageHeigh = (upperDashLineHeight*6-upperDashLineHeight*1)/num1;
        NSDateComponents *lastDay = [[NSDateComponents alloc] init];
        [lastDay setDay:-1];
        double totalValue =0.0f;
        double dailyValue = 0.0f;
        NetWorthData * data = [_netWorthDataDictionary objectForKey:date];
        if (data) {
            dailyValue = data->dailyValue;
        }
//        [crossLine setFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        for (int i = 0; i <= num; i++) {
            NetWorthData * data = [_netWorthDataDictionary objectForKey:date];
            if (data) {
                crossLine.hidden = NO;
                totalValue =data->totalValue;
                [crossLine setFrame:CGRectMake(0, upperDashLineHeight*6-((data->totalValue-_minTotal)*imageHeigh), self.frame.size.width, 0.5)];
                break;
            }else{
                
                date = [gregorian dateByAddingComponents:lastDay toDate:date options:0];
            }
        }
        NSString * dateStr = @"";
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS)
        {
            dateStr = [NSString stringWithFormat:@"%02d/%02d/%d",month,day,year];
        }else{
            dateStr = [NSString stringWithFormat:@"%d/%02d/%02d",year,month,day];
        }
        dateLabel.text = dateStr;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:[self dateFormateDefinition]];
        NSDate *touchDate = [formatter dateFromString:dateStr];
        if([_netWorthDataArray count] != 0){
            NetWorthData *data = [_netWorthDataArray objectAtIndex:0];
            if([CodingUtil makeDateFromDate:touchDate] >= [CodingUtil makeDateFromDate:data->date]){
                if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
                    valueLabel.text = [NSString stringWithFormat:@"$%@",[CodingUtil CoverFloatWithCommaForCN:totalValue]];
                }else{
                    valueLabel.text = [NSString stringWithFormat:@"$%@",[CodingUtil CoverFloatWithComma:totalValue DecimalPoint:0]];
                }
            }else{
                valueLabel.text = @"";
            }
        }else{
            valueLabel.text = @"";
        }
        
        if (totalValue > 0) {
            valueLabel.textColor = [StockConstant PriceUpColor];
        }else{
            valueLabel.textColor = [StockConstant PriceDownColor];
        }
        touchPoint.x = result;
        [_netWorthViewController doTouchesWithPoint:touchPoint Date:dateStr Value:dailyValue];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    crossLine.hidden = YES;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    int result = touchPoint.x / dayWidth;
    float restNum = fmodf(touchPoint.x, dayWidth);
    if (restNum >= dayWidth / 2){
        result ++;
    }
    
    // if (fmodf(touchPoint.x, dayWidth)<1) {
    
    int num = result;
    if(num <= [dateArray count]-1){
        result *= dayWidth;
        NSDate * date = [dateArray objectAtIndex:num];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *comps = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
        int day = (int)[comps day];
        int month = (int)[comps month];
        int year = (int)[comps year];
        
        float upperDashLineHeight = self.frame.size.height/6.5f;
        float num1;
        if (_maxTotal-_minTotal <=0) {
            num1 = 1;
        }else{
            num1 = _maxTotal-_minTotal;
        }
        float imageHeigh = (upperDashLineHeight*6-upperDashLineHeight*1)/num1;
        NSDateComponents *lastDay = [[NSDateComponents alloc] init];
        [lastDay setDay:-1];
        double totalValue =0.0f;
        double dailyValue = 0.0f;
        NetWorthData * data = [_netWorthDataDictionary objectForKey:date];
        if (data) {
            dailyValue = data->dailyValue;
        }
//        [crossLine setFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        for (int i = 0; i <= num; i++) {
            NetWorthData * data = [_netWorthDataDictionary objectForKey:date];
            if (data) {
                crossLine.hidden = NO;
                totalValue = data->totalValue;
                [crossLine setFrame:CGRectMake(0, upperDashLineHeight*6-((data->totalValue-_minTotal)*imageHeigh), self.frame.size.width, 0.5)];
                break;
            }else{
                
                date = [gregorian dateByAddingComponents:lastDay toDate:date options:0];
            }
        }
        NSString * dateStr = @"";
        if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS)
        {
            dateStr = [NSString stringWithFormat:@"%02d/%02d/%d",month,day,year];
        }else{
            dateStr = [NSString stringWithFormat:@"%d/%02d/%02d",year,month,day];
        }
        dateLabel.text = dateStr;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:[self dateFormateDefinition]];
        NSDate *touchDate = [formatter dateFromString:dateStr];
        if([_netWorthDataArray count] != 0){
            NetWorthData *data = [_netWorthDataArray objectAtIndex:0];
            if([CodingUtil makeDateFromDate:touchDate] >= [CodingUtil makeDateFromDate:data->date]){

                if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionCN) {
                    valueLabel.text = [NSString stringWithFormat:@"$%@",[CodingUtil CoverFloatWithCommaForCN:totalValue]];
                }else{
                    valueLabel.text = [NSString stringWithFormat:@"$%@",[CodingUtil CoverFloatWithComma:totalValue DecimalPoint:0]];
                }
            }else{
                valueLabel.text = @"";
            }
        }else{

            valueLabel.text = @"";
        }
        
        if (totalValue>0) {
            valueLabel.textColor = [StockConstant PriceUpColor];
        }else{
            valueLabel.textColor = [StockConstant PriceDownColor];
        }
        touchPoint.x = result;
        [_netWorthViewController doTouchesWithPoint:touchPoint Date:dateStr Value:dailyValue];
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
