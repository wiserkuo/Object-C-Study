//
//  FigureSearchViewLayout.m
//  WirtsLeg
//
//  Created by Connor on 13/10/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchViewLayout.h"

@implementation FigureSearchViewLayout

- (id)init {
    if (self = [super init]) {
        self.itemSize = CGSizeMake(85, 85);
        self.minimumInteritemSpacing = 15;
        self.minimumLineSpacing = 40;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 40, 10);
    }
    return self;
}

@end