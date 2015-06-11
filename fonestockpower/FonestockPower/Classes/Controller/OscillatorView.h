//
//  OscillatorView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/5.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface OscillatorView : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int oscParameter;
    CGAffineTransform zoomTransform;
	
	NSMutableArray *oscValues;
	NSMutableArray *sumValues;

    CGFloat maxValue;
    CGFloat minValue;
    NSInteger dataStartIndex;
}

@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat minValue;

@end
