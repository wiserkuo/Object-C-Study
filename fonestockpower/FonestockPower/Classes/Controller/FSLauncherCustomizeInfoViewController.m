//
//  FSLauncherCustomizeViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/10/31.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherCustomizeInfoViewController.h"
#import "UnitView.h"
#import "MacroeconomicViewController.h"
#import "InternationalInfoForexViewController.h"
#import "InternationalInfoIndustryViewController.h"
#import "InternationalInfoMaterialViewController.h"
#import "IndexQuotesViewController.h"

@interface FSLauncherCustomizeInfoViewController ()

@end

@implementation FSLauncherCustomizeInfoViewController{
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
    self.title = NSLocalizedStringFromTable(@"神乎分析", @"CustomizeUnitView", nil);
    
    NSMutableArray *forOneImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"國際總經", @"國際競爭力", nil];
    one = [[UnitView alloc] initWithEmptyView:forOneImgAndLabelArray :forOneImgAndLabelArray :61 :self];
    one.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:one];
    
    NSMutableArray *forTwoImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"國際指數", @"外匯走勢", nil];
    two = [[UnitView alloc] initWithEmptyView:forTwoImgAndLabelArray :forTwoImgAndLabelArray :62 :self];
    two.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:two];
    
    NSMutableArray *forThreeImgAndLabelArray = [[NSMutableArray alloc] initWithObjects:@"國際期貨", nil];
    three = [[UnitView alloc] initWithEmptyView:forThreeImgAndLabelArray :forThreeImgAndLabelArray :63 :self];
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
    [super updateViewConstraints];
//    [self.view removeConstraints:self.view.constraints];
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(one, two, three, wl12, wl23);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[one(100)]-10-[wl12(2)]-10-[two(one)]-10-[wl23(2)]-10-[three(one)]" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[one]-3-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[two]-3-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[three]-3-|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl12]|" options:0 metrics:nil views:allObj]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wl23]|" options:0 metrics:nil views:allObj]];
    
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
        case 61:
            if(itemNum == 1){
                NSLog(@"總經分析");
                viewController = [[MacroeconomicViewController alloc] init];
            }else if(itemNum == 2){
                NSLog(@"國際競爭力");
                viewController = [[InternationalInfoIndustryViewController alloc] init];
            }
            break;
        case 62:
            if(itemNum == 1){
                NSLog(@"國際指數");
                viewController = [[IndexQuotesViewController alloc] init];
            }else if(itemNum == 2){
                NSLog(@"外匯走勢");
                viewController = [[InternationalInfoForexViewController alloc] init];
            }
            break;
        case 63:
            if(itemNum == 1){
                NSLog(@"國際期貨");
                viewController = [[InternationalInfoMaterialViewController alloc] init];
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
