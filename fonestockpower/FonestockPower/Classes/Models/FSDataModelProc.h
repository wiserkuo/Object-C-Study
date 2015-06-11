//
//  FSDataModelProc.h
//  FonestockPower
//
//  Created by Connor on 14/3/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSThreadProtocol.h"
#import "FSDatabaseAgent.h"
#import "FSAccountManager.h"
#import "FSLoginService.h"
#import "FigureSearchUS.h"
#import "SecuritySearchModel.h"
#import "FSCategoryTree.h"
#import "MarketInfo.h"
#import "Indicator.h"
#import "BrokerInfo.h"
#import "Brokers.h"
#import "EsmData.h"
#import "EsmTraderInfo.h"
#import "BalanceSheet.h"
#import "Income.h"
#import "CashFlow.h"
#import "FinancialRatio.h"
#import "HistoricalEPS.h"
#import "NewCompanyProfile.h"
#import "Portfolio.h"
#import "SecurityName.h"
#import "WatchLists.h"
#import "TradeDistribute.h"
#import "PortfolioTick.h"
#import "OperationalIndicator.h"
#import "FSIAPHelper.h"
#import "Alert.h"
#import "FSPushNotificationCenter.h"
#import "EODActionModel.h"
#import "EODTarget.h"
#import "FSActionPlanModel.h"
#import "FSSocketProc.h"
#import "FSInvestedModel.h"
#import "FSPositionModel.h"
#import "MajorProducts.h"
#import "MajorHolders.h"
#import "BoardMemberHolding.h"
#import "BoardMemberTransfer.h"
#import "StockHolderMeeting.h"
#import "InvesterHold.h"
#import "BoardHolding.h"
#import "CYQModel.h"
#import "InvesterBS.h"
#import "MarginTrading.h"
#import "TodayReserve.h"
#import "RelatedNewsData.h"
#import "NewsData.h"
#import "TrendEODActionModel.h"
#import "NewRevenue.h"
#import "FSFinanceReportUS.h"
#import "FutureModel.h"
#import "Option.h"
#import "FSEmergingObject.h"
#import "SpecialStateModel.h"
#import "VIPMessage.h"
#import "GoodStockModel.h"
#import "FSMainBargainingModel.h"
#import "FSBrokerBranchInfo.h"
#import "FSPowerSeriesObject.h"
#import "FSSignupModel.h"
#import "FSFastStockModel.h"
#import "Tech.h"
#import "FSNewsDataModel.h"
#import "FSDivergenceModel.h"
#import "PatternTipsModel.h"
#import "FigureSearchMyProfileModel.h"
#import "FSInfoPanelPageSetCenter.h"
#import "Warrant.h"
#import "FSFinanceModel.h"
#import "FSFinanceReportCN.h"

@class FSFonestock;

@interface FSDataModelProc : NSThread <FSThreadProtocol>

+ (id)sharedInstance;
+ (void)sendData:(NSObject *)data WithPacket:(NSObject <EncodeProtocol> *)body;
//+ (void)sendPacketWithData:(NSObject *)data;

@property (readonly, nonatomic) FSFonestock *fonestock;
@property (readonly, nonatomic) FSAccountManager *accountManager;
@property (readonly, nonatomic) FSLoginService *loginService;
@property (readonly, nonatomic) FSDatabaseAgent *mainDB;
@property (readonly, nonatomic) FigureSearchUS * figureSearchUS;
@property (readonly, nonatomic) SecuritySearchModel * securitySearchModel;
@property (readonly, nonatomic) FSCategoryTree *category;
@property (readonly, nonatomic) Portfolio * portfolioData;
@property (readonly, nonatomic) WatchLists * watchlists;
@property (readonly, nonatomic) SecurityNameData *securityName;
@property (readonly, nonatomic) MarketInfo * marketInfo;
@property (readonly, nonatomic) Indicator * indicator;
@property (readonly, nonatomic) BrokerInfo * brokerInfo;
@property (readonly, nonatomic) Brokers * brokers;
@property (readonly, nonatomic) FSBrokerBranchInfo * brokerBranchInfo;
@property (readonly, nonatomic) EsmData * esmData;
@property (readonly, nonatomic) EsmTraderInfo * esmTraderInfo;
@property (readonly, nonatomic) NewCompanyProfile * companyProfile;
@property (readonly, nonatomic) MajorProducts * majorProducts;
@property (readonly, nonatomic) MajorHolders * majorHolders;
@property (readonly, nonatomic) BoardMemberHolding * boardMemberHolding;
@property (readonly, nonatomic) BoardMemberTransfer * boardMemberTransfer;
@property (readonly, nonatomic) StockHolderMeeting * stockHolderMeeting;
@property (readonly, nonatomic) InvesterHold * investerHold;
@property (readonly, nonatomic) BoardHolding * boardHolding;
@property (readonly, nonatomic) NewRevenue * nRevenue;
@property (readonly, nonatomic) HistoricalEPS * historicalEPS;
@property (readonly, nonatomic) BalanceSheet * balanceSheet;
@property (readonly, nonatomic) Income * income;
@property (readonly, nonatomic) CashFlow * cashFlow;
@property (readonly, nonatomic) FinancialRatio * financialRatio;
@property (readonly, nonatomic) TradeDistribute * tradeDistribute;
@property (readonly, nonatomic) PortfolioTick * portfolioTickBank;
@property (readonly, nonatomic) PortfolioTick * historicTickBank;
@property (readonly, nonatomic) OperationalIndicator * operationalIndicator;
@property (readonly, nonatomic) Alert * alert;
@property (readonly, nonatomic) FSPushNotificationCenter *pushNotificationCenter;
@property (readonly, nonatomic) EODTarget *eodTarget;
@property (readonly, nonatomic) EODActionModel * edoActionModel;
@property (readonly, nonatomic) FSIAPHelper *iapHelper;
@property (readonly, nonatomic) FSActionPlanModel *actionPlanModel;
@property (readonly, nonatomic) FSInvestedModel *investedModel;
@property (readonly, nonatomic) FSPositionModel *positionModel;
@property (readonly, nonatomic) CYQModel *cyqModel;
@property (readonly, nonatomic) InvesterBS *investerBS;
@property (readonly, nonatomic) MarginTrading *marginTrading;
@property (readonly, nonatomic) TodayReserve *todayReserve;
@property (readonly, nonatomic) RelatedNewsData *relatedNewsData;
@property (readonly, nonatomic) NewsData *newsData;
@property (readonly, nonatomic) FSFinanceReportUS *financeReportUS;
@property (readonly, nonatomic) FSFinanceReportCN *financeReportCN;

@property (readonly, nonatomic) FutureModel * futureModel;
@property (readonly, nonatomic) Option * option;
@property (readonly, nonatomic) FSEmergingObject *emergingObj;
@property (readonly, nonatomic) FSMainBargaining *mainBargaining;
@property (readonly, nonatomic) Tech *tech;
@property (readonly, nonatomic) FSNewsDataModel *newsDataModel;
@property (readonly, nonatomic) Warrant *warrant;

@property (readonly, nonatomic) SpecialStateModel * specialStateModel;
@property (readonly, nonatomic) VIPMessage * vipMessage;
@property (readonly, nonatomic) GoodStockModel * goodStockModel;
@property (readonly, nonatomic) FSFastStockModel *fastStockModel;


@property (readonly, nonatomic) TrendEODActionModel *trendEODModel;
@property (readonly, nonatomic) NSThread *thread;
@property (strong, nonatomic) FSSocketProc *mainSocket;
@property (readonly, nonatomic) FSPowerSeriesObject *powerSeriesObject;
@property (nonatomic) FSSignupModel *signupModel;
@property (readonly, nonatomic) FSDivergenceModel *divergenceModel;
@property (readonly, nonatomic) PatternTipsModel *patternTipsModel;
@property (readonly, nonatomic) FigureSearchMyProfileModel *figureSearchModel;
@property (strong, nonatomic) FSInfoPanelPageSetCenter *infoPanelCenter;

@property (readonly, nonatomic) FSFinanceModel *financeModel;

@property (nonatomic) BOOL isRejectReLogin;
@end
