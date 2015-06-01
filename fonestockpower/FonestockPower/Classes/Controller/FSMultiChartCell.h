//
//  FSMultiChartCell.h
//  Bullseye
//
//  Created by Shen Kevin on 13/8/5.
//
//

#import <UIKit/UIKit.h>

@class PortfolioItem, CPTGraphHostingView;

@interface FSMultiChartCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *portfolioNameLabel;
@property (nonatomic, strong) UILabel *currentPriceLabel;
@property (nonatomic, strong) UILabel *rateOfChangeLabel;
@property (nonatomic, strong) UIImageView *chartImageView;

//- (void)reloadGraph;
//- (void)custmizeGraphColor:(EquitySnapshotDecompressed *) snapshot;
- (void)custmizeCellAccordingToPorfolioItem:(PortfolioItem *) portfolioItem;

@end
