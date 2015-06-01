//
//  TextFieldTableViewCell.h
//  WirtsLeg
//
//  Created by Neil on 13/10/18.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldTableViewDelegate.h"

@interface TextFieldTableViewCell : FSUITableViewCell <UITextFieldDelegate>

@property (strong ,nonatomic) id<TextFieldTableViewDelegate> delegate;

@property (strong, nonatomic) NSIndexPath * indexPath;
@property (strong, nonatomic) NSMutableArray *textFields;
@property (strong, nonatomic) UITextField *profitTextField;
@property (strong, nonatomic) UITextField *lostTextField;
@property (strong, nonatomic) UILabel * label;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
