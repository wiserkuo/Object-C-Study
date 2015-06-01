//
//  VIPDueDateIn.h
//  Bullseye
//
//  Created by Neil on 13/8/30.
//
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"


@interface VIPDueDateIn : NSObject<DecodeProtocol>{
@public
    //系統日期
    UInt16 systemDate;
	UInt16 systemYear;
	UInt8 systemMonth;
	UInt8 systemDay;
    //即時盤到日期
    UInt16 deadLineDate;
	UInt16 deadLineYear;
	UInt8 deadLineMonth;
	UInt8 deadLineDay;
    
    UInt16 count;
    UInt8 retCode;
    
    UInt8 * companyId;
    UInt16 * consultancyId;
    UInt16 * expireDate;
    UInt8 * reviseFlag;
    
    UInt16 * expireYear;
	UInt8 * expireMonth;
	UInt8 * expireDay;
}

@end
