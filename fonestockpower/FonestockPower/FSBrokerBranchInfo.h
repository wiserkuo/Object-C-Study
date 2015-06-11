//
//  FSBrokerBranchInfo.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSBrokerBranchIn.h"

@protocol FSBrokerBranchInfoProtocol <NSObject>

-(void)notify;

@end

@interface FSBrokerBranchInfo : NSObject{
    
    NSObject <FSBrokerBranchInfoProtocol> *notifyTarget;
    NSRecursiveLock *lock;
    
}

-(void)syncBrokerBranchInfo:(FSBrokerBranchIn *) obj;
-(void)setTarget:(NSObject <FSBrokerBranchInfoProtocol> *) obj;

@end
