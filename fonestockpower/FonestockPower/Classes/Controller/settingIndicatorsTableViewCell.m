//
//  settingIndicatorsTableViewCell.m
//  WirtsLeg
//
//  Created by Neil on 13/11/20.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "settingIndicatorsTableViewCell.h"

@implementation settingIndicatorsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel  =[[UILabel alloc]init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
        
        self.textFields = [[NSMutableArray alloc] init];
        
        
        self.dayTextField = [[UITextField alloc] init];
        _dayTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _dayTextField.delegate = self;
        _dayTextField.tag = 0;
        _dayTextField.textAlignment=NSTextAlignmentCenter;
        _dayTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _dayTextField.borderStyle = UITextBorderStyleRoundedRect;
        _dayTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.textFields addObject:_dayTextField];
        [self.contentView addSubview:_dayTextField];
        
        self.weekTextField = [[UITextField alloc] init];
        _weekTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _weekTextField.delegate = self;
        _weekTextField.tag = 1;
        _weekTextField.textAlignment=NSTextAlignmentCenter;
        _weekTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _weekTextField.borderStyle = UITextBorderStyleRoundedRect;
        _weekTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.textFields addObject:_weekTextField];
        [self.contentView addSubview:_weekTextField];
        
        self.monthTextField = [[UITextField alloc] init];
        _monthTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _monthTextField.delegate = self;
        _monthTextField.tag = 2;
        _monthTextField.textAlignment=NSTextAlignmentCenter;
        _monthTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _monthTextField.borderStyle = UITextBorderStyleRoundedRect;
        _monthTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.textFields addObject:_monthTextField];
        [self.contentView addSubview:_monthTextField];
        
        self.minuteTextField = [[UITextField alloc] init];
        _minuteTextField.translatesAutoresizingMaskIntoConstraints = NO;
        _minuteTextField.delegate = self;
        _minuteTextField.tag = 3;
        _minuteTextField.textAlignment=NSTextAlignmentCenter;
        _minuteTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _minuteTextField.borderStyle = UITextBorderStyleRoundedRect;
        _minuteTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.textFields addObject:_minuteTextField];
        [self.contentView addSubview:_minuteTextField];
        
        [self setLayout];
    }
    return self;
}

-(void)setLayout{
    NSDictionary * dic = NSDictionaryOfVariableBindings(_titleLabel,_dayTextField,_weekTextField,_monthTextField,_minuteTextField);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel(50)]" options:0 metrics:nil views:dic]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel(75)][_dayTextField]-5-[_weekTextField(==_dayTextField)]-5-[_monthTextField(==_dayTextField)]-5-[_minuteTextField(==_dayTextField)]-2-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:dic]];
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
    for (UITextField *textField in _textFields) {
        textField.text = nil;
    }
    _titleLabel.text = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([_delegateForClicked respondsToSelector:@selector(textFieldBeClicked:cellTag:textFieldTag:)]){
        [_delegateForClicked textFieldBeClicked:textField cellTag:self.tag textFieldTag:textField.tag];
        return NO;
    }
    return YES;
//需要參數 textField 還需要叫起一個UITextField 的delegate 的method
//NSInvocation 不知道會不會比較適合
//    if([_delegateForClicked respondsToSelector:@selector(textFieldShouldBeginEditing:)]){
//
//        NSMethodSignature *mySignature = [UITextField instanceMethodSignatureForSelector:@selector(textFieldShouldBeginEditing:)];
//        NSInvocation *myInvocation = [NSInvocation invocationWithMethodSignature:mySignature];
//        [myInvocation setTarget:_delegateForClicked];
//        [myInvocation setSelector:@selector(textFieldShouldBeginEditing:)];
//        [myInvocation setArgument:&targetTextField atIndex:2];
//        [myInvocation invoke];
//        
//    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _beforeValue = [textField.text intValue];
    [_delegate indicatorsCellBeginEditWithCell:self];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (!(_beforeValue == [textField.text intValue])) {
        [_delegate indicatorsCellTextChangeWithCell:self TextField:textField];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
