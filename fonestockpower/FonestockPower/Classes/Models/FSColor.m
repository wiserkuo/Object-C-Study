//
//  FSColor.m
//  FonestockPower
//
//  Created by Connor on 14/4/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSColor.h"

static NSArray *colorSwatchesList;

@implementation FSColor
+ (UIColor *)colorWithIndex:(NSUInteger)index {
    if (colorSwatchesList == nil) {
        colorSwatchesList = @[
                              [UIColor colorWithRed:196/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f],
                              [UIColor colorWithRed:68/255.0f green:153/255.0f blue:0/255.0f alpha:1.0f],
                              [UIColor colorWithRed:255/255.0f green:166/255.0f blue:1/255.0f alpha:1.0f],
                              [UIColor colorWithRed:0/255.0f green:143/255.0f blue:232/255.0f alpha:1.0f],
                              [UIColor colorWithRed:255/255.0f green:0/255.0f blue:246/255.0f alpha:1.0f],
                              [UIColor colorWithRed:255/255.0f green:128/255.0f blue:247/255.0f alpha:1.0f],
                              [UIColor colorWithRed:190/255.0f green:236/255.0f blue:255/255.0f alpha:1.0f]
                              ];
    }
    return [colorSwatchesList objectAtIndex:index % [colorSwatchesList count]];
}
@end
