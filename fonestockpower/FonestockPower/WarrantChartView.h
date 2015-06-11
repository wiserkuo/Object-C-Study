//
//  WarrantChartView.h
//  FonestockPower
//
//  Created by Kenny on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WarrantDrawView.h"
#import "WarrantChartViewController.h"
@interface WarrantChartView : UIView
{
    NSMutableDictionary *dict;
}
@property (nonatomic, strong) UILabel *symbolName;
@property (nonatomic, strong) UIView *leftTopView;
@property (nonatomic, strong) UIView *leftBottomView;
@property (nonatomic, strong) WarrantDrawView *chartView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UILabel *buyLabel;
@property (nonatomic, strong) UILabel *sellLabel;
@property (nonatomic, strong) UILabel *tradeLabel;
@property (nonatomic, strong) UILabel *highLabel;
@property (nonatomic, strong) UILabel *lowLabel;
@property (nonatomic, strong) UILabel *upDownLabel;
@property (nonatomic, strong) UILabel *upRatioLabel;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UILabel *buyValue;
@property (nonatomic, strong) UILabel *sellValue;
@property (nonatomic, strong) UILabel *tradeValue;
@property (nonatomic, strong) UILabel *highValue;
@property (nonatomic, strong) UILabel *lowValue;
@property (nonatomic, strong) UILabel *upDownValue;
@property (nonatomic, strong) UILabel *upRatioValue;
@property (nonatomic, strong) UILabel *volumeValue;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) WarrantChartViewController *controller;
-(void)setDataAndDraw:(NSMutableArray *)data timeData:(NSMutableArray *)timeArray volumeData:(NSMutableArray *)volumeArray ReferencePrice:(double)rp CeilingPrice:(double)cp FloorPrice:(double)fp startTime:(int)time;
-(id)initWithController:(WarrantChartViewController *)controller;
@end
