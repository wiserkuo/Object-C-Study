//
//  WarrantCollectionView.m
//  FonestockPower
//
//  Created by Kenny on 2014/9/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantCollectionView.h"
#import "WarrantCollectionModel.h"
#import "BtnCollectionView.h"
#import "BtnCollectionViewCell.h"


@interface WarrantCollectionView ()<SecuritySearchDelegate>
{
    FSDataModelProc *dataModal;
    FSUIButton *targetButton;
    BtnCollectionView *topCollectionView;
    BtnCollectionView *bottomCollectionView;
    UILabel *textLabel;
    WarrantCollectionModel *model;
    NSMutableArray *catNameArray;
    NSMutableArray *catIDArray;
    NSMutableArray *fullNameArray;
    NSMutableDictionary *dict;
    int catNum;
    int selectNum;
    int fullNameNum;
}

@property (nonatomic, strong) NSMutableArray *test;
@end

static NSString *itemIdentifier = @"WarrantItemIdentifier";

@implementation WarrantCollectionView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self initModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    model = [WarrantCollectionModel alloc];
    dict = [model getCatName];
    topCollectionView.btnArray = [dict objectForKey:@"TargetName"];
    catIDArray = [dict objectForKey:@"CatID"];
    [topCollectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dataModal = [FSDataModelProc sharedInstance];
    
    [dataModal.securityName setTarget:self];
    
    [dataModal.securityName selectCatID:[(NSNumber *)[catIDArray objectAtIndex:0]intValue]];
    
    fullNameNum = [(NSNumber *)[catIDArray objectAtIndex:0]intValue];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [dataModal.securityName clearCurrID];
}

-(void)notify{
    
    fullNameArray = [model getFullName:fullNameNum];
    bottomCollectionView.btnArray = fullNameArray;
    [topCollectionView reloadData];
    [bottomCollectionView reloadData];
    [FSHUD hideHUDFor:self.view];
}

-(void)initView
{
    
    targetButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    [targetButton setTitle:@"標的" forState:UIControlStateNormal];
    targetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetButton];
    
    textLabel = [[UILabel alloc] init];
    textLabel.text = @"由下列標的物選取股票";
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:textLabel];
    
    UICollectionViewFlowLayout *topLayout = [[UICollectionViewFlowLayout alloc] init];
    topLayout.itemSize = CGSizeMake(100, 44);
    topLayout.minimumInteritemSpacing = 1;
    topLayout.minimumLineSpacing = 1;
    topLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    
    topCollectionView = [[BtnCollectionView alloc] initWithFrame:CGRectMake(3, 10, 310, 200) collectionViewLayout:topLayout];
    topCollectionView.backgroundColor = [UIColor clearColor];
    [topCollectionView setCollectionViewLayout:topLayout animated:YES];
    topCollectionView.myDelegate = self;
    topCollectionView.layer.borderColor = [UIColor blackColor].CGColor;
    topCollectionView.layer.borderWidth = 1;
    topCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topCollectionView];
    
    UICollectionViewFlowLayout *topLayoutB = [[UICollectionViewFlowLayout alloc] init];
    topLayoutB.itemSize = CGSizeMake(100, 44);
    topLayoutB.minimumInteritemSpacing = 1;
    topLayoutB.minimumLineSpacing = 1;
    topLayoutB.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    
    bottomCollectionView = [[BtnCollectionView alloc] initWithFrame:CGRectMake(3, 10, 310, 200) collectionViewLayout:topLayoutB];
    bottomCollectionView.backgroundColor = [UIColor clearColor];
    bottomCollectionView.myDelegate = self;
    bottomCollectionView.layer.borderColor = [UIColor blackColor].CGColor;
    bottomCollectionView.layer.borderWidth = 1;
    bottomCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    bottomCollectionView.holdBtn = 99999;
    [self.view addSubview:bottomCollectionView];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(targetButton, textLabel, topCollectionView, bottomCollectionView);
    NSDictionary *metrics = @{@"imageHeight": @((CGRectGetHeight(self.view.frame) - 58)/5*2)
                              };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[targetButton(33)][topCollectionView][textLabel(25)][bottomCollectionView(imageHeight)]-3-|" options:0 metrics:metrics views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[targetButton(70)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textLabel]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[topCollectionView]-3-|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[bottomCollectionView]-3-|" options:0 metrics:nil views:viewDictionary]];
}

-(void)groupButtonClick:(FSUIButton *)button Object:(BtnCollectionView *)scrl
{
    if([scrl isEqual:topCollectionView]){
        [dataModal.securityName selectCatID:[(NSNumber *)[catIDArray objectAtIndex:button.tag]intValue]];
        fullNameNum = [(NSNumber *)[catIDArray objectAtIndex:button.tag]intValue];
        [FSHUD showHUDin:self.view title:NSLocalizedStringFromTable(@"搜尋中", @"Warrant", nil)];
    }else if([scrl isEqual:bottomCollectionView]){
        self.warrantViewController.targetIdentCode = [[model getIdentCodeSymbol:[fullNameArray objectAtIndex:button.tag]] substringToIndex:2];
        self.warrantViewController.targetSymbol = [[model getIdentCodeSymbol:[fullNameArray objectAtIndex:button.tag]] substringFromIndex:3];
        self.warrantViewController.targetStockName = [fullNameArray objectAtIndex:button.tag];
        [self.navigationController popViewControllerAnimated:NO];
    }
}



@end
