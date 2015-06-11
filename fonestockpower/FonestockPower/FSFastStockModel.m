//
//  FSFastStockModel.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSFastStockModel.h"

@implementation FSFastStockModel

-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)fastStockModelCallBack:(NSMutableArray *)array{
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:array waitUntilDone:NO];
}
@end

@implementation BasicGoodStock

@end