//
//  NewsRelateIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"

@interface NewsRelateIn : NSObject <DecodeProtocol>{
@public
	UInt8 count;
	//new content format 3
	UInt8 flag;
	UInt16 totalNum;
	NSMutableArray *mimeArray;
	UInt32 commodityNo;
	UInt8 retCode;
}

@property (nonatomic,retain) NSMutableArray *mimeArray;

@end

@interface NewsContentFormat3 : NSObject{
@public
	UInt32 newsSN;
	UInt16 date;
	UInt16 time;
	UInt8 type;
	bool contentFlag;
	UInt8 reserved;
	UInt16 sectorID;
	UInt16 SN;
	UInt16 length;
	UInt8 *mimeData;
	NSString *mimeString;
}

@end
