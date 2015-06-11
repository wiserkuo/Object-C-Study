//
//  FutureModel.h
//  WirtsLeg
//
//  Created by Neil on 13/9/30.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "portfolio.h"
#import "FutureViewController.h"

@class FMDatabaseQueue;

@protocol FutureDelegate
@required

@optional
- (void)notifyDataArrive;
- (void)SnapshotNnotifyDataArrive;

@end


@interface FutureModel : NSObject{
    PortfolioTick * tickBank;
    FutureViewController *groupNotifyObj;
    
}
@property (weak) NSObject<FutureDelegate> *notifyObj;

//@property (strong) NSMutableArray * priceArray;
@property (strong) NSMutableDictionary *singleVolumeDictionary;
@property (strong) FMDatabaseQueue * queue;

-(void)setTarget:(id)obj;
-(void)setGroupTarget:(id)obj;
-(void)updateSnapshotWithArray:(NSMutableArray *)array;
-(void)searchSnapshotWithArray:(NSMutableArray *)array;


@end
