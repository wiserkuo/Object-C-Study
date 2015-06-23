//
//  FSLauncherConfigureViewController.m
//  FonestockPower
//
//  Created by Connor on 14/7/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherConfigureViewController.h"
#import "FSLauncherCollectionViewCell.h"
#import "ConnectSettingViewController.h"
#import "FSWebViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "ShopInfoViewController.h"
#import "FSPaymentViewController.h"


@interface FSLauncherConfigureViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    UICollectionView *configureCollectionView;;
}

@end

@implementation FSLauncherConfigureViewController

- (void)viewDidLoad {
    
    // 神乎服務
    self.title = NSLocalizedStringFromTable(@"Service", @"Launcher", nil);
    self.view.backgroundColor = [UIColor colorWithRed:102.0f/255 green:145.0f/255 blue:1.0f/255 alpha:1.0];
    
    [self setupConfigureCollectionView];
    [self setUpImageBackButton];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)setupConfigureCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(120, 120)];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    [layout setSectionInset:UIEdgeInsetsMake(10, 35, 10, 35)];
    
    // layout
    configureCollectionView = [[UICollectionView alloc]
                              initWithFrame:CGRectZero
                              collectionViewLayout:layout];
    [configureCollectionView setBackgroundColor:[UIColor clearColor]];
    configureCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [configureCollectionView registerClass:NSClassFromString(@"FSLauncherCollectionViewCell")
               forCellWithReuseIdentifier:@"newsLinkCollectionView"];
    
    configureCollectionView.delegate = self;
    configureCollectionView.dataSource = self;
    configureCollectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [self.view addSubview:configureCollectionView];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(configureCollectionView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[configureCollectionView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[configureCollectionView]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSLauncherCollectionViewCell *cell;
    cell = (FSLauncherCollectionViewCell *) [cv dequeueReusableCellWithReuseIdentifier:@"newsLinkCollectionView" forIndexPath:indexPath];
    
    cell.title.textColor = [UIColor whiteColor];
#ifdef PatternPowerTW
    cell.title.font = [UIFont boldSystemFontOfSize:18];
#endif
    
    switch (indexPath.row) {
        case 0:
            cell.title.text = NSLocalizedStringFromTable(@"Payment", @"Launcher", @"線上繳費");
            cell.imageView.image = [UIImage imageNamed:@"線上繳費"];
            break;
        case 1:
            cell.title.text = NSLocalizedStringFromTable(@"Setup", @"Launcher", @"連線設定");
            cell.imageView.image = [UIImage imageNamed:@"連線設定"];
            break;
#ifdef PatternPowerTW
        case 2:
            cell.title.text = NSLocalizedStringFromTable(@"Location", @"Launcher", @"門市據點");
            cell.imageView.image = [UIImage imageNamed:@"門市據點"];
            break;
#endif
//        case 3:
//            cell.title.text = NSLocalizedStringFromTable(@"DataBackup", @"Launcher", @"資料備份");
//            cell.imageView.image = [UIImage imageNamed:@"資料備份"];
//            break;
    }
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
       
    switch ([indexPath row]) {
        case 0:
        {
            FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
            FSFonestock *fonestock = [FSFonestock sharedInstance];
            NSString *paymentFullURL = [NSString stringWithFormat:@"%@?acc_id=%@&app_id=%@&lang=%@&request_iap=1&forapp=1", fonestock.paymentPageURL, loginService.account, fonestock.appId, fonestock.lang];
            
            FSPaymentViewController *paymentWebView = [[FSPaymentViewController alloc] initWithPaymentURL:paymentFullURL];
            
            [self.navigationController pushViewController:paymentWebView animated:NO];
            break;
        }
        case 1:
        {
            [self.navigationController pushViewController:[[ConnectSettingViewController alloc] init] animated:NO];
            break;
        }
        case 2:
        {
#ifdef PatternPowerTW
            [self.navigationController pushViewController:[[ShopInfoViewController alloc] init] animated:NO];
            break;
#endif
        }
        case 3:
        {
            break;
        }
    }
}

@end
