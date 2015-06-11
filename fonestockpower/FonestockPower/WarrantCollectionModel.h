//
//  WarrantCollectionModel.h
//  FonestockPower
//
//  Created by Kenny on 2014/9/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WarrantCollectionModel : NSObject 
-(NSMutableDictionary *)getCatName;
-(NSMutableArray *)getFullName:(int)sectorID;
-(NSString *)getIdentCodeSymbol:(NSString*)fullName;
@end
