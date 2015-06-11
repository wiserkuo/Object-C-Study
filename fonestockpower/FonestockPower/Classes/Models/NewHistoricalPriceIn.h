//
//  NewHistoricalPriceIn.h
//  Bullseye
//
//  Created by Connor on 13/9/6.
//
//

#import <Foundation/Foundation.h>
#import "DecodeProtocol.h"

@class HistoricalParm;

@interface NewHistoricalPriceIn : NSObject <DecodeProtocol>{
	HistoricalParm *historicalParm;
}

@property (nonatomic,strong) HistoricalParm *historicalParm;

@end