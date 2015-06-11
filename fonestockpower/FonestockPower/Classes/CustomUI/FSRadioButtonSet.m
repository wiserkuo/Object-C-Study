//
//  FSRadioButtonSet.m
//  FonestockPower
//
//  Created by Connor on 14/3/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSRadioButtonSet.h"

@implementation FSRadioButtonSet
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedIndex = NSNotFound;
    }
    return self;
}

- (instancetype)initWithButtonArray:(NSArray *)buttons andDelegate:(id)delegate {
    self = [super init];
    if (self) {
        self.selectedIndex = NSNotFound;
        self.delegate = delegate;
        self.buttons = buttons;
    }
    return self;
}

#pragma mark - Custom accessors

- (void)setButtons:(NSArray *)buttons
{
    if (buttons != _buttons)
    {
        // Remove event handlers from old buttons (no-op if _buttons is nil)
        for (UIButton *button in _buttons)
        {
            [button removeTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        // Assign new buttons array
        _buttons = buttons;
        
        // Set event handlers on new buttons (no-op if _buttons is nil)
        for (UIButton *button in _buttons)
        {
            [button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex != _selectedIndex)
    {
        _selectedIndex = selectedIndex;
        for (NSUInteger i = 0; i < [self.buttons count]; i++)
        {
            UIButton *button = [self.buttons objectAtIndex:i];
            button.selected = i == selectedIndex;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(radioButtonSet:didSelectButtonAtIndex:)]) {
        [self.delegate radioButtonSet:self
                         didSelectButtonAtIndex:self.selectedIndex];
    }
}

#pragma mark - UI event handlers

- (void)handleButtonTap:(id)sender
{
    NSUInteger index = [self.buttons indexOfObject:sender];
    if (index != self.selectedIndex) {
        self.selectedIndex = index;
        
        for (UIButton *button in self.buttons)
        {
            button.selected = button == sender;
        }
    }
}
@end
