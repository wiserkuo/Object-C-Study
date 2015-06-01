//
//  FigureSearchViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/10/18.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchViewController.h"
#import "DDPageControl.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FigureSearchViewLayout.h"
#import "FigureSearchCollectionViewCell.h"
#import "FigureSearchModel.h"
#import "FigureSearchMyProfileModel.h"
#import "FigureSearchConditionViewController.h"
#import "KxMenu.h"
#import "FSTeachPopView.h"
#import "FSTeachPopDelegate.h"

@interface FigureSearchViewController () <UICollectionViewDelegate, UIScrollViewDelegate,FSTeachPopDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSString *functionName;
@property (strong, nonatomic) NSString *functionName2;
@property (strong, nonatomic) FSUIButton *moreOptionButton;
@property (strong, nonatomic) FSUIButton *zeroOptionButton;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) DDPageControl *pageControl;
@property (unsafe_unretained, nonatomic) NSInteger numberOfPages;

@property (unsafe_unretained, nonatomic) NSInteger selectedOptionIndex;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) FigureSearchViewLayout *layout;
@property (strong, nonatomic) FigureSearchModel *figureSearchSysModel;
@property (strong, nonatomic) FigureSearchMyProfileModel *figureSearchMyProfileModel;

@property (strong, nonatomic) UICollectionView *collectionView_custom;
@property (strong, nonatomic) FigureSearchViewLayout *layout_custom;
@property (strong, nonatomic) FigureSearchModel *model;

@property (strong, nonatomic) FSTeachPopView * explainView;

@end

static NSString *itemIdentifier = @"FigureSearchItemIdentifier";

@implementation FigureSearchViewController

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(88, 88);
}

- (id)init {
    self = [super init];
    if (self) {
        self.functionName = NSLocalizedStringFromTable(@"圖示選股", @"FigureSearch", nil);
        self.functionName2 = NSLocalizedStringFromTable(@"用戶自定", @"FigureSearch", nil);
        self.title = self.functionName;
    }
    return self;
}

- (void)viewDidLoad {
    [self setUpImageBackButton];
    
    [self initModel];
    [self initScrollView];
    [self initMoreOption];
    [self initZeroOption];
    [self initPageControll];
    
    [self processLayout];
    NSString * show = [_figureSearchMyProfileModel searchInstructionByControllerName:[[self class] description]];
    if ([show isEqualToString:@"YES"]) {
        [self teachPop];
    }
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (_model.currentOption ==kFigureSearchSystemLong ||_model.currentOption == kFigureSearchSystemShort) {
        [self.collectionView reloadData];
    }else if (_model.currentOption ==kFigureSearchMyProfileLong ||_model.currentOption == kFigureSearchMyProfileShort){
        [self.collectionView_custom reloadData];
    }
    
}

- (void)initModel {
    self.model = [[FigureSearchModel alloc]init];
    self.figureSearchSysModel = [FigureSearchModel sharedInstance];
    self.figureSearchMyProfileModel = [FigureSearchMyProfileModel sharedInstance];
}

- (void)initScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:self.scrollView];
    
    [self initMoreCollectionView];
    //[self initCustomCollectionView];
}

- (void)initPageControll {
    self.numberOfPages = 1;
    self.pageControl = [[DDPageControl alloc] init];
    self.pageControl.numberOfPages = self.numberOfPages;
    self.pageControl.currentPage = 0;
    
    [self.pageControl setDefersCurrentPageDisplay: YES] ;
	[self.pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
	[self.pageControl setOnColor: [UIColor redColor]];
	[self.pageControl setOffColor: [UIColor redColor]];
	[self.pageControl setIndicatorDiameter: 7.0f] ;
	[self.pageControl setIndicatorSpace: 7.0f] ;
    
    //[self.view addSubview:self.pageControl];
}

- (void)initMoreOption {
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股", @"FigureSearch", nil);
    
    self.moreOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    self.moreOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_moreOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.moreOptionButton.selected = YES;
    
    [self.moreOptionButton setTitle:moreOptionTitle forState:UIControlStateNormal];
    [self.moreOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.moreOptionButton];
}

-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:_moreOptionButton]) {
        _zeroOptionButton.selected = NO;
        _moreOptionButton.selected = YES;
        _model.currentOption = kFigureSearchSystemLong;
    }else{
        _zeroOptionButton.selected = YES;
        _moreOptionButton.selected = NO;
        _model.currentOption = kFigureSearchSystemShort;
    }
    [_collectionView reloadData];
}

- (void)initZeroOption {
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股", @"FigureSearch", nil);
    
    self.zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    self.zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [self.zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.zeroOptionButton];
}

- (void)initMoreCollectionView {
    self.layout = [[FigureSearchViewLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[FigureSearchCollectionViewCell class] forCellWithReuseIdentifier:itemIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self.model;
    self.collectionView.bounces = NO;
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    self.collectionView.layer.borderWidth = 1;

    [self.scrollView addSubview:self.collectionView];
}

- (void)initCustomCollectionView {
    self.layout_custom = [[FigureSearchViewLayout alloc] init];
    self.collectionView_custom = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout_custom];
    self.collectionView_custom.backgroundColor = [UIColor clearColor];
    [self.collectionView_custom registerClass:[FigureSearchCollectionViewCell class] forCellWithReuseIdentifier:itemIdentifier];
    self.collectionView_custom.delegate = self;
    self.collectionView_custom.dataSource = self.model;
    self.collectionView_custom.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    //[self.scrollView addSubview:self.collectionView_custom];

}
#pragma mark -
#pragma mark Layout處理

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_scrollView, _moreOptionButton, _zeroOptionButton, _collectionView);
    
    // scrollView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewControllers]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_scrollView]|" options:0 metrics:nil views:viewControllers]];
    
    // moreOptionButton, zeroOptionButton, scrollView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_moreOptionButton]-2-[_zeroOptionButton(==_moreOptionButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    // moreOptionButton, scrollView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_moreOptionButton(44)][_scrollView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_zeroOptionButton(44)]" options:0 metrics:nil views:viewControllers]];
//    // moreOptionButton, scrollView
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_moreOptionButton][_scrollView]" options:0 metrics:nil views:viewControllers]];
    

}

- (void)viewDidLayoutSubviews {
    [self.scrollView setContentSize: CGSizeMake(self.scrollView.bounds.size.width * self.numberOfPages, self.scrollView.bounds.size.height)];
    
    [self.collectionView setFrame:CGRectMake(self.scrollView.bounds.size.width * 0+2, 2, self.scrollView.bounds.size.width-4, self.scrollView.bounds.size.height-4)];
    
    //[self.collectionView_custom setFrame:CGRectMake(self.scrollView.bounds.size.width * 1, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    
    //[self.pageControl setCenter:CGPointMake(self.scrollView.center.x, self.view.bounds.size.height - 10)];
    
    [self.view layoutSubviews];
}

#pragma mark -
#pragma mark DDPageControl triggered actions

//- (void)pageControlClicked:(id)sender {
//	DDPageControl *thePageControl = (DDPageControl *)sender;
//	
//	[self.scrollView setContentOffset: CGPointMake(self.scrollView.bounds.size.width * thePageControl.currentPage, self.scrollView.contentOffset.y) animated: YES] ;
//}


#pragma mark -
#pragma mark UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
	CGFloat pageWidth = self.scrollView.bounds.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
	NSInteger nearestNumber = lround(fractionalPage);
	
	if (self.pageControl.currentPage != nearestNumber) {
		self.pageControl.currentPage = nearestNumber;
		if (self.scrollView.dragging) {
            
            [self changePage:self.pageControl.currentPage];
            
			[self.pageControl updateCurrentPageDisplay] ;
        }
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
	[self.pageControl updateCurrentPageDisplay] ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FigureSearchConditionViewController * searchConditionView = [[FigureSearchConditionViewController alloc]initWithCurrentOption:self.model.currentOption SearchNum:(int)indexPath.row+1];
        
    [self.navigationController pushViewController:searchConditionView animated:NO];
}


- (void)changePage:(NSInteger)pageNumber {
    
    if (pageNumber == 0) {
        self.title = self.functionName;
        if (self.model.currentOption == kFigureSearchMyProfileLong) {
            self.model.currentOption = kFigureSearchSystemLong;
        }else if (self.model.currentOption == kFigureSearchMyProfileShort){
            self.model.currentOption = kFigureSearchSystemShort;
        }
        [self.collectionView reloadData];
    } else if (pageNumber == 1) {
        self.title = self.functionName2;
        if (self.model.currentOption == kFigureSearchSystemLong) {
            self.model.currentOption = kFigureSearchMyProfileLong;
        }else if (self.model.currentOption == kFigureSearchSystemShort){
            self.model.currentOption = kFigureSearchMyProfileShort;
        }
        [self.collectionView_custom reloadData];
    }
    
}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];
 
    [_explainView showMenuWithRect:CGRectMake(50, 105, 0, 0) String:NSLocalizedStringFromTable(@"選擇多空", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView showMenuWithRect:CGRectMake(150, 290, 0, 0) String:NSLocalizedStringFromTable(@"選擇圖示", @"FigureSearch",nil) Detail:NO Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(50, 55, 30, 56)];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(150, 240, 30, 56)];
    
}

-(void)closeTeachPop:(UIView *)view{
    //存資料庫
    [view removeFromSuperview];
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    if (teachPopView.checkBtn.selected) {
        [_figureSearchMyProfileModel editInstructionByControllerName:[[self class]description] Show:@"NO"];
    }else{
        [_figureSearchMyProfileModel editInstructionByControllerName:[[self class]description] Show:@"YES"];
    }
    
}

@end
