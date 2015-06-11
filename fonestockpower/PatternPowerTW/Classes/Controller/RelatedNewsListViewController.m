//
//  RelatedNewsListViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/6/28.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//  相關新聞

#import "RelatedNewsListViewController.h"
#import "RelatedNewsListCell.h"
#import "RelatedNewsDetailViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"

@implementation RelatedNewsListViewController
@synthesize relatedNewsData;
@synthesize portfolioItem;
@synthesize mainView;
@synthesize collectionView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    mainView = [[UITableView alloc] init];
    mainView.delegate = self;
    mainView.dataSource = self;
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.separatorColor = [UIColor darkGrayColor];
    mainView.layer.borderWidth = 1.0;
    mainView.frame = self.view.frame;
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainView];
//	if(self.portfolioItem->fullName)
//		self.navigationItem.title = self.portfolioItem->fullName;
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:166.0f/255.0f green:27.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(loadData)];
    [self loadData];

}

-(void)loadData{
    [self.view showHUDWithTitle:@"Waiting..."];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    relatedNewsData = dataModal.relatedNewsData;
    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
	[relatedNewsData selectRelated:[portfolioItem getIdentCodeSymbol]];
    self.count = [relatedNewsData getCount];
    [relatedNewsData setTarget:self];
//    [mainView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [relatedNewsData setTarget:nil];
    [self unregisterLoginNotificationCallBack:self];
}

- (void)notify{
	self.count = [relatedNewsData getCount];
    [relatedNewsData setTarget:self];
	[mainView reloadData];
    [self.view hideHUD];
}

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [relatedNewsData getCount];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  77;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RelatedNewsDetailViewController *relatedNewsDetailViewController = [RelatedNewsDetailViewController new];
    relatedNewsDetailViewController.portfolioItem = portfolioItem;
	relatedNewsDetailViewController.titleIndex = indexPath.row;
	relatedNewsDetailViewController.newsCount = [relatedNewsData getCount];
    
    [self.navigationController pushViewController:relatedNewsDetailViewController animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RelatedNewsListCell";
    RelatedNewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RelatedNewsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UInt32 newsSN;
    UInt16 date;
    UInt16 time;
    UInt8 hadRead;
    int year, month, day;
    int hour, minute;
    NSString *strTime;
    
    NSString *titleString = [relatedNewsData getTitleAt:(int)indexPath.row andDate:&date andTime:&time andHadRead:&hadRead andNewsSN:&newsSN];
    cell.titleLabel.numberOfLines = 2;
    cell.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", titleString];
    cell.datetimeLabel.text = [NSString stringWithFormat:@"%@", titleString];
    if (hadRead == 1){ // means the news hadRead
        cell.titleLabel.textColor = [UIColor orangeColor];
        cell.datetimeLabel.textColor = [UIColor orangeColor];
    }
    else{
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.datetimeLabel.textColor = [UIColor blackColor];
    }
    year = (date>>9) + 1960;
    month = (date>>5) & 0XF;
    day = date & 0X1F;
    NSString *strDate = [NSString stringWithFormat:@"%d/%02d/%02d  ", year, month, day];
    
    // transfer UInt16 time to normal time presentation
    if (time == 1440)
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
    NSString *timeStamp = [strDate stringByAppendingString:strTime];
    
//    cell.datetimeLabel.textColor = [UIColor orangeColor];
    cell.datetimeLabel.text = timeStamp;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}
- (void)dealloc{
}

@end
