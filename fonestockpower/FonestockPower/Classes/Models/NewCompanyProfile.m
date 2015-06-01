//
//  NewCompanyProfile.m
//  WirtsLeg
//
//  Created by Connor on 13/12/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "NewCompanyProfile.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "NewCompanyProfileOut.h"

@interface NewCompanyProfile()
{
    int sendNum;
}
@property (nonatomic, strong) NSRecursiveLock *datalock;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@end

@implementation NewCompanyProfile

+ (instancetype)sharedInstance {
    static NewCompanyProfile *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NewCompanyProfile alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.datalock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)sendAndRead {
    sendNum = 1;
    
    [self.datalock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:30]];
    
    self.portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
     [NSString stringWithFormat:@"%c%c %@ CompanyProfile.plist",
      self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    if (self.mainDict) {
        
        if ([self.delegate respondsToSelector:@selector(notifyData:)]) {
            [self.delegate performSelectorOnMainThread:@selector(notifyData:) withObject:self.mainDict waitUntilDone:NO];
        }
    } else {
        self.mainDict = [[NSMutableDictionary alloc] init];
    }
    
    [self syncCompanyProfile:sendNum];
    
    [self.datalock unlock];
    
}

- (void)syncCompanyProfile:(int)subTypeNum {
    NSString *recordDateKey = [NSString stringWithFormat:@"Data%dRecordDate", subTypeNum];
    UInt16 tmpDate = [[self.mainDict objectForKey:recordDateKey] unsignedIntValue];
    if (tmpDate == 0) {
        tmpDate = 10000;
    }
    if (self.portfolioItem->commodityNo) {
        NewCompanyProfileOut *cpOut = [[NewCompanyProfileOut alloc] initWithSecurityNum:self.portfolioItem->commodityNo
                                                                                subType:subTypeNum
                                                                             recordDate:tmpDate];
        [FSDataModelProc sendData:self WithPacket:cpOut];
    }
}


- (void)companyProfileDataCallBack:(NewCompanyProfileIn *)data {
    [self.datalock lock];
    if (data->subType == 1) {
        CompanyProfileData *data1 = data->data1;
        if (data1) {
            NSDateFormatter *formatterYear = [[NSDateFormatter alloc] init];
            [formatterYear setDateFormat:@"yyyy"];
            NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
            [formatterMonth setDateFormat:@"MM"];
            NSDateFormatter *formatterDay = [[NSDateFormatter alloc] init];
            [formatterDay setDateFormat:@"dd"];
            
            int foundYear = [[formatterYear stringFromDate:[[NSNumber numberWithUnsignedInt:data1->foundDate]uint16ToDateForCompany]]intValue];
            NSString *foundMonth = [formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:data1->foundDate]uint16ToDateForCompany]];
            NSString *foundDay = [formatterDay stringFromDate:[[NSNumber numberWithUnsignedInt:data1->foundDate]uint16ToDateForCompany]];
            
            int listYear = [[formatterYear stringFromDate:[[NSNumber numberWithUnsignedInt:data1->listDate]uint16ToDateForCompany]]intValue];
            NSString *listMonth = [formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:data1->listDate]uint16ToDateForCompany]];
            NSString *listDay = [formatterDay stringFromDate:[[NSNumber numberWithUnsignedInt:data1->listDate]uint16ToDateForCompany]];

            
            [self.mainDict setObject:[NSNumber numberWithInt:data1->recordDate] forKey:@"Data1RecordDate"];
            [self.mainDict setObject:data1->officialName forKey:@"Official Name"];
            [self.mainDict setObject:[NSString stringWithFormat:@"%d/%@/%@", foundYear-1911, foundMonth, foundDay] forKey:@"FoundDate"];
            [self.mainDict setObject:[NSString stringWithFormat:@"%d/%@/%@", listYear-1911, listMonth, listDay] forKey:@"ListDate"];
            [self.mainDict setObject:data1->phone forKey:@"Phone"];
            [self.mainDict setObject:data1->fax forKey:@"Fax"];
            [self.mainDict setObject:data1->address forKey:@"Address"];
            [self.mainDict setObject:data1->website forKey:@"Website"];
            [self.mainDict setObject:[NSNumber numberWithInt:data1->employees] forKey:@"Employees"];
            [self.mainDict setObject:data1->sharesOutstanding forKey:@"SharesOutstanding"];
            [self.mainDict setObject:[NSNumber numberWithDouble:data1->sharesOutstandingDouble] forKey:@"SharesOutstandingDouble"];
            [self.mainDict setObject:[NSNumber numberWithDouble:data1->capital] forKey:@"Capital"];
            [self.mainDict setObject:data1->businessSummary forKey:@"Business Summary"];

            [self.mainDict setObject:data1->industryAssociationName forKey:@"IndustryAssociationName"];
        }
        sendNum ++;
        [self syncCompanyProfile:sendNum];
    }
    
    if (data->subType == 2) {
        CompanyProfileData *data2 = data->data1;
        if (data2) {
            NSString * valueString =nil;
            [self.mainDict setObject:[NSNumber numberWithInt:data2->epsDate] forKey:@"Data2RecordDate"];
            valueString = [CodingUtil getValueUnitString:data2->epsValue Unit:data2->epsUnit];
            [self.mainDict setObject:valueString forKey:@"eps"];
            //[self.mainDict setObject:data2->newEpsUnit forKey:@"Unit"];
        }
        sendNum ++;
        [self syncCompanyProfile:sendNum];
    }
    
    if (data->subType == 3) {
        CompanyProfileData *data3 = data->data1;
        if (data3) {
            for(int i = 0 ; i <[data3->employeesArray count]; i ++){
                if([[[data3->employeesArray objectAtIndex:i] objectAtIndex:0] isEqualToString:@"董事長"]){
                    [self.mainDict setObject:[[data3->employeesArray objectAtIndex:i] objectAtIndex:1] forKey:@"COB"];
                }
                if([[[data3->employeesArray objectAtIndex:i] objectAtIndex:0] isEqualToString:@"總經理"]){
                    [self.mainDict setObject:[[data3->employeesArray objectAtIndex:i] objectAtIndex:1] forKey:@"Manager"];
                }
            }
        }
        sendNum ++;
    }
//    if(sendNum == 4){
//        if ([self.delegate respondsToSelector:@selector(notifyData:)]) {
//            [self.delegate notifyData:self.mainDict];
//        }
//    }
    
    [self saveToFile];
    if ([self.delegate respondsToSelector:@selector(notifyData:)]) {
        [self.delegate notifyData:self.mainDict];
    }
    [self.datalock unlock];
}

- (void)cnCompanyProfileDataCallBack:(TempCompanyProfileForCN *)data
{
    [self.datalock lock];
    if (data->subType == 1) {
        CNCompanyProfileData *data1 = data->cncProfile;
        
        if(data1){
            NSDateFormatter *formatterYear = [[NSDateFormatter alloc] init];
            [formatterYear setDateFormat:@"yyyy"];
            NSDateFormatter *formatterMonth = [[NSDateFormatter alloc] init];
            [formatterMonth setDateFormat:@"MM"];
            NSDateFormatter *formatterDay = [[NSDateFormatter alloc] init];
            [formatterDay setDateFormat:@"dd"];
            
            int foundYear = [[formatterYear stringFromDate:[[NSNumber numberWithUnsignedInt:data1->foundDate]uint16ToDateForCompany]]intValue];
            NSString *foundMonth = [formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:data1->foundDate]uint16ToDateForCompany]];
            NSString *foundDay = [formatterDay stringFromDate:[[NSNumber numberWithUnsignedInt:data1->foundDate]uint16ToDateForCompany]];
            
            int listYear = [[formatterYear stringFromDate:[[NSNumber numberWithUnsignedInt:data1->listDate]uint16ToDateForCompany]]intValue];
            NSString *listMonth = [formatterMonth stringFromDate:[[NSNumber numberWithUnsignedInt:data1->listDate]uint16ToDateForCompany]];
            NSString *listDay = [formatterDay stringFromDate:[[NSNumber numberWithUnsignedInt:data1->listDate]uint16ToDateForCompany]];
            
            [self.mainDict setObject:[NSNumber numberWithInt:data1->recordDate] forKey:@"Data1RecordDate"];
            [self.mainDict setObject:data1->exchange forKey:@"Exchange"];
            [self.mainDict setObject:data1->address forKey:@"Address"];
            [self.mainDict setObject:data1->phone forKey:@"Phone"];
            [self.mainDict setObject:[NSString stringWithFormat:@"%d/%@/%@", foundYear, foundMonth, foundDay] forKey:@"FoundDateF"];
            [self.mainDict setObject:[NSString stringWithFormat:@"%d/%@/%@",listYear, listMonth, listDay] forKey:@"ListDateF"];
            [self.mainDict setObject:[NSNumber numberWithFloat:data1->employees] forKey:@"Employees"];
        }
        sendNum ++;
        [self syncCompanyProfile:sendNum];
    }
    if (data->subType == 2) {
        CNCompanyProfileData *data2 = data->cncProfile;
        if (data2) {
            for(int i = 0 ; i < [data2->employeesArray count]; i ++){
                if([[[data2->employeesArray objectAtIndex:i] objectAtIndex:0] isEqualToString:@"董事長"]){
                    [self.mainDict setObject:[[data2->employeesArray objectAtIndex:i] objectAtIndex:1] forKey:@"COB"];
                }
                if([[[data2->employeesArray objectAtIndex:i] objectAtIndex:0] isEqualToString:@"總經理"]){
                    [self.mainDict setObject:[[data2->employeesArray objectAtIndex:i] objectAtIndex:1] forKey:@"Manager"];
                }
                if([[[data2->employeesArray objectAtIndex:i] objectAtIndex:0] isEqualToString:@"董事長秘書"]){
                    [self.mainDict setObject:[[data2->employeesArray objectAtIndex:i] objectAtIndex:1] forKey:@"Secretary"];
                }
            }
        }
        sendNum ++;
    }
    [self saveToFile];
    if ([self.delegate respondsToSelector:@selector(notifyData:)]) {
        [self.delegate notifyData:self.mainDict];
    }
    [self.datalock unlock];
}

- (void)saveToFile {
	[self.datalock lock];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%c%c %@ CompanyProfile.plist",
                       self.portfolioItem->identCode[0], self.portfolioItem->identCode[1], self.portfolioItem->symbol]];
    
	BOOL success = [self.mainDict writeToFile:path atomically:YES];
	if(!success) NSLog(@"companyProfile wirte error!!");
	[self.datalock unlock];
}
@end
