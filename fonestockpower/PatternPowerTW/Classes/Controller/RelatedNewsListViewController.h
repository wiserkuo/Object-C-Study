//
//  RelatedNewsListViewController.h
//  WirtsLeg
//
//  Created by Connor on 13/6/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//  相關新聞

#import <UIKit/UIKit.h>
#import "RelatedNewsData.h"
#import "Portfolio.h"

@interface RelatedNewsListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) RelatedNewsData *relatedNewsData;
@property (nonatomic, strong) PortfolioItem *portfolioItem;
@property (nonatomic, strong) Portfolio *portfolio;
@property (nonatomic, strong) UITableView *mainView;
@property (nonatomic, readwrite) NSInteger count;
@property (nonatomic, strong) UICollectionView *collectionView;
@end
