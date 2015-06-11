//
//  WarrantCollectionViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/9/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantCollectionViewCell.h"

@implementation WarrantCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initStockButton];
        [self updateConstraints];
    }
    return self;
}

-(void)initStockButton
{
    self.stockButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalGreen];
    self.stockButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.stockButton.userInteractionEnabled = NO;
    [self.contentView addSubview:_stockButton];
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_stockButton);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_stockButton]|" options:0 metrics:Nil views:viewDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stockButton]|" options:0 metrics:nil views:viewDictionary]];
}

@end
