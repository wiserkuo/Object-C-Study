//
//  UnitView.m
//  PutUIViewInScrollView
//
//  Created by CooperLin on 2014/10/28.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import "UnitView.h"
#import "FSLauncherCustomizeAnalysisViewController.h"
#import "FSLauncherCustomizeNewsViewController.h"
#import "FSLauncherCustomizeDerivativeViewController.h"
#import "FSLauncherCustomizeDecisionViewController.h"
#import "FSLauncherCustomizeServiceViewController.h"
#import "FSLauncherCustomizeInfoViewController.h"

#define ONLY_BACKGROUND 1
#define WITH_LEFT_IMAGE 2
#define WITH_TOP_IMAGE 3
#define SPECIALIZE_AUTOLAYOUT 4

@implementation UnitView{
    NSInteger itemSize;
    NSInteger counts;
    NSInteger whichImgShouldDisplay;
    UITapGestureRecognizer *tapper;
    UITapGestureRecognizer *tapper1;
    UITapGestureRecognizer *tapper2;
    UIImageView *whiteLine;
    BOOL isLastOrNot;
}

-(void)initStuff
{
    whichImgShouldDisplay = 0;
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tapper1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tapper2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    _backgroundImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4"]];
    _backgroundImg.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundImg.userInteractionEnabled = YES;
    [self addSubview:_backgroundImg];
}

-(id)initWithEmptyView:(NSMutableArray *)forItem :(NSMutableArray *)forLabel :(NSInteger)tag :(id)target
{
    self = [super init];
    counts = forItem.count==forLabel.count?counts=forItem.count:0;
    if(self && counts != 0){
        itemSize = 80;
        self.tag = tag;
        [self initStuff];
        targetObj = target;
        whichImgShouldDisplay = ONLY_BACKGROUND;
        [self initItemAndLabel:forItem :forLabel];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(id)initWithLeftImageView:(NSMutableArray *)forItem :(NSMutableArray *)forLabel :(NSInteger)tag :(NSString *)inLeftImg :(id)target
{
    self = [super init];
    counts = forItem.count == forLabel.count? counts = forItem.count : 0;
    if(self && counts != 0){
        itemSize = 70;
        self.tag = tag;
        [self initStuff];
        targetObj = target;
        _leftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3"]];
        _leftImg.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftImg];
        _inLeftImg = [[UILabel alloc] init];
        _inLeftImg.text = inLeftImg;
        _inLeftImg.textColor = [UIColor whiteColor];
        _inLeftImg.numberOfLines = 0;
        _inLeftImg.font = [UIFont boldSystemFontOfSize:16.0];
        _inLeftImg.translatesAutoresizingMaskIntoConstraints = NO;
        [_leftImg addSubview:_inLeftImg];
        whichImgShouldDisplay = WITH_LEFT_IMAGE;
        [self initItemAndLabel:forItem :forLabel];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(id)initWithTopImageView:(NSMutableArray *)forItem :(NSMutableArray *)forLabel :(NSInteger)tag :(NSString *)inTopImg :(id)target
{
    self = [super init];
    counts = forItem.count == forLabel.count? counts = forItem.count : 0;
    if(self && counts != 0){
        itemSize = 70;
        self.tag = tag;
        [self initStuff];
        targetObj = target;
        _topImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1"]];
        _topImg.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_topImg];
        _inTopImg = [[UILabel alloc] init];
        _inTopImg.text = inTopImg;
        _inTopImg.textColor = [UIColor whiteColor];
        _inTopImg.font = [UIFont boldSystemFontOfSize:18.0];
        _inTopImg.translatesAutoresizingMaskIntoConstraints = NO;
        [_topImg addSubview:_inTopImg];
        whichImgShouldDisplay = WITH_TOP_IMAGE;
        [self initItemAndLabel:forItem :forLabel];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(id)initWithSpecialize:(NSString *)forItem :(NSInteger)tag :(NSString *)inLeftImg :(id)target
{
    self = [super init];
    if(self){
        itemSize = 80;
        self.tag = tag;
        [self initStuff];
        targetObj = target;
        _leftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3"]];
        _leftImg.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_leftImg];
        _inLeftImg = [[UILabel alloc] init];
        _inLeftImg.text = inLeftImg;
        _inLeftImg.textColor = [UIColor whiteColor];
        _inLeftImg.numberOfLines = 0;
        _inLeftImg.font = [UIFont boldSystemFontOfSize:16.0];
        _inLeftImg.translatesAutoresizingMaskIntoConstraints = NO;
        [_leftImg addSubview:_inLeftImg];
        whichImgShouldDisplay = SPECIALIZE_AUTOLAYOUT;
        _item1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",forItem]]];
        _item1.translatesAutoresizingMaskIntoConstraints = NO;
        _item1.userInteractionEnabled = YES;
        _item1.tag = 1;
        [_item1 addGestureRecognizer:tapper2];
        [_backgroundImg addSubview:_item1];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(void)tapHandler:(id)sender
{
    if([targetObj isKindOfClass:[FSLauncherCustomizeServiceViewController class]]){
        FSLauncherCustomizeServiceViewController *viewc = (FSLauncherCustomizeServiceViewController *)targetObj;
        [viewc tapOccurred:self.tag :sender];
    }
    if([targetObj isKindOfClass:[FSLauncherCustomizeNewsViewController class]]){
        FSLauncherCustomizeNewsViewController *viewc = (FSLauncherCustomizeNewsViewController *)targetObj;
        [viewc tapOccurred:self.tag :sender];
    }
    if([targetObj isKindOfClass:[FSLauncherCustomizeDerivativeViewController class]]){
        FSLauncherCustomizeDerivativeViewController *viewc = (FSLauncherCustomizeDerivativeViewController *)targetObj;
        [viewc tapOccurred:self.tag :sender];
    }
    if([targetObj isKindOfClass:[FSLauncherCustomizeDecisionViewController class]]){
        FSLauncherCustomizeDecisionViewController *viewc = (FSLauncherCustomizeDecisionViewController *)targetObj;
        [viewc tapOccurred:self.tag :sender];
    }
    if([targetObj isKindOfClass:[FSLauncherCustomizeServiceViewController class]]){
        FSLauncherCustomizeServiceViewController *viewc = (FSLauncherCustomizeServiceViewController *)targetObj;
        [viewc tapOccurred:self.tag :sender];
    }
    if([targetObj isKindOfClass:[FSLauncherCustomizeAnalysisViewController class]]){
        FSLauncherCustomizeAnalysisViewController *viewc = (FSLauncherCustomizeAnalysisViewController *)targetObj;
        [viewc tapOccurred:self.tag :sender];
    }
    if([targetObj isKindOfClass:[FSLauncherCustomizeInfoViewController class]]){
        FSLauncherCustomizeInfoViewController *viewc = (FSLauncherCustomizeInfoViewController *)targetObj;
        [viewc tapOccurred:self.tag :sender];
    }
}

-(void)initItemAndLabel:(NSMutableArray *)forItem :(NSMutableArray *)forLabel
{
    switch(counts){
        case 3:
            _item3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[forItem lastObject]]]];
            _label3 = [[UILabel alloc] init];
            _label3.textColor = [UIColor whiteColor];
            _label3.text = [NSString stringWithFormat:@"%@",[forLabel lastObject]];
            _item3.translatesAutoresizingMaskIntoConstraints = NO;
            _label3.translatesAutoresizingMaskIntoConstraints = NO;
            _item3.userInteractionEnabled = YES;
            _item3.tag = 3;
            [_item3 addGestureRecognizer:tapper];
            [_backgroundImg addSubview:_item3];
            [_backgroundImg addSubview:_label3];
        case 2:
            _item2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[forItem objectAtIndex:1]]]];
            _label2 = [[UILabel alloc] init];
            _label2.textColor = [UIColor whiteColor];
            _label2.text = [NSString stringWithFormat:@"%@",[forLabel objectAtIndex:1]];
            _item2.translatesAutoresizingMaskIntoConstraints = NO;
            _label2.translatesAutoresizingMaskIntoConstraints = NO;
            _item2.userInteractionEnabled = YES;
            _item2.tag = 2;
            [_item2 addGestureRecognizer:tapper1];
            [_backgroundImg addSubview:_item2];
            [_backgroundImg addSubview:_label2];
        case 1:
            _item1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[forItem firstObject]]]];
            _label1 = [[UILabel alloc] init];
            _label1.textColor = [UIColor whiteColor];
            _label1.text = [NSString stringWithFormat:@"%@",[forLabel firstObject]];
            _item1.translatesAutoresizingMaskIntoConstraints = NO;
            _label1.translatesAutoresizingMaskIntoConstraints = NO;
            _item1.userInteractionEnabled = YES;
            _item1.tag = 1;
            [_item1 addGestureRecognizer:tapper2];
            [_backgroundImg addSubview:_item1];
            [_backgroundImg addSubview:_label1];
            break;
        default: break;
    }
}

-(void)updateConstraints
{
    [self removeConstraints:self.constraints];
    
    NSNumber *ww1 = [[NSNumber alloc] initWithInt:itemSize];
    NSNumber *wwForOneItem = [[NSNumber alloc] initWithFloat:((self.window.frame.size.width - itemSize)/ 2 + 30)];
    NSNumber *ww2down = [[NSNumber alloc] initWithFloat:(self.window.frame.size.width - itemSize - 50)/ 2];
    NSNumber *wwForTwoItems = [[NSNumber alloc] initWithFloat:(self.window.frame.size.width - itemSize*2)/3];
    NSNumber *wwForThreeItems = [[NSNumber alloc] initWithFloat:(self.window.frame.size.width - itemSize*3)/4];
    NSNumber *toTheTop = [[NSNumber alloc] initWithFloat:5.0];
    NSNumber *ww3down = [[NSNumber alloc] initWithFloat:(self.window.frame.size.width - itemSize*2+33)/3 - itemSize/3];
    NSNumber *ww4down = [[NSNumber alloc] initWithFloat:(self.window.frame.size.width - itemSize*3+33)/4 - itemSize/4];
    NSNumber *forTopImg = [[NSNumber alloc] initWithFloat:35.0];
    NSNumber *sss = [[NSNumber alloc] initWithFloat:-10.0];
    NSNumber *ems = [[NSNumber alloc] initWithFloat:-8.0];
    //ww2 是畫面只有一個東西的時候用的
    //ww3 是畫面有兩個東西的時候用的
    //ww4 是畫面有三個東西的時候用的
    
    NSDictionary *metrics = @{@"ww1":ww1, @"ww2":wwForOneItem, @"ww3":wwForTwoItems, @"ww4":wwForThreeItems, @"toTheEdge":toTheTop, @"ww3down":ww3down, @"ww4down":ww4down, @"forTop":forTopImg, @"sss":sss, @"topEdge":toTheTop, @"ww2down":ww2down, @"ems":ems};
    
    switch(whichImgShouldDisplay){
        case ONLY_BACKGROUND:
        {
            switch(counts){
                case 3: [self doAutoLayout3:metrics]; break;
                case 2: [self doAutoLayout2:metrics]; break;
                case 1: [self doAutoLayout1:metrics]; break;
                default: break;
            }
            break;
        }
        case WITH_LEFT_IMAGE:
        {
            switch(counts){
                case 3: [self doAutoLayoutWithLeft3:metrics]; break;
                case 2: [self doAutoLayoutWithLeft2:metrics]; break;
                case 1: [self doAutoLayoutWithLeft1:metrics]; break;
                default: break;
            }
            break;
        }
        case WITH_TOP_IMAGE:
        {
            switch(counts){
                case 3: [self doAutoLayoutWithTop3:metrics]; break;
                case 2: [self doAutoLayoutWithTop2:metrics]; break;
                case 1: [self doAutoLayoutWithTop1:metrics]; break;
                default: break;
            }
            break;
        }
        case SPECIALIZE_AUTOLAYOUT:
        {
            [self doSpecializeAutoLayout:metrics]; break;
        }
        default: break;
    }
    [super updateConstraints];
}

#pragma mark autoLayout for background only

-(void)doAutoLayout3:(NSDictionary *)metrics
{
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _item2, _item3, _label1, _label2, _label3, _backgroundImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww4)-[_item1(ww1)]-(ww4)-[_item2(_item1)]-(ww4)-[_item3(_item1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item1(ww1)]-(ems)-[_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item2(_item1)]-(ems)-[_label2(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item3(_item1)]-(ems)-[_label3(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
}

-(void)doAutoLayout2:(NSDictionary *)metrics
{
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _item2, _label1, _label2, _backgroundImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[_item1(ww1)]-(ww3)-[_item2(_item1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item1(ww1)]-(ems)-[_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item2(_item1)]-(ems)-[_label2(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
}

-(void)doAutoLayout1:(NSDictionary *)metrics
{
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _label1, _backgroundImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[_item1(ww1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item1(ww1)]-(ems)-[_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
}

#pragma mark autoLayout with left image

-(void)doAutoLayoutWithLeft3:(NSDictionary *)metrics
{
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _item2, _item3, _label1, _label2, _label3, _backgroundImg, _leftImg, _inLeftImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftImg(30)][_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww4down)-[_item1(ww1)]-(ww4down)-[_item2(_item1)]-(ww4down)-[_item3(_item1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(toTheEdge)-[_item1(ww1)]-(sss)-[_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(toTheEdge)-[_item2(_item1)]-(sss)-[_label2(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(toTheEdge)-[_item3(_item1)]-(sss)-[_label3(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[_inLeftImg]" options:0 metrics:nil views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_inLeftImg(80)]" options:0 metrics:nil views:allObj]];
}

-(void)doAutoLayoutWithLeft2:(NSDictionary *)metrics
{
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _item2, _label1, _label2, _backgroundImg, _leftImg, _inLeftImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftImg(30)][_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3down)-[_item1(ww1)]-(ww3down)-[_item2(_item1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(toTheEdge)-[_item1(ww1)]-(sss)-[_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(toTheEdge)-[_item2(_item1)]-(sss)-[_label2(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[_inLeftImg]" options:0 metrics:nil views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_inLeftImg(80)]" options:0 metrics:nil views:allObj]];
}

-(void)doAutoLayoutWithLeft1:(NSDictionary *)metrics
{
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _label1, _backgroundImg, _leftImg, _inLeftImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftImg(30)][_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww2down)-[_item1(ww1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(toTheEdge)-[_item1(ww1)]-(sss)-[_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[_inLeftImg]" options:0 metrics:nil views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_inLeftImg(80)]" options:0 metrics:nil views:allObj]];
}

#pragma mark autoLayout with top image

-(void)doAutoLayoutWithTop3:(NSDictionary *)metrics
{
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _item2, _item3, _label1, _label2, _label3, _backgroundImg, _topImg, _inTopImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topImg(25)][_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww4)-[_item1(ww1)]-(ww4)-[_item2(_item1)]-(ww4)-[_item3(_item1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item1(ww1)][_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item2(_item1)][_label2(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item3(_item1)][_label3(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_topImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(forTop)-[_inTopImg]" options:0 metrics:metrics views:allObj]];
    [_topImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(sss)-[_inTopImg(forTop)]" options:0 metrics:metrics views:allObj]];
}

-(void)doAutoLayoutWithTop2:(NSDictionary *)metrics
{
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _item2, _label1, _label2, _backgroundImg, _topImg, _inTopImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topImg(25)][_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[_item1(ww1)]-(ww3)-[_item2(_item1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item1(ww1)][_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item2(_item1)][_label2(_label1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_topImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(forTop)-[_inTopImg]" options:0 metrics:metrics views:allObj]];
    [_topImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(sss)-[_inTopImg(forTop)]" options:0 metrics:metrics views:allObj]];
}

-(void)doAutoLayoutWithTop1:(NSDictionary *)metrics
{
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _label1, _backgroundImg, _topImg, _inTopImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_topImg(25)][_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww3)-[_item1(ww1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topEdge)-[_item1(ww1)][_label1(35)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_topImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(forTop)-[_inTopImg]" options:0 metrics:metrics views:allObj]];
    [_topImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(sss)-[_inTopImg(forTop)]" options:0 metrics:metrics views:allObj]];
}

#pragma mark specialize autoLayout for only one item

-(void)doSpecializeAutoLayout:(NSDictionary *)metrics
{
    NSDictionary *allObj = NSDictionaryOfVariableBindings(_item1, _backgroundImg, _leftImg, _inLeftImg);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftImg(30)][_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImg]|" options:0 metrics:nil views:allObj]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftImg]|" options:0 metrics:nil views:allObj]];
    
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(ww2down)-[_item1(ww1)]" options:0 metrics:metrics views:allObj]];
    [_backgroundImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_item1(ww1)]" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[_inLeftImg]" options:0 metrics:nil views:allObj]];
    [_leftImg addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_inLeftImg(80)]" options:0 metrics:nil views:allObj]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
