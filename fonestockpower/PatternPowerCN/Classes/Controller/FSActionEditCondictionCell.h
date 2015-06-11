//
//  FSActionEditCondictionCell.h
//  FonestockPower
//
//  Created by Derek on 2014/5/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSWatchlistItemProtocol.h"
#import "FSActionEditCondictionDelegate.h"
#import "MarqueeLabel.h"

@interface FSActionEditCondictionCell : FSUITableViewCell <UIActionSheetDelegate, UITextFieldDelegate>
@property (strong, nonatomic) NSIndexPath *indexPath;
#ifdef PatternPowerUS
@property (strong, nonatomic) MarqueeLabel *label;
#else
@property (strong, nonatomic) UILabel *label;
#endif
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;
@property (strong ,nonatomic) id<FSActionEditCondictionDelegate> delegate;


@end
