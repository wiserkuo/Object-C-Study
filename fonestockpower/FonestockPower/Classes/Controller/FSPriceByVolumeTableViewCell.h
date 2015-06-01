//
//  FSPriceByVolumeTableViewCell.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSPriceByVolumeTableViewCell : FSUITableViewCell {
    
}
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *volumeLabel;
//percentage值為0~100
@property (nonatomic, strong) UILabel *percentageLabel;
@property (nonatomic, strong) UILabel *innerLabel;
@property (nonatomic, strong) UILabel *outerLabel;
@property (nonatomic, strong) UILabel *tickCountLabel;
@property (nonatomic) BOOL hasPlat;

@end
