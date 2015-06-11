//
//  BiasView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/2.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface BiasView : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int biasParameter;
    CGAffineTransform zoomTransform;

    NSMutableArray *biasValues;
    CGFloat maxValue;
    
    UInt8 type;
}

@property (nonatomic, readonly) CGFloat maxValue;

@end
