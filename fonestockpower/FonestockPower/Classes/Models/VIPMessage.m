//
//  VIPMessage.m
//  Bullseye
//
//  Created by Neil on 13/9/2.
//
//

#import "VIPMessage.h"
#import "VIPDueDateOut.h"
#import "VIPSNQueryOut.h"
#import "VIPSNQueryIn.h"
#import "VIPMessageQueryOut.h"
#import "VIPMessageQueryIn.h"
#import "FMResultSet.h"


@implementation VIPMessage

- (VIPMessage*) init
{
	self = [super init];
	if (self)
	{
        
		_isDatabaseValid = NO;
        //[self vipSNQueryOut];

	}
	return self;
}

- (void) initDatabase
{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS VIPMessage (SerialNumber integer,Date integer,Time integer,Content TEXT,Del integer NOT NULL  DEFAULT (0) , Title TEXT, Read INTEGER DEFAULT 0)"];
    }];
}

-(void)insertDataInDB:(NSMutableArray *)array{
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
        
    for (ConsultancyMessage * item in array) {
        
        [ dbAgent  inDatabase: ^ ( FMDatabase  * db)  {
            NSRange titleBegin = [item-> dataContent rangeOfString:@"<TITLE>"];
            NSRange bodyBegin = [item-> dataContent rangeOfString:@"<BODY>"];
            NSRange titleEnd = [item-> dataContent rangeOfString:@"</TITLE>"];
            NSRange bodyEnd = [item-> dataContent rangeOfString:@"</BODY>"];
            NSString * body = @"";
            NSString * title = @"";
            if (titleBegin.location != NSNotFound) {
                if (titleEnd.location != NSNotFound) {
                    if (titleEnd.location > titleBegin.location) {
                        title = [item-> dataContent substringWithRange:NSMakeRange(NSMaxRange(titleBegin), titleEnd.location - NSMaxRange(titleBegin))];
                        //NSLog(@"title: %@", title);
                    }
                }
            }
            if (bodyBegin.location != NSNotFound) {
                if (bodyEnd.location != NSNotFound) {
                    if (bodyEnd.location > bodyBegin.location) {
                        body = [item-> dataContent substringWithRange:NSMakeRange(NSMaxRange(bodyBegin), bodyEnd.location - NSMaxRange(bodyBegin))];
                        //NSLog(@"body: %@", body);
                    }
                }
            }

            [db executeUpdate:@"INSERT INTO VIPMessage(SerialNumber, Date, Time, Content, Title) VALUES(?,?,?,?,?)",[ NSNumber numberWithInt:item-> serialNumber],[ NSNumber numberWithInt:item-> date],[ NSNumber numberWithInt:item-> time],body,title];
        }];
        
//        NSLog(@"serialNumber:%d",item-> serialNumber);
//        NSLog(@"date:%d",item-> date);   
//        NSLog(@"time:%d",(unsigned int)item-> time);
//        NSLog(@"dataContent:%@",item-> dataContent);
    }
    [self showVIPMessageTitle];
}

-(void)setMessageQueryOutData:(VIPSNQueryIn *)obj{
    
    UInt16 * maxSerial = malloc((obj->count*sizeof(UInt16)));
    
    UInt16 * date = malloc((obj->count*sizeof(UInt16)));
    maxSerial = obj->maxSerial;
    date = obj->date;
    
    for (int i = 0; i < obj->count; i++)
	{
        if (maxSerial[i]>0) {
            //NSLog(@"Date:%d,Max:%d",date[i],maxSerial[i]);
            _maxS = maxSerial[i];
            [self vipMessageQueryOut:date[i] maxSerial:maxSerial[i]];
        }
    }
}

-(void)vipMessageQueryOut:(UInt16)date maxSerial:(UInt16)maxS{
    //送出VIPMessageQuery電文
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
            
        FMResultSet *message = [db executeQuery:@"SELECT MAX(SerialNumber) S FROM VIPMessage where Date = ? ",[NSNumber numberWithInt:date]];
            
        while([message next]){
            dbMaxSerial = [message intForColumnIndex:0];
        }
    }];


    if (dbMaxSerial != maxS) {
        int count = maxS - dbMaxSerial;
        UInt8 * t = malloc(sizeof(UInt8)*count);
        UInt16 * beginS = malloc(sizeof(UInt16)*count);
        UInt16 * endS = malloc(sizeof(UInt16)*count);
        UInt8 * tCount = malloc(sizeof(UInt8)*count);
        UInt16 * s = malloc(sizeof(UInt16)*count);
        if (count == 1) {
            t[0]=2;
            tCount[0]=1;
            s[0]=maxS;
        }else{
            t[0]=1;
            beginS[0]=dbMaxSerial+1;
            endS[0]=maxS;
        }
    

        VIPMessageQueryOut * messageQuerypacket = [[VIPMessageQueryOut alloc] initWithConsultancyId:99 pdaItemId:1 askDate:date count:1 type:t beginSerial:beginS endSerial:endS typeCount:tCount serial:s];
        [FSDataModelProc sendData:self WithPacket:messageQuerypacket];
    }

}

-(void)showVIPMessageTitle{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {

        FMResultSet *message = [db executeQuery:@"SELECT SerialNumber,Title,Content,Date,Time,Read FROM VIPMessage WHERE Del = 0 ORDER BY Date DESC,Time DESC LIMIT 100"];
        _contentArray = [[NSMutableArray alloc]init];
        _titleArray =[[NSMutableArray alloc]init];
        _subTitleArray =[[NSMutableArray alloc]init];
        _readArray = [[NSMutableArray alloc]init];
        _SNumberArray = [[NSMutableArray alloc]init];
        _dateArray = [[NSMutableArray alloc]init];
        while ([message next]) {
            [_titleArray addObject:[message stringForColumn:@"Title"]];
            [_contentArray addObject:[message stringForColumn:@"Content"]];
            [_readArray addObject:[message stringForColumn:@"Read"]];
            [_SNumberArray addObject:[message stringForColumn:@"SerialNumber"]];
            [_dateArray addObject:[message stringForColumn:@"Date"]];
            NSNumber * date = [NSNumber numberWithInt:[message intForColumn:@"Date"]];
            NSNumber * time =[NSNumber numberWithInt:[message intForColumn:@"Time"]];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy/MM/dd"];
            NSString *dateString = [dateFormat stringFromDate:[date uint16ToDate]];
            
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"HH:mm:ss"];
            [timeFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSString *timeString = [timeFormat stringFromDate:[time uint16ToTime]];
            
            [_subTitleArray addObject:[NSString stringWithFormat:@"%@ %@",dateString,timeString]];
        }
    }];
    NSArray * array = [[NSArray alloc]initWithObjects:_titleArray,_contentArray,_subTitleArray,_readArray, nil];
    
    [notifyObj performSelectorOnMainThread:@selector(notifyArrive:) withObject:array waitUntilDone:NO];

}

-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)vipDueDateOut{
    VIPDueDateOut *packet = [[VIPDueDateOut alloc] init];
    [FSDataModelProc sendData:self WithPacket:packet];
    
    //[self vipSNQueryOut];
    
}
-(void)vipSNQueryOut{
    //送出vipSNQueryOut電文
    UInt16 * cid = malloc(sizeof(UInt16)*1);
    UInt8 * pid = malloc(sizeof(UInt8)*1);
    UInt8 * day = malloc(sizeof(UInt8)*1);
    
    for (int i = 0; i < 1; i++){
        cid[i] = 99;//神乎飛信為99
        pid[i] = 1;//神乎飛信type為1
        day[i]= 7;//往回查詢天數,max＝7
    }
    
    VIPSNQueryOut *snQuerypacket = [[VIPSNQueryOut alloc] initWithCount:1 consultancyId:cid pdaItemId:pid days:day];
    [FSDataModelProc sendData:self WithPacket:snQuerypacket];
    
    free(cid);
    free(pid);
    free(day);
    
    //[self insertDataInDB];

}


-(void)setRead2:(NSNumber*)row{
    //NSLog(@"select Row:%d",[row intValue]);
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE VIPMessage SET Read = 1 WHERE Date = ? AND SerialNumber = ?",[_dateArray objectAtIndex:[row intValue]],[_SNumberArray objectAtIndex:[row intValue]]];
        
    }];
}

-(void)deleteMessage:(NSNumber *)row{
    //NSLog(@"select Row:%d",[row intValue]);
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE VIPMessage SET Del = 1 WHERE Date = ? AND SerialNumber = ?",[_dateArray objectAtIndex:[row intValue]],(NSNumber *)[_SNumberArray objectAtIndex:[row intValue]]];
        
    }];
    [self showVIPMessageTitle];
}

@end
