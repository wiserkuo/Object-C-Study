//
//  FSOptionCell.h
//  FonestockPower
//
//  Created by Derek on 2014/9/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSOptionCell : FSUITableViewCell
@property (strong, nonatomic) NSMutableArray *labels;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
