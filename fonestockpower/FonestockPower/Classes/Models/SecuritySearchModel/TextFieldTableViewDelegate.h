//
//  TextFieldTableViewDelegate.h
//  WirtsLeg
//
//  Created by Neil on 13/10/18.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextFieldTableViewCell;
@class settingIndicatorsTableViewCell;

@protocol TextFieldTableViewDelegate <NSObject>
@optional
-(void)cellTextChangeWithCell:(TextFieldTableViewCell *)cell  TextField:(UITextField *)text;
-(void)cellBeginEditWithCell:(TextFieldTableViewCell *)cell;
-(void)cellEdit:(TextFieldTableViewCell *)cell;

-(void)indicatorsCellTextChangeWithCell:(settingIndicatorsTableViewCell *)cell  TextField:(UITextField *)text;

-(void)indicatorsCellBeginEditWithCell:(settingIndicatorsTableViewCell *)cell;

@end
