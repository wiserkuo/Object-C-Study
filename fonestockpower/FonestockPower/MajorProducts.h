//
//  MajorProducts.h
//  FonestockPower
//
//  Created by Kenny on 2014/8/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MajorProductsIn.h"

@protocol MajorProductsDelegate;

@interface MajorProducts : NSObject
-(void)sendAndRead;
-(void)MajorProductsDataCallBack:(MajorProductsIn *)data;

@property (nonatomic, weak) NSObject <MajorProductsDelegate> *delegate;
@end

@protocol  MajorProductsDelegate <NSObject>
-(void)notifyProductData:(id)target;
@end
