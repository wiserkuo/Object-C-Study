//
//  VolatilityDrawTopView.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/17.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VolatilityDrawTopView : UIView
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic) BOOL hvFlag;
@property (nonatomic) BOOL hv30Flag;
@property (nonatomic) BOOL hv60Flag;
@property (nonatomic) BOOL hv90Flag;
@property (nonatomic) BOOL hv120Flag;
@property (nonatomic) BOOL ivFlag;
@property (nonatomic) BOOL sivFlag;
@property (nonatomic) BOOL bivFlag;

@end
