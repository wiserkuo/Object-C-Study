//
//  Alert.m
//  FonestockPower
//
//  Created by Neil on 14/5/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "Alert.h"
#import "AlertINIIn.h"
#import "GetINIOut.h"
#import "AlertRegisterOut.h"
#import "AlertSnapshotOut.h"
#import "AlertSnapshotIn.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@interface Alert (){
    NSRecursiveLock *dataLock;
    NSMutableDictionary *priceAlertData;		//放全部的alertData
    NSMutableDictionary *techAlertData;
    NSMutableArray *alertDataArrayByTick;
    NSMutableArray *cancelAlertDataArray;
    NSMutableData *xmlData;
    NSMutableArray *alertXMLParamArray;
    NSMutableDictionary * upAlertDictionary;
    NSMutableDictionary * downAlertDictionary;
    BOOL sendSnapshotFlag;
	BOOL alertOnOff;
	BOOL sendXML;			//計錄有沒有送過XML

}

@end

@implementation Alert
@synthesize priceAlertData;
- (id)init
{
	if(self = [super init])
	{
        dataLock = [[NSRecursiveLock alloc]init];
        priceAlertData = [[NSMutableDictionary alloc]init];
        techAlertData = [[NSMutableDictionary alloc]init];
        alertDataArrayByTick = [[NSMutableArray alloc]init];
        cancelAlertDataArray = [[NSMutableArray alloc]init];
        upAlertDictionary = [[NSMutableDictionary alloc]init];
        downAlertDictionary = [[NSMutableDictionary alloc]init];
        xmlData = [[NSMutableData alloc] init];
        sendSnapshotFlag = NO;
        alertOnOff = YES;
        sendXML = NO;
        [self loadAlertDataFromFile];
        [self saveAlertDataToFile];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertLocalNotification:) name:@"alertNotification" object:nil];

    }
    return self;
}

-(void)showAlertLocalNotification:(NSNotification *)notification{
    //SHOW localNotification
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    NSString * alertString = @"";
    dataArray = notification.object;
    if ([dataArray count]>0) {
        for (AlertParam * alertParam in dataArray) {
            if (alertParam->alertID == profitAlert){
                UInt16 alertDateInt = [(NSNumber *)[upAlertDictionary objectForKey:alertParam->identSymbol]intValue];
                UInt16 nowAlertDateInt = alertParam->date;
                
                NSDate * alertDate = [[NSNumber numberWithUnsignedInt:alertDateInt] uint16ToDate];
                
                NSDate * nowAlertDate = [[NSNumber numberWithUnsignedInt:nowAlertDateInt] uint16ToDate];
                
                if (alertDate == 0 || ![alertDate isEqualToDate:nowAlertDate]) {
                    //沒有通知過 或 日期不同
                    if ([alertString isEqualToString:@""]) {
                        alertString = [NSString stringWithFormat:@"%@ %@",[alertParam->identSymbol substringFromIndex:3],NSLocalizedStringFromTable(@"獲利", @"SecuritySearch", nil)];
                    }else{
                        alertString = [NSString stringWithFormat:@"%@, %@ %@",alertString,[alertParam->identSymbol substringFromIndex:3],NSLocalizedStringFromTable(@"獲利", @"SecuritySearch", nil)];
                    }
                    [upAlertDictionary setObject:[NSNumber numberWithUnsignedInt:alertParam->date] forKey:alertParam->identSymbol];
                }
                
            }else if (alertParam->alertID == lostAlert){
                
                UInt16 alertDateInt = [(NSNumber *)[downAlertDictionary objectForKey:alertParam->identSymbol]intValue];
                UInt16 nowAlertDateInt = alertParam->date;
                
                NSDate * alertDate = [[NSNumber numberWithUnsignedInt:alertDateInt] uint16ToDate];
                
                NSDate * nowAlertDate = [[NSNumber numberWithUnsignedInt:nowAlertDateInt] uint16ToDate];
                if (alertDate == nil || ![nowAlertDate isEqualToDate:alertDate]) {
                    //沒有通知過 或 日期不同
                    if ([alertString isEqualToString:@""]) {
                        alertString = [NSString stringWithFormat:@"%@ %@",[alertParam->identSymbol substringFromIndex:3],NSLocalizedStringFromTable(@"停損", @"SecuritySearch", nil)];
                    }else{
                        alertString = [NSString stringWithFormat:@"%@, %@ %@",alertString,[alertParam->identSymbol substringFromIndex:3],NSLocalizedStringFromTable(@"停損", @"SecuritySearch", nil)];
                    }
                    [downAlertDictionary setObject:[NSNumber numberWithUnsignedInt:alertParam->date] forKey:alertParam->identSymbol];
                }
            }
        }
        //send LocalNotification
        
        if (![alertString isEqualToString:@""]) {
            UILocalNotification * alert =[[UILocalNotification alloc]init];
            alert.alertBody = alertString;
            [[UIApplication sharedApplication]presentLocalNotificationNow:alert];
            
        }
        
        
    }
    
    
}


-(NSMutableArray *)checkAlertData{
    BOOL alertFlag = NO;
    NSMutableArray * alertArray = [[NSMutableArray alloc]init];
    for( NSString *aKey in [priceAlertData allKeys] ){
        NSMutableArray * dataArray = [priceAlertData objectForKey:aKey];
         EquitySnapshotDecompressed *mySnapshot = [[[FSDataModelProc sharedInstance]portfolioTickBank] getSnapshotFromIdentCodeSymbol:aKey];
        if ([dataArray count]>0) {
            for (int i =0; i<[dataArray count]; i++) {
                NSMutableDictionary * alertDirectory = [[NSMutableDictionary alloc]init];
                alertDirectory = [dataArray objectAtIndex:i];
                AlertParam *aParam = [[AlertParam alloc]init];
                aParam->identSymbol = aKey;
                aParam->alertID = [(NSNumber *)[alertDirectory objectForKey:@"alertId"]intValue];
                aParam->alertValue = [(NSNumber *)[alertDirectory objectForKey:@"alertValue"]floatValue];
                aParam->date =mySnapshot.date;
                if([aParam alertWithSnapshot:mySnapshot])
                {
                    alertFlag = YES;
                    [alertArray addObject:aParam];
                }
            }
        }
        
    }
    if(alertFlag)
	{
		//[self saveAlertLogToFile];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:alertArray];
    }
    return alertArray;
}

- (void) alertNotify:(NSArray *)tickNotification
{
    
	[dataLock lock];
	if([tickNotification count]<2)
	{
		[dataLock unlock];
		return;
	}
	NSNumber *tmpCommodityNo = [tickNotification objectAtIndex:0];
	EquityTick *equityTick = [tickNotification objectAtIndex:1];
	UInt32 commodityNo = [tmpCommodityNo unsignedIntValue];
	
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	PortfolioItem *portfolioItem = [dataModal.portfolioData findInPortfolio:commodityNo];
	BOOL newAlertFlag = NO;
	if(portfolioItem && equityTick)
	{
        [alertDataArrayByTick removeAllObjects];
        [cancelAlertDataArray removeAllObjects];
		NSString *is =[portfolioItem getIdentCodeSymbol];
		NSMutableArray *alertData = [self findAlertDataByIdentSybmol:is];
		if([alertData count]>0)
		{
            for (int i =0; i<[alertData count]; i++) {
                NSMutableDictionary * alertDirectory = [[NSMutableDictionary alloc]init];
                alertDirectory = [alertData objectAtIndex:i];
                AlertParam *aParam = [[AlertParam alloc]init];
                aParam->identSymbol = is;
                aParam->alertID = [(NSNumber *)[alertDirectory objectForKey:@"alertId"]intValue];
                aParam->alertValue = [(NSNumber *)[alertDirectory objectForKey:@"alertValue"]floatValue];
                aParam->date = equityTick.snapshot.date;
                if ([aParam alertWithTick:equityTick]) {
                    newAlertFlag = YES;
                        
                    [alertDataArrayByTick addObject:aParam];
                }else{
                    [cancelAlertDataArray addObject:aParam];
                }
            }

        }
    }
        [self saveAlertDataToFile];
        
    if ([cancelAlertDataArray count]>0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"cancelAlertNotification" object:cancelAlertDataArray];
    }

	if(newAlertFlag)
	{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"alertNotification" object:alertDataArrayByTick];
        //neil
//		[self performSelectorOnMainThread:@selector(showBadgeValue) withObject:nil waitUntilDone:NO];
//		if(notifyObj)
//			[notifyObj performSelectorOnMainThread:@selector(notifyReload) withObject:nil waitUntilDone:NO];
        
	}
	[dataLock unlock];
}

- (void) sendAlertSnapshot
{
	[dataLock lock];
    
    if(!sendXML)
	{
		NSString *pathDate = [CodingUtil getDocumentsStringByFileName:@"XMLUpdate.plist"];
		NSString *key = nil;
		NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"cn"])
		{
			key = @"AlertDateCN";
		}else{
			key = @"AlertDate";
		}
        NSNumber *dateNumber = [[NSDictionary dictionaryWithContentsOfFile:pathDate] objectForKey:key];
		UInt16 tmpDate;
		if(dateNumber)
			tmpDate = [dateNumber unsignedIntValue];
		else
			tmpDate = [CodingUtil makeDate:1960 month:1 day:1];
		GetINIOut *giOut = [[GetINIOut alloc] initWithDate:tmpDate SwitchINI:1];
		[FSDataModelProc sendData:self WithPacket:giOut];
		sendXML = YES;
	}
    
	if(!sendSnapshotFlag)
	{
		sendSnapshotFlag = YES;
		AlertRegisterOut *arOut = [[AlertRegisterOut alloc] initWithAlertFlag:1];
		[FSDataModelProc sendData:self WithPacket:arOut];
		if(alertOnOff)
		{
			NSMutableArray *identSymbolArray = [[NSMutableArray alloc] init];
			for(NSString *aKey in [priceAlertData allKeys])
			{
				[identSymbolArray addObject:aKey];
			}
			if([identSymbolArray count])
			{
				UInt32 *allSecurityNum = malloc([identSymbolArray count] * sizeof(UInt32));
				int i=0;
				for(NSString *identSymbol in identSymbolArray)
				{
					PortfolioItem *pItem = [[[FSDataModelProc sharedInstance]portfolioData] findItemByIdentCodeSymbol:identSymbol];
					if(pItem && pItem->commodityNo)
					{
						allSecurityNum[i++] = pItem->commodityNo;
					}
				}
//				AlertSnapshotOut *asOut = [[AlertSnapshotOut alloc] initWithSecurityNum:allSecurityNum Count:i];
//				[FSDataModelProc sendData:self WithPacket:asOut];
				
				free(allSecurityNum);
			}
		}
	}
	
	
	
	[dataLock unlock];
}

-(NSMutableDictionary*)findTermDataByAlertID:(FSAlertID)aID{
    [dataLock lock];
	NSMutableDictionary *termDict = [[NSMutableDictionary alloc] init];
    for (NSString *aKey in [priceAlertData allKeys]) {
        NSMutableArray *dataArray = [priceAlertData objectForKey:aKey];
        if ([self findAlertDataByAlertID:aID DataArray:dataArray]) {
            [termDict setObject:dataArray forKey:aKey];
        }
    }
	[dataLock unlock];
    return termDict;
}

- (NSMutableArray*)findAlertDataByIdentSybmol:(NSString*)is
{
	[dataLock lock];
	NSMutableArray *returnData = nil;
    returnData = [priceAlertData objectForKey:is];
	[dataLock unlock];
	return returnData;
}

- (NSMutableDictionary*)findAlertDataByAlertID:(FSAlertID)aID DataArray:(NSMutableArray *)dataArray
{
	[dataLock lock];
	NSMutableDictionary *returnAlert = nil;
	for(NSMutableDictionary *data in dataArray)
	{
		if(aID == [(NSNumber *)[data objectForKey:@"alertId"]intValue])
		{
			returnAlert = data;
			break;
		}
        else if (aID == [(NSNumber *)[data objectForKey:@"termId"] intValue]) {
            returnAlert = data;
            break;
        }
        else if (aID == [(NSNumber *)[data objectForKey:@"targetId"] intValue]){
            returnAlert = data;
            break;
        }
        else if (aID == [(NSNumber *)[data objectForKey:@"spId"] intValue]){
            returnAlert = data;
            break;
        }
        else if (aID == [(NSNumber *)[data objectForKey:@"slId"] intValue]){
            returnAlert = data;
            break;
        }
        else if (aID == [(NSNumber *)[data objectForKey:@"buyStrId"] intValue]){
            returnAlert = data;
            break;
        }
        else if (aID == [(NSNumber *)[data objectForKey:@"sellStrId"] intValue]){
            returnAlert = data;
            break;
        }
        else if (aID == [(NSNumber *)[data objectForKey:@"refId"] intValue]){
            returnAlert =data;
            break;
        }
	}
	[dataLock unlock];
	return returnAlert;
}

-(NSString *)findTechAlertDataByAlertID:(FSAlertID)aID{
    [dataLock lock];
	NSString *returnData = nil;
    returnData = [priceAlertData objectForKey:[NSNumber numberWithInt:aID]];
	[dataLock unlock];
	return returnData;
}

- (void)removeAlertByAlertID:(FSAlertID)aID InIdentCodeSymbol:(NSString *)is
{
	[dataLock lock];
	NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray = [priceAlertData objectForKey:is];
	for(NSMutableDictionary *aParam in dataArray)
	{
		if([(NSNumber *)[aParam objectForKey:@"alertId"]intValue] == aID)
			[tmpArray addObject:aParam];
        if([(NSNumber *)[aParam objectForKey:@"termId"]intValue] == aID)
			[tmpArray addObject:aParam];
        if([(NSNumber *)[aParam objectForKey:@"targetId"]intValue] == aID)
			[tmpArray addObject:aParam];
        if([(NSNumber *)[aParam objectForKey:@"spId"]intValue] == aID)
			[tmpArray addObject:aParam];
        if([(NSNumber *)[aParam objectForKey:@"slId"]intValue] == aID)
			[tmpArray addObject:aParam];
        if([(NSNumber *)[aParam objectForKey:@"buyStrId"]intValue] == aID)
			[tmpArray addObject:aParam];
        if([(NSNumber *)[aParam objectForKey:@"sellStrId"]intValue] == aID)
			[tmpArray addObject:aParam];
        if([(NSNumber *)[aParam objectForKey:@"refId"]intValue] == aID)
			[tmpArray addObject:aParam];
	}
    
	for(NSMutableDictionary *aParam in tmpArray)
	{
		[dataArray removeObject:aParam];
	}
	[dataLock unlock];
}

- (void)deleteDataByIdentCodeSymbol:(NSString *)is{
    [dataLock lock];
    [priceAlertData removeObjectForKey:is];
	[dataLock unlock];
}

-(void)deleteAllData{
    [dataLock lock];
    [priceAlertData removeAllObjects];
    [dataLock unlock];
}

-(void)addAlertData:(NSMutableDictionary *)dict{
    [dataLock lock];
    priceAlertData = dict;
    [dataLock unlock];
}

- (void)addNewAlertData:(NSMutableDictionary*)data InIdentCodeSymbol:(NSString *)is
{
	[dataLock lock];

    NSMutableArray * dataArray;
    if ([priceAlertData objectForKey:is] != nil) {
        dataArray = [[NSMutableArray alloc]initWithArray:[priceAlertData objectForKey:is]];
    }else{
        dataArray = [[NSMutableArray alloc]init];
    }
    [dataArray addObject:data];
	[priceAlertData setObject:dataArray forKey:is];
	[dataLock unlock];
    
}

- (void)loadAlertDataFromFile
{
	[dataLock lock];
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AlertData.plist"];
	NSDictionary *loadDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	
	[priceAlertData removeAllObjects];
    [techAlertData removeAllObjects];
    
    if ([loadDictionary objectForKey:@"priceAlert"] != nil) {
        priceAlertData = [[loadDictionary objectForKey:@"priceAlert"] mutableCopy];
    }
    if ([loadDictionary objectForKey:@"techAlert"] !=nil) {
        techAlertData = [[loadDictionary objectForKey:@"techAlert"] mutableCopy];
    }
    
    [dataLock unlock];
}

- (void)saveAlertDataToFile
{
	[dataLock lock];
	NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"AlertData.plist"];
	
	NSMutableDictionary *saveDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:techAlertData,@"techAlert",priceAlertData,@"priceAlert", nil];
    
	[saveDictionary writeToFile:path atomically:YES];
	[dataLock unlock];
}

- (void)xmlDataIn:(AlertINIIn*)alertXML
{
	[dataLock lock];
	if(xmlData == nil)
		xmlData = [[NSMutableData alloc] init];
	[xmlData appendData:[NSData dataWithBytes:alertXML->data length:alertXML->dataLength]];
	if(alertXML->totalSN == alertXML->sn && alertXML->totalSN > 0 && alertXML->dataLength)
	{
		NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
		NSString *path = nil;
		NSString *key = nil;
		NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"cn"])
		{
			key = @"AlertDateCN";
			path = [documentsDirectory stringByAppendingPathComponent:@"AnalysisAlertCN.xml"];
		}
		else
		{
			key = @"AlertDate";
			path = [documentsDirectory stringByAppendingPathComponent:@"AnalysisAlert.xml"];
		}
		NSString *pathDate = [documentsDirectory stringByAppendingPathComponent:@"XMLUpdate.plist"];
		NSMutableDictionary *dateDict = [NSMutableDictionary dictionaryWithContentsOfFile:pathDate];
		if(dateDict)
		{
			[dateDict setObject:[NSNumber numberWithUnsignedInt:alertXML->date] forKey:key];
			[dateDict writeToFile:pathDate atomically:YES];
		}
		else
		{
			dateDict = [[NSMutableDictionary alloc] init];
			[dateDict setObject:[NSNumber numberWithUnsignedInt:alertXML->date] forKey:key];
			[dateDict writeToFile:pathDate atomically:YES];
		}
		[xmlData writeToFile:path atomically:YES];
        
        [self goParserAlert:xmlData];
		
    }
    
	[dataLock unlock];
}

-(void)goParserAlert:(NSMutableData*)newXmlData{
    NSMutableArray *paramArray = [[NSMutableArray alloc]init];
    DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithData:newXmlData options:0 error:nil];
    
    NSArray *alert = [xmlDoc nodesForXPath:@"/AlertUI/AlertIDList/alert" error:nil];
    for (DDXMLElement *element in alert) {
        
        AlertXMLParam *xmlParam = [[AlertXMLParam alloc] init];
        xmlParam->name = [[element elementForName:@"name"] stringValue];
        xmlParam->alertID = [(NSNumber *)[[element elementForName:@"id"]stringValue]intValue];
        xmlParam->type = [(NSNumber *)[[element elementForName:@"type"]stringValue]intValue];
        [paramArray addObject:xmlParam];
        
    }
    
    alertXMLParamArray = paramArray;
}

- (void)alertSnapshotArrive:(AlertSnapshotIn*)asIn
{
	[dataLock lock];
	for(AlertSnapshotParam *asParam in asIn.alertSnapshotArray)
	{
		PortfolioItem *portfolioItem = [[[FSDataModelProc sharedInstance]portfolioData] getAllItem:asParam->securityNum];
		if(portfolioItem)		//如果有在自選股裡
		{
            for( NSString *aKey in [techAlertData allKeys] )
            {
                int i = [aKey intValue]-1;
                UInt8 flagValue = [CodingUtil getUint8FromBuf:&asParam->alertBytes[i/8] Offset:i%8 Bits:1];
                if (flagValue) {
                    AlertParam *aParam = [[AlertParam alloc]init];
                    aParam->identSymbol = [portfolioItem getIdentCodeSymbol];
                    aParam->alertID = i;
                }
            }
        }
    }
    
    [self saveAlertDataToFile];
    [dataLock unlock];
}

@end

@implementation AlertParam

- (BOOL)alertWithTick:(EquityTick*)equityTick{
    BOOL newAlertFlag = NO;
	UInt16 sequenceNo = equityTick.snapshot.sequenceOfTick;
	TickDecompressed *currentTick = [equityTick copyTickAtSequenceNo:sequenceNo];
	TickDecompressed *preTick = [equityTick copyTickAtSequenceNo:(sequenceNo-1)];
	if(currentTick == nil || preTick == nil)
	{
		return NO;
	}
    
    if (alertID == profitAlert){
        if (currentTick.price>=alertValue) {
            newAlertFlag = YES;
        }
    }
    else if (alertID == lostAlert){
        if (currentTick.price <= alertValue) {
            newAlertFlag = YES;
        }
    }
	return newAlertFlag;
}

-(BOOL)alertWithSnapshot:(EquitySnapshotDecompressed *)snapShot{
    BOOL alertFlag = NO;
    
    if (alertID == profitAlert){
        if (snapShot.currentPrice>=alertValue) {
            alertFlag = YES;
        }
    }
    else if (alertID == lostAlert){
        if (snapShot.currentPrice <= alertValue) {
            alertFlag = YES;
        }
    }
    
    return alertFlag;
}
@end


@implementation AlertXMLParam


@end
