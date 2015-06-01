//
//  FSCollectionViewArrayModel.h
//  Bullseye
//
//  Created by Shen Kevin on 13/8/5.
//
//

#import <Foundation/Foundation.h>
#import "FSWatchlistItemProtocol.h"

typedef void (^ConfigureCellBlock)(UICollectionViewCell*, NSObject*);

@interface FSMultiChartViewModel : NSObject <UICollectionViewDataSource, UIScrollViewDelegate>

//@property (nonatomic, strong) NSArray *items;
//@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;

//@property (copy) ConfigureCellBlock configureCellBlock;

@end
