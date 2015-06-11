//
//  FSFastStockModel.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSFastStockModel : NSObject{
    id notifyObj;
}

-(void)fastStockModelCallBack:(NSMutableArray *)array;

-(void)setTarget:(id)obj;

@end

@interface BasicGoodStock : NSObject

@end
