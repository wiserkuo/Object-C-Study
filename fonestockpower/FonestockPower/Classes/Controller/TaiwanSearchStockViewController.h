//
//  TaiwanSearchStockViewController.h
//  Bullseye
//
//  Created by Neil on 13/9/17.
//
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"

@class CustomBtnInScrollView;
@class BtnCollectionView;

@interface TaiwanSearchStockViewController : FSUIViewController<SecuritySearchDelegate>
@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;

@property (strong, nonatomic) FSUIButton *backToListBtn;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong) UILabel * noStockLabel;
@property (strong) BtnCollectionView * collectionView;
@property (strong) NSMutableArray * data1Array;
@property (strong) NSMutableArray * dataICArray;
@property (strong) NSMutableArray * dataIdArray;
@property (strong) NSMutableArray * userStockArray;
@property (strong) NSMutableArray * userICArray;
@property (nonatomic) BOOL changeStock;

@property (nonatomic) int searchGroup;

@property (nonatomic) UIAlertView *existAlert;

@property (nonatomic) FSUIButton *storeBtn;

@property (nonatomic) NSMutableArray *storeArray;
@property (nonatomic) int totalCount;
@property (nonatomic) int count;
-(void)setSearchGroup;
-(void)reloadButton;
@end
