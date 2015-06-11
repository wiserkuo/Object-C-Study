//
//  CompanyProfilePage1Cell.h
//  WirtsLeg
//
//  Created by Connor on 13/11/12.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

#define CELL_TITLE_CONTENT_WIDTH 90.0f

@interface CompanyProfilePage1Cell : FSUITableViewCell
@property (strong, nonatomic) MarqueeLabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end
