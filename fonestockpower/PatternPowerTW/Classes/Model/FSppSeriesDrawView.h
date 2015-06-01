//
//  FSppSeriesDrawView.h
//  FonestockPower
//
//  Created by CooperLin on 2014/12/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSppSeriesDrawView : UIView

@property (nonatomic) double theSellData;
@property (nonatomic) double marketSentiment;
@property (nonatomic) double theBuyData;
@property (nonatomic) double theForce;
@property (nonatomic) double totalOffsetForBuy;
@property (nonatomic) double totalOffsetForSell;

@property (nonatomic, strong) NSMutableArray *storeBuyArray;
@property (nonatomic, strong) NSMutableArray *storeSellArray;

@end
