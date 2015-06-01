//
//  FSAddActionEditCondictionCell.h
//  FonestockPower
//
//  Created by Derek on 2014/5/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSWatchlistItemProtocol.h"
#import "FSAddActionEditCondictionDelegate.h"
#import "MarqueeLabel.h"

@interface FSAddActionEditCondictionCell : FSUITableViewCell <UIActionSheetDelegate, UITextFieldDelegate>
#ifdef PatternPowerUS
@property (strong, nonatomic) MarqueeLabel *label;
#else
@property (strong, nonatomic) UILabel *label;
#endif
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) FSUIButton *nonButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
@property (strong ,nonatomic) id<FSAddActionEditCondictionDelegate> delegate;


@end
