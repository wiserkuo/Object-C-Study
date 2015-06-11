//
//  MacroeconomicDrawTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/7/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MacroeconomicDrawTableViewCell.h"

@implementation MacroeconomicDrawTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_dateLabel];
        
        self.valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_valueLabel];
        
        self.changeLabel = [[UILabel alloc] init];
        _changeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _changeLabel.textAlignment = NSTextAlignmentRight;
        [_changeLabel setTextColor:[UIColor redColor]];
        _changeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_changeLabel];
        
        self.changePrecentLabel = [[UILabel alloc] init];
        _changePrecentLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _changePrecentLabel.textAlignment = NSTextAlignmentRight;
        [_changePrecentLabel setTextColor:[UIColor redColor]];
        _changePrecentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_changePrecentLabel];
        
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
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_dateLabel, _valueLabel, _changeLabel, _changePrecentLabel );
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_dateLabel]|" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dateLabel(70)][_valueLabel(==_dateLabel)]-10-[_changeLabel(==_dateLabel)]-10-[_changePrecentLabel(==_dateLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
}
@end
