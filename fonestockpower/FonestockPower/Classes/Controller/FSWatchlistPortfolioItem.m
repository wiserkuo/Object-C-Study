//
//  FSWatchlistPortfolioItem.m
//  WirtsLeg
//
//  Created by KevinShen on 13/9/24.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSWatchlistPortfolioItem.h"

@interface FSWatchlistPortfolioItem ()

@end


@implementation FSWatchlistPortfolioItem

- (id)init
{
    self = [super init];
    if (self) {
        int groupID = [[[FSDataModelProc sharedInstance]watchlists].watchs[0] groupID];
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID:groupID];
        [[[FSDataModelProc sharedInstance]portfolioData] selectGroupID:0];
        self.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

- (NSUInteger)count
{
    return [[[FSDataModelProc sharedInstance]portfolioData] getCount];
}

- (PortfolioItem *) portfolioItem:(NSIndexPath *) indexPath
{
    return [[[FSDataModelProc sharedInstance]portfolioData] getItemAt:(int)indexPath.row];
}

- (PortfolioItem *) portfolioItemAtIndex:(NSUInteger) index
{
    return [[[FSDataModelProc sharedInstance]portfolioData] getItemAt:(int)index];
}

- (NSMutableArray*) getWatchListArray{
    return [[[FSDataModelProc sharedInstance]portfolioData] getWatchListArray];
}

- (NSString *)name:(NSIndexPath *) indexPath
{
    PortfolioItem *item = [self portfolioItem:indexPath];
    
	NSString *identCodeString = [NSString stringWithUTF8String:&item->identCode[0]];
	
	if([identCodeString isEqualToString:@"TW"] ||
       [identCodeString isEqualToString:@"SS"] ||
       [identCodeString isEqualToString:@"SZ"] ||
       [identCodeString isEqualToString:@"GX"] ||
       [identCodeString isEqualToString:@"HK"] ||
       item->type_id == 10 ||
       (item->type_id == 3 && [identCodeString isEqualToString:@"US"]) ||
       (item->type_id == 6 && [identCodeString isEqualToString:@"US"])) {
		
		return item->fullName;	// TW, SS, SZ, GX HK, tyie_id=10 .
	}
	else {
		
		return item->symbol; // US and others
	}
    
}

- (UIColor *)alertStatus:(NSIndexPath *) indexPath
{
    PortfolioItem *item = [self portfolioItem:indexPath];
	
	if(item->alertState==1){
		
		return [StockConstant PriceUpColor];	//獲利
	}
	else if(item->alertState==2){
		
		return [StockConstant PriceDownColor]; //損失
	}else{
        return [UIColor clearColor];
    }
}

- (BOOL)editable:(NSUInteger) watchedIndex
{
    //全部商品的portfolio groupId
//    int groupID = [[DataModalProc getDataModal].watchlists.watchs[0] groupID];
//    int watchsIndex = [[DataModalProc getDataModal].watchlists getWatchsIndexByWatchGroupID:groupID];
    if (watchedIndex == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)sortDescending:(BOOL) descending;
{
    [[[FSDataModelProc sharedInstance]portfolioData] sortWatchlistArray:descending];
}

@end
