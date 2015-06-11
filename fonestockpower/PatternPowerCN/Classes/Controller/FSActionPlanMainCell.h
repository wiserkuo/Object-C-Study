//
//  FSActionPlanMainCell.h
//  FonestockPower
//
//  Created by Derek on 2014/5/22.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigureSearchMyProfileModel.h"

@protocol FSActionPlanMainCellDelegate <NSObject>
@required

- (void)changeKeyBoardValue:(BOOL)value;
- (void)returnCellWithTarget:(NSInteger)indexRow TargetText:(NSString *)targetText SPText:(UITextField *)spText SLText:(UITextField *)slText;
- (void)returnCellWithSP:(NSInteger)indexRow Text:(NSString *)text;
- (void)returnCellWithSL:(NSInteger)indexRow Text:(NSString *)text;
- (void)returnCell:(NSInteger)indexRow Sender:(FSUIButton *)sender BtnTag:(NSInteger)btnTag;
- (void)returnCell:(UITableViewCell *)cell;
- (void)returnCellWithSP:(NSInteger)indexRow SPTextField:(UITextField *)SPTextField;
- (void)returnCellWithSL:(NSInteger)indexRow SLTextField:(UITextField *)SLTextField;

@optional
@end

@interface FSActionPlanMainCell : FSUITableViewCell <UITextFieldDelegate, UIActionSheetDelegate>{
    UIView *targerCustomView;
    FSUIButton *targetDoneButton;
    FSUIButton *targetCancelButton;
    UILabel *targetTipLabel;
    UIView *spCustomView;
    UILabel *spTipLabel;
    FSUIButton *spDoneButton;
    FSUIButton *spCancelButton;
    UIView *slCustomView;
    UILabel *slTipLabel;
    FSUIButton *slDoneButton;
    FSUIButton *slCancelButton;
}
@property (strong, nonatomic) UITextField *targetText;
@property (strong, nonatomic) FSUIButton *strBuyBtn;
@property (strong, nonatomic) UILabel *buyLabel;
@property (strong, nonatomic) UILabel *costLabel;
@property (strong, nonatomic) UILabel *lastLabel;
@property (strong, nonatomic) UILabel *refLabel;
@property (strong, nonatomic) UITextField *spText;
@property (strong, nonatomic) UITextField *slText;
@property (strong, nonatomic) FSUIButton *strSellBtn;
@property (strong, nonatomic) UILabel *remove;
@property (strong, nonatomic) UITextField *targetInputText;
@property (strong, nonatomic) UITextField *spInputText;
@property (strong, nonatomic) UITextField *slInputText;
@property (strong, nonatomic) UITextField *refInputText;
@property (strong, nonatomic) NSMutableArray *figureSearchArray;

@property (weak, nonatomic) id<FSActionPlanMainCellDelegate>delegate;

-(void)setWindowWidth:(float)width;
@end
