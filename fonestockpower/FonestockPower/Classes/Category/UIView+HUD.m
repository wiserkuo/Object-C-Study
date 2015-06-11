//
//  UIView+HUD.m
//  FonestockPower
//
//  Created by Connor on 14/4/9.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "UIView+HUD.h"
#import "FSHUD.h"

@implementation UIView (HUD)

- (void)showHUDWithTitle:(NSString *)title {
    [FSHUD showHUDin:self title:title];
}

- (void)hideHUD {
    [FSHUD hideHUDFor:self];
}
@end
