//
//  BoardHolding.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardHoldingIn.h"

@protocol BoardHoldingDelegate;
@interface BoardHolding : NSObject
-(void)sendAndRead;
-(void)HDataCallBack:(BoardHoldingIn *)data;
-(void)PDataCallBack:(BoardHoldingIn *)data;
@property (nonatomic, weak) NSObject <BoardHoldingDelegate> *delegate;
@end

@protocol  BoardHoldingDelegate <NSObject>
-(void)BoardHoldingNotifyData:(id)target;
@end

