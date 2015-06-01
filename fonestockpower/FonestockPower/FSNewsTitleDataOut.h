//
//  FSNewsTitleDataOut.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSNewsTitleDataOut : NSObject<EncodeProtocol>{
    
    UInt16 sectorID;
    UInt16 beginSN;
    UInt16 endSN;
}

-(id)initWithSectorID:(UInt16)s beginSN:(UInt16)bSN endSN:(UInt16)eSN;
-(id)initWithSectorID:(UInt16)s beginSN:(UInt16)bSN;
@end
