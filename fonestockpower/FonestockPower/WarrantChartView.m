//
//  WarrantChartView.m
//  FonestockPower
//
//  Created by Kenny on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantChartView.h"

@implementation WarrantChartView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        
//    }
//    return self;
//}
-(id)initWithController:(WarrantChartViewController *)controller
{
    self = [super init];
    if (self){
        self.controller = controller;
        self.symbolName = [[UILabel alloc] init];
        _symbolName.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_symbolName];
        
        self.leftTopView = [[UIView alloc] init];
        _leftTopView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftTopView];
        
        self.leftBottomView = [[UIView alloc] init];
        _leftBottomView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftBottomView];
        
        self.chartView = [[WarrantDrawView alloc] initWithController:self.controller];
        _chartView.layer.borderWidth = 1.0f;
        _chartView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_chartView];
        
        self.rightView = [[UIView alloc] init];
        _rightView.layer.borderWidth = 1.0f;
        _rightView.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:230.0/255.0 blue:144.0/255.0 alpha:1];
        _rightView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rightView];
        
        UIColor *labelColor = [UIColor colorWithRed:30.0/255.0 green:122/255.0 blue:172/255.0 alpha:1];
        self.buyLabel = [[UILabel alloc] init];
        _buyLabel.text = @"買進";
        _buyLabel.textColor = labelColor;
        _buyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_buyLabel];
        
        self.sellLabel = [[UILabel alloc] init];
        _sellLabel.text = @"賣出";
        _sellLabel.textColor = labelColor;
        _sellLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_sellLabel];
        
        self.tradeLabel = [[UILabel alloc] init];
        _tradeLabel.text = @"成交";
        _tradeLabel.textColor = labelColor;
        _tradeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_tradeLabel];
        
        self.highLabel = [[UILabel alloc] init];
        _highLabel.text = @"最高";
        _highLabel.textColor = labelColor;
        _highLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_highLabel];
        
        self.lowLabel = [[UILabel alloc] init];
        _lowLabel.text = @"最低";
        _lowLabel.textColor = labelColor;
        _lowLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_lowLabel];
        
        self.upDownLabel = [[UILabel alloc] init];
        _upDownLabel.text = @"漲跌";
        _upDownLabel.textColor = labelColor;
        _upDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_upDownLabel];
        
        self.upRatioLabel = [[UILabel alloc] init];
        _upRatioLabel.text = @"漲幅";
        _upRatioLabel.textColor = labelColor;
        _upRatioLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_upRatioLabel];
        
        self.volumeLabel = [[UILabel alloc] init];
        _volumeLabel.text = @"單量";
        _volumeLabel.textColor = labelColor;
        _volumeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_volumeLabel];
        
        self.buyValue = [[UILabel alloc] init];
        _buyValue.textAlignment = NSTextAlignmentCenter;
        _buyValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_buyValue];
        
        self.sellValue = [[UILabel alloc] init];
        _sellValue.textAlignment = NSTextAlignmentCenter;
        _sellValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_sellValue];
        
        self.tradeValue = [[UILabel alloc] init];
        _tradeValue.textAlignment = NSTextAlignmentCenter;
        _tradeValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_tradeValue];
        
        self.highValue = [[UILabel alloc] init];
        _highValue.textAlignment = NSTextAlignmentCenter;
        _highValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_highValue];
        
        self.lowValue = [[UILabel alloc] init];
        _lowValue.textAlignment = NSTextAlignmentCenter;
        _lowValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_lowValue];
        
        self.upDownValue = [[UILabel alloc] init];
        _upDownValue.textAlignment = NSTextAlignmentCenter;
        _upDownValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_upDownValue];
        
        self.upRatioValue = [[UILabel alloc] init];
        _upRatioValue.textAlignment = NSTextAlignmentCenter;
        _upRatioValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_upRatioValue];
        
        self.volumeValue = [[UILabel alloc] init];
        _volumeValue.textColor = [UIColor blueColor];
        _volumeValue.textAlignment = NSTextAlignmentCenter;
        _volumeValue.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_volumeValue];
        
        self.verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = [UIColor blackColor];
        _verticalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self.rightView addSubview:_verticalLine];
        
        dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithDouble:(self.viewForBaselineLayout.frame.size.height - 20) / 3] forKey:@"BottomChartViewHeight"];
        [self processLayout];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_symbolName, _leftTopView, _leftBottomView, _chartView,  _rightView, _buyLabel, _sellLabel, _tradeLabel, _highLabel, _lowLabel, _upDownLabel, _upRatioLabel, _volumeLabel, _buyValue, _sellValue, _tradeValue, _highValue, _lowValue, _upDownValue, _upRatioValue, _volumeValue, _verticalLine);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_symbolName]" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightView(110)]|" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftTopView(50)][_chartView][_rightView(110)]|" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftBottomView(50)][_chartView][_rightView(110)]|" options:0 metrics:nil views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_symbolName(20)][_leftTopView][_leftBottomView(80)]|" options:0 metrics:dict views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_symbolName(20)][_chartView]|" options:0 metrics:dict views:viewController]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightView]|" options:0 metrics:nil views:viewController]];
    
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_buyLabel(40)][_verticalLine(1)]-3-[_buyValue]|" options:0 metrics:nil views:viewController]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_sellLabel][_verticalLine(1)]-3-[_sellValue]|" options:0 metrics:nil views:viewController]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_tradeLabel][_verticalLine(1)]-3-[_tradeValue]|" options:0 metrics:nil views:viewController]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_highLabel][_verticalLine(1)]-3-[_highValue]|" options:0 metrics:nil views:viewController]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_lowLabel][_verticalLine(1)]-3-[_lowValue]|" options:0 metrics:nil views:viewController]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_upDownLabel][_verticalLine(1)]-3-[_upDownValue]|" options:0 metrics:nil views:viewController]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_upRatioLabel][_verticalLine(1)]-3-[_upRatioValue]|" options:0 metrics:nil views:viewController]];
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_volumeLabel][_verticalLine(1)]-3-[_volumeValue]|" options:0 metrics:nil views:viewController]];
    
    
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buyLabel][_sellLabel(==_buyLabel)][_tradeLabel(==_buyLabel)][_highLabel(==_buyLabel)][_lowLabel(==_buyLabel)][_upDownLabel(==_buyLabel)][_upRatioLabel(==_buyLabel)][_volumeLabel(==_buyLabel)]|" options:0 metrics:nil views:viewController]];
    
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buyValue][_sellValue(==_buyValue)][_tradeValue(==_buyValue)][_highValue(==_buyValue)][_lowValue(==_buyValue)][_upDownValue(==_buyValue)][_upRatioValue(==_buyValue)][_volumeValue(==_buyValue)]|" options:0 metrics:nil views:viewController]];
    
    [self.rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_verticalLine(300)]" options:0 metrics:nil views:viewController]];
    
    
}

-(void)setDataAndDraw:(NSMutableArray *)data timeData:(NSMutableArray *)timeArray volumeData:(NSMutableArray *)volumeArray ReferencePrice:(double)rp CeilingPrice:(double)cp FloorPrice:(double)fp  startTime:(int)time;
{
    self.chartView.priceArray = data;
    self.chartView.timeArray = timeArray;
    self.chartView.volumeArray = volumeArray;
    self.chartView.referencePrice = rp;
    self.chartView.ceilingPrice = cp;
    self.chartView.floorPrice = fp;
    self.chartView.startTime = time;
    [self.chartView setNeedsDisplay];
}

@end
