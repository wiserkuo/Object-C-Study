//
//  EODTargetIn.h
//  FonestockPower
//
//  Created by Kenny on 2014/6/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EODTargetIn : NSObject{
@public
    UInt8 serialNumber;
    UInt8 patternCount;
    UInt8 *patternName;
    UInt8 reserved;
    UInt16 resultCount;
    NSMutableDictionary *longData;
    NSMutableDictionary *shortData;
}
@end

@interface TPNObject : NSObject{
@public
    NSString *name;
    int number;
    int count;
    NSData *imgData;
}

@end
