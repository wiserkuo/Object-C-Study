//
//  SectorTableIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/25.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"


@interface SectorTableIn : NSObject <DecodeProtocol>{
@public
	UInt16 sectorDate;
	UInt16 sectorCount;
	NSMutableArray *sectorAdd;
	UInt16 sectorToRemoveCount;
	NSMutableArray *sectorRemove;
	UInt8 retCode;
}

@property (nonatomic,retain) NSMutableArray *sectorAdd;
@property (nonatomic,retain) NSMutableArray *sectorRemove;

@end


@interface AddSector : NSObject{
@public
	UInt16 sectorIDAdd;
	UInt8 flag;
	UInt16 sectorType;
	UInt8 sectorOrder;
	UInt8 nameLength;
	NSString *sectorName;
	UInt16 superID;
	UInt8 marketIDCount;
	UInt8 *marketID;
}

@property (nonatomic,copy) NSString *sectorName;

@end

@interface RemoveSector : NSObject{
@public
	UInt16 sectorIDRemove;
}
@end
