//
//  FigureTrackListViewController.h
//  WirtsLeg
//
//  Created by Neil on 13/10/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FigureTrackListViewController : FSUIViewController

- (id)initWithTrackUpArray:(NSMutableArray *)trackUpArray FigureSearchName:(NSString *)name FigureSearchId:(NSNumber *)figureSearchId Range:(NSString *)range;

@end
