//
//  settingIndicatorsTableViewCell.h
//  WirtsLeg
//
//  Created by Neil on 13/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldTableViewDelegate.h"

@protocol FSSettingIndicatorsTableViewCellDelegate <NSObject>
@required
-(void)textFieldBeClicked:(UITextField *)targetTextField cellTag:(NSInteger)cellTag textFieldTag:(NSInteger)textFieldTag;
@end

@interface settingIndicatorsTableViewCell : FSUITableViewCell <UITextFieldDelegate>

@property (strong ,nonatomic) id<TextFieldTableViewDelegate> delegate;
@property (weak, nonatomic) id<FSSettingIndicatorsTableViewCellDelegate> delegateForClicked;
@property (strong, nonatomic) NSMutableArray *textFields;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UITextField *dayTextField;
@property (strong, nonatomic) UITextField *weekTextField;
@property (strong, nonatomic) UITextField *monthTextField;
@property (strong, nonatomic) UITextField *minuteTextField;

@property (nonatomic) int beforeValue;
@end
