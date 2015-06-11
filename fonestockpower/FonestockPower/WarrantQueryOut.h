//
//  WarrantQueryOut.h
//  Bullseye
//
//  Created by Yehsam on 2009/6/11.
//  Copyright 2009 FoneStock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncodeProtocol.h"


@interface WarrantQueryOut : NSObject <EncodeProtocol>{
	NSString *identCodeSymbol;
    int functionID;
    int rankingType;
    int direction;
    int filltI;
}

- (id)initWithIdentCodeSymbol:(NSString *)symbol function:(int)num;
- (id)initWithFunction:(int)num rankingType:(int)rankingNum direction:(int)dir filltI:(int)type;
@end
