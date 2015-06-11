//
//  FSCollectionViewArrayModel.m
//  Bullseye
//
//  Created by Shen Kevin on 13/8/5.
//
//

#import "FSMultiChartViewModel.h"
#import "FSMultiChartCell.h"
#import "FSMultiChartPlotManager.h"
#import "FSMultiChartPlotData.h"

@interface FSMultiChartViewModel ()
@property (nonatomic, strong) NSOperationQueue *imageProcessingQueue;
@end


@implementation FSMultiChartViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.imageProcessingQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}



#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [_watchlistItem count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSMultiChartCell *cell = (FSMultiChartCell *)[cv dequeueReusableCellWithReuseIdentifier:@"MultiChartCell" forIndexPath:indexPath];
    PortfolioItem *item = [_watchlistItem portfolioItem:indexPath];
    
    for (FSMultiChartPlotData *dataSource in [FSMultiChartPlotManager sharedInstance].plotDataSources) {
        if ([[dataSource.portfolioItem getIdentCodeSymbol] isEqualToString:[item getIdentCodeSymbol]]) {
            UIImage *chartImage = [dataSource imageOfChart:cell.chartImageView.frame];
            cell.chartImageView.image = chartImage;
            [cell custmizeCellAccordingToPorfolioItem:dataSource.portfolioItem];
        }
    }
    
    return cell;
}

@end
