//
//  SnapshotIn.m
//  FonestockPower
//
//  Created by Connor on 14/4/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SnapshotIn.h"
#import "Commodity.h"

@implementation SnapshotIn

- (id)init
{
	if(self = [super init])
	{
		ssParam = [[SnapshotParam alloc] init];
	}
	return self;
}

- (void)decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	int offset = 0,tmpOffset=0;
	PriceFormatData tmpPrice;
	TAvalueFormatData tmpTA;
	double tmpVal;
	dataLength = *tmpPtr++;
	ssParam->snapshot->subType = *tmpPtr++;
    
	ssParam->security = commodity;
	
	if(ssParam->snapshot->subType == 1) // SnapShotFormat1
	{
		ssParam->snapshot->date = [CodingUtil getUInt16:tmpPtr];
		offset += 16;
		ssParam->snapshot->timeOfLastTick = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:12];
		offset += 12;
		if([CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:1])
		{
			ssParam->snapshot->statusOfEquity = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:3];
			offset +=3;
		}
		else
		{
			ssParam->snapshot->statusOfEquity = 0;
			offset++;
		}
		ssParam.snapshot->sequenceOfTick = [CodingUtil getTickSNValue:tmpPtr Offset:&offset];
		tmpOffset = offset;
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->referencePrice Offset:0];
		tmpOffset = offset;
        
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->ceilingPrice Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->floorPrice Offset:0];
		tmpOffset = offset;
        
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->openPrice Offset:0];
		tmpOffset = offset;
        
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->highestPrice Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->lowestPrice Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->currentPrice Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->bid Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->ask Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->volume Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->accumulatedVolume Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->preVolume Offset:0];
		tmpOffset = offset;
		
		ssParam->snapshot->commodityType = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:4];
		offset += 4;
		if(ssParam->snapshot->commodityType == kCommodityTypeMarketIndex)
		{
			IndexSnapshot *indexSnapshot = [[IndexSnapshot alloc] init];
			tmpOffset = offset;
            
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&indexSnapshot->bidRecordCount Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&indexSnapshot->askRecordCount Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&indexSnapshot->bidVolume Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&indexSnapshot->askVolume Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&indexSnapshot->dealVolume Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&indexSnapshot->dealRecordCount Offset:0];
			tmpOffset = offset;
			
			indexSnapshot->upSecurityNo = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
			offset+=16;
			indexSnapshot->downSecurityNo = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
			offset+=16;
			indexSnapshot->unchangedSecurityNo = [CodingUtil getUint16FromBuf:tmpPtr Offset:offset Bits:16];
            offset += 16;
            
			[ssParam.snapshot.commodityArray addObject:indexSnapshot];
			
		}
		else if(ssParam->snapshot->commodityType == kCommodityTypeFuture ||
			    ssParam->snapshot->commodityType == kCommodityTypeOption  )  //期貨跟選擇權
		{
			FutureOptionSnapshot *futureOptionSnapshot = [[FutureOptionSnapshot alloc] init];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&futureOptionSnapshot->termHigh Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&futureOptionSnapshot->termLow Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&futureOptionSnapshot->settlement Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&futureOptionSnapshot->openInterest Offset:0];
			tmpOffset = offset;
			
			tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&futureOptionSnapshot->preOpenInterest Offset:0];
			tmpOffset = offset;
            
			[ssParam.snapshot.commodityArray addObject:futureOptionSnapshot];
            
		}
		else if(ssParam->snapshot->commodityType == kCommodityTypeETF)
		{
            [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		}
		else if(ssParam->snapshot->commodityType == kCommodityTypeWarrant)
		{
			WarrantSnapshot *warrantSnapshot = [[WarrantSnapshot alloc] init];
			tmpOffset = offset;
            
			tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
			[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&warrantSnapshot->strikePrice Offset:0];
			tmpOffset = offset;
			[ssParam->snapshot.commodityArray addObject:warrantSnapshot];
		}
        
		
        /* warning code for 處置股票
         warning code
         
         8 bit
         處置股票代碼: 00 ＝ 正常、01 ＝ 注意、02 ＝處置、03 ＝ 注意及處置、04 ＝ 再次處置、05 ＝ 注意及再次處置、06 ＝ 彈性處置、07 ＝ 注意及彈性處置
         因為代碼後面的文字過於簡單, 不足以顯示實際交易所所做的處置
         建議client可以只顯示"此股票為處置股票, 下單時..." 固定文字就好, 不用個別顯示處置代碼的敘述.
         如因個別需要顯示代碼文字, 可以使用格式trading warning information 查詢.
         */
        ssParam->snapshot->tradeWarningCode = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:8];
		offset += 8;
		
		/*
		 delay_close
		 4 bit
		 延後收盤 0 or 1, 0 is NO, 1 is Yes
		 */
        ssParam->snapshot->delayClose = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:4];
		offset += 4;
		
		/*
		 trade_suspend
		 4 bit
		 暫停交易on/off　0 or 1, 0 is 現在是沒有暫停交易, 1 is 現在是暫停交易 ..
		 */
		
        ssParam->snapshot->tradeSuspend = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:4];
		offset += 4;
		
		
		/*
         trade_suspend_time
		 32	bit
		 暫停交易時間, 絕對時間 HH:MM:SS, 999999 代表目前沒有暫停交易時間. 顯示--.
		 */
        ssParam->snapshot->tradeSuspendTime = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
		offset += 32;
		
		
		/*
		 trade_resume_time
		 32	bit
		 恢復交易時間, 絕對時間 HH:MM:SS, 999999 如果有暫停交易時間, 代表時間尚未確認, 如果沒有暫停交易時間, 代表沒有恢復交易時間. 顯示--.
		 */
        ssParam->snapshot->tradeResumeTime = [CodingUtil getUint32FromBuf:tmpPtr Offset:offset Bits:32];
		offset += 32;
		
		/*
		 daily status code
		 8	bit
		 1st bit=1: 異常推介. 2nd bit=1: 特殊異常. 其他bit reserved 填0 (MSB)
		 */
        ssParam->snapshot->dailyStatusCode = [CodingUtil getUint8FromBuf:tmpPtr Offset:offset Bits:8];
		//offset += 8;
		
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        //neil
		if(ssParam->snapshot->commodityType == kCommodityTypeOption) {
			[dataModal.option performSelector:@selector(snapshotArrive:) onThread:dataModal.thread withObject:ssParam waitUntilDone:NO];
		}
//		else {
			[dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:ssParam waitUntilDone:NO];
//		}
	}
	else if(ssParam->snapshot->subType == 2)
	{
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->week52High Offset:0];
		tmpOffset = offset;
		
		tmpVal = [CodingUtil getPriceFormatValue:tmpPtr Offset:&offset TAstruct:&tmpPrice];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->week52Low Offset:0];
		tmpOffset = offset;
        
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		[dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:ssParam waitUntilDone:NO];
        
	}
	else if(ssParam->snapshot->subType == 3)
	{
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->eps Offset:0];
		tmpOffset = offset;
        
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->annualDividend Offset:0];
		tmpOffset = offset;
        
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->currentAsset Offset:0];
		tmpOffset = offset;
        
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->issuedShares Offset:0];
		tmpOffset = offset;
		
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		[dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:ssParam waitUntilDone:NO];
	}
	else if(ssParam->snapshot->subType == 4)
	{
		tmpVal = [CodingUtil getTAvalueFormatValue:tmpPtr Offset:&offset TAstruct:&tmpTA];
		[CodingUtil setBufferr:[CodingUtil getUint32FromBuf:tmpPtr Offset:tmpOffset Bits:(offset-tmpOffset)] Bits:(offset-tmpOffset) Buffer:&ssParam->snapshot->averageVolume Offset:0];
		tmpOffset = offset;
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		[dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:ssParam waitUntilDone:NO];
	}
	else if(ssParam->snapshot->subType == 5)
	{
		ssParam->snapshot->settlementDay = [CodingUtil getUInt16:tmpPtr];
		tmpPtr += 2;
		ssParam->snapshot->warrantParamArray = [[NSMutableArray alloc] init];
		UInt16 size = 0;
		UInt8 count = *tmpPtr++;
		for(int i=0 ; i<count ; i++)
		{
			WarrantParam *warrantParam = [[WarrantParam alloc] initWithBuff:tmpPtr ObjSize:&size Offset:&offset];
			tmpPtr += size;
			
			[ssParam->snapshot.warrantParamArray addObject:warrantParam];
		}
		FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
		[dataModal.portfolioTickBank performSelector:@selector(updateEquitySnapshot:) onThread:dataModal.thread withObject:ssParam waitUntilDone:NO];
	}
}

@end
