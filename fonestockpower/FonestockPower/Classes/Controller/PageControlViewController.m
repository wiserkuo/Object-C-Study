//
//  PageCollectionViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "PageControlViewController.h"
#import "UIViewController+ContainerNavigationItem.h"

@implementation PageControlViewController
#pragma mark -
#pragma mark object life

- (id)initWithViewController:(NSArray *)candidateViewControllersClassName setCurrentPage:(NSInteger)currentPage {
    if (self = [super init]) {
        self.candidateViewControllersClassName = candidateViewControllersClassName;
        self.currentPage = currentPage;
        self.numberOfPages = [candidateViewControllersClassName count];
        
        // 產生目標數量的空ViewController
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        for (unsigned i = 0; i < self.numberOfPages; i++) {
            [controllers addObject:[NSNull null]];
        }
        self.viewControllers = controllers;
    }
    return self;
}

+ (id)pageControlWithViewControllerClassName:(NSArray *)candidateViewControllersClassName {
    
    if ([candidateViewControllersClassName count] == 0) {
        return nil;
    }
    
    id viewController = [[self alloc] initWithViewController:candidateViewControllersClassName setCurrentPage:1];

    return viewController;
}

- (void)dealloc {
    
}

#pragma mark -
#pragma mark view controller life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initScrollView];
    [self initPageControl];
    
    if (self.numberOfPages > 0 && self.currentPage < self.numberOfPages) {
        
        
        for(int i = 0; i<self.numberOfPages; i++){
            [self loadScrollViewWithPage:i];
        }
        
//        [self loadScrollViewWithPage:self.currentPage];
//        
//        if (self.currentPage + 1 < self.numberOfPages) {
//            [self loadScrollViewWithPage:self.currentPage + 1];
//        }
//        if (self.currentPage - 1 >= 0) {
//            [self loadScrollViewWithPage:self.currentPage - 1];
//        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController respondsToSelector:@selector(refreshData)]) {
            [viewController performSelector:@selector(refreshData) withObject:nil];
        }
    }
    self.currentPage = 1;
//    if (self.numberOfPages > 0 && self.currentPage < self.numberOfPages) {
//        
//        [self loadScrollViewWithPage:self.currentPage];
//        
//        if (self.currentPage + 1 < self.numberOfPages) {
//            [self loadScrollViewWithPage:self.currentPage + 1];
//        }
//        if (self.currentPage - 1 >= 0) {
//            [self loadScrollViewWithPage:self.currentPage - 1];
//        }
//    }
//    [self.scrollView setContentOffset:CGPointMake(self.currentPage * self.scrollView.frame.size.width, 0)];
}

#pragma mark -
#pragma mark pageController main logic

- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.frame = self.view.bounds;
#pragma 為了硬解頁面主畫面滑動的問題而用的骯髒解法
    if(![self isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")]){
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.numberOfPages, self.scrollView.frame.size.height);
    [self.scrollView setContentOffset:CGPointMake(self.currentPage * self.scrollView.frame.size.width, 0)];
    
    [self.view addSubview:self.scrollView];
}

- (void)initPageControl {
    self.pageControl = [[DDPageControl alloc] init];
    self.pageControl.numberOfPages = self.numberOfPages;
    self.pageControl.currentPage = self.currentPage;
    self.pageControl.defersCurrentPageDisplay = YES;
    self.pageControl.type = DDPageControlTypeOnFullOffEmpty;
    self.pageControl.onColor = [UIColor redColor];
    self.pageControl.offColor = [UIColor redColor];
    self.pageControl.indicatorDiameter = 7.0f;
    self.pageControl.indicatorSpace = 7.0f;
    [self.pageControl setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height - 75)];
    [self.view addSubview:self.pageControl];
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= self.numberOfPages) return;
    
    UIViewController *controller = [self.viewControllers objectAtIndex:page];
    
#pragma 為了硬解頁面跳轉不完全而用的骯髒解法
    if([self isKindOfClass:NSClassFromString(@"FSLauncherPageViewController")] && (self.scrollView.contentOffset.x == 72.0 || self.scrollView.contentOffset.x == 160.0)){
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * 1, self.scrollView.contentOffset.y)];
    }
    
    if ((NSNull *)controller == [NSNull null]) {
        
        NSString *className = [self.candidateViewControllersClassName objectAtIndex:page];
        
        controller = [[NSClassFromString(className) alloc] init]; // controller 初始化
                
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }

    if (nil == controller.view.superview) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = sender.frame.size.width;
    int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page == _currentPage) return;
    self.pageControl.currentPage = page;
    _currentPage = page;
    [self.pageControl updateCurrentPageDisplay];
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    
//    UIViewController *currentViewController = [self.viewControllers objectAtIndex:page];
//    self.title = [currentViewController title];
    
//    [self.navigationItem setHidesBackButton:currentViewController.navigationItem.hidesBackButton];
//    self.navigationItem.leftBarButtonItems = currentViewController.navigationItem.leftBarButtonItems;
}

@end
