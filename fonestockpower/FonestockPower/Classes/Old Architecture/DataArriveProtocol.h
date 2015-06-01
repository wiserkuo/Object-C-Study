//
//  DataArriveProtocol.h
//  Bullseye
//
//  Created by johaiyu on 2008/12/12.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TickDataSource.h"

@protocol DataArriveProtocol

- (void)notifyDataArrive:(NSObject <TickDataSourceProtocol> *)dataSource;

@end

@protocol HistoricDataArriveProtocol

- (void)notifyDataArrive:(NSObject <HistoricTickDataSourceProtocol> *)dataSource;

@end

@protocol DataNotifyProtocol

- (void)notifyData;

@end