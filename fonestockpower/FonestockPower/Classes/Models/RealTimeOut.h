//
//  RealTimeOut.h
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"

@interface RealTimeOut : NSObject<EncodeProtocol>{
    int searchSize;
    int update;
    NSMutableArray * searchArray;
    NSMutableArray * sortingArray;
    NSMutableArray * sectorArray;
    
}

- (id)initWithSectorArray:(NSMutableArray *)secArray SearchArray:(NSMutableArray *)array SortingArray:(NSMutableArray *)sArray Size:(int)size Update:(int)update;

@end
