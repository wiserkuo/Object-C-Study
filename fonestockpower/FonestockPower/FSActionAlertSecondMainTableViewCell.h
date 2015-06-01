//
//  FSActionAlertSecondMainTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/10/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSActionAlertSecondMainCellDelegate <NSObject>
@required
-(void)returncellWithPattern:(NSInteger)indexRow sender:(UIButton *)sender;
-(void)returnTargetTextField:(UITextField *)targetTextField;
-(void)returnSPTextField:(UITextField *)SPTextField;
-(void)returnSLTextField:(UITextField *)SLTextField;
-(void)returnSP2TextField:(UITextField *)SP2TextField;
-(void)returnSL2TextField:(UITextField *)SL2TextField;

@optional

@end

@interface FSActionAlertSecondMainTableViewCell : FSUITableViewCell <UITextFieldDelegate>
@property (strong, nonatomic) UIButton *patternBtn;
@property (strong, nonatomic) UITextField *targetTextField;
@property (strong, nonatomic) UITextField *spTextField;
@property (strong, nonatomic) UITextField *slTextField;
//@property (strong, nonatomic) UIButton *removeBtn;

@property (strong, nonatomic) UIButton *pattern2Btn;
@property (strong, nonatomic) FSUIButton *costBtn;
@property (strong, nonatomic) UITextField *sp2TextField;
@property (strong, nonatomic) UITextField *sl2TextField;
@property (strong, nonatomic) UIView *pattern1View;
@property (strong, nonatomic) UIView *pattern2View;
@property (strong, nonatomic) UILabel *pattern1Label;
@property (strong, nonatomic) UILabel *pattern2Label;

@property (weak, nonatomic) id<FSActionAlertSecondMainCellDelegate>delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
