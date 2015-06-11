//
//  FSBrokerBranchOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBrokerBranchOut : NSObject<EncodeProtocol>{
    
    UInt16 date;
}

-(id)initWithDate:(UInt16)d;
@end
