//
//  CrossInfoView.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/1/9.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CrollInfoProtocol

- (void)openCrossView:(BOOL)toOpen;

@end


@class DrawAndScrollController;

@interface CrossInfoView : UIView {
	
    UILabel *openLabelTitle;
    UILabel *highLabelTitle;
    UILabel *lowLabelTitle;
    UILabel *closeLabelTitle;
    UILabel *chgLabelTitle;
    UILabel *chgPerLabelTitle;
    UILabel *volumeLabelTitle;
	
    UILabel *dateLabel;
    UILabel *openLabel;
    UILabel *highLabel;
    UILabel *lowLabel;
    UILabel *closeLabel;
    UILabel *chgLabel;
    UILabel *chgPerLabel;
    UILabel *volumeLabel;
	
    NSObject *viewController;
	
	BOOL portraitFlag;		//判斷是橫式 或 直式
}

@property (nonatomic, strong) UILabel *openLabelTitle;
@property (nonatomic, strong) UILabel *highLabelTitle;
@property (nonatomic, strong) UILabel *lowLabelTitle;
@property (nonatomic, strong) UILabel *closeLabelTitle;
@property (nonatomic, strong) UILabel *chgLabelTitle;
@property (nonatomic, strong) UILabel *chgPerLabelTitle;
@property (nonatomic, strong) UILabel * stock1CloseTitle;
@property (nonatomic, strong) UILabel * stock2CloseTitle;
@property (nonatomic, strong) UILabel * stock1VolumeTitle;
@property (nonatomic, strong) UILabel * stock2VolumeTitle;
@property (nonatomic, strong) UILabel *volumeLabelTitle;

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *openLabel;
@property (nonatomic, strong) UILabel *highLabel;
@property (nonatomic, strong) UILabel *lowLabel;
@property (nonatomic, strong) UILabel *closeLabel;
@property (nonatomic, strong) UILabel *chgLabel;
@property (nonatomic, strong) UILabel *chgPerLabel;
@property (nonatomic, strong) UILabel * stock1Close;
@property (nonatomic, strong) UILabel * stock2Close;
@property (nonatomic, strong) UILabel * stock1Volume;
@property (nonatomic, strong) UILabel * stock2Volume;
@property (nonatomic, strong) UILabel *volumeLabel;

@property (nonatomic, strong) NSObject *viewController;
@property (nonatomic) BOOL isCrossInfoShowing;
@property (assign) BOOL portraitFlag;

-(void)setTitleStringWithType:(int)type realtimeOrHistoric:(int)chartType;

@end
