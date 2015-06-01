//
//  ShowResultTableViewCell.h
//  DivergenceStock
//
//  Created by CooperLin on 2014/12/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUITableViewCell.h"

@protocol FSDivergenceMainCellDelegate <NSObject>
@required
-(void)cellBtnBeClicked:(NSInteger)indexRow sender:(UIButton *)sender;
@end

@interface ShowResultTableViewCell : FSUITableViewCell

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UILabel *mainLbl;
@property (nonatomic, strong) UILabel *detailLbl;
@property (nonatomic, strong) UIButton *VolBtn;
@property (nonatomic, strong) UIButton *KdBtn;
@property (nonatomic, strong) UIButton *RsiBtn;
@property (nonatomic, strong) UIButton *MacdBtn;
@property (nonatomic, strong) UIButton *ObvBtn;

@property (nonatomic, weak) id<FSDivergenceMainCellDelegate> delegate;

-(instancetype)initWithCustomTableViewCell:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
