//
//  FSArrayTableViewDataSource.h
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ConfigureCellBlock)(UITableViewCell *cell, NSObject *item);

@interface FSArrayTableViewDataSource : NSObject <UITableViewDataSource>
@property (nonatomic, readonly) NSArray *allItems;
- (id)initWithItems:(NSArray*)anItems cellIdentifier:(NSString*)aCellIdentifier configureCellBlock:(ConfigureCellBlock)aConfigureCellBlock;
@end
