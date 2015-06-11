//
//  FSSnapshot.m
//  FonestockPower
//
//  Created by Connor on 14/7/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSnapshot.h"

@implementation FSSnapshot

//bit 1
- (void)setOpen_price:(FSBValueFormat *)open_price{
    if (open_price != nil) _open_price = open_price;
}
- (void)setHigh_price:(FSBValueFormat *)high_price{
    if (high_price != nil) _high_price = high_price;
}
- (void)setLow_price:(FSBValueFormat *)low_price{
    if (low_price != nil) _low_price = low_price;
}
- (void)setLast_price:(FSBValueFormat *)last_price{
    if (last_price != nil) _last_price = last_price;
}
- (void)setVolume:(FSBValueFormat *)volume{
    if (volume != nil) _volume = volume;
}
- (void)setAccumulated_volume:(FSBValueFormat *)accumulated_volume{
    if (accumulated_volume != nil) _accumulated_volume = accumulated_volume;
}
- (void)setPrevious_volume:(FSBValueFormat *)previous_volume{
    if (previous_volume != nil) _previous_volume = previous_volume;
}

//bit 2
- (void)setTop_price:(FSBValueFormat *)top_price {
    if (top_price != nil) _top_price = top_price;
}
- (void)setBottom_price:(FSBValueFormat *)bottom_price {
    if (bottom_price != nil) _bottom_price = bottom_price;
}

//bit 3
- (void)setBid_price:(FSBValueFormat *)bid_price {
    if (bid_price != nil) _bid_price = bid_price;
}
- (void)setAsk_price:(FSBValueFormat *)ask_price {
    if (ask_price != nil) _ask_price = ask_price;
}

//bit 4
- (void)setBid_volume:(FSBValueFormat *)bid_volume {
    if (bid_volume != nil) _bid_volume = bid_volume;
}
- (void)setAsk_volume:(FSBValueFormat *)ask_volume {
    if (ask_volume != nil) _ask_volume = ask_volume;
}

//bit 9
- (void)setInner_price:(FSBValueFormat *)inner_price {
    if (inner_price != nil) _inner_price = inner_price;
}
- (void)setOuter_price:(FSBValueFormat *)outer_price {
    if (outer_price != nil) _outer_price = outer_price;
}

//指數
- (void)setDeal_volume:(FSBValueFormat *)deal_volume {
    if (deal_volume != nil) _deal_volume = deal_volume;
}
- (void)setUp_count:(FSBValueFormat *)up_count {
    if (up_count != nil) _up_count = up_count;
}
- (void)setDown_count:(FSBValueFormat *)down_count {
    if (down_count != nil) _down_count = down_count;
}
- (void)setUnchange_count:(FSBValueFormat *)unchange_count {
    if (unchange_count != nil) _unchange_count = unchange_count;
}

- (void)setDealRecord:(FSBValueFormat *)dealRecord {
    if (dealRecord != nil) _dealRecord = dealRecord;
}
- (void)setBidRecord:(FSBValueFormat *)bidRecord {
    if (bidRecord != nil) _bidRecord = bidRecord;
}
- (void)setAskRecord:(FSBValueFormat *)askRecord {
    if (askRecord != nil) _askRecord = askRecord;
}

// snapshot2
- (void)setHighest_52week_volume:(FSBValueFormat *)highest_52week_volume {
    if (highest_52week_volume != nil) _highest_52week_volume = highest_52week_volume;
}
- (void)setLowest_52week_volume:(FSBValueFormat *)lowest_52week_volume {
    if (lowest_52week_volume != nil) _lowest_52week_volume = lowest_52week_volume;
}
- (void)setAverage_3month_volume:(FSBValueFormat *)average_3month_volume {
    if (average_3month_volume != nil) _average_3month_volume = average_3month_volume;
}

 // snapshot3
- (void)setCdp_ah:(FSBValueFormat *)cdp_ah {
    if (cdp_ah != nil) _cdp_ah = cdp_ah;
}
- (void)setCdp_nh:(FSBValueFormat *)cdp_nh {
    if (cdp_nh != nil) _cdp_nh = cdp_nh;
}
- (void)setCdp_nl:(FSBValueFormat *)cdp_nl {
    if (cdp_nl != nil) _cdp_nl = cdp_nl;
}
- (void)setCdp_al:(FSBValueFormat *)cdp_al {
    if (cdp_al != nil) _cdp_al = cdp_al;
}
- (void)setCdp:(FSBValueFormat *)cdp {
    if (cdp != nil) _cdp = cdp;
}

 // snapshot4
- (void)setEps:(FSBValueFormat *)eps {
    if (eps != nil) _eps = eps;
}
- (void)setAnnual_divided:(FSBValueFormat *)annual_divided {
    if (annual_divided != nil) _annual_divided = annual_divided;
}
- (void)setTotal_equity:(FSBValueFormat *)total_equity {
    if (total_equity != nil) _total_equity = total_equity;
}
- (void)setIssued_shares:(FSBValueFormat *)issued_shares {
    if (issued_shares != nil) _issued_shares = issued_shares;
}


@end
