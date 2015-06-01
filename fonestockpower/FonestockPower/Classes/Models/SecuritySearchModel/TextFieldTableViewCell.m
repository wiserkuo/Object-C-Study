//
//  TextFieldTableViewCell.m
//  WirtsLeg
//
//  Created by Neil on 13/10/18.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

@synthesize textFields;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.label  =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 77, 44)];
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
        
        self.textFields = [[NSMutableArray alloc] init];
        
        
        self.profitTextField = [[UITextField alloc] initWithFrame:CGRectMake( 82, 4, 80, 35)];
        _profitTextField.delegate = self;
        _profitTextField.tag = 0;
        _profitTextField.textAlignment=NSTextAlignmentRight;
        _profitTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _profitTextField.borderStyle = UITextBorderStyleRoundedRect;
        _profitTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.textFields addObject:_profitTextField];
        [self.contentView addSubview:_profitTextField];
        
        self.lostTextField = [[UITextField alloc] initWithFrame:CGRectMake(164, 4, 80, 35)];
        _lostTextField.delegate = self;
        _lostTextField.tag = 1;
        _lostTextField.textAlignment=NSTextAlignmentRight;
        _lostTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        _lostTextField.borderStyle = UITextBorderStyleRoundedRect;
        _lostTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [self.textFields addObject:_lostTextField];
        [self.contentView addSubview:_lostTextField];
        
        
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
    for (UITextField *textField in textFields) {
        textField.text = nil;
    }
    _label.text = nil;
}

- (void)updateConstraints {
    [super updateConstraints];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [_delegate cellBeginEditWithCell:self];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (![textField.text isEqualToString:@""]) {
        if (textField.tag == 0) {
            if(![_lostTextField.text isEqualToString:@""]){
                if ([textField.text floatValue]<=[_lostTextField.text floatValue]) {
                    textField.text  = [NSString stringWithFormat:@"%.3f",[_lostTextField.text floatValue]+1];
                }
            }
        }else{
            if(![_profitTextField.text isEqualToString:@""]){
                if ([textField.text floatValue]>=[_profitTextField.text floatValue]) {
                    textField.text  = [NSString stringWithFormat:@"%.3f",[_profitTextField.text floatValue]-1];
                }
            }
        }
    }
    
    
    [_delegate cellTextChangeWithCell:self TextField:textField];
}


@end
