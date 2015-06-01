//
//  PatternTipsTableViewCell.h
//  FonestockPower
//
//  Created by Kenny on 2015/1/14.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatternsTipsCollectionCell.h"
#import "MarqueeLabel.h"
@protocol PatternTipsTableViewCellDelegate <NSObject>

@required
-(void)cellBtnBeClicked:(NSInteger)cellTag CollectionRow:(NSInteger)collectionRow;
@end

@interface PatternTipsTableViewCell : FSUITableViewCell<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) id<PatternTipsTableViewCellDelegate>delegate;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) MarqueeLabel *imgName;
@property (nonatomic, strong) UILabel *imgCount;
@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UICollectionView *collectionView;
-(void)setImgArray:(NSMutableArray*)array;
@end
