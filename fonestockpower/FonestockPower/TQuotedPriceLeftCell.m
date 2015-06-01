//
//  TQuotedPriceLeftCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/10.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TQuotedPriceLeftCell.h"
#import "TQuotedView.h"
@implementation TQuotedPriceLeftCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier CellWidth:(double)width Type:(int)type
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.textColor = [UIColor orangeColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
        
        TQuotedView *view = [[TQuotedView alloc] initWithFrame:CGRectMake(0, 0, width, 35) Type:type];
        [self addSubview:view];
        [view addSubview:_nameLabel];
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(view, _nameLabel);
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nameLabel]|" options:0 metrics:nil views:viewDictionary]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nameLabel]|" options:0 metrics:nil views:viewDictionary]];
    
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
