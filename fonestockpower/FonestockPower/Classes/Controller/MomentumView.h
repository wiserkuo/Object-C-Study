//
//  MomentumView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/4.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface MomentumView : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int mtmParameter;
    CGAffineTransform zoomTransform;
	NSMutableArray *mtmValues;
	NSMutableArray *sumValues;
    CGFloat maxValue;
    
    NSInteger dataStartIndex;
}

@property (nonatomic, readonly) CGFloat maxValue;

@end
