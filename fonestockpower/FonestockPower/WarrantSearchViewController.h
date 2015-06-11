//
//  WarrantSearchViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/10/1.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"
#import "WarrantViewController.h"

@class CustomBtnInScrollView;
@class BtnCollectionView;

@interface WarrantSearchViewController : UIViewController<UITextFieldDelegate,SecuritySearchDelegate>

@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;
@property (nonatomic, strong) WarrantViewController *warrantViewController;
@property (strong) UILabel * titleLabel;
@property (strong) UILabel * noStockLabel;
@property (strong) BtnCollectionView * collectionView;
@property (strong) NSMutableArray * data1Array;
@property (strong) NSMutableArray * dataIdArray;

@property (nonatomic) int searchGroup;

-(void)reloadButton;

@end
