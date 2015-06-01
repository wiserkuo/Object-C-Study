//
//  CompanyProfilePage1WideStyleCell.m
//  WirtsLeg
//
//  Created by Connor on 14/1/2.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "CompanyProfilePage1WideStyleCell.h"

@implementation CompanyProfilePage1WideStyleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.font = font;
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.detailLabel.numberOfLines = 0;
        [self.contentView addSubview:self.detailLabel];
        [self processLayout];
        
    }
    return self;
}

#pragma mark -
#pragma mark Layout處理

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_detailLabel);
    
    NSDictionary *metrics = @{@"CELL_CONTENT_MARGIN":@CELL_CONTENT_MARGIN};
    
    // detailLabel
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-CELL_CONTENT_MARGIN-[_detailLabel]-CELL_CONTENT_MARGIN-|" options:0 metrics:metrics views:viewControllers]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_detailLabel]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark -
#pragma mark 資料欄位reset

- (void)prepareForReuse {
	[super prepareForReuse];
    self.detailLabel.text = nil;
}

@end
