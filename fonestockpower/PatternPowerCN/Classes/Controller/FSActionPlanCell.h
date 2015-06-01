//
//  FSActionPlanCell.h
//  FonestockPower
//
//  Created by Derek on 2014/5/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSActionPlanCell : FSUITableViewCell
@property (strong, nonatomic) NSMutableArray *labels;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;

@end
