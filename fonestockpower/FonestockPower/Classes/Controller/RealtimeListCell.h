//
//  RealtimeListCell.h
//  Bullseye
//
//  Created by Ray Kuo on 2009/2/16.
//  Copyright 2009 TelePaq Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RealtimeListCell : FSUITableViewCell {
    BOOL hasBidAsk;
}

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *bidLabel;
@property (nonatomic, strong) UILabel *askLabel;
@property (nonatomic, strong) UILabel *tradeLabel;
@property (nonatomic, strong) UILabel *chgLabel;
@property (nonatomic, strong) UILabel *volLabel;

- (id)initWithStyle:(UITableViewCellStyle)style HasBidAsk:(BOOL)bidAsk;
//- (void)type19NotifyDataArrive;
//- (void)esmDataDataArrive;
@end
