//
//  BoardMemberHolding.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardMemberHoldingIn.h"

@protocol BoardMemberHoldingDelegate;

@interface BoardMemberHolding : NSObject
-(void)sendAndRead;
-(void)BoardMemberHoldingDataCallBack:(BoardMemberHoldingIn *)data;

@property (nonatomic, weak) NSObject <BoardMemberHoldingDelegate> *delegate;
@end

@protocol  BoardMemberHoldingDelegate <NSObject>
-(void)notifyBoardMemberHoldingData:(id)target;
@end

