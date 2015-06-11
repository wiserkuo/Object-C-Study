//
//  FSSnapshot.h
//  FonestockPower
//
//  Created by Connor on 14/7/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSSnapshot : NSObject {
    // bit 3
    //FSBValueFormat *bid_price;
    //FSBValueFormat *ask_price;
    // bit 4
    //FSBValueFormat *best_bid_volume;
    //FSBValueFormat *best_ask_volume;
    // bit 5
    //FSBValueFormat *deal_volume;
    // bit 6
    //FSBValueFormat *deal_record;
    //FSBValueFormat *bid_record;
    //FSBValueFormat *ask_record;
    //FSBValueFormat *bid_volume;
    //FSBValueFormat *ask_volume;
    
    
    // snapshot
    
}

@property NSString *identCodeSymbol;
@property UInt32 securityNumber;

//bit 1
@property FSDateFormat *trading_date;
@property FSBTimeFormat *tick_time;
@property (strong, nonatomic)FSBValueFormat *reference_price;
@property (strong, nonatomic)FSBValueFormat *open_price;
@property (strong, nonatomic)FSBValueFormat *high_price;
@property (strong, nonatomic)FSBValueFormat *low_price;
@property (strong, nonatomic)FSBValueFormat *last_price;
@property (strong, nonatomic)FSBValueFormat *volume;
@property (strong, nonatomic)FSBValueFormat *accumulated_volume;
@property (strong, nonatomic)FSBValueFormat *previous_volume;
//bit 2
@property (strong, nonatomic)FSBValueFormat *top_price;
@property (strong, nonatomic)FSBValueFormat *bottom_price;
//bit 3
@property (strong, nonatomic)FSBValueFormat *bid_price;
@property (strong, nonatomic)FSBValueFormat *ask_price;
//bit 4
@property (strong, nonatomic)FSBValueFormat *bid_volume;
@property (strong, nonatomic)FSBValueFormat *ask_volume;
//bit 9
@property (strong, nonatomic)FSBValueFormat *inner_price;
@property (strong, nonatomic)FSBValueFormat *outer_price;

//指數
@property (strong, nonatomic)FSBValueFormat *pre_volume;
@property (strong, nonatomic)FSBValueFormat *deal_volume;
@property (strong, nonatomic)FSBValueFormat *up_count;
@property (strong, nonatomic)FSBValueFormat *down_count;
@property (strong, nonatomic)FSBValueFormat *unchange_count;

@property (strong, nonatomic)FSBValueFormat *dealRecord;
@property (strong, nonatomic)FSBValueFormat *bidRecord;
@property (strong, nonatomic)FSBValueFormat *askRecord;

// snapshot2
@property (strong, nonatomic)FSBValueFormat *highest_52week_volume;
@property (strong, nonatomic)FSBValueFormat *lowest_52week_volume;
@property (strong, nonatomic)FSBValueFormat *average_3month_volume;

// snapshot3
@property (strong, nonatomic)FSBValueFormat *cdp_ah;
@property (strong, nonatomic)FSBValueFormat *cdp_nh;
@property (strong, nonatomic)FSBValueFormat *cdp_nl;
@property (strong, nonatomic)FSBValueFormat *cdp_al;
@property (strong, nonatomic)FSBValueFormat *cdp;

// snapshot4
@property (strong, nonatomic)FSBValueFormat *eps;
@property (strong, nonatomic)FSBValueFormat *annual_divided;
@property (strong, nonatomic)FSBValueFormat *total_equity;
@property (strong, nonatomic)FSBValueFormat *issued_shares;


//五檔

@property NSMutableArray * BABidArray;
@property NSMutableArray * BAAskArray;



@property BOOL snapshotQueryFlag;

@end