//
//  PageCollectionViewController.h
//  WirtsLeg
//
//  Created by Connor on 13/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPageControl.h"

@protocol PageControlViewControllerDelegate <NSObject>

- (void)refreshData;

@end


@interface PageControlViewController : FSUIViewController <UIScrollViewDelegate>

+ (id)pageControlWithViewControllerClassName:(NSArray *)candidateViewControllersClassName;
- (void)loadScrollViewWithPage:(int)page;

@property (strong, nonatomic) NSArray *candidateViewControllersClassName;
@property (strong, nonatomic) NSMutableArray *viewControllers; // 已產生的
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) DDPageControl *pageControl;
@property (unsafe_unretained, nonatomic) NSInteger currentPage;
@property (unsafe_unretained, nonatomic) NSInteger numberOfPages;

@end
