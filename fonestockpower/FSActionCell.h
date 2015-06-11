//
//  FSActionCell.h
//  FonestockPower
//
//  Created by Derek on 2014/4/22.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSActionCell;
@protocol FSActionCellDelegate <NSObject>

@optional
- (void)toTableView:(FSActionCell *)cell;

@end

@interface FSActionCell : FSUITableViewCell

@property (strong, nonatomic) NSMutableArray *labels;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(NSUInteger)capacity;
@property (weak ,nonatomic) id<FSActionCellDelegate> delegate;

@end
