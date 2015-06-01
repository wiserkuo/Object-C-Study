//
//  FSLauncherCustomizeViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherCustomizeServiceViewController.h"
#import "UnitView.h"

#import "FSPaymentViewController.h"

#define EACH_CONTENT_HEIGHT 100

@interface FSLauncherCustomizeServiceViewController ()<UIScrollViewDelegate>

@end

@implementation FSLauncherCustomizeServiceViewController{
    NSInteger worstWayToSolveTheDoubleCalledBug;
    
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
    self.title = NSLocalizedStringFromTable(@"神乎服務", @"CustomizeUnitView", nil);
    
    worstWayToSolveTheDoubleCalledBug = 0;
    
    theWidth = self.view.frame.size.width;
    
    sclView = [[UIScrollView alloc] init];
    sclView.translatesAutoresizingMaskIntoConstraints = NO;
    sclView.directionalLockEnabled = YES;
    sclView.userInteractionEnabled = YES;
    sclView.delegate = self;
    sclView.bounces = NO;
    [self.view addSubview:sclView];
    
    NSMutableArray *forOneImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"線上繳費", @"雲端備份", nil];
    one = [[UnitView alloc] initWithEmptyView:forOneImgAndLabelArray :forOneImgAndLabelArray :11 :self];
    one.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:one];
    
    NSMutableArray *forTwoImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"連線設定", @"螢幕鎖定", nil];
    two = [[UnitView alloc] initWithEmptyView:forTwoImgAndLabelArray :forTwoImgAndLabelArray :12 :self];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:two];
    
    NSMutableArray *forThreeImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"空中升級", @"神乎公告", nil];
    three = [[UnitView alloc] initWithEmptyView:forThreeImgAndLabelArray :forThreeImgAndLabelArray :13 :self];
    three.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:three];
    
    NSMutableArray *forFourImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"門市據點", nil];
    four = [[UnitView alloc] initWithEmptyView:forFourImgAndLabelArray :forFourImgAndLabelArray :14 :self];
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
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sclView]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sclView]|" options:0 metrics:nil views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[one(contentHeight)]-5-[wl12(2)]-1-[two(one)]-5-[wl23(2)]-1-[three(one)]-5-[wl34(2)]-1-[four(one)]" options:0 metrics:metrics views:allObj]];
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
    worstWayToSolveTheDoubleCalledBug++;
    NSInteger itemNum = something.view.tag;
    UIViewController *viewController = nil;
//    if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
//        return;
//    }
    if(worstWayToSolveTheDoubleCalledBug % 2 != 0)return;
    switch(viewNum){
        case 11:
            if(itemNum == 1){
                NSLog(@"線上繳費");
                FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
                FSFonestock *fonestock = [FSFonestock sharedInstance];
                
                NSString *paymentFullURL = [NSString stringWithFormat:@"%@?acc_id=%@&app_id=%@&lang=%@&request_iap=1&forapp=1", fonestock.paymentPageURL, loginService.account, fonestock.appId, fonestock.lang];
                viewController = [[FSPaymentViewController alloc] initWithPaymentURL:paymentFullURL];
            }else{
                NSLog(@"雲端備份");
                viewController = nil;
            }
            break;
        case 12:
            if(itemNum == 1){
                NSLog(@"連線設定");
                viewController = [[NSClassFromString(@"ConnectSettingViewController") alloc] init];
            }else{
                NSLog(@"螢幕鎖定");
                viewController = nil;
            }
            break;
        case 13:
            if(itemNum == 1){
                NSLog(@"空中升級");
                viewController = nil;
            }else{
                NSLog(@"神乎飛信");
                viewController = nil;
            }
            break;
        case 14:
            if(itemNum == 1){
                NSLog(@"門市據點");
                viewController = [[NSClassFromString(@"ShopInfoViewController") alloc] init];
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
