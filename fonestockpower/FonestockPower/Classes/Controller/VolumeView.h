//
//  VolumeView.h
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/1/4.
//  Copyright 2009 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"

@class DrawAndScrollController;
@class BottonView;

@interface VolumeView : UIView <AnalysisChart> {
	
	DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
	
    NSObject<HistoricTickDataSourceProtocol> *historicData;
	
	CGRect chartFrame;
	CGPoint chartFrameOffset;
	
	NSInteger xLines;
	NSInteger yLines;
    
    int volParameter1;
    int volParameter2;

    CGAffineTransform zoomTransform;
    
    UInt8 type;
    
    NSRecursiveLock * dataLock;
    NSMutableArray * AVSArray;
    NSMutableArray * AVLArray;
}

@property (nonatomic, strong) DrawAndScrollController *drawAndScrollController;

@property (nonatomic,strong) BottonView *bottonView;

@property (nonatomic,strong) NSObject<HistoricTickDataSourceProtocol> *historicData;

@property (nonatomic) CGRect chartFrame;
@property (nonatomic) CGPoint chartFrameOffset;

@property (nonatomic,readwrite) NSInteger xLines;
@property (nonatomic,readwrite) NSInteger yLines;

@property (nonatomic) CGAffineTransform zoomTransform;

- (id)initWithChartFrame:(CGRect)frame chartFrameOffset:(CGPoint)offset;



@end
