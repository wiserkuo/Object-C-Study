//
//  EDOActionController.h
//  FonestockPower
//
//  Created by Kenny on 2014/5/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EODActionModel.h"

@interface EODActionController : FSUIViewController<UITableViewDataSource,UITableViewDelegate>
-(void)notifyLongData:(ArrayData *)target;
-(void)notifyShortData:(ArrayData *)target;
@end


@interface ActionObject : NSObject
@property (nonatomic, strong)NSString *symbol;
@property (nonatomic, strong)NSString *term;
@end