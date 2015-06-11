//
//  FSNewsSnDataOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSNewsSnDataOut : NSObject<EncodeProtocol>{

    UInt16 sectorID;
}

-(id)initWithSectorID:(UInt16)sID;
@end
