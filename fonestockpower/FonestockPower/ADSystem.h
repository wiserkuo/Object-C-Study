//
//  ADSystem.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/2/12.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADSystem : NSObject

-(void)getAdConnect;
-(NSMutableArray *)getLoaclAdPlist;
//-(void)adForShow;

@end

@interface NSData(MD5)

- (NSString *)MD5;

@end
