//
//  TempCompanyProfileForCN.h
//  FonestockPower
//
//  Created by CooperLin on 2015/4/24.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CNCompanyProfileData : NSObject{
@public
    UInt16 recordDate;
    NSString *exchange;
    NSString *address;
    NSString *phone;
    UInt16 foundDate;
    UInt16 listDate;
    float employees;
    UInt16 data2Date;
    UInt8 data2Count;
    NSMutableArray *employeesArray;
}

@end

@interface TempCompanyProfileForCN : NSObject<DecodeProtocol>{
@public
    UInt8 subType;
    CNCompanyProfileData *cncProfile;
}

@end
