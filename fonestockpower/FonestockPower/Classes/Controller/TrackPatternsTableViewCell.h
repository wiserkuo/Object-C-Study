//
//  EODTrackPatternsTableViewCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TrackTableViewCellDelegate <NSObject>
@required
-(void)trackBeClick:(UITableViewCell *)cell Btn:(FSUIButton *)sender Row:(NSInteger)row;
@end

@interface TrackPatternsTableViewCell : FSUITableViewCell
@property (nonatomic, weak) id<TrackTableViewCellDelegate>delegate;
@property (nonatomic, strong) UIImageView *leftImage;
@property (nonatomic, strong) UILabel *imageName;
@property (nonatomic, strong) UILabel *verticalLine1;
@property (nonatomic, strong) UILabel *horizonLine1;
@property (nonatomic, strong) UILabel *horizonLine2;
@property (nonatomic, strong) UILabel *topViewVerticalLine;
@property (nonatomic, strong) UILabel *centerViewVerticalLine;
@property (nonatomic, strong) UILabel *bottomViewVerticalLine;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *dayContentLabel;
@property (nonatomic, strong) UILabel *weekContentLabel;
@property (nonatomic, strong) UILabel *monthContentLabel;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIButton *topBtn;
@property (nonatomic, strong) UIButton *centerBtn;
@property (nonatomic, strong) UIButton *bottomBtn;
@end
