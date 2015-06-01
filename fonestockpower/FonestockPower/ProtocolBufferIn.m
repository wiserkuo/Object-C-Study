//
//  ProtocolBufferIn.m
//  FonestockPower
//
//  Created by CooperLin on 2015/1/7.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "ProtocolBufferIn.h"
#import "Tips_location_down.pb.h"
@interface ProtocolBufferIn(){
    UInt16 downloadDataLength;
    NSData *downloadData;
}
@end

@implementation ProtocolBufferIn

-(id)init
{
    self = [super init];
    if(self) {
        
    }
    return self;
}

-(void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    NSLog(@"i had received some Data");
    UInt8 *tmpPtr = body;
    // retcode == 1 代表後面還有資料
    // retcode == 0 結束
//    int returnCode = (unsigned int)retcode;
    
    downloadDataLength = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    char *aaa = (char*)tmpPtr;
    downloadData = [[NSData alloc] initWithBytes:aaa length:downloadDataLength];
    
    tips_location_down *downObj = [tips_location_down parseFromData:downloadData];
    self.downLoadURL = downObj.location;

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    switch(downObj.type){
        case tips_location_downdata_typeDivergenceUs:
        case tips_location_downdata_typeDivergenceTw:
        case tips_location_downdata_typeDivergenceCn:
        case tips_location_downdata_typeDivergenceHk:
            if ([dataModel.divergenceModel respondsToSelector:@selector(protocolBufferCallBack:)]) {
                [dataModel.divergenceModel performSelector:@selector(protocolBufferCallBack:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
            }
            break;
        case tips_location_downdata_typePatternUs:
        case tips_location_downdata_typePatternTw:
        case tips_location_downdata_typePatternCn:
        case tips_location_downdata_typePatternHk:
            if([dataModel.patternTipsModel respondsToSelector:@selector(protocolBufferCallBack:)]) {
                [dataModel.patternTipsModel performSelector:@selector(protocolBufferCallBack:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
            }
            break;
        default:
            break;
    }
}

@end
