//
//  InvesterHold.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InvesterHoldIn.h"
#import "InvesterHoldOut.h"
@protocol InvesterHoldDelegate;
@interface InvesterHold : NSObject

- (void)sendAndRead;
- (void)InvesterDataCallBack1:(InvesterHoldIn *)data;
- (void)InvesterDataCallBack2:(InvesterHoldIn *)data;
- (void)InvesterDataCallBack3:(InvesterHoldIn *)data;
@property (nonatomic, weak) NSObject <InvesterHoldDelegate> *delegate;
@end

@protocol InvesterHoldDelegate <NSObject>
- (void)InvesterNotifyData:(id)target;
@end
