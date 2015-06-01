//
//  EODTargetIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/6/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODTargetIn.h"
#import "EODTargetModel.h"
@implementation EODTargetIn
- (id)init {
    if (self = [super init]) {
        longData = [[NSMutableDictionary alloc] init];
        shortData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    
	UInt8 *tmpPtr = body;
    
    UInt16 optionLength;
    optionLength = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt8 bitMask;
    bitMask = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    UInt16 trans_id;
    trans_id = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 status_code;
    status_code = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    UInt16 content_length;
    content_length = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    EODTargetIn * eodTargetIn = [[EODTargetIn alloc] init];
    eodTargetIn->serialNumber = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    eodTargetIn->patternCount = [CodingUtil getUInt8:&tmpPtr needOffset:YES];

    eodTargetIn->patternName = malloc(6 * sizeof(UInt8));
    
    NSMutableArray *tpnLongArray = [[NSMutableArray alloc] init];
    NSMutableArray *tpnShortArray = [[NSMutableArray alloc] init];
    for(int i =0; i<eodTargetIn->patternCount; i++){
        for(int j=0; j<6; j++){
            eodTargetIn->patternName[j] = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
        }
        eodTargetIn->resultCount = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
        NSString *patternName_local = [NSString stringWithFormat:@"%c%c%c%c%c%c",eodTargetIn->patternName[0],eodTargetIn->patternName[1],eodTargetIn->patternName[2],eodTargetIn->patternName[3],eodTargetIn->patternName[4],eodTargetIn->patternName[5]];
        int patternID = [(NSNumber *)[patternName_local stringByReplacingOccurrencesOfString:@"TPN" withString:@""]intValue];
        if(eodTargetIn->resultCount != 0 /*|| patternID <= 0 || patternID > 24*/){

            if(patternID > 12){
                TPNObject *obj = [[TPNObject alloc] init];
                obj->number = patternID-12;
                obj->count = eodTargetIn->resultCount;
                obj->name = [EODTargetModel getTPNName:patternID];
                obj->imgData = [EODTargetModel getTPNImage:patternID];
                [tpnShortArray addObject:obj];
            }else{
                TPNObject *obj = [[TPNObject alloc] init];
                obj->number = patternID;
                obj->count = eodTargetIn->resultCount;
                obj->name = [EODTargetModel getTPNName:patternID];
                obj->imgData = [EODTargetModel getTPNImage:patternID];
                [tpnLongArray addObject:obj];
            }
            
        }
    }
    
    eodTargetIn->reserved = [CodingUtil getUInt8:&tmpPtr needOffset:YES];

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    EODTarget * eodTarget = dataModel.eodTarget;
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"count" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *sortedLongArray = [[NSMutableArray alloc]initWithArray:[tpnLongArray sortedArrayUsingDescriptors:sortDescriptors]];
    NSMutableArray *sortedShortArray = [[NSMutableArray alloc]initWithArray:[tpnShortArray sortedArrayUsingDescriptors:sortDescriptors]];
    
    for (int i = 0; i < [sortedLongArray count]; i++){
        TPNObject *obj = [sortedLongArray objectAtIndex:i];
        [longData setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
    }

    for (int i = 0; i < [sortedShortArray count]; i++){
        TPNObject *obj = [sortedShortArray objectAtIndex:i];
        [shortData setObject:obj forKey:[NSString stringWithFormat:@"%d",i]];
    }
    
    
    if ([eodTarget respondsToSelector:@selector(callBackData:)]) {
        [eodTarget performSelector:@selector(callBackData:) onThread:dataModel.thread withObject:self waitUntilDone:NO];
    }
}


@end

@implementation TPNObject
@end
