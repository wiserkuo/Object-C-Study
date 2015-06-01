//
//  TechInfoView.h
//  FonestockPower
//
//  Created by Kenny on 2014/12/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TechInfoView : UIView
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *openTitle;
@property (nonatomic, strong) UILabel *highTitle;
@property (nonatomic, strong) UILabel *lowTitle;
@property (nonatomic, strong) UILabel *lastTitle;
@property (nonatomic, strong) UILabel *changeTitle;
@property (nonatomic, strong) UILabel *whiteLabel;
@property (nonatomic, strong) UILabel *volumeTitle;
@property (nonatomic, strong) UILabel *open;
@property (nonatomic, strong) UILabel *high;
@property (nonatomic, strong) UILabel *low;
@property (nonatomic, strong) UILabel *last;
@property (nonatomic, strong) UILabel *change;
@property (nonatomic, strong) UILabel *changeRate;
@property (nonatomic, strong) UILabel *volume;
@property (nonatomic, strong) UIView *topView;
@end
