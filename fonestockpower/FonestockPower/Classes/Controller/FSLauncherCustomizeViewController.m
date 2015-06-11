//
//  FSLauncherCustomizeViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherCustomizeViewController.h"
#import "UnitCell.h"
#import "EODTargetController.h"
#import "EODActionController.h"
#import "FigureSearchViewController.h"
#import "MyFigureSearchViewController.h"
#import "FSWatchlistViewController.h"
#import "FSActionAlertViewController.h"
#import "FSPositionManagementViewController.h"
#import "FSTradeDiaryViewController.h"
#import "TrackPatternsViewController.h"
#import "FutureViewController.h"


@interface FSLauncherCustomizeViewController ()<UIScrollViewDelegate>

@end

@implementation FSLauncherCustomizeViewController{
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
    
    UIScrollView *sclView;
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)initView
{
    self.title = NSLocalizedStringFromTable(@"newTitle", @"Launcher", nil);
    
    sclView = [[UIScrollView alloc] init];
    sclView.translatesAutoresizingMaskIntoConstraints = NO;
    sclView.directionalLockEnabled = YES;
    sclView.bounces = NO;
    sclView.userInteractionEnabled = YES;
    sclView.delegate = self;
    [self.view addSubview:sclView];
    
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
    [sclView addSubview:one];
    
    two = [[UnitCell alloc] initWithCell:@"時機健診" :NSLocalizedStringFromTable(@"時機健診", @"Launcher", nil) imageSize:NAN];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    two.tag = 2;
    [two addGestureRecognizer:tap2];
    [sclView addSubview:two];
    
    three = [[UnitCell alloc] initWithCell:@"標竿型態" :NSLocalizedStringFromTable(@"標竿型態", @"Launcher", nil) imageSize:NAN];
    three.translatesAutoresizingMaskIntoConstraints = NO;
    three.tag = 3;
    [three addGestureRecognizer:tap3];
    [sclView addSubview:three];
    
    four = [[UnitCell alloc] initWithCell:@"我的型態" :NSLocalizedStringFromTable(@"我的型態", @"Launcher", nil) imageSize:NAN];
    four.translatesAutoresizingMaskIntoConstraints = NO;
    four.tag = 4;
    [four addGestureRecognizer:tap4];
    [sclView addSubview:four];
    
    five = [[UnitCell alloc] initWithCell:@"型態追蹤" :NSLocalizedStringFromTable(@"型態追蹤", @"Launcher", nil) imageSize:NAN];
    five.translatesAutoresizingMaskIntoConstraints = NO;
    five.tag = 5;
    [five addGestureRecognizer:tap5];
    [sclView addSubview:five];
    
    six = [[UnitCell alloc] initWithCell:@"個股研究" :NSLocalizedStringFromTable(@"自選分析", @"Launcher", nil) imageSize:NAN];
    six.translatesAutoresizingMaskIntoConstraints = NO;
    six.tag = 6;
    [six addGestureRecognizer:tap6];
    [sclView addSubview:six];
    
    seven = [[UnitCell alloc] initWithCell:@"紀律交易" :NSLocalizedStringFromTable(@"紀律交易", @"Launcher", nil) imageSize:NAN];
    seven.translatesAutoresizingMaskIntoConstraints = NO;
    seven.tag = 7;
    [seven addGestureRecognizer:tap7];
    [sclView addSubview:seven];
    
    eight = [[UnitCell alloc] initWithCell:@"部位管理" :NSLocalizedStringFromTable(@"部位管理", @"Launcher", nil) imageSize:NAN];
    eight.translatesAutoresizingMaskIntoConstraints = NO;
    eight.tag = 8;
    [eight addGestureRecognizer:tap8];
    [sclView addSubview:eight];
    
    nine = [[UnitCell alloc] initWithCell:@"交易日記" :NSLocalizedStringFromTable(@"交易日記", @"Launcher", nil) imageSize:NAN];
    nine.translatesAutoresizingMaskIntoConstraints = NO;
    nine.tag = 9;
    [nine addGestureRecognizer:tap9];
    [sclView addSubview:nine];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
//    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(one, two, three, four, five, six, seven, eight, nine, sclView);
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSNumber *ww1 = [[NSNumber alloc] initWithInt:80];
    NSNumber *wwForOneItem = [[NSNumber alloc] initWithFloat:(self.view.frame.size.width - 80)/ 2];
    NSNumber *wwForTwoItems = [[NSNumber alloc] initWithFloat:(self.view.frame.size.width - 160)/3];
    NSNumber *wwForThreeItems = [[NSNumber alloc] initWithFloat:(self.view.frame.size.width - 240)/4];
    //ww2 是畫面只有一個東西的時候用的 -> 不過只剩一個東西的時候不用置中，所以應該是不需要用到ww2 的
    //ww3 是畫面有兩個東西的時候用的
    //ww4 是畫面有三個東西的時候用的
    
    NSDictionary *metrics = @{@"ww1":ww1,@"ww2":wwForOneItem,@"ww3":wwForTwoItems,@"ww4":wwForThreeItems};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sclView]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sclView]|" options:0 metrics:nil views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[one]-10-[three]-10-[six]-10-[eight]" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[one]-(ww3)-[two]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww4)-[three]-(ww4)-[four]-(ww4)-[five]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[six]-(ww3)-[seven]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[eight]-(ww3)-[nine]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:allObj]];
    
    [self replaceCustomizeConstraints:constraints];
}

-(void)viewDidLayoutSubviews
{
    [sclView setContentSize:CGSizeMake(self.view.frame.size.width, 500)];
}

-(void)tapHandler:(UITapGestureRecognizer *)sender
{
    int theTag = (int)sender.view.tag;
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
            viewController = [[FSTradeDiaryViewController alloc] init];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
