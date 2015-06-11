//
//  DMIView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/6.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface DMIView : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int dmiParameter;
    CGAffineTransform zoomTransform;

    CGFloat maxValue;
    CGFloat minValue;

    NSMutableArray *plusValues;
    NSMutableArray *minusValues;
    NSMutableArray *adxValues;
    
    UInt8 type;
}

@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat minValue;

@end
