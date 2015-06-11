//
//  FSActionAlertMainTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/10/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSActionAlertMainCellDelegate <NSObject>
@required
-(void)returncellWithPattern:(NSInteger)indexRow sender:(UIButton *)sender;
-(void)returnTargetTextField:(UITextField *)targetTextField;
-(void)returnSPTextField:(UITextField *)SPTextField;
-(void)returnSLTextField:(UITextField *)SLTextField;

@optional

@end

@interface FSActionAlertMainTableViewCell : FSUITableViewCell <UITextFieldDelegate>
@property (strong, nonatomic) UIButton *patternBtn;
@property (strong, nonatomic) UITextField *targetTextField;
@property (strong, nonatomic) UITextField *spTextField;
@property (strong, nonatomic) UITextField *slTextField;
@property (strong, nonatomic) UIButton *removeBtn;

@property (strong, nonatomic) UIView *patternView;
@property (strong, nonatomic) UILabel *patternLabel;

@property (weak, nonatomic) id<FSActionAlertMainCellDelegate>delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
