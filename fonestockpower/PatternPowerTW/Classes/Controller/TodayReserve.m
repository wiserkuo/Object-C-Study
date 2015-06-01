//
//  TodayReserve.m
//  Bullseye
//
//  Created by Connor on 13/9/6.
//
//

#import "TodayReserve.h"
#import "InvesterBSIn.h"
#import "TodayReserveViewController.h"

@interface TodayReserve()
@property (nonatomic, retain) id callBackTarget;
@property (nonatomic, unsafe_unretained) double volume;
@end

@implementation TodayReserve

- (id)init {
	if(self = [super init]) {
        _volume = -1;
	}
	return self;
}

+ (TodayReserve *)sharedInstance
{
    static TodayReserve *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TodayReserve alloc] init];
    });
    return sharedInstance;
}

- (void)setTargetNotify:(id)callBackTarget {
    _callBackTarget = callBackTarget;
    
    if (_callBackTarget == nil) {
        _volume = -1;
    }
}

- (void)setHistoricTickVolume:(NSNumber *)volume {
    
    _volume = [volume doubleValue];
    
//    if (_volume != -1 && _callBackTarget) {
        [_callBackTarget performSelectorOnMainThread:@selector(notifyVolume) withObject:nil waitUntilDone:NO];
//    }
    
}

- (NSString *)getInvestorProportion {
    
    // 沒有回傳數值時, 顯示 ----
    if (_volume == -1) {
        return @"----";
    }
    else {
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        
        InvesterBSData *BSData1, *BSData2, *BSData3;
        
        NSArray *tmpArray = [dataModel.investerBS getDataForTodayUse];
        if (tmpArray) {
            BSData1 = [tmpArray objectAtIndex:0];
            BSData2 = [tmpArray objectAtIndex:1];
            BSData3 = [tmpArray objectAtIndex:2];
        }
        
        double sum = 0;
        
        double sumBuyShares = (BSData1->buyShares * pow(1000, BSData1->buySharesUnit)) + (BSData2->buyShares * pow(1000, BSData2->buySharesUnit)) + (BSData3->buyShares * pow(1000, BSData3->buySharesUnit));
        
        double sumSellShares = (BSData1->sellShares * pow(1000, BSData1->sellSharesUnit)) + (BSData2->sellShares * pow(1000, BSData2->sellSharesUnit)) + (BSData3->sellShares * pow(1000, BSData3->sellSharesUnit));
        
        sum += sumBuyShares;
        sum += sumSellShares;
        
        sum /= 2;
        
        double proportion = sum / _volume * 100;
        return [NSString stringWithFormat:@"%.2f%%", proportion];
        
    }
}

@end
