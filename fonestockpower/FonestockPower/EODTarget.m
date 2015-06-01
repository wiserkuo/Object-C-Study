//
//  EODTarget.m
//  FonestockPower
//
//  Created by Kenny on 2014/6/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODTarget.h"

@implementation EODTarget
- (id)init {
    if (self = [super init]) {
        dataLock = [[NSRecursiveLock alloc] init];
        self.dataDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)callBackData:(NSMutableDictionary *)data {
    [dataLock lock];
    
    self.dataDict = data;

    if ([self.delegate respondsToSelector:@selector(callBackResultDict:)]) {
        [self.delegate callBackResultDict:self.dataDict];
    }

    
    [dataLock unlock];
}
@end
