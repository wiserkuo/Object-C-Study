//
//  FigureSearchUSOut.h
//  WirtsLeg
//
//  Created by Connor on 13/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FigureSearchUS.h"

@interface FigureSearchUSOut : NSObject <EncodeProtocol>
{
    UInt8 _sectorCount;
    UInt16 *_sectorIDs;
    UInt8 _flag;
    UInt8 _sn;
    UInt8 _reqCount;
    UInt16 _equationLen;
    UInt8 *_equationString;
}

- (instancetype)initWithFigureSearchUSFeeType:(enum FigureSearchUSFeeType)type SectorIDs:(UInt16 *)sectorIDs sectorIDsCount:(UInt8)sectorIDsCount flag:(UInt8)flag sn:(UInt8)sn reqCount:(UInt8)reqCount equationLen:(UInt16)equationLen equationString:(UInt8 *)equationString;

@end