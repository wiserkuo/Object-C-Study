//
//  SectorTableOut.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncodeProtocol.h"

typedef struct _sync{
	UInt8 sectorIDsync[2];  //sector id to sync. If 0, to sync. all root sectors 
	UInt8 recursive;  //0:only sync ???; 1:sync recursively 
	UInt8 STdate[2];  
	UInt8 ifsync;     //1??????ไป?????, 0 ??????? 
}SectorTableOutData, *SectorTableOutRef;


@interface SectorTableOut : NSObject <EncodeProtocol>{
	SectorTableOutData headerData;
	UInt16 sectorCount;  //	client root sector count 
	UInt16 *sectorID;     // client root sector ids 
}

- (void)makedate:(int)year month:(int)month day:(int)day;
- (void)setdate:(UInt16)date;
- (id)initWithIDsync:(UInt16)sID recursive:(UInt8)r Sync:(UInt8)ifsync sectorCount:(UInt16)c sectorID:(UInt16*)d;

@end
