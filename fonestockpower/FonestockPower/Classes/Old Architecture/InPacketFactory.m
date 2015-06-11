//
//  InPacketFactory.m
//  test4
//
//  Created by Yehsam on 2008/11/21.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InPacketFactory.h"

@implementation InPacketFactory

+ (id)createInPacketWithMessage:(int)message Command:(int)command
{
	NSObject *obj = nil;
	
    NSLog(@"InPacket - msg: %d / cmd: %d", message, command);
    
	if(message == 0)
	{
        if (command ==3)
            obj = [NSClassFromString(@"MessageType03") alloc];
        else if(command ==6)
            obj = [NSClassFromString(@"MessageType06") alloc];
        else if(command == 10)
			obj = [NSClassFromString(@"MessageType10") alloc];
        else if(command == 11)
			obj = [NSClassFromString(@"MessageType11") alloc];
        else if(command == 12)
			obj = [NSClassFromString(@"MessageType12") alloc];
        else if(command == 14)
            obj = [NSClassFromString(@"MessageType14") alloc];
        else if(command == 19)
			obj = [NSClassFromString(@"MessageType19") alloc];
        
    }else if(message == 1){
        if (command == 1)
            obj	= [NSClassFromString(@"TickDataIn") alloc];
        else if(command == 2)
            obj	= [NSClassFromString(@"SnapshotIn") alloc];
        else if(command == 3)
			obj = [NSClassFromString(@"BADataIn") alloc];
        else if (command == 4)
            obj = [NSClassFromString(@"SymbolSyncIn") alloc];
        else if (command == 6)
            obj = [NSClassFromString(@"FSSymbolKeywordIn") alloc];
        else if (command == 7)
            obj = [NSClassFromString(@"SymbolSectorIdIn") alloc];
        else if (command == 8)
            obj = [NSClassFromString(@"OptionSymbolSyncIn") alloc];
        else if (command == 10)
            obj = [NSClassFromString(@"FutrueOptionTargetPriceIn") alloc];
        else if(command == 11)
			obj = [NSClassFromString(@"TradeDistributeIn") alloc];
        else if(command == 15)
			obj = [NSClassFromString(@"NewSymbolKeywordIn") alloc];
        else if(command == 19)
			obj = [NSClassFromString(@"EsmPriceIn") alloc];
        else if(command == 21)
			obj = [NSClassFromString(@"AlertSnapshotIn") alloc];
        else if(command == 28)
			obj = [NSClassFromString(@"DiscreteTickIn") alloc];
    }

    else if (message == 2){
        if(command == 2)
			obj = [NSClassFromString(@"BalanceSheetIn") alloc];
		else if(command == 3)
			obj = [NSClassFromString(@"IncomeDataIn") alloc];
		else if(command == 4)
			obj = [NSClassFromString(@"FinanicalDataIn") alloc];
		else if(command == 5)
			obj = [NSClassFromString(@"CashFlowDataIn") alloc];
        else if (command == 6)
            obj = [NSClassFromString(@"InvesterBSIn") alloc];
        else if (command == 7)
            obj = [NSClassFromString(@"InvesterHoldIn") alloc];
		else if(command == 8)
			obj = [NSClassFromString(@"NewCompanyProfileIn") alloc];
        else if(command == 9)
            obj = [NSClassFromString(@"MajorHoldersIn") alloc];
        else if(command == 10 || command == 29)
			obj = [NSClassFromString(@"NewRevenueIn") alloc];
        else if(command == 11)
			obj = [NSClassFromString(@"HistoricalDividendIn") alloc];
        else if(command == 12)
			obj = [NSClassFromString(@"HistoricalEPSIn") alloc];
        else if (command == 13)
            obj = [NSClassFromString(@"MarginTradingIn") alloc];
        else if(command == 16)
            obj = [NSClassFromString(@"MajorProductsIn") alloc];
        else if(command == 20)
            obj = [NSClassFromString(@"BoardHoldingIn") alloc];
        else if (command == 22) {
            obj = [NSClassFromString(@"BrokersIn") alloc];
        }
        else if (command == 24) {
            obj = [NSClassFromString(@"BrokersByBrokerIn") alloc];
        }
        else if (command == 25) {
            obj = [NSClassFromString(@"BrokersByAnchorIn") alloc];
        }
        else if(command == 26)
			obj =[NSClassFromString(@"EsmTraderSyncIn") alloc];

        else if(command == 27){
            obj =[NSClassFromString(@"BoardMemberHoldingIn") alloc];
        }
        else if (command == 30)
            obj = [NSClassFromString(@"BrokersByStockIn") alloc];
        else if (command == 31)
            obj = [NSClassFromString(@"NewBrokersByBrokerIn") alloc];
        else if(command == 32)
            obj =[NSClassFromString(@"NewHistoricalPriceIn") alloc];
        else if(command == 34)
            obj = [NSClassFromString(@"BoardMemberTransferIn") alloc];
        else if(command == 37)
            obj = [NSClassFromString(@"TechIn")alloc];
    }
    else if (message == 3){
        if (command == 1) {
            obj = [NSClassFromString(@"FSNewsSnDataIn") alloc];
        }
        else if (command == 2) {
            obj = [NSClassFromString(@"FSNewsTitleDataIn") alloc];
        }
        else if (command == 3) {
            obj = [NSClassFromString(@"NewsContentIn") alloc];
        }
        else if (command == 4)
            obj = [NSClassFromString(@"NewsRelateIn") alloc];
    }
    else if (message == 4) {
        if (command == 2) {
            obj = [NSClassFromString(@"PortfolioIn") alloc];
        }else if (command == 4) {
            obj = [NSClassFromString(@"OptionPortfolioIn") alloc];
        }
        else if (command == 8) { //sector Table sync
			obj = [NSClassFromString(@"SectorTableIn") alloc];
        }
        else if (command == 10) {//MarketInfo
            obj = [NSClassFromString(@"MarketInfoIn") alloc];
        }
        else if (command == 18) {
            obj = [NSClassFromString(@"AlertINIIn") alloc];
        }
        else if (command == 19) {
            obj = [NSClassFromString(@"AlertINIIn") alloc];
        }
        
        else if (command == 24) {
            obj = [NSClassFromString(@"FSSetFocusIn") alloc];
        }
    }
    
    else if (message == 5){
        if (command == 1) {
            obj = [NSClassFromString(@"VIPDueDateIn") alloc];
        }
        else if (command == 2){
            obj = [NSClassFromString(@"VIPMessageQueryIn") alloc];
        }
        else if (command == 3){
            obj = [NSClassFromString(@"VIPSNQueryIn") alloc];
        }
    }
    else if (message == 6){
        if (command == 1) {
            obj = [NSClassFromString(@"FSKPIIn") alloc];
        }
    }
    
    else if (message == 8) {
        if (command == 2) {
            obj = [NSClassFromString(@"FSBAIn") alloc];
        }
        else if (command == 3) {
            obj = [NSClassFromString(@"FSTickIn") alloc];
        }else if (command == 4) {
            obj = [NSClassFromString(@"FSIndexIn") alloc];
        }else if (command == 28){
            obj = [NSClassFromString(@"FSJoinPacketIn") alloc];
        }
    }
    
    else if (message == 9){
        if (command == 1) {
            obj = [NSClassFromString(@"FSSnapshotQueryIn") alloc];
        } else if (command == 2) {
            obj = [NSClassFromString(@"FSBAQueryIn") alloc];
        } else if (command == 3) {
            obj = [NSClassFromString(@"FSTickQueryIn") alloc];
        } else if (command == 11) {
            obj = [NSClassFromString(@"FSDistributeIn") alloc];
        } else if (command == 13){
            //obj = [NSClassFromString(@"WarrantQueryIn") alloc];
            obj = [NSClassFromString(@"SpecialStateIn") alloc];
        }
        
    }
    
    else if (message == 10){
        
        // 陸股財報
        
        if (command == 2){
            // 資產負債表
            obj = [NSClassFromString(@"FSBalanceSheetCNIn") alloc];
        } else if (command == 3) {
            // 損益表
            obj = [NSClassFromString(@"FSIncomeStatementCNIn") alloc];
        } else if (command == 4){
            // 財務比率
            obj = [NSClassFromString(@"FSFinancialRatioCNIn") alloc];
        } else if (command == 5) {
            // 現金流量表
            obj = [NSClassFromString(@"FSCashFlowCNIn") alloc];
        }
        
        
        
        if (command == 8){
            obj = [NSClassFromString(@"TempCompanyProfileForCN") alloc];
        }
        if (command == 12) {
            obj = [NSClassFromString(@"FSBalanceSheetUSIn") alloc];
        }
        if (command == 13){
            obj = [NSClassFromString(@"FSIncomeStatementUSIn") alloc];
        }
        if (command == 14) {
            obj = [NSClassFromString(@"FSFinancialRatioUSIn") alloc];
        }
        if (command == 15) {
            obj = [NSClassFromString(@"FSCashFlowUSIn") alloc];
        }
        if (command == 21){
            obj = [NSClassFromString(@"StockHolderMeetingIn") alloc];
        }
        if (command == 32){
            obj = [NSClassFromString(@"StockRankIn") alloc];
        }
        if (command == 35 ) {
            obj = [NSClassFromString(@"FSBrokerBranchByStockIn") alloc];
        }
        if (command == 36 ) {
            obj = [NSClassFromString(@"FSBrokerBranchByAnchorIn") alloc];
        }
        if (command == 37 ) {
            obj = [NSClassFromString(@"FSBrokerBranchDetailByAnchorIn") alloc];
        }
        if (command == 38) {
            obj = [NSClassFromString(@"FSBrokerBranchByBrokerIn") alloc];
        }
        if (command == 39) {
            obj = [NSClassFromString(@"FSBrokerBranchIn") alloc];
        }
        if (command == 40) {
            obj = [NSClassFromString(@"WarrantHistoryIn") alloc];
        }
        if (command == 41) {
            obj = [NSClassFromString(@"WarrantBasicIn") alloc];
        }
        if (command == 42) {
            obj = [NSClassFromString(@"FSMainBargainingChipIn") alloc];
        }
        if (command == 43) {
            obj = [NSClassFromString(@"FSMainBranchKLineIn")alloc];
        }
        if (command == 44) {
            obj = [NSClassFromString(@"FSOptionalMainIn")alloc];
        }
        if (command == 45){
            obj = [NSClassFromString(@"PowerPPPIn") alloc];
        }
        if (command == 46){
            obj = [NSClassFromString(@"PowerTwoPIn") alloc];
        }
        
    }

    else if (message == 12){
        if (command == 1) {
            obj = [NSClassFromString(@"FGLoginIn") alloc];
        }
        else if (command == 2) {
            obj = [NSClassFromString(@"FSAuthLoginIn") alloc];
        }
        else if (command == 6) {
            obj = [NSClassFromString(@"KeepAliveIn") alloc];
        }
    }
    else if (message ==13){
        if(command == 1 || command == 2 || command == 3){
            obj = [NSClassFromString(@"EODTargetIn")alloc];
        }
    }
    

    // 圖示選股(扣點) @deprecate
    else if (message == 100) {
        // 美股圖示選股(扣點):msg_id=100,cmd_id=1
        // 陸股圖示選股(扣點):msg_id=100,cmd_id=2
        if (command == 1 ||
            command == 2) {
            obj = [NSClassFromString(@"FigureSearchUSIn") alloc]; // 圖示選股
        }
    }
    
    else if (message == 103){
        //背離力 : msg_id=103,cmd_id=1
        if(command == 1){
            obj = [NSClassFromString(@"ProtocolBufferIn") alloc];
        }
    }
    
    // 圖示選股(月租)
    else if (message == 150) {
        // 美股圖示選股(月租)盤後內建:msg_id=150,cmd_id=1
        // 美股圖示選股(月租)盤中內建:msg_id=150,cmd_id=2
        // 美股圖示選股(月租)盤後DIY:msg_id=150,cmd_id=3
        // 美股圖示選股(月租)盤中DIY:msg_id=150,cmd_id=4
        // 陸股圖示選股(月租)盤後內建:msg_id=150,cmd_id=5
        // 陸股圖示選股(月租)盤中內建:msg_id=150,cmd_id=6
        // 陸股圖示選股(月租)盤後DIY:msg_id=150,cmd_id=7
        // 陸股圖示選股(月租)盤中DIY:msg_id=150,cmd_id=8
        // 台股圖示選股(月租)盤後內建:msg_id=150,cmd_id=9
        // 台股圖示選股(月租)盤中內建:msg_id=150,cmd_id=10
        // 台股圖示選股(月租)盤後DIY:msg_id=150,cmd_id=11
        // 台股圖示選股(月租)盤中DIY:msg_id=150,cmd_id=12
        if (command == 1 ||
            command == 2 ||
            command == 3 ||
            command == 4 ||
            command == 5 ||
            command == 6 ||
            command == 7 ||
            command == 8 ||
            command == 9 ||
            command == 10 ||
            command == 11 ||
            command == 12) {
            obj = [NSClassFromString(@"FigureSearchUSIn") alloc]; // 圖示選股
        }
    }
    
    if (!obj) {
        obj = [NSClassFromString(@"Dummy") alloc]; // 目前不支援此電文, 用假的代替
    }
    
	return obj;
}
@end
