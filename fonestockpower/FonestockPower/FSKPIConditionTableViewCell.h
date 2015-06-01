//
//  FSKPIConditionTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/12/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FSKPIConditionCellDelegate <NSObject>
@required
-(void)returnDetailBtn:(FSUIButton *)detailBtn;
-(void)returnLowScoreTextField:(UITextField *)lowScoreTextField;
-(void)returnHighScoreTextField:(UITextField *)highScoreTextField;
-(void)returnTextFieldDidBeginEditing:(UITextField *)textField;

@optional
@end

@interface FSKPIConditionTableViewCell : UITableViewCell <UITextFieldDelegate>
@property (nonatomic) UIImageView *chooseImageView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UILabel *tildeLabel;
@property (strong, nonatomic) FSUIButton *detailBtn;
@property (strong, nonatomic) UITextField *lowScoreTextField;
@property (strong, nonatomic) UITextField *highScoreTextField;
@property (weak, nonatomic) id<FSKPIConditionCellDelegate>delegate;

@end
