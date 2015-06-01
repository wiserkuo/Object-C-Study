//
//  GoodStockModel.h
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodStockModel : NSObject{
    id notifyObj;
}

-(void)searchStockWithArray:(NSArray *)array update:(NSNumber *)up;
-(void)setTarget:(id)obj;
@end
