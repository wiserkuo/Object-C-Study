//
//  TaiwanStockViewController.h
//  Bullseye
//
//  Created by Neil on 13/9/16.
//
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"

@class TaiwanSearchStockViewController;
@class TaiwanStockListViewController;

@interface TaiwanStockViewController : FSUIViewController<UITextFieldDelegate,SecuritySearchDelegate>


@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;
@property (strong) UITextField * searchText;
@property (strong) FSUIButton * searchBtn;
@property (strong) UILabel * groupTitleLabel;
@property (strong) FSUIButton * groupBtn;
@property (strong) FSUIButton * reNameBtn;
@property (strong) NSMutableDictionary * objDictionary;

@property (strong) NSString * stringV;
@property (strong) NSString * stringH;
@property (nonatomic) int searchGroup;

@property (strong) NSMutableArray * groupIdArray;
@property (strong) NSMutableArray * categoryArray;

@property (retain,nonatomic) TaiwanSearchStockViewController * searchStockView;
@property (retain,nonatomic) TaiwanStockListViewController * stockListView;

@end
