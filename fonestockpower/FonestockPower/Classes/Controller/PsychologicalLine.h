//
//  PsychologicalLine.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/1/23.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface PsychologicalLine : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;
	NSMutableArray *psyValues;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int psyParameter;
    CGAffineTransform zoomTransform;
    
    NSRecursiveLock * dataLock;
}

@end
