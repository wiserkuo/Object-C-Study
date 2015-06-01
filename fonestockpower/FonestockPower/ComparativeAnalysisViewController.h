//
//  ComparativeAnalysisViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/10/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComparativeAnalysisViewController : UIViewController
-(void)reload:(NSMutableArray *)saveArray touchPoint:(double)pointX;
-(void)sendHandler;
@end
