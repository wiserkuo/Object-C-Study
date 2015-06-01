//
//  RevenueController.h
//  Bullseye
//
//  Created by Ming-Zhe Wu on 2009/1/13.
//  Copyright 2009 NHCUE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataArriveProtocol.h"
#import "SKCustomTableView.h"
//#import "TAtestController.h"
//#import "MultiTouchView.h"

@class RevenueView, Revenue, HMSegmentedControl, PortfolioItem;
//@class TAtestController;
@interface RevenueController : FSUIViewController <UIActionSheetDelegate, UIScrollViewDelegate, SKCustomTableViewDelegate, NewRevenueDelegate> {
	FSDataModelProc *dataModal;
	
	Revenue *revenueData;
	
//	NSArray *revenueHeaderNameArray; //營收
//	
//	NSArray *headerSmybolArray;
	
	//MultiTouchView *multiTouchView;
	
	UIBarButtonItem *barBtn;	
	
	BOOL isSelectACell;
	
}

@property(nonatomic,strong) UIBarButtonItem *barBtn;

@property(nonatomic,readwrite) BOOL isSelectACell;


- (void)changeSegmentIndex:(id)sender;
- (int)getSegmentIndexByHeaderIndex:(int)headerIndex;
- (int)getCurrentPageBySelectedSegmentIndex:(int)selectedIndex;
-(void)sendRequest;
@end
