//
//  BoardMemberTransfer.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardMemberTransferIn.h"

@protocol BoardMemberTransferDelegate;

@interface BoardMemberTransfer : NSObject
-(void)sendAndRead;
-(void)BoardMemberTransferDataCallBack:(BoardMemberTransferIn *)data;

@property (nonatomic, weak) NSObject <BoardMemberTransferDelegate> *delegate;
@end

@protocol  BoardMemberTransferDelegate <NSObject>
-(void)notifyBoardMemberTransferData:(id)target;
@end
