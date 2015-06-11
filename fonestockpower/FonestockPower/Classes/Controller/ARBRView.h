//
//  ARBRView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/5.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottonView.h"


@interface ARBRView : UIView <AnalysisChart> {

    DrawAndScrollController *drawAndScrollController;
    BottonView *bottonView;
    NSObject<HistoricTickDataSourceProtocol> *historicData;

    CGRect chartFrame;
    CGPoint chartFrameOffset;
    NSInteger xLines;
    NSInteger yLines;
	int arParameter;
	int brParameter;	
    CGAffineTransform zoomTransform;

    CGFloat maxValue;
    CGFloat minValue;
    NSMutableArray *arValues;
    NSMutableArray *brValues;
    
    UInt8 type;
}

@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) CGFloat minValue;

@end
