//
//  testViewController.h
//  FonestockPower
//
//  Created by Neil on 14/6/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetWorthViewController : FSUIViewController
@property (strong, nonatomic) NSString *termStr;
@property (strong, nonatomic) NSString *dealStr;

-(void)setBeginDay:(NSDate*)beginDay;

- (void)doTouchesWithPoint:(CGPoint)point Date:(NSString *)date Value:(float)value;
- (void)doTouchesAndMoveWithPoint:(CGPoint)point Date:(NSString *)date Value:(float)value;
-(void)dataCallBack:(NSMutableArray*)dataArray;
@end

@interface NetWorthData : NSObject{
@public
	NSDate * date;
	double totalValue;
    double dailyValue;
}

@end