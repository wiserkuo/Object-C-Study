//
//  FSMacros.h
//  FonestockPower
//
//  Created by Connor on 14/5/23.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#ifndef FonestockPower_FSMacros_h
#define FonestockPower_FSMacros_h

#define FS_appDelegate ((UAAppDelegate *)[[UIApplication sharedApplication] delegate])

#define FS_rgba(r,g,b,a)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define FS_rgb(r,g,b)       FS_rgba(r, g, b, 1.0f)


// 用來做Log用, 列印錯誤位置 如 <FSAppDelegate.m:46>
#ifdef DEBUG
#define FS_log( s, ... ) NSLog( @"<%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define FS_log( s, ... )
#endif

#define FS_logBounds(view) FS_log(@"%@ bounds: %@", view, NSStringFromRect([view bounds]))
#define FS_logFrame(view)  FS_log(@"%@ frame: %@", view, NSStringFromRect([view frame]))

#define NSStringFromBool(b) (b ? @"YES" : @"NO")

#define FS_SHOW_VIEW_BORDERS YES
#define FS_showDebugBorderForViewColor(view, color) if (FS_SHOW_VIEW_BORDERS) { view.layer.borderColor = color.CGColor; view.layer.borderWidth = 1.0; }
#define FS_showDebugBorderForView(view) FS_showDebugBorderForViewColor(view, [UIColor colorWithWhite:0.0 alpha:1.00])

#define FS_runOnMainThread if (![NSThread isMainThread]) { dispatch_sync(dispatch_get_main_queue(), ^{ [self performSelector:_cmd]; }); return; };

#endif
