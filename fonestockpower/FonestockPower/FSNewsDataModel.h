//
//  FSNewsDataModel.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/8.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSNewsDataModel : NSObject{
    id notifyObj;
}
@property int sectorID;

//-(void)newsModelCallBack:(NSMutableArray *)array;

-(void)setTarget:(id)obj;

-(void)sendPacketWithRootID;

-(void)newsSnDataCallBack:(NSMutableArray *)array;

-(void)sendPacketWithSectorID:(int)sectorID;

-(void)newsTitleDataCallBack:(NSMutableArray *)array;

-(void)notify:(NewsContentIn *)obj;

-(NSMutableArray *)loadDB:(int)parentID;

-(NSMutableArray *)loadDBTitleWithSectorID:(int)sectorID;

-(NSString *)makeDateStringByDate:(UInt16)date time:(UInt16)time;

-(void)sendNewsContent:(UInt32)sn;

- (void) setHadReadNet:(NSString *)obj;

-(int)loadDBCountWithSectorID:(int)sectroID;

-(NSString *)loadDBCatNameWithSectorID:(int)sectorID;

-(NSMutableArray *)loadDBNavNameWithRootID;

-(void)parseNewsUrlAndSaveToDB;

-(void)parseNewsContentUrlAndSaveToDB:(int)sectorID;

-(NSString *)loadDBCatNameWithSectorIDForURL:(int)sectorID;

-(int)loadDBCountWithSectorIDForURL:(int)sectroID;

@end

@interface NewNewsContentFormat1 : NSObject

@property UInt16 sN;
@property UInt32 newsSN;
@property UInt16 time;
@property UInt8 type;
@property bool contentFlag;
@property UInt8 reserved;
@property UInt16 length;
@property UInt8 *mimeData;
@property NSString *mimeString;

-(instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset;

@end


@interface FinancialNews : NSObject

@property NSString *btnName;
@property int catID;
@property NSString *tableViewTitle;
@property int tableViewDate;
@property int tableViewTime;
@property int hadRead;
@property int newsSN;
@property NSString *content;
@property int type;
@property int sectorID;
@property NSString *urlContentTime;

@end

@interface NewsObject : NSObject

+ (NewsObject *)sharedInstance;

@property int sectorID;

@end

