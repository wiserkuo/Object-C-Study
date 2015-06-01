//
//  FSUITableViewCell.m
//  FonestockPower
//
//  Created by Connor on 2014/11/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSUITableViewCell.h"

@interface FSUITableViewCell(){
    NSMutableArray *layoutConstraints;
}
@end

@implementation FSUITableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //將cell 分隔線設為完整，不缺口
        if([self respondsToSelector:@selector(setLayoutMargins:)]){
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        layoutConstraints = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addCustomizeConstraints:(NSArray *)newConstraints
{
    [layoutConstraints addObjectsFromArray:newConstraints];
    [self.contentView addConstraints:layoutConstraints];
}

-(void)removeCustomizeConstraints
{
    [self.contentView removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
}

-(void)replaceCustomizeConstraints:(NSArray *)newConstraints
{
    [self removeConstraints:newConstraints];
    [self addCustomizeConstraints:newConstraints];
}


@end
