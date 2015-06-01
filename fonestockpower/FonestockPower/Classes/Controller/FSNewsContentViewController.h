//
//  FSNewsContentViewController.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/12.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSNewsContentViewController : FSUIViewController

-(instancetype)initWithNewsSN:(int)sn index:(int)idx array:(NSMutableArray *)newsDataArray;
-(instancetype)initWithNewsIndex:(int)idx array:(NSMutableArray *)newsDataArray net:(BOOL)netView name:(NSString *)navname;

@end
