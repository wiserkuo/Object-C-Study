//
//  FSActionPlanDatabase.m
//  FonestockPower
//
//  Created by Derek on 2014/5/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionPlanDatabase.h"
#import "FMDB.h"

@implementation FSActionPlanDatabase
+(FSActionPlanDatabase *)sharedInstances{
    static FSActionPlanDatabase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FSActionPlanDatabase alloc] init];
    });
    return sharedInstance;
}

-(void)setUpTables{
//    [self createPortfolioTable];
//    [self createPerformanceTable];
    [self createInvestedTable];
    [self createTradeTable];
    [self createActionTable];
}

#pragma mark - Portfolio Database
-(void)createPortfolioTable{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS PortfolioManage(Date DATETIME, Symbol TEXT, Price FLOAT, Count INTEGER, Fee INTEGER, Term TEXT)"];
    }];
}

-(NSMutableArray *)searchPortfolioWithTerm:(NSString *)Term{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Symbol, Price, Count, Fee, Term, rowid FROM PortfolioManage WHERE Term = ?", Term];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *fee = [message stringForColumn:@"Fee"];
            NSString *term = [message stringForColumn:@"Term"];
            NSString *rowid = [message stringForColumn:@"rowid"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", price, @"Price", count, @"Count", fee, @"Fee", term, @"term", rowid, @"rowid", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchPortfolioWithSymbol:(NSString *)symbol{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol, Price, Count FROM PortfolioManage WHERE Symbol = ?", symbol];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *count = [message stringForColumn:@"Count"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", price, @"Price", count, @"Count", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(void)insertPortfolioWithDate:(NSString *)date Symbol:(NSString *)symbol Price:(NSString *)price Count:(NSString *)count Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"INSERT INTO PortfolioManage(Date, Symbol, Price, Count, term) VALUES(?, ?, ?, ?, ?, ?)", date, symbol, price, count, term];
    }];
}

-(void)updatePortfolioCount:(NSString *)count Withrowid:(NSString *)rowid{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE PortfolioManage SET Count = ? WHERE rowid = ?", count, rowid];
    }];
}

-(void)deletePortfolioWithSymbol:(NSString *)symbol{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM PortfolioManage WHERE Symbol = ?", symbol];
    }];
}

-(void)deletePortfolioWithrowID:(NSString *)rowid{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM PortfolioManage WHERE rowid = ?", rowid];
    }];
}

#pragma mark - Invested fund Database
-(void)createInvestedTable{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ActionPlanInvested(Date DATETIME, Remit TEXT, Amount INTEGER, Term TEXT)"];
//        [db executeUpdate:@"INSERT INTO ActionPlanInvested(Date, Remit, Amount, Term) SELECT strftime('%Y/%m/%d', 'now'), '匯入', '100000', 'Long' WHERE NOT EXISTS (SELECT 1 FROM ActionPlanInvested) UNION SELECT strftime('%Y/%m/%d', 'now'), '匯入', '100000', 'Short' WHERE NOT EXISTS (SELECT 1 FROM ActionPlanInvested)"];
    }];
}

-(id)searchInvestedByTerm:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT rowid, Date, Remit, Amount, Term, (Select SUM(Amount) FROM ActionPlanInvested as B WHERE Term = ? AND A.Date > B.Date OR (A.Date = B.Date AND A.rowid >= B.rowid AND Term = ?) ORDER BY Date) as Total_Amount from ActionPlanInvested as A WHERE Term = ? ORDER BY Date DESC, rowid DESC", term, term, term];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *remit = [message stringForColumn:@"Remit"];
            NSString *amount = [message stringForColumn:@"Amount"];
            NSString *totalAmount = [message stringForColumn:@"Total_Amount"];
            NSString *rowid = [message stringForColumn:@"rowid"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  date, @"Date", remit, @"Remit", amount, @"Amount", totalAmount, @"Total_Amount", rowid, @"rowid", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableDictionary *)searchInvestedDictionaryByTerm:(NSString *)term{
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT rowid, Date, Remit, Amount, Term, (Select SUM(Amount) FROM ActionPlanInvested as B WHERE Term = ? AND A.Date > B.Date OR (A.Date = B.Date AND A.rowid >= B.rowid AND Term = ?) ORDER BY Date) as Total_Amount from ActionPlanInvested as A WHERE Term = ? ORDER BY Date", term, term, term];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            float amount = [message doubleForColumn:@"Amount"];
            
            if ([dataDictionary objectForKey:date]) {
                amount += [(NSNumber *)[dataDictionary objectForKey:date]floatValue];
            }
            
            [dataDictionary setObject:[NSNumber numberWithFloat:amount] forKey:date];
        }
        [message close];
    }];
    return dataDictionary;
}

-(NSString *)searchInvestedTotalAmountByTerm:(NSString *)term Date:(NSString *)date{
    __block NSString *totalAmountStr;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT SUM(Amount) as Total_Amount FROM ActionPlanInvested WHERE Term = ? AND Date <= ?", term, date];
        while ([message next]) {
            NSString *totalAmount = [message stringForColumn:@"Total_Amount"];
            totalAmountStr = totalAmount;
        }
        [message close];
    }];
    return totalAmountStr;
}

-(id)searchInvestedData{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT rowid, Date, Remit, Amount, (Select SUM(Replace(Amount, ',', '')) FROM ActionPlanInvested as B where A.Date >= B.Date) as Total_Amount from ActionPlanInvested as A Group By Date"];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *totalAmount = [message stringForColumn:@"Total_Amount"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", totalAmount, @"totalAmount", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(void)insertInvestedWithDate:(NSString *)date Remit:(NSString *)remit Amount:(NSString *)amount Term:(NSString *)term {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"INSERT INTO ActionPlanInvested(Date, Remit, Amount, Term) VALUES(?, ?, ?, ?)", date, remit, amount, term];
    }];
}

-(void)deleteInvestedDataWithrowid:(NSString *)rowid{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM ActionPlanInvested WHERE rowid = ?", rowid];
    }];
}

#pragma mark - Performance Database
-(void)createPerformanceTable{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Performance(PerformanceNum INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE,EntryDate DATETIME, ExitDate DATETIME, Symbol TEXT, EntryPrice FLOAT, ExitPrice FLOAT, Quantity INTEGER, Fee INTEGER, Term TEXT, Note TEXT)"];
    }];
}

-(NSMutableArray *)searchPerformanceWithTerm:(NSString *)Term{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT rowid,EntryDate, ExitDate, Symbol, EntryPrice, ExitPrice, Quantity, Fee, Term,Note FROM Performance Where Term = ?", Term];
        while ([message next]) {
            NSString *rowid = [message stringForColumn:@"PerformanceNum"];
            NSString *entryDate = [message stringForColumn:@"EntryDate"];
            NSString *exitDate = [message stringForColumn:@"ExitDate"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *entryPrice = [message stringForColumn:@"EntryPrice"];
            NSString *exitPrice = [message stringForColumn:@"ExitPrice"];
            NSString *quantity = [message stringForColumn:@"Quantity"];
            NSString *fee = [message stringForColumn:@"Fee"];
            NSString *term = [message stringForColumn:@"Term"];
            NSString *note = [message stringForColumn:@"Note"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:rowid, @"rowid", entryDate, @"EntryDate", exitDate, @"ExitDate", symbol, @"Symbol", entryPrice, @"EntryPrice",exitPrice,@"ExitPrice", quantity, @"Quantity",  fee, @"Fee", term, @"Term", note, @"Note", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}


-(NSMutableArray *)searchSameDayBuyOrSellAVGWithIdentCodeSymbol:(NSString *)ids Date:(NSString *)date Deal:(NSString *)deal{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    NSMutableArray * countArray = [[NSMutableArray alloc]init];
    NSMutableArray * priceArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Count, Price FROM Trade Where Symbol = ? AND Date = ? AND Deal = ?", ids,date,deal];
        while ([message next]) {
            int count = [message intForColumn:@"Count"];
            double price = [message doubleForColumn:@"Price"];
            
            [countArray addObject:[NSNumber numberWithInt:abs(count)]];
            [priceArray addObject:[NSNumber numberWithDouble:price]];
        }
        [message close];
    }];
    [dataArray addObject:countArray];
    [dataArray addObject:priceArray];
    return dataArray;
}

-(void)insertPerformanceWithEntryDate:(NSString *)entryDate ExitDate:(NSString *)exitDate Symbol:(NSString *)symbol EntryPrice:(NSString *)entryPrice ExitPrice:(NSString *)exitPrice Quantity:(NSString *)quantity Fee:(NSString *)fee Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"INSERT INTO Performance(entryDate, exitDate, symbol, entryPrice, exitPrice, quantity, fee, term) VALUES(?, ?, ? ,?, ?, ?, ?, ?)", entryDate, exitDate, symbol, entryPrice, exitPrice, quantity, fee, term];
    }];
}

-(void)updatePerformanceNote:(NSString *)note WithPerformanceNum:(NSString *)date{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE Trade SET Note = ? WHERE Date = ? ",note,date];
    }];
}

-(void)updateReason:(NSString *)reason WithPerformanceNum:(NSString *)date{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE Trade SET Reason = ? WHERE Date = ? ",reason,date];
    }];
}

-(void)insertReasonWithIdSymbol:(NSString *)ids Date:(NSString *)date num:(NSNumber *)num Type:(NSString *)type{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"INSERT INTO reason(identCodeSymbol, date, reason, type) VALUES(?, ?, ?, ?)", ids,date,num,type];
    }];
}

-(void)deleteReasonWithIdSymbol:(NSString *)ids andDate:(NSString *)date Type:(NSString *)type{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM reason WHERE identCodeSymbol = ? And date = ? And type = ?", ids,date,type];
    }];
}

-(NSMutableArray *)searchReasonWithIdSymbol:(NSString *)ids andDate:(NSString *)date Type:(NSString *)type{
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT reason FROM reason  WHERE identCodeSymbol = ? And date = ? And type = ?",ids,date,type];
        while ([message next]) {
            int reason = [message intForColumn:@"reason"];
            [dataArray addObject:[NSNumber numberWithInt:reason]];
        }
        [message close];
    }];
    return dataArray;
}

-(NSData *)searchimageWithFigureSearchId:(NSNumber *)idNum{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    __block NSData * data;
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT image_binary FROM FigureSearch WHERE figureSearch_ID = ?",idNum];
        while ([message next]) {
            data = [message dataForColumn:@"image_binary"];
        }
        [message close];
    }];
    return data;
}



-(void)deletePerformanceWithSymbol:(NSString *)rowid{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM Performance WHERE PerformanceNum = ?", rowid];
    }];
}

-(id)unionTablesDateColumnWithTerm:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Date FROM ActionPlanInvested Where term = ? Union SELECT Date FROM Trade Where term = ? ORDER BY Date", term, term];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

#pragma mark - Trade Database
-(void)createTradeTable{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;

    [dbAgent inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Trade(Seq INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Date DATETIME, Symbol TEXT, Deal TEXT, Count Integer, Price Float, Term TEXT, Note TEXT, Reason Text)"];
    }];
}

-(NSMutableArray *)searchPositionWithTerm:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol, SUM(Count) as TotalCount FROM Trade WHERE Term = ? GROUP BY Symbol ORDER BY Seq", term];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", totalCount, @"TotalCount", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchPositionWithTermNotOrderBySeq:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol, SUM(Count) as TotalCount FROM Trade WHERE Term = ? GROUP BY Symbol", term];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", totalCount, @"TotalCount", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchCostOfTradeWithTerm:(NSString *)term Date:(NSString *)Date{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol, SUM(Count) as TotalCount FROM Trade WHERE Term = ? AND Date <= ? GROUP BY Symbol", term, Date];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", totalCount, @"TotalCount", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchTradeCountWithSymbol:(NSString *)symbol Date:(NSString *)date{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"select Date, Symbol, (SELECT SUM(Count) From trade as B where A. date >= B.date AND Symbol = ? Order By Date) as TotalCount from Trade as A WHERE Date <= ? AND Symbol = ? group by Date order by Date", symbol, date, symbol];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", totalCount, @"TotalCount", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSString *)searchSharesOwnedWithSymbol:(NSString *)symbol term:(NSString *)term{
    __block NSString *sharesOwnedStr = nil;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT SUM(Count) AS Count From trade WHERE Symbol = ? AND Term = ?", symbol, term];
        while ([message next]) {
            NSString *sharesOwned = [message stringForColumn:@"count"];
            sharesOwnedStr = [NSString stringWithFormat:@"%@", sharesOwned];
        }
        [message close];
    }];
    return sharesOwnedStr;
}

-(NSMutableArray *)searchRealizedOfNetWorthWithTerm:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Symbol, deal, Count, Price FROM Trade WHERE Term = ?", term];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *deal = [message stringForColumn:@"Deal"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *price = [message stringForColumn:@"Price"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", deal, @"Deal", count, @"Count", price, @"Price", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchRealizedWithIdSymbol:(NSString *)ids Term:(NSString *)term Deal:(NSString *)deal{

    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Count, Price FROM Trade WHERE Symbol = ? AND Term = ? AND Deal = ?",ids,term,deal];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            int count = [message intForColumn:@"Count"];
            [dic setObject:[NSNumber numberWithInt:count] forKey:@"Count"];
            float price = [message doubleForColumn:@"Price"];
            [dic setObject:[NSNumber numberWithFloat:price] forKey:@"Price"];
            [dataDictionary setObject:dic forKey:date];
            [dataArray addObject:dataDictionary];
            
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchPositionWithTerm:(NSString *)term Deal:(NSString *)deal{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Trade WHERE Term = ? AND Deal = ?", term, deal];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *count = [message stringForColumn:@"Count"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", price, @"Price", count, @"Count", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}


-(NSMutableArray *)searchPositionidSymbolWithTerm:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol FROM Trade WHERE Term = ? GROUP BY Symbol", term];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            [dataArray addObject:symbol];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchPositionWithIdSybol:(NSString *)ids Term:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT * FROM Trade WHERE Symbol = ? AND Term = ? ORDER BY Date",ids, term];
        while ([message next]) {
            NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            NSString *date = [message stringForColumn:@"Date"];
            int count = [message intForColumn:@"Count"];
            [dic setObject:[NSNumber numberWithInt:count] forKey:@"Count"];
            float price = [message doubleForColumn:@"Price"];
            [dic setObject:[NSNumber numberWithFloat:price] forKey:@"Price"];
            
            [dataDictionary setObject:dic forKey:date];
            [dataArray addObject:dataDictionary];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchPositionFirstDateWithIdSybol:(NSString *)ids Term:(NSString *)term{
    NSMutableArray *dataAray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Date FROM Trade WHERE Symbol = ? AND Term = ? ORDER BY Date",ids, term];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            
            [dataAray addObject:date];
        }
        [message close];
    }];
    return dataAray;
}

-(NSMutableArray *)searchPositionWithTerm:(NSString *)term Symbol:(NSString *)symbol{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message =[db executeQuery:@"SELECT Seq, Date, Symbol, Deal, Count, Price, (SELECT Count * Price) as Amount, (SELECT SUM(Count) FROM Trade as B WHERE A.Date >= B.Date AND Symbol = ? AND Term = ? ORDER BY Date) as TotalCount ,Note, Reason FROM Trade as A WHERE Term = ? AND Symbol = ? ORDER BY Date DESC, Seq DESC", symbol, term, term, symbol];
        while ([message next]) {
            NSString *seq = [message stringForColumn:@"Seq"];
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *deal = [message stringForColumn:@"Deal"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *amount = [message stringForColumn:@"Amount"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            NSString *note = [message stringForColumn:@"Note"];
            NSString *reason = [message stringForColumn:@"Reason"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:seq, @"Seq", date, @"Date", symbol, @"Symbol", deal, @"Deal", count, @"Count", price, @"Price", amount, @"Amount", totalCount, @"TotalCount", note, @"Note", reason, @"Reason", nil];

            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(double)searchPositionQTYWithTerm:(NSString *)term symbol:(NSString *)symbol{
    __block double totalQTY = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message =[db executeQuery:@"SELECT (SELECT SUM(Count) FROM Trade as B WHERE A.Date >= B.Date AND Symbol = ? AND Term = ? ORDER BY Date) as TotalCount FROM Trade as A WHERE Term = ? AND Symbol = ?", symbol, term, term, symbol];
        while ([message next]) {
            totalQTY = [message doubleForColumn:@"totalCount"];
        }
        [message close];
    }];
    return totalQTY;
}

-(NSMutableArray *)searchDiaryWithDeal:(NSString *)deal{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message =[db executeQuery:@"SELECT Symbol, SUM(Count) as TotalCount, SUM(Price * Count) / SUM(Count) as AvgCost FROM Trade WHERE Deal = ? GROUP BY Symbol", deal];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            NSString *avgCost = [message stringForColumn:@"AvgCost"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", totalCount, @"TotalCount", avgCost, @"AvgCost", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSMutableArray *)searchRealizedOfTradeWithDate:(NSString *)date{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message =[db executeQuery:@"SELECT Symbol, SUM(Count) as TotalCount FROM Trade WHERE Date <= ? GROUP BY Symbol", date];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", totalCount, @"TotalCount", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    return dataArray;
}

-(NSString *)searchQTYOfTradeWithSymbol:(NSString *)symbol Date:(NSString *)date Term:(NSString *)term{
    __block NSString *qTYStr;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message =[db executeQuery:@"SELECT SUM(Count) as TotalCount FROM Trade WHERE Symbol = ? AND Date <= ? AND Term = ?", symbol, date, term];
        while ([message next]) {
            NSString *str = [message stringForColumn:@"TotalCount"];
            qTYStr = str;
        }
        [message close];
    }];
    
    return qTYStr;
}

-(NSMutableArray *)searchDiaryWithTerm:(NSString *)term Deal:(NSString *)deal{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    return dataArray;
}

-(NSMutableArray *)searchAvgCostWithSymbol:(NSString *)symbol{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Symbol, Count, Price, (Select SUM(Count) FROM Trade as B WHERE A.Date >= B.Date AND Symbol = ? AND A.Seq >= B.Seq) as TotalCount, Deal FROM Trade as A WHERE Symbol = ? Order By Date", symbol, symbol];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            NSString *deal = [message stringForColumn:@"Deal"];
       
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", count, @"Count", price, @"Price", totalCount, @"TotalCount", deal, @"Deal", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchBuyDataOrderByPriceWithSymbol:(NSString *)symbol deal:(NSString *)deal{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Symbol, Count, Price, Deal FROM Trade as A WHERE Symbol = ? AND Deal = ? Order By Price DESC", symbol, deal];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *deal = [message stringForColumn:@"Deal"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", count, @"Count", price, @"Price", deal, @"Deal", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchBuyDataOrderByPriceWithSymbol:(NSString *)symbol deal:(NSString *)deal date:(NSString *)date{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Symbol, Count, Price, Deal FROM Trade as A WHERE Symbol = ? AND Deal = ? AND Date <= ? Order By Price DESC", symbol, deal, date];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *deal = [message stringForColumn:@"Deal"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", count, @"Count", price, @"Price", deal, @"Deal", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    
    return dataArray;
}


-(NSMutableArray *)searchAvgCosOfTradetWithSymbol:(NSString *)symbol Date:(NSString *)Date{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol, Count, Price, (Select SUM(Count) FROM Trade as B WHERE A.Date >= B.Date AND Symbol = ? AND A.Seq >= B.Seq) as TotalCount, Deal FROM Trade as A WHERE Symbol = ? AND Date <= ?", symbol, symbol, Date];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *price = [message stringForColumn:@"Price"];
            NSString *totalCount = [message stringForColumn:@"TotalCount"];
            NSString *deal = [message stringForColumn:@"Deal"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", count, @"Count", price, @"Price", totalCount, @"TotalCount", deal, @"Deal", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchGainDataWithSymbol:(NSString *)symbol Term:(NSString *)term DealBuy:(NSString *)dealBuy DealSell:(NSString *)dealSell{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];

    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
   
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Date, Symbol, (SELECT SUM(Count) FROM Trade as B WHERE A.Date >= B.Date AND Symbol = ? AND Term = ?) as Count, (SELECT SUM(Count * Price)  FROM Trade as B WHERE Deal = ? AND A.Date >= B.Date AND Symbol = ? AND Term = ?) as TotalBuy, (SELECT SUM(Count * Price) FROM Trade as C WHERE Deal = ? AND A.Date >= C.Date AND Symbol = ? AND Term = ?) as TotalSell FROM Trade as A WHERE Term = ? AND Symbol = ? GROUP BY Date ORDER BY Date", symbol, term, dealBuy, symbol, term, dealSell, symbol, term, term, symbol];
        while ([message next]) {
            NSString *date = [message stringForColumn:@"Date"];
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *count = [message stringForColumn:@"Count"];
            NSString *totalBuy = [message stringForColumn:@"TotalBuy"];
            NSString *totalSell = [message stringForColumn:@"TotalSell"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:date, @"Date", symbol, @"Symbol", count, @"Count", totalBuy, @"TotalBuy", totalSell, @"TotalSell", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    
    return dataArray;
}

-(BOOL)insertTradeWithDate:(NSString *)date Symbol:(NSString *)symbol Deal:(NSString *)deal Count:(NSString *)count Price:(NSString *)price Term:(NSString *)term Note:(NSString *)note{
    __block BOOL hasData = NO;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol FROM Trade WHERE Symbol = ? AND Term = ?", symbol, term];
        while ([message next]) {
            hasData = YES;
        }
        [message close];
//        if (hasData) {
//            [db executeUpdate:@"UPDATE Trade Set Date = ?, Symbol = ?, Deal = ?, Count = ?, Price = ?, Term = ?, Note = ? Where ", date, symbol, deal, count, price, term, note];
//        }else{
            [db executeUpdate:@"INSERT INTO Trade(Date, Symbol, Deal, Count, Price, Term, Note) VALUES(?, ?, ?, ?, ?, ?, ?)", date, symbol, deal, count, price, term,note];
//        }
        
    }];
    return hasData;
} 

-(void)deletePositionsWithrowid:(NSString *)rowid{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM Trade WHERE Seq = ?", rowid];
    }];
}

-(void)deletePositionsWithIdentCodeSymbol:(NSString *)symbol{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM Trade WHERE Symbol = ?", symbol];
    }];
}

-(void)deletePositionsWithIdentCodeSymbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM Trade WHERE Symbol = ? AND Term = ?", symbol, term];
    }];
}

#pragma mark - ActionPlan Database
-(void)createActionTable{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS ActionPlan(Symbol TEXT, Manual FLOAT, Pattern1 INTEGER, SProfit FLOAT, SLoss FLOAT, Pattern2 INTEGER, SProfit2 FLOAT, SLoss2 FLOAT,Term Text, CostType BOOL)"];
    }];
}

-(NSMutableArray *)searchActionPlanDataWithSymbol:(NSString *)symbol{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol, Term FROM ActionPlan WHERE Symbol = ?", symbol];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *term = [message stringForColumn:@"Term"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", term, @"Term", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    
    return dataArray;
}

-(int)searchActionPlanDataWithSymbol:(NSString *)symbol term:(NSString *)term{
    __block int exist = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol FROM ActionPlan WHERE Symbol = ? AND Term = ?", symbol, term];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            
            if ([symbol isEqualToString:symbol]) {
                exist = 1;
            }
        }
        [message close];
    }];
    
    return exist;
}

-(NSMutableArray *)searchActionPlanDataWithTerm:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT A1.* FROM ActionPlan A1, groupPortfolio A2 WHERE A1.Symbol = A2.identCodeSymbol AND A1.Term = ? AND A2.GroupID = '0' Order By A2.rowid ", term];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            NSString *term = [message stringForColumn:@"Term"];
            NSString *manual = [message stringForColumn:@"Manual"];
            NSString *pattern1 = [message stringForColumn:@"Pattern1"];
            NSString *SProfit = [message stringForColumn:@"SProfit"];
            NSString *SLoss = [message stringForColumn:@"SLoss"];
            NSString *pattern2 = [message stringForColumn:@"pattern2"];
            NSString *SProfit2 = [message stringForColumn:@"SProfit2"];
            NSString *SLoss2 = [message stringForColumn:@"SLoss2"];
            NSString *costType = [message stringForColumn:@"CostType"];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:symbol, @"Symbol", term, @"Term", manual, @"Manual", pattern1, @"Pattern1", SProfit, @"SProfit", SLoss, @"SLoss", pattern2, @"Pattern2", SProfit2, @"SProfit2", SLoss2, @"SLoss2", costType, @"CostType", nil];
            [dataArray addObject:dict];
        }
        [message close];
    }];
    
    return dataArray;
}

-(NSMutableArray *)searchActionPlanIdentCodeSymbol{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol FROM ActionPlan"];
        while ([message next]) {            
            [dataArray addObject:[message stringForColumn:@"Symbol"]];
        }
        [message close];
    }];
    
    return dataArray;
}

-(NSArray *)searchIdentCodeSymbolWithTerm:(NSString *)term{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol FROM ActionPlan  A1, groupPortfolio A2 WHERE A1.Symbol = A2.identCodeSymbol AND A1.Term = ? AND A2.GroupID = '0' Order By A2.rowid", term];
        while ([message next]) {
            [dataArray addObject:[message stringForColumn:@"Symbol"]];
        }
        [message close];
    }];
    
    return dataArray;
}

-(BOOL)searchExistSymbolWithSymbol:(NSString *)symbol{
    __block BOOL exist = NO;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT Symbol FROM ActionPlan WHERE Symbol = ?", symbol];
        while ([message next]) {
            NSString *symbol = [message stringForColumn:@"Symbol"];
            if (symbol != nil) {
                exist = YES;
            }
        }
        [message close];
    }];
    
    return exist;
}

-(float)searchNumberOfActionPlan{
    __block float countNum = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) as Count FROM ActionPlan"];
        while ([message next]) {
            NSString *count = [message stringForColumn:@"Count"];
            countNum = [(NSNumber *)count floatValue];
        }
        [message close];
    }];
    return countNum;
}

-(void)insertActionPlanWithSybmol:(NSString *)symbol Manual:(NSNumber *)manual Pattern1:(NSNumber *)pattern1 SProfit:(NSNumber *)sProfit SLoss:(NSNumber *)sLoss Pattern2:(NSNumber *)pattern2 Term:(NSString *)term SProfit2:(NSNumber *)SProfit2 SLoss2:(NSNumber *)SLoss2 CostType:(NSString *)costType{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"INSERT INTO ActionPlan(Symbol, Manual, Pattern1, SProfit, SLoss, Pattern2, Term, SProfit2, SLoss2, CostType) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", symbol, manual, pattern1, sProfit, sLoss, pattern2, term, SProfit2, SLoss2, costType];
    }];
}

-(void)updateActionPlanDataWithManual:(NSString *)manual Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET Manual = ? WHERE Symbol = ? AND Term = ?", manual, symbol, term];
    }];
}

-(void)updateActionPlanDataWithSProfit:(NSString *)SProfit Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET SProfit = ? WHERE Symbol = ? AND Term = ?", SProfit, symbol, term];
    }];
}

-(void)updateActionPlanDataWithSLoss:(NSString *)SLoss Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET SLoss = ? WHERE Symbol = ? AND Term = ?", SLoss, symbol, term];
    }];
}

-(void)updateActionPlanDataWithSProfit2:(NSString *)SProfit2 Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET SProfit2 = ? WHERE Symbol = ? AND Term = ?", SProfit2, symbol, term];
    }];
}

-(void)updateActionPlanDataWithSLoss2:(NSString *)SLoss2 Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET SLoss2 = ? WHERE Symbol = ? AND Term = ?", SLoss2, symbol, term];
    }];
}

-(void)updateActionPlanDataWithPattern1:(NSString *)pattern1 Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET Pattern1 = ? WHERE Symbol = ? AND Term = ?", pattern1, symbol, term];
    }];
}

-(void)updateActionPlanDataWithPattern2:(NSString *)pattern2 Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET Pattern2 = ? WHERE Symbol = ? AND Term = ?", pattern2, symbol, term];
    }];
}

-(void)updateActionPlanDataWithCostType:(NSString *)costType Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET CostType = ? WHERE Symbol = ? AND Term = ?", costType, symbol, term];
    }];
}

-(void)updateActionPlanDataWithPattern2:(NSString *)pattern2 SProfit2:(NSString *)SProfit2 SLoss2:(NSString *)SLoss2 Symbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"UPDATE ActionPlan SET Pattern2 = ?, SProfit2 =?, SLoss2 = ? WHERE Symbol = ? AND Term = ?", pattern2, SProfit2, SLoss2, symbol, term];
    }];
}

-(void)deleteActionbPlanDataWithSymbol:(NSString *)symbol{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM ActionPlan WHERE Symbol = ?", symbol];
    }];
}

-(void)deleteActionPlanDataWithSymbol:(NSString *)symbol Term:(NSString *)term{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        [db executeUpdate:@"DELETE FROM ActionPlan WHERE Symbol = ? AND Term = ?", symbol, term];
    }];
}

//groupPortfolio
-(int)searchGroupPortfolioWithids:(NSString *)ids{
    __block int exist = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT IdentCodeSymbol FROM groupPortfolio WHERE IdentCodeSymbol = ?", ids];
        while ([message next]) {
            NSString *identCodeSymbol = [message stringForColumn:@"IdentCodeSymbol"];
            if ([ids isEqualToString:identCodeSymbol]) {
                exist = 1;
            }
        }
        [message close];
    }];
    return exist;
}

-(int)searchNumberOfgroupPortfolio{
    __block int countNum = 0;
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [dbAgent inDatabase:^(FMDatabase *db) {
        FMResultSet *message = [db executeQuery:@"SELECT COUNT(*) as Count FROM groupPortfolio WHERE groupID = '0'"];
        while ([message next]) {
            NSString *count = [message stringForColumn:@"Count"];
            countNum = [(NSNumber *)count floatValue];
        }
        [message close];
    }];
    return countNum;
}

@end
