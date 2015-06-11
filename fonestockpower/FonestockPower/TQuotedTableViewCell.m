//
//  TestCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TQuotedTableViewCell.h"

@implementation TQuotedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelArray:(NSMutableArray *)array
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.scrollView = [[UIScrollView alloc] init];
        _scrollView.bounces = NO;
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_scrollView];
        
        for (int i = 0; i< [array count]; i++){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*80, 0, 80, 44)];
            label.text = [array objectAtIndex:i];
            label.textAlignment = NSTextAlignmentCenter;
            [self.scrollView addSubview:label];
        }
        [_scrollView setContentSize:CGSizeMake([array count]*80, 0)];
        [self updateConstraints];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateConstraints
{
    [super updateConstraints];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_scrollView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewDictionary]];
    
    
}





@end
