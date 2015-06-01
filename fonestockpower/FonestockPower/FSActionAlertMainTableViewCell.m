//
//  FSActionAlertMainTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/10/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSActionAlertMainTableViewCell.h"

@implementation FSActionAlertMainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _patternView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
        [self.contentView addSubview:_patternView];
        
        _patternLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 54, 40)];
        _patternLabel.adjustsFontSizeToFitWidth = YES;
        _patternLabel.textAlignment = NSTextAlignmentCenter;
        _patternLabel.backgroundColor = [UIColor clearColor];
        [_patternView addSubview:_patternLabel];
        
        _patternBtn = [[UIButton alloc] init];
        _patternBtn.tag = 600;
        [_patternBtn addTarget:self action:@selector(patternBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_patternView addSubview:_patternBtn];
        
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
        
        _removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(405, 3, 40, 40)];
        [self.contentView addSubview:_removeBtn];
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
    _patternView.backgroundColor = [UIColor clearColor];
    _patternLabel.text = nil;
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
    }
    
    return YES;
}

#pragma mark - Button Action
-(void)patternBtnAction:(UIButton *)sender{
    [_delegate returncellWithPattern:self.tag sender:sender];
}

@end
