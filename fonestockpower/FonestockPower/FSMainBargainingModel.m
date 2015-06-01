//
//  FSMainBargainingModel.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/11/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainBargainingModel.h"
#import "FSBrokerBranchOut.h"

@implementation FSMainBargaining

-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)mainBargainingChipCallBack:(NSMutableArray *)array{
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:array waitUntilDone:NO];
}
@end

@implementation FSMainBargainingChip
@end

@implementation FSBrokerBranchByStock
@end

@implementation FSBrokerBranchByAnchor
@end

@implementation FSBrokerBranchDetailByAnchor
@end

@implementation FSBrokerBranchByBroker
@end

@implementation FSMainBranchKLine
@end

@implementation FSMainBranchKLineNew
@end

@implementation FSBrokerOptional
@end

@implementation FSBrokerBranchByStockLeft
@end

@implementation FSBrokerBranchByStockRight
@end
