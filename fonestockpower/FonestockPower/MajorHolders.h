//
//  MajorHolders.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MajorHoldersIn.h"

@protocol MajorHoldersDelegate;

@interface MajorHolders : NSObject
-(void)sendAndRead;
-(void)MajorHoldersDataCallBack:(MajorHoldersIn *)data;

@property (nonatomic, weak) NSObject <MajorHoldersDelegate> *delegate;
@end

@protocol  MajorHoldersDelegate <NSObject>
-(void)notifyHoldersData:(id)target;
@end
