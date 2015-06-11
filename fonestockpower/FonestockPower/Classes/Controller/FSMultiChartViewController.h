//
//  FSMultiChartViewController.h
//  Bullseye
//
//  Created by Shen Kevin on 13/8/5.
//
//

#import <UIKit/UIKit.h>
#import "FSMultiChartPlotManagerDelegate.h"
#import "FSWatchlistItemProtocol.h"

@interface FSMultiChartViewController : UICollectionViewController <FSMultiChartPlotManagerDelegate>
@property (nonatomic, strong) NSObject<FSWatchlistItemProtocol> *watchlistItem;

-(void)updatePlotDataSource;
@end
