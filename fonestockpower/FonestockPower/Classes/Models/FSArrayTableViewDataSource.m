//
//  FSArrayTableViewDataSource.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSArrayTableViewDataSource.h"

@interface FSArrayTableViewDataSource ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) ConfigureCellBlock configureCellBlock;
@end

@implementation FSArrayTableViewDataSource

- (id)initWithItems:(NSArray*)anItems cellIdentifier:(NSString*)aCellIdentifier configureCellBlock:(ConfigureCellBlock)aConfigureCellBlock
{
    self = [super init];
    if (self) {
        _items = anItems;
        _cellIdentifier = aCellIdentifier;
        _configureCellBlock = aConfigureCellBlock;
    }
    return self;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath {
    return _items[(NSUInteger)indexPath.row];
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    id cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier
                                              forIndexPath:indexPath];
    id item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell,item);
    return cell;
}

- (NSArray *)allItems
{
    return [self.items copy];
}

@end
