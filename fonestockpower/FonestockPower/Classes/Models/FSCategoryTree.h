//
//  FSCategoryTree.h
//  FonestockPower
//
//  Created by Connor on 14/4/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SectorTableIn;

@interface FSCategoryTree : NSObject{
    NSRecursiveLock *lockCategory;
    NSObject * targetObj;
}
- (void)loginNotify;
- (void)updateCategory:(SectorTableIn *)obj;
- (UInt16) getCatType: (UInt16) catID;
- (NSMutableArray*) getAllLeafCategories;
-(void)searcgSectorTableWithSectorID:(UInt16 *)sectorID;
-(void)setTargetObj:(id)obj;
-(void)searchSectorIdByIdentCode:(NSString *)ids Symbol:(NSString *)symbol;

-(void)dataCallBackWithArray:(NSMutableArray *)dataArray;
@end

@interface CategoryNode : NSObject {
@public
	NSString* catName;
	UInt16 catID;
	UInt16 parentID;
	UInt16 type;  //bit 1:news, bit2:Stock, bit3:warrant, bit4:index, bit5:future, bit6:-Option, bit7:forex. bit8~16:reserved(low bit 的第一個位置，代表Bit1，以此類推. 值：1表示Yes，0表示No。)
	int leaf; // 0:not leaf=1:formal leaf=3:special leaf(the leaf is aslo include identcode symbol leaf) leaf=5 權證商品的leaf
};
@end