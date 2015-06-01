//
//  FSDiaryCell.h
//  FonestockPower
//
//  Created by Derek on 2014/9/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSDiaryCell;
@protocol FSDiaryCellDelegate <NSObject>

@optional
- (void)toTableView:(FSDiaryCell *)cell;

@end

@interface FSDiaryCell : FSUITableViewCell

@property (strong, nonatomic) NSMutableArray *labels;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;
@property (weak ,nonatomic) id<FSDiaryCellDelegate> delegate;

@end
