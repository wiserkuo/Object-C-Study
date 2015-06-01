//
//  SortingCustomTableView.m
//  WirtsLeg
//
//  Created by Neil on 13/10/11.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "SortingCustomTableView.h"


@implementation SortingCustomTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.labelArray = [[NSMutableArray alloc]init];
        _selectType = YES;
    }
    return self;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (!_selectType) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;

    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    [_labelArray removeAllObjects];
    if ([tableView isEqual:self.fixedTableView] && section == 0) {
        
//        UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
        
        UIView *fixedTableHeader = [[UIView alloc] init];
        fixedTableHeader.backgroundColor = [UIColor colorWithRed: 0.0/255.0 green: 78.0/255.0 blue: 162.0/255.0 alpha: 1.0];
        
        self.fixColumnsName =[[NSMutableArray alloc]initWithArray:[self.delegate columnsInFixedTableView]];
        for (int i = 0; i < [_fixColumnsName count]; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * 73, 0, 73, 44)];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
            
            [label addGestureRecognizer:tap];
            label.userInteractionEnabled = YES;
//            label.font = font;
            label.tag = i;
            label.textColor = [UIColor whiteColor];
            if (i==_focuseLabel) {
                label.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:162.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
            }else{
                label.backgroundColor = [UIColor clearColor];
            }
            label.text = [_fixColumnsName objectAtIndex:i];
            label.textAlignment = NSTextAlignmentLeft;
            if (_whiteLine) {
                label.layer.borderColor = [UIColor whiteColor].CGColor;
                label.layer.borderWidth = 0.5;
                label.textAlignment = NSTextAlignmentRight;
            }
            label.adjustsFontSizeToFitWidth = YES;
            
            [fixedTableHeader addSubview:label];
            [_labelArray addObject:label];
        }
        return fixedTableHeader;
        
    }else if ([tableView isEqual:self.mainTableView] && section == 0) {
        
//        UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
        UIView *mainTableHeader = [[UIView alloc] init];
        mainTableHeader.backgroundColor = [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0];
        NSArray *columnsName = [self.delegate columnsInMainTableView];
        for (int i = 0; i < [columnsName count]; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * self.mainColumnSize, 0, self.mainColumnSize, 44)];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
            
            [label addGestureRecognizer:tap];
            label.userInteractionEnabled = YES;
            label.numberOfLines = 0;
            [label setAdjustsFontSizeToFitWidth:YES];
//            label.lineBreakMode = NSLineBreakByCharWrapping;
            if (i+[_fixColumnsName count]==_focuseLabel) {
                label.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:162.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
            }else{
                label.backgroundColor = [UIColor clearColor];
            }
            
//            label.font = font;
            label.adjustsFontSizeToFitWidth = YES;
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [columnsName objectAtIndex:i];
            label.tag = i+[_fixColumnsName count];
            if (_whiteLine) {
                label.layer.borderColor = [UIColor whiteColor].CGColor;
                label.layer.borderWidth = 0.5;
                label.textAlignment = NSTextAlignmentRight;
            }
            [mainTableHeader addSubview:label];
            [_labelArray addObject:label];
        }
        return mainTableHeader;

    }
    
    return nil;
    
}

-(void)labelTap:(UITapGestureRecognizer *)sender{
    UILabel * label =(UILabel *)sender.view;
    if ([self.delegate respondsToSelector:@selector(labelTap:)]) {
        [self.delegate labelTap:label];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
