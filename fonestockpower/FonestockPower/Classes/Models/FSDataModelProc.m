//
//  FSDataModelProc.m
//  FonestockPower
//
//  Created by Connor on 14/3/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSDataModelProc.h"
#import "FSSocketProc.h"
#import "OutPacket.h"
#import "FigureSearchUS.h"
#import "SecuritySearchModel.h"
#import "FSOutPacket.h"
#import "NSObject+Ext.h"

@interface FSDataModelProc() {
    NSTimer *dataModelTimer;
    NSCondition *conditionReady;
    FSNotificationCenter *notificationCenter;
    BOOL isReady;
}
@end

@implementation FSDataModelProc
static FSDataModelProc *sharedInstance = nil;

#pragma --
#pragma mark 生命週期

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FSDataModelProc alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        conditionReady = [[NSCondition alloc] init];
    }
    return self;
}

- (void)waitUntilReady {
    [conditionReady lock];
    
    while (!isReady) {
        [conditionReady wait];
    }
    
    [conditionReady unlock];
}

- (void)dealloc {
    // 永遠不被執行
}

#pragma --
#pragma mark 執行緒執行階段

- (void)main {
    
    _thread = [NSThread currentThread];
    
    // 系統參數初始化
    _fonestock = [FSFonestock sharedInstance];
    
    _isRejectReLogin = NO;
    
    _accountManager = [[FSAccountManager alloc] init];
    
    // 驗證
    _loginService = [[FSLoginService alloc] initWithAuthURLString:[_fonestock authenticationServerURL]];
    
    // service server
    _mainSocket = [[FSSocketProc alloc] init];
    [_mainSocket start];
    [_mainSocket waitUntilReady];
    
    // 資料庫
    _mainDB = [[FSDatabaseAgent alloc] initWithPath:[_fonestock appMainDatabaseFilePath]];
//#ifdef SERVER_SYNC
    
#if defined(PatternTipsUS) || defined(PatternTipsTW) || defined(PatternTipsCN) || defined(PatternPowerUS) || defined(PatternPowerTW) || defined(PatternPowerCN)
    [_mainDB initFonestockDB];
#endif
    
    
    
    
    
    // 推播通知
    _pushNotificationCenter = [[FSPushNotificationCenter alloc] initWithUpdateTokenWithURLString:[_fonestock updatePushNotificationTokenURL]];
    
    notificationCenter = [[FSNotificationCenter alloc] init];
    _signupModel = [[FSSignupModel alloc] initWithSignupURL:_fonestock.signupPageURL
                                                 resetPWURL:_fonestock.forgotPasswordURL
                                             openProjectURL:_fonestock.openProjectURL
                                                fbSharedURL:_fonestock.FBShareNotificationURL
                                                      appId:_fonestock.appId
                                                       uuid:[FSFonestock uuid]
                                                       lang:_fonestock.lang];
#ifdef SERVER_SYNC
    

    
    _iapHelper = [[FSIAPHelper alloc] initWithProductsListsURL:@"http://172.31.5.104/fs_service/apiQuery/subscription_id" verifyReceiptURL:@"https://www.fonestock.com.tw/fs_service/apiPayment/receipt_ios"];
    
    _category = [[FSCategoryTree alloc] init];
    //portfolio
    _securityName = [[SecurityNameData alloc]init];
    _portfolioData = [[Portfolio alloc]init];
    
    _portfolioTickBank = [[PortfolioTick alloc]initWithType:kTickTypeEquity];
    _historicTickBank = [[PortfolioTick alloc]initWithType:kTickTypeHistoricData];
#endif
    
    
   
    // 關閉alert 20150120 connor
//    _alert = [[Alert alloc]init];
    
    dataModelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runtest) userInfo:nil repeats:YES];
    

    
    
    //背離
    _tech = [[Tech alloc] init];
    _divergenceModel = [[FSDivergenceModel alloc] init];
    
    //patterntips
    _patternTipsModel = [[PatternTipsModel alloc] init];
    
    

#ifdef SERVER_SYNC
    
    
    
    // watchlist
    _watchlists = [[WatchLists alloc]init];
    
    
    
    
    //eod
    _edoActionModel = [[EODActionModel alloc] init];
    _eodTarget = [[EODTarget alloc] init];
    _trendEODModel = [[TrendEODActionModel alloc] init];
    
    //figureSearchUS
    _figureSearchUS = [[FigureSearchUS alloc]init];
    
    _securitySearchModel = [[SecuritySearchModel alloc]init];
    
    _marketInfo = [[MarketInfo alloc] init];
    
    _indicator = [[Indicator alloc]init];
    
    //券商
    _brokers = [[Brokers alloc] init];
    _brokerInfo = [[BrokerInfo alloc] init];
    _brokerBranchInfo = [[FSBrokerBranchInfo alloc] init];

    
    //營業員
    _esmTraderInfo = [[EsmTraderInfo alloc] init];
    _esmData = [[EsmData alloc]init];
    
    //公司
    _companyProfile = [[NewCompanyProfile alloc]init];
    _majorProducts = [[MajorProducts alloc] init];
    _majorHolders = [[MajorHolders alloc] init];
    _boardMemberHolding = [[BoardMemberHolding alloc] init];
    _boardMemberTransfer = [[BoardMemberTransfer alloc] init];
    _stockHolderMeeting = [[StockHolderMeeting alloc] init];
    _investerHold = [[InvesterHold alloc] init];
    _boardHolding = [[BoardHolding alloc] init];
    
    //Revenue
//    _revenue = [[Revenue alloc]init];
    _nRevenue = [[NewRevenue alloc] init];
    
    //eps
    _historicalEPS = [[HistoricalEPS alloc]init];
    
    //財報
    _balanceSheet = [[BalanceSheet alloc]init];
    _income = [[Income alloc]init];
    _cashFlow = [[CashFlow alloc]init];
    _financialRatio = [[FinancialRatio alloc]init];
    
    
    
    if (_fonestock.marketVersion == FSMarketVersionUS) {
        _financeReportUS = [[FSFinanceReportUS alloc] init];
    } else if (_fonestock.marketVersion == FSMarketVersionCN) {
        _financeReportCN = [[FSFinanceReportCN alloc] init];
    }
    
    _tradeDistribute = [[TradeDistribute alloc]init];
    
    _operationalIndicator = [[OperationalIndicator alloc]init];
    
    //FigureSearch
    _figureSearchModel = [[FigureSearchMyProfileModel alloc] init];
    
    //Real Time
    _infoPanelCenter = [[FSInfoPanelPageSetCenter alloc] init];
    
    _investedModel = [[FSInvestedModel alloc] init];
    
    _positionModel = [[FSPositionModel alloc] init];
    
    _investerBS = [[InvesterBS alloc] init];
    
    _cyqModel = [[CYQModel alloc] init];
    
    _marginTrading = [[MarginTrading alloc] init];
    
    _todayReserve = [[TodayReserve alloc] init];
    
    _relatedNewsData = [[RelatedNewsData alloc] init];
    
    
    
    _specialStateModel = [[SpecialStateModel alloc]init];
    
    _actionPlanModel = [[FSActionPlanModel alloc] init];
    
    _financeModel = [[FSFinanceModel alloc] init];
    
    
// 神奇力使用
#ifdef StockPowerTW
    [self stockPowerModel];
#endif
    
    
    
#endif
    
    [conditionReady lock];
    
    isReady = YES;
    [conditionReady signal];
    [conditionReady unlock];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    do {
        [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while (1);
}

- (void)runtest {
    
}



#ifdef StockPowerTW

// 神奇力使用
- (void)stockPowerModel {
    
    //
    _vipMessage = [[VIPMessage alloc] init];

    // 權證
    _warrant = [[Warrant alloc] init];
    
    // 選擇權
    _option = [[Option alloc] init];
    
    // 興櫃
    _emergingObj = [[FSEmergingObject alloc] init];
    
    // 期貨
    _futureModel = [[FutureModel alloc]init];
    
    //
    _goodStockModel = [[GoodStockModel alloc]init];
    
    //
    _fastStockModel = [[FSFastStockModel alloc]init];
    
    //
    _mainBargaining = [[FSMainBargaining alloc]init];
    
    // 主力系列
    _powerSeriesObject = [[FSPowerSeriesObject alloc] init];
    
    // 新聞
    // _newsData = [[NewsData alloc] init];
    // _newsDataModel = [[FSNewsDataModel alloc] init];
    
}

#endif






// 舊格式支援

+ (void)sendData:(NSObject *)data WithPacket:(NSObject <EncodeProtocol> *)body {
    
    FSSocketProc *mainSocket = [[FSDataModelProc sharedInstance] mainSocket];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    if([mainSocket isConnected] == NO && dataModel.isRejectReLogin){
        //在這裡需做重新連線的動作，
        dataModel.isRejectReLogin = NO;
        [dataModel.accountManager setLoginAccount:dataModel.accountManager.account password:dataModel.accountManager.password];
        [dataModel.loginService disconnectReloginAuth];
        return;
    }
    else if ([mainSocket isConnected] == NO) {
        return;
    }
    
	OutPacket *head = [[OutPacket alloc] init];
	[head attchBody:body]; // 配置記憶體
	[head encode:data]; // 編碼

	NSLog(@"OutPacket - msg: %d / cmd: %d", [head msg], [head cmd]);
    
    [mainSocket performSelector:@selector(sendPacket:) onThread:mainSocket.thread withObject:head waitUntilDone:NO];
}

//+ (void)sendPacketWithData:(NSObject *)data {
//    FSSocketProc *mainSocket = [[FSDataModelProc sharedInstance] mainSocket];
//    if ([mainSocket isConnected] == NO) {
//        return;
//    }
//    
//    FSOutPacket *packet = [[FSOutPacket alloc] initWithData:data];
//    [mainSocket performSelector:@selector(sendPacket:) onThread:mainSocket.thread withObject:packet waitUntilDone:NO];
//    
//    NSLog(@"電文送出 %@", [self classCallerName]);
//}

@end
