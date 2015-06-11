//
//  EDOActionCollectionViewLayout.m
//  FonestockPower
//
//  Created by Kenny on 2014/5/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODActionCollectionViewLayout.h"

@implementation EODActionCollectionViewLayout
- (id)init {
    if (self = [super init]) {
        self.itemSize = CGSizeMake(80, 80);
        self.minimumInteritemSpacing = 40;
        self.minimumLineSpacing = 8;
        self.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
        self.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}
@end
