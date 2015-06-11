//
//  GoodStockViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "GoodStockViewController.h"
#import "GoodStockCollectionViewCell.h"
#import "RealTimeGoodStockViewController.h"
#import "TechnicalGoodStockViewController.h"
#import "BasicGoodStockViewController.h"
#import "ChipGoodStockViewController.h"
#import "AmericaEditChooseViewController.h"
#import "AmericaStockSettingViewController.h"
#import "UIViewController+CustomNavigationBar.h"


@interface GoodStockViewController (){
    NSMutableArray *layoutConstraints;
}

@end

static NSString *ItemIdentifier = @"ItemIdentifier";


@implementation GoodStockViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"飆股密碼";
    [self setUpImageBackButton];
	// Do any additional setup after loading the view.
}

-(void)loadView{
    layoutConstraints = [[NSMutableArray alloc] init];

    self.textArray = [[NSArray alloc]initWithObjects:@"即時面密碼",@"技術面密碼",@"基本面密碼",@"籌碼面密碼", nil];
    self.objDictionary = [[NSMutableDictionary alloc]init];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    aFlowLayout.itemSize = CGSizeMake(102, 102);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 314, 480) collectionViewLayout:aFlowLayout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.collectionView registerClass:[GoodStockCollectionViewCell class] forCellWithReuseIdentifier:ItemIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = NO;

    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"LauncherMainBackground"];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.collectionView setBackgroundView:imageView];
    [_objDictionary setObject:self.collectionView forKey:@"_collectionView"];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    NSMutableArray *constraints = [NSMutableArray new];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:_objDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:_objDictionary]];
    
    [self replaceCustomizeConstraints:constraints];
}

- (void)addCustomizeConstraints:(NSArray *)newConstraints {
    [layoutConstraints addObjectsFromArray:newConstraints];
    [self.view addConstraints:layoutConstraints];
}

- (void)removeCustomizeConstraints {
    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
}

- (void)replaceCustomizeConstraints:(NSArray *)newConstraints {
    [self removeCustomizeConstraints];
    [self addCustomizeConstraints:newConstraints];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        RealTimeGoodStockViewController * realTimeView = [[RealTimeGoodStockViewController alloc]init];
        [self.navigationController pushViewController:realTimeView animated:NO];
    }else if (indexPath.row == 1){
        TechnicalGoodStockViewController * technicalView = [[TechnicalGoodStockViewController alloc]init];
        [self.navigationController pushViewController:technicalView animated:NO];
    }else if (indexPath.row == 2){
        BasicGoodStockViewController * basicView = [[BasicGoodStockViewController alloc]init];
        [self.navigationController pushViewController:basicView animated:NO];
//        AmericaStockSettingViewController * settingView = [[AmericaStockSettingViewController alloc]init];
//        [self.navigationController pushViewController:settingView animated:NO];
    }else if (indexPath.row == 3){
        ChipGoodStockViewController * chipView = [[ChipGoodStockViewController alloc]init];
        [self.navigationController pushViewController:chipView animated:NO];
//        AmericaEditChooseViewController * view = [[AmericaEditChooseViewController alloc]init];
//        [self.navigationController pushViewController:view animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;//物件數量
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodStockCollectionViewCell *cell = (GoodStockCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ItemIdentifier forIndexPath:indexPath];
    
    
    [cell setImage:[UIImage imageNamed:[NSString stringWithFormat:@"q98_menu3_4_%d.png",(int)indexPath.row +1]]];

    [cell setText:[NSString stringWithFormat:@"%@",[_textArray objectAtIndex:indexPath.row]]];
    
    return cell;
}


@end
