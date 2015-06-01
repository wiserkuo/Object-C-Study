//
//  WarrantViewController.h
//  WirtsLeg
//
//  Created by Connor on 13/9/26.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKCustomTableView.h"


@interface WarrantViewController : UIViewController <SKCustomTableViewDelegate, DataArriveProtocol>

@property (strong, nonatomic) NSString *targetStockName;
@property (strong, nonatomic) NSString *targetSymbol;
@property (strong, nonatomic) NSString *targetIdentCode;
@property (strong, nonatomic) NSString *targetIdentCodeSymbol;


@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *symbol;
@property (nonatomic, readonly) char *identCode;
@property (nonatomic) BOOL firstFlag;
-(void)sendHandler;
-(void)pushHandler;
@end
