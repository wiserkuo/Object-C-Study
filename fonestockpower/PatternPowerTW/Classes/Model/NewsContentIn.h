//
//  NewsContentIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"


@interface NewsContentIn : NSObject <DecodeProtocol>{
@public
	UInt8 type;
	// type0
	UInt32 newsSN;
	// type1
	UInt16 date;
	UInt16 year;
	UInt8 month;
	UInt8 day;
	UInt16 sectorID;
	UInt16 SN;
	UInt8 count;
	NSMutableArray *mimeArray;
	UInt8 retCode;
}

@property (nonatomic,retain) NSMutableArray *mimeArray;
@end

@interface NewsContentFormat2 : NSObject{
@public
//	UInt16 date;
//	UInt16 sectorID;
//	UInt16 SN;
	UInt16 length;
	UInt8 *mimeData;
	NSString *mimeString;
}

@end
