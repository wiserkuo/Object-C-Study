//
//  FSStoryBoardLeftViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/12/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSStoryBoardLeftViewController.h"
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
#import "FSLauncherConfigureViewController.h"

@interface FSStoryBoardLeftViewController ()

@end

@implementation FSStoryBoardLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

-(void)initView
{
    UIButton *serviceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [serviceButton setImage:[UIImage imageNamed:@"Macroeconomic"] forState:UIControlStateNormal];
    [serviceButton addTarget:self action:@selector(rightTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *serviceBarButton = [[UIBarButtonItem alloc] initWithCustomView:serviceButton];
    self.navigationItem.rightBarButtonItem = serviceBarButton;
    
    _sclView.userInteractionEnabled = YES;
    _sclView.directionalLockEnabled = YES;
    _sclView.bounces = NO;
    _sclView.pagingEnabled = YES;
    _sclView.showsHorizontalScrollIndicator = NO;
    _sclView.showsVerticalScrollIndicator = NO;
    _sclView.contentSize = CGSizeMake(self.view.frame.size.width * 2, 500);
    
    self.title = @"圖是力";
    self.navigationItem.hidesBackButton = YES;
    UIColor *backgroundColor = [UIColor colorWithRed:102.0f/255 green:145.0f/255 blue:1.0f/255 alpha:1.0];
    [self.view setBackgroundColor:backgroundColor];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img1.userInteractionEnabled = YES;
    _img1.tag = 1;
    [_img1 addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img2.userInteractionEnabled = YES;
    _img2.tag = 2;
    [_img2 addGestureRecognizer:tap2];
    
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img3.userInteractionEnabled = YES;
    _img3.tag = 3;
    [_img3 addGestureRecognizer:tap3];
    
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img4.userInteractionEnabled = YES;
    _img4.tag = 4;
    [_img4 addGestureRecognizer:tap4];
    
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img5.userInteractionEnabled = YES;
    _img5.tag = 5;
    [_img5 addGestureRecognizer:tap5];
    
    UITapGestureRecognizer *tap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img6.userInteractionEnabled = YES;
    _img6.tag = 6;
    [_img6 addGestureRecognizer:tap6];
    
    UITapGestureRecognizer *tap7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img7.userInteractionEnabled = YES;
    _img7.tag = 7;
    [_img7 addGestureRecognizer:tap7];
    
    UITapGestureRecognizer *tap8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img8.userInteractionEnabled = YES;
    _img8.tag = 8;
    [_img8 addGestureRecognizer:tap8];
    
    UITapGestureRecognizer *tap9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img9.userInteractionEnabled = YES;
    _img9.tag = 9;
    [_img9 addGestureRecognizer:tap9];
    
    //右邊的頁面
    
    UITapGestureRecognizer *tap11 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img11.userInteractionEnabled = YES;
    _img11.tag = 1;
    [_img11 addGestureRecognizer:tap11];
    
    UITapGestureRecognizer *tap12 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img12.userInteractionEnabled = YES;
    _img12.tag = 2;
    [_img12 addGestureRecognizer:tap12];
    
    UITapGestureRecognizer *tap13 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img13.userInteractionEnabled = YES;
    _img13.tag = 3;
    [_img13 addGestureRecognizer:tap13];
    
    UITapGestureRecognizer *tap14 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img14.userInteractionEnabled = YES;
    _img14.tag = 4;
    [_img14 addGestureRecognizer:tap14];
    
    UITapGestureRecognizer *tap15 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img15.userInteractionEnabled = YES;
    _img15.tag = 5;
    [_img15 addGestureRecognizer:tap15];
    
    UITapGestureRecognizer *tap16 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img16.userInteractionEnabled = YES;
    _img16.tag = 6;
    [_img16 addGestureRecognizer:tap16];
    
    UITapGestureRecognizer *tap17 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img17.userInteractionEnabled = YES;
    _img17.tag = 7;
    [_img17 addGestureRecognizer:tap17];
    
    UITapGestureRecognizer *tap18 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img18.userInteractionEnabled = YES;
    _img18.tag = 8;
    [_img18 addGestureRecognizer:tap18];
    
    UITapGestureRecognizer *tap19 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _img19.userInteractionEnabled = YES;
    _img19.tag = 9;
    [_img19 addGestureRecognizer:tap19];
}

//-(BOOL)shouldAutorotate
//{
//    return NO;
//}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationLandscapeRight;
//}
//
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
            viewController = [[FigureSearchViewController alloc] init];
            break;
        case 3:
        {
            viewController = [[MyFigureSearchViewController alloc] init];
            break;
        }
        case 4:
        {
            viewController = [[FSWatchlistViewController alloc] init];
            break;
        }
        case 5:
        {
            viewController = [[TrackPatternsViewController alloc] init];
            break;
        }
        case 6:
        {
            viewController = [[FSActionAlertViewController alloc] init];
            break;
        }
        case 7:
            viewController = [[EODActionController alloc] init];
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

    [self.navigationController pushViewController:viewController animated:NO];
}

- (void)rightTapped:(id)sender {
    [self.navigationController pushViewController:[[FSLauncherConfigureViewController alloc] init] animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
