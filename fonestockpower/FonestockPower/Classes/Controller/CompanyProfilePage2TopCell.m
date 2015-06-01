//
//  CompanyProfilePage2TopCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage2TopCell.h"

@implementation CompanyProfilePage2TopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIFont * font = [UIFont boldSystemFontOfSize:18.0f];
        UIFont * font2 = [UIFont boldSystemFontOfSize:16.0f];
        self.legalLabel = [[UILabel alloc] init];
        self.legalLabel.numberOfLines = 0;
        self.legalLabel.font = font;
        [self.legalLabel setTextColor:[UIColor whiteColor]];
        self.legalLabel.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
        self.legalLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_legalLabel];
        
        self.foreignCapitalLabel = [[UILabel alloc] init];
        self.foreignCapitalLabel.numberOfLines = 0;
        [self.foreignCapitalLabel setTextColor:[UIColor whiteColor]];
        self.foreignCapitalLabel.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
        self.foreignCapitalLabel.font = font;
        self.foreignCapitalLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_foreignCapitalLabel];
        
        self.foreignCapitalPercent = [[UILabel alloc] init];
        self.foreignCapitalPercent.numberOfLines = 0;
        self.foreignCapitalPercent.font = font2;
        [self.foreignCapitalPercent setTextColor:[UIColor blueColor]];
        self.foreignCapitalPercent.backgroundColor = [UIColor whiteColor];
        self.foreignCapitalPercent.textAlignment = NSTextAlignmentCenter;
        self.foreignCapitalPercent.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_foreignCapitalPercent];
        
        self.investmentTrustLabel = [[UILabel alloc] init];
        self.investmentTrustLabel.numberOfLines = 0;
        [self.investmentTrustLabel setTextColor:[UIColor whiteColor]];
        self.investmentTrustLabel.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
        self.investmentTrustLabel.font = font;
        self.investmentTrustLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_investmentTrustLabel];
        
        self.investmentTrustPercent = [[UILabel alloc] init];
        self.investmentTrustPercent.numberOfLines = 0;
        self.investmentTrustPercent.font = font2;
        [self.investmentTrustPercent setTextColor:[UIColor blueColor]];
        self.investmentTrustPercent.backgroundColor = [UIColor whiteColor];
        self.investmentTrustPercent.textAlignment = NSTextAlignmentCenter;
        self.investmentTrustPercent.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_investmentTrustPercent];
        
        self.dealersLabel = [[UILabel alloc] init];
        self.dealersLabel.numberOfLines = 0;
        self.dealersLabel.font = font;
        self.dealersLabel.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
        [self.dealersLabel setTextColor:[UIColor whiteColor]];
        self.dealersLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_dealersLabel];
        
        self.dealersPercent = [[UILabel alloc] init];
        self.dealersPercent.numberOfLines = 0;
        self.dealersPercent.font = font2;
        [self.dealersPercent setTextColor:[UIColor blueColor]];
        self.dealersPercent.backgroundColor = [UIColor whiteColor];
        self.dealersPercent.textAlignment = NSTextAlignmentCenter;
        self.dealersPercent.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_dealersPercent];
        
        self.directorsLabel = [[UILabel alloc] init];
        self.directorsLabel.numberOfLines = 0;
        self.directorsLabel.font = font;
        self.directorsLabel.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
        [self.directorsLabel setTextColor:[UIColor whiteColor]];
        self.directorsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_directorsLabel];
        
        self.directorsPercent = [[UILabel alloc] init];
        self.directorsPercent.numberOfLines = 0;
        self.directorsPercent.font = font2;
        [self.directorsPercent setTextColor:[UIColor blueColor]];
        self.directorsPercent.backgroundColor = [UIColor whiteColor];
        self.directorsPercent.textAlignment = NSTextAlignmentCenter;
        self.directorsPercent.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_directorsPercent];
        
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
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_legalLabel, _foreignCapitalLabel, _foreignCapitalPercent, _investmentTrustLabel, _investmentTrustPercent, _dealersLabel, _dealersPercent, _directorsLabel, _directorsPercent);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_legalLabel]|" options:0 metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_foreignCapitalLabel][_foreignCapitalPercent(==_foreignCapitalLabel)][_investmentTrustLabel(==_foreignCapitalLabel)][_investmentTrustPercent(==_foreignCapitalLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dealersLabel][_dealersPercent(==_dealersLabel)][_directorsLabel(==_dealersLabel)][_directorsPercent(==_dealersLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_legalLabel(30)][_foreignCapitalLabel][_dealersLabel]-5-|" options:0 metrics:nil views:viewController]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_legalLabel(30)][_investmentTrustLabel][_directorsLabel]-5-|" options:0 metrics:nil views:viewController]];
}

- (void)prepareForReuse {
	[super prepareForReuse];
    self.legalLabel.text = nil;
    self.foreignCapitalLabel.text = nil;
    self.foreignCapitalPercent.text = nil;
    self.investmentTrustLabel.text = nil;
    self.investmentTrustPercent.text = nil;
    self.dealersLabel.text = nil;
    self.dealersLabel.text = nil;
    self.directorsLabel.text = nil;
    self.directorsPercent.text = nil;
}


@end
