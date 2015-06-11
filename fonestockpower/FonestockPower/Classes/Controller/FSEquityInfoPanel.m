//
//  FSEquityInfoPanel.m
//  WirtsLeg
//
//  Created by KevinShen on 2013/11/29.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FSEquityInfoPanel.h"
#import "ValueUtil.h"
#import "BADataOut.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSBAIn.h"

@interface FSEquityInfoPanel ()
@property (nonatomic, strong) UILabel *epsTitleLabel;
@property (nonatomic, strong) UILabel *epsContentLabel;

@property (nonatomic, strong) UILabel *peTitleLabel;
@property (nonatomic, strong) UILabel *peContentLabel;

@property (nonatomic, strong) UILabel *lastTitleLabel;
@property (nonatomic, strong) UILabel *lastContentLabel;

@property (nonatomic, strong) UILabel *volTitleLabel;
@property (nonatomic, strong) UILabel *volContentLabel;

@property (nonatomic, strong) UILabel *chgTitleLabel;
@property (nonatomic, strong) UILabel *chgContentLabel;
@property (nonatomic, strong) UILabel *chgTitleLabel2;
@property (nonatomic, strong) UILabel *chgContentLabel2;

@property (nonatomic, strong) UILabel *chgpTitleLabel;
@property (nonatomic, strong) UILabel *chgpContentLabel;
@property (nonatomic, strong) UILabel *chgpTitleLabel2;
@property (nonatomic, strong) UILabel *chgpContentLabel2;

@property (nonatomic, strong) UILabel *openTitleLabel;
@property (nonatomic, strong) UILabel *openContentLabel;

@property (nonatomic, strong) UILabel *closeTitleLabel;
@property (nonatomic, strong) UILabel *closeContentLabel;

@property (nonatomic, strong) UILabel *highTitleLabel;
@property (nonatomic, strong) UILabel *highContentLabel;
@property (nonatomic, strong) UILabel *highTitleLabel2;
@property (nonatomic, strong) UILabel *highContentLabel2;

@property (nonatomic, strong) UILabel *lowTitleLabel;
@property (nonatomic, strong) UILabel *lowContentLabel;
@property (nonatomic, strong) UILabel *lowTitleLabel2;
@property (nonatomic, strong) UILabel *lowContentLabel2;

@property (nonatomic, strong) UILabel *todayVolTitleLabel;
@property (nonatomic, strong) UILabel *todayVolContentLabel;

@property (nonatomic, strong) UILabel *yesterdayVolTitleLabel;
@property (nonatomic, strong) UILabel *yesterdayVolContentLabel;

@property (nonatomic, strong) UILabel *week52HighTitleLabel;
@property (nonatomic, strong) UILabel *week52HighContentLabel;

@property (nonatomic, strong) UILabel *week52LowTitleLabel;
@property (nonatomic, strong) UILabel *week52LowContentLabel;

@property (nonatomic, strong) UILabel *volPTitleLabel;
@property (nonatomic, strong) UILabel *volPContentLabel;

@property (nonatomic, strong) UILabel *vol3MTitleLabel;
@property (nonatomic, strong) UILabel *vol3MContentLabel;

@property (nonatomic, strong) UILabel *bidTitleLabel;
@property (nonatomic, strong) UILabel *bidContentLabel;

@property (nonatomic, strong) UILabel *askTitleLabel;
@property (nonatomic, strong) UILabel *askContentLabel;

@property (nonatomic, strong) UILabel *chg2TitleLabel;
@property (nonatomic, strong) UILabel *chg2ContentLabel;

@property (nonatomic, strong) UILabel *todayVol2TitleLabel;
@property (nonatomic, strong) UILabel *todayVol2ContentLabel;

@property (nonatomic, strong) UILabel *divTitleLabel;
@property (nonatomic, strong) UILabel *divContentLabel;

@property (nonatomic, strong) UILabel *innerTitleLabel;
@property (nonatomic, strong) UILabel *innerContentLabel;

@property (nonatomic, strong) UILabel *outerTitleLabel;
@property (nonatomic, strong) UILabel *outerContentLabel;

@property (nonatomic, strong) UILabel *platTitleLabel;
@property (nonatomic, strong) UILabel *platContentLabel;

@property (nonatomic, strong) NSArray *titleStrings;
@property (nonatomic, strong) NSArray *labelIdentifiers;

@property (nonatomic, strong) UIView *page1;
@property (nonatomic, strong) UIView *page2;
@property (nonatomic, strong) UIView *page3;
@property (nonatomic, strong) UIView *page4;
@property (nonatomic, strong) UIView *page5;

@property (nonatomic, strong) UIView *sellView;
@property (nonatomic, strong) UIView *sellTitleView;
@property (nonatomic, strong) UIView *sellLabelView;
@property (nonatomic, strong) UIView *buyView;
@property (nonatomic, strong) UIView *buyTitleView;
@property (nonatomic, strong) UIView *buyLabelView;
@property (nonatomic, strong) UILabel *buyTitleTopLabel;
@property (nonatomic, strong) UILabel *buyTitleBottonLabel;
@property (nonatomic, strong) UILabel *sellTitleTopLabel;
@property (nonatomic, strong) UILabel *sellTitleBottonLabel;

@property (nonatomic, strong) UILabel *buyVolume1;
@property (nonatomic, strong) UILabel *buyVolume2;
@property (nonatomic, strong) UILabel *buyVolume3;
@property (nonatomic, strong) UILabel *buyPrice1;
@property (nonatomic, strong) UILabel *buyPrice2;
@property (nonatomic, strong) UILabel *buyPrice3;

@property (nonatomic, strong) UILabel *sellVolume1;
@property (nonatomic, strong) UILabel *sellVolume2;
@property (nonatomic, strong) UILabel *sellVolume3;
@property (nonatomic, strong) UILabel *sellPrice1;
@property (nonatomic, strong) UILabel *sellPrice2;
@property (nonatomic, strong) UILabel *sellPrice3;

@property (nonatomic, strong) UILabel *bidVolTitleLabel;
@property (nonatomic, strong) UILabel *bidVolLabel;

@property (nonatomic, strong) UILabel *askVolTitleLabel;
@property (nonatomic, strong) UILabel *askVolLabel;

@property (nonatomic, strong) UILabel *dealVolTitleLabel;
@property (nonatomic, strong) UILabel *dealVolLabel;

@property (nonatomic, strong) UILabel *bidPerVolTitleLabel;
@property (nonatomic, strong) UILabel *bidPerVolLabel;

@property (nonatomic, strong) UILabel *askPerVolTitleLabel;
@property (nonatomic, strong) UILabel *askPerVolLabel;

@property (nonatomic, strong) UILabel *dealPerVolTitleLabel;
@property (nonatomic, strong) UILabel *dealPerVolLabel;

@property (nonatomic, strong) UILabel *upTitleLabel;
@property (nonatomic, strong) UILabel *upLabel;

@property (nonatomic, strong) UILabel *downTitleLabel;
@property (nonatomic, strong) UILabel *downLabel;

@property (nonatomic, strong) UILabel *unchangedTitleLabel;
@property (nonatomic, strong) UILabel *unchangedLabel;

@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic) BOOL cleanFlag;
@end

@implementation FSEquityInfoPanel

- (id)init
{
    self = [super init];
    if (self) {
        //用來顯示Label的內容
        [self setupTitleStrings];
        //取property用的
        [self setupLabelIdentifiers];
        [self setup];
        
    }
    return self;
}

- (id)initWithPortfolioItem:(PortfolioItem*)aPortfolioItem
{
    self = [super init];
    if (self) {
        self.portfolioItem = aPortfolioItem;
        //用來顯示Label的內容
//        [self getBidAsk];
        [self setupTitleStrings];
        //取property用的
        [self setupLabelIdentifiers];
        [self setup];
        //[self updateConstraints];
    }
    return self;
}

-(void)reSetInfoPanel{
    if (_page1) {
        [_page1 removeFromSuperview];
    }
    if (_page2) {
        [_page2 removeFromSuperview];
    }
    if (_page3) {
        [_page3 removeFromSuperview];
    }
    if (_page4) {
        [_page4 removeFromSuperview];
    }
    if (_page5) {
        [_page5 removeFromSuperview];
    }
    self.portfolioItem = [[FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio]portfolioItem];
    [self setup];
}

-(void)getBidAsk{
//    BADataOut * BAOut = [[BADataOut alloc]initWithCommodityNum:_portfolioItem->commodityNo];
//    [FSDataModelProc sendData:self WithPacket:BAOut];
}

- (void)setupTitleStrings {
    self.titleStrings = @[NSLocalizedStringFromTable(@"EPS", @"Equity", @"The EPS label of InfoPanel"),
                          NSLocalizedStringFromTable(@"本益比", @"Equity", @"The P/E label of InfoPanel"),
                          NSLocalizedStringFromTable(@"Last", @"Equity", @"The last price label of InfoPanel"),
                          NSLocalizedStringFromTable(@"單量", @"Equity", @"The today volume label of InfoPanel"),
                          NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel"),
                          NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel"),
                          NSLocalizedStringFromTable(@"開盤", @"Equity", @"The open price label of InfoPanel"),
                          NSLocalizedStringFromTable(@"收盤", @"Equity", @"The close price label of InfoPanel"),
                          NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel"),
                          NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel"),
                          NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel"),
                          NSLocalizedStringFromTable(@"昨量", @"Equity", @"Yesterday volume label of InfoPanel") ,
                          NSLocalizedStringFromTable(@"52週最高", @"Equity", nil) ,
                          NSLocalizedStringFromTable(@"52週最低", @"Equity", nil) ,
                          NSLocalizedStringFromTable(@"Vol%", @"Equity", nil) ,
                          NSLocalizedStringFromTable(@"3月均量", @"Equity", nil) ,
                          ];
}

- (void)setupLabelIdentifiers {
    self.labelIdentifiers = @[@"eps", @"pe", @"last", @"vol", @"chg", @"chgp", @"open", @"close", @"high", @"low", @"todayVol", @"yesterdayVol",  @"week52High", @"week52Low", @"volP", @"vol3M"];
}

- (void)setup
{
    //page模式
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.scrollsToTop = NO;
    self.bounces = NO;
    self.backgroundColor = [UIColor colorWithRed:0.998 green:0.899 blue:0.600 alpha:1.000];
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
        
        [self setContentSize: CGSizeMake(mainScreenWidth * 2, 100)];
        self.contentOffset = CGPointMake(0, 0);
        
        self.page1 = [[UIView alloc]init];
        self.page1.translatesAutoresizingMaskIntoConstraints = YES;
        [self.page1 setFrame:CGRectMake(0, 0, mainScreenWidth, 100)];
        [self addSubview:_page1];
        
        self.page2 = [[UIView alloc]init];
        self.page2.translatesAutoresizingMaskIntoConstraints = YES;
        [self.page2 setFrame:CGRectMake(mainScreenWidth * 1, 0, mainScreenWidth, 100)];
        [self addSubview:_page2];
        
//        self.page3 = [[UIView alloc]init];
//        self.page3.translatesAutoresizingMaskIntoConstraints = YES;
//        [self.page3 setFrame:CGRectMake(mainScreenWidth * 2, 0, mainScreenWidth, 100)];
//        [self addSubview:_page3];
        [self setUSLabel];
    }
    else if ([group isEqualToString:@"cn"]){
        CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
        
        [self setContentSize: CGSizeMake(mainScreenWidth * 4, 100)];
        self.contentOffset = CGPointMake(0, 0);
        
        self.page1 = [[UIView alloc]init];
        self.page1.translatesAutoresizingMaskIntoConstraints = YES;
        [self.page1 setFrame:CGRectMake(0, 0, mainScreenWidth, 100)];
        [self addSubview:_page1];
        
        self.page2 = [[UIView alloc]init];
        self.page2.translatesAutoresizingMaskIntoConstraints = YES;
        [self.page2 setFrame:CGRectMake(mainScreenWidth * 1, 0, mainScreenWidth, 100)];
        [self addSubview:_page2];
        
        if(_portfolioItem -> type_id == 3 || _portfolioItem -> type_id == 6){
            
            [self setContentSize: CGSizeMake(mainScreenWidth * 2, 100)];
            
        }else{

            self.page3 = [[UIView alloc]init];
            self.page3.translatesAutoresizingMaskIntoConstraints = YES;
            [self.page3 setFrame:CGRectMake(mainScreenWidth * 2, 0, mainScreenWidth, 100)];
            [self addSubview:_page3];
            
            self.page4 = [[UIView alloc]init];
            self.page4.translatesAutoresizingMaskIntoConstraints = YES;
            self.page4.backgroundColor = [UIColor greenColor];
            
            self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(mainScreenWidth * 3, 0, mainScreenWidth, 85)];
            self.scrollView.bounces = NO;
            [self addSubview:_scrollView];
            [self.scrollView addSubview:_page4];
        }
        
        [self setCNLabel];
    }else{
        CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
        
        self.page1 = [[UIView alloc]init];
        self.page1.translatesAutoresizingMaskIntoConstraints = YES;
        [self.page1 setFrame:CGRectMake(0, 0, mainScreenWidth, 100)];
        [self addSubview:_page1];
        
        self.page2 = [[UIView alloc]init];
        self.page2.translatesAutoresizingMaskIntoConstraints = YES;
        [self.page2 setFrame:CGRectMake(mainScreenWidth * 1, 0, mainScreenWidth, 100)];
        [self addSubview:_page2];
        
        self.page3 = [[UIView alloc]init];
        self.page3.translatesAutoresizingMaskIntoConstraints = YES;
        [self.page3 setFrame:CGRectMake(mainScreenWidth * 2, 0, mainScreenWidth, 100)];
        [self addSubview:_page3];
        
        if(_portfolioItem->type_id==6){
            //加權指數
            [self setContentSize: CGSizeMake(mainScreenWidth * 2, 100)];
            self.contentOffset = CGPointMake(0, 0);
            
            [self setMarketIndexLabel];
        }else if (_portfolioItem->type_id == 3){
            [self setContentSize: CGSizeMake(mainScreenWidth * 1, 100)];
            self.contentOffset = CGPointMake(0, 0);
            
            [self setTwIndexLabel];
        }else{
            [self setContentSize: CGSizeMake(mainScreenWidth * 4, 100)];
            self.contentOffset = CGPointMake(0, 0);
            
            self.page4 = [[UIView alloc]init];
            self.page4.translatesAutoresizingMaskIntoConstraints = YES;
            self.page4.backgroundColor = [UIColor greenColor];
            
            self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(mainScreenWidth * 3, 0, mainScreenWidth, 85)];
            self.scrollView.bounces = NO;
            [self addSubview:_scrollView];
            [self.scrollView addSubview:_page4];
            
//            self.page4 = [[UIView alloc]init];
//            self.page4.translatesAutoresizingMaskIntoConstraints = YES;
////            [self.page4 setFrame:CGRectMake(0, 0, mainScreenWidth, 85)];
//            [self.page4 setFrame:CGRectMake(mainScreenWidth * 3, 0, mainScreenWidth, 100)];
//            [self addSubview:_page4];
//            
//            
//            self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(mainScreenWidth * 3, 0, mainScreenWidth, 85)];
//            
//            [self addSubview:_scrollView];

//            self.page5 = [[UIView alloc]init];
//            self.page5.translatesAutoresizingMaskIntoConstraints = YES;
//            [self.page5 setFrame:CGRectMake(0, 0, mainScreenWidth, 85)];

            
            [self setTWLabel];
        }
        
    }
    
//    [self setLayout];
}

-(void)setUSLabel{
    CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
    CGFloat labelWidth = (mainScreenWidth-18)/4;
    CGFloat labelWidth2 = (mainScreenWidth-18)/3;
    CGFloat labelHeigh = (_page1.frame.size.height-10)/3;
    CGFloat labelHeigh4 = (_page1.frame.size.height-10)/4;
    //第一頁
    //last
    self.lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.lastTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lastTitleLabel.text = NSLocalizedStringFromTable(@"Last", @"Equity", @"The last price label of InfoPanel");
    self.lastTitleLabel.textAlignment = NSTextAlignmentLeft;

    self.lastTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.lastTitleLabel];
    
    self.lastContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.lastContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lastContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.lastContentLabel];
    
    //vol
    self.volTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*2, 0, labelWidth, labelHeigh)];
    self.volTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.volTitleLabel.text = NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel");
    self.volTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.volTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.volTitleLabel];
    
    self.volContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*3, 0, labelWidth, labelHeigh)];
    self.volContentLabel.adjustsFontSizeToFitWidth = YES;
    self.volContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.volContentLabel];
    
    //chg
    self.chgTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.chgTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgTitleLabel.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chgTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgTitleLabel];
    
    self.chgContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh, labelWidth, labelHeigh)];
    self.chgContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgContentLabel];
    
    //chgp
    self.chgpTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*2, labelHeigh, labelWidth, labelHeigh)];
    self.chgpTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpTitleLabel.text = NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel");
    self.chgpTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgpTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgpTitleLabel];
    
    self.chgpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*3, labelHeigh, labelWidth, labelHeigh)];
    self.chgpContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgpContentLabel];
    
    //high
    self.highTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.highTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.highTitleLabel.text = NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel");
    self.highTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.highTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.highTitleLabel];
    
    self.highContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh*2, labelWidth, labelHeigh)];
    self.highContentLabel.adjustsFontSizeToFitWidth = YES;
    self.highContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.highContentLabel];
    
    //Low
    self.lowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.lowTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lowTitleLabel.text = NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel");
    self.lowTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.lowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.lowTitleLabel];
    
    self.lowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.lowContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lowContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.lowContentLabel];
    
    //第二頁
    //Open
    self.openTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.openTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.openTitleLabel.text = NSLocalizedStringFromTable(@"開盤", @"Equity", @"The open price label of InfoPanel");
    self.openTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.openTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.openTitleLabel];
    
    self.openContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, 0, labelWidth, labelHeigh)];
    self.openContentLabel.adjustsFontSizeToFitWidth = YES;
    self.openContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.openContentLabel];
    
    //Close
    self.closeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*2, 0, labelWidth, labelHeigh)];
    self.closeTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.closeTitleLabel.text = NSLocalizedStringFromTable(@"收盤", @"Equity", @"The close price label of InfoPanel");
    self.closeTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.closeTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.closeTitleLabel];
    
    self.closeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*3, 0, labelWidth, labelHeigh)];
    self.closeContentLabel.adjustsFontSizeToFitWidth = YES;
    self.closeContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.closeContentLabel];
    
    //High
    self.highTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.highTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.highTitleLabel2.text = NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel");
    self.highTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.highTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.highTitleLabel2];
    
    self.highContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh, labelWidth, labelHeigh)];
    self.highContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.highContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.highContentLabel2];
    
    //Low
    self.lowTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*2, labelHeigh, labelWidth, labelHeigh)];
    self.lowTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.lowTitleLabel2.text = NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel");
    self.lowTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.lowTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.lowTitleLabel2];
    
    self.lowContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*3, labelHeigh, labelWidth, labelHeigh)];
    self.lowContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.lowContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.lowContentLabel2];
    
    //chg
    self.chgTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgTitleLabel2.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chgTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.chgTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.chgTitleLabel2];
    
    self.chgContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.chgContentLabel2];
    
    //chgp
    self.chgpTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgpTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgpTitleLabel2.text = NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel");
    self.chgpTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.chgpTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.chgpTitleLabel2];
    
    self.chgpContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+5)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgpContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgpContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.chgpContentLabel2];
    
    //第三頁
    //VolT
    self.todayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth2*2, labelHeigh4)];
    self.todayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVolTitleLabel.text = NSLocalizedStringFromTable(@"今日總量", @"Equity", @"The today volume label of InfoPanel");
    self.todayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.todayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page3 addSubview:self.todayVolTitleLabel];
    
    self.todayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth2+2)*2, 0, labelWidth2, labelHeigh4)];
    self.todayVolContentLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVolContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page3 addSubview:self.todayVolContentLabel];
    
    //VolY
    self.yesterdayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh4, labelWidth2*2, labelHeigh4)];
    self.yesterdayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolTitleLabel.text = NSLocalizedStringFromTable(@"昨量", @"Equity", @"Yesterday volume label of InfoPanel");
    self.yesterdayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.yesterdayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page3 addSubview:self.yesterdayVolTitleLabel];
    
    self.yesterdayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth2+2)*2, labelHeigh4, labelWidth2, labelHeigh4)];
    self.yesterdayVolContentLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page3 addSubview:self.yesterdayVolContentLabel];
    
    //Volp
    self.volPTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh4*2, labelWidth2*2, labelHeigh4)];
    self.volPTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.volPTitleLabel.text = NSLocalizedStringFromTable(@"Vol%", @"Equity", nil);
    self.volPTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.volPTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page3 addSubview:self.volPTitleLabel];
    
    self.volPContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth2+2)*2, labelHeigh4*2, labelWidth2, labelHeigh4)];
    self.volPContentLabel.adjustsFontSizeToFitWidth = YES;
    self.volPContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page3 addSubview:self.volPContentLabel];
    
    //Vol3M
    self.vol3MTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh4*3, labelWidth2*2, labelHeigh4)];
    self.vol3MTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.vol3MTitleLabel.text = NSLocalizedStringFromTable(@"3月均量", @"Equity", nil);
    self.vol3MTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.vol3MTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page3 addSubview:self.vol3MTitleLabel];
    
    self.vol3MContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth2+2)*2, labelHeigh4*3, labelWidth2, labelHeigh4)];
    self.vol3MContentLabel.adjustsFontSizeToFitWidth = YES;
    self.vol3MContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page3 addSubview:self.vol3MContentLabel];
}

-(void)setCNLabel{
    CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
    CGFloat labelWidth = (mainScreenWidth-10)/4;
    CGFloat labelHeigh = (_page1.frame.size.height-10)/3;
    //第一頁
    //Open
    self.openTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.openTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.openTitleLabel.text = NSLocalizedStringFromTable(@"開盤", @"Equity", @"The open price label of InfoPanel");
    self.openTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.openTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.openTitleLabel];
    
    self.openContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.openContentLabel.adjustsFontSizeToFitWidth = YES;
    self.openContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.openContentLabel];
    
    //Close
    self.closeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
    self.closeTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.closeTitleLabel.text = NSLocalizedStringFromTable(@"收盤", @"Equity", @"The close price label of InfoPanel");
    self.closeTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.closeTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.closeTitleLabel];
    
    self.closeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
    self.closeContentLabel.adjustsFontSizeToFitWidth = YES;
    self.closeContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.closeContentLabel];
    
    //High
    self.highTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.highTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.highTitleLabel.text = NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel");
    self.highTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.highTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.highTitleLabel];
    
    self.highContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh, labelWidth, labelHeigh)];
    self.highContentLabel.adjustsFontSizeToFitWidth = YES;
    self.highContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.highContentLabel];
    
    //Low
    self.lowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
    self.lowTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lowTitleLabel.text = NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel");
    self.lowTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.lowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.lowTitleLabel];
    
    self.lowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
    self.lowContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lowContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.lowContentLabel];
    
    //chg
    self.chgTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgTitleLabel2.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chgTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.chgTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgTitleLabel2];
    
    self.chgContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgContentLabel2];
    
    //chgp
    self.chgpTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgpTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgpTitleLabel2.text = NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel");
    self.chgpTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.chgpTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgpTitleLabel2];
    
    self.chgpContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.chgpContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.chgpContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgpContentLabel2];
    

    //第二頁
    //last
    self.lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.lastTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lastTitleLabel.text = NSLocalizedStringFromTable(@"成交", @"Equity", @"The last price label of InfoPanel");
    self.lastTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.lastTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.lastTitleLabel];
    
    self.lastContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.lastContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lastContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.lastContentLabel];
    
    //vol
    self.todayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
    self.todayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVolTitleLabel.text = NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel");
    self.todayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.todayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.todayVolTitleLabel];
    
    self.todayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
    self.todayVolContentLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVolContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.todayVolContentLabel];
    
    //chg
    self.chgTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.chgTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgTitleLabel.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chgTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.chgTitleLabel];
    
    self.chgContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh, labelWidth, labelHeigh)];
    self.chgContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.chgContentLabel];
    
    //chgp
    self.chgpTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
    self.chgpTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpTitleLabel.text = NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel");
    self.chgpTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgpTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.chgpTitleLabel];
    
    self.chgpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
    self.chgpContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.chgpContentLabel];
    
    //high
    self.highTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.highTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.highTitleLabel2.text = NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel");
    self.highTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.highTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.highTitleLabel2];
    
    self.highContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh*2, labelWidth, labelHeigh)];
    self.highContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.highContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.highContentLabel2];
    
    //low
    self.lowTitleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.lowTitleLabel2.adjustsFontSizeToFitWidth = YES;
    self.lowTitleLabel2.text = NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel");
    self.lowTitleLabel2.textAlignment = NSTextAlignmentLeft;
    self.lowTitleLabel2.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.lowTitleLabel2];
    
    self.lowContentLabel2 = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.lowContentLabel2.adjustsFontSizeToFitWidth = YES;
    self.lowContentLabel2.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.lowContentLabel2];
    
    
    //第三頁
    //VolT
//    self.todayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
//    self.todayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.todayVolTitleLabel.text = NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel");
//    self.todayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.todayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.todayVolTitleLabel];
//    
//    self.todayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
//    self.todayVolContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.todayVolContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.todayVolContentLabel];
//    
//    //VolY
//    self.yesterdayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
//    self.yesterdayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.yesterdayVolTitleLabel.text = NSLocalizedStringFromTable(@"昨量", @"Equity", @"Yesterday volume label of InfoPanel");
//    self.yesterdayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.yesterdayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.yesterdayVolTitleLabel];
//    
//    self.yesterdayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
//    self.yesterdayVolContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.yesterdayVolContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.yesterdayVolContentLabel];
//    
//    //Volp
//    self.volPTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
//    self.volPTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.volPTitleLabel.text = NSLocalizedStringFromTable(@"Vol%", @"Equity", nil);
//    self.volPTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.volPTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.volPTitleLabel];
//    
//    self.volPContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*1, labelHeigh, labelWidth, labelHeigh)];
//    self.volPContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.volPContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.volPContentLabel];
//    
//    //Vol3M
//    self.vol3MTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
//    self.vol3MTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.vol3MTitleLabel.text = NSLocalizedStringFromTable(@"3月均量", @"Equity", nil);
//    self.vol3MTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.vol3MTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.vol3MTitleLabel];
//    
//    self.vol3MContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
//    self.vol3MContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.vol3MContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.vol3MContentLabel];
    
    //第三頁  五檔
    CGFloat viewWidth = mainScreenWidth/2;
    CGFloat viewHeight = _page3.frame.size.height-15;
    
    self.buyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    self.buyView.backgroundColor = [UIColor clearColor];
    self.buyView.layer.borderWidth = 0.5f;
    self.buyView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.page3 addSubview:self.buyView];
    
    self.sellView = [[UIView alloc]initWithFrame:CGRectMake(viewWidth, 0, viewWidth, viewHeight)];
    self.sellView.backgroundColor = [UIColor clearColor];
    self.sellView.layer.borderWidth = 0.5f;
    self.sellView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.page3 addSubview:self.sellView];
    
    //掛買
    self.buyTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 25, viewHeight)];
    self.buyTitleView.backgroundColor = [UIColor colorWithRed:0 green:92.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
    self.buyTitleView.layer.borderWidth = 0.5f;
    self.buyTitleView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.buyView addSubview:self.buyTitleView];
    
    self.buyLabelView = [[UIView alloc]initWithFrame:CGRectMake(25, 0, viewWidth-25, viewHeight)];
    self.buyLabelView.backgroundColor = [UIColor clearColor];
    [self.buyView addSubview:self.buyLabelView];
    
    self.buyTitleTopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25, viewHeight/2)];
    self.buyTitleTopLabel.backgroundColor = [UIColor clearColor];
    self.buyTitleTopLabel.textColor = [UIColor whiteColor];
    self.buyTitleTopLabel.text = NSLocalizedStringFromTable(@"掛", @"Equity", nil);
    self.buyTitleTopLabel.textAlignment = NSTextAlignmentCenter;
    [self.buyTitleView addSubview:self.buyTitleTopLabel];
    
    self.buyTitleBottonLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, viewHeight/2, 25, viewHeight/2)];
    self.buyTitleBottonLabel.backgroundColor = [UIColor clearColor];
    self.buyTitleBottonLabel.textColor = [UIColor whiteColor];
    self.buyTitleBottonLabel.text = NSLocalizedStringFromTable(@"買", @"Equity", nil);
    self.buyTitleBottonLabel.textAlignment = NSTextAlignmentCenter;
    [self.buyTitleView addSubview:self.buyTitleBottonLabel];
    
    //掛買價量
    CGFloat buyLabelHeight = _buyLabelView.frame.size.height/3;
    CGFloat buyLabelWidth = (_buyLabelView.frame.size.width-6)/2;
    
    self.buyPrice1 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, 0, buyLabelWidth, buyLabelHeight)];
    self.buyPrice1.backgroundColor = [UIColor clearColor];
    self.buyPrice1.textAlignment = NSTextAlignmentRight;
    self.buyPrice1.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyPrice1];
    
    self.buyPrice2 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.buyPrice2.backgroundColor = [UIColor clearColor];
    self.buyPrice2.textAlignment = NSTextAlignmentRight;
    self.buyPrice2.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyPrice2];
    
    self.buyPrice3 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.buyPrice3.backgroundColor = [UIColor clearColor];
    self.buyPrice3.textAlignment = NSTextAlignmentRight;
    self.buyPrice3.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyPrice3];
    
    self.buyVolume1 = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, buyLabelWidth, buyLabelHeight)];
    self.buyVolume1.backgroundColor = [UIColor clearColor];
    self.buyVolume1.textColor = [UIColor blueColor];
    self.buyVolume1.textAlignment = NSTextAlignmentLeft;
    self.buyVolume1.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyVolume1];
    
    self.buyVolume2 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.buyVolume2.backgroundColor = [UIColor clearColor];
    self.buyVolume2.textColor = [UIColor blueColor];
    self.buyVolume2.textAlignment = NSTextAlignmentLeft;
    self.buyVolume2.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyVolume2];
    
    self.buyVolume3 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.buyVolume3.backgroundColor = [UIColor clearColor];
    self.buyVolume3.textColor = [UIColor blueColor];
    self.buyVolume3.textAlignment = NSTextAlignmentLeft;
    self.buyVolume3.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyVolume3];
    
    
    //掛賣
    self.sellLabelView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth-25, viewHeight)];
    self.sellLabelView.backgroundColor = [UIColor clearColor];
    [self.sellView addSubview:self.sellLabelView];
    
    self.sellTitleView = [[UIView alloc]initWithFrame:CGRectMake(viewWidth-25, 0, 25, viewHeight)];
    self.sellTitleView.backgroundColor = [UIColor colorWithRed:0 green:92.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
    self.sellTitleView.layer.borderWidth = 0.5f;
    self.sellTitleView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.sellView addSubview:self.sellTitleView];
    
    self.sellTitleTopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25, viewHeight/2)];
    self.sellTitleTopLabel.backgroundColor = [UIColor clearColor];
    self.sellTitleTopLabel.textColor = [UIColor whiteColor];
    self.sellTitleTopLabel.text = NSLocalizedStringFromTable(@"掛", @"Equity", nil);
    self.sellTitleTopLabel.textAlignment = NSTextAlignmentCenter;
    [self.sellTitleView addSubview:self.sellTitleTopLabel];
    
    self.sellTitleBottonLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, viewHeight/2, 25, viewHeight/2)];
    self.sellTitleBottonLabel.backgroundColor = [UIColor clearColor];
    self.sellTitleBottonLabel.textColor = [UIColor whiteColor];
    self.sellTitleBottonLabel.text = NSLocalizedStringFromTable(@"賣", @"Equity", nil);
    self.sellTitleBottonLabel.textAlignment = NSTextAlignmentCenter;
    [self.sellTitleView addSubview:self.sellTitleBottonLabel];
    
    //掛賣價量
    self.sellPrice1 = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, buyLabelWidth, buyLabelHeight)];
    self.sellPrice1.backgroundColor = [UIColor clearColor];
    self.sellPrice1.textAlignment = NSTextAlignmentLeft;
    self.sellPrice1.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellPrice1];
    
    self.sellPrice2 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.sellPrice2.backgroundColor = [UIColor clearColor];
    self.sellPrice2.textAlignment = NSTextAlignmentLeft;
    self.sellPrice2.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellPrice2];
    
    self.sellPrice3 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.sellPrice3.backgroundColor = [UIColor clearColor];
    self.sellPrice3.textAlignment = NSTextAlignmentLeft;
    self.sellPrice3.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellPrice3];
    
    self.sellVolume1 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, 0, buyLabelWidth, buyLabelHeight)];
    self.sellVolume1.backgroundColor = [UIColor clearColor];
    self.sellVolume1.textColor = [UIColor blueColor];
    self.sellVolume1.textAlignment = NSTextAlignmentRight;
    self.sellVolume1.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellVolume1];
    
    self.sellVolume2 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.sellVolume2.backgroundColor = [UIColor clearColor];
    self.sellVolume2.textColor = [UIColor blueColor];
    self.sellVolume2.textAlignment = NSTextAlignmentRight;
    self.sellVolume2.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellVolume2];
    
    self.sellVolume3 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.sellVolume3.backgroundColor = [UIColor clearColor];
    self.sellVolume3.textColor = [UIColor blueColor];
    self.sellVolume3.textAlignment = NSTextAlignmentRight;
    self.sellVolume3.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellVolume3];
    
    
}

-(void)setTWLabel{
    CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
    CGFloat labelWidth = (mainScreenWidth-10)/6;
//    CGFloat label4Width = (mainScreenWidth-10)/4;
    CGFloat labelHeigh = (_page1.frame.size.height-10)/3;
    //第一頁
    //Open
    self.openTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.openTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.openTitleLabel.text = NSLocalizedStringFromTable(@"開盤", @"Equity", @"The open price label of InfoPanel");
    self.openTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.openTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.openTitleLabel];
    
    self.openContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.openContentLabel.adjustsFontSizeToFitWidth = YES;
    self.openContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.openContentLabel];
    
    //High
    self.highTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
    self.highTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.highTitleLabel.text = NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel");
    self.highTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.highTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.highTitleLabel];
    
    self.highContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
    self.highContentLabel.adjustsFontSizeToFitWidth = YES;
    self.highContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.highContentLabel];
    
    //Low
    self.lowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, 0, labelWidth, labelHeigh)];
    self.lowTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lowTitleLabel.text = NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel");
    self.lowTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.lowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.lowTitleLabel];
    
    self.lowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, 0, labelWidth, labelHeigh)];
    self.lowContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lowContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.lowContentLabel];
    
    //Close
    self.closeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.closeTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.closeTitleLabel.text = NSLocalizedStringFromTable(@"收盤", @"Equity", @"The close price label of InfoPanel");
    self.closeTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.closeTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.closeTitleLabel];
    
    self.closeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh, labelWidth, labelHeigh)];
    self.closeContentLabel.adjustsFontSizeToFitWidth = YES;
    self.closeContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.closeContentLabel];
    
    //chg
    self.chgTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
    self.chgTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgTitleLabel.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chgTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgTitleLabel];
    
    self.chgContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
    self.chgContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgContentLabel];
    
    //VolT
    self.todayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh, labelWidth, labelHeigh)];
    self.todayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVolTitleLabel.text = NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel");
    self.todayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.todayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.todayVolTitleLabel];
    
    self.todayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh, labelWidth, labelHeigh)];
    self.todayVolContentLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVolContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.todayVolContentLabel];
    
    //外盤
    self.outerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.outerTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.outerTitleLabel.text = NSLocalizedStringFromTable(@"外盤", @"Equity", @"");
    self.outerTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.outerTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.outerTitleLabel];
    
    self.outerContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh*2, labelWidth, labelHeigh)];
    self.outerContentLabel.adjustsFontSizeToFitWidth = YES;
    self.outerContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.outerContentLabel];
    
    //內盤
    self.innerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.innerTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.innerTitleLabel.text = NSLocalizedStringFromTable(@"內盤", @"Equity", @"");
    self.innerTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.innerTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.innerTitleLabel];
    
    self.innerContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.innerContentLabel.adjustsFontSizeToFitWidth = YES;
    self.innerContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.innerContentLabel];
    
    //比值
    self.platTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh*2, labelWidth, labelHeigh)];
    self.platTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.platTitleLabel.text = NSLocalizedStringFromTable(@"比值", @"Equity", @"");
    self.platTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.platTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.platTitleLabel];
    
    self.platContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh*2, labelWidth, labelHeigh)];
    self.platContentLabel.adjustsFontSizeToFitWidth = YES;
    self.platContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.platContentLabel];
    
    
    //第二頁
    //bid
    self.bidTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.bidTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.bidTitleLabel.text = NSLocalizedStringFromTable(@"買進", @"Equity", @"");
    self.bidTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.bidTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.bidTitleLabel];
    
    self.bidContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.bidContentLabel.adjustsFontSizeToFitWidth = YES;
    self.bidContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.bidContentLabel];
    
    //ask
    self.askTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
    self.askTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.askTitleLabel.text = NSLocalizedStringFromTable(@"賣出", @"Equity", @"");
    self.askTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.askTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.askTitleLabel];
    
    self.askContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
    self.askContentLabel.adjustsFontSizeToFitWidth = YES;
    self.askContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.askContentLabel];
    
    
    //last
    self.lastTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, 0, labelWidth, labelHeigh)];
    self.lastTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lastTitleLabel.text = NSLocalizedStringFromTable(@"Last", @"Equity", @"The last price label of InfoPanel");
    self.lastTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.lastTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.lastTitleLabel];
    
    self.lastContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, 0, labelWidth, labelHeigh)];
    self.lastContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lastContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.lastContentLabel];
    
    
    //vol
    self.volTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.volTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.volTitleLabel.text = NSLocalizedStringFromTable(@"單量", @"Equity", @"The today volume label of InfoPanel");
    self.volTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.volTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.volTitleLabel];
    
    self.volContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh, labelWidth, labelHeigh)];
    self.volContentLabel.adjustsFontSizeToFitWidth = YES;
    self.volContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.volContentLabel];
    
    //chg
    self.chg2TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
    self.chg2TitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chg2TitleLabel.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chg2TitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chg2TitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.chg2TitleLabel];
    
    self.chg2ContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
    self.chg2ContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chg2ContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.chg2ContentLabel];
    
    //chgp
    self.chgpTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh, labelWidth, labelHeigh)];
    self.chgpTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpTitleLabel.text = NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel");
    self.chgpTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgpTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.chgpTitleLabel];
    
    self.chgpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh, labelWidth, labelHeigh)];
    self.chgpContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.chgpContentLabel];
    
    //VolT
    self.todayVol2TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.todayVol2TitleLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVol2TitleLabel.text = NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel");
    self.todayVol2TitleLabel.textAlignment = NSTextAlignmentLeft;
    self.todayVol2TitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.todayVol2TitleLabel];
    
    self.todayVol2ContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh*2, labelWidth, labelHeigh)];
    self.todayVol2ContentLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVol2ContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.todayVol2ContentLabel];
    
    //VolY
    self.yesterdayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.yesterdayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolTitleLabel.text = NSLocalizedStringFromTable(@"昨量", @"Equity", @"Yesterday volume label of InfoPanel");
    self.yesterdayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.yesterdayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.yesterdayVolTitleLabel];
    
    self.yesterdayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.yesterdayVolContentLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.yesterdayVolContentLabel];
    
    //Volp
    self.volPTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh*2, labelWidth, labelHeigh)];
    self.volPTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.volPTitleLabel.text = NSLocalizedStringFromTable(@"Vol%", @"Equity", nil);
    self.volPTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.volPTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.volPTitleLabel];
    
    self.volPContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh*2, labelWidth, labelHeigh)];
    self.volPContentLabel.adjustsFontSizeToFitWidth = YES;
    self.volPContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.volPContentLabel];
    

    //第三頁
    
    //52WkH
//    self.week52HighTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, label4Width, labelHeigh)];
//    self.week52HighTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.week52HighTitleLabel.text = NSLocalizedStringFromTable(@"52週最高", @"Equity", nil);
//    self.week52HighTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.week52HighTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.week52HighTitleLabel];
//    
//    self.week52HighContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, 0, label4Width, labelHeigh)];
//    self.week52HighContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.week52HighContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.week52HighContentLabel];
//    
//    //eps
//    self.epsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((label4Width+2)*2, 0, label4Width, labelHeigh)];
//    self.epsTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.epsTitleLabel.text = NSLocalizedStringFromTable(@"EPS", @"Equity", @"The EPS label of InfoPanel");
//    self.epsTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.epsTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.epsTitleLabel];
//    
//    self.epsContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((label4Width+2)*3, 0, label4Width, labelHeigh)];
//    self.epsContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.epsContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.epsContentLabel];
//    
//    
//    //52WkL
//    self.week52LowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, label4Width, labelHeigh)];
//    self.week52LowTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.week52LowTitleLabel.text = NSLocalizedStringFromTable(@"52週最低", @"Equity", nil);
//    self.week52LowTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.week52LowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.week52LowTitleLabel];
//    
//    self.week52LowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, labelHeigh, label4Width, labelHeigh)];
//    self.week52LowContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.week52LowContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.week52LowContentLabel];
//    
//    
//    //pe
//    self.peTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((label4Width+2)*2, labelHeigh, label4Width, labelHeigh)];
//    self.peTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.peTitleLabel.text = NSLocalizedStringFromTable(@"本益比", @"Equity", @"The P/E label of InfoPanel");
//    self.peTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.peTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.peTitleLabel];
//    
//    self.peContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((label4Width+2)*3, labelHeigh, label4Width, labelHeigh)];
//    self.peContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.peContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.peContentLabel];
//    
//
//    //Vol3M
//    self.vol3MTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, label4Width, labelHeigh)];
//    self.vol3MTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.vol3MTitleLabel.text = NSLocalizedStringFromTable(@"3月均量", @"Equity", nil);
//    self.vol3MTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.vol3MTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.vol3MTitleLabel];
//    
//    self.vol3MContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, labelHeigh*2, label4Width, labelHeigh)];
//    self.vol3MContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.vol3MContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.vol3MContentLabel];
//    
//    //股利
//    self.divTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((label4Width+2)*2, labelHeigh*2, label4Width, labelHeigh)];
//    self.divTitleLabel.adjustsFontSizeToFitWidth = YES;
//    self.divTitleLabel.text = NSLocalizedStringFromTable(@"股利", @"Equity", nil);
//    self.divTitleLabel.textAlignment = NSTextAlignmentLeft;
//    self.divTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
//    [self.page3 addSubview:self.divTitleLabel];
//    
//    self.divContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((label4Width+2)*3, labelHeigh*2, label4Width, labelHeigh)];
//    self.divContentLabel.adjustsFontSizeToFitWidth = YES;
//    self.divContentLabel.textAlignment = NSTextAlignmentRight;
//    [self.page3 addSubview:self.divContentLabel];
    
    
    
    //第四頁  五檔
    CGFloat viewWidth = mainScreenWidth/2;
    CGFloat viewHeight = _page3.frame.size.height-15;
    
    self.buyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    self.buyView.backgroundColor = [UIColor clearColor];
    self.buyView.layer.borderWidth = 0.5f;
    self.buyView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.page3 addSubview:self.buyView];
    
    self.sellView = [[UIView alloc]initWithFrame:CGRectMake(viewWidth, 0, viewWidth, viewHeight)];
    self.sellView.backgroundColor = [UIColor clearColor];
    self.sellView.layer.borderWidth = 0.5f;
    self.sellView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.page3 addSubview:self.sellView];
    
    //掛買
    self.buyTitleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 25, viewHeight)];
    self.buyTitleView.backgroundColor = [UIColor colorWithRed:0 green:92.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
    self.buyTitleView.layer.borderWidth = 0.5f;
    self.buyTitleView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.buyView addSubview:self.buyTitleView];
    
    self.buyLabelView = [[UIView alloc]initWithFrame:CGRectMake(25, 0, viewWidth-25, viewHeight)];
    self.buyLabelView.backgroundColor = [UIColor clearColor];
    [self.buyView addSubview:self.buyLabelView];
    
    self.buyTitleTopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25, viewHeight/2)];
    self.buyTitleTopLabel.backgroundColor = [UIColor clearColor];
    self.buyTitleTopLabel.textColor = [UIColor whiteColor];
    self.buyTitleTopLabel.text = NSLocalizedStringFromTable(@"掛", @"Equity", nil);
    self.buyTitleTopLabel.textAlignment = NSTextAlignmentCenter;
    [self.buyTitleView addSubview:self.buyTitleTopLabel];
    
    self.buyTitleBottonLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, viewHeight/2, 25, viewHeight/2)];
    self.buyTitleBottonLabel.backgroundColor = [UIColor clearColor];
    self.buyTitleBottonLabel.textColor = [UIColor whiteColor];
    self.buyTitleBottonLabel.text = NSLocalizedStringFromTable(@"買", @"Equity", nil);
    self.buyTitleBottonLabel.textAlignment = NSTextAlignmentCenter;
    [self.buyTitleView addSubview:self.buyTitleBottonLabel];
    
    //掛買價量
    CGFloat buyLabelHeight = _buyLabelView.frame.size.height/3;
    CGFloat buyLabelWidth = (_buyLabelView.frame.size.width-6)/2;
    
    self.buyPrice1 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, 0, buyLabelWidth, buyLabelHeight)];
    self.buyPrice1.backgroundColor = [UIColor clearColor];
    self.buyPrice1.textAlignment = NSTextAlignmentRight;
    self.buyPrice1.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyPrice1];
    
    self.buyPrice2 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.buyPrice2.backgroundColor = [UIColor clearColor];
    self.buyPrice2.textAlignment = NSTextAlignmentRight;
    self.buyPrice2.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyPrice2];
    
    self.buyPrice3 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.buyPrice3.backgroundColor = [UIColor clearColor];
    self.buyPrice3.textAlignment = NSTextAlignmentRight;
    self.buyPrice3.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyPrice3];
    
    self.buyVolume1 = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, buyLabelWidth, buyLabelHeight)];
    self.buyVolume1.backgroundColor = [UIColor clearColor];
    self.buyVolume1.textColor = [UIColor blueColor];
    self.buyVolume1.textAlignment = NSTextAlignmentLeft;
    self.buyVolume1.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyVolume1];
    
    self.buyVolume2 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.buyVolume2.backgroundColor = [UIColor clearColor];
    self.buyVolume2.textColor = [UIColor blueColor];
    self.buyVolume2.textAlignment = NSTextAlignmentLeft;
    self.buyVolume2.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyVolume2];
    
    self.buyVolume3 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.buyVolume3.backgroundColor = [UIColor clearColor];
    self.buyVolume3.textColor = [UIColor blueColor];
    self.buyVolume3.textAlignment = NSTextAlignmentLeft;
    self.buyVolume3.adjustsFontSizeToFitWidth = YES;
    [self.buyLabelView addSubview:self.buyVolume3];
    
    
    //掛賣
    self.sellLabelView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth-25, viewHeight)];
    self.sellLabelView.backgroundColor = [UIColor clearColor];
    [self.sellView addSubview:self.sellLabelView];
    
    self.sellTitleView = [[UIView alloc]initWithFrame:CGRectMake(viewWidth-25, 0, 25, viewHeight)];
    self.sellTitleView.backgroundColor = [UIColor colorWithRed:0 green:92.0f/255.0f blue:184.0f/255.0f alpha:1.0f];
    self.sellTitleView.layer.borderWidth = 0.5f;
    self.sellTitleView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.sellView addSubview:self.sellTitleView];
    
    self.sellTitleTopLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 25, viewHeight/2)];
    self.sellTitleTopLabel.backgroundColor = [UIColor clearColor];
    self.sellTitleTopLabel.textColor = [UIColor whiteColor];
    self.sellTitleTopLabel.text = NSLocalizedStringFromTable(@"掛", @"Equity", nil);
    self.sellTitleTopLabel.textAlignment = NSTextAlignmentCenter;
    [self.sellTitleView addSubview:self.sellTitleTopLabel];
    
    self.sellTitleBottonLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, viewHeight/2, 25, viewHeight/2)];
    self.sellTitleBottonLabel.backgroundColor = [UIColor clearColor];
    self.sellTitleBottonLabel.textColor = [UIColor whiteColor];
    self.sellTitleBottonLabel.text = NSLocalizedStringFromTable(@"賣", @"Equity", nil);
    self.sellTitleBottonLabel.textAlignment = NSTextAlignmentCenter;
    [self.sellTitleView addSubview:self.sellTitleBottonLabel];
    
    //掛賣價量
    self.sellPrice1 = [[UILabel alloc]initWithFrame:CGRectMake(2, 0, buyLabelWidth, buyLabelHeight)];
    self.sellPrice1.backgroundColor = [UIColor clearColor];
    self.sellPrice1.textAlignment = NSTextAlignmentLeft;
    self.sellPrice1.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellPrice1];
    
    self.sellPrice2 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.sellPrice2.backgroundColor = [UIColor clearColor];
    self.sellPrice2.textAlignment = NSTextAlignmentLeft;
    self.sellPrice2.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellPrice2];
    
    self.sellPrice3 = [[UILabel alloc]initWithFrame:CGRectMake(2, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.sellPrice3.backgroundColor = [UIColor clearColor];
    self.sellPrice3.textAlignment = NSTextAlignmentLeft;
    self.sellPrice3.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellPrice3];
    
    self.sellVolume1 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, 0, buyLabelWidth, buyLabelHeight)];
    self.sellVolume1.backgroundColor = [UIColor clearColor];
    self.sellVolume1.textColor = [UIColor blueColor];
    self.sellVolume1.textAlignment = NSTextAlignmentRight;
    self.sellVolume1.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellVolume1];
    
    self.sellVolume2 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight, buyLabelWidth, buyLabelHeight)];
    self.sellVolume2.backgroundColor = [UIColor clearColor];
    self.sellVolume2.textColor = [UIColor blueColor];
    self.sellVolume2.textAlignment = NSTextAlignmentRight;
    self.sellVolume2.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellVolume2];
    
    self.sellVolume3 = [[UILabel alloc]initWithFrame:CGRectMake(buyLabelWidth+4, buyLabelHeight*2, buyLabelWidth, buyLabelHeight)];
    self.sellVolume3.backgroundColor = [UIColor clearColor];
    self.sellVolume3.textColor = [UIColor blueColor];
    self.sellVolume3.textAlignment = NSTextAlignmentRight;
    self.sellVolume3.adjustsFontSizeToFitWidth = YES;
    [self.sellLabelView addSubview:self.sellVolume3];
    
    
}

-(void)setTwIndexLabel{
    CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
    CGFloat labelWidth = (mainScreenWidth-10)/6;
    CGFloat label4Width = (mainScreenWidth-10)/4;
    CGFloat labelHeigh = (_page1.frame.size.height-10)/3;
    //第一頁
    //Open
    self.openTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.openTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.openTitleLabel.text = NSLocalizedStringFromTable(@"開盤", @"Equity", @"The open price label of InfoPanel");
    self.openTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.openTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.openTitleLabel];
    
    self.openContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.openContentLabel.adjustsFontSizeToFitWidth = YES;
    self.openContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.openContentLabel];
    
    //High
    self.highTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
    self.highTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.highTitleLabel.text = NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel");
    self.highTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.highTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.highTitleLabel];
    
    self.highContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
    self.highContentLabel.adjustsFontSizeToFitWidth = YES;
    self.highContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.highContentLabel];
    
    //Low
    self.lowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, 0, labelWidth, labelHeigh)];
    self.lowTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lowTitleLabel.text = NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel");
    self.lowTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.lowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.lowTitleLabel];
    
    self.lowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, 0, labelWidth, labelHeigh)];
    self.lowContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lowContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.lowContentLabel];
    
    //Close
    self.closeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.closeTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.closeTitleLabel.text = NSLocalizedStringFromTable(@"收盤", @"Equity", @"The close price label of InfoPanel");
    self.closeTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.closeTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.closeTitleLabel];
    
    self.closeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh, labelWidth, labelHeigh)];
    self.closeContentLabel.adjustsFontSizeToFitWidth = YES;
    self.closeContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.closeContentLabel];
    
    //chg
    self.chgTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
    self.chgTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgTitleLabel.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chgTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgTitleLabel];
    
    self.chgContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
    self.chgContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgContentLabel];
    
    //chgp
    self.chgpTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh, labelWidth, labelHeigh)];
    self.chgpTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpTitleLabel.text = NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel");
    self.chgpTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgpTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgpTitleLabel];
    
    self.chgpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh, labelWidth, labelHeigh)];
    self.chgpContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgpContentLabel];
    
    //VolT
    self.todayVol2TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.todayVol2TitleLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVol2TitleLabel.text = NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel");
    self.todayVol2TitleLabel.textAlignment = NSTextAlignmentLeft;
    self.todayVol2TitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.todayVol2TitleLabel];
    
    self.todayVol2ContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh*2, labelWidth, labelHeigh)];
    self.todayVol2ContentLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVol2ContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.todayVol2ContentLabel];
    
    //VolY
    self.yesterdayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.yesterdayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolTitleLabel.text = NSLocalizedStringFromTable(@"昨量", @"Equity", @"Yesterday volume label of InfoPanel");
    self.yesterdayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.yesterdayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.yesterdayVolTitleLabel];
    
    self.yesterdayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.yesterdayVolContentLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.yesterdayVolContentLabel];
    
    //Volp
    self.volPTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh*2, labelWidth, labelHeigh)];
    self.volPTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.volPTitleLabel.text = NSLocalizedStringFromTable(@"Vol%", @"Equity", nil);
    self.volPTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.volPTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.volPTitleLabel];
    
    self.volPContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh*2, labelWidth, labelHeigh)];
    self.volPContentLabel.adjustsFontSizeToFitWidth = YES;
    self.volPContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.volPContentLabel];
    
    
    //第二頁
    //52WkH
    self.week52HighTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, label4Width, labelHeigh)];
    self.week52HighTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.week52HighTitleLabel.text = NSLocalizedStringFromTable(@"52週最高", @"Equity", nil);
    self.week52HighTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.week52HighTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.week52HighTitleLabel];
    
    self.week52HighContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, 0, label4Width, labelHeigh)];
    self.week52HighContentLabel.adjustsFontSizeToFitWidth = YES;
    self.week52HighContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.week52HighContentLabel];
    
    //52WkL
    self.week52LowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, label4Width, labelHeigh)];
    self.week52LowTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.week52LowTitleLabel.text = NSLocalizedStringFromTable(@"52週最低", @"Equity", nil);
    self.week52LowTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.week52LowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.week52LowTitleLabel];
    
    self.week52LowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, labelHeigh, label4Width, labelHeigh)];
    self.week52LowContentLabel.adjustsFontSizeToFitWidth = YES;
    self.week52LowContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.week52LowContentLabel];
    
    //Vol3M
    self.vol3MTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, label4Width, labelHeigh)];
    self.vol3MTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.vol3MTitleLabel.text = NSLocalizedStringFromTable(@"3月均量", @"Equity", nil);
    self.vol3MTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.vol3MTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.vol3MTitleLabel];
    
    self.vol3MContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, labelHeigh*2, label4Width, labelHeigh)];
    self.vol3MContentLabel.adjustsFontSizeToFitWidth = YES;
    self.vol3MContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.vol3MContentLabel];
    
}

-(void)setMarketIndexLabel{
    CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);
    CGFloat labelWidth = (mainScreenWidth-10)/6;
    CGFloat label4Width = (mainScreenWidth-10)/4;
    CGFloat labelHeigh = (_page1.frame.size.height-10)/3;
    //第一頁
    //Open
    self.openTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.openTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.openTitleLabel.text = NSLocalizedStringFromTable(@"開盤", @"Equity", @"The open price label of InfoPanel");
    self.openTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.openTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.openTitleLabel];
    
    self.openContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.openContentLabel.adjustsFontSizeToFitWidth = YES;
    self.openContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.openContentLabel];
    
    //High
    self.highTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
    self.highTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.highTitleLabel.text = NSLocalizedStringFromTable(@"最高", @"Equity", @"The high price label of InfoPanel");
    self.highTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.highTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.highTitleLabel];
    
    self.highContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
    self.highContentLabel.adjustsFontSizeToFitWidth = YES;
    self.highContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.highContentLabel];
    
    //Low
    self.lowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, 0, labelWidth, labelHeigh)];
    self.lowTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.lowTitleLabel.text = NSLocalizedStringFromTable(@"最低", @"Equity", @"The low price label of InfoPanel");
    self.lowTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.lowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.lowTitleLabel];
    
    self.lowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, 0, labelWidth, labelHeigh)];
    self.lowContentLabel.adjustsFontSizeToFitWidth = YES;
    self.lowContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.lowContentLabel];
    
    //Close
    self.closeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.closeTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.closeTitleLabel.text = NSLocalizedStringFromTable(@"收盤", @"Equity", @"The close price label of InfoPanel");
    self.closeTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.closeTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.closeTitleLabel];
    
    self.closeContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh, labelWidth, labelHeigh)];
    self.closeContentLabel.adjustsFontSizeToFitWidth = YES;
    self.closeContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.closeContentLabel];
    
    //chg
    self.chgTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
    self.chgTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgTitleLabel.text = NSLocalizedStringFromTable(@"Chg$", @"Equity", @"The price change label of InfoPanel");
    self.chgTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgTitleLabel];
    
    self.chgContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
    self.chgContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgContentLabel];
    
    //chgp
    self.chgpTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh, labelWidth, labelHeigh)];
    self.chgpTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpTitleLabel.text = NSLocalizedStringFromTable(@"Chg%", @"Equity", @"The price change percentage label of InfoPanel");
    self.chgpTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.chgpTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.chgpTitleLabel];
    
    self.chgpContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh, labelWidth, labelHeigh)];
    self.chgpContentLabel.adjustsFontSizeToFitWidth = YES;
    self.chgpContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.chgpContentLabel];
    
    //VolT
    self.todayVol2TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.todayVol2TitleLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVol2TitleLabel.text = NSLocalizedStringFromTable(@"總量", @"Equity", @"The today volume label of InfoPanel");
    self.todayVol2TitleLabel.textAlignment = NSTextAlignmentLeft;
    self.todayVol2TitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.todayVol2TitleLabel];
    
    self.todayVol2ContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh*2, labelWidth, labelHeigh)];
    self.todayVol2ContentLabel.adjustsFontSizeToFitWidth = YES;
    self.todayVol2ContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.todayVol2ContentLabel];
    
    //VolY
    self.yesterdayVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.yesterdayVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolTitleLabel.text = NSLocalizedStringFromTable(@"昨量", @"Equity", @"Yesterday volume label of InfoPanel");
    self.yesterdayVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.yesterdayVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.yesterdayVolTitleLabel];
    
    self.yesterdayVolContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.yesterdayVolContentLabel.adjustsFontSizeToFitWidth = YES;
    self.yesterdayVolContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.yesterdayVolContentLabel];
    
    //Volp
    self.volPTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh*2, labelWidth, labelHeigh)];
    self.volPTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.volPTitleLabel.text = NSLocalizedStringFromTable(@"Vol%", @"Equity", nil);
    self.volPTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.volPTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page1 addSubview:self.volPTitleLabel];
    
    self.volPContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh*2, labelWidth, labelHeigh)];
    self.volPContentLabel.adjustsFontSizeToFitWidth = YES;
    self.volPContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page1 addSubview:self.volPContentLabel];
    
    
    //第二頁
    //bid
    self.bidVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, labelWidth, labelHeigh)];
    self.bidVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.bidVolTitleLabel.text = NSLocalizedStringFromTable(@"買張", @"Equity", @"");
    self.bidVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.bidVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.bidVolTitleLabel];
    
    self.bidVolLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, 0, labelWidth, labelHeigh)];
    self.bidVolLabel.adjustsFontSizeToFitWidth = YES;
    self.bidVolLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.bidVolLabel];
    
    //ask
    self.askVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, 0, labelWidth, labelHeigh)];
    self.askVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.askVolTitleLabel.text = NSLocalizedStringFromTable(@"賣張", @"Equity", @"");
    self.askVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.askVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.askVolTitleLabel];
    
    self.askVolLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, 0, labelWidth, labelHeigh)];
    self.askVolLabel.adjustsFontSizeToFitWidth = YES;
    self.askVolLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.askVolLabel];
    
    
    //deal
    self.dealVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, 0, labelWidth, labelHeigh)];
    self.dealVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.dealVolTitleLabel.text = NSLocalizedStringFromTable(@"成張", @"Equity", @"The last price label of InfoPanel");
    self.dealVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.dealVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.dealVolTitleLabel];
    
    self.dealVolLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, 0, labelWidth, labelHeigh)];
    self.dealVolLabel.adjustsFontSizeToFitWidth = YES;
    self.dealVolLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.dealVolLabel];
    
    
    //bidPer
    self.bidPerVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, labelWidth, labelHeigh)];
    self.bidPerVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.bidPerVolTitleLabel.text = NSLocalizedStringFromTable(@"買均", @"Equity", @"The today volume label of InfoPanel");
    self.bidPerVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.bidPerVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.bidPerVolTitleLabel];
    
    self.bidPerVolLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh, labelWidth, labelHeigh)];
    self.bidPerVolLabel.adjustsFontSizeToFitWidth = YES;
    self.bidPerVolLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.bidPerVolLabel];
    
    //askPer
    self.askPerVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh, labelWidth, labelHeigh)];
    self.askPerVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.askPerVolTitleLabel.text = NSLocalizedStringFromTable(@"賣均", @"Equity", @"The price change label of InfoPanel");
    self.askPerVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.askPerVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.askPerVolTitleLabel];
    
    self.askPerVolLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh, labelWidth, labelHeigh)];
    self.askPerVolLabel.adjustsFontSizeToFitWidth = YES;
    self.askPerVolLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.askPerVolLabel];
    
    //dealPer
    self.dealPerVolTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh, labelWidth, labelHeigh)];
    self.dealPerVolTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.dealPerVolTitleLabel.text = NSLocalizedStringFromTable(@"成均", @"Equity", @"The price change percentage label of InfoPanel");
    self.dealPerVolTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.dealPerVolTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.dealPerVolTitleLabel];
    
    self.dealPerVolLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh, labelWidth, labelHeigh)];
    self.dealPerVolLabel.adjustsFontSizeToFitWidth = YES;
    self.dealPerVolLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.dealPerVolLabel];
    
    //up
    self.upTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, labelWidth, labelHeigh)];
    self.upTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.upTitleLabel.text = NSLocalizedStringFromTable(@"漲家", @"Equity", @"The today volume label of InfoPanel");
    self.upTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.upTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.upTitleLabel];
    
    self.upLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth+2, labelHeigh*2, labelWidth, labelHeigh)];
    self.upLabel.adjustsFontSizeToFitWidth = YES;
    self.upLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.upLabel];
    
    //VolY
    self.downTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*2, labelHeigh*2, labelWidth, labelHeigh)];
    self.downTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.downTitleLabel.text = NSLocalizedStringFromTable(@"跌家", @"Equity", @"Yesterday volume label of InfoPanel");
    self.downTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.downTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.downTitleLabel];
    
    self.downLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*3, labelHeigh*2, labelWidth, labelHeigh)];
    self.downLabel.adjustsFontSizeToFitWidth = YES;
    self.downLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.downLabel];
    
    //unchanged
    self.unchangedTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*4, labelHeigh*2, labelWidth, labelHeigh)];
    self.unchangedTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.unchangedTitleLabel.text = NSLocalizedStringFromTable(@"平家", @"Equity", nil);
    self.unchangedTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.unchangedTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page2 addSubview:self.unchangedTitleLabel];
    
    self.unchangedLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth+2)*5, labelHeigh*2, labelWidth, labelHeigh)];
    self.unchangedLabel.adjustsFontSizeToFitWidth = YES;
    self.unchangedLabel.textAlignment = NSTextAlignmentRight;
    [self.page2 addSubview:self.unchangedLabel];
    
    //第三頁
    //52WkH
    self.week52HighTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, label4Width, labelHeigh)];
    self.week52HighTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.week52HighTitleLabel.text = NSLocalizedStringFromTable(@"52週最高", @"Equity", nil);
    self.week52HighTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.week52HighTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page3 addSubview:self.week52HighTitleLabel];
    
    self.week52HighContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, 0, label4Width, labelHeigh)];
    self.week52HighContentLabel.adjustsFontSizeToFitWidth = YES;
    self.week52HighContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page3 addSubview:self.week52HighContentLabel];
    
    //52WkL
    self.week52LowTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh, label4Width, labelHeigh)];
    self.week52LowTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.week52LowTitleLabel.text = NSLocalizedStringFromTable(@"52週最低", @"Equity", nil);
    self.week52LowTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.week52LowTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page3 addSubview:self.week52LowTitleLabel];
    
    self.week52LowContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, labelHeigh, label4Width, labelHeigh)];
    self.week52LowContentLabel.adjustsFontSizeToFitWidth = YES;
    self.week52LowContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page3 addSubview:self.week52LowContentLabel];
    
    //Vol3M
    self.vol3MTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, labelHeigh*2, label4Width, labelHeigh)];
    self.vol3MTitleLabel.adjustsFontSizeToFitWidth = YES;
    self.vol3MTitleLabel.text = NSLocalizedStringFromTable(@"3月均量", @"Equity", nil);
    self.vol3MTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.vol3MTitleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
    [self.page3 addSubview:self.vol3MTitleLabel];
    
    self.vol3MContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(label4Width+2, labelHeigh*2, label4Width, labelHeigh)];
    self.vol3MContentLabel.adjustsFontSizeToFitWidth = YES;
    self.vol3MContentLabel.textAlignment = NSTextAlignmentRight;
    [self.page3 addSubview:self.vol3MContentLabel];

}


- (void)reloadBValueSnapshot:(FSSnapshot *)snapshot {
    
    if (snapshot == nil || snapshot.reference_price.calcValue == 0) {
        _epsContentLabel.text = @"";
        _peContentLabel.text = @"";
        _lastContentLabel.text = @"";
        _volContentLabel.text = @"";
        _chgContentLabel.text = @"";
        _chgpContentLabel.text = @"";
        _chgContentLabel2.text = @"";
        _chgpContentLabel2.text = @"";
        _openContentLabel.text = @"";
        _closeContentLabel.text = @"";
        _highContentLabel.text = @"";
        _lowContentLabel.text = @"";
        _highContentLabel2.text = @"";
        _lowContentLabel2.text = @"";
        _todayVolContentLabel.text = @"";
        _yesterdayVolContentLabel.text =@"";
        _week52HighContentLabel.text = @"";
        _week52LowContentLabel.text =@"";
        _volPContentLabel.text = @"";
        _vol3MContentLabel.text = @"";
        _todayVolContentLabel.text = @"";
        _innerContentLabel.text = @"";
        _outerContentLabel.text = @"";
        _buyPrice1.text = @"";
        _buyPrice2.text = @"";
        _buyPrice3.text = @"";
        _buyVolume1.text = @"";
        _buyVolume2.text = @"";
        _buyVolume3.text = @"";
        _sellPrice1.text = @"";
        _sellPrice2.text = @"";
        _sellPrice3.text = @"";
        _sellVolume1.text = @"";
        _sellVolume2.text = @"";
        _sellVolume3.text = @"";
        return;
    }
    
    double open_price = (snapshot.open_price)? snapshot.open_price.calcValue : 0;
//    double reference_price = (snapshot->reference_price)? snapshot->reference_price->calcValue : 0;
    
    double last_price = (snapshot.last_price)? snapshot.last_price.calcValue : 0;
    double reference_price = (snapshot.reference_price)? snapshot.reference_price.calcValue : 0;
    
    double eps = (snapshot.eps)? snapshot.eps.calcValue : 0;
    
    double top_price = (snapshot.top_price)? snapshot.top_price.calcValue : 0;
    double bottom_price = (snapshot.bottom_price)? snapshot.bottom_price.calcValue : 0;
    
    double high_price = (snapshot.high_price)? snapshot.high_price.calcValue : 0;
    double low_price = (snapshot.low_price)? snapshot.low_price.calcValue : 0;
    
    double highest_52week_volume = (snapshot.highest_52week_volume)? snapshot.highest_52week_volume.calcValue : 0;
    double lowest_52week_volume = (snapshot.lowest_52week_volume)? snapshot.lowest_52week_volume.calcValue : 0;
    
    
    /* page1 */

    // 成交價
    if (snapshot.last_price && [snapshot.last_price calcValue] != 0) {
        if ([snapshot.top_price calcValue] == last_price) {
            _lastContentLabel.backgroundColor = [StockConstant PriceUpColor];
            _lastContentLabel.textColor = [UIColor whiteColor];
            _lastContentLabel.text = [NSString stringWithFormat:@"%.2f", last_price];
        }else if ([snapshot.bottom_price calcValue] == last_price){
            _lastContentLabel.backgroundColor = [StockConstant PriceDownColor];
            _lastContentLabel.textColor = [UIColor whiteColor];
            _lastContentLabel.text = [NSString stringWithFormat:@"%.2f", last_price];
        }else{
            [ValueUtil updateLabel:self.lastContentLabel
                         withPrice:last_price
                          refPrice:reference_price
                      ceilingPrice:top_price
                        floorPrice:bottom_price whiteStyle:NO];
        }

    }else{
        self.lastContentLabel.text = @"----";
        self.lastContentLabel.textColor = [UIColor blueColor];
    }
    
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        // 美股用總量
        //單量
        if (snapshot.accumulated_volume.calcValue) {
            self.volContentLabel.textColor = [UIColor blueColor];
            self.volContentLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.accumulated_volume.calcValue];
        }
        else {
            self.volContentLabel.text = @"----";
            self.volContentLabel.textColor = [UIColor blueColor];
        }
        
    }
    else {
        //單量
        if (snapshot.volume.calcValue) {
            self.volContentLabel.textColor = [UIColor blueColor];
            self.volContentLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.volume.calcValue];
        }
        else {
            self.volContentLabel.text = @"----";
            self.volContentLabel.textColor = [UIColor blueColor];
        }
    }
    
    //漲跌
    
    
    [ValueUtil updateChangeLabel:self.chgContentLabel withPrice:last_price refPrice:reference_price whiteStyle:NO];
    [ValueUtil updateChangeLabel:self.chgContentLabel2 withPrice:last_price refPrice:reference_price whiteStyle:NO];
    
    [ValueUtil updateChangeLabel:self.chg2ContentLabel withPrice:last_price refPrice:reference_price whiteStyle:NO];
    
    //漲幅
    if (last_price != 0 && reference_price != 0) {
        double chg = last_price - reference_price;
        self.chgpContentLabel.textColor = self.chgContentLabel.textColor;
        self.chgpContentLabel2.textColor = self.chgContentLabel.textColor;
		
        if(chg > 0){
			self.chgpContentLabel.text = [NSString stringWithFormat:@"+%.2lf%%",(chg/reference_price)*100];
            self.chgpContentLabel2.text = [NSString stringWithFormat:@"+%.2lf%%",(chg/reference_price)*100];
        }else{
			self.chgpContentLabel.text = [NSString stringWithFormat:@"%.2lf%%",(chg/reference_price)*100];
            self.chgpContentLabel2.text = [NSString stringWithFormat:@"%.2lf%%",(chg/reference_price)*100];
        }
        
    }else{
        self.chgpContentLabel.text = @"----";
        self.chgpContentLabel.textColor = [UIColor blueColor];
        self.chgpContentLabel2.text = @"----";
        self.chgpContentLabel2.textColor = [UIColor blueColor];
    }
    
    if (eps == 0)
        _epsContentLabel.text = @"----";
    else
        _epsContentLabel.text = [snapshot.eps format];
    _epsContentLabel.textColor = [UIColor blueColor];
    
    //本益比
    double pe = last_price / eps;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:0];
    if (eps == 0) {
        _peContentLabel.text = @"----";
    } else {
        self.peContentLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:pe]];
    }
    _peContentLabel.textColor = [UIColor blueColor];


    /* page2 */
    
    // 開盤價
    if (snapshot.open_price && [snapshot.last_price calcValue] != 0) {
        if ([snapshot.top_price calcValue] == open_price) {
            _openContentLabel.backgroundColor = [StockConstant PriceUpColor];
            _openContentLabel.textColor = [UIColor whiteColor];
            _openContentLabel.text = [NSString stringWithFormat:@"%.2f", open_price];
        }else if ([snapshot.bottom_price calcValue] == open_price){
            _openContentLabel.backgroundColor = [StockConstant PriceDownColor];
            _openContentLabel.textColor = [UIColor whiteColor];
            _openContentLabel.text = [NSString stringWithFormat:@"%.2f", open_price];
        }else{
            [ValueUtil updateLabel:self.openContentLabel
                         withPrice:open_price
                          refPrice:reference_price
                      ceilingPrice:high_price
                        floorPrice:low_price
                        whiteStyle:NO];
        }
    }else{
        self.openContentLabel.text = @"----";
        self.openContentLabel.textColor = [UIColor blueColor];
    }
    
    
    // 收盤價
    if (snapshot.last_price && [snapshot.last_price calcValue] != 0) {
        //如果已經收盤
//        if ([[[FSDataModelProc sharedInstance]marketInfo] isTickTime:snapshot.timeOfLastTick EqualToMarketClosedTime:_portfolioItem->market_id]) {
        
        if ([snapshot.top_price calcValue] == last_price) {
            _closeContentLabel.backgroundColor = [StockConstant PriceUpColor];
            _closeContentLabel.textColor = [UIColor whiteColor];
            _closeContentLabel.text = [NSString stringWithFormat:@"%.2f", last_price];
        }else if ([snapshot.bottom_price calcValue] == last_price){
            _closeContentLabel.backgroundColor = [StockConstant PriceDownColor];
            _closeContentLabel.textColor = [UIColor whiteColor];
            _closeContentLabel.text = [NSString stringWithFormat:@"%.2f", last_price];
        }else{
            [ValueUtil updateLabel:self.closeContentLabel
                         withPrice:last_price
                          refPrice:reference_price
                      ceilingPrice:high_price
                        floorPrice:low_price
                        whiteStyle:NO];
        }
    }
    else {
        self.closeContentLabel.text = @"----";
        self.closeContentLabel.textColor = [UIColor blueColor];
    }
    
    // 高
    if (snapshot.high_price && [snapshot.last_price calcValue] != 0) {
        if ([snapshot.top_price calcValue] == high_price) {
            _highContentLabel.backgroundColor = [StockConstant PriceUpColor];
            _highContentLabel.textColor = [UIColor whiteColor];
            _highContentLabel.text = [NSString stringWithFormat:@"%.2f", high_price];
            _highContentLabel2.backgroundColor = [StockConstant PriceUpColor];
            _highContentLabel2.textColor = [UIColor whiteColor];
            _highContentLabel2.text = [NSString stringWithFormat:@"%.2f", high_price];
        }else if ([snapshot.bottom_price calcValue] == high_price){
            _highContentLabel.backgroundColor = [StockConstant PriceDownColor];
            _highContentLabel.textColor = [UIColor whiteColor];
            _highContentLabel.text = [NSString stringWithFormat:@"%.2f", high_price];
            _highContentLabel2.backgroundColor = [StockConstant PriceDownColor];
            _highContentLabel2.textColor = [UIColor whiteColor];
            _highContentLabel2.text = [NSString stringWithFormat:@"%.2f", high_price];
        }else{
            [ValueUtil updateLabel:self.highContentLabel
                         withPrice:high_price
                          refPrice:reference_price
                      ceilingPrice:top_price
                        floorPrice:bottom_price
                        whiteStyle:NO];
            [ValueUtil updateLabel:self.highContentLabel2
                         withPrice:high_price
                          refPrice:reference_price
                      ceilingPrice:top_price
                        floorPrice:bottom_price
                        whiteStyle:NO];
        }
    }else{
        self.highContentLabel.text = @"----";
        self.highContentLabel.textColor = [UIColor blueColor];
        self.highContentLabel2.text = @"----";
        self.highContentLabel2.textColor = [UIColor blueColor];
    }
    
    // 低
    if (snapshot.low_price && [snapshot.last_price calcValue] != 0) {
        if ([snapshot.top_price calcValue] == low_price) {
            _lowContentLabel.backgroundColor = [StockConstant PriceUpColor];
            _lowContentLabel.textColor = [UIColor whiteColor];
            _lowContentLabel.text = [NSString stringWithFormat:@"%.2f", low_price];
            _lowContentLabel2.backgroundColor = [StockConstant PriceUpColor];
            _lowContentLabel2.textColor = [UIColor whiteColor];
            _lowContentLabel2.text = [NSString stringWithFormat:@"%.2f", low_price];
        }else if ([snapshot.bottom_price calcValue] == low_price){
            _lowContentLabel.backgroundColor = [StockConstant PriceDownColor];
            _lowContentLabel.textColor = [UIColor whiteColor];
            _lowContentLabel.text = [NSString stringWithFormat:@"%.2f", low_price];
            _lowContentLabel2.backgroundColor = [StockConstant PriceDownColor];
            _lowContentLabel2.textColor = [UIColor whiteColor];
            _lowContentLabel2.text = [NSString stringWithFormat:@"%.2f", low_price];
        }else{
            [ValueUtil updateLabel:self.lowContentLabel
                         withPrice:low_price
                          refPrice:reference_price
                      ceilingPrice:top_price
                        floorPrice:bottom_price
                        whiteStyle:NO];
            [ValueUtil updateLabel:self.lowContentLabel2
                         withPrice:low_price
                          refPrice:reference_price
                      ceilingPrice:top_price
                        floorPrice:bottom_price
                        whiteStyle:NO];
        }

    }else{
        self.lowContentLabel.text = @"----";
        self.lowContentLabel.textColor = [UIColor blueColor];
        self.lowContentLabel2.text = @"----";
        self.lowContentLabel2.textColor = [UIColor blueColor];
    }
    
    
    //昨量
    if(snapshot.previous_volume.calcValue) {
        
        _yesterdayVolContentLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.previous_volume.calcValue];
        
        self.yesterdayVolContentLabel.textColor = [UIColor blueColor];
    }else{
        self.yesterdayVolContentLabel.text = @"----";
        self.yesterdayVolContentLabel.textColor = [UIColor blueColor];
    }
    
    
    //總量
    if (snapshot.accumulated_volume.calcValue) {
//        if (_portfolioItem->type_id == 3 || _portfolioItem->type_id == 6) {
//            self.todayVolContentLabel.text =[CodingUtil twStringWithVolumeByValue:snapshot.accumulated_volume.calcValue];
//            self.todayVol2ContentLabel.text =[CodingUtil twStringWithVolumeByValue:snapshot.accumulated_volume.calcValue];
//        }else{
//            self.todayVolContentLabel.text =[CodingUtil twStringWithVolumeByValue:snapshot.accumulated_volume.calcValue];
//            self.todayVol2ContentLabel.text =[CodingUtil stringWithVolumeByValue2:snapshot.accumulated_volume.calcValue];
//        }
        _todayVolContentLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.accumulated_volume.calcValue];
        _todayVol2ContentLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.accumulated_volume.calcValue];
        
    }
    else {
        self.todayVolContentLabel.text = @"----";
        self.todayVol2ContentLabel.text = @"----";
    }
    self.todayVolContentLabel.textColor = [UIColor blueColor];
    self.todayVol2ContentLabel.textColor = [UIColor blueColor];
    //VolP
    if (snapshot.previous_volume.calcValue != 0 && snapshot.accumulated_volume.calcValue != 0 && snapshot.previous_volume.calcValue && snapshot.accumulated_volume.calcValue) {
        double volP = snapshot.accumulated_volume.calcValue / snapshot.previous_volume.calcValue;
        self.volPContentLabel.text = [NSString stringWithFormat:@"%.2f", volP];
        
    }else{
        self.volPContentLabel.text = @"----";
    }
    self.volPContentLabel.textColor = [UIColor blueColor];
    
    //52週最高
    if (snapshot.highest_52week_volume) {
        [ValueUtil updateLabel:self.week52HighContentLabel withPrice:highest_52week_volume refPrice:snapshot.reference_price.calcValue ceilingPrice:-1 floorPrice:-1 whiteStyle:NO];
    }else {
        self.week52HighContentLabel.text = @"----";
        self.week52HighContentLabel.textColor = [UIColor blueColor];
    }
    
    //52週最低
    if (snapshot.lowest_52week_volume) {
        [ValueUtil updateLabel:self.week52LowContentLabel withPrice:lowest_52week_volume refPrice:snapshot.reference_price.calcValue ceilingPrice:-1 floorPrice:-1 whiteStyle:NO];
    }else{
        self.week52LowContentLabel.text = @"----";
        self.week52LowContentLabel.textColor = [UIColor blueColor];
    }
    
    
    if (snapshot.average_3month_volume) {
        _vol3MContentLabel.text = [CodingUtil stringWithVolumeByValue2:snapshot.average_3month_volume.calcValue];
    }else {
        self.vol3MContentLabel.text = @"----";
    }
    self.vol3MContentLabel.textColor = [UIColor blueColor];
    
    //買進
    if (snapshot.bid_price && snapshot.bid_price.calcValue != 0) {
        if ([snapshot.top_price calcValue] == snapshot.bid_price.calcValue && snapshot.bid_price.calcValue != 0) {
            _bidContentLabel.backgroundColor = [StockConstant PriceUpColor];
            _bidContentLabel.textColor = [UIColor whiteColor];
            _bidContentLabel.text = [NSString stringWithFormat:@"%.2f", snapshot.bid_price.calcValue];
        }else if ([snapshot.bottom_price calcValue] == snapshot.bid_price.calcValue && snapshot.bid_price.calcValue != 0){
            _bidContentLabel.backgroundColor = [StockConstant PriceDownColor];
            _bidContentLabel.textColor = [UIColor whiteColor];
            _bidContentLabel.text = [NSString stringWithFormat:@"%.2f", snapshot.bid_price.calcValue];
        }else{
            [ValueUtil updateLabel:self.bidContentLabel withPrice:snapshot.bid_price.calcValue refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:NO];
        }
    }else{
        self.bidContentLabel.text = @"----";
        self.bidContentLabel.textColor = [UIColor blueColor];
    }

    
    //賣出
    if (snapshot.ask_price && snapshot.ask_price.calcValue != 0) {
        if ([snapshot.top_price calcValue] == snapshot.ask_price.calcValue && snapshot.ask_price.calcValue != 0) {
            _askContentLabel.backgroundColor = [StockConstant PriceUpColor];
            _askContentLabel.textColor = [UIColor whiteColor];
            _askContentLabel.text = [NSString stringWithFormat:@"%.2f", snapshot.ask_price.calcValue];
        }else if ([snapshot.bottom_price calcValue] == snapshot.ask_price.calcValue && snapshot.ask_price.calcValue != 0){
            _askContentLabel.backgroundColor = [StockConstant PriceDownColor];
            _askContentLabel.textColor = [UIColor whiteColor];
            _askContentLabel.text = [NSString stringWithFormat:@"%.2f", snapshot.ask_price.calcValue];
        }else{
            [ValueUtil updateLabel:self.askContentLabel withPrice:snapshot.ask_price.calcValue refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:NO];
        }
    }else{
        self.askContentLabel.text = @"----";
        self.askContentLabel.textColor = [UIColor blueColor];
    }

    
    //內外盤
    _innerContentLabel.text = [NSString stringWithFormat:@"%.0f",snapshot.inner_price.calcValue];
    _innerContentLabel.textColor = [UIColor darkGrayColor];
    _outerContentLabel.text = [NSString stringWithFormat:@"%.0f",snapshot.outer_price.calcValue];
    _outerContentLabel.textColor = [UIColor orangeColor];
    if (snapshot.inner_price.calcValue == 0) {
        _platContentLabel.text = @"---";
    }else{
        _platContentLabel.text = [NSString stringWithFormat:@"%.2f",((float)snapshot.outer_price.calcValue/(float)snapshot.inner_price.calcValue)];
    }
    _platContentLabel.textColor = [UIColor blueColor];
    
    _divContentLabel.text = [NSString stringWithFormat:@"%.2f",snapshot.annual_divided.calcValue];
    self.divContentLabel.textColor = [UIColor blueColor];
    
    
    //五檔
    if ([snapshot.BABidArray count]>0) {
        BAData_bValue * baData = [snapshot.BABidArray objectAtIndex:0];
        if ([snapshot.top_price calcValue] == [snapshot.bid_price calcValue] && baData->bidPrice > 0) {
            _buyPrice1.backgroundColor = [StockConstant PriceUpColor];
            _buyPrice1.textColor = [UIColor whiteColor];
            _buyPrice1.text = [NSString stringWithFormat:@"%.2f", baData->bidPrice];
        }else if ([snapshot.bottom_price calcValue] == [snapshot.ask_price calcValue] && baData->bidPrice > 0){
            _buyPrice1.backgroundColor = [StockConstant PriceDownColor];
            _buyPrice1.textColor = [UIColor whiteColor];
            _buyPrice1.text = [NSString stringWithFormat:@"%.2f", baData->bidPrice];
        }else{
            [ValueUtil updateLabel:self.buyPrice1 withPrice:baData->bidPrice refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:YES];
        }

        if ([self.buyPrice1.text isEqualToString:@"----"]) {
            self.buyVolume1.text = @"----";
        }else{
            self.buyVolume1.text = [NSString stringWithFormat:@"%.0f", baData->bidVolume];
        }
        
    }else{
        self.buyPrice1.text = @"----";
        self.buyVolume1.text = @"----";
        self.buyPrice1.textColor = [UIColor blueColor];
        self.buyVolume1.textColor = [UIColor blueColor];
    }
    
    if ([snapshot.BABidArray count]>1) {
        BAData_bValue * baData = [snapshot.BABidArray objectAtIndex:1];
        
        
        [ValueUtil updateLabel:self.buyPrice2 withPrice:baData->bidPrice refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:YES];
        
        if ([self.buyPrice2.text isEqualToString:@"----"]) {
            self.buyVolume2.text = @"----";
        }else{
            self.buyVolume2.text = [NSString stringWithFormat:@"%.0f", baData->bidVolume];
        }
    }else{
        self.buyPrice2.text = @"----";
        self.buyVolume2.text = @"----";
        self.buyPrice2.textColor = [UIColor blueColor];
        self.buyVolume2.textColor = [UIColor blueColor];
    }
    
    if ([snapshot.BABidArray count]>2) {
        BAData_bValue * baData = [snapshot.BABidArray objectAtIndex:2];
        
        
        [ValueUtil updateLabel:self.buyPrice3 withPrice:baData->bidPrice refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:YES];
        
        if ([self.buyPrice3.text isEqualToString:@"----"]) {
            self.buyVolume3.text = @"----";
        }else{
            self.buyVolume3.text = [NSString stringWithFormat:@"%.0f", baData->bidVolume];
        }
    }else{
        self.buyPrice3.text = @"----";
        self.buyVolume3.text = @"----";
        self.buyPrice3.textColor = [UIColor blueColor];
        self.buyVolume3.textColor = [UIColor blueColor];
    }
    
    
    if ([snapshot.BAAskArray count]>0) {
        BAData_bValue * baData = [snapshot.BAAskArray objectAtIndex:0];
        if ([snapshot.top_price calcValue] == [snapshot.ask_price calcValue] && baData->askPrice > 0) {
            _sellPrice1.backgroundColor = [StockConstant PriceUpColor];
            _sellPrice1.textColor = [UIColor whiteColor];
            _sellPrice1.text = [NSString stringWithFormat:@"%.2f", baData->askPrice];
        }else if ([snapshot.bottom_price calcValue] == [snapshot.ask_price calcValue] && baData->askPrice > 0){
            _sellPrice1.backgroundColor = [StockConstant PriceDownColor];
            _sellPrice1.textColor = [UIColor whiteColor];
            _sellPrice1.text = [NSString stringWithFormat:@"%.2f", baData->askPrice];
        }else{
            [ValueUtil updateLabel:self.sellPrice1 withPrice:baData->askPrice refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:YES];
        }
        
        if ([self.sellPrice1.text isEqualToString:@"----"]) {
            self.sellVolume1.text = @"----";
        }else{
            self.sellVolume1.text = [NSString stringWithFormat:@"%.0f", baData->askVolume];
        }
        
    }else{
        self.sellPrice1.text = @"----";
        self.sellVolume1.text = @"----";
        self.sellPrice1.textColor = [UIColor blueColor];
        self.sellVolume1.textColor = [UIColor blueColor];
    }
    
    if ([snapshot.BAAskArray count]>1) {
        BAData_bValue * baData = [snapshot.BAAskArray objectAtIndex:1];
        
        
        [ValueUtil updateLabel:self.sellPrice2 withPrice:baData->askPrice refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:YES];
        
        if ([self.sellPrice2.text isEqualToString:@"----"]) {
            self.sellVolume2.text = @"----";
        }else{
            self.sellVolume2.text = [NSString stringWithFormat:@"%.0f", baData->askVolume];
        }
    }else{
        self.sellPrice2.text = @"----";
        self.sellVolume2.text = @"----";
        self.sellPrice2.textColor = [UIColor blueColor];
        self.sellVolume2.textColor = [UIColor blueColor];
    }
    
    if ([snapshot.BAAskArray count]>2) {
        BAData_bValue * baData = [snapshot.BAAskArray objectAtIndex:2];
        
        
        [ValueUtil updateLabel:self.sellPrice3 withPrice:baData->askPrice refPrice:snapshot.reference_price.calcValue ceilingPrice:snapshot.top_price.calcValue floorPrice:snapshot.bottom_price.calcValue whiteStyle:YES];
        
        if ([self.sellPrice3.text isEqualToString:@"----"]) {
            self.sellVolume3.text = @"----";
        }else{
            self.sellVolume3.text = [NSString stringWithFormat:@"%.0f", baData->askVolume];
        }
    }else{
        self.sellPrice3.text = @"----";
        self.sellVolume3.text = @"----";
        self.sellPrice3.textColor = [UIColor blueColor];
        self.sellVolume3.textColor = [UIColor blueColor];
    }
    
    
    if (_portfolioItem->type_id == 6) {
        
        _bidVolLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.bid_volume.calcValue];
        _askVolLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.ask_volume.calcValue];
        _dealVolLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.deal_volume.calcValue];
        
        _bidPerVolLabel.text = [CodingUtil priceRoundRownWithDouble:snapshot.bid_volume.calcValue/snapshot.bidRecord.calcValue];
        _askPerVolLabel.text = [CodingUtil priceRoundRownWithDouble:snapshot.ask_volume.calcValue/snapshot.askRecord.calcValue];
        _dealPerVolLabel.text = [CodingUtil priceRoundRownWithDouble:snapshot.deal_volume.calcValue/snapshot.dealRecord.calcValue];
        
        _upLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.up_count.calcValue];
        _downLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.down_count.calcValue];
        _unchangedLabel.text = [CodingUtil volumeRoundRownWithDouble:snapshot.unchange_count.calcValue];
        
        _bidVolLabel.textColor = [UIColor blueColor];
        _askVolLabel.textColor = [UIColor blueColor];
        _dealVolLabel.textColor = [UIColor blueColor];
        _bidPerVolLabel.textColor = [UIColor blueColor];
        _askPerVolLabel.textColor = [UIColor blueColor];
        _dealPerVolLabel.textColor = [UIColor blueColor];
        _upLabel.textColor = [UIColor blueColor];
        _downLabel.textColor = [UIColor blueColor];
        _unchangedLabel.textColor = [UIColor blueColor];
        
    }
    
}

- (void)reloadDataWithSnapshot:(EquitySnapshotDecompressed *) snapshot
{
    if ([snapshot isKindOfClass:[IndexSnapshotDecompressed class]]) {
        NSLog(@"指數");
        
        IndexSnapshotDecompressed * indexSnapshot = (IndexSnapshotDecompressed *)snapshot;
        
        _bidVolLabel.text =[CodingUtil stringWithVolumeByValue2:indexSnapshot.bidVolume * pow(1000, indexSnapshot.bidVolumeUnit)];
        _askVolLabel.text =[CodingUtil stringWithVolumeByValue2:indexSnapshot.askVolume * pow(1000, indexSnapshot.askVolumeUnit)];
        _dealVolLabel.text = [CodingUtil stringWithVolumeByValue2:indexSnapshot.dealVolume * pow(1000, indexSnapshot.dealVolumeUnit)];
        
        _bidPerVolLabel.text = [NSString stringWithFormat:@"%.2f",indexSnapshot.bidVolume * pow(1000, indexSnapshot.bidVolumeUnit)/indexSnapshot.bidRecordCount * pow(1000, indexSnapshot.bidRecordCountUnit)];
        _askPerVolLabel.text = [NSString stringWithFormat:@"%.2f",indexSnapshot.askVolume * pow(1000, indexSnapshot.askVolumeUnit)/indexSnapshot.askRecordCount * pow(1000, indexSnapshot.askRecordCountUnit)];
        _dealPerVolLabel.text = [NSString stringWithFormat:@"%.2f",indexSnapshot.dealVolume * pow(1000, indexSnapshot.dealVolumeUnit)/indexSnapshot.dealRecordCount * pow(1000, indexSnapshot.dealRecordCountUnit)];
        
        _upLabel.text = [NSString stringWithFormat:@"%d",indexSnapshot.upSecurityNo];
        _downLabel.text = [NSString stringWithFormat:@"%d",indexSnapshot.downSecurityNo];
        _unchangedLabel.text = [NSString stringWithFormat:@"%d",indexSnapshot.unchangedSecurityNo];
        
        _bidVolLabel.textColor = [UIColor blueColor];
        _askVolLabel.textColor = [UIColor blueColor];
        _dealVolLabel.textColor = [UIColor blueColor];
        _bidPerVolLabel.textColor = [UIColor blueColor];
        _askPerVolLabel.textColor = [UIColor blueColor];
        _dealPerVolLabel.textColor = [UIColor blueColor];
        _upLabel.textColor = [UIColor blueColor];
        _downLabel.textColor = [UIColor blueColor];
        _unchangedLabel.textColor = [UIColor blueColor];
        
    }else{
        NSLog(@"股票");
    }
    if(snapshot==nil){
        _epsContentLabel.text = @"";
        _peContentLabel.text = @"";
        _lastContentLabel.text = @"";
        _volContentLabel.text = @"";
        _chgContentLabel.text = @"";
        _chg2ContentLabel.text = @"";
        _chgpContentLabel.text = @"";
        _openContentLabel.text = @"";
        _closeContentLabel.text = @"";
        _highContentLabel.text = @"";
        _lowContentLabel.text = @"";
        _todayVolContentLabel.text = @"";
        _yesterdayVolContentLabel.text =@"";
        _week52HighContentLabel.text = @"";
        _week52LowContentLabel.text =@"";
        _volPContentLabel.text = @"";
        _vol3MContentLabel.text = @"";
        _todayVolContentLabel.text = @"";
        _bidContentLabel.text = @"";
        _askContentLabel.text = @"";
        _divContentLabel.text = @"";
        _innerContentLabel.text = @"";
        _outerContentLabel.text = @"";
        _buyPrice1.text = @"";
        _buyPrice2.text = @"";
        _buyPrice3.text = @"";
        _buyVolume1.text = @"";
        _buyVolume2.text = @"";
        _buyVolume3.text = @"";
        _sellPrice1.text = @"";
        _sellPrice2.text = @"";
        _sellPrice3.text = @"";
        _sellVolume1.text = @"";
        _sellVolume2.text = @"";
        _sellVolume3.text = @"";
        _bidVolLabel.text = @"";
        _askVolLabel.text = @"";
        _dealVolLabel.text = @"";
        _bidPerVolLabel.text = @"";
        _askPerVolLabel.text = @"";
        _dealPerVolLabel.text = @"";
        _upLabel.text = @"";
        _downLabel.text = @"";
        _unchangedLabel.text = @"";
        
        return;
    }
    if(snapshot.eps == 0)
        _epsContentLabel.text = @"----";
    else
        _epsContentLabel.text = [CodingUtil getValueUnitString:snapshot.eps Unit:snapshot.epsUnit]; //EPS
    _epsContentLabel.textColor = [UIColor blueColor];
    
    //本益比
    double pe = snapshot.currentPrice / snapshot.eps*pow(1000, snapshot.epsUnit);
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setMinimumFractionDigits:0];
    if (snapshot.eps == 0) {
        _peContentLabel.text = @"----";
    }else{
        self.peContentLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:pe]];
    }
    
    _peContentLabel.textColor = [UIColor blueColor];
    
    //成
    _lastContentLabel.textColor = [UIColor blueColor];
    [ValueUtil updateLabel:self.lastContentLabel withPrice:[snapshot currentPrice] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    
    
    //單量
    if (snapshot.volume != 0)
	{
        self.volContentLabel.textColor = [UIColor blueColor];
        self.volContentLabel.text = [ValueUtil stringWithValue:snapshot.volume unit:snapshot.volumeUnit sign:NO];
    }
    else {
        self.volContentLabel.text = @"----";
        self.volContentLabel.textColor = [UIColor blueColor];
    }
    
    //漲跌
    [ValueUtil updateChangeLabel:self.chgContentLabel withPrice:snapshot.currentPrice refPrice:snapshot.referencePrice whiteStyle:NO];
    [ValueUtil updateChangeLabel:self.chg2ContentLabel withPrice:snapshot.currentPrice refPrice:snapshot.referencePrice whiteStyle:NO];
    
    //漲幅
    if (snapshot.currentPrice != 0 && snapshot.referencePrice != 0) {
        double chg = snapshot.currentPrice - snapshot.referencePrice;
        self.chgpContentLabel.textColor = self.chgContentLabel.textColor;
		
		if(chg > 0)
			self.chgpContentLabel.text = [NSString stringWithFormat:@"+%.2lf%%",(chg/snapshot.referencePrice)*100];
		else
			self.chgpContentLabel.text = [NSString stringWithFormat:@"%.2lf%%",(chg/snapshot.referencePrice)*100];
        
    }
    //開
    [ValueUtil updateLabel:self.openContentLabel withPrice:[snapshot openPrice] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    
    //收
    if (snapshot != nil && _portfolioItem != nil) {
        //如果已經收盤
        if ([[[FSDataModelProc sharedInstance]marketInfo] isTickTime:snapshot.timeOfLastTick EqualToMarketClosedTime:_portfolioItem->market_id]) {
            [ValueUtil updateLabel:self.closeContentLabel withPrice:[snapshot currentPrice] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
        }
    }
    else {
        self.closeContentLabel.text = @"----";
    }
    
    //高
    [ValueUtil updateLabel:self.highContentLabel withPrice:[snapshot highestPrice] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    [ValueUtil updateLabel:self.highContentLabel2 withPrice:[snapshot highestPrice] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    //低
    [ValueUtil updateLabel:self.lowContentLabel withPrice:[snapshot lowestPrice] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    [ValueUtil updateLabel:self.lowContentLabel2 withPrice:[snapshot lowestPrice] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    
    //總量
    if (snapshot.accumulatedVolume != 0)
	{
//        self.todayVolContentLabel.text = [ValueUtil stringWithValue:snapshot.accumulatedVolume unit:snapshot.accumulatedVolumeUnit sign:NO];
        self.todayVolContentLabel.text =[CodingUtil stringWithVolumeByValue2:snapshot.accumulatedVolume * pow(1000, snapshot.accumulatedVolumeUnit)];
        self.todayVolContentLabel.textColor = [UIColor blueColor];
        
        self.todayVol2ContentLabel.text =[CodingUtil stringWithVolumeByValue2:snapshot.accumulatedVolume * pow(1000, snapshot.accumulatedVolumeUnit)];
        self.todayVol2ContentLabel.textColor = [UIColor blueColor];
    }
    else {
        self.todayVolContentLabel.text = @"----";
        self.todayVol2ContentLabel.text = @"----";
    }
    //昨量
    if(snapshot.previousVolume!=0) {
//        self.yesterdayVolContentLabel.text = [ValueUtil stringWithValue:snapshot.previousVolume unit:snapshot.previousVolumeUnit sign:NO];
        _yesterdayVolContentLabel.text = [CodingUtil stringWithVolumeByValue2:snapshot.previousVolume * pow(1000, snapshot.previousVolumeUnit)];
        self.yesterdayVolContentLabel.textColor = [UIColor blueColor];
    }
    //52週最高
    [ValueUtil updateLabel:self.week52HighContentLabel withPrice:snapshot.week52High refPrice:snapshot.referencePrice ceilingPrice:-1 floorPrice:-1 whiteStyle:NO];
    //52週最低
    [ValueUtil updateLabel:self.week52LowContentLabel withPrice:snapshot.week52Low refPrice:snapshot.referencePrice ceilingPrice:-1 floorPrice:-1 whiteStyle:NO];
    
    if (snapshot.averageVolume != 0) {
        //self.vol3MContentLabel.text = [ValueUtil stringWithValue:snapshot.averageVolume unit:snapshot.averageVolumeUnit sign:NO];
        _vol3MContentLabel.text = [CodingUtil stringWithVolumeByValue2:snapshot.averageVolume * pow(1000, snapshot.averageVolumeUnit)];
        self.vol3MContentLabel.textColor = [UIColor blueColor];
    }
    else {
        self.vol3MContentLabel.text = @"----";
    }
    
    if (snapshot.previousVolume!=0 && snapshot.accumulatedVolume != 0) {
        double volP = (snapshot.accumulatedVolume*pow(1000, snapshot.accumulatedVolumeUnit)) / (snapshot.previousVolume*pow(1000, snapshot.previousVolumeUnit));
        self.volPContentLabel.text = [NSString stringWithFormat:@"%.2f", volP];
        self.volPContentLabel.textColor = [UIColor blueColor];
    }

    //買進
    [ValueUtil updateLabel:self.bidContentLabel withPrice:snapshot.bid refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    
    //賣出
    [ValueUtil updateLabel:self.askContentLabel withPrice:snapshot.ask refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
    
    //股利
    _divContentLabel.text = [NSString stringWithFormat:@"%.2f",snapshot.annualDividend];
    self.divContentLabel.textColor = [UIColor blueColor];
    
    //內外盤
    _innerContentLabel.text = [NSString stringWithFormat:@"%d",snapshot.innerPlat];
    _innerContentLabel.textColor = [UIColor darkGrayColor];
    _outerContentLabel.text = [NSString stringWithFormat:@"%d",snapshot.outerPlat];
    _outerContentLabel.textColor = [UIColor orangeColor];
    
    _platContentLabel.text = [NSString stringWithFormat:@"%.2f",((float)snapshot.outerPlat/(float)snapshot.innerPlat)];
    _platContentLabel.textColor = [UIColor blueColor];
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if (![group isEqualToString:@"us"]) {
        self.buyPrice1.text = @"----";
        self.buyPrice1.textColor = [UIColor blueColor];
        self.buyPrice2.text = @"----";
        self.buyPrice2.textColor = [UIColor blueColor];
        self.buyPrice3.text = @"----";
        self.buyPrice3.textColor = [UIColor blueColor];
        self.buyVolume1.text = @"----";
        self.buyVolume2.text = @"----";
        self.buyVolume3.text = @"----";
        self.sellPrice1.text = @"----";
        self.sellPrice1.textColor = [UIColor blueColor];
        self.sellPrice2.text = @"----";
        self.sellPrice2.textColor = [UIColor blueColor];
        self.sellPrice3.text = @"----";
        self.sellPrice3.textColor = [UIColor blueColor];
        self.sellVolume1.text = @"----";
        self.sellVolume2.text = @"----";
        self.sellVolume3.text = @"----";
        if (snapshot.nearestBidAskCount!=0){
            if (snapshot.nearestBidAskCount>=1) {
                double buyVolume = snapshot.nearestBidVolume[0]*pow(1000, snapshot.nearestBidVolumeUnit[0]);
                double sellVolume = snapshot.nearestAskVolume[0]*pow(1000, snapshot.nearestAskVolumeUnit[0]);
                
                [ValueUtil updateLabel:self.buyPrice1 withPrice:snapshot.nearestBidPrice[0] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:YES];
                
                self.buyVolume1.text = [NSString stringWithFormat:@"%.0f", buyVolume];
                [ValueUtil updateLabel:self.sellPrice1 withPrice:snapshot.nearestAskPrice[0] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:NO];
                self.sellVolume1.text = [NSString stringWithFormat:@"%.0f", sellVolume];
            }
            if (snapshot.nearestBidAskCount>=2) {
                double buyVolume = snapshot.nearestBidVolume[1]*pow(1000, snapshot.nearestBidVolumeUnit[1]);
                double sellVolume = snapshot.nearestAskVolume[1]*pow(1000, snapshot.nearestAskVolumeUnit[1]);
                
                [ValueUtil updateLabel:self.buyPrice2 withPrice:snapshot.nearestBidPrice[1] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:YES];
                self.buyVolume2.text = [NSString stringWithFormat:@"%.0f", buyVolume];
                [ValueUtil updateLabel:self.sellPrice2 withPrice:snapshot.nearestAskPrice[1] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:YES];
                self.sellVolume2.text = [NSString stringWithFormat:@"%.0f", sellVolume];
            }
            if (snapshot.nearestBidAskCount>=3) {
                double buyVolume = snapshot.nearestBidVolume[2]*pow(1000, snapshot.nearestBidVolumeUnit[2]);
                double sellVolume = snapshot.nearestAskVolume[2]*pow(1000, snapshot.nearestAskVolumeUnit[2]);
                
                [ValueUtil updateLabel:self.buyPrice3 withPrice:snapshot.nearestBidPrice[2] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:YES];
                self.buyVolume3.text = [NSString stringWithFormat:@"%.0f", buyVolume];
                [ValueUtil updateLabel:self.sellPrice3 withPrice:snapshot.nearestAskPrice[2] refPrice:snapshot.referencePrice ceilingPrice:snapshot.ceilingPrice floorPrice:snapshot.floorPrice whiteStyle:YES];
                self.sellVolume3.text = [NSString stringWithFormat:@"%.0f", sellVolume];
            }
        }
    }
}

-(void)reloadMarketInfo:(NSMutableArray *)dataArray{
    NSMutableArray * keyArray = [dataArray objectAtIndex:0];
    NSMutableArray * sectorIdArray = [dataArray objectAtIndex:1];
    CGFloat mainScreenWidth = CGRectGetWidth([UIScreen mainScreen].applicationFrame);

    CGFloat labelWidth2 = (mainScreenWidth-18)/3;
    
    double high = 0;
    double high2 = 0;
    for (int i = 0; i<[keyArray count]; i++) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, high, labelWidth2*2, 0)];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.text = [keyArray objectAtIndex:i];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor colorWithRed:0.083 green:0.491 blue:0.659 alpha:1.000];
        CGSize size = [[sectorIdArray objectAtIndex:i] sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        [titleLabel setFrame:CGRectMake(2, high, labelWidth2*2, size.height)];
        high += titleLabel.frame.size.height;
        [self alignLabelWithTop:titleLabel];
        [self.page4 addSubview:titleLabel];
    }
    
    for (int i = 0; i<[sectorIdArray count]; i++) {
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelWidth2 *1+2, i*25, labelWidth2*2, 0)];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.text = [sectorIdArray objectAtIndex:i];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor blueColor];
        CGSize size = [[sectorIdArray objectAtIndex:i] sizeWithFont:titleLabel.font constrainedToSize:CGSizeMake(titleLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        [titleLabel setFrame:CGRectMake(labelWidth2 *1+2, high2, labelWidth2*2, size.height)];
        high2 +=titleLabel.frame.size.height;
        [self alignLabelWithTop:titleLabel];
        [self.page4 addSubview:titleLabel];
    }
    [_scrollView setContentSize:CGSizeMake(mainScreenWidth, high2)];

}

- (void) alignLabelWithTop:(UILabel *)label {
    CGSize maxSize = CGSizeMake(label.frame.size.width, 999);
    label.adjustsFontSizeToFitWidth = NO;
    // get actual height
    CGSize actualSize = [label.text sizeWithFont:label.font constrainedToSize:maxSize lineBreakMode:label.lineBreakMode];
    
//    CGSize actualSize = [label.text boundingRectWithSize:maxSize
//                                                 options:NSStringDrawingUsesFontLeading
//                                              attributes:@{NSFontAttributeName: label.font}
//                                                 context:nil].size;
    
    CGRect rect = label.frame;
    rect.size.height = actualSize.height;
    label.frame = rect;
}

-(void)setLayout
{
    NSDictionary *viewsDictionary;
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"us"]) {
        viewsDictionary = NSDictionaryOfVariableBindings(_volTitleLabel, _volContentLabel, _chgTitleLabel, _chgContentLabel, _chgpTitleLabel, _chgpContentLabel, _epsTitleLabel, _epsContentLabel, _peTitleLabel, _peContentLabel, _openTitleLabel, _openContentLabel, _closeTitleLabel, _closeContentLabel, _highTitleLabel, _highContentLabel, _lowTitleLabel, _lowContentLabel, _week52HighTitleLabel, _week52HighContentLabel, _week52LowTitleLabel, _week52LowContentLabel, _todayVolTitleLabel, _todayVolContentLabel, _yesterdayVolTitleLabel, _yesterdayVolContentLabel, _volPTitleLabel, _volPContentLabel, _vol3MTitleLabel, _vol3MContentLabel);
        [self setUSLayout:viewsDictionary];
    }
    else if ([group isEqualToString:@"cn"]){
        viewsDictionary = NSDictionaryOfVariableBindings(_volTitleLabel, _volContentLabel, _chgTitleLabel, _chgContentLabel, _chgpTitleLabel, _chgpContentLabel, _epsTitleLabel, _epsContentLabel, _peTitleLabel, _peContentLabel, _openTitleLabel, _openContentLabel, _closeTitleLabel, _closeContentLabel, _highTitleLabel, _highContentLabel, _lowTitleLabel, _lowContentLabel, _week52HighTitleLabel, _week52HighContentLabel, _week52LowTitleLabel, _week52LowContentLabel, _todayVolTitleLabel, _todayVolContentLabel, _yesterdayVolTitleLabel, _yesterdayVolContentLabel, _volPTitleLabel, _volPContentLabel, _vol3MTitleLabel, _vol3MContentLabel,_buyView,_sellView,_buyTitleView,_buyLabelView,_sellTitleView,_sellLabelView,_buyTitleTopLabel,_buyTitleBottonLabel,_sellTitleTopLabel,_sellTitleBottonLabel,_buyPrice1,_buyPrice2,_buyPrice3,_buyVolume1,_buyVolume2,_buyVolume3,_sellPrice1,_sellPrice2,_sellPrice3,_sellVolume1,_sellVolume2,_sellVolume3);
        [self setCNLayout:viewsDictionary];
    }else{
        
    }
    
    
}


-(void)setUSLayout:(NSDictionary*)viewsDictionary{
    //第一頁
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_volTitleLabel][_volContentLabel(==_volTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chgTitleLabel][_chgContentLabel(==_volTitleLabel)]-5-[_chgpTitleLabel(==_volTitleLabel)][_chgpContentLabel(==_volTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_epsTitleLabel][_epsContentLabel(==_volTitleLabel)]-5-[_peTitleLabel(==_volTitleLabel)][_peContentLabel(==_volTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_chgTitleLabel(20)]-10-[_epsTitleLabel(20)]" options:0 metrics:nil views:viewsDictionary]];
    
    //第二頁
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_openTitleLabel][_openContentLabel(==_openTitleLabel)]-5-[_closeTitleLabel(==_openTitleLabel)][_closeContentLabel(==_openTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_highTitleLabel][_highContentLabel(==_openTitleLabel)]-5-[_lowTitleLabel(==_openTitleLabel)][_lowContentLabel(==_openTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_week52HighTitleLabel][_week52HighContentLabel(==_openTitleLabel)]-5-[_week52LowTitleLabel(==_openTitleLabel)][_week52LowContentLabel(==_openTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_openTitleLabel(20)]-10-[_highTitleLabel(20)]-10-[_week52HighTitleLabel(20)]" options:0 metrics:nil views:viewsDictionary]];
    
    //第三頁
    [self.page3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_todayVolTitleLabel][_todayVolContentLabel(==_todayVolTitleLabel)]-5-[_yesterdayVolTitleLabel(==_todayVolTitleLabel)][_yesterdayVolContentLabel(==_todayVolTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_volPTitleLabel][_volPContentLabel(==_todayVolTitleLabel)]-5-[_vol3MTitleLabel(==_todayVolTitleLabel)][_vol3MContentLabel(==_todayVolTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_todayVolTitleLabel(20)]-10-[_volPTitleLabel(20)]" options:0 metrics:nil views:viewsDictionary]];
}

-(void)setCNLayout:(NSDictionary*)viewsDictionary{
    //第一頁
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_openTitleLabel][_openContentLabel(==_openTitleLabel)]-5-[_closeTitleLabel(==_openTitleLabel)][_closeContentLabel(==_openTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_highTitleLabel][_highContentLabel(==_openTitleLabel)]-5-[_lowTitleLabel(==_openTitleLabel)][_lowContentLabel(==_openTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_week52HighTitleLabel][_week52HighContentLabel(==_openTitleLabel)]-5-[_week52LowTitleLabel(==_openTitleLabel)][_week52LowContentLabel(==_openTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_openTitleLabel(20)]-10-[_highTitleLabel(20)]-10-[_week52HighTitleLabel(20)]" options:0 metrics:nil views:viewsDictionary]];
    
    
    //第二頁
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_volTitleLabel(==_volTitleLabel)][_volContentLabel(==_volTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chgTitleLabel][_chgContentLabel(==_volTitleLabel)]-5-[_chgpTitleLabel(==_volTitleLabel)][_chgpContentLabel(==_volTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_epsTitleLabel][_epsContentLabel(==_volTitleLabel)]-5-[_peTitleLabel(==_volTitleLabel)][_peContentLabel(==_volTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page2 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_chgTitleLabel(20)]-10-[_epsTitleLabel(20)]" options:0 metrics:nil views:viewsDictionary]];
    
    //第三頁
    [self.page3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_todayVolTitleLabel][_todayVolContentLabel(==_todayVolTitleLabel)]-5-[_yesterdayVolTitleLabel(==_todayVolTitleLabel)][_yesterdayVolContentLabel(==_todayVolTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_volPTitleLabel][_volPContentLabel(==_todayVolTitleLabel)]-5-[_vol3MTitleLabel(==_todayVolTitleLabel)][_vol3MContentLabel(==_todayVolTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.page3 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_todayVolTitleLabel(20)]-10-[_volPTitleLabel(20)]" options:0 metrics:nil views:viewsDictionary]];
    
    //第四頁
    [self.page4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buyView]-20-|" options:0 metrics:nil views:viewsDictionary]];
    [self.page4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_sellView]-20-|" options:0 metrics:nil views:viewsDictionary]];
    [self.page4 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buyView][_sellView(==_buyView)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    
    [self.buyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buyTitleView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.buyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buyLabelView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.buyView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buyTitleView(25)][_buyLabelView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.buyTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buyTitleTopLabel]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
    [self.buyTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_buyTitleBottonLabel]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
    [self.buyTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buyTitleTopLabel]|" options:0 metrics:nil views:viewsDictionary]];
    [self.buyTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buyTitleBottonLabel]|" options:0 metrics:nil views:viewsDictionary]];
    
    [self.buyLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buyVolume1][_buyVolume2(==_buyVolume1)][_buyVolume3(==_buyVolume1)]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
    [self.buyLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_buyVolume1]-30-[_buyPrice1(==_buyVolume1)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.buyLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_buyVolume2]-30-[_buyPrice2(==_buyVolume2)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.buyLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_buyVolume3]-30-[_buyPrice3(==_buyVolume3)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.buyLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_buyPrice1(==_buyVolume1)]" options:0 metrics:nil views:viewsDictionary]];
    [self.buyLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_buyPrice2(==_buyVolume2)]" options:0 metrics:nil views:viewsDictionary]];
    [self.buyLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_buyPrice3(==_buyVolume3)]" options:0 metrics:nil views:viewsDictionary]];
    
    
    [self.sellView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_sellTitleView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.sellView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_sellLabelView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.sellView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_sellLabelView][_sellTitleView(25)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.sellTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_sellTitleTopLabel]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
    [self.sellTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_sellTitleBottonLabel]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
    [self.sellTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_sellTitleTopLabel]|" options:0 metrics:nil views:viewsDictionary]];
    [self.sellTitleView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_sellTitleBottonLabel]|" options:0 metrics:nil views:viewsDictionary]];
    
    [self.sellLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_sellPrice1][_sellPrice2(==_sellPrice1)][_sellPrice3(==_sellPrice1)]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:viewsDictionary]];
    [self.sellLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_sellPrice1][_sellVolume1(==_sellPrice1)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.sellLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_sellPrice2][_sellVolume2(==_sellPrice2)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.sellLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_sellPrice3][_sellVolume3(==_sellPrice3)]-3-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    [self.sellLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_sellVolume1(==_sellPrice1)]" options:0 metrics:nil views:viewsDictionary]];
    [self.sellLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_sellVolume2(==_sellPrice2)]" options:0 metrics:nil views:viewsDictionary]];
    [self.sellLabelView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_sellVolume3(==_sellPrice3)]" options:0 metrics:nil views:viewsDictionary]];
    
}


@end
