//
//  FSBAIn.h
//  FonestockPower
//
//  Created by Neil on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBAIn : NSObject<DecodeProtocol>

@end

@interface BAData_bValue : NSObject{
@public
    float bidPrice;
    float bidVolume;
    float askPrice;	
    float askVolume;
}
@end
