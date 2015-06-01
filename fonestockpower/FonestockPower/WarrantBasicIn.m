//
//  WarrantBasicIn.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantBasicIn.h"

@implementation WarrantBasicIn
- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    if(!self.dict){
        self.dict = [[NSMutableDictionary alloc] init];
    }
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    blockMask = [CodingUtil getUInt16:&body needOffset:YES];
    if(blockMask == 1){
        [_dict setObject:[CodingUtil getShortStringFormatByBuffer:&body needOffset:YES] forKey:@"IdentCodeSymbol"];
        [_dict setObject:[CodingUtil getShortStringFormatByBuffer:&body needOffset:YES] forKey:@"BrokersID"];
        FSBValueFormat *exercise = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.0f",exercise.calcValue] forKey:@"ExercisePrice"];
        UInt8 first = [CodingUtil getUint8FromBuf:body Offset:0 Bits:4];
        if(first == 1){
            [_dict setObject:@"認購" forKey:@"Type"];
        }else{
            [_dict setObject:@"認售" forKey:@"Type"];
        }
        UInt8 second = [CodingUtil getUint8FromBuf:body Offset:4 Bits:4];
        if(second == 1){
            [_dict setObject:@"美式" forKey:@"Method"];
        }else{
            [_dict setObject:@"歐式" forKey:@"Method"];
        }
    //    UInt8 third = [CodingUtil getUint8FromBuf:body Offset:8 Bits:4];
    //    UInt8 fourd = [CodingUtil getUint8FromBuf:body Offset:12 Bits:4];
        body +=2;
        FSBValueFormat *proportion = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.1f", proportion.calcValue] forKey:@"Proportion"];
        FSBValueFormat *limitPrice = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        if(limitPrice.calcValue == 0){
            [_dict setObject:@"----" forKey:@"LimitPrice"];
        }else{
            [_dict setObject:[NSString stringWithFormat:@"%.0f", limitPrice.calcValue] forKey:@"LimitPrice"];
        }
        FSBValueFormat *stock = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.0f", stock.calcValue] forKey:@"Stock"];
        FSBValueFormat *volume = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.0f", volume.calcValue] forKey:@"Volume"];
        

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        UInt16 finalInt16 = [CodingUtil getUInt16:&body needOffset:YES];
        [_dict setObject:[formatter stringFromDate:[[NSNumber numberWithUnsignedInt:finalInt16]uint16ToDate]] forKey:@"FinalTradeDate"];
        UInt16 endInt16 = [CodingUtil getUInt16:&body needOffset:YES];
        [_dict setObject:[formatter stringFromDate:[[NSNumber numberWithUnsignedInt:endInt16]uint16ToDate]] forKey:@"EndDate"];
        
        
        NSDate *todayDate = [[NSDate alloc] init];
        NSDate *endDate = [[NSNumber numberWithUnsignedInt:endInt16]uint16ToDate];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *component = [gregorian components:NSCalendarUnitDay fromDate:todayDate toDate:endDate options:0];
        int dayCount = (int)[component day];
        [_dict setObject:[NSString stringWithFormat:@"%d", dayCount+1] forKey:@"Day"];
        
        [dataModal.warrant performSelector:@selector(warrantBasicDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }else if(blockMask == 2){
        FSBValueFormat *hv = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.2f%%", hv.calcValue*100] forKey:@"HV"];
        FSBValueFormat *iv = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.2f%%", iv.calcValue*100] forKey:@"IV"];
        FSBValueFormat *siv = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.2f%%", siv.calcValue*100] forKey:@"SIV"];
        FSBValueFormat *biv = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.2f%%", biv.calcValue*100] forKey:@"BIV"];
        FSBValueFormat *delta = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.4f", delta.calcValue] forKey:@"Delta"];
        FSBValueFormat *gamma = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.4f", gamma.calcValue] forKey:@"Gamma"];
        FSBValueFormat *vega = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.4f", vega.calcValue] forKey:@"Vega"];
        FSBValueFormat *theta = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        [_dict setObject:[NSString stringWithFormat:@"%.4f", theta.calcValue] forKey:@"Theta"];
        
        [dataModal.warrant performSelector:@selector(warrantSummaryDataCallBack:) onThread:dataModal.thread withObject:self waitUntilDone:NO];
    }

}
@end
