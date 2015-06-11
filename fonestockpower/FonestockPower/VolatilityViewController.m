//
//  VolatilityViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "VolatilityViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "VolatilityDrawTopView.h"
#import "VolatilityDrawBottomView.h"
@interface VolatilityViewController ()<UIScrollViewDelegate>
{
    FSUIButton *hvBtn;
    UILabel *hvLabel;
    FSUIButton *ivBtn;
    UILabel *ivLabel;
    FSUIButton *sivBtn;
    UILabel *sivLabel;
    FSUIButton *bivBtn;
    UILabel *bivLabel;
    FSUIButton *hv30Btn;
    UILabel *hv30Label;
    FSUIButton *hv60Btn;
    UILabel *hv60Label;
    FSUIButton *hv90Btn;
    UILabel *hv90Label;
    FSUIButton *hv120Btn;
    UILabel *hv120Label;
    
    UIScrollView *topScrollView;
    UIScrollView *bottomScrollView;
    UIView *topRightView;
    UIView *bottomRightView;
    
    
    NSMutableArray *layoutConstrains;
    FSDataModelProc *model;
    PortfolioItem *portfolioItem;
    NSMutableArray *drawArray;
    VolatilityDrawTopView *drawTopView;
    VolatilityDrawBottomView *drawBottomView;
    
    
    UILabel *rateLabel1;
    UILabel *rateLabel2;
    UILabel *rateLabel3;
    UILabel *rateLabel4;
    UILabel *rateLabel5;
    UILabel *rateLabel6;
    UILabel *rateLabel7;
    
    UILabel *volumeLabel1;
    UILabel *volumeLabel2;
    UILabel *volumeLabel3;
    
    UILabel *bottomTextLabel;
}
@end

@implementation VolatilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initModel];
    [self initView];
    [self.view setNeedsUpdateConstraints];
}

-(id)initWithViewHeight:(double)height
{
    if (self = [super init]) {

        self.viewHeight = height;
    }
    
    return self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    [model.warrant setTarget:self];
    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
    if(portfolioItem!=nil){
        [model.warrant sendWarrantHistoryData:portfolioItem->commodityNo queryType:1 dataCount:300];
    }
}

-(void)initView
{
    layoutConstrains = [[NSMutableArray alloc] init];
    
    hvBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
    [hvBtn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    hvBtn.selected = YES;
    hvBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hvBtn];
    
    hvLabel = [[UILabel alloc] init];
    hvLabel.text = NSLocalizedStringFromTable(@"HV", @"Warrant", nil);
    hvLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hvLabel];
    
    ivBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
    [ivBtn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    ivBtn.selected = YES;
    ivBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ivBtn];
    
    ivLabel = [[UILabel alloc] init];
    ivLabel.text = NSLocalizedStringFromTable(@"IV", @"Warrant", nil);
    ivLabel.textColor = [UIColor colorWithRed:253.0/255.0 green:210.0/255.0 blue:0 alpha:1];
    ivLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ivLabel];
    
    sivBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    [sivBtn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    sivBtn.selected = YES;
    sivBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sivBtn];
    
    sivLabel = [[UILabel alloc] init];
    sivLabel.text = NSLocalizedStringFromTable(@"SIV", @"Warrant", nil);
    sivLabel.textColor = [UIColor redColor];
    sivLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sivLabel];
    
    bivBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    [bivBtn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    bivBtn.selected = YES;
    bivBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bivBtn];
    
    bivLabel = [[UILabel alloc] init];
    bivLabel.text = NSLocalizedStringFromTable(@"BIV", @"Warrant", nil);
    bivLabel.textColor = [UIColor colorWithRed:242.0/255.0 green:0 blue:1 alpha:1];
    bivLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bivLabel];
    
    hv30Btn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    [hv30Btn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    hv30Btn.selected = YES;
    hv30Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv30Btn];
    
    hv30Label = [[UILabel alloc] init];
    hv30Label.text = @"30";
    hv30Label.textColor = [UIColor brownColor];
    hv30Label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv30Label];
    
    hv60Btn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    [hv60Btn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    hv60Btn.selected = YES;
    hv60Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv60Btn];
    
    hv60Label = [[UILabel alloc] init];
    hv60Label.text = @"60";
    hv60Label.textColor = [UIColor colorWithRed:122.0/255.0 green:193.0/255.0 blue:254.0/255.0 alpha:1];
    hv60Label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv60Label];
    
    hv90Btn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    [hv90Btn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    hv90Btn.selected = YES;
    hv90Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv90Btn];
    
    hv90Label = [[UILabel alloc] init];
    hv90Label.text = @"90";
    hv90Label.textColor = [UIColor colorWithRed:125.0/255.0 green:1 blue:0 alpha:1];
    hv90Label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv90Label];
    
    hv120Btn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeCheckBox];
    [hv120Btn addTarget:self action:@selector(BtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    hv120Btn.selected = YES;
    hv120Btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv120Btn];
    
    hv120Label = [[UILabel alloc] init];
    hv120Label.text = @"120";
    hv120Label.textColor = [UIColor colorWithRed:65.0/255.0 green:200.0/255.0 blue:0 alpha:1];
    hv120Label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hv120Label];
    
    topScrollView = [[UIScrollView alloc] init];
    topScrollView.delegate = self;
    topScrollView.layer.borderWidth = 0.5;
    topScrollView.bounces = NO;
    [topScrollView setShowsHorizontalScrollIndicator:NO];
    topScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topScrollView];
    
    topRightView = [[UIView alloc] init];
    topRightView.layer.borderWidth = 0.5;
    topRightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topRightView];
    
    bottomScrollView = [[UIScrollView alloc] init];
    bottomScrollView.delegate = self;
    bottomScrollView.layer.borderWidth = 0.5;
    bottomScrollView.bounces = NO;
    [bottomScrollView setShowsHorizontalScrollIndicator:NO];
    bottomScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomScrollView];
    
    bottomRightView = [[UIView alloc] init];
    bottomRightView.layer.borderWidth = 0.5;
    bottomRightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomRightView];
    
    
    drawTopView = [[VolatilityDrawTopView alloc] init];
    drawTopView.backgroundColor = [UIColor clearColor];
    drawTopView.hvFlag = hvBtn.selected;
    drawTopView.hv30Flag = hv30Btn.selected;
    drawTopView.hv60Flag = hv60Btn.selected;
    drawTopView.hv90Flag = hv90Btn.selected;
    drawTopView.hv120Flag = hv120Btn.selected;
    drawTopView.ivFlag = ivBtn.selected;
    drawTopView.sivFlag = sivBtn.selected;
    drawTopView.bivFlag = bivBtn.selected;
    drawTopView.backgroundColor = [UIColor clearColor];
    [topScrollView addSubview:drawTopView];
    
    drawBottomView = [[VolatilityDrawBottomView alloc] init];
    drawBottomView.backgroundColor = [UIColor clearColor];
    [bottomScrollView addSubview:drawBottomView];
    
    
    rateLabel1 = [[UILabel alloc] init];
    rateLabel1.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [topRightView addSubview:rateLabel1];
    rateLabel2 = [[UILabel alloc] init];
    rateLabel2.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [topRightView addSubview:rateLabel2];
    rateLabel3 = [[UILabel alloc] init];
    rateLabel3.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [topRightView addSubview:rateLabel3];
    rateLabel4 = [[UILabel alloc] init];
    rateLabel4.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [topRightView addSubview:rateLabel4];
    rateLabel5 = [[UILabel alloc] init];
    rateLabel5.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [topRightView addSubview:rateLabel5];
    rateLabel6 = [[UILabel alloc] init];
    rateLabel6.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [topRightView addSubview:rateLabel6];
    rateLabel7 = [[UILabel alloc] init];
    rateLabel7.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [topRightView addSubview:rateLabel7];
    
    volumeLabel1 = [[UILabel alloc] init];
    volumeLabel1.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [bottomRightView addSubview:volumeLabel1];
    
    volumeLabel2 = [[UILabel alloc] init];
    volumeLabel2.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [bottomRightView addSubview:volumeLabel2];
    
    volumeLabel3 = [[UILabel alloc] init];
    volumeLabel3.textColor = [UIColor colorWithRed:32.0/255.0 green:25.0/255.0 blue:168.0/255.0 alpha:1];
    [bottomRightView addSubview:volumeLabel3];
    
    bottomTextLabel = [[UILabel alloc] init];
    bottomTextLabel.adjustsFontSizeToFitWidth = YES;
    [bottomScrollView addSubview:bottomTextLabel];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view removeConstraints:layoutConstrains];
    
    [layoutConstrains removeAllObjects];
    NSDictionary *metrics = @{@"topViewWidth":@(self.view.frame.size.width-80),
                              @"bottomViewHeight":@(self.viewHeight/5)};
    if(hvBtn.selected){
        [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hvBtn(30)][hv30Btn(==hvBtn)][topScrollView][bottomScrollView(==bottomViewHeight)]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(hvBtn, hv30Btn, topScrollView, bottomScrollView)]];
        [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hv30Btn(30)][hv30Label(==hv30Btn)][hv60Btn(==hv30Btn)][hv60Label(==hv30Btn)][hv90Btn(==hv30Btn)][hv90Label(==hv30Btn)][hv120Btn(==hv30Btn)][hv120Label(==hv30Btn)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(hv30Btn, hv30Label, hv60Btn, hv60Label, hv90Btn, hv90Label, hv120Btn, hv120Label)]];
    }else{
        [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hvBtn(30)][topScrollView][bottomScrollView(==bottomViewHeight)]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(hvBtn, hv30Btn, topScrollView, bottomScrollView)]];
    }
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hvBtn(30)][hvLabel(==hvBtn)][ivBtn(==hvBtn)][ivLabel(==hvBtn)][sivBtn(==hvBtn)][sivLabel(==hvBtn)][bivBtn(==hvBtn)][bivLabel(==hvBtn)]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(hvBtn, hvLabel, ivBtn, ivLabel, sivBtn, sivLabel, bivBtn, bivLabel)]];
    
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topScrollView(==topViewWidth)][topRightView(80)]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:NSDictionaryOfVariableBindings(topScrollView, topRightView)]];
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomScrollView(==topViewWidth)][bottomRightView(80)]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:NSDictionaryOfVariableBindings(bottomScrollView, bottomRightView)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topRightView(==topScrollView)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(topRightView, topScrollView)]];
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomRightView(==bottomScrollView)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bottomRightView, bottomScrollView)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[ivBtn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(ivBtn)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hv30Btn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(hv30Btn)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sivBtn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(sivBtn)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hv60Btn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(hv60Btn)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sivBtn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(sivBtn)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hv90Btn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(hv90Btn)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bivBtn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(bivBtn)]];
    
    [layoutConstrains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hv120Btn(30)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(hv120Btn)]];
    
    [self.view addConstraints:layoutConstrains];
    
}

-(void)viewDidLayoutSubviews
{
    [self setRateLabelFrame];
    [self setVolumeLabelFrame];
    
    if([drawArray count] * 4 > topScrollView.frame.size.width){
        [topScrollView setContentSize:CGSizeMake([drawArray count]*4, topScrollView.frame.size.height)];
        [drawTopView setFrame:CGRectMake(topScrollView.contentSize.width - ([drawArray count]*4), 0, [drawArray count]*4, topScrollView.frame.size.height)];
    }else{
        [topScrollView setContentSize:CGSizeMake(topScrollView.frame.size.width, topScrollView.frame.size.height)];
        [drawTopView setFrame:CGRectMake(0, 0, topScrollView.frame.size.width, topScrollView.frame.size.height)];
    }
    
    [drawTopView setNeedsDisplay];
    
    
    if([drawArray count] * 4 > drawBottomView.frame.size.width){
        [bottomScrollView setContentSize:CGSizeMake([drawArray count]*4, bottomScrollView.frame.size.height)];
        [drawBottomView setFrame:CGRectMake(bottomScrollView.contentSize.width - ([drawArray count]*4), 0, [drawArray count]*4, bottomScrollView.frame.size.height)];
    }else{
        [bottomScrollView setContentSize:CGSizeMake(bottomScrollView.frame.size.width, bottomScrollView.frame.size.height)];
        [drawBottomView setFrame:CGRectMake(0, 0, bottomScrollView.frame.size.width, bottomScrollView.frame.size.height)];
    }

    [drawBottomView setNeedsDisplay];
}

-(void)BtnHandler:(FSUIButton *)sender
{
    if(sender.selected){
        sender.selected = NO;
    }else{
        sender.selected = YES;
    }
    if([sender isEqual:hvBtn]){
        [self.view setNeedsUpdateConstraints];
        if(sender.selected){
            hv30Btn.hidden = NO;
            hv30Label.hidden = NO;
            hv60Btn.hidden = NO;
            hv60Label.hidden = NO;
            hv90Btn.hidden = NO;
            hv90Label.hidden = NO;
            hv120Btn.hidden = NO;
            hv120Label.hidden = NO;
        }else{
            hv30Btn.hidden = YES;
            hv30Label.hidden = YES;
            hv60Btn.hidden = YES;
            hv60Label.hidden = YES;
            hv90Btn.hidden = YES;
            hv90Label.hidden = YES;
            hv120Btn.hidden = YES;
            hv120Label.hidden = YES;
        }
    }
    drawTopView.hvFlag = hvBtn.selected;
    drawTopView.hv30Flag = hv30Btn.selected;
    drawTopView.hv60Flag = hv60Btn.selected;
    drawTopView.hv90Flag = hv90Btn.selected;
    drawTopView.hv120Flag = hv120Btn.selected;
    drawTopView.ivFlag = ivBtn.selected;
    drawTopView.sivFlag = sivBtn.selected;
    drawTopView.bivFlag = bivBtn.selected;
    [drawTopView setNeedsDisplay];
    [self setRateLabelText];
    
}

-(void)notifyHistoryData:(NSMutableArray *)dataArray
{
    
    drawArray = dataArray;
    drawTopView.dataArray = dataArray;
    drawBottomView.dataArray = dataArray;
    
    if([drawArray count] * 4 > topScrollView.frame.size.width){
        [topScrollView setContentSize:CGSizeMake([drawArray count]*4, topScrollView.frame.size.height)];
        [drawTopView setFrame:CGRectMake(topScrollView.contentSize.width - ([drawArray count]*4), 0, [drawArray count]*4, topScrollView.frame.size.height)];
        topScrollView.contentOffset = CGPointMake(topScrollView.contentSize.width - topScrollView.frame.size.width, topScrollView.contentOffset.y);
    }else{
        [topScrollView setContentSize:CGSizeMake(topScrollView.frame.size.width, topScrollView.frame.size.height)];
        [drawTopView setFrame:CGRectMake(0, 0, topScrollView.frame.size.width, topScrollView.frame.size.height)];
    }
    
    if([drawArray count] * 4 > drawBottomView.frame.size.width){
        [bottomScrollView setContentSize:CGSizeMake([drawArray count]*4, bottomScrollView.frame.size.height)];
        [drawBottomView setFrame:CGRectMake(bottomScrollView.contentSize.width - ([drawArray count]*4), 0, [drawArray count]*4, bottomScrollView.frame.size.height)];
        bottomScrollView.contentOffset = CGPointMake(bottomScrollView.contentSize.width - bottomScrollView.frame.size.width, bottomScrollView.contentOffset.y);
    }else{
        [bottomScrollView setContentSize:CGSizeMake(bottomScrollView.frame.size.width, bottomScrollView.frame.size.height)];
        [drawBottomView setFrame:CGRectMake(0, 0, bottomScrollView.frame.size.width, bottomScrollView.frame.size.height)];
    }
    
    [self setRateLabelText];
    [self setVolumeLabelText];
    [drawTopView setNeedsDisplay];
    [drawBottomView setNeedsDisplay];
}

-(void)setRateLabelFrame
{
    [rateLabel1 setFrame:CGRectMake(3, 15, 80, 20)];
    [rateLabel2 setFrame:CGRectMake(3, 15 + (topRightView.frame.size.height-40) / 6 * 1, 80, 20)];
    [rateLabel3 setFrame:CGRectMake(3, 15 + (topRightView.frame.size.height-40) / 6 * 2, 80, 20)];
    [rateLabel4 setFrame:CGRectMake(3, 15 + (topRightView.frame.size.height-40) / 6 * 3, 80, 20)];
    [rateLabel5 setFrame:CGRectMake(3, 15 + (topRightView.frame.size.height-40) / 6 * 4, 80, 20)];
    [rateLabel6 setFrame:CGRectMake(3, 15 + (topRightView.frame.size.height-40) / 6 * 5, 80, 20)];
    [rateLabel7 setFrame:CGRectMake(3, 15 + (topRightView.frame.size.height-40) / 6 * 6, 80, 20)];
}

-(void)setVolumeLabelFrame
{
    [volumeLabel1 setFrame:CGRectMake(3, 15, 80, bottomRightView.frame.size.height - bottomRightView.frame.size.height/5*3)];
    [volumeLabel2 setFrame:CGRectMake(3, 15, 80, bottomRightView.frame.size.height - bottomRightView.frame.size.height/5*1)];
    [volumeLabel3 setFrame:CGRectMake(3, 15, 80, bottomRightView.frame.size.height + bottomRightView.frame.size.height/5*1)];
    
}

-(void)setRateLabelText
{
    double maxValue = -MAXFLOAT;
    double minValue = MAXFLOAT;
    for(int i =0; i<[drawArray count]; i++){
        HistoryObject *obj = [drawArray objectAtIndex:i];
        
        if(hvBtn.selected){
            if(hv30Btn.selected){
                maxValue = MAX(maxValue, obj.hv_30);
                minValue = MIN(minValue, obj.hv_30);
            }
            if(hv60Btn.selected){
                maxValue = MAX(maxValue, obj.hv_60);
                minValue = MIN(minValue, obj.hv_60);
            }
            if(hv90Btn.selected){
                maxValue = MAX(maxValue, obj.hv_90);
                minValue = MIN(minValue, obj.hv_90);
            }
            if(hv120Btn.selected){
                maxValue = MAX(maxValue, obj.hv_120);
                minValue = MIN(minValue, obj.hv_120);
            }
        }
        if(ivBtn.selected){
            maxValue = MAX(maxValue, obj.iv);
            minValue = MIN(minValue, obj.iv);
        }
        if(sivBtn.selected){
            maxValue = MAX(maxValue, obj.siv);
            minValue = MIN(minValue, obj.siv);
        }
        if(bivBtn.selected){
            maxValue = MAX(maxValue, obj.biv);
            minValue = MIN(minValue, obj.biv);
        }
    }
    
    double rateRang = (maxValue - minValue) / 6;
    
    if(hvBtn.selected || ivBtn.selected || sivBtn.selected || bivBtn.selected){
        rateLabel1.text = [self getText:maxValue * 100];
        rateLabel2.text = [self getText:(minValue + rateRang * 5) * 100];
        rateLabel3.text = [self getText:(minValue + rateRang * 4) * 100];
        rateLabel4.text = [self getText:(minValue + rateRang * 3) * 100];
        rateLabel5.text = [self getText:(minValue + rateRang * 2) * 100];
        rateLabel6.text = [self getText:(minValue + rateRang * 1) * 100];
        rateLabel7.text = [self getText:minValue * 100];
    }else{
        rateLabel1.text = @"";
        rateLabel2.text = @"";
        rateLabel3.text = @"";
        rateLabel4.text = @"";
        rateLabel5.text = @"";
        rateLabel6.text = @"";
        rateLabel7.text = @"";
    }
}

-(void)setVolumeLabelText
{
    int maxVolume = -MAXFLOAT;
    
    for(int i = 0; i<[drawArray count];i++){
        HistoryObject *obj = [drawArray objectAtIndex:i];
        maxVolume = MAX(maxVolume, obj.volume);
    }
    
    int volumeRange = maxVolume / 4;
    volumeLabel1.text = [NSString stringWithFormat:@"%d", maxVolume - volumeRange];
    volumeLabel2.text = [NSString stringWithFormat:@"%d", maxVolume - volumeRange * 2];
    volumeLabel3.text = [NSString stringWithFormat:@"%d", maxVolume - volumeRange * 3];
    bottomTextLabel.text = NSLocalizedStringFromTable(@"流通在外張數", @"Warrant", nil);
    [bottomTextLabel setFrame:CGRectMake(bottomScrollView.contentOffset.x, 0, 80, 15)];
}

-(NSString *)getText:(double)value
{
    if(value>0 ){
        return [NSString stringWithFormat:@"+%.1f%%", value];
    }else{
        return [NSString stringWithFormat:@"-%.1f%%", value];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    topScrollView.contentOffset = scrollView.contentOffset;
    bottomScrollView.contentOffset = scrollView.contentOffset;
    [bottomTextLabel setFrame:CGRectMake(bottomScrollView.contentOffset.x, 0, 80, 15)];
}
@end
