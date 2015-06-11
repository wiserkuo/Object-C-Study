//
//  FSNewMainRightViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/12/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSNewMainRightViewController.h"
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
#import "FSLauncherConfigureViewController.h"
#import "TQuoteViewController.h"

#define IS_IPAD [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound
//因為螢幕尺寸的問題，所以用這個常數來判斷開啟的裝置是否為ipad 系列裝置
//這頁內容只有刻畫面及各個項目的點擊事件

@interface FSNewMainRightViewController ()<UIScrollViewDelegate>{
    UIScrollView *sclView;
    
    UIView *baseView;
    
    UITapGestureRecognizer *rec;
    UITapGestureRecognizer *tar;
    UITapGestureRecognizer *myp;
    UITapGestureRecognizer *cus;
    UITapGestureRecognizer *pat;
    UITapGestureRecognizer *tra;
    UITapGestureRecognizer *tim;
    UITapGestureRecognizer *pos;
    UITapGestureRecognizer *dia;
    
    UnitCell *recommand;
    UnitCell *targetPattern;
    UnitCell *myPattern;
    UnitCell *customize;
    UnitCell *patternTrack;
    UnitCell *trade;
    UnitCell *timing;
    UnitCell *position;
    UnitCell *diary;
    
    UIImageView *arrow1;
    UIImageView *arrow2;
    UIImageView *arrow3;
    UIImageView *arrow4;
    UIImageView *arrow5;
    UIImageView *arrow6;
    UIImageView *arrow7;
    UIImageView *arrow8;
    
    CGFloat beginOffset;
    CGFloat endOffset;
    
    CGRect baseViewRect;
    CGRect recommandRect;
    CGRect targetRect;
    CGRect myPatternRect;
    CGRect myChoiceRect;
    CGRect patternRect;
    CGRect traderRect;
    CGRect timingRect;
    CGRect positionRect;
    CGRect diaryRect;
    NSInteger unitCellHeight;
    NSInteger unitCellWidth;
    NSInteger imageSize;
    CGRect ar1;
    CGRect ar2;
    CGRect ar3;
    CGRect ar4;
    CGRect ar5;
    CGRect ar6;
    CGRect ar7;
    CGRect ar8;
}

@end

@implementation FSNewMainRightViewController

- (void)viewDidLoad {
    [self getTheDeviceSize];
    [self initView];
    // Do any additional setup after loading the view.
//    [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"登入中", @"AccountSetting", nil)];
    [super viewDidLoad];
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

#pragma mark a better way to moves scrollView
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    endOffset = scrollView.contentOffset.y;
    
    if(beginOffset == endOffset)
        return;
    
    if(beginOffset == 0){
        [sclView setContentOffset:CGPointMake(0, 100) animated:YES];
    }else if(beginOffset == 100){
        [sclView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    beginOffset = scrollView.contentOffset.y;
}

-(void)getTheDeviceSize
{
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if(self.view.frame.size.width < 375){
        baseViewRect = CGRectMake(0, 0, 320, 530);
        unitCellHeight = 113;
        unitCellWidth = 80;
        imageSize = 80;
        recommandRect = CGRectMake(62, 1, unitCellWidth, unitCellHeight);
        targetRect = CGRectMake(186, 1, unitCellWidth, unitCellHeight);
        myPatternRect = CGRectMake(15, 129, unitCellWidth, unitCellHeight);
        myChoiceRect = CGRectMake(122, 129, unitCellWidth, unitCellHeight);
        if([group isEqualToString:@"us"])
            patternRect = CGRectMake(230, 129, 80, 133);
        else
            patternRect = CGRectMake(230, 129, unitCellWidth, unitCellHeight);
        traderRect = CGRectMake(62, 254, unitCellWidth, unitCellHeight);
        timingRect = CGRectMake(186, 254, unitCellWidth, unitCellHeight);
        positionRect = CGRectMake(62, 381, unitCellWidth, unitCellHeight);
        diaryRect = CGRectMake(186, 381, unitCellWidth, unitCellHeight);
        ar1 = CGRectMake(116, 107, 27, 26);
        ar2 = CGRectMake(185, 107, 27, 26);
        ar3 = CGRectMake(100, 159, 20, 16);
        ar4 = CGRectMake(205, 159, 21, 15);
        ar5 = CGRectMake(149, 286, 31, 19);
        ar6 = CGRectMake(92, 359, 21, 23);
        ar7 = CGRectMake(99, 230, 27, 26);
        ar8 = CGRectMake(148, 335, 50, 50);
    }else if(self.view.frame.size.width == 375){
        //尚未更新iphone6 的長、寬（需留最下面18pt 的長度）
        baseViewRect = CGRectMake(0, 0, 375, 530);
        unitCellHeight = 128;
        unitCellWidth = 95;
        imageSize = 95;
        recommandRect = CGRectMake(70, 5, unitCellWidth, unitCellHeight);
        targetRect = CGRectMake(211, 5, unitCellWidth, unitCellHeight);
        myPatternRect = CGRectMake(16, 155, unitCellWidth, unitCellHeight);
        myChoiceRect = CGRectMake(141, 155, unitCellWidth, unitCellHeight);
        if([group isEqualToString:@"us"])
            patternRect = CGRectMake(265, 155, unitCellWidth, 148);
        else
            patternRect = CGRectMake(265, 155, unitCellWidth, unitCellHeight);
        traderRect = CGRectMake(70, 305, unitCellWidth, unitCellHeight);
        timingRect = CGRectMake(211, 305, unitCellWidth, unitCellHeight);
        positionRect = CGRectMake(70, 460, unitCellWidth, unitCellHeight);
        diaryRect = CGRectMake(211, 460, unitCellWidth, unitCellHeight);
        ar1 = CGRectMake(130, 130, 27, 26);
        ar2 = CGRectMake(220, 130, 27, 26);
        ar3 = CGRectMake(115, 200, 20, 16);
        ar4 = CGRectMake(238, 200, 21, 15);
        ar5 = CGRectMake(170, 340, 31, 19);
        ar6 = CGRectMake(110, 430, 21, 29);
        ar7 = CGRectMake(125, 280, 27, 26);
        ar8 = CGRectMake(165, 400, 50, 50);
    }
}

-(void)initView
{
    baseView = [[UIView alloc] initWithFrame:baseViewRect];
    
    sclView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    sclView.userInteractionEnabled = YES;
    sclView.directionalLockEnabled = YES;
    sclView.showsHorizontalScrollIndicator = NO;
    sclView.showsVerticalScrollIndicator = NO;
    sclView.pagingEnabled = YES;
    sclView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //一定要有frame ，才讓autoreiszing 可以依比例放大、縮小
    if(IS_IPAD){
        sclView.contentSize = CGSizeMake(baseView.frame.size.width, self.view.frame.size.height + 100);
    }else{
        sclView.contentSize = CGSizeMake(baseView.frame.size.width, baseView.frame.size.height);
    }
    sclView.bounces = NO;
    sclView.delegate = self;
    [sclView addSubview:baseView];
    [self.view addSubview:sclView];
    
    
    rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    recommand = [[UnitCell alloc] initWithCell:@"推薦股票" :NSLocalizedStringFromTable(@"推薦股票", @"Launcher", nil) imageSize:imageSize];
    [recommand setFrame:recommandRect];
    recommand.userInteractionEnabled = YES;
    [recommand addGestureRecognizer:rec];
    recommand.tag = 1;
    [baseView addSubview:recommand];
    
    tar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    targetPattern = [[UnitCell alloc] initWithCell:@"標竿型態" :NSLocalizedStringFromTable(@"標竿型態", @"Launcher", nil) imageSize:imageSize];
    [targetPattern setFrame:targetRect];
    targetPattern.userInteractionEnabled = YES;
    [targetPattern addGestureRecognizer:tar];
    targetPattern.tag = 2;
    [baseView addSubview:targetPattern];
    
    myp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    myPattern = [[UnitCell alloc ]initWithCell:@"我的型態" :NSLocalizedStringFromTable(@"我的型態", @"Launcher", nil) imageSize:imageSize];
    [myPattern setFrame:myPatternRect];
    myPattern.userInteractionEnabled = YES;
    [myPattern addGestureRecognizer:myp];
    myPattern.tag = 3;
    [baseView addSubview:myPattern];
    
    cus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    customize = [[UnitCell alloc] initWithCell:@"我的自選" :NSLocalizedStringFromTable(@"我的自選", @"Launcher", nil) imageSize:imageSize];
    [customize setFrame:myChoiceRect];
    customize.userInteractionEnabled = YES;
    [customize addGestureRecognizer:cus];
    customize.tag = 4;
    [baseView addSubview:customize];
    
    pat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    patternTrack = [[UnitCell alloc] initWithCell:@"新的型態追蹤" :NSLocalizedStringFromTable(@"型態追蹤", @"Launcher", nil) imageSize:imageSize];
    [patternTrack setFrame:patternRect];
    patternTrack.userInteractionEnabled = YES;
    [patternTrack addGestureRecognizer:pat];
    patternTrack.tag = 5;
    [baseView addSubview:patternTrack];
    
    tra = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    trade = [[UnitCell alloc] initWithCell:@"交易警示" :NSLocalizedStringFromTable(@"交易警示", @"Launcher", nil) imageSize:imageSize];
    [trade setFrame:traderRect];
    trade.userInteractionEnabled = YES;
    [trade addGestureRecognizer:tra];
    trade.tag = 6;
    [baseView addSubview:trade];
    
    tim = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    timing = [[UnitCell alloc] initWithCell:@"新的時機健診" :NSLocalizedStringFromTable(@"時機健診", @"Launcher", nil) imageSize:imageSize];
    [timing setFrame:timingRect];
    timing.userInteractionEnabled = YES;
    [timing addGestureRecognizer:tim];
    timing.tag = 7;
    [baseView addSubview:timing];
    
    pos = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    position = [[UnitCell alloc] initWithCell:@"部位風險" :NSLocalizedStringFromTable(@"部位風險", @"Launcher", nil) imageSize:imageSize];
    [position setFrame:positionRect];
    position.userInteractionEnabled = YES;
    [position addGestureRecognizer:pos];
    position.tag = 8;
    [baseView addSubview:position];
    
    dia = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    diary = [[UnitCell alloc] initWithCell:@"績效日記" :NSLocalizedStringFromTable(@"績效日記", @"Launcher", nil) imageSize:imageSize];
    [diary setFrame:diaryRect];
    diary.userInteractionEnabled = YES;
    [diary addGestureRecognizer:dia];
    diary.tag = 9;
    [baseView addSubview:diary];
    
    arrow1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"右斜箭"]];
    [arrow1 setFrame:ar1];
    [baseView addSubview:arrow1];
    
    arrow2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"左斜箭"]];
    [arrow2 setFrame:ar2];
    [baseView addSubview:arrow2];
    
    arrow3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"右箭"]];
    [arrow3 setFrame:ar3];
    [baseView addSubview:arrow3];
    
    arrow4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"一個給圖是利用的左箭"]];
    [arrow4 setFrame:ar4];
    [baseView addSubview:arrow4];
    
    arrow5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"雙箭"]];
    [arrow5 setFrame:ar5];
    [baseView addSubview:arrow5];
    
    arrow6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"下箭"]];
    [arrow6 setFrame:ar6];
    [baseView addSubview:arrow6];
    
    arrow7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"左斜箭"]];
    [arrow7 setFrame:ar7];
    [baseView addSubview:arrow7];
    
    arrow8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"長右斜箭"]];
    [arrow8 setFrame:ar8];
    [baseView addSubview:arrow8];
}

-(void)tapHandler:(UITapGestureRecognizer *)sender
{
    int theTag = (int)sender.view.tag;
    [[[FSDataModelProc sharedInstance] fonestock] setTarget:(FSLauncherPageViewController*)self.parentViewController];
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
//            if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
//                return;
//            }
            //            viewController = [[EODActionController alloc] init];
            viewController = [[FigureSearchViewController alloc] init];
            break;
        case 3:
        {
            if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
                return;
            }
            viewController = [[MyFigureSearchViewController alloc] init];
            break;
        }
        case 4:
        {
            viewController = [[FSWatchlistViewController alloc] init];
            //            viewController = [[MyFigureSearchViewController alloc] init];
            break;
        }
        case 5:
        {
            viewController = [[TrackPatternsViewController alloc] init];
            break;
        }
        case 6:
        {
            //            viewController = [[FSWatchlistViewController alloc] init];
            viewController = [[FSActionAlertViewController alloc] init];
            break;
        }
        case 7:
            if (![[FSFonestock sharedInstance] checkPermission:FSPermissionTypeEODNewTarget showAlertViewToShopping:YES]) {
                return;
            }
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
