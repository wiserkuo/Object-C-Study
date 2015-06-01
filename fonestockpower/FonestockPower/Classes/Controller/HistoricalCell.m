//
//  HistoricalCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/18.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "HistoricalCell.h"

@implementation HistoricalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.yearLabel = [[UILabel alloc] init];
        self.yearLabel.numberOfLines = 0;
        [self.yearLabel setTextColor:[UIColor blueColor]];
        self.yearLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_yearLabel];
        
        self.ernDivLabel = [[UILabel alloc] init];
        self.ernDivLabel.numberOfLines = 0;
        [self.ernDivLabel setTextColor:[UIColor blueColor]];
        self.ernDivLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_ernDivLabel];
        
        self.capDivLabel = [[UILabel alloc] init];
        self.capDivLabel.numberOfLines = 0;
        [self.capDivLabel setTextColor:[UIColor blueColor]];
        self.capDivLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_capDivLabel];
        
        self.cshDivLabel = [[UILabel alloc] init];
        self.cshDivLabel.numberOfLines = 0;
        [self.cshDivLabel setTextColor:[UIColor blueColor]];
        self.cshDivLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_cshDivLabel];
        
        self.epsLabel = [[UILabel alloc] init];
        self.epsLabel.numberOfLines = 0;
        [self.epsLabel setTextColor:[UIColor redColor]];
        self.epsLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_epsLabel];
        
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
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_yearLabel, _ernDivLabel, _capDivLabel, _cshDivLabel, _epsLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_yearLabel][_ernDivLabel(==_yearLabel)][_capDivLabel(==_yearLabel)][_cshDivLabel(==_yearLabel)][_epsLabel(==_yearLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_yearLabel]|" options:0 metrics:nil views:viewController]];
    
    
}

- (void)prepareForReuse {
	[super prepareForReuse];
    self.yearLabel.text = nil;
    self.ernDivLabel.text = nil;
    self.capDivLabel.text = nil;
    self.cshDivLabel.text = nil;
    self.epsLabel.text = nil;
}


@end
