//
//  FSActionAlertSecondMainTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/10/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionAlertSecondMainTableViewCell.h"

@implementation FSActionAlertSecondMainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _pattern1View = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        [self.contentView addSubview:_pattern1View];
        
        _pattern1Label = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 54, 40)];
        _pattern1Label.adjustsFontSizeToFitWidth = YES;
        _pattern1Label.textAlignment = NSTextAlignmentCenter;
        _pattern1Label.backgroundColor = [UIColor clearColor];
        [_pattern1View addSubview:_pattern1Label];
        
        _patternBtn = [[UIButton alloc] init];
        _patternBtn.tag = 600;
        [_patternBtn addTarget:self action:@selector(patternBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pattern1View addSubview:_patternBtn];
        
        _targetTextField = [[UITextField alloc] initWithFrame:CGRectMake(105, 5, 90, 40)];
        _targetTextField.borderStyle = UITextBorderStyleRoundedRect;
        _targetTextField.adjustsFontSizeToFitWidth = YES;
        _targetTextField.textAlignment = NSTextAlignmentCenter;
        _targetTextField.delegate = self;
        [self.contentView addSubview:_targetTextField];
        
        _spTextField = [[UITextField alloc] initWithFrame:CGRectMake(205, 5, 90, 40)];
        _spTextField.borderStyle = UITextBorderStyleRoundedRect;
        _spTextField.adjustsFontSizeToFitWidth = YES;
        _spTextField.textAlignment = NSTextAlignmentCenter;
        _spTextField.delegate = self;
        [self.contentView addSubview:_spTextField];
        
        _slTextField = [[UITextField alloc] initWithFrame:CGRectMake(305, 5, 90, 40)];
        _slTextField.borderStyle = UITextBorderStyleRoundedRect;
        _slTextField.adjustsFontSizeToFitWidth = YES;
        _slTextField.textAlignment = NSTextAlignmentCenter;
        _slTextField.delegate = self;
        [self.contentView addSubview:_slTextField];
        
        _costBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetail2Button];
        _costBtn.frame = CGRectMake(105, 55, 90, 40);
        [self.contentView addSubview:_costBtn];
        
        _pattern2View = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 100, 50)];
        [self.contentView addSubview:_pattern2View];
        
        _pattern2Label = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 54, 40)];
        _pattern2Label.adjustsFontSizeToFitWidth = YES;
        _pattern2Label.textAlignment = NSTextAlignmentCenter;
        _pattern2Label.backgroundColor = [UIColor clearColor];
        [_pattern2View addSubview:_pattern2Label];
        
        _pattern2Btn = [[UIButton alloc] init];
        _pattern2Btn.tag = 601;
        [_pattern2Btn addTarget:self action:@selector(patternBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_pattern2View addSubview:_pattern2Btn];
        
        _sp2TextField = [[UITextField alloc] initWithFrame:CGRectMake(205, 55, 90, 40)];
        _sp2TextField.borderStyle = UITextBorderStyleRoundedRect;
        _sp2TextField.adjustsFontSizeToFitWidth = YES;
        _sp2TextField.textAlignment = NSTextAlignmentCenter;
        _sp2TextField.delegate = self;
        [self.contentView addSubview:_sp2TextField];
        
        _sl2TextField = [[UITextField alloc] initWithFrame:CGRectMake(305, 55, 90, 40)];
        _sl2TextField.borderStyle = UITextBorderStyleRoundedRect;
        _sl2TextField.adjustsFontSizeToFitWidth = YES;
        _sl2TextField.textAlignment = NSTextAlignmentCenter;
        _sl2TextField.delegate = self;
        [self.contentView addSubview:_sl2TextField];
        
//        _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(405, 30, 40, 40)];
//        [self.contentView addSubview:_removeBtn];
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
    _pattern1View.backgroundColor = [UIColor clearColor];
    _pattern1Label.text = nil;
    _pattern2View.backgroundColor = [UIColor clearColor];
    _pattern2Label.text = nil;
}

#pragma mark - TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.tag = self.tag;
    if ([textField isEqual:_targetTextField]) {
        [_delegate returnTargetTextField:_targetTextField];
        return NO;
    }else if([textField isEqual:_spTextField]){
        [_delegate returnSPTextField:_spTextField];
        return NO;
    }else if ([textField isEqual:_slTextField]){
        [_delegate returnSLTextField:_slTextField];
        return NO;
    }else if ([textField isEqual:_sp2TextField]){
        [_delegate returnSP2TextField:_sp2TextField];
        return NO;
    }else if ([textField isEqual:_sl2TextField]){
        [_delegate returnSL2TextField:_sl2TextField];
        return NO;
    }
    
    return YES;
}

-(void)patternBtnAction:(UIButton *)sender{
    if (_patternBtn == sender) {
        [_delegate returncellWithPattern:self.tag sender:sender];
    }else if (_pattern2Btn == sender){
        [_delegate returncellWithPattern:self.tag sender:sender];
    }
}

@end
