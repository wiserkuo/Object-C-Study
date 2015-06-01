//
//  FSDatabaseAgent.h
//  FonestockPower
//
//  Created by Connor on 14/3/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface FSDatabaseAgent : FMDatabaseQueue{
    BOOL createDB;//建立資料庫
}
- (void)initFonestockDB;
- (NSString *)dbVersion;
@end
