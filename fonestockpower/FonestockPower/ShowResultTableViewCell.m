//
//  ShowResultTableViewCell.m
//  DivergenceStock
//
//  Created by CooperLin on 2014/12/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ShowResultTableViewCell.h"

@interface ShowResultTableViewCell(){
    BOOL isMainTableViewBeCalled;
    UIView *vvv;
    UIImageView *blackLine;
}

@end

@implementation ShowResultTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)btnClick:(UIButton *)sender
{
    [_delegate cellBtnBeClicked:self.tag sender:sender];
}

-(instancetype)initWithCustomTableViewCell:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //button的給圖設定上，建議用setImage 而不要用setBackgroundImage
    //因為前者的圖片大小會維持圖狀，而後者則會隨著button 大小跟著變形
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        // 將cell分隔線設為完整, 不缺口
//        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
//            [self setLayoutMargins:UIEdgeInsetsZero];
//        }
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _leftView = [[UIView alloc] init];
        _leftView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_leftView];
        
        _mainLbl = [[UILabel alloc] init];
        _mainLbl.textColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:120.0/255.0 alpha:1];
        _mainLbl.translatesAutoresizingMaskIntoConstraints = NO;
        _mainLbl.textAlignment = NSTextAlignmentCenter;
        _mainLbl.adjustsFontSizeToFitWidth = YES;
        [_leftView addSubview:_mainLbl];
        _detailLbl = [[UILabel alloc] init];
        _detailLbl.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLbl.textAlignment = NSTextAlignmentCenter;
        _detailLbl.adjustsFontSizeToFitWidth = YES;
        [_leftView addSubview:_detailLbl];
        blackLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackLine"]];
        blackLine.translatesAutoresizingMaskIntoConstraints = NO;
        [_leftView addSubview:blackLine];
        
        _VolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _VolBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_VolBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_VolBtn setImage:[UIImage imageNamed:@"新的勾勾"] forState:UIControlStateNormal];
        [_VolBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _VolBtn.tag = 501;
        [self.contentView addSubview:_VolBtn];
        _KdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _KdBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_KdBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_KdBtn setImage:[UIImage imageNamed:@"新的勾勾"] forState:UIControlStateNormal];
        [_KdBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _KdBtn.tag = 502;
        [self.contentView addSubview:_KdBtn];
        _RsiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _RsiBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_RsiBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_RsiBtn setImage:[UIImage imageNamed:@"新的勾勾"] forState:UIControlStateNormal];
        [_RsiBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _RsiBtn.tag = 503;
        [self.contentView addSubview:_RsiBtn];
        _MacdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _MacdBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_MacdBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_MacdBtn setImage:[UIImage imageNamed:@"新的勾勾"] forState:UIControlStateNormal];
        [_MacdBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _MacdBtn.tag = 504;
        [self.contentView addSubview:_MacdBtn];
        _ObvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _ObvBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_ObvBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_ObvBtn setImage:[UIImage imageNamed:@"新的勾勾"] forState:UIControlStateNormal];
        [_ObvBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _ObvBtn.tag = 505;
        [self.contentView addSubview:_ObvBtn];
        
        [self.contentView setNeedsUpdateConstraints];
    }
    return self;
}

-(void)updateConstraints
{
    [super updateConstraints];
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_leftView, _mainLbl, _detailLbl, _VolBtn, _KdBtn, _MacdBtn, _RsiBtn, _ObvBtn, blackLine);
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftView(80)][_VolBtn][_KdBtn(_VolBtn)][_RsiBtn(_VolBtn)][_MacdBtn(_VolBtn)][_ObvBtn(_VolBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftView]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_VolBtn(_leftView)]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_KdBtn(_leftView)]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_RsiBtn(_leftView)]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_MacdBtn(_leftView)]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_ObvBtn(_leftView)]|" options:0 metrics:nil views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainLbl][_detailLbl(==_mainLbl)]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blackLine]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainLbl][blackLine(2)]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_detailLbl][blackLine(2)]|" options:0 metrics:nil views:allObj]];
    
    [super replaceCustomizeConstraints:constraints];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    //讓元件回復到沒有人設定值的狀態（並不是dealloc）
    [super prepareForReuse];
    _mainLbl.text = nil;
    _detailLbl.text = nil;
    _ObvBtn.hidden = YES;
    _KdBtn.hidden = YES;
    _RsiBtn.hidden = YES;
    _MacdBtn.hidden = YES;
    _ObvBtn.hidden = YES;
}


@end
