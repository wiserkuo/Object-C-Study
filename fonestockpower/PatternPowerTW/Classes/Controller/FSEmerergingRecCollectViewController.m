//
//  RecCollectViewController.m
//  EmergingRec
//
//  Created by Michael.Hsieh on 2014/10/15.
//  Copyright (c) 2014年 Michael. All rights reserved.
//

#import "FSEmerergingRecCollectViewController.h"
#import "FSEmergingRecCollectionViewCell.h"
#import "FMDB.h"
#import "FSEmergingObject.h"

@interface FSEmerergingRecCollectViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *recCollectionView;
    NSMutableArray *verticalConstrains;
    NSData *resultList;
    NSString *resultListStr;
    NSArray *componentsArray;
    NSMutableArray *comMutableArray;
    NSMutableArray *recMutableArray;
    NSString *timeTemp;
    NSString *timeNULL;
    RecObject * recOO;
}
@end

@implementation FSEmerergingRecCollectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
	// Do any additional setup after loading the view.
}

-(void)initView{
    resultList = [[NSData alloc]init];
    recOO = [[RecObject alloc] init];
    timeNULL = @"NULL";
    //    componentsArray = [recOO textParser:timeNULL];
    [self textParser];
    recMutableArray = [recOO getTheDB:componentsArray];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"推薦券商";
    
    verticalConstrains = [[NSMutableArray alloc]init];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(70, 40);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
    
    recCollectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    recCollectionView.delegate = self;
    recCollectionView.dataSource = self;
    recCollectionView.backgroundColor = [UIColor clearColor];
    recCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [recCollectionView registerClass:[FSEmergingRecCollectionViewCell class] forCellWithReuseIdentifier:@"FSEmergingRecCollectionViewCell"];
    [self.view addSubview:recCollectionView];
    
}
-(void)textParser{
    
    NSArray *pathCacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [pathCacheDir objectAtIndex:0];
    NSString *recBroker = [cachePath stringByAppendingPathComponent:@"recBroker"];
    NSString *urlRecBrokerListPath  = [NSString stringWithFormat:@"http://kqstock.fonestock.com:2172/query/emg_broker.cgi?cmd=broker_list&time_stamp=%@",timeNULL];
    
    resultList = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlRecBrokerListPath]] returningResponse:nil error:nil];
    resultListStr = [[NSString alloc]initWithData:resultList encoding:NSUTF8StringEncoding];
    
    [resultListStr writeToFile:recBroker atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSArray *comArray = [resultListStr componentsSeparatedByString:@"\n"];
    comMutableArray = [[NSMutableArray alloc]initWithArray:comArray];
    
    [comMutableArray removeObjectAtIndex:0];
    [comMutableArray removeLastObject];
    
    NSString *comStr = [comMutableArray componentsJoinedByString:@","];
    comStr = [comStr stringByReplacingOccurrencesOfString:@"9A0T" withString:@"9910"];
    comStr = [comStr stringByReplacingOccurrencesOfString:@"T" withString:@"0"];
    componentsArray = [comStr componentsSeparatedByString:@","];
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
    FSEmergingRecCollectionViewCell *cell = (FSEmergingRecCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    cell.backgroundColor = [UIColor redColor];
    
    RecObject *brokerObj = [recMutableArray objectAtIndex:indexPath.row];
    [RecObject sharedInstance].changeBtnName = brokerObj.brokerName;
    
    [RecObject sharedInstance].brokerIDWithT = [comMutableArray objectAtIndex:indexPath.row];
    [recOO parserRecBroker:[RecObject sharedInstance].brokerIDWithT :timeNULL];
    NSLog(@"[RecObject sharedInstance].recBrokerSymbol : %@", [RecObject sharedInstance].recBrokerSymbol);
    
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
