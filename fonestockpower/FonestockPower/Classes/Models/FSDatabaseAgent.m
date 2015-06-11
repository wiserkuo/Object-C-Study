//
//  FSDatabaseAgent.m
//  FonestockPower
//
//  Created by Connor on 14/3/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSDatabaseAgent.h"
#import "DefaultDBData.h"
#import "FSActionPlanDatabase.h"

@interface FSDatabaseAgent() {
    
}

@end

@implementation FSDatabaseAgent

- (instancetype)initWithPath:(NSString*)aPath {
    if(![self databaseExist]){
        [self copyDatabase];
        createDB = YES;
    }
    return [super initWithPath:aPath];
}

- (void)initFonestockDB {
    
    
    if (createDB) {
        DefaultDBData * defaultDB = [[DefaultDBData alloc]init];
        [defaultDB setDefaultDBData];
        
        
    }
#ifdef SERVER_SYNC
    NSDictionary *path =[[NSBundle mainBundle] infoDictionary ];
    NSString * buildNumber = [path objectForKey:@"CFBundleVersion"];
    FSActionPlanDatabase *actionPlanDB = [[FSActionPlanDatabase alloc] init];
    [actionPlanDB setUpTables];
    
    if (![self checkTableExists:@"FonestockSystemParameters"]) {
        [self inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS FonestockSystemParameters(Parameter TEXT PRIMARY KEY, Value TEXT, Description TEXT)"];
        [db executeUpdate:@"INSERT INTO FonestockSystemParameters (Parameter, Value, Description) VALUES ('DBVersion', ?, '資料庫版本')",buildNumber];
        }];
    }
#endif
}

- (NSString *)dbVersion {
    __block NSString *dbVersion;
    [self inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT Value FROM FonestockSystemParameters WHERE Parameter = 'DBVersion'"];
        while ([rs next]) {
            dbVersion = [rs stringForColumn:@"Value"];
            break;
        }
        [rs close];
    }];
    return dbVersion;
}

- (BOOL)checkTableExists:(NSString *)tableName {
    __block BOOL tableExists = NO;
    [self inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM sqlite_master WHERE name = ? and type='table'", tableName];
        while ([rs next]) {
            tableExists = YES;
            break;
        }
        [rs close];
    }];
    return tableExists;
}

- (void)copyDatabase
{
	NSError *error;
	
    NSFileManager *fileManager = [[NSFileManager alloc] init];
	
     NSString *dbFilePath = [[FSFonestock sharedInstance]appMainDatabaseBundleFilePath];
    
    NSString * dbCachePath = [[FSFonestock sharedInstance]appMainDatabaseFilePath];
	
	//Copy the database file to the users document directory.
	if (![fileManager copyItemAtPath:dbFilePath toPath:dbCachePath error:&error])
		NSLog(@"Failed to copy the database. Error: %@.", [error localizedDescription]);
    
}

- (BOOL)databaseExist
{
	NSFileManager *fileManager =  [[NSFileManager alloc] init];
	return [fileManager fileExistsAtPath:[[FSFonestock sharedInstance]appMainDatabaseFilePath]];
}

@end
