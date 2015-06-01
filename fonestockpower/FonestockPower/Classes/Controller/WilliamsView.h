//
//  WilliamsView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/2.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface WilliamsView : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;
	NSMutableArray *williamsValues;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int williamsParameter;
    CGAffineTransform zoomTransform;
    NSInteger dataStartIndex;
}

@end
