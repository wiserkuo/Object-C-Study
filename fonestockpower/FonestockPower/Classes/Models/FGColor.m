//
//  FGColor.m
//  WirtsLeg
//
//  Created by Connor on 13/12/3.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FGColor.h"

static NSArray *colorSwatchesList;

@implementation FGColor

+ (UIColor *)colorWithIndex:(NSUInteger)index {
    if (colorSwatchesList == nil) {
        colorSwatchesList = @[
                              [UIColor colorWithRed:196/255.0f green:0/255.0f blue:0/255.0f alpha:1],
                              [UIColor colorWithRed:68/255.0f green:153/255.0f blue:0/255.0f alpha:1],
                              [UIColor colorWithRed:178/255.0f green:92/255.0f blue:26/255.0f alpha:1],
                              [UIColor colorWithRed:0/255.0f green:143/255.0f blue:232/255.0f alpha:1],
                              [UIColor colorWithRed:255/255.0f green:0/255.0f blue:246/255.0f alpha:1],
                              [UIColor colorWithRed:255/255.0f green:128/255.0f blue:247/255.0f alpha:1],
                              [UIColor colorWithRed:190/255.0f green:236/255.0f blue:255/255.0f alpha:1]
                              ];
    }
    return [colorSwatchesList objectAtIndex:index % [colorSwatchesList count]];
}

@end
