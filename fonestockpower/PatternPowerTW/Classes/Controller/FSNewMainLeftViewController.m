//
//  FSNewMainLeftViewController.m
//  FonestockPower
//
//  Created by CooperLin on 2014/12/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSNewMainLeftViewController.h"
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

#define IS_IPAD [[[UIDevice currentDevice] model] rangeOfString:@"iPad"].location != NSNotFound
//因為螢幕尺寸的問題，所以用這個常數來判斷開啟的裝置是否為ipad 系列裝置
//這頁內容只有刻畫面及各個項目的點擊事件

@interface FSNewMainLeftViewController ()<UIScrollViewDelegate>{
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
    
    UIImageView *whiteLine1;
    UIImageView *whiteLine2;
    
    UILabel *findStock;
    UILabel *findPoint;
    UILabel *profitAnalysis;
    UILabel *addLook;
    UILabel *addBuy;
    
    UIImageView *top;
    UIImageView *mid;
    UIImageView *bottom;
    
    UILabel *one;
    UILabel *two;
    UILabel *three;
    UILabel *four;
    UILabel *five;
    UILabel *six;
    UILabel *seven;
    UILabel *eight;
    UILabel *nine;
    
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
    CGRect wl1Rect;
    CGRect wl2Rect;
    CGRect topGreen;
    CGRect midGreen;
    CGRect bottomGreen;
    CGRect fStockRect;
    CGRect fPointRect;
    CGRect pAnalysisRect;
    UIFont *greenTextSize;
    CGRect addLookRect;
    CGRect addBuyRect;
    UIFont *otherTextSize;
    CGRect rect1;
    CGRect rect2;
    CGRect rect3;
    CGRect rect4;
    CGRect rect5;
    CGRect rect6;
    CGRect rect7;
    CGRect rect8;
    CGRect rect9;
}

@end

@implementation FSNewMainLeftViewController

- (void)viewDidLoad {
    [self getTheDeviceSize];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initView];
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

#pragma mark a better way to move scrollView
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
        recommandRect = CGRectMake(82, 1, unitCellWidth, unitCellHeight);
        targetRect = CGRectMake(196, 1, unitCellWidth, unitCellHeight);
        myPatternRect = CGRectMake(38, 129, unitCellWidth, unitCellHeight);
        myChoiceRect = CGRectMake(134, 129, unitCellWidth, unitCellHeight);
        traderRect = CGRectMake(82, 254, unitCellWidth, unitCellHeight);
        timingRect = CGRectMake(196, 254, unitCellWidth, unitCellHeight);
        positionRect = CGRectMake(82, 381, unitCellWidth, unitCellHeight);
        diaryRect = CGRectMake(196, 381, unitCellWidth, unitCellHeight);
        ar1 = CGRectMake(131, 107, 27, 26);
        ar2 = CGRectMake(190, 107, 27, 26);
        ar3 = CGRectMake(119, 159, 14, 16);
        ar4 = CGRectMake(215, 159, 15, 15);
        ar5 = CGRectMake(164, 286, 31, 19);
        ar6 = CGRectMake(112, 359, 21, 23);
        ar7 = CGRectMake(115, 230, 25, 26);
        ar8 = CGRectMake(163, 335, 50, 50);
        wl1Rect = CGRectMake(0, 242, 320, 1);
        wl2Rect = CGRectMake(0, 370, 320, 1);
        topGreen = CGRectMake(0, 0, 35, 235);
        midGreen = CGRectMake(0, 248, 35, 118);
        bottomGreen = CGRectMake(0, 377, 35, 131);
        greenTextSize = [UIFont boldSystemFontOfSize:20.0f];
        addLookRect = CGRectMake(42, 11, 17, 120);
        addBuyRect = CGRectMake(42, 244, 17, 124);
        otherTextSize = [UIFont systemFontOfSize:14.0f];
        rect1 = CGRectMake(6, 1, 68, 80);
        rect2 = CGRectMake(0, 6, 83, 69);
        rect3 = CGRectMake(0, 6, 83, 69);
        rect4 = CGRectMake(0, 6, 83, 69);
        rect5 = CGRectMake(0, 6, 83, 69);
        rect6 = CGRectMake(-1, 10, 83, 69);
        rect7 = CGRectMake(-1, 10, 83, 69);
        rect8 = CGRectMake(0, 6, 83, 69);
        rect9 = CGRectMake(0, 6, 83, 69);
        if([group isEqualToString:@"us"]){
            patternRect = CGRectMake(230, 129, unitCellWidth, 133);
            fStockRect = CGRectMake(-60, 100, 151, 22);
            fPointRect = CGRectMake(-37, 300, 107, 22);
            pAnalysisRect = CGRectMake(-35, 430, 107, 22);
        }
        else{
            patternRect = CGRectMake(230, 129, unitCellWidth, unitCellHeight);
            fStockRect = CGRectMake(6, 48, 22, 151);
            fPointRect = CGRectMake(6, 222, 22, 151);
            pAnalysisRect = CGRectMake(6, 378, 22, 107);
        }
        
    }else if(self.view.frame.size.width == 375){
        //尚未更新iphone6 的長、寬（需留最下面18pt 的長度）
        baseViewRect = CGRectMake(0, 0, 375, 530);
        unitCellHeight = 128;
        unitCellWidth = 95;
        imageSize = 95;
        recommandRect = CGRectMake(90, 5, unitCellWidth, unitCellHeight);
        targetRect = CGRectMake(226, 5, unitCellWidth, unitCellHeight);
        myPatternRect = CGRectMake(41, 155, unitCellWidth, unitCellHeight);
        myChoiceRect = CGRectMake(156, 155, unitCellWidth, unitCellHeight);
        if([group isEqualToString:@"us"])
            patternRect = CGRectMake(275, 155, unitCellWidth, 148);
        else
            patternRect = CGRectMake(275, 155, unitCellWidth, unitCellHeight);
        traderRect = CGRectMake(90, 305, unitCellWidth, unitCellHeight);
        timingRect = CGRectMake(226, 305, unitCellWidth, unitCellHeight);
        positionRect = CGRectMake(90, 460, unitCellWidth, unitCellHeight);
        diaryRect = CGRectMake(226, 460, unitCellWidth, unitCellHeight);
        ar1 = CGRectMake(148, 130, 27, 26);
        ar2 = CGRectMake(220, 130, 27, 26);
        ar3 = CGRectMake(136, 197, 20, 16);
        ar4 = CGRectMake(250, 200, 21, 15);
        ar5 = CGRectMake(190, 340, 31, 19);
        ar6 = CGRectMake(130, 430, 21, 29);
        ar7 = CGRectMake(135, 280, 27, 26);
        ar8 = CGRectMake(180, 420, 50, 50);
        wl1Rect = CGRectMake(0, 290, 375, 1);
        wl2Rect = CGRectMake(0, 445, 375, 1);
        topGreen = CGRectMake(0, 0, 35, 285);
        midGreen = CGRectMake(0, 295, 35, 145);
        bottomGreen = CGRectMake(0, 455, 35, 150);
        greenTextSize = [UIFont boldSystemFontOfSize:25.0f];
        addLookRect = CGRectMake(42, 3, 17, 160);
        addBuyRect = CGRectMake(42, 285, 17, 160);
        otherTextSize = [UIFont systemFontOfSize:16.0f];
        rect1 = CGRectMake(13, 7, 68, 80);
        rect2 = CGRectMake(5, 15, 83, 69);
        rect3 = CGRectMake(5, 15, 83, 69);
        rect4 = CGRectMake(5, 15, 83, 69);
        rect5 = CGRectMake(5, 15, 83, 69);
        rect6 = CGRectMake(5, 15, 83, 69);
        rect7 = CGRectMake(5, 15, 83, 69);
        rect8 = CGRectMake(5, 15, 83, 69);
        rect9 = CGRectMake(5, 15, 83, 69);
        if([group isEqualToString:@"us"]){
            patternRect = CGRectMake(275, 155, unitCellWidth, 148);
            [findStock setFrame:CGRectMake(-60, 100, 151, 22)];
            [findPoint setFrame:CGRectMake(-37, 300, 107, 22)];
            [profitAnalysis setFrame:CGRectMake(-35, 430, 107, 22)];
        }
        else{
            patternRect = CGRectMake(275, 155, unitCellWidth, unitCellHeight);
            fStockRect = CGRectMake(0, 50, 35, 150);
            fPointRect = CGRectMake(0, 285, 35, 150);
            pAnalysisRect = CGRectMake(0, 445, 35, 150);
        }
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
    sclView.bounces = NO;
    sclView.delegate = self;
    sclView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //一定要有frame ，才讓autoreiszing 可以依比例放大、縮小
    if(IS_IPAD){
        sclView.contentSize = CGSizeMake(baseView.frame.size.width, self.view.frame.size.height + 100);
    }else{
        sclView.contentSize = CGSizeMake(baseView.frame.size.width, baseView.frame.size.height);
    }
    
    [sclView addSubview:baseView];
    [self.view addSubview:sclView];
    
    rec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    recommand = [[UnitCell alloc] initWithCell:@"紅球" :NSLocalizedStringFromTable(@"推薦股票", @"Launcher", nil) imageSize:imageSize];
    [recommand setFrame:recommandRect];
    recommand.userInteractionEnabled = YES;
    [recommand addGestureRecognizer:rec];
    recommand.tag = 1;
    [baseView addSubview:recommand];
    
    tar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    targetPattern = [[UnitCell alloc] initWithCell:@"紅球" :NSLocalizedStringFromTable(@"標竿型態", @"Launcher", nil) imageSize:imageSize];
    [targetPattern setFrame:targetRect];
    targetPattern.userInteractionEnabled = YES;
    [targetPattern addGestureRecognizer:tar];
    targetPattern.tag = 2;
    [baseView addSubview:targetPattern];
    
    myp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    myPattern = [[UnitCell alloc ]initWithCell:@"紅球" :NSLocalizedStringFromTable(@"我的型態", @"Launcher", nil) imageSize:imageSize];
    [myPattern setFrame:myPatternRect];
    myPattern.userInteractionEnabled = YES;
    [myPattern addGestureRecognizer:myp];
    myPattern.tag = 3;
    [baseView addSubview:myPattern];
    
    cus = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    customize = [[UnitCell alloc] initWithCell:@"黃球" :NSLocalizedStringFromTable(@"我的自選", @"Launcher", nil) imageSize:imageSize];
    [customize setFrame:myChoiceRect];
    customize.userInteractionEnabled = YES;
    [customize addGestureRecognizer:cus];
    customize.tag = 4;
    [baseView addSubview:customize];
    
    pat = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    patternTrack = [[UnitCell alloc] initWithCell:@"紅球" :NSLocalizedStringFromTable(@"型態追蹤", @"Launcher", nil) imageSize:imageSize];
    [patternTrack setFrame:patternRect];
    patternTrack.userInteractionEnabled = YES;
    [patternTrack addGestureRecognizer:pat];
    patternTrack.tag = 5;
    [baseView addSubview:patternTrack];
    
    whiteLine1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"白色線條"]];
    [whiteLine1 setFrame:wl1Rect];
    [baseView addSubview:whiteLine1];
    
    tra = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    trade = [[UnitCell alloc] initWithCell:@"綠球+" :NSLocalizedStringFromTable(@"交易警示", @"Launcher", nil) imageSize:imageSize];
    [trade setFrame:traderRect];
    trade.userInteractionEnabled = YES;
    [trade addGestureRecognizer:tra];
    trade.tag = 6;
    [baseView addSubview:trade];
    
    tim = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    timing = [[UnitCell alloc] initWithCell:@"粉紅球" :NSLocalizedStringFromTable(@"時機健診", @"Launcher", nil) imageSize:imageSize];
    [timing setFrame:timingRect];
    timing.userInteractionEnabled = YES;
    [timing addGestureRecognizer:tim];
    timing.tag = 7;
    [baseView addSubview:timing];
    
    whiteLine2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"白色線條"]];
    [whiteLine2 setFrame:wl2Rect];
    [baseView addSubview:whiteLine2];
    
    pos = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    position = [[UnitCell alloc] initWithCell:@"綠球" :NSLocalizedStringFromTable(@"部位風險", @"Launcher", nil) imageSize:imageSize];
    [position setFrame:positionRect];
    position.userInteractionEnabled = YES;
    [position addGestureRecognizer:pos];
    position.tag = 8;
    [baseView addSubview:position];
    
    dia = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    diary = [[UnitCell alloc] initWithCell:@"綠球" :NSLocalizedStringFromTable(@"績效日記", @"Launcher", nil) imageSize:imageSize];
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
    
    [baseView bringSubviewToFront:whiteLine1];
    [baseView bringSubviewToFront:whiteLine2];
    
    top = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"小綠棒"]];
    [top setFrame:topGreen];
    [baseView addSubview:top];
    
    mid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"小綠棒"]];
    [mid setFrame:midGreen];
    [baseView addSubview:mid];
    
    bottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"小綠棒"]];
    [bottom setFrame:bottomGreen];
    [baseView addSubview:bottom];
    
    CGAffineTransform aff = CGAffineTransformMakeRotation(0.0);
#ifdef PatternPowerUS
    aff = CGAffineTransformMakeRotation((M_PI)/2);
#endif
    findStock = [[UILabel alloc] init];
    //    findStock.text = @"找\n\n股\n\n票";
    findStock.text = NSLocalizedStringFromTable(@"找股票", @"Launcher", nil);
    findStock.numberOfLines = 0;
    [findStock setFrame:fStockRect];
    findStock.font = greenTextSize;
    findStock.textAlignment = NSTextAlignmentCenter;
    findStock.textColor = [UIColor whiteColor];
    findStock.transform = aff;
    [baseView addSubview:findStock];
    
    findPoint = [[UILabel alloc] init];
    //    findPoint.text = @"找\n買\n賣\n點";
    findPoint.text = NSLocalizedStringFromTable(@"找買賣點", @"Launcher", nil);
    [findPoint setFrame:fPointRect];
    findPoint.numberOfLines = 0;
    findPoint.font = greenTextSize;
    findPoint.textAlignment = NSTextAlignmentCenter;
    findPoint.textColor = [UIColor whiteColor];
    findPoint.transform = aff;
    [baseView addSubview:findPoint];
    
    profitAnalysis = [[UILabel alloc] init];
    //    profitAnalysis.text = @"獲\n利\n分\n析";
    [profitAnalysis setFrame:pAnalysisRect];
    profitAnalysis.text = NSLocalizedStringFromTable(@"獲利分析", @"Launcher", nil);
    profitAnalysis.numberOfLines = 0;
    profitAnalysis.font = greenTextSize;
    profitAnalysis.textAlignment = NSTextAlignmentCenter;
    profitAnalysis.textColor = [UIColor whiteColor];
    profitAnalysis.transform = aff;
    [baseView addSubview:profitAnalysis];
    
    addLook = [[UILabel alloc] initWithFrame:addLookRect];
    //    addLook.text = @"加\n入\n想\n看\n的\n股\n票";
    addLook.text = NSLocalizedStringFromTable(@"加入想看的股票", @"Launcher", nil);
    addLook.numberOfLines = 0;
    addLook.font = otherTextSize;
    addLook.textAlignment = NSTextAlignmentCenter;
    addLook.textColor = [UIColor whiteColor];
    [baseView addSubview:addLook];
    
    addBuy = [[UILabel alloc] initWithFrame:addBuyRect];
    //    addBuy.text = @"加\n入\n想\n買\n的\n股\n票";
    addBuy.text = NSLocalizedStringFromTable(@"加入想買的股票", @"Launcher", nil);
    addBuy.numberOfLines = 0;
    addBuy.font = otherTextSize;
    addBuy.textAlignment = NSTextAlignmentCenter;
    addBuy.textColor = [UIColor whiteColor];
    [baseView addSubview:addBuy];
    
    one = [[UILabel alloc] initWithFrame:rect1];
    //    one.text = @"哪些股票\n達到\n轉折型態";
    one.text = NSLocalizedStringFromTable(@"哪些股票達到轉折型態", @"Launcher", nil);
    one.textAlignment = NSTextAlignmentCenter;
    one.numberOfLines = 0;
    one.font = otherTextSize;
    [recommand addSubview:one];
    
    two = [[UILabel alloc] initWithFrame:rect2];
    //    two.text = @"搭配基本面\n選股";
    two.text = NSLocalizedStringFromTable(@"搭配基本面選股", @"Launcher", nil);
    two.textAlignment = NSTextAlignmentCenter;
    two.numberOfLines = 0;
    two.font = otherTextSize;
    [targetPattern addSubview:two];
    
    three = [[UILabel alloc] initWithFrame:rect3];
    //    three.text = @"個人自訂\n專屬型態";
    three.text = NSLocalizedStringFromTable(@"個人自訂專屬型態", @"Launcher", nil);
    three.textAlignment = NSTextAlignmentCenter;
    three.numberOfLines = 0;
    three.font = otherTextSize;
    [myPattern addSubview:three];
    
    four = [[UILabel alloc] initWithFrame:rect4];
    //    four.text = @"買賣標的\n研究分析";
    four.text = NSLocalizedStringFromTable(@"買賣標的研究分析", @"Launcher", nil);
    four.textAlignment = NSTextAlignmentCenter;
    four.numberOfLines = 0;
    four.font = otherTextSize;
    [customize addSubview:four];
    
    five = [[UILabel alloc] initWithFrame:rect5];
    //    five.text = @"追蹤型態\n有效性";
    five.text = NSLocalizedStringFromTable(@"追蹤型態有效性", @"Launcher", nil);
    five.textAlignment = NSTextAlignmentCenter;
    five.numberOfLines = 0;
    five.font = otherTextSize;
    [patternTrack addSubview:five];
    
    six = [[UILabel alloc] initWithFrame:rect6];
    //    six.text = @"條件設定\n即時警示\n進行交易";
    six.text = NSLocalizedStringFromTable(@"條件設定即時警示進行交易", @"Launcher", nil);
    six.textAlignment = NSTextAlignmentCenter;
    six.numberOfLines = 0;
    six.font = otherTextSize;
    [trade addSubview:six];
    
    seven = [[UILabel alloc] initWithFrame:rect7];
    //    seven.text = @"手中個股\n是否出現\n買賣訊號";
    seven.text = NSLocalizedStringFromTable(@"手中個股是否出現買賣訊號", @"Launcher", nil);
    seven.textAlignment = NSTextAlignmentCenter;
    seven.numberOfLines = 0;
    seven.font = otherTextSize;
    [timing addSubview:seven];
    
    eight = [[UILabel alloc] initWithFrame:rect8];
    //    eight.text = @"部位績效\n風險控管";
    eight.text = NSLocalizedStringFromTable(@"部位績效風險控管", @"Launcher", nil);
    eight.textAlignment = NSTextAlignmentCenter;
    eight.numberOfLines = 0;
    eight.font = otherTextSize;
    [position addSubview:eight];
    
    nine = [[UILabel alloc] initWithFrame:rect9];
    //    nine.text = @"交易紀錄\n檢討改進";
    nine.text = NSLocalizedStringFromTable(@"交易紀錄檢討改進", @"Launcher", nil);
    nine.textAlignment = NSTextAlignmentCenter;
    nine.numberOfLines = 0;
    nine.font = otherTextSize;
    [diary addSubview:nine];
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

