//
//  OBVView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/3.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface OBVView : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int obvParameter;
    CGAffineTransform zoomTransform;

    NSMutableArray *obvValues;
    double maxValue;
    UInt8 maxVolUnit;
    UInt8 type;
}

@property (nonatomic, readonly) double maxValue;
@property (nonatomic, readonly) UInt8 maxVolUnit;

@end
