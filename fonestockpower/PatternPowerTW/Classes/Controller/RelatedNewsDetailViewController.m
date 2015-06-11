//
//  RelatedNewsDetailViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/7/1.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "RelatedNewsDetailViewController.h"
#import "CodingUtil.h"
#import "UIView+NewComponent.h"
#import "UIViewController+CustomNavigationBar.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "NewSymbolKeywordOut.h"
#import "NewSymbolKeywordIn.h"

@implementation RelatedNewsDetailViewController
@synthesize portfolioItem;
@synthesize titleIndex;
@synthesize newsCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    [self setUpImageBackButton];

    if(self.portfolioItem->fullName)
		self.navigationItem.title = self.portfolioItem->fullName;
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	relatedNewsData = dataModal.relatedNewsData;
    
    // 新聞標題Label
    newsTitleLabel = [UILabel new];
    newsTitleLabel.backgroundColor = [UIColor colorWithRed:255/255 green:233.0f/255 blue:169.0f/255 alpha:1];
    newsTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;    
    newsTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    newsTitleLabel.numberOfLines = 0;
    
    mainTextView = [UITextView new];
    mainTextView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTextView.backgroundColor = [UIColor whiteColor];
    mainTextView.font = [UIFont systemFontOfSize:18];
    mainTextView.editable = NO;
    
    // 按鈕
    previewBtn = [self.view newButton:FSUIButtonTypeNormalBlue];
    previewBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [previewBtn setTitle:@"上一則" forState:UIControlStateNormal];
    previewBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [previewBtn addTarget:self action:@selector(previousNews) forControlEvents:UIControlEventTouchUpInside];
    // 按鈕
    nextBtn = [self.view newButton:FSUIButtonTypeNormalBlue];
    nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];

    [nextBtn setTitle:@"下一則" forState:UIControlStateNormal];
    nextBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [nextBtn addTarget:self action:@selector(nextNews) forControlEvents:UIControlEventTouchUpInside];
    
    
    pageLabel = [UILabel new];
    pageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [pageLabel setAdjustsFontSizeToFitWidth:YES];
    pageLabel.text = @"1/30";
    
    dateLabel = [UILabel new];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:newsTitleLabel];
    [self.view addSubview:mainTextView];
    [self.view addSubview:previewBtn];
    [self.view addSubview:nextBtn];
    [self.view addSubview:pageLabel];
    [self.view addSubview:dateLabel];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(newsTitleLabel, mainTextView, previewBtn, nextBtn, pageLabel, dateLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[newsTitleLabel]|" options:0 metrics:nil views:viewControllers]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTextView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainTextView]-[dateLabel(22)]-[previewBtn(44)]|" options:0 metrics:nil views:viewControllers]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainTextView]-[dateLabel(22)]-[nextBtn(44)]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainTextView]-[dateLabel(22)]-[pageLabel(44)]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewBtn(100)]-34-[pageLabel]-24-[nextBtn(100)]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dateLabel(>=80)]" options:0 metrics:nil views:viewControllers]];
}

- (void)viewWillAppear:(BOOL)animated {
    [relatedNewsData setTarget:self];
    
    UInt32 newsSN;
    UInt16 date;
    UInt16 time;
    UInt8 hadRead;
    
    NSString *titleString = [relatedNewsData getTitleAt:(int)titleIndex andDate:&date andTime:&time andHadRead:&hadRead andNewsSN:&newsSN];
    NSString *contentString = [relatedNewsData getContentAt:(int)titleIndex andSN:newsSN];
    NSString *dateString = [self makeDateStringByDate:date time:time];
    dateLabel.text = dateString;
    newsTitleLabel.text = titleString;
    
//    self.newsSerialNumber = newsSN;
    
    if (!contentString)
    {        
        if(contentString==nil)
            contentString = @"Loading...";
        
    }
    
    mainTextView.text = contentString;
    [self showNewsPage:&titleIndex andCount:&newsCount];
}

//-(void)searchNewsRelativeStock{
//    UInt32 newsSN;
//    UInt16 date;
//    UInt16 time;
//    UInt8 hadRead;
//    
//    [relatedNewsData getTitleAt:titleIndex andDate:&date andTime:&time andHadRead:&hadRead andNewsSN:&newsSN];
//    
//    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://kqquery.fonestock.com:2172/query/news.cgi?news_num=%u", (unsigned int)newsSN]];
//    NSString *xmlStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
//    DDXMLDocument *xml = [[DDXMLDocument alloc] initWithXMLString:xmlStr options:0 error:nil];
//    NSArray *stockArray = [xml nodesForXPath:@"/news/related_symbols/symbol" error:nil];
//    for (DDXMLElement *element in stockArray) {
//        NSString *identCode = [[element elementForName:@"ident_code"] stringValue];
//        NSString *stockCode = [[element elementForName:@"stock_code"] stringValue];
//        NSString *fullName = [dataModal.securitySearchModel searchFullNameWithIdentCode:identCode Symbol:stockCode];
//        if ([fullName isEqualToString:@""]) {
//            UInt16 *IdentCode = malloc(sizeof(UInt16)*1);
//            IdentCode[0] = 'T'*16 +'W';
//            UInt8 *SecurityType = malloc(sizeof(UInt8)*2);
//            SecurityType[0] = 1;
//
//            NewSymbolKeywordOut* packet = [[NewSymbolKeywordOut alloc] initWithIdentCount:1 IdentCode:IdentCode countPage:5 Page_No:1 FieldType:0 SearchType:1];
//            [packet setSecurityCount:1 SecurityType:SecurityType];
//            [packet setKeyword:stockCode];
//            [FSDataModelProc sendData:self WithPacket:packet];
//            fullName = [dataModal.securitySearchModel searchFullNameWithIdentCode:identCode Symbol:stockCode];
//        }
//    }
//}

- (void)viewWillDisappear:(BOOL)animated {
	[relatedNewsData setTarget:nil];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];

}

- (NSString *)makeDateStringByDate:(UInt16)date time:(UInt16)time {
	
	int year, month, day;
	int hour, minute;
	NSString *strTime;
	// transfer UInt16 date to normal date presentation
	year = (date>>9) + 1960;
	month = (date>>5) & 0XF;
	day = date & 0X1F;
	NSString *strDate = [NSString stringWithFormat:@"%d/%02d/%02d  ", year, month, day];
	
	// transfer UInt16 time to normal time presentation
	if (time >= 1440)
	{
		strTime = @"--:--";
	}
	else
	{
		hour = time/60;
		minute = time%60;
		strTime = [NSString stringWithFormat:@"  %02d:%02d", hour, minute];
	}
	// combine strDate and strTime
	NSString *dateString = [strDate stringByAppendingString:strTime];
	
	return dateString;
	
}

- (void)notify
{
	
	UInt32 newsSN;
	UInt16 date;
	UInt16 time;
	UInt8 hadRead;
	
	NSString *titleString = [relatedNewsData getTitleAt:(int)titleIndex andDate:&date andTime:&time andHadRead:&hadRead andNewsSN:&newsSN];
	NSString *contentString = [relatedNewsData getContentAt:(int)self.titleIndex andSN:newsSN];
//	NSString *dateString = [self makeDateStringByDate:date time:time];
	
	
    newsTitleLabel.text = titleString;
    mainTextView.text = contentString;
    
	[self.view setNeedsDisplay];
}


- (void)previousNews {
    if (titleIndex <= 0) return;
    
//    self.navigationItem.title = nil;
    
    --titleIndex;
    [self showNewsPage:&titleIndex andCount:&newsCount];
    UInt32 newsSN;
	UInt16 date;
	UInt16 time;
	UInt8 hadRead;
    
    NSString *titleString = [relatedNewsData getTitleAt:(int)titleIndex andDate:&date andTime:&time andHadRead:&hadRead andNewsSN:&newsSN];
    
//    self.navigationItem.title = titleString;
    
	NSString *dateString = [self makeDateStringByDate:date time:time];
    dateLabel.text = dateString;
    mainTextView.text = [relatedNewsData getContentAt:(int)self.titleIndex andSN:newsSN];
    
    
    NSString *contentString = [relatedNewsData getContentAt:(int)titleIndex andSN:newsSN];
//    NSString *dateString = [self makeDateStringByDate:date time:time];
    
    newsTitleLabel.text = titleString;
    
    //    self.newsSerialNumber = newsSN;
    
    if (!contentString)
    {
        if(contentString==nil)
            contentString = @"Loading...";
        
    }
    
    mainTextView.text = contentString;
}

- (void)nextNews {
    if (titleIndex+1 >= newsCount)		return;
    
//    self.navigationItem.title = nil;
    
    titleIndex++;
    [self showNewsPage:&titleIndex andCount:&newsCount];
    UInt32 newsSN;
	UInt16 date;
	UInt16 time;
	UInt8 hadRead;
    
    NSString *titleString = [relatedNewsData getTitleAt:(int)titleIndex andDate:&date andTime:&time andHadRead:&hadRead andNewsSN:&newsSN];
    
//    self.navigationItem.title = titleString;
    
	NSString *dateString = [self makeDateStringByDate:date time:time];
    dateLabel.text = dateString;
    mainTextView.text = [relatedNewsData getContentAt:(int)self.titleIndex andSN:newsSN];
    
    
    NSString *contentString = [relatedNewsData getContentAt:(int)titleIndex andSN:newsSN];
    //    NSString *dateString = [self makeDateStringByDate:date time:time];
    
    newsTitleLabel.text = titleString;
    
    //    self.newsSerialNumber = newsSN;
    
    if (!contentString)
    {
        if(contentString==nil)
            contentString = @"Loading...";
        
    }
    
    mainTextView.text = contentString;
    
}
- (void) showNewsPage: (NSInteger*) index andCount:(NSInteger*) count
{
	// set showCurPageOfTotal
	NSString *curNo = [NSString stringWithFormat:@"%02d/", (int)*index+1];
	NSString *totalNo = [NSString stringWithFormat:@"%02d", (int)*count];
	NSString *curOfTotal = [curNo stringByAppendingString:totalNo];
	pageLabel.text = curOfTotal;
}

@end
