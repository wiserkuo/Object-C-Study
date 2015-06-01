//
//  FSBAQueryOut.h
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSBAQueryOut : NSObject <EncodeProtocol>
- (instancetype)initWithIdentCodeSymbols:(NSArray *)identCodeSymbols;
@end
