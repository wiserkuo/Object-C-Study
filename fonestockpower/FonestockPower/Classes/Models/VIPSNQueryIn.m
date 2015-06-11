//
//  VIPSNQueryIn.m
//  Bullseye
//
//  Created by Neil on 13/8/30.
//
//

#import "VIPSNQueryIn.h"
#import "CodingUtil.h"

@implementation VIPSNQueryIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    UInt8 *tmpPtr;
	tmpPtr = body;
    count = *tmpPtr++;
    
    consultancyId = malloc((count*sizeof(UInt16)));
    pdaItemId = malloc((count*sizeof(UInt8)));
    maxSerial = malloc((count*sizeof(UInt16)));
    
	date = malloc((count*sizeof(UInt16)));
	year = malloc((count*sizeof(UInt16)));
    month = malloc((count*sizeof(UInt8)));
    day = malloc((count*sizeof(UInt8)));
    
    for(int i=0 ; i<count ; i++)
    {
        consultancyId[i] = [CodingUtil getUInt16:tmpPtr];
		tmpPtr+=2;
        
		pdaItemId[i] = *tmpPtr++;
        
        date[i] = [CodingUtil getUInt16:tmpPtr];
        //NSNumber * dateNum = [NSNumber numberWithInt:date[i]];
        //NSLog(@"date:%@",[dateNum uint16ToDate]);
        
        year[i] = [CodingUtil getUint8FromBuf:tmpPtr Offset:0 Bits:7]+1960;
        month[i] = [CodingUtil getUint8FromBuf:tmpPtr Offset:7 Bits:4];
        day[i] = [CodingUtil getUint8FromBuf:tmpPtr Offset:11 Bits:5];
        tmpPtr+=2;
		
        maxSerial[i] =[CodingUtil getUInt16:tmpPtr];
		tmpPtr+=2;

        //NSLog(@"maxSerial:%d",maxSerial[i]);
        
        
	}
    
	retCode = retcode;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.vipMessage performSelector:@selector(setMessageQueryOutData:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    
    
}
- (void)dealloc
{
	if(count)
	{
        free(consultancyId);
        free(pdaItemId);
		free(maxSerial);
        free(date);        
        free(year);
		free(month);
        free(day);
	}
}


@end
