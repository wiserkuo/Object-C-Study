//
//  FSKPIConditionTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/12/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSKPIConditionTableViewCell.h"

@implementation FSKPIConditionTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _chooseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [self.contentView addSubview:_chooseImageView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, 90, 44)];
    _label.textColor = [UIColor blueColor];
    [self.contentView addSubview:_label];
    
    _lowScoreTextField = [[UITextField alloc] initWithFrame:CGRectMake(140, 7, 50, 30)];
    _lowScoreTextField.borderStyle = UITextBorderStyleRoundedRect;
    _lowScoreTextField.textAlignment = NSTextAlignmentCenter;
    _lowScoreTextField.delegate = self;
    _lowScoreTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_lowScoreTextField endEditing:YES];
    [self.contentView addSubview:_lowScoreTextField];
    
    _tildeLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 0, 15, 44)];
    _tildeLabel.textColor = [UIColor blueColor];
    _tildeLabel.text = @"~";
    [self.contentView addSubview:_tildeLabel];
    
    _highScoreTextField = [[UITextField alloc] initWithFrame:CGRectMake(210, 7, 50, 30)];
    _highScoreTextField.borderStyle = UITextBorderStyleRoundedRect;
    _highScoreTextField.textAlignment = NSTextAlignmentCenter;
    _highScoreTextField.delegate = self;
    _highScoreTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:_highScoreTextField];
    
    _detailBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeShortDetailYellow];
    _detailBtn.frame = CGRectMake(265, 7, 50, 30);
    [_detailBtn addTarget:self action:@selector(detailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_detailBtn];
    
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _label = nil;
    _chooseImageView = nil;
    _lowScoreTextField = nil;
    _highScoreTextField = nil;
    _detailBtn = nil;
    _tildeLabel = nil;
}

-(void)detailBtnClick:(FSUIButton *)sender{
    [_delegate returnDetailBtn:sender];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [_delegate returnTextFieldDidBeginEditing:textField];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:_lowScoreTextField]) {
        [_delegate returnLowScoreTextField:_lowScoreTextField];
    }else if ([textField isEqual:_highScoreTextField]){
        [_delegate returnHighScoreTextField:_highScoreTextField];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
