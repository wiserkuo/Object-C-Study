//
//  FSBrokerBranchInfo.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerBranchInfo.h"
#import "FSBrokerBranchOut.h"


@implementation FSBrokerBranchInfo

#define SYNCDATE_BROKERBRANCH 7


- (void) setTarget: (NSObject <FSBrokerBranchInfoProtocol>*) obj
{
    notifyTarget = obj;
}

-(FSBrokerBranchInfo *)init{
    if (self = [super init]) {
        
        lock = [[NSRecursiveLock alloc] init];
        notifyTarget = nil;
        
        [self initDatabase];
    }
    
    return self;
}

- (void) loginNotify
{
    [lock lock];
    
    UInt16 nSyncDate = [self getSyncDate:SYNCDATE_BROKERBRANCH];
    
    FSBrokerBranchOut *branchOutPacket = [[FSBrokerBranchOut alloc]initWithDate:nSyncDate];
    [FSDataModelProc sendData:self WithPacket:branchOutPacket];
    
    [lock unlock];
    
}

- (void) initDatabase{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS brokerBranch (BrokerBranchID TEXT PRIMARY KEY NOT NULL, BrokerID INTEGER , Name TEXT)"];
    }];
}

-(int)getSyncDate:(int)catID{
    int date = [self getDate:catID];
    if(date < 0){
        date = [CodingUtil makeDate:1960 month:1 day:1];
    }
    return date;
}

- (int) getDate: (int) catID
{
    __block int date = -1;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )   {
        
        FMResultSet *message = [db executeQuery:@"SELECT SyncDate FROM Misc_SyncDate where SectorID = ?",[NSNumber numberWithInt:catID]];
        while ([message next]) {
            date = [message intForColumn:@"SyncDate"];
        }
        [message close];
    }];
    
    return date;
}

- (void)syncBrokerBranchInfo:(FSBrokerBranchIn *)obj{
    
    
    BOOL modify = NO;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    for (BrokerBranchNameFormat *brokerBranch in obj.brokerBranchAdd)
    {
        __block BOOL hasData = NO;
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            FMResultSet *message = [db executeQuery:@"SELECT BrokerBranchID, BrokerID, Name FROM brokerBranch WHERE BrokerBranchID = ?",brokerBranch.brokerBranchID];
            while ([message next]) {
                hasData = YES;
            }
            [message close];
            if (hasData) {
                [db executeUpdate:@"UPDATE brokerBranch SET Name = ?, brokerID = ? WHERE BrokerBranchID = ?",brokerBranch.name,[NSNumber numberWithUnsignedInt:brokerBranch.brokerID],brokerBranch.brokerBranchID];
            }else{
                [db executeUpdate:@"INSERT INTO brokerBranch (BrokerBranchID, BrokerID, Name) VALUES (?,?,?)",brokerBranch.brokerBranchID,[NSNumber numberWithUnsignedInt:brokerBranch.brokerID],brokerBranch.name];
            }
            
        }];
        modify = YES;
    }
    
    for (NSString *brokerBranch in obj.brokerBranchRemove)
    {
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            [db executeUpdate:@"DELETE FROM brokerBranch WHERE BrokerBranchID = ?",brokerBranch];
        }];
        modify = YES;
    }
    
    if (modify && obj.returnCode == 0)
    {
        UInt16 nSyncDate = obj.date;
        [self updateSyncDate: nSyncDate  andSectorID: SYNCDATE_BROKERBRANCH];
        
        if (notifyTarget != nil)
            [notifyTarget performSelectorOnMainThread:@selector(notify) withObject: nil waitUntilDone: NO];
    }
}
- (void) updateSyncDate: (UInt16) syncDate  andSectorID: (UInt16) sectorID
{
    __block int count = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) AS COUNT FROM Misc_SyncDate where SectorID = ?",[NSNumber numberWithUnsignedInt:sectorID]];
        while ([message next]) {
            count = [message intForColumn:@"COUNT"];
        }
        [message close];
        
        if (count == 0) {
            [db executeUpdate:@"INSERT INTO Misc_SyncDate (SectorID, SyncDate) VALUES (?,?)",[NSNumber numberWithUnsignedInt:sectorID],[NSNumber numberWithUnsignedInt:syncDate]];
        }else{
            [db executeUpdate:@"UPDATE Misc_SyncDate SET SyncDate = ? where SectorID = ?",[NSNumber numberWithUnsignedInt:syncDate],[NSNumber numberWithUnsignedInt:sectorID]];
        }
    }];
}

@end
