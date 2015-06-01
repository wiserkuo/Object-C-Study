//
//  CompanyProfilePage5Cell.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage5Cell.h"

@implementation CompanyProfilePage5Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIFont * font1 = [UIFont boldSystemFontOfSize:18.0f];
        
        self.directorLabel = [[UILabel alloc] init];
        self.directorLabel.numberOfLines = 0;
        self.directorLabel.font = font1;
        [self.directorLabel setTextColor:[UIColor blueColor]];
        self.directorLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_directorLabel];
        
        UIFont * font2 = [UIFont boldSystemFontOfSize:16.0f];
        UIFont * font3 = [UIFont boldSystemFontOfSize:14.0f];
        
        self.applyShareLabel = [[UILabel alloc] init];
        self.applyShareLabel.numberOfLines = 0;
        self.applyShareLabel.font = font2;
        self.applyShareLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_applyShareLabel];
        
        self.sheetLabel = [[UILabel alloc] init];
        self.sheetLabel.numberOfLines = 0;
        self.sheetLabel.font = font3;
        [self.sheetLabel setTextColor:[UIColor redColor]];
        self.sheetLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_sheetLabel];
        
        self.orgShareLabel = [[UILabel alloc] init];
        self.orgShareLabel.numberOfLines = 0;
        self.orgShareLabel.font = font2;
        self.orgShareLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_orgShareLabel];
        
        self.beforeSheetLabel = [[UILabel alloc] init];
        self.beforeSheetLabel.numberOfLines = 0;
        self.beforeSheetLabel.font = font3;
        [self.beforeSheetLabel setTextColor:[UIColor redColor]];
        self.beforeSheetLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_beforeSheetLabel];
        
        self.applyPriceLabel = [[UILabel alloc] init];
        self.applyPriceLabel.numberOfLines = 0;
        self.applyPriceLabel.font = font2;
        self.applyPriceLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_applyPriceLabel];
        
        self.sheetPriceLabel = [[UILabel alloc] init];
        self.sheetPriceLabel.numberOfLines = 0;
        self.sheetPriceLabel.font = font3;
        [self.sheetPriceLabel setTextColor:[UIColor redColor]];
        self.sheetPriceLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_sheetPriceLabel];
        
        self.actualShareLabel = [[UILabel alloc] init];
        self.actualShareLabel.numberOfLines = 0;
        self.actualShareLabel.font = font2;
        self.actualShareLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_actualShareLabel];
        
        self.afterSheetLabel = [[UILabel alloc] init];
        self.afterSheetLabel.numberOfLines = 0;
        self.afterSheetLabel.font = font3;
        [self.afterSheetLabel setTextColor:[UIColor redColor]];
        self.afterSheetLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_afterSheetLabel];
        
        self.tradeLabel = [[UILabel alloc] init];
        self.tradeLabel.numberOfLines = 0;
        self.tradeLabel.font = font2;
        self.tradeLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_tradeLabel];
        
        self.letDateLabel = [[UILabel alloc] init];
        self.letDateLabel.numberOfLines = 0;
        self.letDateLabel.font = font2;
        self.letDateLabel.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_letDateLabel];
        
        
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
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_directorLabel, _sheetLabel, _beforeSheetLabel, _sheetPriceLabel, _afterSheetLabel, _tradeLabel, _letDateLabel, _applyShareLabel, _orgShareLabel, _applyPriceLabel, _actualShareLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_directorLabel]" options:0 metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_applyShareLabel][_sheetLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_orgShareLabel][_beforeSheetLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_applyPriceLabel][_sheetPriceLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_actualShareLabel][_afterSheetLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tradeLabel]" options:0 metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_letDateLabel]" options:0 metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_directorLabel][_sheetLabel][_sheetPriceLabel][_tradeLabel][_letDateLabel]-3-|" options:0 metrics:nil views:viewController]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-31-[_orgShareLabel][_actualShareLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewController]];
    
}

- (void)prepareForReuse {
	[super prepareForReuse];
    self.directorLabel.text = nil;
    self.sheetLabel.text = nil;
    self.beforeSheetLabel.text = nil;
    self.sheetPriceLabel.text = nil;
    self.afterSheetLabel.text = nil;
    self.tradeLabel.text = nil;
    self.letDateLabel.text = nil;
}

@end
