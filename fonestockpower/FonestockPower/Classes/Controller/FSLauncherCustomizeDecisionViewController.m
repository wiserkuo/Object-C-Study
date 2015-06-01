//
//  FSLauncherCustomizeViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherCustomizeDecisionViewController.h"
#import "UnitView.h"

//#import "EODTargetController.h"
//#import "EODActionController.h"
//#import "FigureSearchViewController.h"
//#import "MyFigureSearchViewController.h"
//#import "FSWatchlistViewController.h"
//#import "FSActionAlertViewController.h"
//#import "FSPositionManagementViewController.h"
//#import "FSDiaryViewController.h"
//#import "TrackPatternsViewController.h"


#define EACH_CONTENT_HEIGHT 120

@interface FSLauncherCustomizeDecisionViewController ()<FSEachSingleViewDeployDelegate>

@end

@implementation FSLauncherCustomizeDecisionViewController{
    UnitView *one;
    UnitView *two;
    UnitView *three;
    UnitView *four;
    
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
    self.title = NSLocalizedStringFromTable(@"神奇力", @"CustomizeUnitView", nil);
    
    theWidth = self.view.frame.size.width;
    
    sclView = [[UIScrollView alloc] init];
    sclView.translatesAutoresizingMaskIntoConstraints = NO;
    sclView.directionalLockEnabled = YES;
    sclView.delegate = self;
    sclView.userInteractionEnabled = YES;
    sclView.bounces = NO;
    [self.view addSubview:sclView];
    
    NSMutableArray *forOneImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"推薦標的", @"時機健診", nil];
    one = [[UnitView alloc] initWithEmptyView:forOneImgAndLabelArray :forOneImgAndLabelArray :41 :self];
    one.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:one];
    
    NSMutableArray *forTwoImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"標竿型態", @"我的型態", @"型態追蹤", nil];
    two = [[UnitView alloc] initWithEmptyView:forTwoImgAndLabelArray :forTwoImgAndLabelArray :42 :self];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:two];
    
    NSMutableArray *forThreeImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"個股研究", @"紀律交易", nil];
    three = [[UnitView alloc] initWithEmptyView:forThreeImgAndLabelArray :forThreeImgAndLabelArray :43 :self];
    three.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:three];
    
    NSMutableArray *forFourImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"部位管理", @"交易日記", nil];
    four = [[UnitView alloc] initWithEmptyView:forFourImgAndLabelArray :forFourImgAndLabelArray :44 :self];
    four.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:four];
    
}

-(void)updateViewConstraints
{
//    [self.view removeConstraints:self.view.constraints];
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSNumber *contentHeight = [[NSNumber alloc] initWithFloat:EACH_CONTENT_HEIGHT];
    NSNumber *contentWidth = [[NSNumber alloc] initWithFloat:theWidth - 6];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(one, two, three, four, sclView);
    NSDictionary *metrics = @{@"contentHeight":contentHeight, @"contentWidth":contentWidth};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sclView]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sclView]|" options:0 metrics:nil views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[one(contentHeight)]-2-[two(one)]-2-[three(one)]-2-[four(one)]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[one(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[two(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[three(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[four(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    
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
    if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
        return;
    }
    switch(viewNum){
        case 41:
            if(itemNum == 1){
                NSLog(@"推薦標的");
                viewController = [[NSClassFromString(@"EODTargetController") alloc] init];
            }else{
                NSLog(@"時機健診");
                viewController = [[NSClassFromString(@"EODActionController") alloc] init];
            }
            break;
        case 42:
            if(itemNum == 1){
                NSLog(@"標竿型態");
                viewController = [[NSClassFromString(@"FigureSearchViewController") alloc] init];
            }else if(itemNum == 2){
                NSLog(@"我的型態");
                viewController = [[NSClassFromString(@"MyFigureSearchViewController") alloc] init];
            }else{
                NSLog(@"型態追蹤");
                viewController = [[NSClassFromString(@"TrackPatternsViewController") alloc] init];
            }
            break;
        case 43:
            if(itemNum == 1){
                NSLog(@"個股研究");
                viewController = [[NSClassFromString(@"FSWatchlistViewController") alloc] init];
            }else{
                NSLog(@"紀律交易");
                viewController = [[NSClassFromString(@"FSActionAlertViewController") alloc] init];
            }
            break;
        case 44:
            if(itemNum == 1){
                NSLog(@"部位管理");
                viewController = [[NSClassFromString(@"FSPositionManagementViewController") alloc] init];
            }else{
                NSLog(@"交易日記");
                viewController = [[NSClassFromString(@"FSDiaryViewController") alloc] init];
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
