//
//  FSDiaryCell.m
//  FonestockPower
//
//  Created by Derek on 2014/9/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSDiaryCell.h"

@implementation FSDiaryCell

@synthesize labels;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.labels = [[NSMutableArray alloc] initWithCapacity:capacity];
        
        for (int i = 0; i < capacity; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * 77, 0, 77, 44)];
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            
            [self.labels addObject:label];
            [self.contentView addSubview:label];
        }
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
    for (UILabel *label in labels) {
        label.text = nil;
    }
}

-(void)toTableView:(UITapGestureRecognizer *)sender{
    [_delegate toTableView:self];
}

@end
