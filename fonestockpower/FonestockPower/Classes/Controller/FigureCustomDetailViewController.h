//
//  FigureCustomDetailViewController.h
//  FonestockPower
//
//  Created by CooperLin on 2015/1/12.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSUIViewController.h"

@interface FigureCustomDetailViewController : FSUIViewController

//typedef NS_ENUM(NSUInteger, FSFigureCustomSearchType) {
//    FSFigureCustomSearchTypeNothing = 0,        // 0: 任意值
//    FSFigureCustomSearchTypeEqualTo,            // 1: 約等於
//    FSFigureCustomSearchTypeBigger,             // 2: 大於
//    FSFigureCustomSearchTypeSmaller             // 3: 小於
//};
//在FigureSearch 資料表及FigureSearchKBarValue 資料表內，皆有該布林值
//在FigureSearch 資料表內還另外記錄有右方應顯示數字的日、週、月的值

-(instancetype)initWithNeededObjectFromDictionary:(NSDictionary *)sendObj :(int)currentOption :(int)searchNum :(int)kNumber :(NSMutableArray*)figureSearchArray;

@end
