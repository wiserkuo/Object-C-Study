//
//  MyFigureSearchViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/11/25.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "MyFigureSearchViewController.h"
#import "DDPageControl.h"
#import "FigureSearchViewLayout.h"
#import "FigureSearchCollectionViewCell.h"
#import "FigureSearchModel.h"
#import "FigureSearchMyProfileModel.h"
#import "FigureSearchConditionViewController.h"
#import "FigureCustomCaseViewController.h"
#import "KxMenu.h"
#import "FSTeachPopView.h"
#import "FSTeachPopDelegate.h"
#import "UIViewController+CustomNavigationBar.h"

@interface MyFigureSearchViewController () <UICollectionViewDelegate, UIScrollViewDelegate,FSTeachPopDelegate>

@property (strong, nonatomic) NSString *functionName;
@property (strong, nonatomic) NSString *functionName2;
@property (strong, nonatomic) FSUIButton *moreOptionButton;
@property (strong, nonatomic) FSUIButton *zeroOptionButton;
//@property (strong, nonatomic) UIScrollView *scrollView;
//@property (strong, nonatomic) DDPageControl *pageControl;
//@property (unsafe_unretained, nonatomic) NSInteger numberOfPages;

@property (unsafe_unretained, nonatomic) NSInteger selectedOptionIndex;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) FigureSearchViewLayout *layout;
@property (strong, nonatomic) FigureSearchModel *figureSearchSysModel;
@property (strong, nonatomic) FigureSearchMyProfileModel *figureSearchMyProfileModel;

@property (strong, nonatomic) UIView * leftView;
@property (strong, nonatomic) UICollectionView *collectionView_custom;
@property (strong, nonatomic) FigureSearchViewLayout *layout_custom;
@property (strong, nonatomic) FigureSearchModel *model;

@property (strong, nonatomic) FSTeachPopView * explainView;

//@property (strong, nonatomic) UIView * infoView;
//@property (strong, nonatomic) UITextView * infoTextView;

@end

static NSString *itemIdentifier = @"FigureSearchItemIdentifier";

@implementation MyFigureSearchViewController

- (id)init{
    self = [super init];
    if (self) {
        self.functionName2 = NSLocalizedStringFromTable(@"用戶自定", @"FigureSearch", nil);
        self.title = self.functionName2;
    }
    return self;
}

- (void)viewDidLoad
{
    [self setUpImageBackButton];
    UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [pointButton addTarget:self action:@selector(explantation:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barPointButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pointButton];
    NSArray *itemArray = [[NSArray alloc] initWithObjects:barPointButtonItem,nil];
    [self.navigationItem setRightBarButtonItems:itemArray];
    [self initModel];
    [self initCustomCollectionView];
    [self initMoreOption];
    [self initZeroOption];
    self.model.currentOption =2;
    _moreOptionButton.selected = YES;
    [self processLayout];
    NSString * show = [_figureSearchMyProfileModel searchInstructionByControllerName:[[self class] description]];
    if ([show isEqualToString:@"YES"]) {
        [self teachPop];
    }
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (_model.currentOption ==kFigureSearchSystemLong ||_model.currentOption == kFigureSearchSystemShort) {
        [self.collectionView reloadData];
    }else if (_model.currentOption ==kFigureSearchMyProfileLong ||_model.currentOption == kFigureSearchMyProfileShort){
        [self.collectionView_custom reloadData];
    }
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    dataModel.figureSearchModel.beSubmit = NO;
    
}

- (void)initModel {
    self.model = [[FigureSearchModel alloc]init];
    self.figureSearchSysModel = [FigureSearchModel sharedInstance];
    self.figureSearchMyProfileModel = [FigureSearchMyProfileModel sharedInstance];
}

-(void)explantation:(UIButton *)sender
{
    [self.navigationController pushViewController:[[NSClassFromString(@"ExplanationViewController") alloc] init] animated:NO];
}

- (void)initMoreOption {
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股", @"FigureSearch", nil);
    
    self.moreOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    self.moreOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_moreOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[_moreOptionButton setBackgroundColor:[UIColor colorWithRed:22.0f/255.0f green:130.0f/255.0f blue:24.0f/255.0f alpha:1.0f]];
    
    [self.moreOptionButton setTitle:moreOptionTitle forState:UIControlStateNormal];
    [self.moreOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.moreOptionButton];
}

-(void)optionButtonClick:(FSUIButton *)btn{
    if ([btn isEqual:_moreOptionButton]) {
        _zeroOptionButton.selected = NO;
        _moreOptionButton.selected = YES;
        _model.currentOption = kFigureSearchMyProfileLong;
    }else{
        _zeroOptionButton.selected = YES;
        _moreOptionButton.selected = NO;
        _model.currentOption = kFigureSearchMyProfileShort;
    }
    [_collectionView_custom reloadData];
}

- (void)initZeroOption {
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股", @"FigureSearch", nil);
    
    self.zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    self.zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[_zeroOptionButton setBackgroundColor:[UIColor redColor]];
    
    [self.zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [self.zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.zeroOptionButton];
}

- (void)initCustomCollectionView {
    self.layout_custom = [[FigureSearchViewLayout alloc] init];
    self.collectionView_custom = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout_custom];
    self.collectionView_custom.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView_custom.backgroundColor = [UIColor clearColor];
    [self.collectionView_custom registerClass:[FigureSearchCollectionViewCell class] forCellWithReuseIdentifier:itemIdentifier];
    self.collectionView_custom.delegate = self;
    self.collectionView_custom.dataSource = self.model;
    self.collectionView_custom.bounces = NO;
    self.collectionView_custom.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.collectionView_custom.layer.borderColor = [UIColor blackColor].CGColor;
    self.collectionView_custom.layer.borderWidth = 1;
    [self.view addSubview:self.collectionView_custom];
    
}

//目前還不知道從哪判斷_colleccionView的內容，只知道按下有東西的cell就會進到searchConditionView去
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:_collectionView]) {
        FigureSearchConditionViewController * searchConditionView = [[FigureSearchConditionViewController alloc]initWithCurrentOption:self.model.currentOption SearchNum:(int)indexPath.row+1];
        
        [self.navigationController pushViewController:searchConditionView animated:NO];
    }else{
        //search DB if no data go to CustomCase
        //NSLog(@"%d",self.model.currentOption);
        NSString * gategory =@"";
        
        if (self.model.currentOption ==0) {
            gategory = @"LongSystem";
        }else if (self.model.currentOption ==1){
            gategory = @"ShortSystem";
        }else if (self.model.currentOption ==2){
            gategory = @"LongCustom";
        }else if (self.model.currentOption ==3){
            gategory = @"ShortCustom";
        }
        NSMutableArray * figureSearchArray =[_figureSearchMyProfileModel searchFigureSearchIdWithGategory:gategory ItemOrder:[NSNumber numberWithInteger:indexPath.row+1]];
        int figureSearchId = [(NSNumber *)[figureSearchArray objectAtIndex:0]intValue];
        if ([_figureSearchMyProfileModel CountKbarWithFigureSearchId:[NSNumber numberWithInt:figureSearchId]]) {
            FigureSearchConditionViewController * searchConditionView = [[FigureSearchConditionViewController alloc]initWithCurrentOption:self.model.currentOption SearchNum:(int)indexPath.row+1];
            
            [self.navigationController pushViewController:searchConditionView animated:NO];
        }else{
            FigureCustomCaseViewController * customCaseView = [[FigureCustomCaseViewController alloc]initWithCurrentOption:self.model.currentOption SearchNum:(int)indexPath.row+1];
            
            customCaseView.firstTimeFlag = YES;//bug#10581 wiser
            
            [self.navigationController pushViewController:customCaseView animated:NO];
        }
    }
}


#pragma mark -
#pragma mark Layout處理

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_moreOptionButton, _zeroOptionButton, _collectionView_custom);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_moreOptionButton(44)]-2-[_collectionView_custom]-2-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_collectionView_custom]-2-|" options:0 metrics:nil views:viewControllers]];
    
    // moreOptionButton, zeroOptionButton, scrollView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_moreOptionButton]-2-[_zeroOptionButton(==_moreOptionButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_zeroOptionButton(44)]" options:0 metrics:nil views:viewControllers]];

    
}

#pragma mark -
#pragma mark UIScrollView delegate methods

//- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
//	CGFloat pageWidth = self.scrollView.bounds.size.width;
//    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
//	NSInteger nearestNumber = lround(fractionalPage);
//	
//	if (self.pageControl.currentPage != nearestNumber) {
//		self.pageControl.currentPage = nearestNumber;
//		if (self.scrollView.dragging) {
//                        
//			[self.pageControl updateCurrentPageDisplay] ;
//        }
//	}
//}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView {
//	[self.pageControl updateCurrentPageDisplay] ;
//}

-(void)teachPop{
    self.explainView = [[FSTeachPopView alloc]initWithFrame:CGRectMake(0, 20,[[UIApplication sharedApplication] keyWindow].frame.size.width , [[UIApplication sharedApplication] keyWindow].frame.size.height-20)];
    _explainView.delegate = self;
    _explainView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_explainView];
    
    [_explainView showMenuWithRect:CGRectMake(150, 200, 0, 0) String:NSLocalizedStringFromTable(@"編輯圖示", @"FigureSearch",nil) Detail:YES Direction:KxMenuViewArrowDirectionUp];
    [_explainView addHandImageWithType:@"handTap"Rect:CGRectMake(150, 140, 30, 56)];
}

-(void)closeTeachPop:(UIView *)view{
    //存資料庫
    FSTeachPopView * teachPopView = (FSTeachPopView *)view;
    [view removeFromSuperview];
    if (teachPopView.checkBtn.selected) {
        [_figureSearchMyProfileModel editInstructionByControllerName:[[self class]description] Show:@"NO"];
    }else{
        [_figureSearchMyProfileModel editInstructionByControllerName:[[self class]description] Show:@"YES"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
