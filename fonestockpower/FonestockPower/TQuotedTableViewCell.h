//
//  TestCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TQuotedTableViewCell : UITableViewCell
@property (nonatomic, strong) UIScrollView *scrollView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelArray:(NSMutableArray *)array;
@end
