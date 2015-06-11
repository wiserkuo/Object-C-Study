//
//  FSLauncherCustomizeViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherCustomizeAnalysisViewController.h"
#import "UnitView.h"
//#import "FSMainBargainingChipViewController.h"
//#import "FSKPIRootViewController.h"
//#import "FSBrokerInAndOutListViewController.h"


#define EACH_CONTENT_HEIGHT 93

@interface FSLauncherCustomizeAnalysisViewController ()<UIScrollViewDelegate>

@end

@implementation FSLauncherCustomizeAnalysisViewController{
    UnitView *one;
    UnitView *two;
    UnitView *three;
    UnitView *four;
    UnitView *five;
    
    UIImageView *wl12;
    UIImageView *wl23;
    UIImageView *wl34;
    UIImageView *wl45;
    
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
    self.title = NSLocalizedStringFromTable(@"神乎分析", @"CustomizeUnitView", nil);
    
    theWidth = self.view.frame.size.width;
    
    sclView = [[UIScrollView alloc] init];
    sclView.directionalLockEnabled = YES;
    sclView.translatesAutoresizingMaskIntoConstraints = NO;
    sclView.userInteractionEnabled = YES;
    sclView.bounces = NO;
    [self.view addSubview:sclView];
    
    NSMutableArray *forOneImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"飆股密碼", @"板塊動態", @"個股查詢", nil];
    one = [[UnitView alloc] initWithLeftImageView:forOneImgAndLabelArray :forOneImgAndLabelArray :51 :@"看\n盤" :self];
    one.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:one];
    
    NSMutableArray *forTwoImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"選股精靈", @"程式選股",@"KPI選股", nil];
    two = [[UnitView alloc] initWithLeftImageView:forTwoImgAndLabelArray :forTwoImgAndLabelArray :52 :@"選\n股" :self];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:two];
    
    NSMutableArray *forThreeImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"我的指標", @"策略回測", nil];
    three = [[UnitView alloc] initWithLeftImageView:forThreeImgAndLabelArray :forThreeImgAndLabelArray :53 :@"技\n術" :self];
    three.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:three];
    
    NSMutableArray *forFourImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"主力籌碼", @"券商追蹤", nil];
    four = [[UnitView alloc] initWithLeftImageView:forFourImgAndLabelArray :forFourImgAndLabelArray :54 :@"籌\n碼" :self];
    four.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:four];
    
    NSMutableArray *forFiveImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"交易下單", nil];
    five = [[UnitView alloc] initWithLeftImageView:forFiveImgAndLabelArray :forFiveImgAndLabelArray :55 :@"下\n單" :self];
    five.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:five];
    
    wl12 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl12.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:wl12];
    wl23 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl23.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:wl23];
    wl34 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl34.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:wl34];
    wl45 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl45.translatesAutoresizingMaskIntoConstraints = NO;
    [sclView addSubview:wl45];

}

-(void)updateViewConstraints
{
//    [self.view removeConstraints:self.view.constraints];
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSNumber *contentHeight = [[NSNumber alloc] initWithInt:EACH_CONTENT_HEIGHT];
    NSNumber *contentWidth = [[NSNumber alloc] initWithInt:theWidth - 6];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(one, two, three, four, five,sclView, wl12, wl23, wl34, wl45);
    NSDictionary *metrics = @{@"contentHeight":contentHeight, @"contentWidth":contentWidth};
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sclView]-20-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sclView]|" options:0 metrics:nil views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[one(contentHeight)]-1-[wl12(2)]-1-[two(one)]-1-[wl23(2)]-1-[three(one)]-1-[wl34(2)]-1-[four(one)]-1-[wl45(2)]-1-[five(one)]" options:0 metrics:metrics views:allObj]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[one(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[two(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[three(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[four(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[five(contentWidth)]-3-|" options:0 metrics:metrics views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl12]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl23]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl34]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl45]|" options:0 metrics:nil views:allObj]];
//    [super updateViewConstraints];
    [self replaceCustomizeConstraints:constraints];
}

-(void)viewDidLayoutSubviews
{
    [sclView setContentSize:CGSizeMake(theWidth,EACH_CONTENT_HEIGHT*5+50)];
}

-(void)tapOccurred:(NSInteger)viewNum :(UITapGestureRecognizer *)something
{
    NSInteger itemNum = something.view.tag;
    UIViewController *viewController = nil;
//    if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
//        return;
//    }
    switch(viewNum){
        case 51:
            if(itemNum == 1){
                NSLog(@"飆股密碼");
                viewController = nil;
            }else if(itemNum == 2){
                NSLog(@"板塊動態");
                viewController = nil;
            }else{
                NSLog(@"個股查詢");
                viewController = nil;
            }
            break;
        case 52:
            if(itemNum == 1){
                NSLog(@"選股精靈");
                viewController = nil;
            }else if(itemNum == 2){
                NSLog(@"程式選股");
                viewController = nil;
            }else{
                NSLog(@"KPI選股");
                viewController = [[NSClassFromString(@"FSKPIRootViewController") alloc] init];;
            }
            break;
        case 53:
            if(itemNum == 1){
                NSLog(@"我的指標");
                viewController = nil;
            }else{
                NSLog(@"策略回測");
                viewController = nil;
            }
            break;
        case 54:
            if(itemNum == 1){
                NSLog(@"主力籌碼");
                viewController = [[NSClassFromString(@"FSMainBargainingChipViewController") alloc]init];
            }else{
                NSLog(@"券商追蹤");
                viewController = [[NSClassFromString(@"FSBrokerInAndOutListViewController") alloc] init];
            }
            break;
        case 55:
            if(itemNum == 1){
                NSLog(@"交易下單");
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
