//
//  BtnCollectionView.h
//  WirtsLeg
//
//  Created by Neil on 13/10/8.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"


@interface BtnCollectionView : UICollectionView<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SecuritySearchDelegate>
@property (strong, nonatomic)NSMutableArray * btnArray ;
@property (strong, nonatomic)NSMutableArray * chooseArray ;
@property (strong, nonatomic) NSMutableDictionary * btnDictionary;
@property (weak, nonatomic) id <SecuritySearchDelegate> myDelegate;
@property (nonatomic) UIControlContentHorizontalAlignment aligment;
@property (nonatomic) int holdBtn;
@property (nonatomic) int searchGroup; //0=TW ,1=US
@property (nonatomic) int btnFlag;
@property (nonatomic) BOOL btnSelectOnlyOne;
@property NSInteger rowCount;
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)aFlowLayout;
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)aFlowLayout rowCount:(NSInteger)rowCount;
@end
