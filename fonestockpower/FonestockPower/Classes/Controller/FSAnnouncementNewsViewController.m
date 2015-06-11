//
//  FSAnnouncementNewsViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/14.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSAnnouncementNewsViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSNewsSnDataOut.h"
#import "FSNewsTitleDataOut.h"
#import "RelatedNewsListCell.h"
#import "FSNewsDataModel.h"
#import "FSRadioButtonSet.h"
#import "RelatedNewsDetailViewController.h"
#import "FSNewsContentViewController.h"
#import "FSStockNewsViewController.h"
#import "FSTendencyViewController.h"
#import "FSGeneralNewsViewController.h"
#import "FSWeatherNewsViewController.h"
#import "FSFinancialNewsViewController.h"
#import "FSLotteryNewsViewController.h"
#import "FSNetNewsViewController.h"
#import "FSLauncherPageViewController.h"

#define SECTORID 171
#define PARENTID 627
#define TITLENAME @"公告特報"

@interface FSAnnouncementNewsViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, FSRadioButtonSetDelegate>{
    
    FSUIButton *titleBtn;
    FSRadioButtonSet *btnSet;
    FinancialNews *newObj;
    FSNewsDataModel *newsModel;
    FSDataModelProc *dataModel;
    NSMutableArray *btnArray;
    NSMutableArray *btnNameArray;
    NSMutableArray *tableViewArray;
    UITableView *mainTableView;
    UIScrollView *scrollView;
    
    UIActionSheet *navSheet;
    
    BOOL firstSend;
}

@end

@implementation FSAnnouncementNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

    [self.navigationController setNavigationBarHidden:NO];
    [self.view showHUDWithTitle:@"資料搜尋中,請稍後..."];
    
    [dataModel.newsDataModel setTarget:self];
    if (!firstSend) {
        [NewsObject sharedInstance].sectorID = SECTORID;
    }else{
        [dataModel.newsDataModel sendPacketWithSectorID:[NewsObject sharedInstance].sectorID];
    }
    [titleBtn setTitle:TITLENAME forState:UIControlStateNormal];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [dataModel.newsDataModel setTarget:nil];
}

-(void)initView{
    [self setUpImageBackButton];
    dataModel = [FSDataModelProc sharedInstance];
    [dataModel.newsDataModel sendPacketWithRootID];
    
    
    titleBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeDetailYellow];

    [titleBtn setFrame:CGRectMake(0, 0, 150, 40)];
    [titleBtn addTarget:self action:@selector(changeTable) forControlEvents:UIControlEventTouchUpInside];
    UIView *btnContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
    [btnContainer addSubview:titleBtn];
    
    self.navigationItem.titleView = btnContainer;
    
    
    mainTableView = [[UITableView alloc] init];
    mainTableView.bounces = NO;
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.backgroundColor = [UIColor whiteColor];
    mainTableView.separatorColor = [UIColor darkGrayColor];
    mainTableView.layer.borderWidth = 1.0;
    
    mainTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
    
    [self loadDB];
    
    [self.view setNeedsUpdateConstraints];
    
    
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    
    NSMutableArray *contraints = [NSMutableArray new];
    NSDictionary *viewContraints = NSDictionaryOfVariableBindings(scrollView, mainTableView);
    
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]" options:0 metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewContraints]];
    [contraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]-2-[mainTableView]|" options:0 metrics:nil views:viewContraints]];
    
    [self replaceCustomizeConstraints:contraints];
}

-(void)loadDB{
    
    btnNameArray = [dataModel.newsDataModel loadDB:PARENTID];
    int width = 0;
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    btnArray = [NSMutableArray new];
    for (int i = 0; i < [btnNameArray count]; i++){
        
        newObj = [btnNameArray objectAtIndex:i];
        int strLen = (int)newObj.btnName.length;
        
        FSUIButton *btn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:19.0f]];
        [btn setTitle:newObj.btnName forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(width, 0, strLen * 20, 40)];
        [btn setTag:i];
        
        [btnArray addObject:btn];
        
        if (btn.tag == 0){
            btn.selected = YES;
        }
        
        [scrollView addSubview:btn];
        
        width += strLen * 20 + 2;
        
    }
    btnSet = [[FSRadioButtonSet alloc]initWithButtonArray:btnArray andDelegate:self];
    
    [scrollView setContentSize:CGSizeMake(width, 40)];
    [self.view addSubview:scrollView];
}
- (void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex{
    
    [self.view showHUDWithTitle:@"資料搜尋中,請稍後..."];
    
    newObj = [btnNameArray objectAtIndex:selectedIndex];
    [dataModel.newsDataModel sendPacketWithSectorID:newObj.catID];
    [NewsObject sharedInstance].sectorID = newObj.catID;
    
    
}

-(void)changeTable{
    navSheet = [[UIActionSheet alloc]initWithTitle:@"請選擇新聞分類" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    int i;
    for(i = 0; i < [[dataModel.newsDataModel loadDBNavNameWithRootID] count]; i++){
        NSString *navActionName = [[dataModel.newsDataModel loadDBNavNameWithRootID] objectAtIndex:i];
        if ([navActionName isEqualToString:@"全球財金"]) {
            navActionName = @"財金分析";
        }
        [navSheet addButtonWithTitle:navActionName];
    }
    [navSheet addButtonWithTitle:@"網路新聞"];
    navSheet.cancelButtonIndex = [navSheet addButtonWithTitle:@"取消"];
    
    [navSheet showInView:self.view];
    
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex < actionSheet.numberOfButtons - 1) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex]isEqual:TITLENAME]) {
            return;
        }else{
            UIViewController *nextView = nil;
            if (buttonIndex == 0) {
                FSGeneralNewsViewController *newView = [FSGeneralNewsViewController new];
                nextView = newView;
            }else if (buttonIndex == 1){
                FSFinancialNewsViewController *newView = [FSFinancialNewsViewController new];
                nextView = newView;
            }else if (buttonIndex == 2){
                FSStockNewsViewController *newView = [FSStockNewsViewController new];
                nextView = newView;
            }else if (buttonIndex == 3){
                FSTendencyViewController *newView = [FSTendencyViewController new];
                nextView = newView;
            }else if (buttonIndex == 4){
                FSAnnouncementNewsViewController *newView = [FSAnnouncementNewsViewController new];
                nextView = newView;
            }else if (buttonIndex == 5){
                FSWeatherNewsViewController *newView = [FSWeatherNewsViewController new];
                nextView = newView;
            }else if (buttonIndex == 6){
                FSLotteryNewsViewController *newView = [FSLotteryNewsViewController new];
                nextView = newView;
            }else if (buttonIndex == 7){
                FSNetNewsViewController *newView = [FSNetNewsViewController new];
                nextView = newView;
            }
            [self.navigationController pushViewController:nextView animated:NO];
        }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableViewArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RelatedNewsListCell";
    RelatedNewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    newObj = [tableViewArray objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[RelatedNewsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.titleLabel.numberOfLines = 2;
    
    if (newObj.hadRead == 0) {
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.datetimeLabel.textColor = [UIColor blackColor];
    }else{
        cell.titleLabel.textColor = [UIColor orangeColor];
        cell.datetimeLabel.textColor = [UIColor orangeColor];
    }
    cell.titleLabel.text = newObj.tableViewTitle;
    
    cell.datetimeLabel.text = [dataModel.newsDataModel makeDateStringByDate:newObj.tableViewDate time:newObj.tableViewTime];
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    newObj = [tableViewArray objectAtIndex:indexPath.row];
    
    
    FSNewsContentViewController *contentView = [[FSNewsContentViewController alloc]initWithNewsSN:newObj.newsSN index:(int)indexPath.row + 1 array:tableViewArray];
    
    [self.navigationController pushViewController:contentView animated:NO];
}

-(void)rootSectorIDDataArrive{
    
    [dataModel.newsDataModel sendPacketWithSectorID:[NewsObject sharedInstance].sectorID];
    firstSend = YES;
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    
    if ([(NSNumber *)[array lastObject]intValue] == 0) {
        UIAlertView *nillAlert = [[UIAlertView alloc]initWithTitle:@"目前無最新資料,請稍後再試..." message:nil delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [nillAlert show];
    }
    
    tableViewArray = [NSMutableArray arrayWithArray:array];
    [tableViewArray removeLastObject];
    
    [mainTableView reloadData];
    
    [self.view hideHUD];
    
    
}
- (void)setUpImageBackButton {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"BackButton"] forState:UIControlStateNormal];
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationItem.hidesBackButton = YES;
}

-(void)popCurrentViewController{
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[FSLauncherPageViewController class]]) {
            [self.navigationController popToViewController:aViewController animated:NO];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
