//
//  FigureSearchConditionViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/23.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchConditionViewController.h"
#import "BtnCollectionView.h"
#import "FigureTrackListViewController.h"
#import "FigureSearchResultViewController.h"
#import "FigureSearchMyProfileModel.h"
#import "FigureCustomCaseViewController.h"
#import "KxMenu.h"
#import "FSMainViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "FSTeachPopView.h"
#import "UIViewController+CustomNavigationBar.h"
#import "SecuritySearchDelegate.h"
#import "DDPageControl.h"
#import "FSTeachPopDelegate.h"
#import "FigureSearchUS.h"
#import "FigureSearchCheckBoxTableViewCell.h"
#import "RadioTableViewCell.h"
#import "SearchCriteriaModel.h"
#import "SearchCriteriaViewController.h"


#define SECTOR_DIAN_TOU      2     // 店頭市場
#define SECTOR_JI_JHONG     21     // 集中市場
#define SECTOR_SHANG_JIAO   101    //上交所
#define SECTOR_SHEN_JIAO    121    //深交所
#define SECTOR_NYSE         296     //NYSE
#define SECTOR_NASDAQ       297     //NASDAQ
#define SECTOR_AMEX         298     //AMEX

#define indicatorNumberOfTables 5

@interface FigureSearchConditionViewController ()<UIAlertViewDelegate,FigureSearchDelegate,SecuritySearchDelegate,UIScrollViewDelegate,FSTeachPopDelegate, UITextViewDelegate>
{
    SearchCriteriaViewController *searchViewController;
    NSMutableDictionary *searchDict;
    UILabel *placeholder;
}
@property (strong, nonatomic)FSInstantInfoWatchedPortfolio * watchedPortfolio;

@property (strong ,nonatomic)FigureSearchUS * figureSearchUS;
@property (nonatomic)enum FigureSearchUSFeeType searchType;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DDPageControl *pageControl;
@property (unsafe_unretained, nonatomic) NSInteger numberOfPages;

@property (strong, nonatomic) UIView * searchView;
@property (strong, nonatomic) UIView * infoView;
@property (strong, nonatomic) UIImageView * infoImageView;
@property (strong, nonatomic) UITextView * infoTextView;

@property (unsafe_unretained, nonatomic) NSInteger selectedOptionIndex;

@property (nonatomic) int searchNum;
@property (nonatomic) int currentOption;
@property (strong , nonatomic)NSString * functionName;
@property (nonatomic)int searchGroup;//1:Day 2:week 3:month

@property (strong , nonatomic) UIImageView * imageView;
@property (strong , nonatomic) UILabel * nameLabel;
@property (strong , nonatomic) UIView * nameLineView;

@property (strong , nonatomic) FSUIButton * dayLineBtn;
@property (strong , nonatomic) FSUIButton * weekLineBtn;
@property (strong , nonatomic) FSUIButton * monthLineBtn;
@property (strong , nonatomic) FSUIButton * considerationsBtn;
@property (strong , nonatomic) FSUIButton * trackBtn;

@property (strong, nonatomic) UIView *trackResultRectView;
@property (strong, nonatomic) UILabel *trackLabel;
@property (strong, nonatomic) NSMutableArray * btnDataArray;
@property (strong, nonatomic) NSMutableArray * btnNameArray;
@property (strong, nonatomic) NSMutableArray * btnIdArray;
@property (strong, nonatomic)BtnCollectionView * collectionViewBtn;

@property (strong, nonatomic) UILabel *detailView;

@property (strong , nonatomic) FSUIButton * searchBtn;
@property (strong , nonatomic) FSUIButton * lastBtn;

@property (strong , nonatomic) UIAlertView * changeAlert;
@property (strong , nonatomic) UIAlertController *changeAlertController;
@property (strong , nonatomic) UIAlertView * searchResultAlert;
@property (strong , nonatomic) UIAlertController * serchResultAlertController;

@property (strong , nonatomic) FigureSearchMyProfileModel * customModel;
@property (strong, nonatomic) NSMutableArray * figureSearchArray;
@property (strong, nonatomic) NSArray * moreOptionIconsEquation;
@property (strong, nonatomic) NSArray * zeroOptionIconsEquation;

@property (strong, nonatomic)NSString * resultEquationName;
@property (strong, nonatomic)NSString * resultTargetMarket;
@property (nonatomic)int resultDataAmount;
@property (nonatomic)int resultTotalAmount;
@property (strong, nonatomic)NSDate * resultDataDate;
@property (strong, nonatomic) NSArray * resultDataArray;
@property (strong, nonatomic) NSArray * resultMarkPriceArray;

@property (strong, nonatomic)UIAlertView * resultAlert;
@property (strong, nonatomic)UIAlertController *resultAlertController;
@property (strong, nonatomic)UIAlertView * searchAlert;
@property (strong, nonatomic)UIAlertController *searchAlertController;

@property (strong, nonatomic) FSTeachPopView * explainView;
@property (strong, nonatomic) FSUIButton *inSessionSearchButton;
@property (strong, nonatomic) FSUIButton *presiousSessionButton;
@property (strong, nonatomic) NSString * opportunity;
@property (strong, nonatomic) NSString *system;
@end

@implementation FigureSearchConditionViewController

- (id)initWithCurrentOption:(enum CurrentOption)current SearchNum:(int)searchNumber
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.currentOption = current;
        self.searchNum = searchNumber;
        if (current==0||current==1) {
            self.navigationItem.title = NSLocalizedStringFromTable(@"圖示選股", @"FigureSearch", nil);
        }else if (current==2||current==3){
            self.navigationItem.title = NSLocalizedStringFromTable(@"用戶自定", @"FigureSearch", nil);
        }
        if(current==0){
            _system = @"LongSystem";
        }else if(current==1){
            _system = @"ShortSystem";
        }
    }
    return self;
}

- (void)viewDidLoad
{

    [self setUpImageBackButton];
    searchDict = [[NSMutableDictionary alloc]init];
    self.customModel = [[FigureSearchMyProfileModel alloc]init];
    self.figureSearchArray = [[NSMutableArray alloc]init];
    self.btnNameArray = [[NSMutableArray alloc]init];
    self.btnDataArray = [[NSMutableArray alloc]init];
    [self initformulaArray];
    [self initScrollView];
    [self initView];
    
    [self initPageControl];
    [self initImage];
    [self initBtn];
    [self initCollectionView];
    _dayLineBtn.selected = YES;
    
    if (_currentOption==2 || _currentOption==3) {
        _infoTextView.editable = YES;
        
        FSUIButton *editButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
        [editButton setFrame:CGRectMake(0, 0, 60, 40)];
        [editButton setTitle:NSLocalizedStringFromTable(@"編輯", @"FigureSearch", nil) forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(barButtonClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        
//        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        negativeSpacer.width = 15;
        
        NSArray *itemArray = [[NSArray alloc] initWithObjects:rightBarButtonItem, nil];
        
        [self.navigationItem setRightBarButtonItems:itemArray];

        //self.navigationItem.rightBarButtonItem = rightBarButtonItem;
//        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, rightBarButtonItem, nil];
    }
    
    [self.view setNeedsUpdateConstraints];
    
    
    
    
    NSString * show = [_customModel searchInstructionByControllerName:[[self class] description]];
    if ([show isEqualToString:@"YES"]) {
        [self teachPop];
    }
    
    self.watchedPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    
    [super viewDidLoad];

}

-(void)initSearchView
{
    searchViewController = [[SearchCriteriaViewController alloc] initWithName:[NSString stringWithFormat:@"%@Search%d",_system, _searchNum]];
    [searchViewController setTarget:self];
}


-(void)barButtonClick{
    self.changeAlert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"重新編輯圖形，將會清空追蹤資料，是否重編?", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"FigureSearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil), nil];
    [_changeAlert show];
}

- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:self.scrollView];
}

- (void)initPageControl {
    self.numberOfPages = 2;
    self.pageControl = [[DDPageControl alloc] init];
    self.pageControl.numberOfPages = self.numberOfPages;
    self.pageControl.currentPage = 0;
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor redColor]];
	[self.pageControl setOffColor: [UIColor redColor]];
	[self.pageControl setIndicatorDiameter: 7.0f] ;
	[self.pageControl setIndicatorSpace: 7.0f] ;
    
    [self.view addSubview:self.pageControl];
}

-(void)initView{
    self.searchView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.scrollView addSubview:_searchView];
    
    self.infoView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.scrollView addSubview:_infoView];
    
    self.infoImageView  = [[UIImageView alloc]init];
    _infoImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_infoView addSubview:_infoImageView];
    
    self.infoTextView = [[UITextView alloc]init];
    _infoTextView.delegate = self;
    _infoTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _infoTextView.editable = NO;
    _infoTextView.font = [UIFont systemFontOfSize:18.0f];
    _infoTextView.backgroundColor = [UIColor clearColor];
    [self.infoView addSubview:_infoTextView];
    
    placeholder = [[UILabel alloc] init];
    placeholder.userInteractionEnabled = NO;
    placeholder.font = [UIFont boldSystemFontOfSize:30.0f];
    placeholder.text = @"請輸入筆記";
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.textColor = [UIColor grayColor];
    [self.infoView addSubview:placeholder];
}

-(void)resetTrackArray{
    NSString * searchName;
    if (_searchGroup==1) {
        searchName = NSLocalizedStringFromTable(@"Day", @"FigureSearch", nil);
    }else if (_searchGroup==2){
        searchName = NSLocalizedStringFromTable(@"Week", @"FigureSearch", nil);
    }else if (_searchGroup ==3){
        searchName = NSLocalizedStringFromTable(@"Month", @"FigureSearch", nil);
    }
    
    [_btnNameArray removeAllObjects];
    [_btnDataArray removeAllObjects];
    _btnDataArray = [_customModel searchAllTrackWithFigureSearchId:[_figureSearchArray objectAtIndex:0] RangeType:searchName];
    if (![_btnDataArray count]==0) {
        for (int i=0; i<[_btnDataArray count]; i++) {
            TrackUpFormat * data = [_btnDataArray objectAtIndex:i];

            NSString * appid = [FSFonestock sharedInstance].appId;
            NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
            if ([group isEqualToString:@"us"]) {
                [_btnNameArray addObject:[NSString stringWithFormat:@"%@",data->symbol]];
            }else{
                [_btnNameArray addObject:data->fullName];
            }
        }
    }
    [_collectionViewBtn reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"FigureSearch.plist"];
    searchDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    int session = [(NSNumber *)[searchDict objectForKey:@"session"]intValue];
    int type = [(NSNumber *)[searchDict objectForKey:@"searchType"]intValue];
    _presiousSessionButton.selected = NO;
    _inSessionSearchButton.selected = NO;
    _dayLineBtn.selected = NO;
    _weekLineBtn.selected = NO;
    _monthLineBtn.selected = NO;
    if (session == 0) {
        _inSessionSearchButton.selected = YES;
        self.opportunity = _inSessionSearchButton.titleLabel.text;
    }else{
        _presiousSessionButton.selected = YES;
        self.opportunity = _presiousSessionButton.titleLabel.text;
    }
    if (type == 0) {
        _dayLineBtn.selected = YES;
        _searchGroup = 1;
    }else if (type == 1){
        _weekLineBtn.selected = YES;
        _searchGroup = 2;
    }else{
        _monthLineBtn.selected = YES;
        _searchGroup = 3;
    }
    [self initSearchView];
    if([searchViewController.formula isEqualToString:@""]){
        self.considerationsBtn.selected = NO;
    }else{
        self.considerationsBtn.selected = YES;
    }
    [self.navigationController setNavigationBarHidden:NO];
    self.figureSearchUS = [[FSDataModelProc sharedInstance] figureSearchUS];
    _figureSearchUS.delegate = self;
    NSString * gategory =@"";
    
    if (_currentOption ==0) {
        gategory = @"LongSystem";
        self.functionName = NSLocalizedStringFromTable(@"圖示選股", @"FigureSearch", nil);
    }else if (_currentOption ==1){
        gategory = @"ShortSystem";
        self.functionName = NSLocalizedStringFromTable(@"圖示選股", @"FigureSearch", nil);
    }else if (_currentOption ==2){
        gategory = @"LongCustom";
        self.functionName = NSLocalizedStringFromTable(@"用戶自定", @"FigureSearch", nil);
    }else if (_currentOption ==3){
        gategory = @"ShortCustom";
        self.functionName = NSLocalizedStringFromTable(@"用戶自定", @"FigureSearch", nil);
    }
    _figureSearchArray = [_customModel searchFigureSearchIdWithGategory:gategory ItemOrder:[NSNumber numberWithInt:_searchNum]];
    [self setImageAndTitle];
    [self resetTrackArray];
    [self setInfoText];
}

-(void)viewWillDisappear:(BOOL)animated{
    [_customModel editdifinitionWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Difinition:_infoTextView.text];
    _figureSearchUS.delegate = nil;
    NSString *pathDate = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"FigureSearch.plist"]];
    int session;
    int type;
    
    if (_inSessionSearchButton.selected == YES) {
        session = 0;
    }else{
        session = 1;
    }
    if (_dayLineBtn.selected == YES) {
        type = 0;
    }else if (_weekLineBtn.selected == YES){
        type = 1;
    }else{
        type = 2;
    }
   NSMutableDictionary * dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:session],@"session",[NSNumber numberWithInt:type],@"searchType", nil];

    BOOL sdf = [dict writeToFile:pathDate atomically:YES];
    NSLog(@"%d",sdf);
    [super viewWillDisappear:animated];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_scrollView,_imageView, _dayLineBtn,_weekLineBtn,_monthLineBtn,_trackBtn,_searchBtn,_lastBtn,_trackResultRectView,_trackLabel,_collectionViewBtn, _inSessionSearchButton, _presiousSessionButton,_infoTextView,_infoImageView,_considerationsBtn, placeholder);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]-22-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoTextView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_infoTextView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:placeholder attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_infoTextView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    if (_currentOption==0 || _currentOption==1) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-110-[_infoImageView(100)]" options:0 metrics:nil views:viewControllers]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_infoImageView(100)]-10-[_infoTextView]|" options:0 metrics:nil views:viewControllers]];
    }else{
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_infoTextView]|" options:0 metrics:nil views:viewControllers]];
    }
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_imageView(80)]-1-[_inSessionSearchButton]-1-[_presiousSessionButton(120)]-1-|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_inSessionSearchButton]-1-[_presiousSessionButton(120)]" options:NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_imageView(76)]" options:NSLayoutFormatAlignAllTop metrics:nil views:viewControllers]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_imageView]-1-[_dayLineBtn]-1-[_weekLineBtn(==_dayLineBtn)]-1-[_monthLineBtn(==_dayLineBtn)]-1-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_searchBtn]-1-[_lastBtn(==_searchBtn)]-1-[_trackBtn(==_searchBtn)]-1-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:viewControllers]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_inSessionSearchButton(38)]" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_dayLineBtn(38)][_considerationsBtn(38)][_searchBtn(38)]-1-[_trackResultRectView]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_weekLineBtn(==_dayLineBtn)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_monthLineBtn(==_dayLineBtn)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_considerationsBtn]-1-|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_trackResultRectView]-2-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_trackLabel(20)]-2-[_collectionViewBtn]|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_trackLabel]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionViewBtn]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_trackBtn(==_searchBtn)]" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lastBtn(==_searchBtn)]" options:0 metrics:nil views:viewControllers]];
    
    [self replaceCustomizeConstraints:constraints];
    
}

- (void)viewDidLayoutSubviews {
    
    [self.scrollView setContentSize: CGSizeMake(self.scrollView.bounds.size.width * self.numberOfPages, self.scrollView.bounds.size.height)];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width * self.pageControl.currentPage, 0);
    
    [self.pageControl setCenter:CGPointMake(self.scrollView.center.x, self.view.bounds.size.height - 10)];
    
    [self.searchView setFrame:CGRectMake(self.scrollView.bounds.size.width * 0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.infoView setFrame:CGRectMake(self.scrollView.bounds.size.width * 1, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    
    [self.view layoutSubviews];
}

-(void)initImage{
    self.imageView = [[UIImageView alloc]init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchView addSubview:_imageView];
}

-(void)setImageAndTitle{
    UIImage * image = [UIImage imageWithData:[_figureSearchArray objectAtIndex:5]];
    [_imageView setImage:image];
    
    self.navigationItem.title = NSLocalizedStringFromTable([_figureSearchArray objectAtIndex:1], @"FigureSearch", nil) ;
}

-(void)initBtn{
    self.dayLineBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_dayLineBtn setTitle:NSLocalizedStringFromTable(@"日線", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_dayLineBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _dayLineBtn.tag = 1;
    _dayLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchView addSubview:_dayLineBtn];
    
    self.weekLineBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_weekLineBtn setTitle:NSLocalizedStringFromTable(@"週線", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_weekLineBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _weekLineBtn.tag = 2;
    _weekLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchView addSubview:_weekLineBtn];
    
    self.monthLineBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [_monthLineBtn setTitle:NSLocalizedStringFromTable(@"月線", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_monthLineBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _monthLineBtn.tag = 3;
    _monthLineBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchView addSubview:_monthLineBtn];
    
    self.trackBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    [_trackBtn setTitle:NSLocalizedStringFromTable(@"追蹤", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_trackBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _trackBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchView addSubview:_trackBtn];
    
    self.searchBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    _searchBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_searchBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchBtn setTitle:NSLocalizedStringFromTable(@"搜尋", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_searchView addSubview:_searchBtn];
    
    self.lastBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalBlue];
    _lastBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_lastBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_lastBtn setTitle:NSLocalizedStringFromTable(@"最新", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_searchView addSubview:_lastBtn];
    
    self.inSessionSearchButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _inSessionSearchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_inSessionSearchButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_inSessionSearchButton setTitle:NSLocalizedStringFromTable(@"盤中", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_searchView addSubview:_inSessionSearchButton];
    
    self.presiousSessionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _presiousSessionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_presiousSessionButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    _presiousSessionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_presiousSessionButton setTitle:NSLocalizedStringFromTable(@"盤後", @"FigureSearch", nil) forState:UIControlStateNormal];
    
    //[_inSessionSearchButton setEnabled:NO];
    [_presiousSessionButton setSelected:YES];
//    self.opportunity = _inSessionSearchButton.titleLabel.text;
    
    self.considerationsBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    _considerationsBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_considerationsBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_considerationsBtn setTitle:NSLocalizedStringFromTable(@"條件2", @"FigureSearch", nil) forState:UIControlStateNormal];
    [_searchView addSubview:_considerationsBtn];
    
    [_searchView addSubview:_presiousSessionButton];
    
}

-(void)btnClick:(UIButton *)btn{
    
    if ([btn isEqual:_trackBtn]) {
        NSString * searchName;
        if (_searchGroup==1) {
            searchName = NSLocalizedStringFromTable(@"Day", @"FigureSearch", nil);
        }else if (_searchGroup==2){
            searchName = NSLocalizedStringFromTable(@"Week", @"FigureSearch", nil);
        }else if (_searchGroup ==3){
            searchName = NSLocalizedStringFromTable(@"Month", @"FigureSearch", nil);
        }
        
        NSMutableArray * trackArray = [_customModel searchAllTrackWithFigureSearchId:[_figureSearchArray objectAtIndex:0] RangeType:searchName];
        
        if (![trackArray count]==0) {
            //go to track page
            FigureTrackListViewController * trackList = [[FigureTrackListViewController alloc]initWithTrackUpArray:trackArray FigureSearchName:[_figureSearchArray objectAtIndex:1] FigureSearchId:[_figureSearchArray objectAtIndex:0]  Range:searchName];
            [self.navigationController pushViewController:trackList animated:NO];
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:self.functionName message:NSLocalizedStringFromTable(@"無追蹤股票", @"FigureSearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil) otherButtonTitles:nil];
            [alert show];
        }
        
    }else if ([btn isEqual:_searchBtn]){
        if (_inSessionSearchButton.selected) {
            self.opportunity = _inSessionSearchButton.titleLabel.text;
        }else if(_presiousSessionButton.selected){
            self.opportunity = _presiousSessionButton.titleLabel.text;
        }
        if (_dayLineBtn.selected) {
            _searchGroup = 1;
        }else if (_weekLineBtn.selected){
            _searchGroup = 2;
        }else if (_monthLineBtn.selected){
            _searchGroup = 3;
        }
        [self goSearch];
    }else if ([btn isEqual:_lastBtn]){
        // search DB  find last time search
        NSString * searchName;
        if (_searchGroup==1) {
            searchName = @"Day";
        }else if (_searchGroup==2){
            searchName = @"Week";
        }else if (_searchGroup ==3){
            searchName = @"Month";
        }
        
        NSMutableArray * dataArray = [_customModel searchLastResultWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Range:searchName SearchType:self.opportunity];
        
        if ([dataArray count]==0) {
            [FSHUD showMsg:NSLocalizedStringFromTable(@"無搜尋記錄", @"FigureSearch", nil)];
        }else{
            NSMutableArray * allArray = [_customModel searchFigureSearchResultDataWithFigureSearchResultInfoId:[dataArray objectAtIndex:0]];
            NSMutableArray * data = [[NSMutableArray alloc]initWithArray:@[]];
            NSMutableArray * markPriceArray = [[NSMutableArray alloc]initWithArray:@[]];
            if ([allArray count]>0) {
                data = [allArray objectAtIndex:0];
                markPriceArray =[allArray objectAtIndex:1];
            }
            FigureSearchResultViewController * resultView = [[FigureSearchResultViewController alloc]initWithFigureSearchId:[_figureSearchArray objectAtIndex:0] FuctionName:_functionName conditionName:[_figureSearchArray objectAtIndex:1] searchGroup:searchName datetime:[dataArray objectAtIndex:1] Opportunity:self.opportunity targetMarket:[dataArray objectAtIndex:2] totalAmount:[(NSNumber *)[dataArray objectAtIndex:3] intValue] displayAmount:(int)[data count] dataArray:data markPriceArray:markPriceArray];
            [self.navigationController pushViewController:resultView animated:NO];
        }
    }else if ([btn isEqual:_inSessionSearchButton]||[btn isEqual:_presiousSessionButton]){
        
        if ([btn isEqual:_inSessionSearchButton]) {
            if ([[FSFonestock sharedInstance] checkPermission:FSPermissionTypePatternSearchInSession showAlertViewToShopping:YES]) {
            } else {
                return;
            }
        }
        _inSessionSearchButton.selected = NO;
        _presiousSessionButton.selected = NO;
        btn.selected = YES;
        self.opportunity = btn.titleLabel.text;
        [self resetTrackArray];
    }else if([btn isEqual:_considerationsBtn]){
        [self.navigationController pushViewController:searchViewController animated:NO];
    }else{
        
        _searchGroup = (int)btn.tag;
        _dayLineBtn.selected = NO;
        _weekLineBtn.selected = NO;
        _monthLineBtn.selected = NO;
        btn.selected = YES;
        [self resetTrackArray];
        //search DB  find track
        //collectionView reload
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:_changeAlert]) {
        if (buttonIndex == 1) {
            FigureCustomCaseViewController * customCaseView = [[FigureCustomCaseViewController alloc]initWithCurrentOption:_currentOption SearchNum:_searchNum];
            
            [self.navigationController pushViewController:customCaseView animated:NO];
        }
    }else if ([alertView isEqual:_resultAlert]){
        if (buttonIndex == 0) { // 確認
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString * date  = [dateFormatter stringFromDate:self.resultDataDate];
            NSDate *currentDate = [dateFormatter dateFromString:date];
            NSString * searchName;
            if (_searchGroup==1) {
                searchName = @"Day";
            }else if (_searchGroup==2){
                searchName = @"Week";
            }else if (_searchGroup ==3){
                searchName = @"Month";
            }
            
            [_customModel editFigureSearchResultInfoWithFigureSearchId:[_figureSearchArray objectAtIndex:0] RangeType:searchName SearchDate:currentDate SearchRange:_resultTargetMarket Total:[NSNumber numberWithInt:_resultTotalAmount] SearchType:self.opportunity];
            
            if (_resultTotalAmount == 0){
                [_customModel deleteFigureSearchResultDataWithFigureSearchResultInfoId:[_figureSearchArray objectAtIndex:0]];
                return;   // 沒有符合的stock, 故不進入搜尋結果
            }
            
            NSMutableArray * data = [_customModel searchLastResultWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Range:searchName SearchType:self.opportunity];
            [_customModel editFigureSearchResultDataWithFigureSearchResultInfoId:[data objectAtIndex:0] DataArray:_resultDataArray MarkPriceArray:_resultMarkPriceArray];
            
            FigureSearchResultViewController * resultView = [[FigureSearchResultViewController alloc]initWithFigureSearchId:[_figureSearchArray objectAtIndex:0] FuctionName:_functionName conditionName:[_figureSearchArray objectAtIndex:1] searchGroup:searchName datetime:currentDate Opportunity:self.opportunity targetMarket:_resultTargetMarket totalAmount:_resultTotalAmount displayAmount:_resultDataAmount dataArray:_resultDataArray markPriceArray:_resultMarkPriceArray];
            [self.navigationController pushViewController:resultView animated:NO];
        }
    }else if([alertView isEqual:_searchAlert]){
        if (buttonIndex==1) {
        }
    }
    
}

-(void)alertControllerAction:(int)target sender:(UIAlertController *)sender
{
    if(sender == _changeAlertController){
        if (target == 1) {
            FigureCustomCaseViewController * customCaseView = [[FigureCustomCaseViewController alloc]initWithCurrentOption:_currentOption SearchNum:_searchNum];
            
            [self.navigationController pushViewController:customCaseView animated:NO];
        }
    }else if(sender == _resultAlertController){
        if (target == 0) { // 確認
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString * date  = [dateFormatter stringFromDate:self.resultDataDate];
            NSDate *currentDate = [dateFormatter dateFromString:date];
            NSString * searchName;
            if (_searchGroup==1) {
                searchName = @"Day";
            }else if (_searchGroup==2){
                searchName = @"Week";
            }else if (_searchGroup ==3){
                searchName = @"Month";
            }
            
            [_customModel editFigureSearchResultInfoWithFigureSearchId:[_figureSearchArray objectAtIndex:0] RangeType:searchName SearchDate:currentDate SearchRange:_resultTargetMarket Total:[NSNumber numberWithInt:_resultTotalAmount] SearchType:self.opportunity];
            
            if (_resultTotalAmount == 0){
                [_customModel deleteFigureSearchResultDataWithFigureSearchResultInfoId:[_figureSearchArray objectAtIndex:0]];
                return;   // 沒有符合的stock, 故不進入搜尋結果
            }
            
            NSMutableArray * data = [_customModel searchLastResultWithFigureSearchId:[_figureSearchArray objectAtIndex:0] Range:searchName SearchType:self.opportunity];
            [_customModel editFigureSearchResultDataWithFigureSearchResultInfoId:[data objectAtIndex:0] DataArray:_resultDataArray MarkPriceArray:_resultMarkPriceArray];
            
            FigureSearchResultViewController * resultView = [[FigureSearchResultViewController alloc]initWithFigureSearchId:[_figureSearchArray objectAtIndex:0] FuctionName:_functionName conditionName:[_figureSearchArray objectAtIndex:1] searchGroup:searchName datetime:currentDate Opportunity:self.opportunity targetMarket:_resultTargetMarket totalAmount:_resultTotalAmount displayAmount:_resultDataAmount dataArray:_resultDataArray markPriceArray:_resultMarkPriceArray];
            [self.navigationController pushViewController:resultView animated:NO];
        }
    }
}

-(NSString *)makeFormulaWithFigureSearchId:(NSNumber *)figureSearchId SearchGroup:(int)searchGroup{
    NSString * formula = @"";
    int maxDay;
    int trend = [_customModel searchTrendTypeByFigureSearch_ID:[_figureSearchArray objectAtIndex:0]];
    NSMutableArray * trendValue = [_customModel searchTrendValueByFigureSearch_ID:[_figureSearchArray objectAtIndex:0]];
    if ([trendValue count]>0) {
        if (trend==0) {
            //upLine
            formula = @"MAX#TRENDPARAM#(#RANGE#0HIGH) >= MAX#TRENDSPEC#(#RANGE#0HIGH) and MIN#TRENDPARAM#(#RANGE#0PRC_MA#TRENDSPEC1#) >= MAX#TRENDSPEC#(#RANGE##MONTRENDPARAM#PRC_MA#TRENDSPEC1#)";
            
            formula = [formula stringByReplacingOccurrencesOfString:@"#TRENDSPEC#" withString:[NSString stringWithFormat:@"%d",[(NSNumber *)[trendValue objectAtIndex:0] intValue]]];
        }else if (trend==1){
            //downLine
            formula = @"MIN#TRENDPARAM#(#RANGE#0LOW) <= MIN#TRENDSPEC#(#RANGE#0LOW) and MAX#TRENDPARAM#(#RANGE#0PRC_MA#TRENDSPEC1#) <= MIN#TRENDSPEC#(#RANGE##MONTRENDPARAM#PRC_MA#TRENDSPEC1#)";
            formula = [formula stringByReplacingOccurrencesOfString:@"#TRENDSPEC#" withString:[NSString stringWithFormat:@"%d",[(NSNumber *)[trendValue objectAtIndex:1] intValue]]];
        }else if (trend==2){
            formula = @"MAX#TRENDSPEC#(#RANGE#1PRC_MA#MONTRENDPARAM#)/MIN#TRENDSPEC#(#RANGE#1PRC_MA#MONTRENDPARAM#)<#FLATTREND#";
            formula = [formula stringByReplacingOccurrencesOfString:@"#TRENDSPEC#" withString:[NSString stringWithFormat:@"%d",[(NSNumber *)[trendValue objectAtIndex:2] intValue]]];
        }

    }
    
    for (int i =0; i<5; i++) {
        NSMutableArray * dataArray = [[NSMutableArray alloc]init];
        dataArray = [_customModel searchCustomKbarWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:i]];
        if (![dataArray count]==0) {
            maxDay = i;
            if ([formula isEqualToString:@""]) {
                formula = [self makeFormulaWithDay:i SearchGroup:searchGroup];
            }else{
                formula = [formula stringByReplacingOccurrencesOfString:@"#DAY+1#" withString:[NSString stringWithFormat:@"%d",i]];
                formula = [NSString stringWithFormat:@"%@ and %@",formula,[self makeFormulaWithDay:i SearchGroup:searchGroup]];
            }
        }
    }
    formula = [formula stringByReplacingOccurrencesOfString:@"#DAY+1#" withString:[NSString stringWithFormat:@"%d",maxDay+1]];
    
    return formula;
}

-(CGFloat)countingPositiveAndNegative:(CGFloat)inPut
{
    CGFloat retNum = 0.0;
    if(inPut < 0){
        retNum = floorf(inPut);
    }else{
        retNum = ceilf(inPut);
    }
    return retNum;
    //約等於的時候才需要取整數，大於或小於的時候就直接取該百分比
}

#pragma mark 計算的公式主要在這邊，漲、跌時代入的公式也不一樣
-(NSString *)makeFormulaWithDay:(int)day SearchGroup:(int)searchGroup{
    NSString * formula = @"";
    NSString * highLine = @"(if(#RANGE##DAY#LAST>=#RANGE##DAY#OPEN)then(#RANGE##DAY#HIGH - #RANGE##DAY#LAST)else(#RANGE##DAY#HIGH - #RANGE##DAY#OPEN)end/#RANGE##DAY+1#LAST)";
    NSString * rect = @"(if(#RANGE##DAY#LAST>=#RANGE##DAY#OPEN)then(#RANGE##DAY#LAST - #RANGE##DAY#OPEN)else(#RANGE##DAY#OPEN - #RANGE##DAY#LAST)end/#RANGE##DAY+1#LAST)";
    NSString * lowLine = @"(if(#RANGE##DAY#LAST>=#RANGE##DAY#OPEN)then(#RANGE##DAY#OPEN - #RANGE##DAY#LOW)else(#RANGE##DAY#LAST - #RANGE##DAY#LOW)end/#RANGE##DAY+1#LAST)";
    NSString * pctChange = @"#RANGE##DAY#PCT_CHG";
    
    NSMutableArray * dataArray = [[NSMutableArray alloc]init];
    dataArray = [_customModel searchCustomKbarWithFigureSearchId:[_figureSearchArray objectAtIndex:0] TNumber:[NSNumber numberWithInt:day]];
    
    NSMutableArray * conditionArray = [_customModel searchkBarConditionsWithFigureSearchId:[_figureSearchArray objectAtIndex:0] tNumber:[NSNumber numberWithInt:day]];
    
    float high  = [(NSNumber *)[dataArray objectAtIndex:0]floatValue]*100;
    float low   = [(NSNumber *)[dataArray objectAtIndex:1]floatValue]*100;
    float open  = [(NSNumber *)[dataArray objectAtIndex:2]floatValue]*100;
    float close = [(NSNumber *)[dataArray objectAtIndex:3]floatValue]*100;
    printf("searchGroup=%d\n",searchGroup);
    float rate=1;
    if(searchGroup==1){
        rate=[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]/10;//因為DB中的型態數值是以10%為範圍存放 所以須做日的換算
    }
    else if(searchGroup==2){
        rate=[(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/10;//週
    }
    else if(searchGroup==3){
        rate=[(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/10;//月
    }
    if (open>=close) {
        highLine =[self setRangeWithString:highLine Range:(high-open)*rate SearchGroup:searchGroup Equation:[(NSNumber *)[conditionArray objectAtIndex:2]intValue]];
        rect = [self setRangeWithString:rect Range:(open-close)*rate SearchGroup:searchGroup Equation:[(NSNumber *)[conditionArray objectAtIndex:3]intValue]];
        lowLine = [self setRangeWithString:lowLine Range:(close-low)*rate SearchGroup:searchGroup Equation:[(NSNumber *)[conditionArray objectAtIndex:4]intValue]];
    }else if (close>open){
        highLine =[self setRangeWithString:highLine Range:(high-close)*rate SearchGroup:searchGroup Equation:[(NSNumber *)[conditionArray objectAtIndex:2]intValue]];
        rect = [self setRangeWithString:rect Range:(close-open)*rate SearchGroup:searchGroup Equation:[(NSNumber *)[conditionArray objectAtIndex:3]intValue]];
        lowLine = [self setRangeWithString:lowLine Range:(open-low)*rate SearchGroup:searchGroup Equation:[(NSNumber *)[conditionArray objectAtIndex:4]intValue]];
    }
    pctChange = [self setChangeRangeWithString:pctChange Range:close*rate SearchGroup:searchGroup Equation:[(NSNumber *)[conditionArray objectAtIndex:0]intValue]];
    
    NSString * riseStr =@"(#RANGE##DAY#LAST >= #RANGE##DAY#OPEN)";
    NSString * downStr = @"(#RANGE##DAY#OPEN > #RANGE##DAY#LAST)";
    
    if ([[conditionArray objectAtIndex:0]boolValue] == YES) {
        formula = [self getFormula:formula formulaChild:pctChange];
    }
    if([[conditionArray objectAtIndex:1]boolValue] == YES){
//        if([(NSNumber *)[conditionArray objectAtIndex:1] intValue] == 1 || [[conditionArray objectAtIndex:1] isEqualToString:@"YES"]){
        if([[conditionArray objectAtIndex:1] isEqualToString:@"1"]){
            formula = [self getFormula:formula formulaChild:riseStr];
        }else{
            formula = [self getFormula:formula formulaChild:downStr];
        }
    }
    if ([[conditionArray objectAtIndex:2]boolValue] == YES) {
        formula = [self getFormula:formula formulaChild:highLine];
    }
    if ([[conditionArray objectAtIndex:3]boolValue] == YES) {
        formula = [self getFormula:formula formulaChild:rect];
    }
    if ([[conditionArray objectAtIndex:4]boolValue] == YES) {
        formula = [self getFormula:formula formulaChild:lowLine];
    }
    
    formula = [formula stringByReplacingOccurrencesOfString:@"#DAY#" withString:[NSString stringWithFormat:@"%d",day]];
    
    return formula;
}

-(NSString *)getFormula:(NSString *)formula formulaChild:(NSString *)child
{
    if([formula isEqualToString:@""]){
        return child;
    }else{
        return [NSString stringWithFormat:@"%@ and %@", formula, child];
    }
}

-(NSString *)setRangeWithString:(NSString *)string Range:(float)range SearchGroup:(int)searchGroup Equation:(int)equation{

    NSString * returnStr = @"";
    
    if(equation == 0) return returnStr;
    //約等於的公式改成實際值的加、減10%，所以把原本0、2、4…等所需用到的程式註解掉了
//    float rangeA;
//    float rangeB;
//    float rangeC;
//    float rangeD;
//    float rangeE;
    
//    if (_searchGroup ==1) {
//        rangeA = 0.02;
//        rangeB = 0.04;
//        rangeC = 0.06;
//        rangeD = 0.08;
//        rangeE = 0.01;
//    }else if (_searchGroup==2){
//        rangeA = 0.05;
//        rangeB = 0.10;
//        rangeC = 0.15;
//        rangeD = 0.20;
//        rangeE = 0.25;
//        range = range * ([(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
//    }else if (_searchGroup==3){
//        rangeA = 0.10;
//        rangeB = 0.20;
//        rangeC = 0.30;
//        rangeD = 0.40;
//        rangeE = 0.50;
//        range = range * ([(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
//    }
    if(equation == 1){
        returnStr = [NSString stringWithFormat:@"%@ >= %f",string,range/100];
    }else if(equation == 2){
        returnStr = [NSString stringWithFormat:@"%@ <= %f",string,range/100];
    }else if(equation == 3){
        float rangeLess;
        float rangePlus;
        float judgeRange = fabs(range);
        if(judgeRange <= 1){
            rangePlus = range * 1.5;
            rangeLess = range * 0.5;
        }else if(1 < judgeRange && judgeRange <= 2){
            rangePlus = range * 1.3;
            rangeLess = range * 0.7;
        }else if(2 < judgeRange && judgeRange <= 3){
            rangePlus = range * 1.2;
            rangeLess = range * 0.8;
        }else{
            rangePlus = range * 1.1;
            rangeLess = range * 0.9;
        }
        if(range > 0)
            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangeLess/100,string,rangePlus/100];
        else if(range < 0)
            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangePlus/100,string,rangeLess/100];
        else
            returnStr = [NSString stringWithFormat:@"%@ == 0",string];
        //約等於的公式改為依range 的值做不同比例的加、減，所以把原本加、減10% 的程式註解掉了
//        float rangeLess = range * 0.9;
//        float rangePlus = range * 1.1;
//        if(range < 0){
//            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangePlus/100,string,rangeLess/100];
//        }else{
//            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangeLess/100,string,rangePlus/100];
//        }
        //約等於的公式改成實際值的加、減10%，所以把原本0、2、4…等所需用到的程式註解掉了
//        range = [self countingPositiveAndNegative:range];
//        if (range==0) {
//            returnStr = [NSString stringWithFormat:@"%@ = 0.0",string];
//        }else if (range>0&&range<=rangeA*100){
//            returnStr = [NSString stringWithFormat:@"%@ > 0.0 and %@ <=%.2f",string,string,rangeA];
//        }else if (range>rangeA*100 && range <=rangeB*100){
//            returnStr = [NSString stringWithFormat:@"%@ > %.2f and %@ <=%.2f",string,rangeA,string,rangeB];
//        }else if (range>rangeB*100 && range <=rangeC*100){
//            returnStr = [NSString stringWithFormat:@"%@ > %.2f and %@ <=%.2f",string,rangeB,string,rangeC];
//        }else if (range>rangeC*100 && range <=rangeD*100){
//            returnStr = [NSString stringWithFormat:@"%@ > %.2f and %@ <=%.2f",string,rangeC,string,rangeD];
//        }else if (range>rangeD*100 && range <=rangeE*100){
//            returnStr = [NSString stringWithFormat:@"%@ > %.2f and %@ <=%.2f",string,rangeD,string,rangeE];
//        }else if (range>rangeE*100){
//            returnStr = [NSString stringWithFormat:@"%@ > %.2f",string,rangeE];
//        }
    }
    return returnStr;
    
}

-(NSString *)setChangeRangeWithString:(NSString *)string Range:(float)range SearchGroup:(int)searchGroup Equation:(int)equation{
    NSString * returnStr = @"";
    if(equation == 0)return returnStr;
    //約等於的公式改成實際值的加、減10%，所以把原本0、2、4…等所需用到的程式註解掉了
//    int rangeA;
//    int rangeB;
//    int rangeC;
//    int rangeD;
//    int rangeE;
    
//    if (_searchGroup ==1) {
//        rangeA = 2;
//        rangeB = 4;
//        rangeC = 6;
//        rangeD = 8;
//        rangeE = 10;
//    }else if (_searchGroup==2){
//        rangeA = 5;
//        rangeB = 10;
//        rangeC = 15;
//        rangeD = 20;
//        rangeE = 25;
//        range = range * ([(NSNumber *)[_figureSearchArray objectAtIndex:3]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
//    }else if (_searchGroup==3){
//        rangeA = 10;
//        rangeB = 20;
//        rangeC = 30;
//        rangeD = 40;
//        rangeE = 50;
//        range = range * ([(NSNumber *)[_figureSearchArray objectAtIndex:4]floatValue]/[(NSNumber *)[_figureSearchArray objectAtIndex:2]floatValue]);
//    }
    
    if(equation == 1){
        returnStr = [NSString stringWithFormat:@"%@ >= %f",string,range];
    }else if(equation == 2){
        returnStr = [NSString stringWithFormat:@"%@ <= %f",string,range];
    }else if(equation == 3){
        float rangeLess;
        float rangePlus;
        float judgeRange = fabs(range);
        if(judgeRange <= 1){
            rangePlus = range * 1.5;
            rangeLess = range * 0.5;
        }else if(1 < judgeRange && judgeRange <= 2){
            rangePlus = range * 1.3;
            rangeLess = range * 0.7;
        }else if(2 < judgeRange && judgeRange <= 3){
            rangePlus = range * 1.2;
            rangeLess = range * 0.8;
        }else{
            rangePlus = range * 1.1;
            rangeLess = range * 0.9;
        }
        if(range > 0)
            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangeLess,string,rangePlus];
        else if(range < 0)
            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangePlus,string,rangeLess];
        else
            returnStr = [NSString stringWithFormat:@"%@ == 0",string];
//        float rangeLess = range * 0.9;
//        float rangePlus = range * 1.1;
//        if(range < 0){
//            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangePlus,string,rangeLess];
//        }else{
//            returnStr = [NSString stringWithFormat:@"%@ > %f and %@ <= %f",string,rangeLess,string,rangePlus];
//        }
        //約等於的公式改成實際值的加、減10%，所以把原本0、2、4…等所需用到的程式註解掉了
//        range = [self countingPositiveAndNegative:range];
//        if (abs(range)==0) {
//            returnStr = [NSString stringWithFormat:@"%@ = 0.0",string];
//        }else if (abs(range)>0&&abs(range)<=rangeA){
//            if (range<0) {
//                returnStr = [NSString stringWithFormat:@"%@ < 0.0 and %@ >=-%d",string,string,rangeA];
//            }else{
//                returnStr = [NSString stringWithFormat:@"%@ > 0.0 and %@ <=%d",string,string,rangeA];
//            }
//        }else if (abs(range)>rangeA && abs(range) <=rangeB){
//            if (range<0) {
//                returnStr = [NSString stringWithFormat:@"%@ < -%d and %@ >=-%d",string,rangeA,string,rangeB];
//            }else{
//                returnStr = [NSString stringWithFormat:@"%@ > %d and %@ <=%d",string,rangeA,string,rangeB];
//            }
//        }else if (abs(range)>rangeB && abs(range) <=rangeC){
//            if (range<0) {
//                returnStr = [NSString stringWithFormat:@"%@ < -%d and %@ >=-%d",string,rangeB,string,rangeC];
//            }else{
//                returnStr = [NSString stringWithFormat:@"%@ > %d and %@ <=%d",string,rangeB,string,rangeC];
//            }
//        }else if (abs(range)>rangeC && abs(range) <=rangeD){
//            if (range<0) {
//                returnStr = [NSString stringWithFormat:@"%@ < -%d and %@ >=-%d",string,rangeC,string,rangeD];
//            }else{
//                returnStr = [NSString stringWithFormat:@"%@ > %d and %@ <=%d",string,rangeC,string,rangeD];
//            }
//        }else if (abs(range)>rangeD && abs(range) <=rangeE){
//            if (range<0) {
//                returnStr = [NSString stringWithFormat:@"%@ < -%d and %@ >=-%d",string,rangeD,string,rangeE];
//            }else{
//                returnStr = [NSString stringWithFormat:@"%@ > %d and %@ <=%d",string,rangeD,string,rangeE];
//            }
//        }else if (abs(range)>rangeE){
//            
//            if (range<0) {
//                returnStr = [NSString stringWithFormat:@"%@ < -%d",string,rangeE];
//            }else{
//                returnStr = [NSString stringWithFormat:@"%@ > %d",string,rangeE];
//            }
//        }
    }
    return returnStr;
    
}

- (void)callBackResultEquationName:(NSString *)equationName targetMarket:(NSString *)targetMarket dataAmount:(int)dataAmount totalAmount:(int)totalAmount dataDate:(UInt16)date dataArray:(NSArray *)dataArray markPriceArray:(NSArray *)markPriceArray{
    [self.view hideHUD];
    
    NSString *alertTitle = self.functionName;
    self.resultEquationName = equationName;
    self.resultTargetMarket = targetMarket;
    self.resultTotalAmount = totalAmount;
    self.resultDataDate = [[NSNumber numberWithInt:date]uint16ToDate];
    NSMutableArray * topDataArray = [[NSMutableArray alloc]init];
    NSMutableArray * topPriceArray = [[NSMutableArray alloc]init];
    if  (totalAmount >100){
        self.resultDataAmount = 100;
        for (int i=0; i<100; i++) {
            [topDataArray addObject:[dataArray objectAtIndex:i]];
            [topPriceArray addObject:[markPriceArray objectAtIndex:i]];
        }
        self.resultDataArray =[[NSArray alloc]initWithArray:topDataArray];
        self.resultMarkPriceArray =[[NSArray alloc]initWithArray:topPriceArray];
    }else{
        self.resultDataAmount = dataAmount;
        self.resultDataArray =[[NSArray alloc]initWithArray:dataArray];
        self.resultMarkPriceArray =[[NSArray alloc]initWithArray:markPriceArray];
    }

    NSString *alertBodyMsgPatten;
    NSString *alertBodyMsg;
    
    if (totalAmount > self.resultDataAmount) {
        alertBodyMsgPatten = NSLocalizedStringFromTable(@"搜尋到%d筆資料!僅顯示%d筆.", @"FigureSearch", nil);
        alertBodyMsg = [NSString stringWithFormat:alertBodyMsgPatten, totalAmount, self.resultDataAmount];
    } else {
        alertBodyMsgPatten = NSLocalizedStringFromTable(@"搜尋到%d筆資料!", @"FigureSearch", nil);
        alertBodyMsg = [NSString stringWithFormat:alertBodyMsgPatten, totalAmount];
    }
    
    self.resultAlert = [[UIAlertView alloc]initWithTitle:alertTitle message:alertBodyMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil),nil];
    [_resultAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    
}

-(void)initCollectionView{
    self.trackResultRectView = [[UIView alloc] init];
    self.trackResultRectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.trackResultRectView.layer.borderColor = [UIColor blackColor].CGColor;
    self.trackResultRectView.layer.borderWidth = 1;
    [_searchView addSubview:self.trackResultRectView];

    self.trackLabel = [[UILabel alloc] init];
    self.trackLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.trackLabel.text = NSLocalizedStringFromTable(@"追蹤標的", @"FigureSearch", nil);
    [self.trackResultRectView addSubview:self.trackLabel];
    
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    aFlowLayout.itemSize = CGSizeMake(100, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    self.collectionViewBtn = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 310, 200) collectionViewLayout:aFlowLayout];
    _collectionViewBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionViewBtn setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionViewBtn.myDelegate = self;
    _collectionViewBtn.searchGroup = 1;
    _collectionViewBtn.holdBtn = 99999;
    _collectionViewBtn.btnArray = _btnNameArray;
    _collectionViewBtn.aligment = UIControlContentHorizontalAlignmentCenter;
    
    [self.trackResultRectView addSubview:_collectionViewBtn];
}

-(void)groupButtonClick:(FSUIButton *)button Object:(BtnCollectionView *)scrl{
    TrackUpFormat * symbol = [_btnDataArray objectAtIndex:button.tag];
    //NSLog(@"%@",symbol->symbol);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.selected = NO;
    _collectionViewBtn.holdBtn = 99999;
    FSDataModelProc * dataModel = [FSDataModelProc sharedInstance];
    FSMainViewController *instantInfoMainViewController = [[FSMainViewController alloc] init];
    
    NSString * symbolStr =[NSString stringWithFormat:@"%@ %@",symbol->identCode,symbol->symbol];
    [dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
    PortfolioItem *portfolioItem = [dataModel.portfolioData findItemByIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",symbol->identCode,symbol->symbol]];
    _watchedPortfolio.portfolioItem = portfolioItem;
    instantInfoMainViewController.firstLevelMenuOption = 1;
    instantInfoMainViewController.techOption = _searchGroup-1;
    [self.navigationController pushViewController:instantInfoMainViewController animated:NO];
}

-(void)setInfoText{
    _infoTextView.bounces = NO;
    if (_currentOption==0 || _currentOption==1) {
        UIImage * image = [UIImage imageWithData:[_figureSearchArray objectAtIndex:5]];
        [_infoImageView setImage:image];
        if ([FSUtility isGraterThanSupportVersion:7]) {
            NSString * htmlString = NSLocalizedStringFromTable(self.navigationItem.title, @"TypicalPattern", nil);
//TODO.M
//這段造成換頁很慢=====
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//==================
            _infoTextView.attributedText = attributedString;
        }else{
            NSString * string =[NSString stringWithFormat:@"%@_6",self.navigationItem.title];
            _infoTextView.text = NSLocalizedStringFromTable(string, @"TypicalPattern", nil);
        }
    }else{
        _infoTextView.text = [_figureSearchArray objectAtIndex:11];
    }
    if([_infoTextView.text isEqualToString:@""]){
        placeholder.hidden = NO;
    }else{
        placeholder.hidden = YES;
    }
   
}

-(void)initformulaArray{
    self.zeroOptionIconsEquation = [[NSArray alloc] initWithObjects:
                                    @"(#RANGE#0OPEN - #RANGE#0LAST) > #RANGE#1LAST * #LONGPARAM2# ",
                                    @"(#RANGE#0LAST / #RANGE#0LOW)< #TWOPARAM# and #RANGE#0OPEN >= #RANGE#0LAST and (#RANGE#0HIGH - #RANGE#0OPEN) > #RANGE#1LAST * #PARAM# and (#RANGE#1LAST / #RANGE#1LOW)< #TWOPARAM# and #RANGE#1OPEN >= #RANGE#1LAST and (#RANGE#1HIGH - #RANGE#1OPEN) > #RANGE#2LAST * #PARAM#",
                                    @"#RANGE#1NEW_HI#TIME# and (#RANGE#0OPEN - #RANGE#0LAST) > #RANGE#1LAST * #PARAM# and #RANGE#0LAST <= #RANGE#2OPEN and #RANGE#0HIGH <= #RANGE#1LOW and (if(#RANGE#1LAST>=#RANGE#1OPEN)then(#RANGE#1LAST - #RANGE#1OPEN)else(#RANGE#1OPEN - #RANGE#1LAST)end/#RANGE#1LAST)< #MULT# and #RANGE#1LOW >= #RANGE#2HIGH and (#RANGE#2LAST - #RANGE#2OPEN) > #RANGE#3LAST * #PARAM#",
                                    @"#BEARS3#",
                                    @"(#RANGE#0OPEN - #RANGE#0LAST ) > #RANGE#1LAST * #PARAM# and #RANGE#1LAST > #RANGE#1OPEN and (#RANGE#2OPEN - #RANGE#2LAST ) > #RANGE#3LAST * #PARAM# and #RANGE#0OPEN > #RANGE#1LAST and #RANGE#0LAST < #RANGE#1OPEN and #RANGE#1LAST < #RANGE#2OPEN and #RANGE#1OPEN > #RANGE#2LAST",
                                    @"#BEAR3CALVES#",
                                    @"#RANGE#1NEW_HI#TIME# and #RANGE#1LOW > #RANGE#0HIGH * 1.02 and #RANGE#1LOW > #RANGE#2HIGH * 1.02",
                                    @"MAX#SPEC1#(#RANGE#1PRC_MA#SPEC2#) / MIN#SPEC1#(#RANGE#1PRC_MA#SPEC2#) < #SPMULT# and #RANGE#0NEW_LO#SPEC1# and (#RANGE#0OPEN - #RANGE#0LAST)  > #RANGE#1LAST * #PARAM#",
                                    @"#RANGE#0NEW_HI#TIME# and if(#RANGE#0LAST >= #RANGE#0OPEN)then(#RANGE#0HIGH - #RANGE#0LAST)else(#RANGE#0HIGH - #RANGE#0OPEN)end  > #RANGE#1LAST * #LONGHORNPARAM#",
                                    @"(#RANGE#3OPEN - #RANGE#3LAST)  > #RANGE#4LAST * #PARAM# and MIN3(#RANGE#0LOW) >= #RANGE#3LOW and MAX3(#RANGE#0HIGH) <= ((#RANGE#3OPEN + #RANGE#3LAST) / 2 )",
                                    @"#RANGE#0NEW_LO#TIME# and #RANGE#0LAST > #RANGE#0OPEN and #RANGE#0HIGH <= #RANGE#1LOW and (#RANGE#0LAST - #RANGE#0OPEN)  < (#RANGE#1OPEN - #RANGE#1LAST)  and (#RANGE#0LAST - #RANGE#0OPEN)  < (#RANGE#2OPEN - #RANGE#2LAST)",
                                    @"#RANGE#2NEW_HI#TIME# and #RANGE#2LAST > #RANGE#2OPEN and #RANGE#1HIGH <= #RANGE#2HIGH and #RANGE#1LOW >= #RANGE#2LOW and #RANGE#1OPEN > #RANGE#1LAST and (#RANGE#0OPEN - #RANGE#0LAST)  > #RANGE#1LAST * #PARAM# and #RANGE#0LAST <= #RANGE#2LOW", nil];
    self.moreOptionIconsEquation= [[NSArray alloc] initWithObjects:
                                   @"(#RANGE#0LAST - #RANGE#0OPEN)> #RANGE#1LAST * #LONGPARAM2# ",
                                   @"(#RANGE#0HIGH / #RANGE#0LAST)< #TWOPARAM# and #RANGE#0LAST >= #RANGE#0OPEN and(#RANGE#0OPEN - #RANGE#0LOW) > #RANGE#1LAST * #PARAM# and (#RANGE#1HIGH /#RANGE#1LAST)< #TWOPARAM# and #RANGE#1LAST > #RANGE#1OPEN and (#RANGE#1OPEN - #RANGE#1LOW) >#RANGE#2LAST * #PARAM#",
                                   @"#MorningStar#",
                                   @"#RED3#",
                                   @"(#RANGE#0LAST - #RANGE#0OPEN) > #RANGE#1LAST * #PARAM# and #RANGE#1OPEN > #RANGE#1LAST and (#RANGE#2LAST - #RANGE#2OPEN ) > #RANGE#3LAST * #PARAM# and #RANGE#0LAST > #RANGE#1OPEN and #RANGE#0OPEN < #RANGE#1LAST and #RANGE#1OPEN < #RANGE#2LAST and #RANGE#1LAST > #RANGE#2OPEN",
                                   @"#BULL3CUBS#",
                                   @"#RANGE#1NEW_LO#TIME# and #RANGE#0LOW > #RANGE#1HIGH * 1.02 and #RANGE#2LOW > #RANGE#1HIGH * 1.02",
                                   @"MAX#SPEC1#(#RANGE#1PRC_MA#SPEC2#) / MIN#SPEC1#(#RANGE#1PRC_MA#SPEC2#) < #SPMULT2# and #RANGE#0NEW_HI#SPEC1# and (#RANGE#0LAST - #RANGE#0OPEN)  > #RANGE#1LAST * #PARAM#",
                                   @"#RANGE#0NEW_LO#TIME# and if(#RANGE#0LAST >= #RANGE#0OPEN)then(#RANGE#0OPEN - #RANGE#0LOW)else(#RANGE#0LAST - #RANGE#0LOW)end > #RANGE#1LAST * #LONGHORNPARAM#",
                                   @"#BullBrewing#",
                                   @"#CubStandUp#",
                                   @"#RANGE#2NEW_LO#TIME# and #RANGE#2OPEN > #RANGE#2LAST and #RANGE#1HIGH <= #RANGE#2HIGH and #RANGE#1LOW >= #RANGE#2LOW and #RANGE#1LAST > #RANGE#1OPEN and (#RANGE#0LAST - #RANGE#0OPEN)  > #RANGE#1LAST * #PARAM# and #RANGE#0LAST >= #RANGE#2HIGH", nil];
}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];
    
    [_explainView showMenuWithRect:CGRectMake(100, 140, 0, 0) String:NSLocalizedStringFromTable(@"選擇時間", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(100, 100, 30, 56)];
    [_explainView showMenuWithRect:CGRectMake(280, 220, 0, 0) String:NSLocalizedStringFromTable(@"選擇追蹤", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(255, 150, 30, 56)];
}

-(void)closeTeachPop:(UIView *)view{
    //存資料庫
    [view removeFromSuperview];
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    if (teachPopView.checkBtn.selected) {
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"NO"];
    }else{
        [_customModel editInstructionByControllerName:[[self class]description] Show:@"YES"];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
	CGFloat pageWidth = self.scrollView.bounds.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
	
	if (self.pageControl.currentPage != nearestNumber) {
		self.pageControl.currentPage = nearestNumber;
		if (self.scrollView.dragging) {
            if (nearestNumber==0) {
                [_infoTextView resignFirstResponder];
            }
            
			[self.pageControl updateCurrentPageDisplay] ;
        }
	}
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
    
	[self.pageControl updateCurrentPageDisplay] ;
}

- (void)goSearch {
    NSString *result = searchViewController.formula;
    NSArray *sectorsID;
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    if ([group isEqualToString:@"cn"]){
        sectorsID = [NSArray arrayWithObjects:@SECTOR_SHANG_JIAO, @SECTOR_SHEN_JIAO, nil];
        
    }
    else if ([group isEqualToString:@"tw"]) {
        sectorsID = [NSArray arrayWithObjects:@SECTOR_JI_JHONG, @SECTOR_DIAN_TOU, nil];
    }
    else {
        sectorsID = [NSArray arrayWithObjects:@SECTOR_NYSE,@SECTOR_NASDAQ,@SECTOR_AMEX, nil];
    }

//    NSArray *sectorsID = [NSArray arrayWithObjects:@SECTOR_DIAN_TOU, @SECTOR_JI_JHONG, nil];
    UInt8 flag = 0;         // 無特殊需求就設0
    UInt8 sn = 65;          // 隨意定義, 回傳sn會一致
    UInt8 reqCount = 100;   // 預設100
    
    NSString *equation = nil;
    
    if (_currentOption == 0) {
        equation = _moreOptionIconsEquation[_searchNum-1];
        if (_inSessionSearchButton.selected) {
            _searchType = FigureSearchUSFeeTypeInSessionBuildIn;
        }else{
            _searchType =FigureSearchUSFeeTypePreviousSessionBuildIn;
        }
    }else if (_currentOption ==1){
        equation = _zeroOptionIconsEquation[_searchNum-1];
        if (_inSessionSearchButton.selected) {
            _searchType = FigureSearchUSFeeTypeInSessionBuildIn;
        }else{
            _searchType = FigureSearchUSFeeTypePreviousSessionBuildIn;
        }
    }else if (_currentOption == 2 || _currentOption==3){
        equation = [self makeFormulaWithFigureSearchId:[_figureSearchArray objectAtIndex:0] SearchGroup:_searchGroup];
        if (_inSessionSearchButton.selected) {
            _searchType = FigureSearchUSFeeTypeInSessionDIY;
        }else{
            _searchType =FigureSearchUSFeeTypePreviousSessionDIY;
        }
    }

    if (_searchGroup==1) {
        result = [searchViewController.formula stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"D0"];
        
        if([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){
            equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"LAND3(#RANGE#0LAST > #RANGE#0OPEN) and LAND3(#RANGE#0HIGH > #RANGE#1HIGH) and LAND3(#RANGE#0LOW > #RANGE#1LOW)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"LAND3(#RANGE#0OPEN > #RANGE#0LAST) and LAND3(#RANGE#0HIGH < #RANGE#1HIGH) and LAND3(#RANGE#0LOW < #RANGE#1LOW)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LAST) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LAST >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#MorningStar#" withString:@"#RANGE#1NEW_LO#TIME# and (#RANGE#0LAST - #RANGE#0OPEN) > #RANGE#1LAST * #PARAM# and #RANGE#0LAST >= #RANGE#2OPEN and #RANGE#0LOW >= #RANGE#1HIGH and (if(#RANGE#1LAST>=#RANGE#1OPEN)then(#RANGE#1LAST - #RANGE#1OPEN)else(#RANGE#1OPEN - #RANGE#1LAST)end/#RANGE#1LAST)< #MULT# and #RANGE#1HIGH <= #RANGE#2LOW and (#RANGE#2OPEN - #RANGE#2LAST) > #RANGE#3LAST * #PARAM#"];
        }else{
            equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"LAND3(#RANGE#0LAST > #RANGE#0OPEN) and LAND3(#RANGE#0HIGH > #RANGE#1HIGH) and LAND3(#RANGE#0LOW > #RANGE#1LOW) and LAND3(#RANGE#0LAST > #RANGE#1LAST)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"LAND3(#RANGE#0OPEN > #RANGE#0LAST) and LAND3(#RANGE#0HIGH < #RANGE#1HIGH) and LAND3(#RANGE#0LOW < #RANGE#1LOW) and LAND3(#RANGE#0LAST < #RANGE#1LAST)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LOW) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LOW >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#MorningStar#" withString:@"D1NEW_LO15 and ( D0LAST - D0OPEN ) > D1LAST * 0.020 and D0LAST - D2LAST > ( D2OPEN - D2LAST ) * 0.5 and D0LOW >= D1HIGH * 0.995 and ( if ( D1LAST >= D1OPEN ) then ( D1LAST - D1OPEN ) else ( D1OPEN - D1LAST ) end ) < D1LAST * 0.010 and D1HIGH <= D2LOW * 1.005 and ( D2OPEN - D2LAST ) > D3LAST * 0.020"];
        }

        equation = [equation stringByReplacingOccurrencesOfString:@"#BULL3CUBS#" withString:@"LAND3(#RANGE#1OPEN >= #RANGE#1LAST )and #RANGE#0LAST > #RANGE#0OPEN and #RANGE#0LAST >= MAX3(#RANGE#1OPEN) and #RANGE#0OPEN <= MIN3(#RANGE#1LAST)"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#BEAR3CALVES#" withString:@"LAND3(#RANGE#1LAST >= #RANGE#1OPEN ) and #RANGE#0OPEN > #RANGE#0LAST and #RANGE#0OPEN >= MAX3(#RANGE#1LAST) and #RANGE#0LAST <= MIN3(#RANGE#1OPEN)"];

        
        equation = [equation stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"D"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#PARAM#" withString:NSLocalizedStringFromTable(@"PARAM_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM2#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Day_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM2#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Day_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TWOPARAM#" withString:NSLocalizedStringFromTable(@"TWOPARAM_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TIME#" withString:NSLocalizedStringFromTable(@"TIME_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TIME2#" withString:NSLocalizedStringFromTable(@"TIME_Day2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MULT#" withString:NSLocalizedStringFromTable(@"MULT_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT#" withString:NSLocalizedStringFromTable(@"SPMULT_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT2#" withString:NSLocalizedStringFromTable(@"SPMULT_Day_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC1#" withString:NSLocalizedStringFromTable(@"SPEC1_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC2#" withString:NSLocalizedStringFromTable(@"SPEC2_Day", @"FigureSearchFormula", nil)];
        
        equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDPARAM#" withString:NSLocalizedStringFromTable(@"TRENDPARAM_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MONTRENDPARAM#" withString:NSLocalizedStringFromTable(@"MONTRENDPARAM_Day", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDSPEC1#" withString:NSLocalizedStringFromTable(@"TRENDSPEC1_Day", @"FigureSearchFormula", nil)];
    
        float flat =1+[(NSNumber *)[_figureSearchArray objectAtIndex:12]intValue]*0.01;
        equation = [equation stringByReplacingOccurrencesOfString:@"#FLATTREND#" withString:[NSString stringWithFormat:@"%f",flat]];


    }else if (_searchGroup==2){
        result = [searchViewController.formula stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"W0"];
        
        if([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){
            equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"#RANGE#0LAST > #RANGE#0OPEN and #RANGE#1LAST > #RANGE#1OPEN and #RANGE#2LAST > #RANGE#2OPEN and #RANGE#0HIGH > #RANGE#1HIGH and #RANGE#1HIGH > #RANGE#2HIGH and #RANGE#0LOW > #RANGE#1LOW and #RANGE#1LOW > #RANGE#2LOW"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LAST) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LAST >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"#RANGE#0LAST < #RANGE#0OPEN and #RANGE#1LAST < #RANGE#1OPEN and #RANGE#2LAST < #RANGE#2OPEN and #RANGE#0HIGH < #RANGE#1HIGH and #RANGE#1HIGH < #RANGE#2HIGH and #RANGE#0LOW < #RANGE#1LOW and #RANGE#1LOW < #RANGE#2LOW"];
        }else{
            equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"#RANGE#0LAST > #RANGE#0OPEN and #RANGE#1LAST > #RANGE#1OPEN and #RANGE#2LAST > #RANGE#2OPEN and #RANGE#0HIGH > #RANGE#1HIGH and #RANGE#1HIGH > #RANGE#2HIGH and #RANGE#0LOW > #RANGE#1LOW and #RANGE#1LOW > #RANGE#2LOW and #RANGE#0LAST > #RANGE#1LAST and #RANGE#1LAST > #RANGE#2LAST"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LOW) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LOW >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"#RANGE#0LAST < #RANGE#0OPEN and #RANGE#1LAST < #RANGE#1OPEN and #RANGE#2LAST < #RANGE#2OPEN and #RANGE#0HIGH < #RANGE#1HIGH and #RANGE#1HIGH < #RANGE#2HIGH and #RANGE#0LOW < #RANGE#1LOW and #RANGE#1LOW < #RANGE#2LOW and #RANGE#0LAST < #RANGE#1LAST and #RANGE#1LAST < #RANGE#2LAST"];
        }
        

        equation = [equation stringByReplacingOccurrencesOfString:@"#BULL3CUBS#" withString:@"#RANGE#1OPEN >= #RANGE#1LAST and #RANGE#2OPEN >= #RANGE#2LAST and #RANGE#3OPEN >= #RANGE#3LAST and #RANGE#0LAST > #RANGE#0OPEN and #RANGE#0LAST >= MAX3(#RANGE#1OPEN) and #RANGE#0OPEN <= MIN3(#RANGE#1LAST)"];
        

        
        equation = [equation stringByReplacingOccurrencesOfString:@"#BEAR3CALVES#" withString:@"#RANGE#1OPEN <= #RANGE#1LAST and #RANGE#2OPEN <= #RANGE#2LAST and #RANGE#3OPEN <= #RANGE#3LAST and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0OPEN >= MAX3(#RANGE#1LAST) and #RANGE#0LAST <= MIN3(#RANGE#1OPEN)"];
        
        equation = [equation stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"W"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#PARAM#" withString:NSLocalizedStringFromTable(@"PARAM_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM2#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Week_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM2#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Week_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TWOPARAM#" withString:NSLocalizedStringFromTable(@"TWOPARAM_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TIME#" withString:NSLocalizedStringFromTable(@"TIME_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MULT#" withString:NSLocalizedStringFromTable(@"MULT_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT#" withString:NSLocalizedStringFromTable(@"SPMULT_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT2#" withString:NSLocalizedStringFromTable(@"SPMULT_Week_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC1#" withString:NSLocalizedStringFromTable(@"SPEC1_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC2#" withString:NSLocalizedStringFromTable(@"SPEC2_Week", @"FigureSearchFormula", nil)];
        
        equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDPARAM#" withString:NSLocalizedStringFromTable(@"TRENDPARAM_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MONTRENDPARAM#" withString:NSLocalizedStringFromTable(@"MONTRENDPARAM_Week", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDSPEC1#" withString:NSLocalizedStringFromTable(@"TRENDSPEC1_Week", @"FigureSearchFormula", nil)];
        
        
        
        float flat =1+[(NSNumber *)[_figureSearchArray objectAtIndex:13]intValue]*0.01;
        equation = [equation stringByReplacingOccurrencesOfString:@"#FLATTREND#" withString:[NSString stringWithFormat:@"%f",flat]];
        
        
    }else if (_searchGroup == 3){
        result = [searchViewController.formula stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"M0"];
        
        if([FSFonestock sharedInstance].marketVersion == FSMarketVersionTW){
            equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"#RANGE#0LAST > #RANGE#0OPEN and #RANGE#1LAST > #RANGE#1OPEN and #RANGE#2LAST > #RANGE#2OPEN and #RANGE#0HIGH > #RANGE#1HIGH and #RANGE#1HIGH > #RANGE#2HIGH and #RANGE#0LOW > #RANGE#1LOW and #RANGE#1LOW > #RANGE#2LOW"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LAST) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LAST >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"#RANGE#0OPEN > #RANGE#0LAST  and #RANGE#1OPEN > #RANGE#1LAST and #RANGE#2OPEN > #RANGE#2LAST and #RANGE#0HIGH < #RANGE#1HIGH and #RANGE#1HIGH < #RANGE#2HIGH and #RANGE#0LOW < #RANGE#1LOW and #RANGE#1LOW < #RANGE#2LOW"];
        }else{
            equation = [equation stringByReplacingOccurrencesOfString:@"#RED3#" withString:@"#RANGE#0LAST > #RANGE#0OPEN and #RANGE#1LAST > #RANGE#1OPEN and #RANGE#2LAST > #RANGE#2OPEN and #RANGE#0HIGH > #RANGE#1HIGH and #RANGE#1HIGH > #RANGE#2HIGH and #RANGE#0LOW > #RANGE#1LOW and #RANGE#1LOW > #RANGE#2LOW and #RANGE#0LAST > #RANGE#1LAST and #RANGE#1LAST > #RANGE#2LAST"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BullBrewing#" withString:@"(#RANGE#3LAST - #RANGE#3OPEN)  > #RANGE#4LAST * #PARAM# and MAX3(#RANGE#0HIGH) <= #RANGE#3HIGH and MIN3(#RANGE#0LOW) >= ((#RANGE#3OPEN + #RANGE#3LAST) / 2)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#CubStandUp#" withString:@"#RANGE#0NEW_HI#TIME# and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0LOW >= #RANGE#1HIGH and (#RANGE#0OPEN - #RANGE#0LAST) < (#RANGE#1LAST - #RANGE#1OPEN)  and (#RANGE#0OPEN - #RANGE#0LAST)  < (#RANGE#2LAST - #RANGE#2OPEN)"];
            equation = [equation stringByReplacingOccurrencesOfString:@"#BEARS3#" withString:@"#RANGE#0LAST < #RANGE#0OPEN and #RANGE#1LAST < #RANGE#1OPEN and #RANGE#2LAST < #RANGE#2OPEN and #RANGE#0HIGH < #RANGE#1HIGH and #RANGE#1HIGH < #RANGE#2HIGH and #RANGE#0LOW < #RANGE#1LOW and #RANGE#1LOW < #RANGE#2LOW"];
        }

        equation = [equation stringByReplacingOccurrencesOfString:@"#BULL3CUBS#" withString:@"#RANGE#1OPEN >= #RANGE#1LAST and #RANGE#2OPEN >= #RANGE#2LAST and #RANGE#3OPEN >= #RANGE#3LAST and #RANGE#0LAST > #RANGE#0OPEN and #RANGE#0LAST >= MAX3(#RANGE#1OPEN) and #RANGE#0OPEN <= MIN3(#RANGE#1LAST)"];

        equation = [equation stringByReplacingOccurrencesOfString:@"#BEAR3CALVES#" withString:@"#RANGE#1OPEN <= #RANGE#1LAST and #RANGE#2OPEN <= #RANGE#2LAST and #RANGE#3OPEN <= #RANGE#3LAST and #RANGE#0LAST < #RANGE#0OPEN and #RANGE#0OPEN >= MAX3(#RANGE#1LAST) and #RANGE#0LAST <= MIN3(#RANGE#1OPEN)"];
        
        equation = [equation stringByReplacingOccurrencesOfString:@"#RANGE#" withString:@"M"];
        equation = [equation stringByReplacingOccurrencesOfString:@"#PARAM#" withString:NSLocalizedStringFromTable(@"PARAM_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGHORNPARAM2#" withString:NSLocalizedStringFromTable(@"LONGHORNPARAM_Month_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#LONGPARAM2#" withString:NSLocalizedStringFromTable(@"LONGPARAM_Month_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TWOPARAM#" withString:NSLocalizedStringFromTable(@"TWOPARAM_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TIME#" withString:NSLocalizedStringFromTable(@"TIME_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MULT#" withString:NSLocalizedStringFromTable(@"MULT_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT#" withString:NSLocalizedStringFromTable(@"SPMULT_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPMULT2#" withString:NSLocalizedStringFromTable(@"SPMULT_Month_2", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC1#" withString:NSLocalizedStringFromTable(@"SPEC1_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#SPEC2#" withString:NSLocalizedStringFromTable(@"SPEC2_Month", @"FigureSearchFormula", nil)];
        
        equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDPARAM#" withString:NSLocalizedStringFromTable(@"TRENDPARAM_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#MONTRENDPARAM#" withString:NSLocalizedStringFromTable(@"MONTRENDPARAM_Month", @"FigureSearchFormula", nil)];
        equation = [equation stringByReplacingOccurrencesOfString:@"#TRENDSPEC1#" withString:NSLocalizedStringFromTable(@"TRENDSPEC1_Month", @"FigureSearchFormula", nil)];
        
        
        
        float flat =1+[(NSNumber *)[_figureSearchArray objectAtIndex:14]intValue]*0.01;
        equation = [equation stringByReplacingOccurrencesOfString:@"#FLATTREND#" withString:[NSString stringWithFormat:@"%f",flat]];
        
        
    }
    if(result.length>0){
        equation = [NSString stringWithFormat:@"%@ and %@",equation, result];
    }
//    equation = @"( if( D0LAST >= D0OPEN )then( D0HIGH - D0LAST )else( D0HIGH - D0OPEN )end  / D1LAST ) == 0 and ( if( D0LAST >= D0OPEN )then( D0LAST - D0OPEN )else( D0OPEN - D0LAST )end  / D1LAST ) == 0 and ( D0LAST >= D0OPEN ) and ( if( D0LAST >= D0OPEN )then( D0OPEN - D0LOW )else( D0LAST - D0LOW )end  / D1LAST ) == 0 and D0PCT_CHG >= -1.125 and D0PCT_CHG < -0.375";
    NSLog(@"\n%@",equation);
    [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"FigureSearch", nil)];
//     查詢
    

    [_figureSearchUS searchByType:_searchType
                        sectorIDs:sectorsID
                             flag:flag
                               sn:sn
                         reqCount:reqCount
                   equationString:equation];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    placeholder.hidden = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if([_infoTextView.text isEqualToString:@""]){
        placeholder.hidden = NO;
    }else{
        placeholder.hidden = YES;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
