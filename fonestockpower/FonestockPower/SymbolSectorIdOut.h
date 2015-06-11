//
//  SymbolSectorIdOut.h
//  FonestockPower
//
//  Created by Neil on 2014/10/28.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SymbolSectorIdOut : NSObject<EncodeProtocol>{
    NSString * identCode;
    NSString * Symbol;
}
- (id)initWithIdentCode:(NSString *)ids Symbol:(NSString *)symbol;

@end
