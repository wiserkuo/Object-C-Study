//
//  FSThreadProtocol.h
//  FonestockPower
//
//  Created by Connor on 14/3/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSThreadProtocol <NSObject>
@required
- (void)waitUntilReady;
@end
