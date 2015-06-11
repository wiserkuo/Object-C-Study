//
//  FSMainForceAnchorViewController.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSMainForceAnchorViewController : FSUIViewController

@end


@interface FSMainForceAnchorData : NSObject
@property NSString *name;
@property double overBought;
@property double buy;
@property double sell;
@property double buyAvg;
@property double sellAvg;

@end

