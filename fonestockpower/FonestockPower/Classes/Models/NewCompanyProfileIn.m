//
//  NewCompanyProfileIn.m
//  WirtsLeg
//
//  Created by Connor on 13/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "NewCompanyProfileIn.h"
#import "NewCompanyProfile.h"

@implementation NewCompanyProfileIn

- (void)decode:(UInt8 *)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode {
    subType = [CodingUtil getUInt8:&body needOffset:YES];
    CompanyProfileData *cp1 = [[CompanyProfileData alloc] init];
    if (subType == 1) {
        cp1->recordDate = [CodingUtil getUInt16:&body needOffset:YES];
        if (cp1->recordDate == 0) {
            return;
        }
        
        cp1->officialName =[CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cp1->listDate = [CodingUtil getUInt16:&body needOffset:YES];
        cp1->foundDate = [CodingUtil getUInt16:&body needOffset:YES];
        cp1->address = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cp1->phone = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cp1->fax = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cp1->website = [CodingUtil getShortStringFormatByBuffer:&body needOffset:YES];
        cp1->FYEDate = [CodingUtil getUInt16:&body needOffset:YES];
        
        TAvalueFormatData tmpTA;
        int bitOffset = 0;
        
        // ta value
        cp1->employees = [CodingUtil getTAvalueFormatValue:body Offset:&bitOffset TAstruct:&tmpTA];
        cp1->sharesOutstanding = [CodingUtil getTAvalueFormatString:body Offset:bitOffset TAstruct:&tmpTA];
        cp1->sharesOutstandingDouble = [CodingUtil getTAvalue:body Offset:&bitOffset TAstruct:&tmpTA];
        cp1->capital = [CodingUtil getTAvalue:body Offset:&bitOffset TAstruct:&tmpTA];
        
        // 這邊 ta value 造成 bit沒補齊, 直接接上內容
        cp1->sector = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&bitOffset];
        cp1->industy = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&bitOffset];
        cp1->businessSummary = [CodingUtil getLongStringFormatByBuffer:body bitOffset:&bitOffset];
        cp1->industryAssociationName = [CodingUtil getShortStringFormatByBuffer:body bitOffset:&bitOffset];
        
        self->data1 = cp1;
    }else if (subType == 2) {
        cp1->epsDate = [CodingUtil getUInt16:&body needOffset:YES];
        if (cp1->epsDate == 0) {
            return;
        }

        TAvalueFormatData tmpTA;
        int bitOffset = 0;
        //ta value
        [CodingUtil getTAvalueFormatValue:body Offset:&bitOffset TAstruct:&tmpTA];
        cp1->epsValue = [CodingUtil getTAvalueFormatValue:body Offset:&bitOffset TAstruct:&tmpTA];
        cp1->epsUnit = tmpTA.magnitude;
        self->data1 = cp1;
    }else if (subType == 3) {
        cp1->employeesArray = [[NSMutableArray alloc] init];
        cp1->data3Date = [CodingUtil getUInt16:&body needOffset:YES];
        if (cp1->data3Date == 0) {
            return;
        }
        cp1->data3Count = [CodingUtil getUInt8:&body needOffset:YES];
        for(int i = 0; i <cp1->data3Count; i++){
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:[CodingUtil getShortStringFormatByBuffer:&body needOffset:YES]];
            [array addObject:[CodingUtil getShortStringFormatByBuffer:&body needOffset:YES]];
            [cp1->employeesArray addObject:array];
        }
        self->data1 = cp1;
    }
    
    NewCompanyProfile *companyProfile = [NewCompanyProfile sharedInstance];
    if ([companyProfile respondsToSelector:@selector(companyProfileDataCallBack:)]) {
        FSDataModelProc *model = [FSDataModelProc sharedInstance];
        [companyProfile performSelector:@selector(companyProfileDataCallBack:) onThread:model.thread withObject:self waitUntilDone:NO];
    }
}

@end

@implementation CompanyProfileData
@end

