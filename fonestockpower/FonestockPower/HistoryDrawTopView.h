//
//  HistoryDrawTopView.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDrawTopView : UIView
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *comparedItemArray;
@property (nonatomic) int viewWidth;
@property (nonatomic) int contentSize;
@property (nonatomic) int contentOffSet;
@end
