//
//  SearchCriteriaViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/10/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderTableViewCell.h"
@interface SearchCriteriaViewController : FSUIViewController
@property (nonatomic, strong) NSString *formula;
-(id)initWithName:(NSString *)name;
-(void)setTarget:(id)obj;
@end
