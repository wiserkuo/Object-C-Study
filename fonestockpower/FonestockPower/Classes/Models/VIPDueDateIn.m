//
//  VIPDueDateIn.m
//  Bullseye
//
//  Created by Neil on 13/8/30.
//
//

#import "VIPDueDateIn.h"
#import "CodingUtil.h"

@implementation VIPDueDateIn


- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    UInt8 *tmpPtr;
	tmpPtr = body;
    
    //系統日期
    systemDate = [CodingUtil getUInt16:tmpPtr];
    NSLog(@"%hu",systemDate);
	systemYear = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:7]+1960;
    NSLog(@"%hu",systemYear);
	systemMonth = [CodingUtil getUint8FromBuf:tmpPtr Offset:7 Bits:4];
    NSLog(@"%hhu",systemMonth);
	systemDay = [CodingUtil getUint8FromBuf:tmpPtr Offset:11 Bits:5];
    NSLog(@"%hhu",systemDay);
	tmpPtr+=2;
    //即時盤到期日
    deadLineDate = [CodingUtil getUInt16:tmpPtr];
	deadLineYear = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:7]+1960;
	deadLineMonth = [CodingUtil getUint8FromBuf:tmpPtr Offset:7 Bits:4];
	deadLineDay = [CodingUtil getUint8FromBuf:tmpPtr Offset:11 Bits:5];
	tmpPtr+=2;
    count = [CodingUtil getUInt16:tmpPtr];
	tmpPtr+=2;
	retCode = retcode;
    
    companyId = malloc((count*sizeof(UInt8)));
	consultancyId = malloc((count*sizeof(UInt16)));
    expireDate = malloc((count*sizeof(UInt16)));
	reviseFlag = malloc((count*sizeof(UInt8)));
    expireYear = malloc((count*sizeof(UInt16)));
    expireMonth = malloc((count*sizeof(UInt8)));
    expireDay = malloc((count*sizeof(UInt8)));
    
    
    for(int i=0 ; i<count ; i++)
    {
		companyId[i] = *tmpPtr++;
		tmpPtr+=1;
		consultancyId[i] = [CodingUtil getUInt16:tmpPtr];
		tmpPtr+=2;
        expireDate[i] = [CodingUtil getUInt16:tmpPtr];
        expireYear[i] = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:7]+1960;
        expireMonth[i] = [CodingUtil getUint8FromBuf:tmpPtr Offset:7 Bits:4];
        expireDay[i] = [CodingUtil getUint8FromBuf:tmpPtr Offset:11 Bits:5];

		tmpPtr+=2;
		reviseFlag[i] = *tmpPtr++;
		tmpPtr+=1;
	}
    
    


}
- (void)dealloc
{
	if(count)
	{
		free(companyId);
		free(consultancyId);
        free(expireDate);
		free(reviseFlag);
        
        free(expireYear);
		free(expireMonth);
        free(expireDay);
	}
}

@end
