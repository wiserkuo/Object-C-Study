//
//  FSLauncherCustomizeViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherCustomizeNewsViewController.h"
#import "UnitView.h"

@interface FSLauncherCustomizeNewsViewController ()

@end

@implementation FSLauncherCustomizeNewsViewController{
    UnitView *one;
    UnitView *two;
    UnitView *three;
    
    UIImageView *wl12;
    UIImageView *wl23;
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
    self.title = NSLocalizedStringFromTable(@"新聞訊息", @"CustomizeUnitView", nil);
    
    NSMutableArray *forOneImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"財經新聞", @"即時新聞", nil];
    one = [[UnitView alloc] initWithLeftImageView:forOneImgAndLabelArray :forOneImgAndLabelArray :21 :@"新\n\n聞" :self];
    one.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:one];
    
    NSMutableArray *forTwoImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"氣象概況", @"彩券發票", nil];
    two = [[UnitView alloc] initWithLeftImageView:forTwoImgAndLabelArray :forTwoImgAndLabelArray :22 :@"生\n活\n資\n訊" :self];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:two];
    
    NSMutableArray *forThreeImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"理財行事曆", @"特殊狀態", nil];
    three = [[UnitView alloc] initWithLeftImageView:forThreeImgAndLabelArray :forThreeImgAndLabelArray :23 :@"個\n股\n消\n息" :self];
    three.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:three];
    
    wl12 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl12.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:wl12];
    wl23 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteLine"]];
    wl23.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:wl23];
    
}

-(void)updateViewConstraints
{
//    [self.view removeConstraints:self.view.constraints];
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(one, two, three, wl12, wl23);
 
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[one(100)]-3-[wl12(2)]-3-[two(one)]-3-[wl23(2)]-3-[three(one)]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[one]-3-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[two]-3-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[three]-3-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl12]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl23]|" options:0 metrics:nil views:allObj]];
    
//    [super updateViewConstraints];
    [self replaceCustomizeConstraints:constraints];
}

-(void)tapOccurred:(NSInteger)viewNum :(UITapGestureRecognizer *)something
{
    NSInteger itemNum = something.view.tag;
    UIViewController *viewController = nil;
    if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
        return;
    }
    switch(viewNum){
        case 21:
            if(itemNum == 1){
                NSLog(@"財金新聞");
                viewController = nil;
            }else{
                NSLog(@"一般新聞");
                viewController = nil;
            }
            break;
        case 22:
            if(itemNum == 1){
                NSLog(@"氣象概況");
                viewController = nil;
            }else{
                NSLog(@"彩券發票");
                viewController = nil;
            }
            break;
        case 23:
            if(itemNum == 1){
                NSLog(@"理財行事曆");
                viewController = nil;
            }else{
                NSLog(@"特殊狀態");
                viewController = nil;
            }
            break;
        case 24:
            if(itemNum == 1){
                NSLog(@"Empty");
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
