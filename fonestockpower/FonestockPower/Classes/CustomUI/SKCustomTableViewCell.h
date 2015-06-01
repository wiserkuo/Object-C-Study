//
//  SKCustomTableViewCell.h
//  WirtsLeg
//
//  Created by Connor on 13/8/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKCustomTableViewCell : FSUITableViewCell
@property (strong, nonatomic) NSMutableArray *labels;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier AndLabelAmount:(int)capacity;
@end
