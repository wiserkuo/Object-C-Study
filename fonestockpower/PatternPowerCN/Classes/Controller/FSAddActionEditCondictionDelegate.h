//
//  FSAddActionEditCondictionDelegate.h
//  FonestockPower
//
//  Created by Derek on 2014/5/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FSAddActionEditCondictionCell;

@protocol FSAddActionEditCondictionDelegate <NSObject>
@optional
-(void)cellButtonActionBegainWithCell:(FSAddActionEditCondictionCell *)cell;
-(void)cellButtonAction:(FSAddActionEditCondictionCell *)cell;

@end
