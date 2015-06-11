//
//  Alert.h
//  FonestockPower
//
//  Created by Neil on 14/5/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AlertINIIn;
typedef NS_ENUM(NSUInteger, FSAlertID) {
    profitAlert=501,
    lostAlert,
    longTerm,
    shortTerm,
    longTarget,
    shortTarget,
    longSP,
    shortSP,
    longSL,
    shortSL,
    longBuyStr,
    shortBuystr,
    longSellStr,
    shortSellStr,
};

@interface Alert : NSObject
-(NSMutableArray *)checkAlertData;
- (void) alertNotify:(NSArray *)tickNotification;
- (void) sendAlertSnapshot;
- (NSMutableArray*)findAlertDataByIdentSybmol:(NSString*)is;
- (NSMutableDictionary*)findAlertDataByAlertID:(FSAlertID)aID DataArray:(NSMutableArray *)dataArray;
- (void)addNewAlertData:(NSMutableDictionary*)data InIdentCodeSymbol:(NSString *)is;
- (void)removeAlertByAlertID:(FSAlertID)aID InIdentCodeSymbol:(NSString *)is;
- (void)xmlDataIn:(AlertINIIn*)alertXML;
- (void)saveAlertDataToFile;
- (void)deleteDataByIdentCodeSymbol:(NSString *)is;
- (void)deleteAllData;
- (void)addAlertData:(NSMutableDictionary *)dict;
- (NSMutableDictionary*)findTermDataByAlertID:(FSAlertID)aID;
@property(strong, nonatomic) NSMutableDictionary *priceAlertData;
@end

@interface AlertParam : NSObject
{
@public
    NSString *identSymbol;
	int alertID;
	float alertValue;
    int termID;
    UInt16 date;
}

- (BOOL)alertWithTick:(EquityTick*)equityTick;
-(BOOL)alertWithSnapshot:(EquitySnapshotDecompressed *)snapShot;
@end

@interface AlertXMLParam : NSObject
{
    @public
	NSString *name;
	int alertID;
	UInt8 type;		//B是買 S是賣
}
@end