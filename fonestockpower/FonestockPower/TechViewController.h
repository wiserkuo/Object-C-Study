//
//  TechViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/12/8.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TechViewController : FSUIViewController
@property(nonatomic) double pinchValue;
@property(nonatomic, strong) UIEvent *event;
@property(nonatomic, strong) NSSet *touch;
@property(nonatomic, strong) NSDictionary *symbolDict;
-(void)notifyTechData:(NSMutableArray *)dataArray;
-(void)touchHandler:(int)lineNum touch:(UITouch*)touch yPoint:(double)ypoint selectNum:(int)selectNum;
-(void)hiddenHandler;
-(void)setPriceLabel;
-(void)setBRLabel;
-(void)setMLabel:(int)num;
-(void)setBLabel:(int)num;
-(id)initWithDict:(NSDictionary *)dict;
-(void)theTranportation:(BOOL)startOrEnd :(NSSet *)touch;
-(void)reDraw;
@end
