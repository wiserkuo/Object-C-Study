//
//  SecuritySearchModel.h
//  WirtsLeg
//
//  Created by Neil on 13/9/23.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NewSymbolKeywordIn;
@class SymbolKeywordIn;

@protocol  SecuritySearchProtocol<NSObject>

-(void)notifyArrive:(NSMutableArray *)dataArray;
-(void)notifyDataArrive:(NSMutableArray *)dataArray;
-(void)groupNotifyDataArrive:(NSMutableArray *)dataArray;
-(void)plateNotifyDataArrive:(NSMutableArray *)dataArray;
-(void)totalCount:(NSNumber *)count;
-(void)editTotalCount:(NSNumber *)count;
-(void)notifySqlDataArrive:(NSMutableArray *)array;
-(void)updateGroupName;

@end

@interface SecuritySearchModel : NSObject{
    NSObject<SecuritySearchProtocol> * notifyObj;
    NSObject<SecuritySearchProtocol> * groupNotifyObj;
    NSObject<SecuritySearchProtocol> * chooseObj;
    NSObject<SecuritySearchProtocol> * editChooseObj;
    NSObject<SecuritySearchProtocol> * chooseGroupObj;
    int nowPage;
    int maxPage;
    
    UInt8 * SecurityType;
    UInt16 * IdentCode;
    NSString * searchName;
    int searchGroup;//0=TW,1=US
    UInt8 IdentCodeCount;
}

@property (strong) NSMutableArray * allDataArray;
@property (strong) NSMutableArray * nameArray;
@property (strong) NSMutableArray * idArray;
@property (strong) NSMutableArray * sectorIdArray;
@property (strong) NSMutableArray * symbolArray;
@property (nonatomic) int totalNumber;
@property (nonatomic) int nowNumber;
@property (nonatomic) BOOL allDataFlag;

-(void)setTarget:(id)obj;
-(void)setGroupTarget:(id)obj;
-(void)setChooseTarget:(id)obj;
-(void)setEditChooseTarget:(id)obj;
-(void)setChooseGroupTarget:(id)obj;
-(void)searchData:(NSNumber *)number;
-(void)searchPlateData:(NSNumber *)number;
-(void)searchStock:(NSNumber *)number;
-(NSMutableArray *)searchGroup1Array:(int)number;
-(NSMutableArray *)searchGroup2Array:(int)number;
-(NSMutableArray *)searchGroup1CatId:(int)number;
-(int)searchUserStockWithName:(NSString *)name Group:(int)group;
-(int)searchUserStockWithSymbol:(NSString *)ids Group:(int)group;
-(int)countUserStockNum;
-(int)searchUserStockWithName:(NSString *)name Group:(int)group Country:(NSString *)country;
-(void)searchStockWithName:(NSString *)name;
-(void)searchWarrantStockWithName:(NSString *)name;
-(void)searchAmericaStockWithName:(NSString *)name;
-(void)searchAmericaStockWithSymbol:(NSString *)symbol;
-(void)searchSymbolAndFullNameWithSymbolFormat1:(SymbolFormat1 *)symbolformat1;
-(void)searchUserGroup;
-(void)searchUserStockWithGroup:(NSNumber*)groupID;
-(NSMutableArray *)searchUserStockArrayWithGroup:(NSNumber*)groupID;
-(void)searchStockFromServerWithName:(NSString *)name;
-(void)searchAmericaStockFromServerWithName:(NSString *)name;
-(void)countUserStock;
-(void)deleteUserStock:(NSMutableArray *)array;
-(void)editUserStock:(NSMutableArray *)array;
-(void)updateUserGroupName:(NSMutableArray *)array;
-(NSString *)searchFullNameWithIdentCode:(NSString *)identCode Symbol:(NSString *)symbol;
-(void)searchAgain:(NewSymbolKeywordIn *)obj;
-(NSMutableArray *)searchUserStockWithGroup2:(NSNumber*)groupID;
@end
