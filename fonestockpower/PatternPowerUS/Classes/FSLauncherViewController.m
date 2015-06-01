//
//  FSLauncherViewController.m
//  FonestockPower
//
//  Created by Connor on 14/4/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherViewController.h"
#import "FSLauncherViewController.h"
#import "FSAccountSettingViewController.h"
#import "FSLauncherCollectionViewCell.h"
#import "FigureSearchViewController.h"
#import "MyFigureSearchViewController.h"
#import "FSWatchlistViewController.h"
#import "FSWebViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "EODTargetController.h"
#import "EODActionController.h"
#import "FSActionAlertViewController.h"
#import "FSPositionManagementViewController.h"
#import "FSDiaryViewController.h"
#import "TrendEODActionViewController.h"
//#import "GADInterstitial.h"
#import "FSBAQuery.h"
#import "FSTickQuery.h"
#import "UnitCell.h"
#import "TrackPatternsViewController.h"


//@interface FSLauncherViewController () <GADInterstitialDelegate> {
@interface FSLauncherViewController () {
//    GADInterstitial *gad_interstitial;
    BOOL popFullAdFlag;
}

@end

@implementation FSLauncherViewController{
    UnitCell *one;
    UnitCell *two;
    UnitCell *three;
    UnitCell *four;
    UnitCell *five;
    UnitCell *six;
    UnitCell *seven;
    UnitCell *eight;
    UnitCell *nine;
    
    UITapGestureRecognizer *tap1;
    UITapGestureRecognizer *tap2;
    UITapGestureRecognizer *tap3;
    UITapGestureRecognizer *tap4;
    UITapGestureRecognizer *tap5;
    UITapGestureRecognizer *tap6;
    UITapGestureRecognizer *tap7;
    UITapGestureRecognizer *tap8;
    UITapGestureRecognizer *tap9;
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
    self.title = NSLocalizedStringFromTable(@"圖是力", @"Launcher", nil);
    
    tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    
    one = [[UnitCell alloc] initWithCell:@"推薦標的" :NSLocalizedStringFromTable(@"推薦標的", @"Launcher", nil) imageSize:NAN];
    one.translatesAutoresizingMaskIntoConstraints = NO;
    one.tag = 1;
    [one addGestureRecognizer:tap1];
    [self.view addSubview:one];
    
    two = [[UnitCell alloc] initWithCell:@"時機健診" :NSLocalizedStringFromTable(@"時機健診", @"Launcher", nil) imageSize:NAN];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    two.tag = 2;
    [two addGestureRecognizer:tap2];
    [self.view addSubview:two];
    
    three = [[UnitCell alloc] initWithCell:@"標竿型態" :NSLocalizedStringFromTable(@"標竿型態", @"Launcher", nil) imageSize:NAN];
    three.translatesAutoresizingMaskIntoConstraints = NO;
    three.tag = 3;
    [three addGestureRecognizer:tap3];
    [self.view addSubview:three];
    
    four = [[UnitCell alloc] initWithCell:@"我的型態" :NSLocalizedStringFromTable(@"我的型態", @"Launcher", nil) imageSize:NAN];
    four.translatesAutoresizingMaskIntoConstraints = NO;
    four.tag = 4;
    [four addGestureRecognizer:tap4];
    [self.view addSubview:four];
    
    five = [[UnitCell alloc] initWithCell:@"型態追蹤" :NSLocalizedStringFromTable(@"型態追蹤", @"Launcher", nil) imageSize:NAN];
    five.translatesAutoresizingMaskIntoConstraints = NO;
    five.tag = 5;
    [five addGestureRecognizer:tap5];
    [self.view addSubview:five];
    
    six = [[UnitCell alloc] initWithCell:@"自選分析" :NSLocalizedStringFromTable(@"自選分析", @"Launcher", nil) imageSize:NAN];
    six.translatesAutoresizingMaskIntoConstraints = NO;
    six.tag = 6;
    [six addGestureRecognizer:tap6];
    [self.view addSubview:six];
    
    seven = [[UnitCell alloc] initWithCell:@"紀律交易" :NSLocalizedStringFromTable(@"紀律交易", @"Launcher", nil) imageSize:NAN];
    seven.translatesAutoresizingMaskIntoConstraints = NO;
    seven.tag = 7;
    [seven addGestureRecognizer:tap7];
    [self.view addSubview:seven];
    
    eight = [[UnitCell alloc] initWithCell:@"部位管理" :NSLocalizedStringFromTable(@"部位管理", @"Launcher", nil) imageSize:NAN];
    eight.translatesAutoresizingMaskIntoConstraints = NO;
    eight.tag = 8;
    [eight addGestureRecognizer:tap8];
    [self.view addSubview:eight];
    
    nine = [[UnitCell alloc] initWithCell:@"交易日記" :NSLocalizedStringFromTable(@"交易日記", @"Launcher", nil) imageSize:NAN];
    nine.translatesAutoresizingMaskIntoConstraints = NO;
    nine.tag = 9;
    [nine addGestureRecognizer:tap9];
    [self.view addSubview:nine];
}

-(void)updateViewConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(one, two, three, four, five, six, seven, eight, nine);
    
    NSNumber *ww1 = [[NSNumber alloc] initWithInt:80];
    NSNumber *wwForOneItem = [[NSNumber alloc] initWithFloat:(self.view.frame.size.width - 80)/ 2];
    NSNumber *wwForTwoItems = [[NSNumber alloc] initWithFloat:(self.view.frame.size.width - 160)/3];
    NSNumber *wwForThreeItems = [[NSNumber alloc] initWithFloat:(self.view.frame.size.width - 240)/4];
    //ww2 是畫面只有一個東西的時候用的 -> 不過只剩一個東西的時候不用置中，所以應該是不需要用到ww2 的
    //ww3 是畫面有兩個東西的時候用的
    //ww4 是畫面有三個東西的時候用的
    
    NSDictionary *metrics = @{@"ww1":ww1,@"ww2":wwForOneItem,@"ww3":wwForTwoItems,@"ww4":wwForThreeItems};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[one]-(ww3)-[two]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww4)-[three]-(ww4)-[four]-(ww4)-[five]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[six]-(ww3)-[seven]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[eight]-(ww3)-[nine]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[one]-10-[three]-10-[six]-10-[eight]" options:0 metrics:metrics views:allObj]];
    
    [super updateViewConstraints];
}

-(void)tapHandler:(UITapGestureRecognizer *)sender
{
    NSInteger theTag = sender.view.tag;
    UIViewController *viewController = nil;
    switch(theTag){
        case 1:
        {
            if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
                return;
            }
            viewController = [[EODTargetController alloc] init];
            break;
        }
        case 2:
            if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
                return;
            }
            viewController = [[EODActionController alloc] init];
            break;
        case 3:
        {
            
            viewController = [[FigureSearchViewController alloc] init];
            break;
        }
        case 4:
        {
            viewController = [[MyFigureSearchViewController alloc] init];
            break;
        }
        case 5:
        {
            viewController = [[TrackPatternsViewController alloc] init];
            break;
        }
        case 6:
        {
            viewController = [[FSWatchlistViewController alloc] init];
        }
            break;
        case 7:
            viewController = [[FSActionAlertViewController alloc] init];
            break;
        case 8:
            viewController = [[FSPositionManagementViewController alloc] init];
            break;
        case 9:
            viewController = [[FSDiaryViewController alloc] init];
            break;
            
        default:
            break;
    }
    
    if (viewController == nil) return;
    
    if (self.parentViewController != nil) {
        [self.parentViewController.navigationController pushViewController:viewController animated:NO];
    } else {
        [self.navigationController pushViewController:viewController animated:NO];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
//    if(popFullAdFlag){
//        [gad_interstitial presentFromRootViewController:self.navigationController];
//        popFullAdFlag = NO;
//        [self popGoogleFullAd];
//    }
}

//- (void)popGoogleFullAd {
//    gad_interstitial = [[GADInterstitial alloc] init];
//    gad_interstitial.delegate = self;
//    gad_interstitial.adUnitID = @"ca-app-pub-4455304471526605/2340677577";  // Pattern Power iOS 插頁廣告
//    [gad_interstitial loadRequest:[GADRequest request]];
//}
//
//- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
//    popFullAdFlag = YES;
//}

@end
