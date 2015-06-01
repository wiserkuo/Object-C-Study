//
//  FSSnapshotQueryOut.h
//  FonestockPower
//
//  Created by Connor on 14/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSnapshotQueryOut : NSObject <EncodeProtocol>
- (instancetype)initWithSnapshotTypes:(NSArray *)snapshotTypes identCodeSymbols:(NSArray *)identCodeSymbols;

@end
