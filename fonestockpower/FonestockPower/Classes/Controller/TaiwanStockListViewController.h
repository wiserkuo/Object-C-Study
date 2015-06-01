//
//  TaiwanStockListViewController.h
//  Bullseye
//
//  Created by Neil on 13/9/17.
//
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"


@class CustomBtnInScrollView;
@class BtnCollectionView;

@interface TaiwanStockListViewController : FSUIViewController<SecuritySearchDelegate, UIAlertViewDelegate>



- (void) notify;

@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;

@property (strong)NSMutableDictionary * objDictionary;

@property (retain,nonatomic) CustomBtnInScrollView * titleScrollView1;
@property (retain,nonatomic) NSMutableArray * titleData1;
@property (retain,nonatomic) NSMutableArray * titleId1;

@property (retain,nonatomic) CustomBtnInScrollView * titleScrollView2;
@property (retain,nonatomic) NSMutableArray * titleData2;
@property (retain,nonatomic) NSMutableArray * titleId2;

@property (strong) BtnCollectionView * group1CollectionView;
@property (retain,nonatomic) CustomBtnInScrollView * btnGroup1;
@property (nonatomic)int group1Height;
@property (nonatomic)int group1Width;
@property (retain) NSMutableArray * data1Array;
@property (retain) NSMutableArray * id1Array;

@property (strong) UILabel * titleLabel;
@property (strong) UILabel * promptLabel;

@property (strong) BtnCollectionView * group2CollectionView;
@property (retain,nonatomic) CustomBtnInScrollView * btnGroup2;
@property (nonatomic)int group2Height;
@property (nonatomic)int group2Width;
@property (retain) NSMutableArray * data2Array;
@property (retain) NSMutableArray * id2Array;
@property (retain) NSMutableArray * id2IdentCodeArray;


@property (strong) BtnCollectionView * group3CollectionView;
@property (retain) NSMutableArray * data3Array;
@property (retain) NSMutableArray * id3Array;

@property (strong) NSString * stringV;
@property (strong)id groupIndex;

@property (strong) NSString * searchText;

@property (nonatomic) int searchGroup;

@property (strong) NSMutableArray * dataIdArray;
@property (strong) NSMutableArray * dataICArray;

@property (nonatomic) BOOL changeStock;

@property (nonatomic) UIAlertView *existAlert;

@property (nonatomic) FSUIButton *storeBtn;

@property (nonatomic) NSMutableArray *storeArray;

-(void)editTotalCount:(NSNumber *)count;
-(void)setSearchGroup;


@end

@interface ForPlateOnly : NSObject
@property (nonatomic, strong) NSString *stringData;
@property (nonatomic, strong) NSString *catIDData;
@end