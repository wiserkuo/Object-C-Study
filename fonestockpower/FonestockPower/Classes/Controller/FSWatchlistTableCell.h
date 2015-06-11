//
//  FSWatchlistTableCell.h
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface FSWatchlistTableCell : FSUITableViewCell
#ifdef PatternPowerUS
@property (nonatomic, strong) MarqueeLabel *nameLabel;
#else 
@property (nonatomic, strong) UILabel *nameLabel;
#endif
@property (nonatomic, strong) UILabel *dynamicLabel0;
@property (nonatomic, strong) UILabel *dynamicLabel1;
@property (nonatomic, strong) UILabel *dynamicLabel2;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) NSString * identCodeSymbol;
@property (nonatomic, strong) UIFont *defaultFont;
@end
