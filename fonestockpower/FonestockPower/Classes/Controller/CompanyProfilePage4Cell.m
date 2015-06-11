//
//  CompanyProfilePage4Cell.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage4Cell.h"

@implementation CompanyProfilePage4Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIFont * font1 = [UIFont boldSystemFontOfSize:18.0f];
        
        self.shareholderLabel = [[UILabel alloc] init];
        self.shareholderLabel.numberOfLines = 0;
        self.shareholderLabel.font = font1;
        [self.shareholderLabel setTextColor:[UIColor blueColor]];
        self.shareholderLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_shareholderLabel];
        
        UIFont * font2 = [UIFont boldSystemFontOfSize:15.0f];
        
        self.shareholderDetailLabel = [[UILabel alloc] init];
        self.shareholderDetailLabel.numberOfLines = 0;
        self.shareholderDetailLabel.font = font2;
        self.shareholderDetailLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_shareholderDetailLabel];
        
        UIFont * font3 = [UIFont boldSystemFontOfSize:15.0f];
        
        self.holdLabel = [[UILabel alloc] init];
        self.holdLabel.numberOfLines = 0;
        self.holdLabel.font = font3;
        [self.holdLabel setTextColor:[UIColor redColor]];
        self.holdLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_holdLabel];
        
        self.holdingLabel = [[UILabel alloc] init];
        self.holdingLabel.numberOfLines = 0;
        self.holdingLabel.font = font3;
        self.holdingLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_holdingLabel];
        
        self.holdRateLabel = [[UILabel alloc] init];
        self.holdRateLabel.numberOfLines = 0;
        self.holdRateLabel.font = font3;
        [self.holdRateLabel setTextColor:[UIColor redColor]];
        self.holdRateLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_holdRateLabel];
        
        [self processLayout];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_shareholderLabel, _shareholderDetailLabel, _holdLabel, _holdingLabel, _holdRateLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shareholderLabel][_holdingLabel][_holdLabel(70)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shareholderDetailLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_shareholderLabel][_shareholderDetailLabel]-3-|" options:0 metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_holdLabel][_holdRateLabel]-3-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewController]];
    
}

- (void)prepareForReuse {
	[super prepareForReuse];
    self.shareholderLabel.text = nil;
    self.shareholderDetailLabel.text = nil;
    self.holdLabel.text = nil;
    self.holdRateLabel.text = nil;
}

@end
