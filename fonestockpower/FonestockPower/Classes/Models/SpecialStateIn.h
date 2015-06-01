//
//  SpecialStateIn.h
//  Bullseye
//
//  Created by Neil on 13/9/5.
//
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"
#import "SpecialStateModel.h"
#import "MarketInfo.h"


@interface SpecialStateIn : NSObject<DecodeProtocol>{
    UInt8 retCode;
    UInt8 functionId;
    UInt16 total;
    
    
    NSMutableArray * securityInfoArray;
    UInt32 securityNumber;

    
    UInt8 stringFormatCount;
    UInt8 stringFieldId;
    
    UInt8 bValueCount;
    UInt8 bValueFieldId;
    
    UInt8 bytesDataCount;
    UInt8 bytesDataFieldId;
    UInt16 bytesData;
    
    NSMutableArray * fieldIdArray;
    NSMutableArray * fieldValueArray;
    NSMutableArray * dataArray;
    
    NSString * symbolNum;
    
}

@end

