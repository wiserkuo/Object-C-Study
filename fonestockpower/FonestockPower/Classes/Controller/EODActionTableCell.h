//
//  EDOActionTableCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/5/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EODActionTableCellDelegate <NSObject>
@required
-(void)btnBeClick:(NSInteger)row;
@end

@interface EODActionTableCell : FSUITableViewCell <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) id<EODActionTableCellDelegate>delegate;
@property (strong, nonatomic) UILabel *stockName;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *imageTitle;
@property (strong, nonatomic) UIView *verticalLine;
@property (strong, nonatomic) UIView *rightView;
@property (strong, nonatomic) UIView *horizontalLine;
@property (strong, nonatomic) UICollectionView *collectionView;
-(void)setCount:(int)count;
-(void)setImgArray:(NSMutableArray*)array;
-(void)setNameArray:(NSMutableArray*)array;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controller:(id)obj;
@end
