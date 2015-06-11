//
//  RevenueViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/12/3.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "RevenueViewController.h"
#import "RevenueController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@interface RevenueViewController ()
@property (strong, nonatomic) UIView *touchView;
@property (nonatomic, strong) NSMutableDictionary *mainDict;
@end

@implementation RevenueViewController

//CGPoint originalLocation;
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    // Pass to top of chain
//    UIResponder *responder = self;
//    while (responder.nextResponder != nil){
//        responder = responder.nextResponder;
//        if ([responder isKindOfClass:[UIViewController class]]) {
//            // Got ViewController
//            break;
//        }
//    }
//    [responder touchesBegan:touches withEvent:event];
//}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    originalLocation = [touch locationInView:self.view];
//    [self.nextResponder touchesBegan:touches withEvent:event];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint currentLocation = [touch locationInView:self.view];
//    CGRect frame = self.view.frame;
//    frame.origin.x += currentLocation.x-originalLocation.x;
//    frame.origin.y += currentLocation.y-originalLocation.y;
//    self.view.frame = frame;
    
//    if (currentLocation.y - originalLocation.y < 0) {
//        UIResponder *responder = self;
//        while (responder.nextResponder != nil){
//            responder = responder.nextResponder;
//            if ([responder isKindOfClass:[SKCustomTableView class]]) {
//                // Got ViewController
//                break;
//            }
//        }
//        [responder touchesBegan:touches withEvent:event];

//    } else {
//        UIResponder *responder = self;
//        while (responder.nextResponder != nil){
//            responder = responder.nextResponder;
//            if ([responder isKindOfClass:[SKCustomTableView class]]) {
//                // Got ViewController
//                break;
//            }
//        }
//        [responder touchesBegan:touches withEvent:event];
//
//    }
//    if (currentLocation.y - originalLocation.y > 0) {
//        //finger touch went upwards
//    } else {
//        //finger touch went downwards
//    }
    
//    [self.nextResponder touchesBegan:touches withEvent:event];
//}

-(void)viewWillAppear:(BOOL)animated
{
    
}


- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)sender {
    switch ([sender direction]) {
            
        case UISwipeGestureRecognizerDirectionUp:
            
            
            break;
            
        case UISwipeGestureRecognizerDirectionDown:

            break;
            
        case UISwipeGestureRecognizerDirectionRight:
            self.pageControl.currentPage = self.pageControl.currentPage - 1;
            [self.scrollView setContentOffset: CGPointMake(self.scrollView.bounds.size.width * self.pageControl.currentPage, 0) animated: YES];
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            self.pageControl.currentPage = self.pageControl.currentPage + 1;
            [self.scrollView setContentOffset: CGPointMake(self.scrollView.bounds.size.width * self.pageControl.currentPage, 0) animated: YES];
            break;            
    }
}

- (void)viewWillDisappear:(BOOL)animated {
//    [self cancelObserveWatchedPortfolio];
    [super viewWillDisappear:animated];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      
                      [NSString stringWithFormat:@"RevenueMemory.plist"]];
    
    self.mainDict = [[NSMutableDictionary alloc] init];
    [self.mainDict setObject:[NSNumber numberWithInteger:self.pageControl.currentPage] forKey:@"RevenueNumber"];
    
    [self.mainDict writeToFile:path atomically:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pageControl.numberOfPages = 2;
    self.pageControl.currentPage = 0;
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
    [self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
    [self.pageControl setOnColor: [UIColor redColor]];
    [self.pageControl setOffColor: [UIColor redColor]];
    [self.pageControl setIndicatorDiameter: 7.0f] ;
    [self.pageControl setIndicatorSpace: 7.0f] ;
    
    self.touchView = [[UIView alloc] init];
    self.touchView.userInteractionEnabled = YES;
    self.touchView.translatesAutoresizingMaskIntoConstraints = NO;
    self.touchView.backgroundColor = [UIColor clearColor];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSwipeFrom:)];
    
    right.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.touchView addGestureRecognizer:left];
    [self.touchView addGestureRecognizer:right];
    
    [self.view addSubview:self.touchView];
    self.touchView.userInteractionEnabled = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_touchView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_touchView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[_touchView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_touchView)]];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSString *path = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"RevenueMemory.plist"]];
    self.mainDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if(_mainDict){
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * [(NSNumber *)[_mainDict objectForKey:@"RevenueNumber"]intValue], 0);
    }else{
        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * 0, 0);
    }
    [self.pageControl setCenter:CGPointMake(self.scrollView.center.x, self.view.bounds.size.height - 10)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.bounds.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger nearestNumber = lround(fractionalPage);
    if (self.pageControl.currentPage != nearestNumber) {
        self.pageControl.currentPage = nearestNumber;
        if (self.scrollView.dragging) {
            
            [self.pageControl updateCurrentPageDisplay] ;
        }
    }
}
@end
