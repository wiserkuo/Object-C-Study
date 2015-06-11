//
//  VIPMessage.h
//  Bullseye
//
//  Created by Neil on 13/9/2.
//
//

#import <Foundation/Foundation.h>
#import "DataArriveProtocol.h"
#import "VIPSNQueryIn.h"

@interface VIPMessage : NSObject{
    id notifyObj;
    int dbMaxSerial;

}


@property (nonatomic) BOOL isDatabaseValid;
@property (strong) NSMutableArray * SNumberArray;
@property (strong) NSMutableArray * titleArray;
@property (strong) NSMutableArray * contentArray;
@property (strong) NSMutableArray * subTitleArray;
@property (strong) NSMutableArray * readArray;
@property (strong) NSMutableArray * dateArray;

@property (nonatomic)int maxS;

- (void) initDatabase;
-(void)vipSNQueryOut;
-(void)showVIPMessageTitle;
-(void)setTarget:(id)obj;
-(void)setRead2:(NSNumber*)row;
-(void)deleteMessage:(NSNumber *)row;
-(void)insertDataInDB:(NSMutableArray *)array;
-(void)setMessageQueryOutData:(VIPSNQueryIn *)obj;
@end
