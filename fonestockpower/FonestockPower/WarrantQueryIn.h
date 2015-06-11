//
//  WarrantQueryIn.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/11.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@class SymbolFormat1;

@interface WarrantQueryIn : NSObject <DecodeProtocol>{
@public
	UInt8 returnCode;
	NSMutableArray *securityQueryArray;		//存SecurityQueryParam
    
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



@interface FieldMaskParam : NSObject
{
@public
	int fieldID;
	UInt8 ckeckUnit;	//0是string 1是taValue 2是data
	NSString *shortString;

	double taValue;
	UInt16 taValueUnit;
	
	int shortData;
}

@property (nonatomic,copy) NSString *shortString;


@end

@class SymbolFormat1;
@interface SecurityQueryParam : NSObject
{
	NSObject *compareString;
@public
	SymbolFormat1 *securityInfo;
	UInt32 securityNum;
	NSMutableArray *fieldMaskArray;		//存FieldMaskParam
}

@property (nonatomic,retain) NSObject *compareString;
@property (readonly) SymbolFormat1 *securityInfo;
@property (readonly) NSMutableArray *fieldMaskArray;

- (id)initWithBuffer:(UInt8*)tmpPtr Offset:(int*)offset SymbolSize:(UInt16*)size;

@end


