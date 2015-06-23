//
//  TWCompanyProfileViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TWCompanyProfileViewController.h"

@interface TWCompanyProfileViewController ()

@end

@implementation TWCompanyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.numberOfPages <= 1) {
        self.pageControl.hidden = YES;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page == self.currentPage) return;
    self.pageControl.currentPage = page;
    self.currentPage = page;
    [self.pageControl updateCurrentPageDisplay];
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    
    if (self.pageControl.currentPage != nearestNumber) {
        self.pageControl.currentPage = nearestNumber;
        if (self.scrollView.dragging) {
            
            [self.pageControl updateCurrentPageDisplay] ;
        }
    }

}

-(void)viewDidLayoutSubviews
{
    [self.pageControl setCenter:CGPointMake(self.scrollView.center.x, self.view.bounds.size.height - 10)];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * self.numberOfPages, self.scrollView.frame.size.height)];
}
@end
