//
//  CompanyProfilePage2BottomCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage2BottomCell.h"

@implementation CompanyProfilePage2BottomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
        
        self.shareHoldersDateLabel = [[UILabel alloc] init];
        _shareHoldersDateLabel.numberOfLines = 0;
        [_shareHoldersDateLabel setTextColor:[UIColor blueColor]];
        _shareHoldersDateLabel.font = font;
        _shareHoldersDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_shareHoldersDateLabel];
        
        self.shareHoldersRateLabel = [[UILabel alloc] init];
        _shareHoldersRateLabel.numberOfLines = 0;
        _shareHoldersRateLabel.font = font;
        _shareHoldersRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_shareHoldersRateLabel];
        
        self.changeRateLabel = [[UILabel alloc] init];
        _changeRateLabel.numberOfLines = 0;
        _changeRateLabel.font = font;
        _changeRateLabel.textAlignment = NSTextAlignmentRight;
        _changeRateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_changeRateLabel];
        
        
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
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_shareHoldersDateLabel, _shareHoldersRateLabel, _changeRateLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shareHoldersDateLabel][_shareHoldersRateLabel(==_shareHoldersDateLabel)][_changeRateLabel(==_shareHoldersDateLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_shareHoldersDateLabel]|" options:0 metrics:nil views:viewController]];
}

- (void)prepareForReuse {
	[super prepareForReuse];
    self.shareHoldersDateLabel.text = nil;
    self.shareHoldersRateLabel.text = nil;
    self.changeRateLabel.text = nil;
}

@end
