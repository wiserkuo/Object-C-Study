//
//  FigureSearchCheckBoxTableViewCell.h
//  FonestockPower
//
//  Created by Kenny on 2014/6/16.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUIButton.h"

@interface FigureSearchCheckBoxTableViewCell : FSUITableViewCell
@property (strong, nonatomic) UIImageView * searchImageView;
@property (strong, nonatomic) FSUIButton *checkBtn;
@property (strong, nonatomic) UILabel *titleLabel;
@end
