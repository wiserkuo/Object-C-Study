//
//  DefaultDBData.h
//  WirtsLeg
//
//  Created by Neil on 14/4/9.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FigureSearchMyProfileModel;

@interface DefaultDBData : NSObject


@property (strong, nonatomic) NSString * group;
@property (strong) FigureSearchMyProfileModel * customModel;

-(void)setDefaultDBData;

@end
