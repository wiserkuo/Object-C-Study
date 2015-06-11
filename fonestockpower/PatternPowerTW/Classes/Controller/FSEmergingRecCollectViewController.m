//
//  RecCollectViewController.m
//  EmergingRec
//
//  Created by Michael.Hsieh on 2014/10/15.
//  Copyright (c) 2014年 Michael. All rights reserved.
//

#import "FSEmergingRecCollectViewController.h"
#import "FSEmergingRecCollectionViewCell.h"
#import "FSEmergingRecommendViewController.h"
#import "FMDB.h"
#import "FSEmergingObject.h"
#import "CodingUtil.h"

@interface FSEmergingRecCollectViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *recCollectionView;
    NSMutableArray *verticalConstrains;
    NSData *resultList;
    NSString *resultListStr;
    NSArray *componentsArray;
    NSMutableArray *brokerMutableArrayWithT;
    NSMutableArray *recMutableArray;
    NSString *timeTemp;
    NSString *timeNULL;
    NSMutableArray *contentMutableArray;
    RecObject * recOO;
    FSDataModelProc *dataModel;
}
@end

@implementation FSEmergingRecCollectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
	// Do any additional setup after loading the view.
}

-(void)notifyDataArrive:(NSObject<TickDataSourceProtocol> *)dataSource{
    
}

-(void)initView{
    resultList = [[NSData alloc]init];
    recOO = [[RecObject alloc] init];
    timeNULL = @"NULL";
    brokerMutableArrayWithT = [[NSMutableArray alloc]init];
    dataModel = [FSDataModelProc sharedInstance];
    componentsArray = [recOO parserRecBrokerNameList:timeNULL :brokerMutableArrayWithT];
    recMutableArray = [recOO getTheDB:componentsArray];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"推薦券商";
    
    verticalConstrains = [[NSMutableArray alloc]init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(80, 30);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
    
    recCollectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    recCollectionView.delegate = self;
    recCollectionView.dataSource = self;
    recCollectionView.backgroundColor = [UIColor clearColor];
    recCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [recCollectionView registerClass:[FSEmergingRecCollectionViewCell class] forCellWithReuseIdentifier:@"FSEmergingRecCollectionViewCell"];
    [self.view addSubview:recCollectionView];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [recMutableArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"FSEmergingRecCollectionViewCell";
    FSEmergingRecCollectionViewCell *cell = (FSEmergingRecCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RecObject *brokerObj = [recMutableArray objectAtIndex:indexPath.row];
    
    cell.label.text = brokerObj.brokerName;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    FSEmergingRecCollectionViewCell *cell = (FSEmergingRecCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    
    RecObject *brokerObj = [recMutableArray objectAtIndex:indexPath.row];
    [RecObject sharedInstance].changeBtnName = brokerObj.brokerName;
    
    [RecObject sharedInstance].brokerIDWithT = [brokerMutableArrayWithT objectAtIndex:indexPath.row];

    NewSymbolObject *newObj;
    [dataModel.portfolioData removeWatchListItemByIdentSymbolArray];
    [dataModel.portfolioTickBank removeIndexQuotesAllKeyWithTaget:_Recommend];
    [dataModel.securityName setTarget:_Recommend];
    [dataModel.securityName selectCatID:[newObj.symbol intValue]];
    [self.navigationController popViewControllerAnimated:NO];
    
    
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
