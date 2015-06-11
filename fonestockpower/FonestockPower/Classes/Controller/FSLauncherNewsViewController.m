//
//  FSLauncherNewsViewController.m
//  FonestockPower
//
//  Created by Connor on 14/6/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSLauncherNewsViewController.h"
#import "FSLauncherCollectionViewCell.h"
#import "FSWebViewController.h"
#import "FSLauncherConfigureViewController.h"
#import "MacroeconomicViewController.h"
#import "InternationalInfoMaterialViewController.h"
#import "IndexQuotesViewController.h"

@interface FSLauncherNewsViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    UICollectionView *newsLinkCollectionView;
    
}
@end

@implementation FSLauncherNewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNewsLinkCollectionView];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNewsLinkCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake(120, 120)];
    [layout setMinimumInteritemSpacing:0];
    [layout setMinimumLineSpacing:0];
    [layout setSectionInset:UIEdgeInsetsMake(10, 35, 10, 35)];
    
    // layout
    newsLinkCollectionView = [[UICollectionView alloc]
                              initWithFrame:CGRectZero
                              collectionViewLayout:layout];
    [newsLinkCollectionView setBackgroundColor:[UIColor clearColor]];
    newsLinkCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [newsLinkCollectionView registerClass:NSClassFromString(@"FSLauncherCollectionViewCell")
               forCellWithReuseIdentifier:@"newsLinkCollectionView"];
    
    newsLinkCollectionView.delegate = self;
    newsLinkCollectionView.dataSource = self;
    newsLinkCollectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [self.view addSubview:newsLinkCollectionView];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(newsLinkCollectionView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[newsLinkCollectionView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[newsLinkCollectionView]|" options:0 metrics:nil views:viewControllers]];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSLauncherCollectionViewCell *cell;
    cell = (FSLauncherCollectionViewCell *) [cv dequeueReusableCellWithReuseIdentifier:@"newsLinkCollectionView" forIndexPath:indexPath];
    
    cell.title.textColor = [UIColor whiteColor];
    
    switch (indexPath.row) {
        case 0:
            cell.title.text = NSLocalizedStringFromTable(@"總經", @"Launcher", nil);
            cell.imageView.image = [UIImage imageNamed:@"Macroeconomic"];
            break;
        case 1:
        {
            cell.title.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
            cell.title.shadowOffset = CGSizeMake(1.0f, 1.0f);
            cell.title.attributedText = [[NSAttributedString alloc]
                                         initWithString:NSLocalizedStringFromTable(@"Service", @"Launcher", nil)
                                         attributes:@{
                                                      //                                                 NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-3.0],
                                                      //                                                 NSStrokeColorAttributeName:[UIColor blackColor],
                                                      NSForegroundColorAttributeName:[UIColor whiteColor]
                                                      }
                                         ];
            cell.imageView.image = [UIImage imageNamed:@"Service"];
            break;
        }


        case 2:
            cell.title.text = NSLocalizedStringFromTable(@"國際資訊", @"Launcher", nil);
            cell.imageView.image = [UIImage imageNamed:@"Service"];
            break;
        case 3:
            cell.title.text = NSLocalizedStringFromTable(@"指數行情", @"Launcher", nil);
            cell.imageView.image = [UIImage imageNamed:@"Service"];
            break;
        default:
            break;
    }
    return cell;
}


#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([indexPath row]) {
        case 0:
        {
            if (self.parentViewController != nil) {
                [self.parentViewController.navigationController pushViewController:[[MacroeconomicViewController alloc] init] animated:NO];
            } else {
                [self.navigationController pushViewController:[[MacroeconomicViewController alloc] init] animated:NO];
            }
            return;
        }
        case 1:
        {
            if (self.parentViewController != nil) {
                [self.parentViewController.navigationController pushViewController:[[FSLauncherConfigureViewController alloc] init] animated:NO];
            } else {
                [self.navigationController pushViewController:[[FSLauncherConfigureViewController alloc] init] animated:NO];
            }
            return;
        }


        case 2:
            if (self.parentViewController != nil) {
                [self.parentViewController.navigationController pushViewController:[[InternationalInfoMaterialViewController alloc] init] animated:NO];
            } else {
                [self.navigationController pushViewController:[[InternationalInfoMaterialViewController alloc] init] animated:NO];
            }
            return;
        case 3:
            if (self.parentViewController != nil) {
                [self.parentViewController.navigationController pushViewController:[[IndexQuotesViewController alloc] init] animated:NO];
            } else {
                [self.navigationController pushViewController:[[IndexQuotesViewController alloc] init] animated:NO];
            }
            return;

        default:
            break;
    }
}

@end
