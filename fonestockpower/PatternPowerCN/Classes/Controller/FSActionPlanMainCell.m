//
//  FSActionPlanMainCell.m
//  FonestockPower
//
//  Created by Derek on 2014/5/22.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionPlanMainCell.h"

@implementation FSActionPlanMainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeFirstResponder)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeKeyBoardStatus)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        if ([reuseIdentifier isEqualToString:@"Long"]) {
            _strBuyBtn = [[FSUIButton alloc] init];
            _strSellBtn = [[FSUIButton alloc] init];
            
        }else{
            _strBuyBtn = [[FSUIButton alloc] init];
            _strSellBtn = [[FSUIButton alloc] init];
        }
        
        _targetText = [[UITextField alloc] initWithFrame:CGRectMake(0, 2, 76, 38)];
        _targetText.borderStyle = UITextBorderStyleRoundedRect;
        _targetText.keyboardType = UIKeyboardTypeDecimalPad;
        _targetText.textAlignment = NSTextAlignmentCenter;
        _targetText.delegate = self;
        _targetText.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_targetText];
        
        _strBuyBtn.frame = CGRectMake(96, 2, 38, 38);
        _strBuyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_strBuyBtn addTarget:self action:@selector(actionSheet:) forControlEvents:UIControlEventTouchUpInside];
        _strBuyBtn.tag = 600;
        [self.contentView addSubview:_strBuyBtn];
        
        _buyLabel = [[UILabel alloc] initWithFrame:CGRectMake(154, 0, 78, 44)];
        _buyLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_buyLabel];
        
        _costLabel = [[UILabel alloc] initWithFrame:CGRectMake(228, 0, 78, 44)];
        _costLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_costLabel];
            
        _lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(306, 4, 78, 35)];
        _lastLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_lastLabel];
            
        _spText = [[UITextField alloc] initWithFrame:CGRectMake(384, 4, 76, 35)];
        _spText.borderStyle = UITextBorderStyleRoundedRect;
        _spText.keyboardType = UIKeyboardTypeDecimalPad;
        _spText.textAlignment = NSTextAlignmentCenter;
        _spText.textColor = [UIColor blueColor];
        _spText.delegate = self;
        _spText.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_spText];
            
        _slText = [[UITextField alloc] initWithFrame:CGRectMake(464, 4, 76, 35)];
        _slText.borderStyle = UITextBorderStyleRoundedRect;
        _slText.keyboardType = UIKeyboardTypeDecimalPad;
        _slText.textAlignment = NSTextAlignmentCenter;
        _slText.textColor = [UIColor blueColor];
        _slText.delegate = self;
        _slText.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_slText];
            
        _strSellBtn.frame = CGRectMake(558, 2, 38, 38);
        _strSellBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_strSellBtn addTarget:self action:@selector(actionSheet:) forControlEvents:UIControlEventTouchUpInside];
        _strSellBtn.tag = 601;
        [self.contentView addSubview:_strSellBtn];
            
        _refLabel = [[UILabel alloc] initWithFrame:CGRectMake(616, 0, 78, 44)];
        _refLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_refLabel];
            
        _remove = [[UILabel alloc] initWithFrame:CGRectMake(704, 0, 44, 44)];
        _remove.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"RedDeleteButton"]];
        _remove.userInteractionEnabled = YES;
        [self.contentView addSubview:_remove];
        
        //Textfield keyboard
        //Target
        targerCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 30)];
        targerCustomView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];\
        
        targetTipLabel = [[UILabel alloc] init];
        targetTipLabel.textColor = [UIColor redColor];
        targetTipLabel.backgroundColor = [UIColor whiteColor];
        targetTipLabel.text = NSLocalizedStringFromTable(@"Enter your target price", @"ActionPlan", nil);
        [targerCustomView addSubview:targetTipLabel];

        _targetText.inputAccessoryView = targerCustomView;
        _targetInputText = [[UITextField alloc] init];
        _targetInputText.borderStyle = UITextBorderStyleRoundedRect;
        _targetInputText.keyboardType = UIKeyboardTypeDecimalPad;
        [targerCustomView addSubview:_targetInputText];
        
        targetDoneButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
        [targetDoneButton setTitle:NSLocalizedStringFromTable(@"Done", @"ActionPlan", nil) forState:UIControlStateNormal];
        [targetDoneButton addTarget:self action:@selector(hideTargetKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [targerCustomView addSubview:targetDoneButton];
        
        targetCancelButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
        [targetCancelButton setTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) forState:UIControlStateNormal];
        [targetCancelButton addTarget:self action:@selector(cancelTargetKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [targerCustomView addSubview:targetCancelButton];
        
        //S@P
        spCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 30)];
        spCustomView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        _spText.inputAccessoryView = spCustomView;
        
        spTipLabel = [[UILabel alloc] init];
        spTipLabel.textColor = [UIColor redColor];
        spTipLabel.backgroundColor = [UIColor whiteColor];
        spTipLabel.text = NSLocalizedStringFromTable(@"Stop At Profit(%):", @"ActionPlan", nil);
        [spCustomView addSubview:spTipLabel];
        
        _spInputText = [[UITextField alloc] init];
        _spInputText.borderStyle = UITextBorderStyleRoundedRect;
        _spInputText.keyboardType = UIKeyboardTypeDecimalPad;
        [spCustomView addSubview:_spInputText];
        
        spDoneButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
        spDoneButton.backgroundColor = [UIColor whiteColor];
        [spDoneButton setTitle:NSLocalizedStringFromTable(@"Done", @"ActionPlan", nil) forState:UIControlStateNormal];
        [spDoneButton addTarget:self action:@selector(hideSPKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [spCustomView addSubview:spDoneButton];
        
        spCancelButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
        spCancelButton.backgroundColor = [UIColor whiteColor];
        [spCancelButton setTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) forState:UIControlStateNormal];
        [spCancelButton addTarget:self action:@selector(cancelTargetKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [spCustomView addSubview:spCancelButton];
        
        //S@L
        slCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 30)];
        slCustomView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        _slText.inputAccessoryView = slCustomView;
        
        slTipLabel = [[UILabel alloc] init];
        slTipLabel.textColor = [UIColor redColor];
        slTipLabel.backgroundColor = [UIColor whiteColor];
        slTipLabel.text = NSLocalizedStringFromTable(@"Stop At Loss(%):", @"ActionPlan", nil);
        [slCustomView addSubview:slTipLabel];
        
        _slInputText = [[UITextField alloc] init];
        _slInputText.borderStyle = UITextBorderStyleRoundedRect;
        _slInputText.keyboardType = UIKeyboardTypeDecimalPad;
        [slCustomView addSubview:_slInputText];
        
        slDoneButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
        slDoneButton.backgroundColor = [UIColor whiteColor];
        [slDoneButton setTitle:NSLocalizedStringFromTable(@"Done", @"ActionPlan", nil) forState:UIControlStateNormal];
        [slDoneButton addTarget:self action:@selector(hideSLKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [slCustomView addSubview:slDoneButton];
        
        slCancelButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
        slCancelButton.backgroundColor = [UIColor whiteColor];
        [slCancelButton setTitle:NSLocalizedStringFromTable(@"取消", @"ActionPlan", nil) forState:UIControlStateNormal];
        [slCancelButton addTarget:self action:@selector(cancelTargetKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [slCustomView addSubview:slCancelButton];
        
        
        UITapGestureRecognizer * targerCustomViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideTargetKeyboard:)];
        targerCustomView.userInteractionEnabled = YES;
        spCustomView.userInteractionEnabled = YES;
        slCustomView.userInteractionEnabled = YES;
        
        [targerCustomView addGestureRecognizer:targerCustomViewTap];
        
        UITapGestureRecognizer * spCustomViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideSPKeyboard:)];
        [spCustomView addGestureRecognizer:spCustomViewTap];

        
        UITapGestureRecognizer * slCustomViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideSLKeyboard:)];
        [slCustomView addGestureRecognizer:slCustomViewTap];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];
    _costLabel.text = nil;
    _lastLabel.text = nil;
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)hideTargetKeyboard:(id)sender{
    
    [_delegate returnCellWithTarget:self.tag TargetText:_targetInputText.text SPText:_spText SLText:_slText];
    _targetText.text = _targetInputText.text;
    [self becomeFirstResponder];
}

-(void)cancelTargetKeyboard:(id)sender{
    [self becomeFirstResponder];
}

-(void)hideSPKeyboard:(id)sender{
    
    [_delegate returnCellWithSP:self.tag Text:_spInputText.text];
    [self becomeFirstResponder];
}

-(void)hideSLKeyboard:(id)sender{
    
    [_delegate returnCellWithSL:self.tag Text:_slInputText.text];
    [self becomeFirstResponder];
}

-(void)changeFirstResponder
{
    [_delegate returnCell:self];
    [_delegate changeKeyBoardValue:YES];
    [_targetInputText becomeFirstResponder];
    [_spInputText becomeFirstResponder];
    [_slInputText becomeFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:_targetText]) {
       // _targetInputText.text = _targetText.text;
        _targetInputText.text = @"";
    }else if ([textField isEqual:_spText]){
        [_delegate returnCellWithSP:self.tag SPTextField:_spInputText];
    }else if ([textField isEqual:_slText]){
        [_delegate returnCellWithSL:self.tag SLTextField:_slInputText];
    }
    return YES;
}


-(void)changeKeyBoardStatus{
    [_delegate changeKeyBoardValue:NO];
}

#pragma mark - Action Sheet
-(void)actionSheet:(FSUIButton *)sender{
    if (_strBuyBtn == sender) {
        [_delegate returnCell:self.tag Sender:sender BtnTag:_strBuyBtn.tag];
    }else if (_strSellBtn == sender){
        [_delegate returnCell:self.tag Sender:sender BtnTag:_strSellBtn.tag];
    }
}


-(void)setWindowWidth:(float)width{
    [targerCustomView setFrame:CGRectMake(0, 0, width, 360)];
    [spCustomView setFrame:CGRectMake(0, 0, width, 360)];
    [slCustomView setFrame:CGRectMake(0, 0, width, 360)];
    
    [targetTipLabel setFrame:CGRectMake(0, 300, width, 30)];
    [_targetInputText setFrame:CGRectMake(1, 330, width - 140, 30)];
    [targetDoneButton setFrame:CGRectMake(width - 140, 330, 70, 30)];
    [targetCancelButton setFrame:CGRectMake(width - 70, 330, 70, 30)];
    
    [spTipLabel setFrame:CGRectMake(0, 300, width, 30)];
    [_spInputText setFrame:CGRectMake(1, 330, width - 140, 30)];
    [spDoneButton setFrame:CGRectMake(width - 140, 330, 70, 30)];
    [spCancelButton setFrame:CGRectMake(width - 70, 330, 70, 30)];

    
    [slTipLabel setFrame:CGRectMake(0, 300, width, 30)];
    [_slInputText setFrame:CGRectMake(1, 330, width - 140, 30)];
    [slDoneButton setFrame:CGRectMake(width - 140, 330, 70, 30)];
    [slCancelButton setFrame:CGRectMake(width - 70, 330, 70, 30)];

}

@end
