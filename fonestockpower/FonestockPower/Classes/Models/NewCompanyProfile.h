//
//  NewCompanyProfile.h
//  WirtsLeg
//
//  Created by Connor on 13/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewCompanyProfileIn.h"
#import "TempCompanyProfileForCN.h"

@protocol NewCompanyProfileDelegate;

@interface NewCompanyProfile : NSObject
+ (instancetype)sharedInstance;
- (void)sendAndRead;
- (void)companyProfileDataCallBack:(NewCompanyProfileIn *)data;
- (void)cnCompanyProfileDataCallBack:(TempCompanyProfileForCN *)data;

@property (nonatomic, weak) NSObject <NewCompanyProfileDelegate> *delegate;
@end

@protocol NewCompanyProfileDelegate <NSObject>
- (void)notifyData:(id)target;
@end