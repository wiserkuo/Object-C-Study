//
//  TempCompanyProfileForCN.m
//  FonestockPower
//
//  Created by CooperLin on 2015/4/24.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "TempCompanyProfileForCN.h"
#import "NewCompanyProfile.h"

@implementation TempCompanyProfileForCN
- (void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    subType = [CodingUtil getUInt8:&body needOffset:YES];
    CNCompanyProfileData *cncData = [[CNCompanyProfileData alloc] init];
    if(subType == 1){
        cncData->recordDate = [CodingUtil getUInt16:&body needOffset:YES];
        if(cncData->recordDate == 0) return;
        
        cncData->exchange = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cncData->address = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cncData->phone = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cncData->foundDate = [CodingUtil getUInt16:&body needOffset:YES];
        cncData->listDate = [CodingUtil getUInt16:&body needOffset:YES];
        FSBValueFormat *employeesNum = [[FSBValueFormat alloc] initWithByte:&body needOffset:YES];
        cncData->employees = employeesNum.calcValue;
        self->cncProfile = cncData;
    }else if(subType == 2){
        cncData->employeesArray = [[NSMutableArray alloc] init];
        cncData->data2Date = [CodingUtil getUInt16:&body needOffset:YES];
        if(cncData->data2Date == 0) return;
        
        cncData->data2Count = [CodingUtil getUInt8:&body needOffset:YES];
        for (int i = 0; i < cncData->data2Count; i++){
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:[CodingUtil getShortStringFormatByBuffer:&body needOffset:YES]];
            [array addObject:[CodingUtil getShortStringFormatByBuffer:&body needOffset:YES]];
            [cncData->employeesArray addObject:array];
            NSLog(@"the array %@",array);
        }
        self->cncProfile = cncData;
    }

    NewCompanyProfile *companyProfile = [NewCompanyProfile sharedInstance];
    if ([companyProfile respondsToSelector:@selector(cnCompanyProfileDataCallBack:)]) {
        FSDataModelProc *model = [FSDataModelProc sharedInstance];
        [companyProfile performSelector:@selector(cnCompanyProfileDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
    
}

@end
@implementation CNCompanyProfileData
@end