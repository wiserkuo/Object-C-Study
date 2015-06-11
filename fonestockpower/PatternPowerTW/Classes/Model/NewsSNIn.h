//
//  NewsSNIn.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecodeProtocol.h"


@interface NewsSNIn : NSObject <DecodeProtocol>{
@public
	UInt16 newsSectorID;
	UInt16 year;
	UInt8 month;
	UInt8 day;
	UInt8 count;
	UInt16 *sectorID;   //???é¡?ä»?ç¢? 
	UInt16 *SN;         //??¾å?¨æ????°ç??sn 
	UInt8 retCode;
}

@end
