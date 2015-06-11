//
//  NewsTitleIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"

@interface NewsTitleIn : NSObject <DecodeProtocol>{
@public
	UInt16 date;
	UInt16 year;
	UInt8 month;
	UInt8 day;
	UInt16 sectorID;
	UInt16 count;
	// new content format 1
	NSMutableArray *mimeArray;
	UInt8 retCode;
}

@property (nonatomic,retain) NSMutableArray *mimeArray;

@end

//@interface NewsContentFormat1 : NSObject{
//@public
////	UInt16 date;
////	UInt16 sectorID;
//	UInt16 SN;
//	UInt32 newsSN;
//	UInt16 time;
//	UInt8 type;
//	bool contentFlag;
//	UInt8 reserved;
//	UInt16 length;
//	UInt8 *mimeData;
//	NSString *mimeString;
//}
//
//@end

