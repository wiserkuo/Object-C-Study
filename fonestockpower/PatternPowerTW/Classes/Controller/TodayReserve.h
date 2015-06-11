//
//  TodayReserve.h
//  Bullseye
//
//  Created by Connor on 13/9/6.
//
//

#import <Foundation/Foundation.h>

@interface TodayReserve : NSObject

+ (TodayReserve *)sharedInstance;
- (void)setHistoricTickVolume:(NSNumber *)volume;
- (NSString *)getInvestorProportion;
- (void)setTargetNotify:(id)callBackTarget;
@end
