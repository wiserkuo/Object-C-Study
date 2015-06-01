//
//  NewCompanyProfileIn.h
//  WirtsLeg
//
//  Created by Connor on 13/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CompanyProfileData;
@interface NewCompanyProfileIn : NSObject <DecodeProtocol> {
@public
    UInt8 subType;
    CompanyProfileData *data1;
}

@end


@interface CompanyProfileData : NSObject {
@public
	UInt16 recordDate;
	NSString *officialName;
	UInt16 listDate;	//Year offset is 1900
	UInt16 foundDate;	//Year offset is 1900
	NSString *address;
	NSString *phone;
	NSString *fax;
	NSString *website;
	UInt16 FYEDate;
	double employees;
	NSString *sharesOutstanding;
    double sharesOutstandingDouble;
	double capital;
	NSString *sector;
	NSString *industy;
	NSString *businessSummary;
    NSString *industryAssociationName;
    UInt16  epsDate;
	double epsValue;
	UInt8 epsUnit;
    UInt16 data3Date;
    UInt8 data3Count;
    NSMutableArray *employeesArray;
}
@end

