//
//  EODTarget.h
//  FonestockPower
//
//  Created by Kenny on 2014/6/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EODTargetIn;



@protocol EODTargetDelegate;

@interface EODTarget : NSObject
{
    NSRecursiveLock *dataLock;
}
@property (strong, nonatomic) NSMutableDictionary *dataDict;

@property (weak, nonatomic) id <EODTargetDelegate> delegate;
- (void)callBackData:(NSMutableDictionary *)data;
@end

@protocol EODTargetDelegate <NSObject>
- (void)callBackResultDict:(NSDictionary*)array;
@end
