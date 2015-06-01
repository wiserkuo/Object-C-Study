//
//  WarrantSearchViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantSearchViewController.h"
#import "BtnCollectionView.h"
#import "WarrantCollectionModel.h"

@interface WarrantSearchViewController ()
{
    WarrantCollectionModel *model;
}
@end

@implementation WarrantSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initModel];
	[self initView];
    
}

-(void)initModel
{
    model = [WarrantCollectionModel alloc];
}

-(void)initView{
    
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text =NSLocalizedStringFromTable(@"由下列標的物選取股票", @"SecuritySearch", nil);
    _titleLabel.textColor = [UIColor blueColor];
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_titleLabel];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    aFlowLayout.itemSize = CGSizeMake(100, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    _collectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:aFlowLayout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionView.myDelegate = self;
    _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
    
    
    [self.view addSubview:_collectionView];
    
    self.noStockLabel = [[UILabel alloc]init];
    _noStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noStockLabel.text = NSLocalizedStringFromTable(@"無相符個股", @"SecuritySearch", nil);
    _noStockLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_noStockLabel];
    _noStockLabel.hidden = YES;
    
    
    
    [self.view setNeedsUpdateConstraints];
    
}

-(void)reloadButton{
    _collectionView.btnArray = _data1Array;
    _collectionView.holdBtn = 99999;
    [_collectionView reloadData];
}

- (void)updateViewConstraints {
    
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_titleLabel,_collectionView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleLabel]-2-[_collectionView]-1-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_collectionView]-3-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [super updateViewConstraints];
}


-(void)groupButtonClick:(FSUIButton *)button Object:(BtnCollectionView *)scrl{
    self.warrantViewController.targetIdentCode = [[model getIdentCodeSymbol:[_data1Array objectAtIndex:button.tag]] substringToIndex:2];
    self.warrantViewController.targetSymbol = [[model getIdentCodeSymbol:[_data1Array objectAtIndex:button.tag]] substringFromIndex:3];
    self.warrantViewController.targetStockName = [_data1Array objectAtIndex:button.tag];
    [self.navigationController popViewControllerAnimated:NO];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
