//
//  FSNewsContentViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/12.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSNewsContentViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "UIView+NewComponent.h"
#import "NewsContentOut.h"
#import "FSNetNewsViewController.h"


@interface FSNewsContentViewController ()<UIWebViewDelegate>{

    UILabel *navLabel;
    UILabel *newsTitleLabel;
    UITextView *mainTextView;
    FSUIButton *previewBtn;
    FSUIButton *nextBtn;
    UILabel *dateLabel;
    UILabel *pageLabel;
    int newsSN;
    int index;
    int maxCount;
    NSMutableArray *newsArray;
    NSString *navName;
    UIWebView *mainWebView;
    BOOL *isNetView;
}

@end

@implementation FSNewsContentViewController

-(instancetype)initWithNewsSN:(int)sn index:(int)idx array:(NSMutableArray *)newsDataArray{
    if (self = [super init]) {
        newsSN = sn;
        index = idx;
        newsArray = [NSMutableArray arrayWithArray:newsDataArray];
    }
    return self;
}

-(instancetype)initWithNewsIndex:(int)idx array:(NSMutableArray *)newsDataArray net:(BOOL)netView name:(NSString *)navname{
    if (self = [super init]) {
        navName = navname;
        isNetView = &netView;
        index = idx;
        newsArray = [NSMutableArray arrayWithArray:newsDataArray];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self setUpImageBackButton];
    
    [self.view showHUDWithTitle:@"資料搜尋中,請稍後..."];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];

    if (!isNetView){
         [dataModel.newsDataModel setTarget:self];
         [dataModel.newsDataModel sendNewsContent:newsSN];
        
        maxCount = [dataModel.newsDataModel loadDBCountWithSectorID:[NewsObject sharedInstance].sectorID];
        navName = [dataModel.newsDataModel loadDBCatNameWithSectorID:[NewsObject sharedInstance].sectorID];
    }else{
        FinancialNews *newsObj = [newsArray objectAtIndex:index - 1];
        
        newsTitleLabel.text = newsObj.tableViewTitle;
        dateLabel.text = newsObj.urlContentTime;
        navLabel.text = [NSString stringWithFormat:@"網路新聞/%@", navName];
        pageLabel.text = [NSString stringWithFormat:@"%d/%d", index, (int)[newsArray count]];
        mainWebView.scalesPageToFit = YES;

        [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newsObj.content]]];
        [dataModel.newsDataModel setHadReadNet:newsObj.content];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)initView{

    navLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 40)];
    navLabel.textColor = [UIColor whiteColor];
    navLabel.font = [UIFont boldSystemFontOfSize:19.0];


    UIView *btnContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 170, 40)];
    [btnContainer addSubview:navLabel];
    
    self.navigationItem.titleView = btnContainer;

    newsTitleLabel = [UILabel new];
    newsTitleLabel.backgroundColor = [UIColor colorWithRed:255/255 green:233.0f/255 blue:169.0f/255 alpha:1];
    newsTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    newsTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    newsTitleLabel.numberOfLines = 0;
    [self.view addSubview:newsTitleLabel];
//    
//    mainTextView = [UITextView new];
//    mainTextView.translatesAutoresizingMaskIntoConstraints = NO;
//    mainTextView.backgroundColor = [UIColor whiteColor];
//    mainTextView.font = [UIFont systemFontOfSize:18];
//    mainTextView.editable = NO;
//    mainTextView.userInteractionEnabled = YES;
//    mainTextView.bounces = NO;
//
//    [self.view addSubview:mainTextView];
//    
//    

    previewBtn = [self.view newButton:FSUIButtonTypeNormalBlue];
    previewBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [previewBtn setTitle:@"上一則" forState:UIControlStateNormal];
    previewBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [previewBtn addTarget:self action:@selector(previousNews) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previewBtn];

    nextBtn = [self.view newButton:FSUIButtonTypeNormalBlue];
    nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [nextBtn setTitle:@"下一則" forState:UIControlStateNormal];
    nextBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [nextBtn addTarget:self action:@selector(nextNews) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    pageLabel = [UILabel new];
    pageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [pageLabel setAdjustsFontSizeToFitWidth:YES];

    [self.view addSubview:pageLabel];
    
    dateLabel = [UILabel new];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dateLabel];
    
    mainWebView = [UIWebView new];
    mainWebView.translatesAutoresizingMaskIntoConstraints = NO;
//    webView.userInteractionEnabled = YES;
    mainWebView.delegate = self;
    mainWebView.scrollView.bounces = NO;
//    webView.scalesPageToFit = YES;
    [self.view addSubview:mainWebView];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints{

    [super updateViewConstraints];
    
    NSMutableArray *contraints = [NSMutableArray new];
    
    NSDictionary *viewContraints = NSDictionaryOfVariableBindings(newsTitleLabel, previewBtn, nextBtn, pageLabel, dateLabel, mainWebView);
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[newsTitleLabel]|" options:0 metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainWebView]|" options:0 metrics:nil views:viewContraints]];
    
//    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTextView]|" options:0 metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainWebView]-[dateLabel(22)]-[previewBtn(44)]|" options:0 metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainWebView]-[dateLabel(22)]-[nextBtn(44)]|" options:0 metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainWebView]-[dateLabel(22)]-[pageLabel(44)]|" options:0 metrics:nil views:viewContraints]];
    
//    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainTextView]-[dateLabel(22)]-[previewBtn(44)]|" options:0 metrics:nil views:viewContraints]];
//    
//    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainTextView]-[dateLabel(22)]-[nextBtn(44)]|" options:0 metrics:nil views:viewContraints]];
//    
//    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsTitleLabel(44)][mainTextView]-[dateLabel(22)]-[pageLabel(44)]|" options:0 metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewBtn(100)]-34-[pageLabel]-24-[nextBtn(100)]|" options:0 metrics:nil views:viewContraints]];
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dateLabel(>=80)]" options:0 metrics:nil views:viewContraints]];
    
    
    [self replaceCustomizeConstraints:contraints];
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FinancialNews *newsObj = [array objectAtIndex:0];
    
    newsTitleLabel.text = newsObj.tableViewTitle;
    dateLabel.text = [dataModel.newsDataModel makeDateStringByDate:newsObj.tableViewDate time:newsObj.tableViewTime];
    
    mainWebView.scalesPageToFit = NO;
    if (newsObj.type == 1 && newsObj.sectorID != 177 ) {
        NSString *str1 = [newsObj.content stringByReplacingOccurrencesOfString:@"<table fix=1>" withString:@"<table fix=1 border=1>"];
        NSString *str2 = @"<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=5.0; user-scalable=0;\">";
        str1 = [str2 stringByAppendingString:str1];
        
//        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[str1 dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        mainTextView.attributedText = attributedString;
        
        [mainWebView loadHTMLString:str1 baseURL:nil];
    }else{
//        mainTextView.text = newsObj.content;
        newsObj.content = [newsObj.content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        [mainWebView loadHTMLString:newsObj.content baseURL:nil];

    }
    navLabel.text = navName;
    pageLabel.text = [NSString stringWithFormat:@"%d/%d", index, maxCount];
    
    [self.view hideHUD];
}

-(void)previousNews{
    if (index == 1) {
        UIAlertView *minAlert = [[UIAlertView alloc]initWithTitle:@"新聞頂端" message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [minAlert show];
        return;
    }else{
        index --;
        if (!isNetView){
            [self sendImmediateNewSn];
            
        }else{
            [self sendImmediateNetNewSn];
            
        }
    }
}

-(void)nextNews{
    if (index == maxCount){
        UIAlertView *maxAlert = [[UIAlertView alloc]initWithTitle:@"新聞底端" message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [maxAlert show];
        return;
    }else{
        index ++;
        if (!isNetView){
            [self sendImmediateNewSn];

        }else{
            [self sendImmediateNetNewSn];

        }
    }
}

-(void)sendImmediateNewSn{
    [self.view showHUDWithTitle:@"資料搜尋中,請稍後..."];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FinancialNews *newsObj = [newsArray objectAtIndex:index - 1];
    [dataModel.newsDataModel sendNewsContent:newsObj.newsSN];
    pageLabel.text = [NSString stringWithFormat:@"%d/%d", index, maxCount];
}
-(void)sendImmediateNetNewSn{
    [self.view showHUDWithTitle:@"資料搜尋中,請稍後..."];
    
//    isNetView = NO;
    
    FinancialNews *newsObj = [newsArray objectAtIndex:index - 1];
    newsTitleLabel.text = newsObj.tableViewTitle;
    dateLabel.text = newsObj.urlContentTime;
    navLabel.text = [NSString stringWithFormat:@"網路新聞/%@", navName];
    pageLabel.text = [NSString stringWithFormat:@"%d/%d", index, (int)[newsArray count]];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:newsObj.content]]];
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    [dataModel.newsDataModel setHadReadNet:newsObj.content];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    NSLog(@"Current URL = %@",webView.request.URL);
    [self.view hideHUD];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
