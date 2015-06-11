//
//  FSLauncherCustomizeViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherCustomizeDerivativeViewController.h"
#import "UnitView.h"
#import "FSOptionMainViewController.h"

#define EACH_CONTENT_HEIGHT 100

@interface FSLauncherCustomizeDerivativeViewController ()<UIScrollViewDelegate>

@end

@implementation FSLauncherCustomizeDerivativeViewController{
    UnitView *one;
    UnitView *two;
    UnitView *three;
    UnitView *four;
    
    UIImageView *wl12;
    UIImageView *wl23;
    UIImageView *wl34;
    
    UIScrollView *sclView;
    
    CGFloat theWidth;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {  // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone;                       //layout adjustements
    }
    [self initView];
    [self.view setNeedsUpdateConstraints];
	// Do any additional setup after loading the view.
}

-(void)initView
{
    self.title = NSLocalizedStringFromTable(@"衍生性商品", @"CustomizeUnitView", nil);
    
    theWidth = self.view.frame.size.width;
    
    sclView = [[UIScrollView alloc] init];
    sclView.directionalLockEnabled = YES;
    sclView.translatesAutoresizingMaskIntoConstraints = NO;
    sclView.delegate = self;
    sclView.userInteractionEnabled = YES;
    sclView.bounces = NO;
    [self.view addSubview:sclView];
    
    one = [[UnitView alloc] initWithSpecialize:@"權證" :31 :@"權\n\n證" :self];
    one.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:one];
    
    two = [[UnitView alloc] initWithSpecialize:@"選擇權" :32 :@"選\n擇\n權" :self];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:two];
    
    three = [[UnitView alloc] initWithSpecialize:@"台灣期貨" :33 :@"台\n灣\n期\n貨" :self];
    three.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:three];
    
    four = [[UnitView alloc] initWithSpecialize:@"興櫃" :34 :@"興\n\n櫃" :self];
    four.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:four];
    
    wl12 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl12.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:wl12];
    wl23 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl23.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:wl23];
    wl34 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl34.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:wl34];

}

-(void)updateViewConstraints
{
//    [self.view removeConstraints:self.view.constraints];
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSNumber *contentHeight = [[NSNumber alloc] initWithFloat:EACH_CONTENT_HEIGHT];
    NSNumber *contentWidth = [[NSNumber alloc] initWithFloat:theWidth - 6];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(one, two, three, four, sclView, wl12, wl23, wl34);
    NSDictionary *metrics = @{@"contentHeight":contentHeight, @"contentWidth":contentWidth};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sclView]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sclView]|" options:0 metrics:nil views:allObj]];
 
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[one(contentHeight)]-3-[wl12(2)]-3-[two(one)]-3-[wl23(2)]-3-[three(one)]-3-[wl34(2)]-3-[four(one)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[one(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[two(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[three(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[four(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl12]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl23]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl34]|" options:0 metrics:nil views:allObj]];
    
//    [super updateViewConstraints];
    [self replaceCustomizeConstraints:constraints];
}

-(void)viewDidLayoutSubviews
{
    [sclView setContentSize:CGSizeMake(theWidth, EACH_CONTENT_HEIGHT * 4 + 40)];
}

-(void)tapOccurred:(NSInteger)viewNum :(UITapGestureRecognizer *)something
{
    NSInteger itemNum = something.view.tag;
    UIViewController *viewController = nil;
//    if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
//        return;
//    }
    switch(viewNum){
        case 31:
            if(itemNum == 1){
                NSLog(@"權證");
                viewController = nil;
            }
            break;
        case 32:
            if(itemNum == 1){
                NSLog(@"選擇權");
                viewController = [[FSOptionMainViewController alloc] init];
            }
            break;
        case 33:
            if(itemNum == 1){
                NSLog(@"台灣期貨");
                viewController = nil;
            }
            break;
        case 34:
            if(itemNum == 1){
                NSLog(@"興櫃");
                viewController = nil;
            }
            break;
        default: break;
    }
    if (viewController == nil) return;
    
    if (self.parentViewController != nil) {
        [self.parentViewController.navigationController pushViewController:viewController animated:NO];
    } else {
        [self.navigationController pushViewController:viewController animated:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
