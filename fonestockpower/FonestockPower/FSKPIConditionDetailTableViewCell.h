//
//  FSKPIConditionDetailTableViewCell.h
//  FonestockPower
//
//  Created by Derek on 2014/12/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FSKPIConditionDetailCellDelegate <NSObject>
@required
-(void)returnLowScoreTextField:(UITextField *)lowScoreTextField row:(NSInteger)row;
-(void)returnHighScoreTextField:(UITextField *)highScoreTextField row:(NSInteger)row;

@optional
@end

@interface FSKPIConditionDetailTableViewCell : UITableViewCell<UITextFieldDelegate>
@property (nonatomic) UIImageView *chooseImageView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UILabel *tildeLabel;
@property (strong, nonatomic) UITextField *lowScoreTextField;
@property (strong, nonatomic) UITextField *highScoreTextField;
@property (weak, nonatomic) id<FSKPIConditionDetailCellDelegate>delegate;

@end
