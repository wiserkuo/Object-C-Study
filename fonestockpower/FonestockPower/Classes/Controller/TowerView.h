//
//  TowerView.h
//  Bullseye
//
//  Created by Yehsam on 2009/3/2.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"

@interface TowerView : UIView <AnalysisChart>{
	DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
	
    NSObject<HistoricTickDataSourceProtocol> *historicData;
	
	CGRect chartFrame;
	CGPoint chartFrameOffset;

	CGFloat maxValue;
    CGFloat minValue;

	NSInteger xLines;
	NSInteger yLines;
	int towerParameter;
	NSMutableArray *openValues;
    NSMutableArray *closeValues;
	NSMutableArray *colorValues;

	CGAffineTransform zoomTransform;
    
    UInt8 type;
}

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,strong) BottonView *bottonView;
@property (nonatomic,strong) NSObject<HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;

@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat minValue;


@property (nonatomic) CGAffineTransform zoomTransform;

-(id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;

@end
