//
//  FigureSearchModel.h
//  WirtsLeg
//
//  Created by Connor on 13/10/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FigureSearchDelegate;

enum CurrentOption {
    kFigureSearchSystemLong,
    kFigureSearchSystemShort,
    kFigureSearchMyProfileLong,
    kFigureSearchMyProfileShort
};

@interface FigureSearchModel : NSObject <UICollectionViewDataSource>
@property (unsafe_unretained, nonatomic) int currentOption;
+ (FigureSearchModel *)sharedInstance;

@end