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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.currentPage = 0;
    self.pageControl.currentPage = 0;
    self.scrollView.bounces = NO;
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
    [self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
    [self.pageControl setOnColor: [UIColor redColor]];
    [self.pageControl setOffColor: [UIColor redColor]];
    [self.pageControl setIndicatorDiameter: 7.0f] ;
    [self.pageControl setIndicatorSpace: 7.0f] ;
    [self.view addSubview:self.pageControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
