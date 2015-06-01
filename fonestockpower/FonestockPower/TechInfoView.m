//
//  TechInfoView.m
//  FonestockPower
//
//  Created by Kenny on 2014/12/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TechInfoView.h"
@interface TechInfoView()
{
    NSMutableArray *layoutConstraints;
}
@end
@implementation TechInfoView

-(id)init
{
    self = [super init];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        
        self.topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:117.0/255.0 blue:174.0/255.0 alpha:1];
        _topView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_topView];

        self.dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor colorWithRed:254.0/255.0 green:250.0/255.0 blue:129.0/255.0 alpha:1];
        _dateLabel.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:117.0/255.0 blue:174.0/255.0 alpha:1];
        _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_topView addSubview:_dateLabel];
        
        self.openTitle = [[UILabel alloc] init];
        _openTitle.text = NSLocalizedStringFromTable(@"開", @"DivergenceTips", nil);
        _openTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_openTitle];
        
        self.highTitle = [[UILabel alloc] init];
        _highTitle.text = NSLocalizedStringFromTable(@"高", @"DivergenceTips", nil);
        _highTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_highTitle];
        
        self.lowTitle = [[UILabel alloc] init];
        _lowTitle.text = NSLocalizedStringFromTable(@"低", @"DivergenceTips", nil);
        _lowTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_lowTitle];
        
        self.lastTitle = [[UILabel alloc] init];
        _lastTitle.text = NSLocalizedStringFromTable(@"收", @"DivergenceTips", nil);
        _lastTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_lastTitle];
        
        self.changeTitle = [[UILabel alloc] init];
        _changeTitle.text = NSLocalizedStringFromTable(@"差", @"DivergenceTips", nil);
        _changeTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_changeTitle];
        
        self.whiteLabel = [[UILabel alloc] init];
        _whiteLabel.text = @"   ";
        _whiteLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_whiteLabel];
        
        self.volumeTitle = [[UILabel alloc] init];
        _volumeTitle.text = NSLocalizedStringFromTable(@"量", @"DivergenceTips", nil);
        _volumeTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_volumeTitle];
        
        self.open = [[UILabel alloc] init];
        _open.textAlignment = NSTextAlignmentRight;
        _open.adjustsFontSizeToFitWidth = YES;
        _open.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_open];
        
        self.high = [[UILabel alloc] init];
        _high.textAlignment = NSTextAlignmentRight;
        _high.adjustsFontSizeToFitWidth = YES;
        _high.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_high];
        
        self.low = [[UILabel alloc] init];
        _low.textAlignment = NSTextAlignmentRight;
        _low.adjustsFontSizeToFitWidth = YES;
        _low.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_low];
        
        self.last = [[UILabel alloc] init];
        _last.textAlignment = NSTextAlignmentRight;
        _last.adjustsFontSizeToFitWidth = YES;
        _last.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_last];
        
        self.change = [[UILabel alloc] init];
        _change.textAlignment = NSTextAlignmentRight;
        _change.adjustsFontSizeToFitWidth = YES;
        _change.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_change];
        
        self.changeRate = [[UILabel alloc] init];
        _changeRate.textAlignment = NSTextAlignmentRight;
        _changeRate.adjustsFontSizeToFitWidth = YES;
        _changeRate.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_changeRate];
        
        self.volume = [[UILabel alloc] init];
        _volume.textAlignment = NSTextAlignmentRight;
        _volume.adjustsFontSizeToFitWidth = YES;
        _volume.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_volume];
        
        
        layoutConstraints = [[NSMutableArray alloc] init];
        
        [self setNeedsUpdateConstraints];
    }
    return  self;
}

-(void)updateConstraints
{
    [super updateConstraints];
    [self removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_dateLabel, _openTitle, _highTitle, _lowTitle, _lastTitle, _changeTitle, _volumeTitle, _open, _high, _low, _last, _change, _changeRate, _volume, _whiteLabel, _topView);

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(==_openTitle)][_openTitle][_highTitle(==_openTitle)][_lowTitle(==_openTitle)][_lastTitle(==_openTitle)][_changeTitle(==_openTitle)][_whiteLabel(==_openTitle)][_volumeTitle(==_openTitle)]|" options:0 metrics:nil views:viewDictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topView(==_open)][_open][_high(==_open)][_low(==_open)][_last(==_open)][_change(==_open)][_whiteLabel(==_open)][_volume(==_open)]|" options:0 metrics:nil views:viewDictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topView]|" options:0 metrics:nil views:viewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_dateLabel]" options:0 metrics:nil views:viewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_dateLabel]" options:0 metrics:nil views:viewDictionary]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_openTitle(55)][_open]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_highTitle(55)][_high]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_lowTitle(55)][_low]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_lastTitle(55)][_last]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_changeTitle(55)][_change]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_whiteLabel(55)][_changeRate]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_volumeTitle(55)][_volume]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewDictionary]];
    
    [self addConstraints:layoutConstraints];
}

@end
