//
//  FSMainViewController.h
//  FonestockPower
//
//  Created by Connor on 14/3/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FSMainMenuItem) {
    QuoteMenuItem = 0,
    TechMenuItem,
    BasicMenuItem,
    ChipMenuItem
};

typedef NS_ENUM(NSUInteger, FSQuoteMenuItem) {
    ChartMenuItem = 0,
    ListMenuItem,
    DistMenuItem,
    PsItem
};

typedef NS_ENUM(NSUInteger, FSBasicMenuItem) {
    ProfileMenuItem = 0,
    RevMenuItem,
    EpsMenuItem,
    FinanceItem
};

typedef NS_ENUM(NSUInteger, FSChipMenuItem) {
    TodayReserveMenuItem = 0,
    MarginTradingMenuItem,
    InstitutionalMenuItem,
    PowerMenuItem,
    PowerPMenuItem,
    PowerPPMenuItem,
    PowerPPPMenuItem,
};

@interface FSMainViewController : UIViewController

@property (nonatomic) FSMainMenuItem firstLevelMenuOption;
@property (nonatomic) FSChipMenuItem secondChipMenuOption;
@property (nonatomic) FSBasicMenuItem secondBasicMenuOption;
@property (nonatomic) AnalysisPeriod techOption;
@property (nonatomic) UInt16 arrowDate;
@property (nonatomic) UInt16 buyDay;
@property (nonatomic) UInt16 sellDay;
@property (strong, nonatomic) NSMutableDictionary * dateDictionary;
@property (strong, nonatomic) NSMutableDictionary * gainDateDictionary;
@property (nonatomic) AnalysisPeriod arrowType;
@property (nonatomic) int performanceNum;
@property (strong, nonatomic) NSString * performanceNote;
@property (nonatomic) int arrowUpDownType;//1:Long 2:short 3:buy,sell 4:buyArray
@property (strong, nonatomic) id mainViewController;
@property (nonatomic) BOOL status;

@end
