//
//  FSKPIConditionDetailTableViewCell.m
//  FonestockPower
//
//  Created by Derek on 2014/12/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSKPIConditionDetailTableViewCell.h"

@implementation FSKPIConditionDetailTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    _chooseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 44, 44)];
    [self.contentView addSubview:_chooseImageView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, 200, 44)];
    _label.textColor = [UIColor blueColor];
    [self.contentView addSubview:_label];
    
    _lowScoreTextField = [[UITextField alloc] initWithFrame:CGRectMake(190, 42, 50, 30)];
    _lowScoreTextField.borderStyle = UITextBorderStyleRoundedRect;
    _lowScoreTextField.textAlignment = NSTextAlignmentCenter;
    _lowScoreTextField.delegate = self;
    _lowScoreTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:_lowScoreTextField];
    
    _tildeLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 37, 15, 44)];
    _tildeLabel.textColor = [UIColor blueColor];
    _tildeLabel.text = @"~";
    [self.contentView addSubview:_tildeLabel];
    
    _highScoreTextField = [[UITextField alloc] initWithFrame:CGRectMake(260, 42, 50, 30)];
    _highScoreTextField.borderStyle = UITextBorderStyleRoundedRect;
    _highScoreTextField.textAlignment = NSTextAlignmentCenter;
    _highScoreTextField.delegate = self;
    _highScoreTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.contentView addSubview:_highScoreTextField];
    
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _label = nil;
    _chooseImageView = nil;
    _lowScoreTextField = nil;
    _highScoreTextField = nil;
    _tildeLabel = nil;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:_lowScoreTextField]) {
        [_delegate returnLowScoreTextField:_lowScoreTextField row:self.tag];
    }else if ([textField isEqual:_highScoreTextField]){
        [_delegate returnHighScoreTextField:_highScoreTextField row:self.tag];
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
