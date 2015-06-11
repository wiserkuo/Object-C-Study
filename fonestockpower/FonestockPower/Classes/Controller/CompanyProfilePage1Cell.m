//
//  CompanyProfilePage1Cell.m
//  WirtsLeg
//
//  Created by Connor on 13/11/12.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "CompanyProfilePage1Cell.h"
#import "MarqueeLabel.h"

@implementation CompanyProfilePage1Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
        
        UIFont *font = [UIFont boldSystemFontOfSize:16.0f];
        
        self.titleLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(0, 0, 130, 30) duration:6.0 andFadeLength:0.0f];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = font;
        
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
        
        [self.titleLabel addGestureRecognizer:tapRecognizer];
        
        self.titleLabel.userInteractionEnabled = YES;
        [self.titleLabel setLabelize:YES];
        self.titleLabel.marqueeType = 4;
        self.titleLabel.continuousMarqueeExtraBuffer = 30.0f;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:233.0f/255.0f blue:169.0f/255.0f alpha:1.0f];
        [self.contentView addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.backgroundColor = [UIColor whiteColor];
        self.detailLabel.font = font;
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.detailLabel.numberOfLines = 0;
        [self.contentView addSubview:self.detailLabel];
        [self processLayout];
        
    }
    return self;
}

- (void)labelTap:(UITapGestureRecognizer *)recognizer{
    [(MarqueeLabel *)recognizer.view setLabelize:NO];
}


#pragma mark -
#pragma mark Layout處理

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_titleLabel, _detailLabel);
    
    NSDictionary *metrics = @{@"titleLabelWidth":@CELL_TITLE_CONTENT_WIDTH};
    
    // detailLabel
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel(titleLabelWidth)][_detailLabel]|" options:0 metrics:metrics views:viewControllers]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|" options:0 metrics:nil views:viewControllers]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_detailLabel]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark -
#pragma mark 資料欄位reset

- (void)prepareForReuse {
	[super prepareForReuse];
    self.titleLabel.text = nil;
    self.detailLabel.text = nil;
}

@end
