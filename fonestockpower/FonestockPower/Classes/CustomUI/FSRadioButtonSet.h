//
//  FSRadioButtonSet.h
//  FonestockPower
//
//  Created by Connor on 14/3/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSRadioButtonSet;

@protocol FSRadioButtonSetDelegate <NSObject>
- (void)radioButtonSet:(FSRadioButtonSet *)controller
          didSelectButtonAtIndex:(NSUInteger)selectedIndex;
@end

@interface FSRadioButtonSet : NSObject

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic, weak) id <FSRadioButtonSetDelegate> delegate;
@property (nonatomic) NSUInteger selectedIndex;

- (instancetype)initWithButtonArray:(NSArray *)buttons andDelegate:(id)delegate;

@end
