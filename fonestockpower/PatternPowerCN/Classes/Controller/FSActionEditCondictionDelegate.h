//
//  FSActionEditCondictionDelegate.h
//  FonestockPower
//
//  Created by Derek on 2014/5/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FSActionEditCondictionCell;

@protocol FSActionEditCondictionDelegate <NSObject>
@optional
-(void)cellButtonActionBegainWithCell:(FSActionEditCondictionCell *)cell;
-(void)cellButtonAction:(FSActionEditCondictionCell *)cell;

@end
