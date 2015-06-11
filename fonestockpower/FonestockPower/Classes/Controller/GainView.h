//
//  GainView.h
//  FonestockPower
//
//  Created by Neil on 2014/7/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"
@class DrawAndScrollController;

@interface GainView : UIView<AnalysisChart>

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,strong) BottonView *bottonView;

@property (nonatomic,strong) NSObject<HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;

@property (nonatomic) CGAffineTransform zoomTransform;

@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat minValue;

@property (nonatomic,strong) NSMutableDictionary *dataDictionary;

@property (nonatomic) BOOL status;//YES:Long NO:Short

-(id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;
@end
