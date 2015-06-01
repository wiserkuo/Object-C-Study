//
//  VIPMessageQueryIn.m
//  Bullseye
//
//  Created by Neil on 13/9/3.
//
//

#import "VIPMessageQueryIn.h"

@implementation VIPMessageQueryIn

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    dataArray = [[NSMutableArray alloc]init];
    UInt8 *tmpPtr;
	tmpPtr = body;
    count = *body++;
   
	retCode = retcode;
    
    for(int i=0 ; i<count ; i++)
	{
		ConsultancyMessage * message = [[ConsultancyMessage alloc] init];
		message->companyId = *body++;
		message->consultancyId = [CodingUtil getUInt16:body];
		body+=2;
        message->pdaItemId = *body++;
        message->serialNumber = [CodingUtil getUInt16:body];
		body+=2;
        
        message->date = [CodingUtil getUInt16:body];
        message->year = [CodingUtil getUint8FromBuf:body Offset:0 Bits:7]+1960;
        message->month = [CodingUtil getUint8FromBuf:body Offset:7 Bits:4];
        message->day = [CodingUtil getUint8FromBuf:body Offset:11 Bits:5];
        body+=2;
        
        message->time = [CodingUtil getUInt32:body];
        message->hour = [CodingUtil getUint8FromBuf:body Offset:0 Bits:8];
        message->minute = [CodingUtil getUint8FromBuf:body Offset:7 Bits:8];
        message->second = [CodingUtil getUint8FromBuf:body Offset:15 Bits:8];
        body+=3;
        
        message->totalPacket = *body++;
//        UInt8 totalP=message->totalPacket;
        message->packetIndex = *body++;
        UInt8 packetNum = message->packetIndex;
        message->format = *body++;
        message->packetLength = [CodingUtil getUInt16:body];
        body+=2;
        UInt16 length = message->packetLength;
        
        message->dataContent = [[NSString alloc]initWithBytes:body length:length encoding:NSUTF8StringEncoding];
        body+=message->packetLength;
        if (packetNum==0) {
            [dataArray addObject:message];
        }else{
            for (ConsultancyMessage * item in dataArray) {
                if (item->serialNumber == message->serialNumber ) {
                    item->dataContent = [NSString stringWithFormat:@"%@%@",item->dataContent,message->dataContent];
                }
            }
        }
        
//        if (totalP == packetNum+1) {
//            //此封包為最後封包
//            if (totalP==1) {
//                //此封包為唯一封包
//                [dataArray addObject:message];
//                [message release];
//            }else{
//                //多封包之最後一個封包
//                NSString * text = [array objectAtIndex:message->serialNumber];
//                message->dataContent = [NSString stringWithFormat:@"%@%@",text,message->dataContent];
//                [dataArray addObject:message];
//                [message release];
//            }
//        }else{
//            //此封包不為最後封包
//            NSString * text = [array objectAtIndex:message->serialNumber];
//            message->dataContent = [NSString stringWithFormat:@"%@%@",text,message->dataContent];
//            [array insertObject:message->dataContent atIndex:message->serialNumber];
//        }
        
	}
	body = tmpPtr;
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.vipMessage performSelector:@selector(insertDataInDB:) onThread:dataModal.thread withObject:dataArray waitUntilDone:NO];
}
    



@end

@implementation ConsultancyMessage

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}


@end

